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
     *     3.0. [for US Agents] create a new Contact (if not created before)
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
        RequestInformation requestInformation = new RequestInformation(iataCode, verNumber, request);

        // 0. validate the input & get auxiliar values
        if (String.isBlank(requestInformation.iataCode))
            return IDCard_ServiceResponse.makeErrorServiceResponse(Label.IDCard_IATACodeRequired);
        if (requestInformation.iataCode.length() != 8)
            return IDCard_ServiceResponse.makeErrorServiceResponse(Label.IDCard_IATACodeNot8Digits);
        if (String.isBlank(requestInformation.verNumber))
            return IDCard_ServiceResponse.makeErrorServiceResponse(Label.IDCard_VERrequired);

        requestInformation.contactCountry = getContactCountry(requestInformation.iataCode);
        requestInformation.isUSAgent = 'US'.equals(requestInformation.contactCountry.ISO_Code__c);

        // for US Agents
        if (requestInformation.isUSAgent)
        {
            Id_Card__c lastIDC = getLastIdCard(requestInformation);
            if (lastIDC.ID_Card_Application__c == null) // no IDCA associated, use the US logic (inferes a IDCA)
                return renewCardForUSAgent(requestInformation, lastIDC.Id);
            // else, used the NON US Agents
        }

        // for NON US Agents (clones the previous IDCA)
        return renewCardForNonUSAgent(requestInformation);
    }

    public static IDCard_ServiceResponse renewCardForUSAgent(RequestInformation requestInformation, Id lastIDCId)
    {
        System.debug('renewCardForUSAgent: ' + lastIDCId + ' ' + requestInformation);

        // 0. validate the input & get auxiliar values - cont.
        try
        {
            requestInformation.contact = getContact(requestInformation.iataCode, requestInformation.verNumber);
        }
        catch (Exception e)
        {
            // NOTHING - the US Agents might not have a Contact
        }

        requestInformation.account = IDCardUtil.GetAccountObjectFromIATACode(requestInformation.iataCode);
        
        requestInformation.accountType = getAccountType(requestInformation.account);
        
        checkBlacklistedCard(requestInformation);

        requestInformation.prices = getPriceTable(requestInformation.accountType, requestInformation.contactCountry);
        
        //checkPendingCases(requestInformation); // No case in US Agents

        // 1. get the current IDCA
        requestInformation.lastIDC = getIdCardFromId(lastIDCId);
        requestInformation.lastIDCA = createIDCAForUSAgent(requestInformation);

        if (requestInformation.contact == null) // because it can only be one Contact per VER#
            requestInformation.contact = getContact(requestInformation.verNumber);

        // 2. create the new IDCA
        requestInformation.newIDCA = createNewIDCA(requestInformation);

        //   2.1. set the agent specialization fields
        setIDCAAgentSpecialization(requestInformation);

        //   2.2. update the payment information
        setPaymentInformation(requestInformation);

        //   2.3. update the training courses information
        setTrainingCourses(requestInformation);

        //   2.4. update and validate the promotion code
        setAndValidatePromotion(requestInformation);

        // 3. create the Case
        //   3.0. [for US Agents] create a new Contact (if not created before)
        createContactForUSAgent(requestInformation);
        updateIdCardContact(requestInformation);

        //   3.1. send the case creation email to the Agent
        insert requestInformation.newIDCA;
        requestInformation.idcaCase = createCaseAndSendEmail(requestInformation);

        //   3.2. send post pardot
        postPardot(requestInformation);

        // 4. auto approve Case
        // 5. create the IDC
        //   5.1. define the card dates based on the previous IDC
        approveCaseAndCreateIDC(requestInformation);
        requestInformation.newIDC = getIdCardFromApplication(requestInformation.newIDCA.Id);
        
        //   5.2. set the printing information based on agent location (US agents = digital)
        setIdCardType(requestInformation);

        //   5.3. set the printing information based on the card type (plastic, digital)
        setIdCardPrintingOptions(requestInformation);

        //   5.4. set the training courses information based on the related IDCA and previous IDC
        setIDCAgentSpecialization(requestInformation);

        //   5.5. set the WebStar_P00_Key__c field on the new card
        setWebStarField(requestInformation);

        // 6. update the Case to "Closed" on digital cards
        closeDigitalCase(requestInformation);

        update requestInformation.newIDC;

        return makeServiceResponse(requestInformation);
    }

    public static IDCard_ServiceResponse renewCardForNonUSAgent(RequestInformation requestInformation)
    {
        System.debug('renewCardForNonUSAgent: ' + requestInformation);

        // 0. validate the input & get auxiliar values - cont.
        requestInformation.contact = getContact(requestInformation.iataCode, requestInformation.verNumber);
        
        requestInformation.account = IDCardUtil.GetAccountObjectFromIATACode(requestInformation.iataCode);
        
        requestInformation.accountType = getAccountType(requestInformation.contact);

        checkBlacklistedCard(requestInformation);
        
        requestInformation.prices = getPriceTable(requestInformation.accountType, requestInformation.contactCountry);

        checkPendingCases(requestInformation);

        // 1. get the current IDCA
        requestInformation.lastIDCA = getCurrentIDCA(requestInformation);
        requestInformation.lastIDC = getIdCardFromApplication(requestInformation.lastIDCA.Id);

        // 2. create the new IDCA
        requestInformation.newIDCA = createNewIDCA(requestInformation);

        //   2.1. set the agent specialization fields
        setIDCAAgentSpecialization(requestInformation);

        //   2.2. update the payment information
        setPaymentInformation(requestInformation);

        //   2.3. update the training courses information
        setTrainingCourses(requestInformation);

        //   2.4. update and validate the promotion code
        setAndValidatePromotion(requestInformation);

        // 3. create the Case
        //   3.1. send the case creation email to the Agent
        insert requestInformation.newIDCA;
        requestInformation.idcaCase = createCaseAndSendEmail(requestInformation);

        //   3.2. send post pardot
        postPardot(requestInformation);

        // 4. auto approve Case
        // 5. create the IDC
        //   5.1. define the card dates based on the previous IDC
        approveCaseAndCreateIDC(requestInformation);
        requestInformation.newIDC = getIdCardFromApplication(requestInformation.newIDCA.Id);
        
        //   5.2. set the printing information based on agent location (US agents = digital)
        setIdCardType(requestInformation);

        //   5.3. set the printing information based on the card type (plastic, digital)
        setIdCardPrintingOptions(requestInformation);

        //   5.4. set the training courses information based on the related IDCA and previous IDC
        setIDCAgentSpecialization(requestInformation);

        //   5.5. set the WebStar_P00_Key__c field on the new card
        setWebStarField(requestInformation);

        // 6. update the Case to "Closed" on digital cards
        closeDigitalCase(requestInformation);

        update requestInformation.newIDC;

        return makeServiceResponse(requestInformation);
    }

    private static IDCard_ServiceResponse makeServiceResponse(RequestInformation requestInformation)
    {
        Case c = [SELECT Id, CaseNumber FROM Case WHERE Id = :requestInformation.idcaCase.Id];

        Map<String, Object> values = new Map<String, Object>();
        values.put('caseNumber', c.CaseNumber);
        values.put('idCardId', requestInformation.newIDC.Id);
        values.put('idCardApplicationId', requestInformation.newIDCA.Id);
        values.put('caseId', c.Id);

        String uir = requestInformation.newIDCA.UIR__c;
        if (String.isBlank(uir) && String.isNotBlank(requestInformation.newIDC.Photo__c))
            uir = requestInformation.newIDC.Photo__c;
        values.put('uir', (String.isBlank(uir) ? '' : uir).replaceAll('[^0-9]*', ''));
        values.put('webstarKey', requestInformation.newIDC.WebStar_P00_Key__c);

        return IDCard_ServiceResponse.makeGenericServiceResponse(values);
    }

    private static void setIdCardPrintingOptions(RequestInformation requestInformation)
    {
        if (CARD_TYPE_PLASTIC.equals(requestInformation.newIDC.Card_Type__c))
        {
            // already defined on IDCardUtil
        }
        else if (CARD_TYPE_DIGITAL.equals(requestInformation.newIDC.Card_Type__c))
        {
            requestInformation.newIDC.MustSyncWithAIMS__c = false;
            requestInformation.newIDC.Card_Status__c = IDCardUtil.CARDSTATUS_VALID;
            requestInformation.newIDC.Sent_to_AIMS_on__c = System.now().date();
            requestInformation.newIDC.Received_From_AIMS__c = System.now().date();
        }
    }

    private static void setIdCardType(RequestInformation requestInformation)
    {
        String type = requestInformation.newIDCA.Card_Type__c;
        if (requestInformation.isUSAgent)
            type = CARD_TYPE_DIGITAL;
        requestInformation.newIDC.Card_Type__c = type;

        System.debug('Checking US agent ' + requestInformation.newIDCA.Card_Type__c + ' ' +
            type + ' ' + requestInformation.contactCountry.ISO_Code__c);
    }

    private static Id_Card__c getIdCardFromApplication(Id appId)
    {
        List<Id_Card__c> idCards = [SELECT Id, ASF_Current_Function__c, ASF_Percentage_of_Annual_Booking__c,
                                        ASF_Market_Specialization__c, ASF_Market_Specialization_Comment__c,
                                        ASF_Market_Focus__c, ASF_Specializing_on_Destination__c,
                                        ASF_Completed_Travel_Courses__c, ASF_Last_Completed_Travel_Course__c,
                                        ASF_FAM_Trips__c, WebStar_P00_Key__c, Photo__c
                                    FROM Id_Card__c
                                    WHERE ID_Card_Application__c = :appId];
        
        if (idCards.isEmpty())
            throw new IDCardException('No card from id application found');
        
        return idCards.get(0);
    }

    private static Id_Card__c getIdCardFromId(Id idCardId)
    {
        List<Id_Card__c> idCards = [SELECT Id, Approving_Manager_s_Name__c, Approving_Manager_s_Email__c, Blacklisted__c,
                                        CurrencyIsoCode, Date_of_Birth__c, Duties__c, Email__c, Fee_Applicable__c,
                                        FirstName__c, Gender__c, Hours_per_week__c, Is_Expedite__c, LastName__c,
                                        Middle_Initial__c, Name_on_ID_Card__c, Nature_of_ID_Card__c, Position__c,
                                        Photo__c, Phone__c, Profit_Center__c, Payment_Type__c, Renewal_From_Replace__c,
                                        Start_Date_Industry__c, Start_Date_Agency_Month__c, Start_Date_Agency_Year__c,
                                        Title__c, VER_Number__c, WebStar_P00_Key__c, ASF_Current_Function__c,
                                        ASF_Percentage_of_Annual_Booking__c, ASF_Market_Specialization__c,
                                        ASF_Market_Specialization_Comment__c, ASF_Market_Focus__c, ASF_Specializing_on_Destination__c,
                                        ASF_Completed_Travel_Courses__c, ASF_Last_Completed_Travel_Course__c, ASF_FAM_Trips__c,
                                        Related_Contact__c
                                    FROM Id_Card__c
                                    WHERE Id = :idCardId];
        
        if (idCards.isEmpty())
            throw new IDCardException('No card from id application found');
        
        return idCards.get(0);
    }

    private static Id_Card__c getLastIdCard(RequestInformation requestInformation)
    {
        List<Id_Card__c> idCards = [SELECT Id, ID_Card_Application__c, Related_Contact__c, WebStar_P00_Key__c
                                    FROM Id_Card__c
                                    WHERE VER_Number__c = :requestInformation.verNumber
                                    ORDER BY CreatedDate DESC];
        
        if (idCards.isEmpty())
            throw new IDCardException('No card from id application found');
        
        return idCards.get(0);
    }

    private static void approveCaseAndCreateIDC(RequestInformation requestInformation)
    {
        Case c2 = requestInformation.idcaCase;
        if (c2.CaseNumber == null)
            c2 = [SELECT Id, CaseNumber, Status FROM Case WHERE Id = :c2.Id];
        
        String result = IDCardUtil.UpdateCaseToApproved_Rejected(c2.CaseNumber, true);
        if (! result.contains('true') && ! result.contains('false'))
            throw new IDCardException(result);
        
        ID_Card_Application__c newIDCA = new ID_Card_Application__c(Id = requestInformation.newIDCA.Id);
        newIDCA.Single_Application_Processing_Step__c = 'Processed';
        update newIDCA;
    }

    private static void closeDigitalCase(RequestInformation requestInformation)
    {
        if (CARD_TYPE_DIGITAL.equals(requestInformation.newIDC.Card_Type__c))
        {
            Case c = new Case(Id = requestInformation.idcaCase.Id);
            c.Status = 'Closed';
            update c;
        }
    }

    private static void createContactForUSAgent(RequestInformation requestInformation)
    {
        if (requestInformation.contact == null)
        {
            Contact theContact = new Contact();
            theContact.RecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
            theContact.AccountId = requestInformation.account.Id;
            theContact.LastName = requestInformation.lastIDCA.Last_Name__c;
            theContact.IDCard_Email__c = requestInformation.lastIDCA.Email_admin__c;
            theContact.Approving_Manager_s_Name__c = requestInformation.lastIDCA.Approving_Manager_s_Name__c;
            theContact.Approving_Manager_s_Email__c = requestInformation.lastIDCA.Approving_Manager_s_Email__c;
            theContact.ID_Card_Preferred_Language__c = requestInformation.lastIDCA.IDCard_Prefered_Language__c;
            theContact.FirstName = requestInformation.lastIDCA.First_Name__c;
            theContact.Salutation = requestInformation.lastIDCA.Title__c;
            theContact.Date_of_Birth__c = requestInformation.lastIDCA.Date_of_Birth__c;
            theContact.Gender__c = requestInformation.lastIDCA.Gender__c;
            theContact.Middle_Initial__c = requestInformation.lastIDCA.Middle_Initial__c;
            theContact.Phone = requestInformation.lastIDCA.Telephone__c;
            theContact.Position__c = requestInformation.lastIDCA.Position_in_Current_Agency__c;
            theContact.Duties__c = requestInformation.lastIDCA.Duties_in_Current_Agency__c;
            theContact.Hours_per_week__c = requestInformation.lastIDCA.Hours_worked__c;
            theContact.Start_Date_Industry__c = Decimal.valueOf(requestInformation.lastIDCA.Start_Date_Industry__c);
            theContact.Start_Date_Agency_Month__c = requestInformation.lastIDCA.Start_Date_Agency_Month__c;
            theContact.Start_Date_Agency_Year__c = Decimal.valueOf(requestInformation.lastIDCA.Start_Date_Agency_Year__c);
            theContact.Solicitation_Flag__c = requestInformation.lastIDCA.Solicitation_Flag__c;
            theContact.Revenue_Confirmation__c = requestInformation.lastIDCA.Revenue_Confirmation__c;
            theContact.AgencyShare_Confirmation__c = requestInformation.lastIDCA.AgencyShare_Confirmation__c;
            theContact.UIR__c = requestInformation.lastIDCA.UIR__c;
            theContact.VER_Number_2__c = requestInformation.lastIDCA.VER_Number__c;
            insert theContact;

            requestInformation.contact = [SELECT c.AgencyShare_Confirmation__c,c.ID_Card_Preferred_Language__c,
                                              c.VER_Number__c, c.Title, c.FirstName, c.Middle_Initial__c, c.LastName,
                                              c.UIR__c, c.Account.IATACode__c, c.Hours_per_week__c, c.Duties__c,
                                              c.Position__c, c.Solicitation_Flag__c, c.Revenue_Confirmation__c,
                                              c.Email
                                          FROM Contact c 
                                          WHERE id = :theContact.Id];
            System.debug('Created new Contact: ' + requestInformation.contact);
        }
    }

    private static void updateIdCardContact(RequestInformation requestInformation)
    {
        if (requestInformation.lastIDC.Related_Contact__c == null)
        {
            requestInformation.lastIDC.Related_Contact__c = requestInformation.contact.Id;
            Id_Card__c newIDC = new Id_Card__c(Id = requestInformation.lastIDC.Id);
            newIDC.Related_Contact__c = requestInformation.contact.Id;
            update newIDC;
        }
    }

    private static Case createCaseAndSendEmail(RequestInformation requestInformation)
    {
        Case c = IDCardUtil.createKeyAccountIdCardApplicationCase(requestInformation.newIDCA, requestInformation.account);

        // update status to send email using workflow rule and "IDCard_ConfirmationEmail" template email
        Case c2 = new Case(Id = c.Id);
        c2.Subject = 'Case for Mobile ID Card Application ' + [SELECT Name FROM ID_Card_Application__c WHERE Id = :requestInformation.newIDCA.Id].Name;
        c2.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ID_Card_Application');
        c2.Status = 'Agent to be Notified';
        c2.Origin = 'ID Card Mobile';
        update c2;

        //requestInformation.newIDCA.Case_Number__c = c.CaseNumber; set automatically on the "IDCard_ConfirmationEmail" template email
        return c;
    }
    
    private static ID_Card_Application__c createNewIDCA(RequestInformation requestInformation)
    {
        ID_Card_Application__c newIDCA = requestInformation.lastIDCA.clone();
        newIDCA.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Standard');
        
        System.debug('requestInformation.lastIDCA RecordTypeId: ' + requestInformation.lastIDCA.RecordTypeId);
        System.debug('newIDCA RecordTypeId: ' + newIDCA.RecordTypeId);

        newIDCA.Application_Status__c = 'Temp';
        newIDCA.Type_of_Application__c = IDCardUtil.APPLICATIONTYPE_RENEWAL;
        newIDCA.Renewal_From_Replace__c = false;
        newIDCA.Single_Application_Processing_Step__c = IDCardUtil.single_application_status_waiting;

        newIDCA.Card_Type__c = CARD_TYPE_PLASTIC;
        if (String.isNotBlank(requestInformation.request.typeOfCard))
            newIDCA.Card_Type__c = requestInformation.request.typeOfCard;
            
        newIDCA.Mobile_App_Transaction_Id__c = requestInformation.request.orderId;
        newIDCA.Mobile_App_Request__c = JSON.serialize(requestInformation.request);

        return newIDCA;
    }

    private static void setPaymentInformation(RequestInformation requestInformation)
    {
        IDCard_RenewalRequest.Payment payment = requestInformation.request.payment;
        if (payment == null)
            throw new IDCardException('No Payment information received');
        
        requestInformation.newIDCA.Application_Status__c = 'Processing Successfull payment';

        requestInformation.newIDCA.Payment_Credit_Card_Number__c = payment.cardNumber;
        requestInformation.newIDCA.Payment_Transaction_Number__c = payment.transactionNumber;
        requestInformation.newIDCA.Payment_Amount__c = payment.amount != null ? payment.amount : 0;
        requestInformation.newIDCA.Payment_Date__c = convertDate(payment.orderDate);
        requestInformation.newIDCA.Payment_Currency__c = payment.cur != null ? payment.cur.toUpperCase() : null;
        requestInformation.newIDCA.Payment_Type__c = IDCardUtil.PAYMENT_TYPE_CC;

        IDCard_RenewalRequest.Items cardRenewal = getRequestItem(requestInformation.request, RENEWAL_ITEM_RENEWAL);
        IDCard_RenewalRequest.Items shipping = getRequestItem(requestInformation.request, RENEWAL_ITEM_EXPEDITE);
        IDCard_RenewalRequest.Items training1 = getRequestItem(requestInformation.request, RENEWAL_ITEM_TRAINING_1);
        IDCard_RenewalRequest.Items training2 = getRequestItem(requestInformation.request, RENEWAL_ITEM_TRAINING_2);

        Double trainingFee = null;
        if (training1 != null || training2 != null)
        {
            trainingFee = (training1 == null || training1.price == null ? 0 : training1.price) +
                          (training2 == null || training2.price == null ? 0 : training2.price);
        }

        requestInformation.newIDCA.IDCard_Expedite_Delivery__c = requestInformation.prices.Expedite_Delivery_added_to_IDCard_Price__c;
        requestInformation.newIDCA.Applicable_Fee__c = getRequestItemTotalAmount(requestInformation.request);
        requestInformation.newIDCA.ID_Card_Fee__c = cardRenewal == null ? 0 : cardRenewal.price;
        requestInformation.newIDCA.IDCard_Expedite_Delivery_Fee__c = shipping == null ? 0 : shipping.price;
        requestInformation.newIDCA.ITDI_Courses_Fee__c = trainingFee == null ? 0 : trainingFee;
        requestInformation.newIDCA.CurrencyIsoCode = requestInformation.prices.CurrencyIsoCode;

        setTaxes(requestInformation);
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

    private static void setTaxes(RequestInformation requestInformation)
    {
        ID_Card_Application__c newIDCA = requestInformation.newIDCA;
        newIDCA.Tax_1_Name__c = null;
        newIDCA.Tax_1_Value__c = null;
        newIDCA.Tax_2_Name__c = null;
        newIDCA.Tax_2_Value__c = null;

        Account account = [SELECT BillingState, BillingCountry FROM Account WHERE Id = :requestInformation.account.Id];

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

        newIDCA.Profit_Center__c = requestInformation.prices.Profit_Center__c;
    }

    private static void setAndValidatePromotion(RequestInformation requestInformation)
    {
        if (requestInformation.request.payment == null)
            throw new IDCardException('No Payment information received');

        try
        {
            validatePromotion(requestInformation);
        }
        catch (Exception e)
        {
            // NOTHING - ignored the validation as the promotion was already applied in the payment
        }

        requestInformation.newIDCA.Promotion_Code__c = requestInformation.request.payment.promotionCode;
    }

    private static void validatePromotion(RequestInformation requestInformation)
    {
        // Promotion code must exists, must be associated to the corresponding Price Table and be between the validity period
        if (String.isNotBlank(requestInformation.request.payment.promotionCode))
        {
            List<Promotion__c> promotionLst = [SELECT p.Promotion_Value__c, p.Promotion_Duration_Valid_Up_to__c,
                                                p.Promotion_Duration_Valid_From__c, p.Promotion_Code__c,
                                                p.Type_of_Application__c
                                               FROM Promotion__c p
                                               WHERE p.Promotion_Code__c = :requestInformation.request.payment.promotionCode];
            
            if (promotionLst.isEmpty())
                throw new IDCardException(String.Format(Label.ID_Card_Invalid_Promotion_Code, new String[] { requestInformation.request.payment.promotionCode }));

            Boolean hasTypeOfApplication = false;
            for (String typeOfApp : promotionLst.get(0).Type_of_Application__c.split(';'))
            {
                System.debug('Validating promotion: ' + typeOfApp + ' ' + requestInformation.newIDCA.Type_of_Application__c);

                if (requestInformation.newIDCA.Type_of_Application__c.equals(typeOfApp))
                {
                    hasTypeOfApplication = true;
                    break;
                }
            }

            if (! hasTypeOfApplication)
                throw new IDCardException(String.Format(Label.ID_Card_Invalid_Promotion_Code_2, new String[] { requestInformation.request.payment.promotionCode }));
            if (promotionLst.get(0).Promotion_Duration_Valid_Up_to__c < Date.today())
                throw new IDCardException(Label.ID_Card_Promotion_Code_No_Longer_Valid);
            if (promotionLst.get(0).Promotion_Duration_Valid_From__c > Date.today())
                throw new IDCardException(Label.ID_Card_Promotion_Code_Not_Yet_Valid);
        }
    }

    private static void setIDCAAgentSpecialization(RequestInformation requestInformation)
    {
        requestInformation.newIDCA.ASF_Current_Function__c = null;
        requestInformation.newIDCA.ASF_Percentage_of_Annual_Booking__c = null;
        requestInformation.newIDCA.ASF_Market_Specialization__c = null;
        requestInformation.newIDCA.ASF_Market_Specialization_Comment__c = null;
        requestInformation.newIDCA.ASF_Market_Focus__c = null;
        requestInformation.newIDCA.ASF_Specializing_on_Destination__c = null;
        requestInformation.newIDCA.ASF_Completed_Travel_Courses__c = null;
        requestInformation.newIDCA.ASF_Last_Completed_Travel_Course__c = null;
        requestInformation.newIDCA.ASF_FAM_Trips__c = null;

        if (requestInformation.request.specializationFields != null)
        {
            requestInformation.newIDCA.ASF_Current_Function__c = requestInformation.request.specializationFields.ASF_Current_Function;
            requestInformation.newIDCA.ASF_Percentage_of_Annual_Booking__c = requestInformation.request.specializationFields.ASF_Percentage_of_Annual_Booking;
            requestInformation.newIDCA.ASF_Market_Specialization__c = requestInformation.request.specializationFields.ASF_Market_Specialization;
            requestInformation.newIDCA.ASF_Market_Specialization_Comment__c = requestInformation.request.specializationFields.ASF_Market_Specialization_Comment;
            requestInformation.newIDCA.ASF_Market_Focus__c = requestInformation.request.specializationFields.ASF_Market_Focus;
            requestInformation.newIDCA.ASF_Specializing_on_Destination__c = requestInformation.request.specializationFields.ASF_Specializing_on_Destination;
            requestInformation.newIDCA.ASF_Completed_Travel_Courses__c = requestInformation.request.specializationFields.ASF_Completed_Travel_Courses;
            requestInformation.newIDCA.ASF_Last_Completed_Travel_Course__c = requestInformation.request.specializationFields.ASF_Last_Completed_Travel_Course;
            requestInformation.newIDCA.ASF_FAM_Trips__c = requestInformation.request.specializationFields.ASF_FAM_Trips;
        }
    }

    private static void setIDCAgentSpecialization(RequestInformation requestInformation)
    {
        // if there is any blank on the request: get the values from the previous IDC
        Id_Card__c oldIdCard = null;
        ID_Card_Application__c newIDCA = requestInformation.newIDCA;

        if (String.isBlank(newIDCA.ASF_Current_Function__c) || String.isBlank(newIDCA.ASF_Percentage_of_Annual_Booking__c)
            || String.isBlank(newIDCA.ASF_Market_Specialization__c) || String.isBlank(newIDCA.ASF_Market_Focus__c)
            || String.isBlank(newIDCA.ASF_Specializing_on_Destination__c) || String.isBlank(newIDCA.ASF_Completed_Travel_Courses__c)
            || String.isBlank(newIDCA.ASF_Last_Completed_Travel_Course__c) || String.isBlank(newIDCA.ASF_FAM_Trips__c))
        {
            oldIdCard = requestInformation.lastIDC;
        }

        requestInformation.newIDC.ASF_Current_Function__c = String.isBlank(newIDCA.ASF_Current_Function__c) && oldIdCard != null ? oldIdCard.ASF_Current_Function__c : newIDCA.ASF_Current_Function__c;
        requestInformation.newIDC.ASF_Percentage_of_Annual_Booking__c = String.isBlank(newIDCA.ASF_Percentage_of_Annual_Booking__c) && oldIdCard != null ? oldIdCard.ASF_Percentage_of_Annual_Booking__c : newIDCA.ASF_Percentage_of_Annual_Booking__c;
        requestInformation.newIDC.ASF_Market_Specialization__c = String.isBlank(newIDCA.ASF_Market_Specialization__c) && oldIdCard != null ? oldIdCard.ASF_Market_Specialization__c : newIDCA.ASF_Market_Specialization__c;
        requestInformation.newIDC.ASF_Market_Specialization_Comment__c = String.isBlank(newIDCA.ASF_Market_Specialization_Comment__c) && oldIdCard != null ? oldIdCard.ASF_Market_Specialization_Comment__c : newIDCA.ASF_Market_Specialization_Comment__c;
        requestInformation.newIDC.ASF_Market_Focus__c = String.isBlank(newIDCA.ASF_Market_Focus__c) && oldIdCard != null ? oldIdCard.ASF_Market_Focus__c : newIDCA.ASF_Market_Focus__c;
        requestInformation.newIDC.ASF_Specializing_on_Destination__c = String.isBlank(newIDCA.ASF_Specializing_on_Destination__c) && oldIdCard != null ? oldIdCard.ASF_Specializing_on_Destination__c : newIDCA.ASF_Specializing_on_Destination__c;
        requestInformation.newIDC.ASF_Completed_Travel_Courses__c = String.isBlank(newIDCA.ASF_Completed_Travel_Courses__c) && oldIdCard != null ? oldIdCard.ASF_Completed_Travel_Courses__c : newIDCA.ASF_Completed_Travel_Courses__c;
        requestInformation.newIDC.ASF_Last_Completed_Travel_Course__c = String.isBlank(newIDCA.ASF_Last_Completed_Travel_Course__c) && oldIdCard != null ? oldIdCard.ASF_Last_Completed_Travel_Course__c : newIDCA.ASF_Last_Completed_Travel_Course__c;
        requestInformation.newIDC.ASF_FAM_Trips__c = String.isBlank(newIDCA.ASF_FAM_Trips__c) && oldIdCard != null ? oldIdCard.ASF_FAM_Trips__c : newIDCA.ASF_FAM_Trips__c;
        update requestInformation.newIDC;
    }

    private static void setWebStarField(RequestInformation requestInformation)
    {
        if (requestInformation.lastIDC != null && requestInformation.lastIDC.WebStar_P00_Key__c != null)
        {
            requestInformation.newIDC.WebStar_P00_Key__c = requestInformation.lastIDC.WebStar_P00_Key__c;
            update requestInformation.newIDC;
        }
    }

    private static void setTrainingCourses(RequestInformation requestInformation)
    {
        IDCard_RenewalRequest.Items training1 = getRequestItem(requestInformation.request, RENEWAL_ITEM_TRAINING_1);
        IDCard_RenewalRequest.Items training2 = getRequestItem(requestInformation.request, RENEWAL_ITEM_TRAINING_2);

        if (training1 == null && training2 != null)
        {
            training1 = training2;
            training2 = null;
        }

        requestInformation.newIDCA.Package_of_Travel_Professionals_Course_1__c = training1 == null ? null : training1.training;
        requestInformation.newIDCA.Package_of_Travel_Professionals_Course_2__c = training2 == null ? null : training2.training;
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

    private static ID_Card_Application__c createIDCAForUSAgent(RequestInformation requestInformation)
    {
        ID_Card__c lastIDCard = requestInformation.lastIDC;

        ID_Card_Application__c objApp = new ID_Card_Application__c();
        objApp.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Standard');
        objApp.Approving_Manager_s_Name__c = lastIDCard.Approving_Manager_s_Name__c;
        objApp.Approving_Manager_s_Email__c = lastIDCard.Approving_Manager_s_Email__c;
        objApp.CurrencyIsoCode = lastIDCard.CurrencyIsoCode;
        objApp.Date_of_Birth__c = lastIDCard.Date_of_Birth__c;
        objApp.Duties_in_Current_Agency__c = lastIDCard.Duties__c;
        objApp.Email_admin__c = lastIDCard.Email__c;
        objApp.ID_Card_Fee__c = lastIDCard.Fee_Applicable__c;
        objApp.First_Name__c = lastIDCard.FirstName__c;
        objApp.Gender__c = lastIDCard.Gender__c;
        objApp.Hours_worked__c = lastIDCard.Hours_per_week__c;
        objApp.IDCard_Expedite_Delivery__c = lastIDCard.Is_Expedite__c;
        objApp.Last_Name__c = lastIDCard.LastName__c;
        objApp.Middle_Initial__c = lastIDCard.Middle_Initial__c;
        objApp.Displayed_Name__c = lastIDCard.Name_on_ID_Card__c;
        objApp.Type_of_application__c = getIdCardApplicationTypeFromNature(lastIDCard.Nature_of_ID_Card__c);
        objApp.Position_in_Current_Agency__c = lastIDCard.Position__c;
        objApp.Photo__c = lastIDCard.Photo__c;
        objApp.Telephone__c = lastIDCard.Phone__c;
        objApp.Profit_Center__c = lastIDCard.Profit_Center__c;
        objApp.Payment_Type__c = lastIDCard.Payment_Type__c;
        objApp.Renewal_From_Replace__c = lastIDCard.Renewal_From_Replace__c;
        objApp.Start_Date_Industry__c = lastIDCard.Start_Date_Industry__c;
        objApp.Start_Date_Agency_Month__c = lastIDCard.Start_Date_Agency_Month__c;
        objApp.Start_Date_Agency_Year__c = lastIDCard.Start_Date_Agency_Year__c;
        objApp.Title__c = lastIDCard.Title__c;
        objApp.VER_Number__c = lastIDCard.VER_Number__c;
        objApp.IATA_Code__c = requestInformation.iataCode;
        objApp.UIR__c = null;
        if (String.isNotBlank(objApp.Photo__c))
        {
            objApp.UIR__c = objApp.Photo__c;
            if (objApp.Photo__c.indexOfAny('.') != -1)
                objApp.UIR__c = objApp.Photo__c.subString(0, objApp.Photo__c.indexOfAny('.'));
        }
        objApp.ASF_Current_Function__c = null;
        objApp.ASF_Percentage_of_Annual_Booking__c = null;
        objApp.ASF_Market_Specialization__c = null;
        objApp.ASF_Market_Specialization_Comment__c = null;
        objApp.ASF_Market_Focus__c = null;
        objApp.ASF_Specializing_on_Destination__c = null;
        objApp.ASF_Completed_Travel_Courses__c = null;
        objApp.ASF_Last_Completed_Travel_Course__c = null;
        objApp.ASF_FAM_Trips__c = null;

        System.debug('Created IDCA for US Agents: ' + objApp);
        return objApp;
    }

    private static String getIdCardApplicationTypeFromNature(String natureOfIdCard)
    {
        if (IDCardUtil.IDCARDNATURE_NEW.equals(natureOfIdCard))
            return IDCardUtil.APPLICATIONTYPE_NEW;
        else if (IDCardUtil.IDCARDNATURE_REPLACEMENT.equals(natureOfIdCard))
            return IDCardUtil.APPLICATIONTYPE_REPLACEMENT;
        else if (IDCardUtil.IDCARDNATURE_RENEWAL.equals(natureOfIdCard))
            return IDCardUtil.APPLICATIONTYPE_RENEWAL;
        else if (IDCardUtil.IDCARDNATURE_REISSUE.equals(natureOfIdCard))
            return IDCardUtil.APPLICATIONTYPE_REISSUE;
        return null;
    }

    private static ID_Card_Application__c getCurrentIDCA(RequestInformation requestInformation)
    {
        ID rectypeid = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card__c', 'AIMS');

        List<ID_Card__c> allCards = [SELECT i.VER_Number__c, i.Middle_Initial__c, i.LastName__c, i.FirstName__c, i.Email__c,
                                        i.Date_of_Birth__c, i.Agency_Name__c, i.Agency_IATA_Code__c, i.ID_Card_Application__c
                                     FROM ID_Card__c i
                                     WHERE i.RecordTypeId = :rectypeid
                                        AND i.VER_Number__c = :requestInformation.verNumber
                                        AND i.Card_Status__c != :IDCardUtil.CARDSTATUS_CANCELED
                                        AND i.ID_Card_Application__c != NULL
                                     ORDER BY i.Valid_To_Date__c DESC, i.CreatedDate DESC, i.Name DESC
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
    
    private static void checkPendingCases(RequestInformation requestInformation)
    {
        List<Case> pendingCase = [SELECT Id 
                                  FROM Case
                                  WHERE RecordType.Name = 'ID Card Application'
                                      AND Contact.Id = :requestInformation.contact.Id
                                      AND status <> 'Closed'
                                      LIMIT 1];
        
        String tempVerNumber = 'Z' + requestInformation.verNumber;
        List<ID_Card_Application__c> pendingIdCardsApp = [SELECT Id
                                                          FROM ID_Card_Application__c
                                                          WHERE RecordType.Name = 'Single ID Card Operation' 
                                                                  AND (VER_Number__c = :requestInformation.verNumber
                                                                       OR VER_Number__c = :tempVerNumber)
                                                                  AND (Application_Status__c = 'Pending'
                                                                       OR Application_Status__c = 'Unpaid')
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

    private static void checkBlacklistedCard(RequestInformation requestInformation)
    {
        List<ID_Card__c> aCards;
        if (requestInformation.contact == null)
        {
            aCards = [SELECT Id, Blacklisted__c, Card_Status__c
                      FROM ID_Card__c
                      WHERE VER_Number__c = :requestInformation.verNumber
                      ORDER BY CreatedDate DESC];
        }
        else
        {
            aCards = [SELECT Id, Blacklisted__c, Card_Status__c
                      FROM ID_Card__c
                      WHERE Related_Contact__c = :requestInformation.contact.Id
                      ORDER BY CreatedDate DESC];
        }

        for (ID_Card__c aCard : aCards)
        {
            if (aCard.Blacklisted__c)
            {
                mailAlertOnBlackListedConnection(aCard, requestInformation.verNumber, requestInformation.iataCode);
                throw new IDCardException('Your IATA/IATAN ID Card has been blacklisted. For more information, please kindly contact IATA Customer Service on www.iata.org/cs');
            }

            break;
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
    
    private static void postPardot(RequestInformation requestInformation)
    {
        if (requestInformation.request.payment == null || ! sendPardot())
            return;

        String payLoad = 'email=' + requestInformation.newIDCA.Email_admin__c;
        payLoad += '&paymentDate=' + requestInformation.request.payment.orderDate;
        payLoad += '&paymentAmount=' + requestInformation.request.payment.amount;
        payLoad += '&paymentCurrency=' + requestInformation.request.payment.cur;
        payLoad += '&CaseNumber=' + requestInformation.idcaCase.CaseNumber;

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
        return getAccountType(contact.Account);
    }

    public static String getAccountType(String iataCode)
    {
        Account theAccount = IDCardUtil.GetAccountObjectFromIATACode(iataCode);
        return getAccountType(theAccount);
    }

    public static String getAccountType(Account theAccount)
    {
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

        if (contacts == null || contacts.isEmpty())
            throw new IDCardException(Label.IDCard_NoContactsFound);
        return contacts.get(0);
    }

    public static Contact getContact(String verNumber)
    {
        System.debug('Looking for any Contact for the ver# ' + verNumber);

        List<Contact> contacts = [SELECT c.VER_Number_2__c, c.FirstName, c.LastName, c.Date_of_Birth__c,
                                    c.Account.IDCard_Key_Account__c, c.Account.Type, c.Account.Short_Name__c,
                                    c.Account.Is_AIMS_Account__c , c.Id, c.Account.Status__c, c.Account.IATACode__c,
                                    c.Account.ID_Card_KeyAccount_features__c
                                  FROM Contact c
                                  WHERE c.VER_Number_2__c = :verNumber];

        if (contacts == null || contacts.isEmpty())
            return null;

        System.debug('Found result: ' + contacts.get(0));
        return contacts.get(0);
    }

    private class RequestInformation
    {
        public Boolean isUSAgent = false;
        public String iataCode;
        public String verNumber;
        public IDCard_RenewalRequest request;
        public Contact contact;
        public IATA_ISO_Country__c contactCountry;
        public String accountType;
        public Price_Table__c prices;
        public Account account;
        public Case idcaCase;

        ID_Card_Application__c lastIDCA;
        ID_Card_Application__c newIDCA;
        ID_Card__c lastIDC;
        ID_Card__c newIDC;

        public RequestInformation(String iataCode, String verNumber, IDCard_RenewalRequest request)
        {
            this.iataCode = iataCode;
            this.verNumber = verNumber;
            this.request = request;
        }
    }

    public class IDCardException extends Exception { }
}
