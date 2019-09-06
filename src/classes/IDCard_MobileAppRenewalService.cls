public with sharing class IDCard_MobileAppRenewalService
{
    private static final String RENEWAL_ITEM_RENEWAL = 'RENEWAL';
    private static final String RENEWAL_ITEM_TRAINING_1 = 'TRAINING_1';
    private static final String RENEWAL_ITEM_TRAINING_2 = 'TRAINING_2';
    private static final String RENEWAL_ITEM_EXPEDITE = 'EXPEDITE';

    public static final String CARD_TYPE_PLASTIC = 'plastic';
    public static final String CARD_TYPE_DIGITAL = 'digital';

    /**
     * Rewal process workflow:
     *   0. validate the input & get auxiliar values
     *   1. get the contact IDCA
     *   2. create the new IDCA
     *     2.1. set the agent specialization fields
     *     2.2. update the payment information
     *     2.3. update the training courses information
     *     2.4. update and validate the promotion code
     *     2.5. the docs?
     *   3. create the Case
     *     3.1. send the case creation email to the Agent
     *     3.2. send post pardot
     *   4. auto approve Case
     *   5. create the IDC
     *     5.1. define the card dates based on the previous IDC
     *     5.2. set the printing information based on agent location (US agents = digital)
     *     5.3. set the printing information based on the card type (plastic, digital)
     *     5.4. set the training courses information based on the related IDCA and previous IDC
     *     5.5. set the WebStar_P00_Key__c field on the new card
     *   6. update the Case to "Closed" on digital cards
     *   9. return the IDCA, Case and IDC information
     */
    public static IDCard_ServiceResponse renewCard(String iataCode, String verNumber, IDCard_RenewalRequest request)
    {
        // 0. validate the input & get auxiliar values
        if (String.isBlank(iataCode))
            return IDCard_ServiceResponse.makeErrorServiceResponse(Label.IDCard_IATACodeRequired);
        if (iataCode.trim().length() != 8)
            return IDCard_ServiceResponse.makeErrorServiceResponse(Label.IDCard_IATACodeNot8Digits);
        if (String.isBlank(verNumber))
            return IDCard_ServiceResponse.makeErrorServiceResponse(Label.IDCard_VERrequired);

        iataCode = iataCode.trim();
        
        Contact contact = getContact(iataCode, verNumber);
        
        String acccountType = getAccountType(contact);
        IATA_ISO_Country__c contactCountry = getContactCountry(iataCode);
        
        checkBlacklistedCard(contact, iataCode, verNumber);

        Price_Table__c prices = getPriceTable(acccountType, contactCountry);

        if (contact.VER_Number_2__c == null)
            throw new IDCardException(Label.IDCard_NumericFieldError);
        
        checkPendingCases(contact, iataCode, verNumber);

        // 1. get the current IDCA
        ID_Card_Application__c currentIdCardApplication = getCurrentIDCA(iataCode, verNumber);

        // 2. create the new IDCA
        ID_Card_Application__c newIdCardApplication = createNewIDCA(currentIdCardApplication, request);

        //   2.1. set the agent specialization fields
        setAgentSpecialization(newIdCardApplication, request);

        //   2.2. update the payment information
        setPaymentInformation(newIdCardApplication, request, prices);

        //   2.3. update the training courses information
        setTrainingCourses(newIdCardApplication, request);

        //   2.4. update and validate the promotion code
        setAndValidatePromotion(newIdCardApplication, request);

        // 3. create the Case
        //   3.1. send the case creation email to the Agent
        insert newIdCardApplication;
        Case c = createCaseAndSendEmail(newIdCardApplication);

        //   3.2. send post pardot
        postPardot(newIdCardApplication, request, c);

        // 4. auto approve Case
        // 5. create the IDC
        //   5.1. define the card dates based on the previous IDC
        approveCaseAndCreateIDC(newIdCardApplication, c);
        ID_Card__c idCard = getIdCardFromApplication(newIdCardApplication);
        
        //   5.2. set the printing information based on agent location (US agents = digital)
        setIdCardType(newIdCardApplication, idCard, contactCountry);

        //   5.3. set the printing information based on the card type (plastic, digital)
        setIdCardPrintingOptions(idCard);

        //   5.4. set the training courses information based on the related IDCA and previous IDC
        setAgentSpecialization(idCard, newIdCardApplication, currentIdCardApplication);

        //   5.5. set the WebStar_P00_Key__c field on the new card
        setWebStarField(idCard, currentIdCardApplication);

        // 6. update the Case to "Closed" on digital cards
        closeDigitalCase(c, idCard);

        update idCard;

        return makeServiceResponse(newIdCardApplication, idCard, c);
    }

    private static IDCard_ServiceResponse makeServiceResponse(ID_Card_Application__c newIDCA, Id_Card__c idCard, Case c)
    {
        c = [SELECT Id, CaseNumber FROM Case WHERE Id = :c.Id];

        Map<String, Object> values = new Map<String, Object>();
        values.put('caseNumber', c.CaseNumber);
        values.put('idCardId', idCard.Id);
        values.put('idCardApplicationId', newIDCA.Id);
        values.put('caseId', c.Id);

        String uir = newIDCA.UIR__c;
        if (String.isBlank(uir) && String.isNotBlank(idCard.Photo__c))
            uir = idCard.Photo__c.replaceAll('[^0-9]*', '');
        values.put('uir', uir);
        values.put('webstarKey', idCard.WebStar_P00_Key__c);

        return IDCard_ServiceResponse.makeGenericServiceResponse(values);
    }

    private static void setIdCardPrintingOptions(Id_Card__c idCard)
    {
        if (CARD_TYPE_PLASTIC.equals(idCard.Card_Type__c))
        {
            // already defined on IDCardUtil
        }
        else if (CARD_TYPE_DIGITAL.equals(idCard.Card_Type__c))
        {
            idCard.MustSyncWithAIMS__c = false;
            idCard.Card_Status__c = IDCardUtil.CARDSTATUS_VALID;
            idCard.Sent_to_AIMS_on__c = System.now().date();
            idCard.Received_From_AIMS__c = System.now().date();
        }
    }

    private static void setIdCardType(ID_Card_Application__c newIDCA, Id_Card__c idCard, IATA_ISO_Country__c contactCountry)
    {
        String type = newIDCA.Card_Type__c;
        if ('US'.equals(contactCountry.ISO_Code__c))
            type = CARD_TYPE_DIGITAL;
        idCard.Card_Type__c = type;
        System.debug('Checking US agent ' + newIDCA.Card_Type__c + ' ' + type + ' ' + contactCountry.ISO_Code__c);
    }

    private static Id_Card__c getIdCardFromApplication(ID_Card_Application__c currentIDCA)
    {
        List<Id_Card__c> idCards = [SELECT Id, ASF_Current_Function__c, ASF_Percentage_of_Annual_Booking__c,
                                        ASF_Market_Specialization__c, ASF_Market_Specialization_Comment__c,
                                        ASF_Market_Focus__c, ASF_Specializing_on_Destination__c,
                                        ASF_Completed_Travel_Courses__c, ASF_Last_Completed_Travel_Course__c,
                                        ASF_FAM_Trips__c, WebStar_P00_Key__c
                                    FROM Id_Card__c
                                    WHERE ID_Card_Application__c = :currentIDCA.Id];
        
        if (idCards.isEmpty())
            throw new IDCardException('No card from id application found');
        
        return idCards.get(0);
    }

    private static void approveCaseAndCreateIDC(ID_Card_Application__c currentIDCA, Case c)
    {
        Case c2 = c;
        if (c2.CaseNumber == null)
            c2 = [SELECT Id, CaseNumber, Status FROM Case WHERE Id = :c2.Id];
        
        String result = IDCardUtil.UpdateCaseToApproved_Rejected(c2.CaseNumber, true);
        if (! result.contains('true') && ! result.contains('false'))
            throw new IDCardException(result);
        
        currentIDCA = new ID_Card_Application__c(Id = currentIDCA.Id);
        currentIDCA.Single_Application_Processing_Step__c = 'Processed';
        update currentIDCA;
    }

    private static void closeDigitalCase(Case c, Id_Card__c idCard)
    {
        if (CARD_TYPE_DIGITAL.equals(idCard.Card_Type__c))
        {
            c = new Case(Id = c.Id);
            c.Status = 'Closed';
            update c;
        }
    }

    private static Case createCaseAndSendEmail(ID_Card_Application__c currentIDCA)
    {
        Account theAccount = IDCardUtil.GetAccountObjectFromIATACode(currentIDCA.IATA_Code__c);
        Case c = IDCardUtil.createKeyAccountIdCardApplicationCase(currentIDCA, theAccount);

        // update status to send email using workflow rule and "IDCard_ConfirmationEmail" template email
        Case c2 = new Case(Id = c.Id);
        c2.Subject = 'Case for Mobile ID Card Application ' + [SELECT Name FROM ID_Card_Application__c WHERE Id = :currentIDCA.Id].Name;
        c2.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ID_Card_Application');
        c2.OwnerId = System.UserInfo.getUserId();
        c2.Status = 'Agent to be Notified';
        c2.Origin = 'ID Card Mobile';
        update c2;

        //currentIDCA.Case_Number__c = c.CaseNumber; set automatically on the "IDCard_ConfirmationEmail" template email
        return c;
    }
    
    private static ID_Card_Application__c createNewIDCA(ID_Card_Application__c currentIDCA, IDCard_RenewalRequest request)
    {
        ID_Card_Application__c newIDCA = currentIDCA.clone();
        newIDCA.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Standard');
        System.debug('currentIDCA RecordTypeId: ' + currentIDCA.RecordTypeId);
        System.debug('newIDCA RecordTypeId: ' + newIDCA.RecordTypeId);
        newIDCA.Application_Status__c = 'Temp';
        newIDCA.Type_of_Application__c = IDCardUtil.APPLICATIONTYPE_RENEWAL;
        newIDCA.Renewal_From_Replace__c = false;
        newIDCA.Single_Application_Processing_Step__c = IDCardUtil.single_application_status_waiting;

        newIDCA.Card_Type__c = CARD_TYPE_PLASTIC;
        if (request.typeOfCard != null)
            newIDCA.Card_Type__c = request.typeOfCard;
            
        newIDCA.Mobile_App_Transaction_Id__c = request.orderId;
        newIDCA.Mobile_App_Request__c = JSON.serialize(request);

        return newIDCA;
    }

    private static void setPaymentInformation(ID_Card_Application__c newIDCA, IDCard_RenewalRequest request,
                                              Price_Table__c prices)
    {
        IDCard_RenewalRequest.Payment payment = request.payment;
        if (payment == null)
            throw new IDCardException('No Payment information received');
        
        Account account = IDCardUtil.GetAccountObjectFromIATACode(newIDCA.IATA_Code__c);
        
        newIDCA.Application_Status__c = 'Processing Successfull payment';

        newIDCA.Payment_Credit_Card_Number__c = payment.cardNumber;
        newIDCA.Payment_Transaction_Number__c = payment.transactionNumber;
        newIDCA.Payment_Amount__c = payment.amount != null ? payment.amount : 0;
        newIDCA.Payment_Date__c = convertDate(payment.orderDate);
        newIDCA.Payment_Currency__c = payment.cur != null ? payment.cur.toUpperCase() : null;
        newIDCA.Payment_Type__c = IDCardUtil.PAYMENT_TYPE_CC;

        IDCard_RenewalRequest.Items cardRenewal = getRequestItem(request, RENEWAL_ITEM_RENEWAL);
        IDCard_RenewalRequest.Items shipping = getRequestItem(request, RENEWAL_ITEM_EXPEDITE);
        IDCard_RenewalRequest.Items training1 = getRequestItem(request, RENEWAL_ITEM_TRAINING_1);
        IDCard_RenewalRequest.Items training2 = getRequestItem(request, RENEWAL_ITEM_TRAINING_2);

        Double trainingFee = null;
        if (training1 != null || training2 != null)
        {
            trainingFee = (training1 == null || training1.price == null ? 0 : training1.price) +
                          (training2 == null || training2.price == null ? 0 : training2.price);
        }

        newIDCA.IDCard_Expedite_Delivery__c = prices.Expedite_Delivery_added_to_IDCard_Price__c;
        newIDCA.Applicable_Fee__c = getRequestItemTotalAmount(request);
        newIDCA.ID_Card_Fee__c = cardRenewal == null ? 0 : cardRenewal.price;
        newIDCA.IDCard_Expedite_Delivery_Fee__c = shipping == null ? 0 : shipping.price;
        newIDCA.ITDI_Courses_Fee__c = trainingFee == null ? 0 : trainingFee;
        newIDCA.CurrencyIsoCode = prices.CurrencyIsoCode;

        setTaxes(newIDCA, prices, account);
    }

    private static String convertDate(String iso8601)
    {
        try
        {
            if (String.isNotBlank(iso8601))
            {
                System.debug('/*/*/*/* iso8601 ' + iso8601);
                string dateConverted = iso8601.subString(0, 13) + ':' + iso8601.subString(13, 15) +
                                    ':' + iso8601.subString(15, iso8601.length());
                System.debug('/*/*/*/* dateConverted ' + dateConverted);
                DateTime dt = (DateTime) JSON.deserialize('"' + dateConverted + '"', DateTime.class);
                return (DateTime.newInstance(dt.getTime())).format('dd-MMMM-yyyy HH:mm:ss') + ' GMT';
            }
            else
            {
                System.debug('******** String Date IS NULL');
                return '';
            }
        }
        catch(Exception e)
        {
            System.debug('Exception converting date: ' + e);
            throw new IDCardException('Invalid payment date');
        }
    }

    private static void setTaxes(ID_Card_Application__c newIDCA, Price_Table__c prices, Account account)
    {
        newIDCA.Tax_1_Name__c = null;
        newIDCA.Tax_1_Value__c = null;
        newIDCA.Tax_2_Name__c = null;
        newIDCA.Tax_2_Value__c = null;

        account = [SELECT BillingState, BillingCountry FROM Account WHERE Id = :account.Id];
        Map<String, String> taxes = IDCardTaxUtil.GetTaxes(account.BillingState, account.BillingCountry);
        List<String> taxNames = new List<String>();
        taxNames.addAll(taxes.keySet());

        if (taxNames.size() == 1)
        {
            String name1 = taxNames.get(0);
            String percentage1 = taxes.get(name1);
            newIDCA.Tax_1_Name__c = name1 + '(' + percentage1 + '%)' ;
            newIDCA.Tax_1_Value__c = IDCardTaxUtil.CalculateTaxes(percentage1, String.ValueOf(newIDCA.Applicable_Fee__c)) + ' '+ newIDCA.CurrencyIsoCode;
        }
        else if (taxNames.size() == 2)
        {
            String name1 = taxNames.get(0);
            String percentage1 = taxes.get(name1);
            String name2 = taxNames.get(1);
            String percentage2 = taxes.get(name2);

            newIDCA.Tax_1_Name__c = name1 + '(' + percentage1 + '%)' ;
            newIDCA.Tax_2_Name__c = name2 + '(' + percentage2 + '%)' ;

            Decimal totalTaxPercentage = Decimal.valueOf(percentage1) + Decimal.valueOf(percentage2);
            Decimal totalTaxAmount = Decimal.valueOf(IDCardTaxUtil.CalculateTaxes(String.valueOf(totalTaxPercentage), String.ValueOf(newIDCA.Applicable_Fee__c)));

            Decimal taxAmount1 = totalTaxAmount / totalTaxPercentage * Decimal.valueOf(percentage1);
            Decimal taxAmount2 = totalTaxAmount / totalTaxPercentage * Decimal.valueOf(percentage2);

            newIDCA.Tax_1_Value__c = taxAmount1.setScale(2) + ' ' + newIDCA.CurrencyIsoCode;
            newIDCA.Tax_2_Value__c = taxAmount2.setScale(2) + ' ' + newIDCA.CurrencyIsoCode;
        }

        newIDCA.Profit_Center__c = prices.Profit_Center__c;
    }

    private static void setAndValidatePromotion(ID_Card_Application__c newIDCA, IDCard_RenewalRequest request)
    {
        if (request.payment == null)
            throw new IDCardException('No Payment information received');

        try
        {
            validatePromotion(newIDCA, request);
        }
        catch (Exception e)
        {
            // NOTHING - ignored the validation as the promotion was already applied in the payment
        }

        newIDCA.Promotion_Code__c = request.payment.promotionCode;
    }

    private static void validatePromotion(ID_Card_Application__c newIDCA, IDCard_RenewalRequest request)
    {
        // Promotion code must exists, must be associated to the corresponding Price Table and be between the validity period
        if (String.isNotBlank(request.payment.promotionCode))
        {
            List<Promotion__c> promotionLst = [SELECT p.Promotion_Value__c, p.Promotion_Duration_Valid_Up_to__c,
                                                p.Promotion_Duration_Valid_From__c, p.Promotion_Code__c,
                                                p.Type_of_Application__c
                                               FROM Promotion__c p
                                               WHERE p.Promotion_Code__c = :request.payment.promotionCode];
            
            if (promotionLst.isEmpty())
                throw new IDCardException(String.Format(Label.ID_Card_Invalid_Promotion_Code, new String[] { request.payment.promotionCode }));

            Boolean hasTypeOfApplication = false;
            for (String typeOfApp : promotionLst.get(0).Type_of_Application__c.split(';'))
            {
                System.debug('Validating promotion: ' + typeOfApp + ' ' + newIDCA.Type_of_Application__c);

                if (newIDCA.Type_of_Application__c.equals(typeOfApp))
                {
                    hasTypeOfApplication = true;
                    break;
                }
            }

            if (! hasTypeOfApplication)
                throw new IDCardException(String.Format(Label.ID_Card_Invalid_Promotion_Code_2, new String[] { request.payment.promotionCode }));
            if (promotionLst.get(0).Promotion_Duration_Valid_Up_to__c < Date.today())
                throw new IDCardException(Label.ID_Card_Promotion_Code_No_Longer_Valid);
            if (promotionLst.get(0).Promotion_Duration_Valid_From__c > Date.today())
                throw new IDCardException(Label.ID_Card_Promotion_Code_Not_Yet_Valid);
        }
    }

    private static void setAgentSpecialization(ID_Card_Application__c newIDCA, IDCard_RenewalRequest request)
    {
        newIDCA.ASF_Current_Function__c = null;
        newIDCA.ASF_Percentage_of_Annual_Booking__c = null;
        newIDCA.ASF_Market_Specialization__c = null;
        newIDCA.ASF_Market_Specialization_Comment__c = null;
        newIDCA.ASF_Market_Focus__c = null;
        newIDCA.ASF_Specializing_on_Destination__c = null;
        newIDCA.ASF_Completed_Travel_Courses__c = null;
        newIDCA.ASF_Last_Completed_Travel_Course__c = null;
        newIDCA.ASF_FAM_Trips__c = null;

        if (request.specializationFields != null)
        {
            newIDCA.ASF_Current_Function__c = request.specializationFields.ASF_Current_Function;
            newIDCA.ASF_Percentage_of_Annual_Booking__c = request.specializationFields.ASF_Percentage_of_Annual_Booking;
            newIDCA.ASF_Market_Specialization__c = request.specializationFields.ASF_Market_Specialization;
            newIDCA.ASF_Market_Specialization_Comment__c = request.specializationFields.ASF_Market_Specialization_Comment;
            newIDCA.ASF_Market_Focus__c = request.specializationFields.ASF_Market_Focus;
            newIDCA.ASF_Specializing_on_Destination__c = request.specializationFields.ASF_Specializing_on_Destination;
            newIDCA.ASF_Completed_Travel_Courses__c = request.specializationFields.ASF_Completed_Travel_Courses;
            newIDCA.ASF_Last_Completed_Travel_Course__c = request.specializationFields.ASF_Last_Completed_Travel_Course;
            newIDCA.ASF_FAM_Trips__c = request.specializationFields.ASF_FAM_Trips;
        }
    }

    private static void setAgentSpecialization(Id_Card__c idCard, ID_Card_Application__c newIDCA, ID_Card_Application__c oldIDCA)
    {
        // if there is any blank on the request: get the values from the previous IDC
        Id_Card__c oldIdCard = null;
        if (String.isBlank(newIDCA.ASF_Current_Function__c) || String.isBlank(newIDCA.ASF_Percentage_of_Annual_Booking__c)
            || String.isBlank(newIDCA.ASF_Market_Specialization__c) || String.isBlank(newIDCA.ASF_Market_Focus__c)
            || String.isBlank(newIDCA.ASF_Specializing_on_Destination__c) || String.isBlank(newIDCA.ASF_Completed_Travel_Courses__c)
            || String.isBlank(newIDCA.ASF_Last_Completed_Travel_Course__c) || String.isBlank(newIDCA.ASF_FAM_Trips__c))
        {
            try
            {
                oldIdCard = getIdCardFromApplication(oldIDCA);
            } catch (Exception e) {
                // NOTHING
            }
        }

        idCard.ASF_Current_Function__c = String.isBlank(newIDCA.ASF_Current_Function__c) && oldIdCard != null ? oldIdCard.ASF_Current_Function__c : newIDCA.ASF_Current_Function__c;
        idCard.ASF_Percentage_of_Annual_Booking__c = String.isBlank(newIDCA.ASF_Percentage_of_Annual_Booking__c) && oldIdCard != null ? oldIdCard.ASF_Percentage_of_Annual_Booking__c : newIDCA.ASF_Percentage_of_Annual_Booking__c;
        idCard.ASF_Market_Specialization__c = String.isBlank(newIDCA.ASF_Market_Specialization__c) && oldIdCard != null ? oldIdCard.ASF_Market_Specialization__c : newIDCA.ASF_Market_Specialization__c;
        idCard.ASF_Market_Specialization_Comment__c = String.isBlank(newIDCA.ASF_Market_Specialization_Comment__c) && oldIdCard != null ? oldIdCard.ASF_Market_Specialization_Comment__c : newIDCA.ASF_Market_Specialization_Comment__c;
        idCard.ASF_Market_Focus__c = String.isBlank(newIDCA.ASF_Market_Focus__c) && oldIdCard != null ? oldIdCard.ASF_Market_Focus__c : newIDCA.ASF_Market_Focus__c;
        idCard.ASF_Specializing_on_Destination__c = String.isBlank(newIDCA.ASF_Specializing_on_Destination__c) && oldIdCard != null ? oldIdCard.ASF_Specializing_on_Destination__c : newIDCA.ASF_Specializing_on_Destination__c;
        idCard.ASF_Completed_Travel_Courses__c = String.isBlank(newIDCA.ASF_Completed_Travel_Courses__c) && oldIdCard != null ? oldIdCard.ASF_Completed_Travel_Courses__c : newIDCA.ASF_Completed_Travel_Courses__c;
        idCard.ASF_Last_Completed_Travel_Course__c = String.isBlank(newIDCA.ASF_Last_Completed_Travel_Course__c) && oldIdCard != null ? oldIdCard.ASF_Last_Completed_Travel_Course__c : newIDCA.ASF_Last_Completed_Travel_Course__c;
        idCard.ASF_FAM_Trips__c = String.isBlank(newIDCA.ASF_FAM_Trips__c) && oldIdCard != null ? oldIdCard.ASF_FAM_Trips__c : newIDCA.ASF_FAM_Trips__c;
        update idCard;
    }

    private static void setWebStarField(Id_Card__c idCard, ID_Card_Application__c oldIDCA)
    {
        // if there is any blank on the request: get the values from the previous IDC
        Id_Card__c oldIdCard = getIdCardFromApplication(oldIDCA);

        if (oldIdCard != null && oldIdCard.WebStar_P00_Key__c != null)
        {
            idCard.WebStar_P00_Key__c = oldIdCard.WebStar_P00_Key__c;
            update idCard;
        }
    }

    private static void setTrainingCourses(ID_Card_Application__c newIDCA, IDCard_RenewalRequest request)
    {
        IDCard_RenewalRequest.Items training1 = getRequestItem(request, RENEWAL_ITEM_TRAINING_1);
        IDCard_RenewalRequest.Items training2 = getRequestItem(request, RENEWAL_ITEM_TRAINING_2);

        if (training1 == null && training2 != null)
        {
            training1 = training2;
            training2 = null;
        }

        newIDCA.Package_of_Travel_Professionals_Course_1__c = training1 == null ? null : training1.training;
        newIDCA.Package_of_Travel_Professionals_Course_2__c = training2 == null ? null : training2.training;
    }

    private static IDCard_RenewalRequest.Items getRequestItem(IDCard_RenewalRequest request, String code)
    {
        if (request.items != null)
        {
            for (IDCard_RenewalRequest.Items item : request.items)
            {
                if (code.equals(item.id))
                    return item;
            }
        }

        return null;
    }

    private static Double getRequestItemTotalAmount(IDCard_RenewalRequest request)
    {
        Double amount = 0;
        if (request.items != null)
        {
            for (IDCard_RenewalRequest.Items item : request.items)
                amount += item.price;
        }

        return amount;
    }


    private static ID_Card_Application__c getCurrentIDCA(String iataCode, String verNumber)
    {
        ID rectypeid = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card__c', 'AIMS');

        List<ID_Card__c> allCards = [SELECT i.VER_Number__c, i.Middle_Initial__c, i.LastName__c, i.FirstName__c, i.Email__c,
                                        i.Date_of_Birth__c, i.Agency_Name__c, i.Agency_IATA_Code__c, i.ID_Card_Application__c
                                     FROM ID_Card__c i
                                     WHERE i.RecordTypeId = :rectypeid
                                        AND i.VER_Number__c = :verNumber
                                        AND i.Card_Status__c != :IDCardUtil.CARDSTATUS_CANCELED
                                        AND i.ID_Card_Application__c != NULL
                                     ORDER BY i.Valid_To_Date__c DESC
                                     LIMIT 1];

        if (allCards.isEmpty())
            throw new IDCardException('No card found');
        
        ID_Card_Application__c idCard = [SELECT i.Payment_Amount__c, i.VER_Number__c, i.RecordTypeId, i.Revenue_Confirmation__c,
                                            i.UIR__c, i.Type_of_Application__c, i.Title__c, i.Telephone__c, i.SystemModstamp,
                                            i.Start_Date_Industry__c, i.Start_Date_Agency_Year__c, i.Start_Date_Agency_Month__c,
                                            i.Solicitation_Flag__c, i.Promotion_Code__c, i.Position_in_Current_Agency__c,
                                            i.Position_Code__c, i.Photo__c, i.Package_of_Travel_Professionals_Course_2__c,
                                            i.Package_of_Travel_Professionals_Course_1__c, i.OwnerId, i.Name, i.Middle_Initial__c,
                                            i.Last_Name__c, i.LastModifiedDate, i.LastModifiedById, i.IsDeleted, i.Id,
                                            i.IDCard_Prefered_Language__c, i.IDCard_Expedite_Delivery__c,
                                            i.IDCard_Expedite_Delivery_Fee__c, i.IATA_numeric_code_previous_employer_4__c,
                                            i.IATA_numeric_code_previous_employer_3__c, i.IATA_numeric_code_previous_employer_2__c,
                                            i.IATA_numeric_code_previous_employer_1__c, i.IATA_Code_for_previous_agency__c,
                                            i.IATA_Code__c, i.Hours_worked__c, i.Hours_Worked_Code__c, i.Gender__c, i.First_Name__c,
                                            i.Email_admin__c, i.Duties_in_Current_Agency__c, i.Duties_Code__c, i.Displayed_Name__c,
                                            i.Date_of_Birth__c, i.CurrencyIsoCode, i.CreatedDate, i.CreatedById,
                                            i.Approving_Manager_s_Name__c, i.Approving_Manager_s_Email__c, i.Applicable_Fee__c,
                                            i.Regional_Office__c, i.AgencyShare_Confirmation__c, i.Revenue_Confirmation_Validation_Failed__c,
                                            i.ID_Card_Fee__c, i.ITDI_Courses_Fee__c, i.Tax_1_Name__c, i.Tax_1_Value__c, i.Tax_2_Name__c,
                                            i.Tax_2_Value__c, i.Profit_Center__c, i.ASF_Current_Function__c,
                                            i.ASF_Percentage_of_Annual_Booking__c, i.ASF_Market_Specialization__c,
                                            i.ASF_Market_Specialization_Comment__c, i.ASF_Market_Focus__c, i.ASF_Specializing_on_Destination__c,
                                            i.ASF_Completed_Travel_Courses__c, i.ASF_Last_Completed_Travel_Course__c, i.ASF_FAM_Trips__c
                                         FROM ID_Card_Application__c i
                                         WHERE i.Id = :allCards.get(0).ID_Card_Application__c
                                         LIMIT 1];

        return idCard;
    }
    
    private static void checkPendingCases(Contact contact, String verNumber, String iataCode)
    {
        List<Case> pendingCase = [SELECT Id 
                                  FROM Case
                                  WHERE RecordType.Name = 'ID Card Application'
                                      AND Contact.Id = :contact.Id
                                      AND status <> 'Closed'
                                      LIMIT 1];
        
        String tempVerNumber = 'Z' + verNumber;
        List<ID_Card_Application__c> pendingIdCardsApp = [SELECT Id
                                                          FROM ID_Card_Application__c
                                                          WHERE RecordType.Name = 'Single ID Card Operation' 
                                                                  AND (VER_Number__c = :verNumber OR VER_Number__c = :tempVerNumber)
                                                                  AND (Application_Status__c = 'Pending' OR Application_Status__c = 'Unpaid')
                                                          LIMIT 1];
        if (! pendingCase.isEmpty())
            throw new IDCardException('There is already a pending case application');
        if (! pendingIdCardsApp.isEmpty())
            throw new IDCardException('There is already a pending application');
    }
    
    public static Price_Table__c getPriceTable(String acccountType, IATA_ISO_Country__c contactCountry)
    {
        List<Price_Table__c> listPriceTables = [SELECT Name, CurrencyIsoCode, Expedite_Delivery_added_to_IDCard_Price__c,
                                                    Expedite__c, IATA_Package__c, ID_Card_Fee__c, Type_Class_of_Agent__c,
                                                    Profit_Center__c, Cost_of_Printer__c
                                                FROM Price_Table__c
                                                WHERE Type_Class_of_Agent__c = :acccountType
                                                    AND ISO_Country__r.Id = :contactCountry.Id];
        if (listPriceTables.isEmpty())
            throw new IDCardException('Please Contact IDCard Support with the following message: Price Table not found for the following Country:' + contactCountry.Name );
        return listPriceTables.get(0);
    }

    private static void checkBlacklistedCard(Contact contact, String verNumber, String iataCode)
    {
        for (ID_Card__c aCard : [SELECT Id, Blacklisted__c, Card_Status__c
                                 FROM ID_Card__c
                                 WHERE Related_Contact__c = :contact.Id
                                 ORDER BY CreatedDate DESC])
        {
            if (aCard.Blacklisted__c)
            {
                mailAlertOnBlackListedConnection(aCard, verNumber, iataCode);
                throw new IDCardException('Your IATA/IATAN ID Card has been blacklisted. For more information, please kindly contact IATA Customer Service on www.iata.org/cs');
            }
        }
    }

    private static void mailAlertOnBlackListedConnection(ID_Card__c card, String verNumber, String iataCode)
    {
        /*
        // logic disabled
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setToAddresses(new String[] {'jfonteray@gmail.com'});
        mail.setSubject('A blacklisted agent has tried to sign in on ID Card Online Platform. VER: ' + verNumber + ' IATA Code: ' + iataCode);
        mail.setPlainTextBody('A blacklisted agent has tried to sign in on ID Card Online Platform. VER: ' + verNumber + ' IATA Code: ' + iataCode);

        List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
        lstMsgs.add(mail);

        try {
            Messaging.sendEmail(lstMsgs);
        } catch (Exception  e) {
            system.debug('Failed to send email ' + e.getMessage());
        }*/
    }
    
    private static void postPardot(ID_Card_Application__c currentIDCA, IDCard_RenewalRequest request, Case c)
    {
        if (request.payment == null || ! sendPardot())
            return;

        String payLoad = 'email=' + currentIDCA.Email_admin__c;
        payLoad += '&paymentDate=' + request.payment.orderDate;
        payLoad += '&paymentAmount=' + request.payment.amount;
        payLoad += '&paymentCurrency=' + request.payment.cur;
        payLoad += '&CaseNumber=' + c.CaseNumber;

        system.debug('Post pardor payLoad: ' + payLoad);

        if (! Test.isRunningTest())
            postPardot(payLoad);
    }

    @Future(Callout=true)
    private static void postPardot(String payLoad)
    {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('http://go.updates.iata.org/l/123902/2017-02-09/7kl76z/');
        req.setTimeout(60000);
        req.setMethod('POST');
        req.setBody(payLoad);
        HttpResponse res = h.send(req);
    }

    private static Boolean sendPardot()
    {
        for (Id_Card_Mobile_Pardot__c setting : Id_Card_Mobile_Pardot__c.getAll().values())
        {
            return setting.isActive__c;
        }

        return false;
    }

    public static IATA_ISO_Country__c getContactCountry(String iataCode)
    {
        try
        {
            return IDCardUtil.GetIATAISOCountryOfContact(iataCode);
        }
        catch (Exception e)
        {
            throw new IDCardException('Please Contact IDCard Support with the following message: ISO Country not found for the following Account: ' + iataCode);
        }
    }

    public static String getAccountType(Contact contact)
    {
        return IDCardUtil.GetAgentTypeFromAccountType(contact.Account.Type);
    }

    public static String getAccountType(String iataCode)
    {
        Account theAccount = IDCardUtil.GetAccountObjectFromIATACode(iataCode);
        return IDCardUtil.GetAgentTypeFromAccountType(theAccount.Type);
    }

    public static Contact getContact(String iataCode, String verNumber)
    {
        ID rectypeid = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card__c', 'AIMS');
        
        List<Contact> contacts = [SELECT c.VER_Number_2__c, c.FirstName, c.LastName, c.Date_of_Birth__c,
                                    c.Account.IDCard_Key_Account__c, c.Account.Type, c.Account.Short_Name__c,
                                    c.Account.Is_AIMS_Account__c , c.Id, c.Account.Status__c, c.Account.IATACode__c,
                                    c.Account.ID_Card_KeyAccount_features__c
                                  FROM Contact c
                                  WHERE c.Id IN (SELECT i.Related_Contact__c
                                                 FROM ID_Card__c i
                                                 WHERE i.RecordTypeId = :rectypeid)
                                    AND c.RecordType.Name = 'Standard'
                                    AND c.Account.RecordType.Name = 'Agency'
                                    AND (c.Account.Status__c IN :IDCardUtil.ALLOWED_ACCOUNT_STATUS
                                         OR Account.Status__c = 'Terminated')
                                    AND c.Account.IATACode__c = :iataCode
                                    AND c.Account.type IN :IDCardUtil.ALLOWED_ACCOUNT_TYPES
                                    AND c.VER_Number_2__c = :verNumber];

        if (contacts == null || contacts.size() == 0)
            throw new IDCardException(Label.IDCard_NoContactsFound);
        return contacts.get(0);
    }

    public class IDCardException extends Exception { }
}