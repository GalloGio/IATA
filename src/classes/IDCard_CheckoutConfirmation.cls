public with sharing class IDCard_CheckoutConfirmation extends IDCardAbstractController {

    public String allParams { get; private set; }

    public String decision { get; private set; }
    public String reasonCode { get; private set; }
    public String orderNumber { get; private set; }
    public String maskedCardNumber { get; private set; }
    public String transactionNumber { get; private set; }
    public Decimal paymentAmount { get; private set; }
    public String paymentDate { get; private set; }
    public String paymentCurrency { get; private set; }

    public Boolean success { get; private set; }
    public Boolean payerAuthentication { get; private set; }
    public Boolean systemError { get; private set; }
    public String idCardApplicationCaseNumber { get; private set;}

    public String ReasonCodeMsg {get; set;}

    public Boolean PaymentByCheque {get; set;}

    //boolean for amount  = 0: pass
    public Boolean freeOfCharges {get; set;}

    public boolean isMassApplicationPurchase {get; set;}

    private ID_Card_Application__c iDCardApplication;

    public IDCard_CheckoutConfirmation() {
        initialize();
        PaymentByCheque = false;
        freeOfCharges = false;
        isMassApplicationPurchase = false;
        //checks if its payment by cheque: gets parameter that specifies that
        if (System.currentPageReference().getParameters().containsKey(IDCardUtil.ISPAYMENTBYCHEQUE))
            PaymentByCheque = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.ISPAYMENTBYCHEQUE)).toLowerCase().contains('true');

        //checks if its payment by cheque: gets parameter that specifies that
        if (System.currentPageReference().getParameters().containsKey(IDCardUtil.ISFOC) && System.currentPageReference().getParameters().get(IDCardUtil.ISFOC) != null ) {

            freeOfCharges = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.ISFOC)).toLowerCase().contains('0.00');

        }
        system.debug('------- PaymentByCheque = ' + PaymentByCheque);

        try {
            success = false;
            payerAuthentication = false;
            systemError = false;

            Map<String, String> params = ApexPages.currentPage().getParameters();

            allParams = '';
            if (params != null && params.size() > 0) {
                for (String keyField : params.keySet()) {
                    allParams += keyField + ':' + params.get(keyField) + '<br />';
                }
            } else
                throw new IDCardApplicationException('Missing the CyberSource parameters.');


            iDCardApplication = new ID_Card_Application__c();
            orderNumber = ApexPages.currentPage().getParameters().get('req_reference_number');//get('orderNumber'); // get orderNumber (which is the ID Card Application auto-number)


            //trim first 3 characters to remove country ISOCode and the dash
            orderNumber = 'IDCA-' + orderNumber.substring(5, orderNumber.length());

            ID_Card_Application__c idCardApp = [Select i.Case_Number__c, i.Application_Status__c,  i.Tax_2_Name__c,
                                                i.Tax_1_Name__c, i.Tax_1_Value__c, i.Tax_2_Value__c,
                                                i.Renewal_From_Replace__c, i.ID_Card_Fee__c, i.VER_Number__c,
                                                i.UIR__c, i.Revenue_Confirmation__c, i.Type_of_application__c,
                                                i.Title__c, i.Telephone__c, i.SystemModstamp, i.Start_Date_Industry__c,
                                                i.Start_Date_Agency_Year__c, i.Start_Date_Agency_Month__c,
                                                i.Solicitation_Flag__c, i.Promotion_Code__c, i.Position_in_Current_Agency__c,
                                                i.Position_Code__c, i.Photo__c, i.Package_of_Travel_Professionals_Course_2__c,
                                                i.Package_of_Travel_Professionals_Course_1__c, i.OwnerId, i.Name,
                                                i.Middle_Initial__c, i.Last_Name__c, i.LastModifiedDate, i.LastModifiedById,
                                                i.IsDeleted, i.Id, i.IDCard_Prefered_Language__c, i.IDCard_Expedite_Delivery__c,
                                                i.IDCard_Expedite_Delivery_Fee__c, i.IATA_numeric_code_previous_employer_4__c,
                                                i.IATA_numeric_code_previous_employer_3__c, i.IATA_numeric_code_previous_employer_2__c,
                                                i.IATA_numeric_code_previous_employer_1__c, i.IATA_Code_for_previous_agency__c,
                                                i.IATA_Code__c, i.Hours_worked__c, i.Hours_Worked_Code__c, i.Gender__c, i.First_Name__c,
                                                i.Hours_Worked_Validation_Failed__c, i.Email_admin__c, i.Duties_in_Current_Agency__c,
                                                i.Duties_Code__c, i.Displayed_Name__c, i.Date_of_Birth__c, i.CurrencyIsoCode,
                                                i.CreatedDate, i.CreatedById,
                                                i.Approving_Manager_s_Name__c, i.Approving_Manager_s_Email__c, i.Applicable_Fee__c,
                                                i.Payment_Credit_Card_Number__c, i.Payment_Date__c, i.Revenue_Confirmation_Validation_Failed__c,
                                                i.Payment_Transaction_Number__c, i.Payment_Amount__c , i.RecordTypeId
                                                From ID_Card_Application__c i where i.Name = :orderNumber limit 1];
            System.debug('/*//*/* ' + idCardApp.Name);
            iDCardApplication = idCardApp;

            String massAppRT = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Mass_Order_Application');
            isMassApplicationPurchase = (massAppRT == idCardApp.RecordTypeId);
            if (idCardApp.RecordTypeId == RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Single_ID_Card_Operation')) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'As a member of a Key Account, you shouln\'t have paid for a Single Application. Please contact IATA with ref: ' + idCardApp.Name));
                success = false;
                return;
            }


            if (freeOfCharges)
                success = true;
            if (!PaymentByCheque && !freeOfCharges) {
                decision = ApexPages.currentPage().getParameters().get('decision');
                reasonCode = ApexPages.currentPage().getParameters().get('reason_code');
                maskedCardNumber = ApexPages.currentPage().getParameters().get('req_card_number');
                transactionNumber = ApexPages.currentPage().getParameters().get('transaction_id');   // NOTE: could be "requestID" or "ccAuthReply_authorizationCode" also...
                paymentCurrency = ApexPages.currentPage().getParameters().get('req_currency');
                if (paymentCurrency != null && paymentCurrency != '')
                    paymentCurrency = paymentCurrency.toUpperCase();



                if (ApexPages.currentPage().getParameters().get('auth_amount') != null) // ex ccAuthReply_amount
                    paymentAmount = Decimal.valueOf(ApexPages.currentPage().getParameters().get('auth_amount'));
                paymentDate = convertDate(ApexPages.currentPage().getParameters().get('auth_time')); // ex ccAuthReply_authorizedDateTime
                System.debug('********************************************************** Case NUMBER ' + iDCardApplication.Case_Number__c);
                //if()

                system.debug('[MASS TEST] reason =' + reasonCode);
                if (decision != null && decision != '' && reasonCode != null && reasonCode != '') {

                    if (reasonCode == '100') {
                        ReasonCodeMsg = Label.IDCARD_reasonCode100;
                        success = true;
                    } else if (reasonCode == '101') {
                        ReasonCodeMsg = Label.IDCARD_reasonCode101;
                    } else if (reasonCode == '102') {
                        ReasonCodeMsg = Label.IDCARD_reasonCode102;
                    } else if (reasonCode == '200') {
                        ReasonCodeMsg = Label.IDCARD_reasonCode200;
                    } else if (reasonCode == '201') {
                        ReasonCodeMsg = Label.IDCARD_reasonCode201;
                    } else if (reasonCode == '203' || reasonCode == '204' || reasonCode == '208' || reasonCode == '231' || reasonCode == '233' ) {
                        ReasonCodeMsg = Label.IDCARD_reasonCode203;
                    } else if (reasonCode == '211') {
                        ReasonCodeMsg = Label.IDCARD_reasonCode211;
                    } else {
                        ReasonCodeMsg = Label.IDCard_PaymentRejected1;
                    }

                }
            }
        } catch (Exception ex) {
            System.debug('*** Error ' + ex);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));

        }
    }

    public Pagereference interpretDecision() {
        system.debug(LoggingLevel.ERROR, '[interpretDecision] --> PaymentByCheque=' + PaymentByCheque + ' -- orderNumber=' + orderNumber);
        try {
            if (orderNumber != null && orderNumber != '') {
                try {
                    if (PaymentByCheque)
                        processChequePayment(iDCardApplication);
                    else if (success) {
                        //Update ID Card Application Payment type
                        processCreditCardPayment(iDCardApplication);
                    } else if (!success || payerAuthentication) {
                        return processFailurePayment(iDCardApplication);
                    } else if (systemError)
                        throw new IDCardApplicationException(String.Format(Label.IDCard_PaymentServerError, new String[] {'<i>' + reasonCode + '</i>'}));
                }  catch (Exception e) {
                    throw e;
                }
            } else
                throw new IDCardApplicationException(Label.IDCard_OrderNumberMissing);

            return null;
        } catch (Exception ex) {
            System.debug('*** Error ' + ex);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }
    }

    public Pagereference processFailurePayment(ID_Card_Application__c idCardApp) {
        //redirect
        //Pagereference checkoutPage = Page.IDCard_Checkout;
        //checkoutPage.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(idCardApp.Id));
        //checkoutPage.getParameters().put(IDCardUtil.PARAM_ERRMSG, IDCardUtil.EncryptEncodeParameter(ReasonCodeMsg));
        //checkoutPage.setRedirect(true);       
        //return checkoutPage;        
        
        Pagereference IDCardLoginPage = Page.IDCardLogin;       
        IDCardLoginPage.setRedirect(true);
        return IDCardLoginPage;
    }

    public void processChequePayment(ID_Card_Application__c idCardApp) {
        system.debug(LoggingLevel.ERROR, '[processChequePayment] --> idCardApp=' + idCardApp);
        if (idCardApp.Application_Status__c == 'Processing Successfull payment' || idCardApp.Case_Number__c != null) {
            return;
        }
        idCardApp.Application_Status__c = 'Processing Successfull payment';
        idCardApp.Payment_Type__c = IDCardUtil.PAYMENT_TYPE_INVOICE;
        update idCardApp;
        try {
            processSuccessPayment(idCardApp);
        }  catch (Exception e) {
            throw e;
        }
    }

    public void processCreditCardPayment(ID_Card_Application__c idCardApp) {
        system.debug(LoggingLevel.ERROR, '[processCreditCardPayment] --> idCardApp=' + idCardApp);

        //if (idCardApp.Application_Status__c == 'Processing Successfull payment')
        //  return;
        if (idCardApp.Case_Number__c != null) idCardApp.Application_Status__c = 'Processing Successfull payment';

        idCardApp.Payment_Credit_Card_Number__c = maskedCardNumber;
        idCardApp.Payment_Transaction_Number__c = transactionNumber;
        idCardApp.Payment_Amount__c = paymentAmount;
        idCardApp.Payment_Date__c = paymentDate;
        idCardApp.Payment_Currency__c = paymentCurrency;
        idCardApp.Payment_Type__c = IDCardUtil.PAYMENT_TYPE_CC;

        update idCardApp;

        if (idCardApp.Application_Status__c == 'Processing Successfull payment' || idCardApp.Case_Number__c != null) {
            return;
        }

        try {
            processSuccessPayment(idCardApp);
        }  catch (Exception e) {
            throw e;
        }
    }

    public void processSuccessPayment(ID_Card_Application__c idCardApp) {
        // check if an ID Card already exists for the ID Card Application
        system.debug(LoggingLevel.ERROR, '[processSuccessPayment] --> idCardApp=' + idCardApp);

        ID_Card__c[] existingIDCards = [Select i.Name_on_ID_Card__c From ID_Card__c i where i.ID_Card_Application__r.Id = :idCardApp.Id limit 1];
        if (existingIDCards != null && existingIDCards.size() > 0)
            throw new IDCardApplicationException(Label.IDCard_IDCardAlreadyExistsError);

        // embed ID Card and Case creation in a transaction
        // SavePoint sp = database.setSavepoint();
        try {

            System.debug('********* Creating Case');
            // Create the case
            if (!isMassApplicationPurchase) {
                Account theAccount = IDCardUtil.GetAccountObjectFromIATACode(idCardApp.IATA_Code__c);
                IDCardUtil.CreateIDCardApplicationCase(idCardApp, theAccount, PaymentByCheque);
                idCardApplicationCaseNumber = 'Loading...';
            }

            //INC158853
            else {
                Account theAccount = IDCardUtil.GetAccountObjectFromIATACode(idCardApp.IATA_Code__c);
                insert IDCardUtil.createKeyAccountIdCardMassApplicationCase(iDCardApplication, theAccount, false);
            }


            //specific to mass update:
            //else {
            if (!PaymentByCheque) {
                idCardApp.Application_Status__c = 'Paid';
            } else {
                idCardApp.Application_Status__c = 'Pending';
            }
            update idCardApp;

            system.debug(LoggingLevel.ERROR, '[processSuccessPayment]  Set case.status = "Ready for production".  keyContactAndDelegateForAccountList.get(idCardApp.IATA_code__c)= ' + keyContactAndDelegateForAccountList.get(idCardApp.IATA_code__c));
            string accFeatures = '';
            if (keyContactAndDelegateForAccountList.get(idCardApp.IATA_code__c) != null)
                accFeatures = keyContactAndDelegateForAccountList.get(idCardApp.IATA_code__c).Account__r.ID_Card_KeyAccount_features__c;
            if (accFeatures == null)
                accFeatures = '';

            if (isMassApplicationPurchase && (!PaymentByCheque || accFeatures.contains(IDCardUtil.Key_Account_Feature_Immediate_Processing))) {
                List<Case> cases = [SELECT Id FROM Case WHERE Related_ID_Card_Application__c = :idCardApp.id];
                if (cases.size() > 0)
                    cases[0].Status = 'Ready for production';
                update cases[0];
            }

            //}
        } catch (Exception ex) {
            //  database.rollback(sp);
            System.debug('********* EXCEPTION' + ex.getMessage());
            throw ex;
        }
    }


    public void refreshCaseNumber() {

        idCardApplicationCaseNumber = iDCardApplication.Case_Number__c;
        if (idCardApplicationCaseNumber == null || idCardApplicationCaseNumber == '' || idCardApplicationCaseNumber == 'Loading...') {

            Id IDCardcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ID_Card_Application');
            if (isMassApplicationPurchase) {
                IDCardcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ID_Card_Mass_Application');
            }
            system.debug('[checkoutConfirmation] lookfor case: SELECT CaseNumber FROM Case c WHERE c.Related_ID_Card_Application__r.Id =' + iDCardApplication.Id + ' and c.RecordTypeId =' + IDCardcaseRecordTypeID + ' limit 1');

            list<Case> aCaseApplication = [SELECT CaseNumber FROM Case c WHERE c.Related_ID_Card_Application__r.Id = :iDCardApplication.Id and c.RecordTypeId = : IDCardcaseRecordTypeID limit 1];
            System.debug('******* Case SIZE = ' + aCaseApplication.size());
            if (aCaseApplication.size() != 0) {

                if (aCaseApplication[0].CaseNumber == null || aCaseApplication[0].CaseNumber == '') {
                    idCardApplicationCaseNumber = 'Loading...';
                } else {
                    idCardApplicationCaseNumber = aCaseApplication[0].CaseNumber;
                    postPardot();
                }
            }

        }
    }

    private string convertDate (string iso8601) {
        if (iso8601 != null && iso8601 != '') {
            System.debug('/*/*/*/* iso8601 ' + iso8601);
            string dateconverted = iso8601.substring(0, 13) + ':' + iso8601.substring(13, 15) + ':' + iso8601.substring(15, iso8601.length());
            System.debug('/*/*/*/* dateconverted ' + dateconverted);
            DateTime dt = (DateTime) JSON.deserialize('"' + dateconverted + '"', DateTime.class);
            return (DateTime.newInstance(dt.getTime())).format('dd-MMMM-yyyy HH:mm:ss') + ' GMT';
        } else {
            System.debug('******** String Date IS NULLL');
            return '';
        }

    }


    public Pagereference terminate () {
        PageReference ref = new PageReference('http://www.iata.org');
        ref.setRedirect(true);
        return ref;
    }

    public void postPardot() {
        String payLoad = 'email=' + iDCardApplication.Email_admin__c;
        payLoad += '&paymentDate=' + paymentDate;
        payLoad += '&paymentAmount=' + paymentAmount;
        payLoad += '&paymentCurrency=' + paymentCurrency;
        payLoad += '&CaseNumber=' + idCardApplicationCaseNumber;

        system.debug('post pardor payLoad: ' + payLoad);

        String endpoint = 'http://go.updates.iata.org/l/123902/2017-02-09/7kl76z/';
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setTimeout(60000);
        req.setMethod('POST');
        req.setBody(payLoad);
        if(!Test.isRunningTest()){
           HttpResponse res = h.send(req);
        }
    }


}
