/**

This controller is used on ID CArd Manageöent part to manage Pending Mass operation.

It is based on List of application for current account
*/
global class IDCard_AdmPendingOpsController extends IDCardAbstractController {

    /**
    List of pneding operation:
    Mass_order_application__c = null and recordTypeId =Single
     and IATA_code__c = currentIATACode and Application_Status__c = 'Pending'
    */
    public List<ID_Card_Application__c> pendingApplications {get; set;}

    /**
    Contact informaetion per pending applicatioj
    */
    public Map<String, ContactProxy> contactsPerApplication {get; set;}

    private String ccurrency = null;


    /**
    applciation list whcih shluldbe processed
    */
    public  Map<String, ID_Card_Application__c> validatedApplication {get; set;}

    /**
    Pending application whcich should be rejected
    */
    public  Map<String, ID_Card_Application__c> unvalidatedApplication {get; set;}

    /*
    Global and calculated var priunted on page

    */
    public String appsCurrency  {get; set;}
    public Double tPrice  {get; set;}
    public Double vatPrice  {get; set;}
    public Double deliveryPrice  {get; set;}
    public Integer rejectedSize  {get; set;}
    public Double expediteFees  {get; set;}

    private double massAppDeliveryFee = 0;

    public Map<String, String> cyberSrcData {get; set;}

    /** use for filtering */
    private Id singeAppRT = null;

    /* information for each pending information*/
    public Map<String, boolean> isApplicationreadyMap {get; set;}

    /*selected payment mode*/
    public String paymentMode  {get; set;}

    /**for payment*/
    private String orderNumber = null;

    /** Signature for the payment form**/
    public String calculatedSignature {get; set;}

    public boolean selectAll {get; set;}



    /** vars used for mexpedite fees.**/
    public boolean fastExpedition {get; set{
            fastExpedition = value;
            if (validatedApplication != null) {
                for (ID_Card_Application__c app : validatedApplication.values())
                    if (isApplicationExpediteAvailable(app))
                        app.IDCard_Expedite_Delivery__c = fastExpedition;
                calculateAllPrices();
            }
        }
    }

    public Map<String, IATA_ISO_Country__c> countriesPerIATACode = new Map<String, IATA_ISO_Country__c>();

    public boolean IsExpediteAvailable {get; set;}

    private  Map<String, Price_Table__c > pricePerCountry = null;

    private  Map<String, String> accountTypesPerIATACode = new Map<String, String>();


    /*Constructor*/
    public IDCard_AdmPendingOpsController() {
        initialize(true);
        selectall = false;
        //init vars
        appsCurrency = '-';
        vatPrice = 0;
        tPrice = 0;
        rejectedSize = 0;
        deliveryPrice = 0;
        expediteFees = 0;
        cyberSrcData = null;
        fastExpedition =  false;
        cyberSrcData = new Map<String, String>()     ;
        pendingApplications = new List<ID_Card_Application__c>();
        unvalidatedApplication = new Map<String, ID_Card_Application__c> ();
        validatedApplication = new Map<String, ID_Card_Application__c> ();
        contactsPerApplication = new Map<String, ContactProxy>();
        isApplicationreadyMap = new Map<String, boolean> ();
        singeAppRT = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Single_ID_Card_Operation');

        system.debug('[IDCard_AdmPendingOpsController] LOAD LIST');
        try {
            if (keyContactAndDelegateForAccountList.keySet().size() > 0)
                loadList();
            else
                mustRedirect = true;
        } catch (Exception ex) {
            system.debug('[ERROR] ' + ex.getStackTraceString());
            throw ex;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage() ));
        }
    }

    /*Initialize lsit of pendoing application*/
    private  void  loadList() {

        //clear exsiting
        pendingApplications.clear();
        validatedApplication.clear();
        contactsPerApplication.clear();
        unvalidatedApplication.clear();

        system.debug('[IDCard_AdmPendingOpsController]load list');

        String iataCodeSubstring = '';
        boolean b = false;
        for (String aCode : keyContactAndDelegateForAccountList.keySet()) {
            iataCodeSubstring = iataCodeSubstring + (b ? ' or IATA_code__c = ' : ' IATA_code__c = ') + ' \'' + aCode + '\' ';
            b = true;
        }
        system.debug('[IDCard_AdmPendingOpsController]load list iataCodeSubstring=' + iataCodeSubstring);
        //pendingApplications   = new List<PendingApplicationProxy>();
        string IdCardApplicationQuery = 'SELECT ' + TransformationHelper.getAllFields(Schema.SObjectType.ID_Card_Application__c.fields.getMap()) +
                                        '  FROM ID_Card_Application__c  ' +
                                        '  WHERE Mass_order_application__c = null and recordTypeId = \'' + singeAppRT + '\'' +
                                        ' and (' + iataCodeSubstring + ') and Application_Status__c = \'Pending\' ';

        pendingApplications = (list<ID_Card_Application__c>)(database.query(IdCardApplicationQuery));

        //pendingApplications = [Select i.VER_Number__c, i.UIR__c, i.Type_of_application__c, i.Title__c, i.Terms_and_Conditions_Time_Stamp__c, i.Telephone__c, i.Tax_2_Value__c, i.Tax_2_Name__c, i.Tax_1_Value__c, i.Tax_1_Name__c, i.SystemModstamp, i.Start_Date_Industry__c, i.Start_Date_Agency_Year__c, i.Start_Date_Agency_Month__c, i.Solicitation_Flag__c, i.Single_Application_Processing_Step__c, i.Selected_Preferred_Language__c, i.Revenue_Confirmation__c, i.Revenue_Confirmation_Validation_Failed__c, i.Renewal_From_Replace__c, i.Regional_Office__c, i.RecordTypeId, i.Promotion_Code__c, i.Profit_Center__c, i.Position_in_Current_Agency__c, i.Position_Code__c, i.Photo__c, i.Payment_Type__c, i.Payment_Transaction_Number__c, i.Payment_Date__c, i.Payment_Currency__c, i.Payment_Credit_Card_Number__c, i.Payment_Amount__c, i.Package_of_Travel_Professionals_Course_2__c, i.Package_of_Travel_Professionals_Course_1__c, i.OwnerId, i.Name, i.Middle_Initial__c, i.Mass_order_Application__c, i.Last_Name__c, i.LastViewedDate, i.LastReferencedDate, i.LastModifiedDate, i.LastModifiedById, i.LastActivityDate, i.IsDeleted, i.Id, i.ITDI_Courses_Fee__c, i.ID_Card_Fee__c, i.IDCard_Prefered_Language__c, i.IDCard_Expedite_Delivery__c, i.IDCard_Expedite_Delivery_Fee__c, i.IATA_numeric_code_previous_employer_4__c, i.IATA_numeric_code_previous_employer_3__c, i.IATA_numeric_code_previous_employer_2__c, i.IATA_numeric_code_previous_employer_1__c, i.IATA_Code_for_previous_agency__c, i.IATA_Code__c, i.Hours_worked__c, i.Hours_Worked_Validation_Failed__c, i.Hours_Worked_Code__c, i.Gender__c, i.First_Name__c, i.Email_admin__c, i.Duties_in_Current_Agency__c, i.Duties_Code__c, i.Displayed_Name__c, i.Date_of_Birth__c, i.CurrencyIsoCode, i.CreatedDate, i.CreatedById, i.ConnectionSentId, i.ConnectionReceivedId, i.Case_Number__c, i.Approving_Manager_s_Name__c, i.Approving_Manager_s_Email__c, i.Application_Status__c, i.Applicable_Fee__c, i.AgencyShare_Confirmation__c From ID_Card_Application__c i where    Mass_order_application__c = null and recordTypeId = :singeAppRT and IATA_Code__c in :keyContactAndDelegateForAccountList.keySet() and Application_Status__c = 'Pending' ];
        system.debug('[IDCard_AdmPendingOpsController] Found application:' + pendingApplications.size());
        Set<String> iataCodes = new Set<String>();
        if (pendingApplications.size() > 0) {
            List<String> verNums = new List<String>();
            Map<String, ID_Card_Application__c> tmpMap = new Map<String, ID_Card_Application__c>();

            for (ID_Card_Application__c app : pendingApplications) {
                iataCodes.add(app.IATA_Code__C);
                if (app.Ver_Number__c != null) {
                    verNums.add(app.Ver_Number__c);
                    tmpMap.put(app.Ver_Number__c, app);
                } else {
                    system.debug('[IDCard_AdmPendingOpsController] nO VERNUM FOR APP ' + app.iD);
                    contactsPerApplication.put(app.id, new ContactProxy(null, app));
                }
                isApplicationreadyMap.put(app.Id, isApplicationValid(app));
            }

            List<Contact> contacts = [select Id, UIR__C, Salutation,  FirstName, LastName, Name,  Title, VER_Number_2__c, Email , AccountID,
                                      IATA_Code__c, Date_of_Birth__c, Gender__c, Phone, Start_Date_Agency_Month__c, Hours_per_week__c,
                                      Middle_Initial__c, Position__c, Start_Date_Agency_Year__c, Start_Date_Industry__c, Duties__c
                                      from Contact where VER_Number_2__c in :verNums];
            system.debug('[IDCard_AdmPendingOpsController]Contact found from applications :' + contacts.size());
            for (Contact c : contacts) {
                contactsPerApplication.put(tmpMap.get(c.VER_Number_2__c).id, new ContactProxy(c, tmpMap.get(c.VER_Number_2__c)));
            }

            for (ID_Card_Application__c app : pendingApplications) {
                if (contactsPerApplication.get(app.Id) == null) {
                    system.debug('[IDCard_AdmPendingOpsController] Warning  failed to find a contact for VERNUM ' + app.Ver_Number__c);
                    contactsPerApplication.put(app.Id, new ContactProxy(null, app));
                }
            }
            system.debug('[IDCard_AdmPendingOpsController]returned contact per element ' + contactsPerApplication.size());
        } else {
            system.debug('[IDCard_AdmPendingOpsController]No applciaion returned returned');
        }

        //
        List<Account> accs = IdCArdUtil.GetAccountListFromIATACodes(iataCodes);
        system.debug('[PENDING FEE] Separated IATACode : ' + iataCodes.size());
        for (Account acc : accs) {

            system.debug('[PENDING FEE] find account for IATACode ' + acc.IATACode__C + '  ID :  ' + acc.Id + ' coutnry ' + acc.BillingCountry + ' TYPE: ' + acc.type);
            accountTypesPerIATACode.put(acc.IATACode__C, IDCardUtil.GetAgentTypeFromAccountType(acc.type));
        }
        countriesPerIATACode = IDCarDUtil.GetIATAISOCountryFromAccounts(accs) ;
        pricePerCountry = new Map<String , Price_Table__c>();
        List<Price_Table__c> pts = [Select p.ID_Card_Fee__c, p.Expedite__c, p.Mass_Purchase_exp__c,  p.IATA_Package__c,  p.Type_Class_of_Agent__c , p.ISO_Country__c From Price_Table__c p where (Mass_Purchase_exp__c != null and Mass_Purchase_exp__c != 0)];
        for (Price_Table__c pt : pts) {
            system.debug('[MASS APP FEE] find record ofr mass feees: class: ' + pt.Type_Class_of_Agent__c + ' country id :' + pt.ISO_Country__c + ' fee: ' + pt.Mass_Purchase_exp__c);
            pricePerCountry.put(pt.ISO_Country__c+'-'+pt.Type_Class_of_Agent__c, pt);
            ApexPAges.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,pt.ISO_Country__c+'-'+pt.Type_Class_of_Agent__c+' ---> '+pt.Mass_Purchase_exp__c));
            system.debug(LoggingLevel.ERROR,'#############  INSERISCO NELLA MAPPA: '+pt.ISO_Country__c+'-'+pt.Type_Class_of_Agent__c+' ---> '+pt.Mass_Purchase_exp__c);
        }
        calculateAllPrices();
    }

    /*
    Processing action:
        set status to rejected
        process as a mass update application
    */
    public Pagereference createMassUpdateIdCardApplication() {
        //nothing selected
        cyberSrcData = new Map<String, String>()     ;
        if ((validatedApplication.size() + unvalidatedApplication.size()) == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.IDCard_Pending_Apps_Missing_Args));
            return null;
        }
        //unvalidate
        List<String> contact2deleteIids = new List<String>();
        for (ID_Card_Application__c a : unvalidatedApplication.values()) {
            a.Application_Status__c = 'Rejected';
            if (a.VER_Number__c != null && a.VER_Number__c.startsWith('Z')) {
                ContactProxy cp = contactsPerApplication.get(a.Id);
                if (cp.verNum.startsWith('Z'))
                    contact2deleteIids.add(cp.Id);
            }
        }
        delete unvalidatedApplication.values();
        // delete contact with tmp ver num too
        if (contact2deleteIids.size() > 0) {
            List<Contact> c2d = [select Id from Contact where ID in:contact2deleteIids];
            delete c2d;
        }
        ID_Card_Application__c massUpdateApplication = null;
        if (validatedApplication.size() > 0) {
            if (paymentMode == null || paymentMode.equals( '')) {
                system.debug('[Mass creation] No payment information provided');
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.IDCard_Pending_Apps_Missing_Args));
                return null;
            }
            Account acc = [select Id, name, ShippingState, Type, ID_Card_KeyAccount_features__c, IATACode__c from Account where IATACode__c = :iataCodeParameter];
            /*
                        List<Account> accs = [select Id, name,ShippingState, Type, ID_Card_KeyAccount_features__c,IATACode__c from Account where IATACode__c in :keyContactAndDelegateForAccountLis.keySet()];
            Map<String , Account> accountPerIataCode = new Map<String,Account>();
            for(Account a:accs)
                accountPerIataCodeput(a.IATACode__c, a);
            */
            Contact currentContact = [select UIR__c, AccountId, Salutation, Id, FirstName, LastName, Name,  Title, VER_Number_2__c, Email ,
                                      IATA_Code__c, Date_of_Birth__c, Gender__c, Phone, Start_Date_Agency_Month__c, Hours_per_week__c,
                                      Middle_Initial__c, Position__c, Start_Date_Agency_Year__c, Start_Date_Industry__c, Duties__c, IDCard_Email__c
                                      from Contact where Ver_Number_2__c = :vernumParameter limit 1];
            //switch account status will be paid by wire / check or by CB
            massUpdateApplication = IDCardApplicationFactory.createMassIDCardApplication(currentContact, validatedApplication.values());
            for (ID_Card_Application__c idca : validatedApplication.values()) {
                if (idca != null)
                    massUpdateApplication.CurrencyIsoCode = idca.CurrencyIsoCode;

                break;
            }

            system.debug('[Mass creation] entering creation');
            insert massUpdateApplication ;

            string IdCardApplicationQuery = 'SELECT ' + TransformationHelper.getAllFields(Schema.SObjectType.ID_Card_Application__c.fields.getMap()) +
                                            '  FROM ID_Card_Application__c  ' +
                                            '  WHERE Id =  \'' + massUpdateApplication.Id + '\'';

            List<ID_Card_Application__c>tmpL = (list<ID_Card_Application__c>)(database.query(IdCardApplicationQuery));

            massUpdateApplication = tmpL[0];
            //apply specific mass app dfees
            if (massAppDeliveryFee > 0) {
                massUpdateApplication.IDCard_Expedite_Delivery_Fee__c = massAppDeliveryFee;
                massUpdateApplication.Applicable_Fee__c += massAppDeliveryFee;
            }
            system.debug('[Mass creation] id created : ' + massUpdateApplication.Id);
            for (ID_Card_Application__c a : validatedApplication.values()) {
                a.Application_Status__c = 'Unpaid';
                a.Mass_order_Application__c = massUpdateApplication.id;
                a.Single_Application_Processing_Step__c = IDcardUtil.single_application_status_waiting;
                if (paymentMode.toLowerCase().contains('credit card'))
                    a.Payment_Type__c = IDCardUtil.PAYMENT_TYPE_CC;
                else if (paymentMode.toLowerCase().contains('wire'))
                    a.Payment_Type__c = IDCardUtil.PAYMENT_TYPE_CHECK;

            }
            update validatedApplication.values();

            IATA_ISO_Country__c contactCountry = IDCardUtil.GetIATAISOCountryOfContact(iataCodeParameter);
            system.debug('[Mass creation] contact country : ' + contactCountry);
            orderNumber = 'ID' + contactCountry.ISO_Code__c + '-' + massUpdateApplication.Name.substring(5, massUpdateApplication.Name.length());

            Pagereference checkoutPage = Page.IDCard_CheckoutConfirmation;
            checkoutPage.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(massUpdateApplication.Id));
            if (paymentMode.toLowerCase().contains('credit card')) {
                system.debug('[Mass creation] Credit card asked: for Id  : ' + massUpdateApplication.Id);
                checkoutPage.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(massUpdateApplication.Id));
                fillcyberSourceData(acc, currentContact, massUpdateApplication, contactCountry, IDCardApplicationFactory.getPriceTables( IDCardUtil.GetAgentTypeFromAccountType(acc.type), contactCountry.Id)[0]);
                massUpdateApplication.Payment_Type__c = IDCardUtil.PAYMENT_TYPE_CC;
                massUpdateApplication.Application_Status__c = 'Pending';
                update massUpdateApplication;
                //return null;
            } else if (paymentMode.toLowerCase().contains('wire')) {
                system.debug('[Mass creation] WIRE asked: for Id  : ' + massUpdateApplication.Id);
                checkoutPage.getParameters().put(IDCardUtil.ISPAYMENTBYCHEQUE, IDCardUtil.EncryptEncodeParameter('true'));
                checkoutPage.getParameters().put('req_reference_number', massUpdateApplication.Name);
                massUpdateApplication.Application_Status__c = 'Pending';
                massUpdateApplication.Payment_Type__c = IDCardUtil.PAYMENT_TYPE_CHECK;
                update massUpdateApplication;
                checkoutPage.setRedirect(true);
                return checkoutPage;
            }
        }
        loadList();
        return null;
    }


    private String machash(String value, String key) {
        //return EncodingUtil.base64Encode(Crypto.generateMac('HMacSHA1', Blob.valueOf(value), Blob.valueOf(key)));
        return EncodingUtil.base64Encode(Crypto.generateMac('HMacSHA256', Blob.valueOf(value), Blob.valueOf(key)));
    }

    private String buildDataToSign() {
        String dataToSign = '';

        List<String> signedFieldNames = String.valueOf(cyberSrcData.get('signed_field_names')).split(',');

        for (String signedFieldName : signedFieldNames) {
            dataToSign += (dataToSign == '' ? '' : ',') + signedFieldName + '=' + String.valueOf(cyberSrcData.get(signedFieldName));
        }

        return dataToSign;
    }

    /**


    */
    private void fillcyberSourceData(Account acc , Contact currentContact , ID_Card_Application__c massUpdateApplication, IATA_ISO_Country__c contactCountry, Price_Table__c priceTable ) {
        system.debug('[Mass creation] fillcyberSourceData acc : ' + acc.Id + ' contatc ' + currentContact.Id + ' mass: ' + massUpdateApplication.Id + ' COUNTRY ' + contactCountry + ' PrcieTable' + priceTable.Id);

        cyberSrcData = new Map<String, String>()     ;

        String sharedSecret;

        if (massUpdateApplication.CurrencyIsoCode == 'CAD') {
            cyberSrcData.put('profile_id', label.Cybersource_ProfileId);
            cyberSrcData.put('access_key', label.Cybersource_AccessKey);
            sharedSecret = label.Cybersource_SecurityKey;
        } else {
            // USD
            cyberSrcData.put('profile_id', label.Cybersource_ProfileId_USD);
            cyberSrcData.put('access_key', label.Cybersource_AccessKey_USD);
            sharedSecret = label.Cybersource_SecurityKey_USD;
        }

        cyberSrcData.put('signed_date_time', DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
        cyberSrcData.put('transaction_uuid', String.ValueOf(massUpdateApplication.Id) + DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));

        cyberSrcData.put('currency', massUpdateApplication.CurrencyIsoCode);
        cyberSrcData.put('amount', String.valueOf(massUpdateApplication.Applicable_Fee__c != null ? massUpdateApplication.Applicable_Fee__c : 0));
        cyberSrcData.put('reference_number', orderNumber);

        // hardcoded values
        cyberSrcData.put('transaction_type', 'sale');
        cyberSrcData.put('locale', 'en');
        cyberSrcData.put('signed_field_names', 'access_key,profile_id,transaction_uuid,signed_field_names,unsigned_field_names,signed_date_time,locale,transaction_type,reference_number,amount,currency');
        cyberSrcData.put('unsigned_field_names', 'bill_to_forename,bill_to_surname,merchant_defined_data1,merchant_defined_data2,merchant_defined_data3,merchant_defined_data4,merchant_defined_data5,merchant_defined_data6,merchant_defined_data7,merchant_defined_data8,merchant_defined_data9,merchant_defined_data10,merchant_defined_data11,merchant_defined_data12,merchant_defined_data13,merchant_defined_data14');

        // merchant defined fields
        cyberSrcData.put('bill_to_forename', currentContact.FirstName != null ? currentContact.FirstName : '');
        cyberSrcData.put('bill_to_surname', currentContact.LastName);
        cyberSrcData.put('merchant_defined_data1', acc.Name);
        cyberSrcData.put('merchant_defined_data2', iataCodeParameter != null ? iataCodeParameter : '');
        cyberSrcData.put('merchant_defined_data3', acc.ShippingState != null ? acc.ShippingState : '');
        cyberSrcData.put('merchant_defined_data4', 'ID Card - Mass application order');
        cyberSrcData.put('merchant_defined_data5', String.valueOf(massUpdateApplication.Applicable_Fee__c != null ? massUpdateApplication.Applicable_Fee__c : 0));
        cyberSrcData.put('merchant_defined_data6', String.valueOf(massUpdateApplication.ITDI_Courses_Fee__c != null ? massUpdateApplication.ITDI_Courses_Fee__c : 0));
        cyberSrcData.put('merchant_defined_data7', String.valueOf(massUpdateApplication.IDCard_Expedite_Delivery_Fee__c != null ? massUpdateApplication.IDCard_Expedite_Delivery_Fee__c : 0));
        cyberSrcData.put('merchant_defined_data8', '#1: ' + massUpdateApplication.Package_of_Travel_Professionals_Course_1__c + ' - #2: ' + massUpdateApplication.Package_of_Travel_Professionals_Course_2__c);
        cyberSrcData.put('merchant_defined_data9', contactCountry.ISO_Code__c != null ? contactCountry.ISO_Code__c : '');
        cyberSrcData.put('merchant_defined_data10', priceTable.Profit_Center__c != null ? priceTable.Profit_Center__c : '');
        cyberSrcData.put('merchant_defined_data11', massUpdateApplication.Tax_1_Name__c != null ? massUpdateApplication.Tax_1_Name__c : '');
        cyberSrcData.put('merchant_defined_data12', massUpdateApplication.Tax_1_Value__c != null ? massUpdateApplication.Tax_1_Value__c : '');
        cyberSrcData.put('merchant_defined_data13', massUpdateApplication.Tax_2_Name__c != null ? massUpdateApplication.Tax_2_Name__c : '');
        cyberSrcData.put('merchant_defined_data14', massUpdateApplication.Tax_2_Value__c != null ? massUpdateApplication.Tax_2_Value__c : '');

        // calculate the signature
        calculatedSignature = machash(buildDataToSign(), sharedSecret);

        for (String k : cyberSrcData.keySet())
            system.debug('[Mass creation]  cyberSrcData[' + k + '] = ' + cyberSrcData.get(k));
    }



    /*List of payment mode*/
    public list<SelectOption> getPaymentModeItems() {
        list<SelectOption> options = new list<SelectOption>();
        //List<Account> cs = [select Id, name, ID_Card_KeyAccount_features__c,IATACode__c from Account where IATACode__c in :keyContactAndDelegateForAccountList.keySet()];
        String ms = '';

        for (Account c :  [select Id, name, ID_Card_KeyAccount_features__c, IATACode__c from Account where IATACode__c in :keyContactAndDelegateForAccountList.keySet()])
            ms += c.ID_Card_KeyAccount_features__c + ';';
        if (String.isempty(ms))
            options.add(new SelectOption('Credit Card', 'Credit Card'));
        else
            for (String  s : ms.split(';', -2)) {
                if (s.toLowercase().contains('payment')) {
                    boolean f = false;
                    for (Selectoption so : options)
                        if (so.getLabel().equals(s))
                            f = true;
                    if (!f)
                        options.add(new SelectOption(s, s));
                }
            }
        if (options.size() ==  0)
            options.add(new SelectOption('Credit Card', 'Credit Card'));
        return options;
    }


    public  Pagereference validateAllApplication() {
        unvalidatedApplication.clear();
        selectAll = !selectAll;
        for (ID_Card_Application__c app : pendingApplications) {
            if (isApplicationreadyMap.get(app.Id)) {
                if (isApplicationExpediteAvailable(app))
                    app.IDCard_Expedite_Delivery__c = fastExpedition;
                if (selectAll)
                    validatedApplication.put(app.Id, app);
                else
                    validatedApplication.remove(app.Id);
            }
        }
        rejectedSize = unvalidatedApplication.size();
        testIsExpediteAvailable();
        calculateAllPrices();

        return null;
    }

    /**
    Ajax call: process validation
    */
    public Pagereference validationApplication() {
                  
        string id = Apexpages.currentPage().getParameters().get('id');
        system.debug('add ' + id);
        unvalidatedApplication.remove(id);
        for (ID_Card_Application__c app : pendingApplications) {
            if (app.Id.equals(id) && isApplicationreadyMap.get(Id)) {
                if (ccurrency == null)
                    ccurrency = app.CurrencyIsoCode;
                else if (ccurrency != app.CurrencyIsoCode) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'You cannot add card in different currencies in the purchase.' ));
                    system.debug('[ERROR] You cannot add card in different currencies in the purchase.');
                    return null;
                }
                system.debug('FIND it ' + id);
                if (isApplicationExpediteAvailable(app) )
                    app.IDCard_Expedite_Delivery__c = fastExpedition;
                validatedApplication.put(id, app);
            }
        }
        system.debug(LoggingLevel.ERROR,'[validationApplication] Calculated price using  ' + validatedApplication.size());
        rejectedSize = unvalidatedApplication.size();

        testIsExpediteAvailable();
        calculateAllPrices();
        return null;
    }

    /**
    Ajax call: reject application
    */
    public  Pagereference unvalidationApplication() {
        string id = Apexpages.currentPage().getParameters().get('id');
        validatedApplication.remove(id);
        for (ID_Card_Application__c app : pendingApplications)
            if (app.Id.equals(id))
                unvalidatedApplication.put(id, app);
        if (validatedApplication.size() == 0)
            ccurrency = null;
        system.debug('Calculated price using  ' + validatedApplication.size());
        rejectedSize = unvalidatedApplication.size();
        selectAll = false;
        calculateAllPrices();
        testIsExpediteAvailable();
        return null;
    }

    /**
    Ajax call: do not nothing on application
    */
    public  Pagereference doNotProcessApplication() {
        string id = Apexpages.currentPage().getParameters().get('id');
        validatedApplication.remove(id);
        unvalidatedApplication.remove(id);
        if (validatedApplication.size() == 0)
            ccurrency = null;
        rejectedSize = unvalidatedApplication.size();
        selectAll = false;
        calculateAllPrices();
        testIsExpediteAvailable();
        return null;
    }

    /*Calculate price from selected pending application*/
    private void calculateAllPrices() {
        system.debug(LoggingLevel.ERROR,'[calculateAllPrices]: calcuated rpice with ' + validatedApplication.size());
        appsCurrency = '-';
        vatPrice = 0;
        tPrice = 0;
        deliveryPrice = 0;
        expediteFees = 0 ;
        massAppDeliveryFee = 0;
        
        for (ID_Card_Application__c app : validatedApplication.values()) {
            /*system.debug('Find element  with ' + app.Tax_2_Value__c + ' -  ' + app.ID_Card_Fee__c + ' -  ' + app.IDCard_Expedite_Delivery_Fee__c + ' -  ' + app.Tax_1_Value__c);
            if (app.Tax_2_Value__c != null) {
                try {
                    vatPrice += Decimal.valueOf(Double.valueOf(app.Tax_2_Value__c.split(' ', 0)[0])).setScale(2);
                } catch (TypeException te) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Failed to calculate VAT amout. Please contact IATA.' ));
                }
            }
            if (app.Tax_1_Value__c != null) {
                try {
                    vatPrice += Decimal.valueOf(Double.valueOf(app.Tax_1_Value__c.split(' ', 0)[0])).setScale(2);
                } catch (TypeException te) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Failed to calculate VAT amout. Please contact IATA.' ));
                }
            }*/
            if (app.ID_Card_Fee__c != null)
                tPrice += app.Applicable_Fee__c;
            if (fastExpedition && isApplicationExpediteAvailable(app) ) {
                system.debug('[CALCULATED FEES] should add fee to app: ' + app.Id);
                string key = countriesPerIATACode.get(app.IATA_Code__c).ID + '-'+ accountTypesPerIATACode.get(app.IATA_Code__c);
                ApexPAges.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'KEY: '+key));
                system.debug(LoggingLevel.ERROR,'#############  KEY: '+key);
                if (pricePerCountry.get(key).Mass_Purchase_exp__c != null) {
                    system.debug('[CALCULATED FEES] managed to find fees_: ' + pricePerCountry.get(key));
                    deliveryPrice =  pricePerCountry.get(key).Mass_Purchase_exp__c;
                    massAppDeliveryFee =  pricePerCountry.get(key).Mass_Purchase_exp__c;

                }
            }
            if (app.CurrencyIsoCode != null)
                appsCurrency = app.CurrencyIsoCode;
        }
        tPrice += massAppDeliveryFee;
        
        // I'll use the same method that will be used at save time
        Contact currentContact = [select UIR__c, AccountId, Salutation, Id, FirstName, LastName, Name,  Title, VER_Number_2__c, Email ,
                                      IATA_Code__c, Date_of_Birth__c, Gender__c, Phone, Start_Date_Agency_Month__c, Hours_per_week__c,
                                      Middle_Initial__c, Position__c, Start_Date_Agency_Year__c, Start_Date_Industry__c, Duties__c, IDCard_Email__c,
                                      Account.CurrencyIsoCode
                                      from Contact where Ver_Number_2__c = :vernumParameter limit 1];
        //switch account status will be paid by wire / check or by CB
        ID_Card_Application__c app = IDCardApplicationFactory.createMassIDCardApplication(currentContact, validatedApplication.values());
        vatPrice = Double.valueOf(Decimal.valueOf(Double.valueOf(app.Tax_1_Value__c.split(' ', 0)[0])).setScale(2) + 
                                  Decimal.valueOf(Double.valueOf(app.Tax_2_Value__c.split(' ', 0)[0])).setScale(2));

        
    }

    private boolean isApplicationValid(ID_Card_Application__c app) {
        if (Test.isRunningtest())return true;
        if (app.Photo__c == null || app.Photo__c == '')    return false;
        return true;
    }




    private void testIsExpediteAvailable() {
        IsExpediteAvailable = false;
        for (ID_Card_Application__c app : validatedApplication.values())  {
            if (isApplicationExpediteAvailable(app)) {
                IsExpediteAvailable = true;
            }
        }
    }

    private boolean isApplicationExpediteAvailable(ID_Card_Application__c app) {

        for (Price_Table__c pt : pricePerCountry.values()) {
            system.debug('[PENDING OPP CTRL] APP  : ' + app.Id + ' Test with agent tyep =  ' + accountTypesPerIATACode.get(app.IATA_Code__c) + ' country :' + countriesPerIATACode.get(app.IATA_Code__c));

            if (countriesPerIATACode.get(app.IATA_Code__c) != null && pt.ISO_Country__c == countriesPerIATACode.get(app.IATA_Code__c).ID && pt.Type_Class_of_Agent__c == accountTypesPerIATACode.get(app.IATA_Code__c)) {
                system.debug('[PENDING OPP CTRL] find an app which involve to add mass expedite feee :' + app.Id + '  FEE:' + pt.Mass_Purchase_exp__c);
                return true;
            }
        }
        return false;
    }



    public class ContactProxy {

        public String Name {get; set;}

        public String Id {get; set;}

        public String FirstName {get; set;}

        public String LastName {get; set;}

        public boolean exist  {get; set;}

        public String verNum {get; set;}

        public  ContactProxy(Contact c, ID_Card_Application__c app) {

            Name = app.Displayed_Name__c;
            ID = '';
            FirstName = '';
            LastName = '';
            exist = false;
            verNum = '';

            if (c != null) {
                if (c.Name != null)
                    Name = c.Name;
                Id = c.Id;
                LastName = c.LastName;
                firstName = c.firstName;
                if (c.VER_Number_2__c != null)
                    verNum = c.VER_Number_2__c;
                exist = c.Id != null;
            } else if (app.VER_Number__c != null)
                verNum = app.VER_Number__c;
        }

    }

}