global with sharing class IDCardUtil {

    //flag to determine if idcard contact trigger can run more than once per execution
    public static Boolean isFirstTime = true;
    @RemoteAction
    public static final String PARAM_APPLICATIONTYPE = 'atype';
    @RemoteAction
    public static final String PARAM_IATACODE = 'iatacode';
    @RemoteAction
    public static final String PARAM_ERRMSG = 'errmsg';
    @RemoteAction
    public static final String PARAM_VER = 'ver';
    @RemoteAction
    public static final String PARAM_FNAME = 'fname';
    @RemoteAction
    public static final String PARAM_LNAME = 'lname';
    @RemoteAction
    public static final String PARAM_DOB = 'dob';
    @RemoteAction
    public static final String PARAM_APPID = 'appID';

    @RemoteAction
    public static final string PAYMENT_TYPE_INVOICE = 'Invoice'; //used to be cheque
    @RemoteAction
    public static final string PAYMENT_TYPE_CC = 'Credit Card';
    @RemoteAction
    public static final string PAYMENT_TYPE_FOC = 'FOC';
    @RemoteAction
    public static final string PAYMENT_TYPE_CHECK = 'CHECK';
    @RemoteAction
    public static final string PAYMENT_TYPE_KEY_ACCOUNT = 'Key Account';

    //TODO: Change to reflect new Application label change
    @RemoteAction
    public static final String APPLICATIONTYPE_NEW = 'New';
    @RemoteAction
    public static final String APPLICATIONTYPE_REPLACEMENT = 'Replacement';
    @RemoteAction
    public static final String APPLICATIONTYPE_RENEWAL = 'Renewal';
    @RemoteAction
    public static final String APPLICATIONTYPE_REISSUE = 'Reissue';
    @RemoteAction
    public static final String APPLICATIONTYPE_REISSUE_RENEWAL = 'Reissue_Renewal';
    @RemoteAction
    public static final String APPLICATIONSTATUS_PENDING = 'Pending';
    @RemoteAction
    public static final String APPLICATIONSTATUS_UNPAID = 'Unpaid';



    @RemoteAction
    public static final String IDCARDNATURE_NEW = 'New';
    @RemoteAction
    public static final String IDCARDNATURE_REPLACEMENT = 'Replacement';
    @RemoteAction
    public static final String IDCARDNATURE_RENEWAL = 'Renew';
    @RemoteAction
    public static final String IDCARDNATURE_REISSUE = 'Reissue';
    @RemoteAction
    public static final String IDCARDNATURE_CANCELED = 'Cancellation';

    @RemoteAction
    public static final String CARDSTATUS_PREAPPROVED = 'Preapproved';
    @RemoteAction
    public static final String CARDSTATUS_APPROVED = 'Sent ID Card';
    @RemoteAction
    public static final String CARDSTATUS_VALID = 'Valid ID Card';
    @RemoteAction
    public static final String CARDSTATUS_PRINTED_DELIVERED = 'Printed/Delivered';
    @RemoteAction
    public static final String CARDSTATUS_CANCELED = 'Cancelled ID Card';
    @RemoteAction
    public static final String CARDSTATUS_Expired = 'Expired ID Card';

    @RemoteAction
    public static final String AGENTTYPE_PASSENGER = 'Passenger';
    @RemoteAction
    public static final String AGENTTYPE_TIDS = 'TIDS';

    @RemoteAction
    public static final String AGENTTYPE_DOMESTICS_AGENT = 'Domestic';


    @RemoteAction
    public static final String ACCOUNT_TYPE_PASSENGER = 'IATA Passenger Sales Agent';
    @RemoteAction
    public static final String ACCOUNT_TYPE_TIDS = 'TIDS Agent';

    @RemoteAction
    public static final String ACCOUNT_TYPE_DOMESTICS_AGENT = 'Domestic Agent';

    @RemoteAction
    public static final   Set<String> ALLOWED_ACCOUNT_TYPES = new  Set<String> {ACCOUNT_TYPE_DOMESTICS_AGENT, ACCOUNT_TYPE_PASSENGER, ACCOUNT_TYPE_TIDS};

    @RemoteAction
    public static final String ACCOUNT_STATUS_LISTED = 'Listed';
    @RemoteAction
    public static final String ACCOUNT_STATUS_UNDER_REVIEW = 'Under review';
    @RemoteAction
    public static final String ACCOUNT_STATUS_CHANGES_PROCESSED = 'Changes processed';
    @RemoteAction
    public static final String ACCOUNT_STATUS_APPROVED = 'Approved';
    @RemoteAction
    public static final String ACCOUNT_STATUS_CASH_NOCOMMISSION = 'Cash basis/no commission';
    @RemoteAction
    public static final String ACCOUNT_STATUS_CASE_COMMISSION = 'Cash basis/with commission';
    @RemoteAction
    public static final   Set<String> ALLOWED_ACCOUNT_STATUS = new  Set<String> { ACCOUNT_STATUS_LISTED, ACCOUNT_STATUS_APPROVED , ACCOUNT_STATUS_CHANGES_PROCESSED, ACCOUNT_STATUS_UNDER_REVIEW, ACCOUNT_STATUS_CASH_NOCOMMISSION, ACCOUNT_STATUS_CASE_COMMISSION};
    @RemoteAction
    public static final String ACCOUNT_STATUS_TERMINATED = 'Terminated';

    @RemoteAction
    public static final string CASECARDSTATUS_APPROVED = 'Approved';
    @RemoteAction
    public static final string CASECARDSTATUS_REJECTED = 'Rejected';
    @RemoteAction
    public static final string CASECARDSTATUS_PENDING = 'Pending ID Card Approval';
    @RemoteAction
    public static final string CASECARDSTATUS_PENDING_ADD_VALIDATION = 'Pending ID Card Approval - Additional Validation';
    //public static final string CASECARDSTATUS_PENDING_PAYMENT = 'Pending Payment';
    @RemoteAction
    public static final string CASECARDSTATUS_PENDING_MNG_APPROVAL = 'Pending Manager Approval';

    @RemoteAction
    public static final string CASESTATUS_PENDING_AGENT_FEEDBACK = 'Pending Agent feedback';
    @RemoteAction
    public Static final string CASESTATUS_INPROGRESS = 'In progress';
    @RemoteAction
    public static final string CASESTATUS_READYFORPRODUCTION = 'Ready for production';

    @RemoteAction
    public static final string CASESTATUS_PENDING_TO_BE_APPROVED = 'To be Approved';



    @RemoteAction
    public static final string PAGE_PART = 'PART';
    @RemoteAction
    public static final string ISPAYMENTBYCHEQUE = 'PayByCheque';
    @RemoteAction
    public static final string ISFOC = 'FreeOfCharge';

    public static final String CREDENTIAL_NAME = 'IdCard';
    public static final String FOLDER_NAME = 'a0W';

    @RemoteAction
    public static Id IDCardContactRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
    @RemoteAction
    public static Id IDCardcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ID_Card_Application');
    public static String Key_Account_Feature_File    = 'CSV File Upload';
    public static String Key_Account_Feature_Email   = 'Email Application Before Renewal';
    public static String Key_Account_Feature_Payment_Wire_Check = 'Payment by Wire / Cheque';
    public static String Key_Account_Feature_Payment_Credit_Card  = 'Payment by Credit Card';
    public static String Key_Account_Feature_Immediate_Processing    = 'Process application without waiting for';
    public static String Key_Account_Feature_Allow_Personnal_Purchase = 'ID Card Paid by Applicant';
    public static String Key_Account_Feature_Only_KC_Purchase = 'Prohibit Applicant to Apply';
    public static String Key_Account_Feature_2_Years_validity = 'ID Cards validity is extended to 2 years';
    public static final string single_application_status_waiting = 'Waiting for processing';

    public static final String IDCARD_SERVICE_NAME = 'Id Card Holder';
    /**
        Get the Card holder Image Id running the query only once if required
    **/
    private static String CARD_HOLDER_IMAGE_ID = null;
    public static String getCardHolderImageId() {
        if (CARD_HOLDER_IMAGE_ID==null) {
            try {
                CARD_HOLDER_IMAGE_ID = [SELECT Id FROM Document WHERE DeveloperName = 'ID_card_PNG'].Id;
            } catch (Exception e) {
                CARD_HOLDER_IMAGE_ID = '';
            }
        }
        return CARD_HOLDER_IMAGE_ID;
    }
    
    public static String getCardHolderImageHtml() {
        String imageUrl = '/servlet/servlet.FileDownload?file=' + getCardHolderImageId();
        return '<img src="' + imageUrl + '" alt="' + IDCARD_SERVICE_NAME + '" title="' + IDCARD_SERVICE_NAME + '" border="0" height="40" width="40"/>';
    }

    // Variables for storing information and limit the queries in case of mass use.
    public static Account massAccount {get; set;}
    public static IATA_ISO_Country__c massCountry {get; set;}
    public static long massCounter {get; set;}
    public static id IdCardAIMSrt {get; set;}

    /**/

    /**
     * Encrypts and URL encode a string to be used as a GET parameter
     */
    public static String EncryptEncodeParameter(String strValue) {
        if (strValue == null || strValue == '')
            throw new IDCardApplicationException('strValue parameter is null or empty');
        return EncodingUtil.urlEncode(IDCardCryptoUtil.getInstance().EncryptString(Label.ID_Card_Encryption_Key, strValue), 'UTF-8');
    }

    /**
     * URL decode and decrypts a string
     */
    public static String DecodeDecryptParameter(String strValue) {
        if (strValue == null && Test.isRunningTest())
            return '';
        if (strValue == null || strValue == '')
            throw new IDCardApplicationException('strValue parameter is null or empty');

        try {
            return IDCardCryptoUtil.getInstance().DecryptString(Label.ID_Card_Encryption_Key, Encodingutil.urlDecode(strValue, 'UTF-8'));
        } catch (Exception ex) {
            throw new IDCardApplicationException('Invalid parameter:' + ex.getMessage() + ' - ' + ex.getStackTraceString());
        }
    }

    //to limit SOQL queries
    private static Map<String, IATA_ISO_Country__c> isoCountryPerIAtaCode = new  Map<String, IATA_ISO_Country__c> ();

    //Returns the country ISO code of a contact based on its IATA code
    public static IATA_ISO_Country__c GetIATAISOCountryOfContact(String iataCode) {
        if ( isoCountryPerIAtaCode.get(iataCode) != null)
            return isoCountryPerIAtaCode.get(iataCode);
        Account theAccount = IDCardUtil.GetAccountObjectFromIATACode(iataCode);
        IATA_ISO_Country__c[] listCountries = IATAIsoCountryDAO.getIsoCountriesByAIMSAreaName(theAccount.BillingCountry);
        if (listCountries == null || listCountries.size() == 0) {
            throw new IDCardApplicationException(string.format(Label.ID_Card_Invalid_ISO_Country, new string[] { theAccount.BillingCountry }));
        }
        isoCountryPerIAtaCode.put(iataCode, listCountries[0]);
        return listCountries[0];
    }



    /**
     * Returns the application fee of a Price Table based on the following: Regular/Reissue, with or without expedite and with or without ITDI Package
     */
    public static decimal GetApplicableFee(Price_Table__c priceTable, boolean isReissue, boolean isWithExpedite, boolean isWithITDIPackage, Promotion__c validPromo) {

        decimal applicableFee = 0.0;

        // reselect the price table (to make sure every required field has been queryed)
        //Price_Table__c thePriceTable = [Select p.ID_Card_Fee__c, p.Expedite__c, p.IATA_Package__c From Price_Table__c p where p.Id =: priceTable.Id limit 1];
        Price_Table__c thePriceTable = priceTable;

        if (isReissue) {
            applicableFee = (thePriceTable.ID_Card_Fee__c / 2);
        } else {
            applicableFee = thePriceTable.ID_Card_Fee__c;
        }

        if (validPromo != null) {
            // apply reduction percentage
            applicableFee = applicableFee - (applicableFee * (validPromo.Promotion_Value__c / 100.0));
        }

        if (isWithExpedite) {
            applicableFee = applicableFee + thePriceTable.Expedite__c;
        }

        if (isWithITDIPackage) {
            applicableFee = applicableFee + thePriceTable.IATA_Package__c;
        }

        return applicableFee;
    }

    public static Map<String, decimal> GetDetailledFees(Price_Table__c priceTable, boolean isReissue, boolean isWithExpedite, boolean isWithITDIPackage, Promotion__c validPromo) {
        return GetDetailledFees( priceTable,  isReissue,  isWithExpedite,  isWithITDIPackage,  validPromo, null);
    }

    /**
     * Returns a Map application detailled fee of a Price Table based on the following: Regular/Reissue, with or without expedite and with or without ITDI Package
     * Keys for the Map are : "IDCardFee", "PromoFee", "ExpediteFee", "ITDIFee"
     */
    public static Map<String, decimal> GetDetailledFees(Price_Table__c priceTable, boolean isReissue, boolean isWithExpedite, boolean isWithITDIPackage, Promotion__c validPromo, Id applicationRecordType) {

        Map<String, decimal> detailledFee = new Map<String, decimal>();
        decimal applicableFee;

        // reselect the price table (to make sure every required field has been queryed)

        Price_Table__c thePriceTable = priceTable;

        if (isReissue) {
            applicableFee = (thePriceTable.ID_Card_Fee__c / 2);
        } else {
            applicableFee = thePriceTable.ID_Card_Fee__c;
        }

        if (validPromo != null) {
            // apply reduction percentage
            detailledFee.put('IDCardFee', (applicableFee - (applicableFee * (validPromo.Promotion_Value__c / 100.0))));
            detailledFee.put('PromoFee', (validPromo.Promotion_Value__c / 100.0));
        } else {
            detailledFee.put('IDCardFee', (applicableFee));
            detailledFee.put('PromoFee', 0);
        }

        if (isWithExpedite) {
            if (applicationRecordType != null && applicationRecordType == RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Single_ID_Card_Operation'))
                detailledFee.put('ExpediteFee', (thePriceTable.Mass_Purchase_exp__c));
            else
                detailledFee.put('ExpediteFee', (thePriceTable.Expedite__c));
        } else {
            detailledFee.put('ExpediteFee', 0);
        }

        if (isWithITDIPackage) {
            detailledFee.put('ITDIFee', thePriceTable.IATA_Package__c);
        } else {
            detailledFee.put('ITDIFee', 0);
        }
        return detailledFee;
    }

    public static void generateAndAssignVERandUIR(ID_Card_Application__c application, Account theAccount) {
        if (massCountry == null || massCountry.AIMS_Area_Name__c != theAccount.BillingCountry) {
            massCountry = IATAIsoCountryDAO.getIsoCountriesByAIMSAreaName(theAccount.BillingCountry)[0];
            massCounter = null;
        }
        if (massCountry.ISO_Code_Numeric__c == null)
            massCountry.ISO_Code_Numeric__c = 0;
        string formattedIsoCodeNumeric = String.valueOf(massCountry.ISO_Code_Numeric__c).leftpad(3).left(3).replace(' ', '0');
        // If there are other VER numbers for this Country I just increase the highest
        if (massCounter == null) {
            List<Contact> c = database.query('SELECT Ver_Number_2__c ' +
                                             'FROM Contact ' +
                                             'WHERE  Ver_Number_2__c LIKE \'5' + formattedIsoCodeNumeric + '%\' ' +
                                             'ORDER BY Ver_Number_2__c DESC LIMIT 1  ');

            try {
                masscounter = Long.valueOf(c[0].VER_Number_2__c);
            } catch (Exception e) {
                masscounter = 0;
            }
        }
        massCounter++;

        string formattedCounter = String.valueOf(massCounter).right(6).leftpad(6).replace(' ', '0');
        string newVER = '5' + formattedIsoCodeNumeric + formattedCounter;
        string newUIR = massCountry.ISO_Code__c + formattedCounter;

        Savepoint sp = Database.setSavepoint();

        try {
            application.VER_Number__c = newVER;
            application.UIR__c = newUIR;
            System.debug('**** updating UIR ' + application.UIR__c + '  VER ' + application.VER_Number__c );
            update application;
        } catch (Exception ex) {
            System.debug('**** Error on generateAndAssignVERandUIR ' + ex);
            Database.rollback(sp);
            throw ex;
        }
        //}
    }

    public static string generateTMPVER( Account theAccount) {

        IATA_ISO_Country__c country = IATAIsoCountryDAO.getIsoCountriesByAIMSAreaName(theAccount.BillingCountry)[0];

        if (country.ISO_Code_Numeric__c == null)
            country.ISO_Code_Numeric__c = 0;
        string formattedIsoCodeNumeric =  String.valueOf(country.ISO_Code_Numeric__c).leftpad(3).left(3).replace(' ', '0');
        string newValue = 'New';
        string last12months = String.valueOf(System.now().addyears(-1).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\''));
        // If there are other VER numbers for this Country I just increase the highest
        List<Contact> c = database.query('SELECT Ver_Number_2__c ' +
                                         'FROM Contact ' +
                                         'WHERE  Ver_Number_2__c LIKE \'5' + formattedIsoCodeNumeric + '%\' ' +
                                         'or  Ver_Number_2__c LIKE \'Z5' + formattedIsoCodeNumeric + '%\' ' +
                                         'ORDER BY Ver_Number_2__c DESC LIMIT 1  ');
        List<ID_Card_Application__c> a = database.query('SELECT Ver_Number__c ' +
                                         'FROM ID_Card_Application__c ' +
                                         'WHERE  CreatedDate > ' + last12months + ' AND Type_of_application__c = :newValue AND (Ver_Number__c LIKE \'5' + formattedIsoCodeNumeric + '%\' ' +
                                         'or  Ver_Number__c LIKE \'Z5' + formattedIsoCodeNumeric + '%\')' +
                                         'ORDER BY Ver_Number__c DESC LIMIT 1  ');

        long counter, counterapp;
        try {
            counter = Long.valueOf(c[0].VER_Number_2__c.replace('Z', ''));
        } catch (Exception e) {
            counter = 0;
        } try {
            counterapp = Long.valueOf(a[0].VER_Number__c.replace('Z', ''));
        } catch (Exception e) {
            counterapp = 0;
        }
        counter = Math.max(counter, counterapp);
        counter++;

        string formattedCounter = String.valueOf(counter).right(6).leftpad(6).replace(' ', '0');
        string newVER = 'Z5' + formattedIsoCodeNumeric + formattedCounter;
        system.debug('VER# ' + newVER);
        return newVer;
    }


    public static string generateTMPUIR( Account theAccount) {

        IATA_ISO_Country__c country = IATAIsoCountryDAO.getIsoCountriesByAIMSAreaName(theAccount.BillingCountry)[0];

        if (country.ISO_Code_Numeric__c == null)
            country.ISO_Code_Numeric__c = 0;
        string formattedIsoCodeNumeric =  String.valueOf(country.ISO_Code_Numeric__c).leftpad(3).left(3).replace(' ', '0');
        // If there are other VER numbers for this Country I just increase the highest
        List<Contact> c = database.query('SELECT Ver_Number_2__c ' +
                                         'FROM Contact ' +
                                         'WHERE  Ver_Number_2__c LIKE \'5' + formattedIsoCodeNumeric + '%\' ' +
                                         'or  Ver_Number_2__c LIKE \'Z5' + formattedIsoCodeNumeric + '%\' ' +
                                         'ORDER BY Ver_Number_2__c DESC LIMIT 1  ');
        List<ID_Card_Application__c> a = database.query('SELECT Ver_Number__c ' +
                                         'FROM ID_Card_Application__c ' +
                                         'WHERE  Ver_Number__c LIKE \'5' + formattedIsoCodeNumeric + '%\' ' +
                                         'or  Ver_Number__c LIKE \'Z5' + formattedIsoCodeNumeric + '%\' ' +
                                         'ORDER BY Ver_Number__c DESC LIMIT 1  ');

        long counter, counterapp;
        try {
            counter = Long.valueOf(c[0].VER_Number_2__c.replace('Z', ''));
        } catch (Exception e) {
            counter = 0;
        } try {
            counterapp = Long.valueOf(a[0].VER_Number__c.replace('Z', ''));
        } catch (Exception e) {
            counterapp = 0;
        }
        counter = Math.max(counter, counterapp);
        counter++;


        string formattedCounter = String.valueOf(counter).right(6).leftpad(6).replace(' ', '0');
        string newVER = '5' + formattedIsoCodeNumeric + formattedCounter;
        string newUIR =  formattedCounter + 'ZZ';
        return newUIR;
    }


    public static string generateVER( Account theAccount) {

        IATA_ISO_Country__c country = IATAIsoCountryDAO.getIsoCountriesByAIMSAreaName(theAccount.BillingCountry)[0];

        if (country.ISO_Code_Numeric__c == null)
            country.ISO_Code_Numeric__c = 0;
        string formattedIsoCodeNumeric =  String.valueOf(country.ISO_Code_Numeric__c).leftpad(3).left(3).replace(' ', '0');
        // If there are other VER numbers for this Country I just increase the highest
        List<Contact> c = database.query('SELECT Ver_Number_2__c ' +
                                         'FROM Contact ' +
                                         'WHERE  Ver_Number_2__c LIKE \'5' + formattedIsoCodeNumeric + '%\' ' +
                                         'ORDER BY Ver_Number_2__c DESC LIMIT 1  ');



        long counter;
        try {
            counter = Long.valueOf(c[0].VER_Number_2__c);
        } catch (Exception e) {
            counter = 0;
        }
        counter++;


        string formattedCounter = String.valueOf(counter).right(6).leftpad(6).replace(' ', '0');
        string newVER = '5' + formattedIsoCodeNumeric + formattedCounter;
        string newUIR = country.ISO_Code__c + formattedCounter;
        return newVer;
    }


    public static string generateUIR( Account theAccount) {

        IATA_ISO_Country__c country = IATAIsoCountryDAO.getIsoCountriesByAIMSAreaName(theAccount.BillingCountry)[0];

        if (country.ISO_Code_Numeric__c == null)
            country.ISO_Code_Numeric__c = 0;
        string formattedIsoCodeNumeric =  String.valueOf(country.ISO_Code_Numeric__c).leftpad(3).left(3).replace(' ', '0');
        // If there are other VER numbers for this Country I just increase the highest
        List<Contact> c = database.query('SELECT Ver_Number_2__c ' +
                                         'FROM Contact ' +
                                         'WHERE  Ver_Number_2__c LIKE \'5' + formattedIsoCodeNumeric + '%\' ' +
                                         'ORDER BY Ver_Number_2__c DESC LIMIT 1  ');


        long counter;
        try {
            counter = Long.valueOf(c[0].VER_Number_2__c);
        } catch (Exception e) {
            counter = 0;
        }
        counter++;


        string formattedCounter = String.valueOf(counter).right(6).leftpad(6).replace(' ', '0');
        string newVER = '5' + formattedIsoCodeNumeric + formattedCounter;
        string newUIR = country.ISO_Code__c + formattedCounter;
        return newUIR;
    }



    public static map<string, long> generateVERforMultipleAccounts( list<Account> theAccounts) {
        map<string, long> CountriesToVER = new map<string, long>();
        set<string> BillingCountries = new set<string>();

        // 1: I get all billing countries
        for (Account a : theAccounts) {
            BillingCountries.add(a.BillingCountry);
        }

        // 2: I get country code for each country
        map<string, string> CountryToISOCode = new map<string, string>();
        set<string> filters = new set<string>();
        for (IATA_ISO_Country__c c : IATAIsoCountryDAO.getIsoCountriesByAIMSAreaName(BillingCountries)){

            if (c.ISO_Code_Numeric__c == null)
                c.ISO_Code_Numeric__c = 0;
            string formattedIsoCodeNumeric =  String.valueOf(c.ISO_Code_Numeric__c).leftpad(3).left(3).replace(' ', '0');
            CountryToISOCode.put(c.AIMS_Area_Name__c, formattedIsoCodeNumeric);
            filters.add('5' + formattedIsoCodeNumeric + '%');
        }


        // 3. I get the max vernumber for each country
        // If there are other VER numbers for this Country I just increase the highest
        //map<string, string> CountryToMaxVER = new map<string,string>();
        for (AggregateResult ag : database.query('SELECT MAX(Ver_Number_2__c) mv, Account.BillingCountry bc ' +
                'FROM Contact ' +
                'WHERE Ver_Number_2__c LIKE :filters   ' +
                'GROUP BY  Account.BillingCountry')) {
            string bc = String.valueOf(ag.get('bc'));
            long counter;
            try {
                counter = Long.valueOf(String.valueOf(ag.get('mv')));
            } catch (Exception e) {
                counter = 0;
            }
            counter++;
            string formattedCounter = String.valueOf(counter).right(6).leftpad(6).replace(' ', '0');

            string formattedIsoCodeNumeric = CountryToISOCode.get(bc);
            if (formattedIsoCodeNumeric == null)
                formattedIsoCodeNumeric =  String.valueOf(0).leftpad(3).left(3).replace(' ', '0');

            long newVER = Long.valueOf('5' + formattedIsoCodeNumeric + formattedCounter);
            CountriesToVER.put(bc.tolowercase(), newVER);
        }


        return CountriesToVER;
    }


    public static map<string, string> generateUIRforMultipleAccounts( list<Account> theAccounts) {
        map<string, string> CountriesToUIR = new map<string, string>();
        set<string> BillingCountries = new set<string>();

        // 1: I get all billing countries
        for (Account a : theAccounts) {
            BillingCountries.add(a.BillingCountry);
        }

        system.debug('@@@@@@@@@@@@@  generateUIRforMultipleAccounts() BillingCountries = ' + BillingCountries);

        // 2: I get country code for each country
        map<string, string> CountryToISOCode = new map<string, string>();
        set<string> filters = new set<string>();
        for (IATA_ISO_Country__c c : IATAIsoCountryDAO.getIsoCountriesByAIMSAreaName(BillingCountries)) {

            if (c.ISO_Code__c == null)
                c.ISO_Code__c = '';
            CountryToISOCode.put(c.AIMS_Area_Name__c.tolowercase(), c.ISO_Code__c);
            filters.add(c.ISO_Code__c + '%');
        }

        // 3. I get the max vernumber for each country
        // If there are other VER numbers for this Country I just increase the highest
        //map<string, string> CountryToMaxVER = new map<string,string>();
        for (AggregateResult ag : database.query('SELECT MAX(UIR__c) mv, Account.BillingCountry bc ' +
                'FROM Contact ' +
                'WHERE UIR__C LIKE :filters   ' +
                'GROUP BY  Account.BillingCountry')) {
            string bc = String.valueOf(ag.get('bc'));
            long counter;

            string isocode = CountryToISOCode.get(bc.tolowercase());
            system.debug('@@@@@@@@@@@@@  bc=' + bc + ' - counter = ' + ag.get('mv') + ' - isocode = ' + isocode);
            try {
                counter = Long.valueOf(String.valueOf(ag.get('mv')).substring(isocode.length()));
            } catch (Exception e) {
                system.debug('@@@@@@@@@@@@@  exception  = ' + e);
                counter = 0;
            }
            counter++;
            string formattedCounter = String.valueOf(counter).right(6).leftpad(6).replace(' ', '0');


            if (isocode == null)
                isocode =  '';

            string newUIR = isocode + formattedCounter;
            CountriesToUIR.put(bc.tolowercase(), newUIR);
        }

        return CountriesToUIR;
    }


    public static String increaseUIR(string oldUIR) {
        long counter = Long.valueOf(String.valueOf(oldUIR.substring(oldUIR.length() - 6)));
        counter ++;
        string formattedCounter = String.valueOf(counter).right(6).leftpad(6).replace(' ', '0');
        string isocode = oldUIR.substring(0, oldUIR.length() - 6);
        string newUIR = IsoCode + formattedCounter;
        return newUIR;
    }

    /**
     * Rename the temp photo filename of contact (guid) to the new generated UIR
     */
    @future(callout = true)
    public static void renameIDCardPhotoOfContact(ID CardApplicationID, String oldPhotoName, String sessionID) {
        system.debug('Picture web service ' + CardApplicationID + ' / ' + oldPhotoName + ' / ' + sessionId);
        String newFilename;
        String existingFilename;  // the file already attached to the IdCard Application
        String extension;
        ID_Card_Application__c idCardApp;

        try {
            // re-select ID Card Application object
            idCardApp = [Select Photo__c, Id, UIR__c From ID_Card_Application__c where Id = :CardApplicationID limit 1];

            existingFilename = idCardApp.Photo__c;
            system.debug('existingFilename :' + existingFilename);

            system.debug('renameIDCardPhotoOfContact - OldName:' + oldPhotoName);
            if (oldPhotoName == '') {
                Integer indexOfDot = idCardApp.Photo__c.lastIndexOf('.'); //indexOf('.');
                system.debug('Index of dot: ' + indexOfDot);
                if (indexOfDot == -1) {
                    system.debug('failed to retreive extension');

                    throw new IDCardApplicationException('Invalid filename : ' + idCardApp.Photo__c);
                }
                extension = idCardApp.Photo__c.substring(indexOfDot);
                system.debug('Extension: ' + extension);
                newFilename = idCardApp.UIR__c + extension;
            } else { // When the old photo name is something else than an empty string, it means we try to rollback the name of the photo to its old name
                newFilename = oldPhotoName;
            }
            system.debug('NewFileName :' + newFilename);

            // WEB SERVICE CALL FOR THE NEW STORAGE ON AMAZON S3
            if (newFilename != existingFilename) {

                if (existingFilename != null) existingFilename = EncodingUtil.urlDecode(existingFilename, 'UTF-8');

                if (newFilename != null)  newFilename = EncodingUtil.urlDecode(newFilename, 'UTF-8');

                Amazon_Cred__c Amazon_Cred = Amazon_Cred__c.getInstance(CREDENTIAL_NAME);
                if (Amazon_Cred == null) {
                    TransformationHelper.sendEmailSupport('FATAL: AmazonCredentials ' + CREDENTIAL_NAME , 'AmazonCredentials   ' + CREDENTIAL_NAME );
                    throw new transformationException('Error Credentials: no value found on the settings!');
                }

                String configurationName = UserInfo.getOrganizationId().substring(0, 15) == '00D2000000008TF'  ? Amazon_Cred.Prod_Configuration__c : Amazon_Cred.Dev_Configuration__c ;
                AWSTools aws = AWSTools.getInstance(configurationName);

                AmazonCredentials credential = AmazonCredentials.getCredentials(CREDENTIAL_NAME);

                Boolean success = aws.renameFileInS3(credential.Bucket, FOLDER_NAME + '/' + existingFilename, FOLDER_NAME + '/' + newFilename);

                if (success) {
                    // update ID Card application
                    idCardApp.Photo__c = newFilename;
                    update idCardApp;

                    // update ID Card
                    ID_Card__c idCard = [Select Photo__c, Id From ID_Card__c where ID_Card_Application__c = : idCardApp.Id limit 1];
                    idCard.Photo__c = newFilename;
                    update idCard;
                } else {
                    throw new IDCardApplicationException('Error renaming the photo file on Amazon S3');
                }
            }

            return;
        } catch (Exception ex) {
            system.debug('ex.getMessage(): ' + ex.getMessage());
            throw ex;
        }
    }

    /**
     * Generates a new GUID
     */
    public static String NewGuid() {

        String kHexChars = '0123456789abcdef';
        String returnValue = '';
        Integer nextByte = 0;

        for (Integer i = 0; i < 16; i++) {

            if (i == 4 || i == 6 || i == 8 || i == 10)
                returnValue += '-';

            nextByte = (Math.round(Math.random() * 255) - 128) & 255;

            if (i == 6) {
                nextByte = nextByte & 15;
                nextByte = nextByte | (4 << 4);
            }

            if (i == 8) {
                nextByte = nextByte & 63;
                nextByte = nextByte | 128;
            }

            returnValue += getCharAtIndex(kHexChars, nextByte >> 4);
            returnValue += getCharAtIndex(kHexChars, nextByte & 15);
        }

        return returnValue;
    }


    /**
     * Generate the CIN/TCIN for newly created ID Card records
     */
    @future(callout = true)
    public static void generateAndAssignCIN(set<ID> lstIdCardIds) {

        list<ID_Card__c> lstIdCards = [SELECT Id, CIN__c, FirstName__c, LastName__c, Date_of_Birth__c, Position_Code__c, Duty_Code__c, HourWorkedCode__c, Gender__c, ID_Card_Application__r.UIR__c  FROM ID_Card__c WHERE Id IN :lstIdCardIds AND RecordType.DeveloperName = 'AIMS'];

        map<Id, String> mapCinTemplatePerIdCardId = new map<Id, String>();
        map<String, Integer> mapIncDigitsPerCinTemplate = new map<String, Integer>();
        set<String> setCinTemplates = new set<String>();

        for (ID_Card__c idCard : lstIdCards) {
            String CIN = '';
            try {
                CIN += idCard.LastName__c.left(3);
                CIN += Datetime.newInstanceGmt(idCard.Date_of_Birth__c.year(), idCard.Date_of_Birth__c.month(), idCard.Date_of_Birth__c.day()).format('yy', 'GMT');
                CIN += idCard.FirstName__c.left(1);
                CIN += Datetime.newInstanceGmt(idCard.Date_of_Birth__c.year(), idCard.Date_of_Birth__c.month(), idCard.Date_of_Birth__c.day()).format('MMdd', 'GMT');
                CIN += '__'; // THE INCREMENT DIGITS
                CIN += idCard.Position_Code__c != '' ? idCard.Position_Code__c : ' ';
                CIN += idCard.Duty_Code__c != '' ? idCard.Duty_Code__c : ' ';
                CIN += idCard.HourWorkedCode__c != '' ? idCard.HourWorkedCode__c : ' ';

                if (idCard.ID_Card_Application__c != null && idCard.ID_Card_Application__r.UIR__c != null) {
                    CIN += idCard.ID_Card_Application__r.UIR__c.left(2);
                }
            } catch (Exception e) {
                // empty fields could lead to this
                system.debug('Error generating CIN: ' + e.getMessage());
            }

            // CIN += idCard.... ; // Industry Qualification

            CIN = CIN.toUpperCase();

            // add a temporary prefix for sex M/F, REMOVE IT BEFORE ASSIGNING to the ID Card
            CIN = (idCard.Gender__c == 'Male' ? 'M' : 'F') + CIN;

            mapCinTemplatePerIdCardId.put(idCard.Id, CIN);
            mapIncDigitsPerCinTemplate.put(CIN, idCard.Gender__c == 'Male' ? 0 : 50);
            setCinTemplates.add(CIN.substring(1)); // add to the set without the prefix, to correctly match in the DB

            system.debug('CIN template: ' + CIN.substring(1));
        }

        // Get current max for the increment digits for each template

        list<ID_Card__c> lstRelatedIdCards = [SELECT Id, CIN__c, LastName__c, Gender__c FROM ID_Card__c WHERE CIN__c <> null AND CIN__c LIKE :setCinTemplates];

        for (ID_Card__c idcard : lstRelatedIdCards) {
            system.debug('Found related CIN: ' + idcard.CIN__c);

            // for Last Names shorter than 3 chars
            Integer LNamelength = idCard.LastName__c.left(3).length();
            Integer incDigitsStartPosition = LNamelength + 7; // 10 normally

            system.debug('incDigitsStartPosition: ' + incDigitsStartPosition);

            Integer incDigits = Integer.valueOf(idcard.CIN__c.mid(incDigitsStartPosition, 2));

            if ( incDigits > mapIncDigitsPerCinTemplate.get( (idcard.Gender__c == 'Male' ? 'M' : 'F') + idcard.CIN__c.left(incDigitsStartPosition) + '__' + idcard.CIN__c.substring(incDigitsStartPosition + 2) ) ) {
                mapIncDigitsPerCinTemplate.put( (idcard.Gender__c == 'Male' ? 'M' : 'F') + idcard.CIN__c.left(incDigitsStartPosition) + '__' + idcard.CIN__c.substring(incDigitsStartPosition + 2), incDigits );
            }
        }


        // Set the new inc digits into the CINs and assign them

        for (ID_Card__c idCard : lstIdCards) {
            // Get the increment digits
            Integer incDigits = mapIncDigitsPerCinTemplate.get(mapCinTemplatePerIdCardId.get(idCard.Id));

            //increase the digits for the new card
            incDigits++;

            // update the increased digits in the map
            mapIncDigitsPerCinTemplate.put(mapCinTemplatePerIdCardId.get(idCard.Id), incDigits);

            // insert the digits in the CIN template for the idcard
            String strCIN = mapCinTemplatePerIdCardId.get(idCard.Id).replace('__', String.valueOf(incDigits).leftPad(2).replace(' ', '0'));

            // remove the temporary prefix (M/F)
            strCIN = strCIN.substring(1);

            idCard.CIN__c = strCIN;

            system.debug('New CIN assigned: ' + strCIN);
        }


        Database.SaveResult[] srList = Database.update(lstIdCards, false);


        // Iterate through each returned result
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully updated idcard CIN. idcard ID: ' + sr.getId());
            } else {
                // Operation failed, so get all errors
                for (Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('ID Card fields that affected this error: ' + err.getFields());
                }
            }
        }

    }


    private static String getCharAtIndex(String str, Integer index) {
        if (str == null)
            return null;

        if (str.length() <= 0)
            return str;

        if (index == str.length())
            return null;

        return str.substring(index, index + 1);
    }

    /**
     * Map the account agent type to the ID Card Application agent type
     */
    public static String GetAgentTypeFromAccountType(String accountType) {

        String agentType = '';
        if (accountType == ACCOUNT_TYPE_PASSENGER) {
            agentType = IDCardUtil.AGENTTYPE_PASSENGER;
        } else if (accountType == ACCOUNT_TYPE_TIDS) {
            agentType = IDCardUtil.AGENTTYPE_TIDS;
        } else if (accountType == ACCOUNT_TYPE_DOMESTICS_AGENT) {
            agentType = IDCardUtil.AGENTTYPE_DOMESTICS_AGENT;
        }
        if (agentType == '') {
            throw new IDCardApplicationException('Invalid agent type: ' + accountType);
        }
        return agentType;
    }

    /**
     * Map the account agent type to the ID Card Application agent type
     */
    public static String GetIDCardNatureFromApplicationType(String applicationType) {

        String idCardNature = '';
        if (applicationType == IDCardUtil.APPLICATIONTYPE_NEW) {
            idCardNature = IDCardUtil.IDCARDNATURE_NEW;
        } else if (applicationType == IDCardUtil.APPLICATIONTYPE_REPLACEMENT) {
            idCardNature = IDCardUtil.IDCARDNATURE_REPLACEMENT;
        } else if (applicationType == IDCardUtil.APPLICATIONTYPE_RENEWAL) {
            idCardNature = IDCardUtil.IDCARDNATURE_RENEWAL;
        } else if (applicationType == IDCardUtil.APPLICATIONTYPE_REISSUE) {
            idCardNature = IDCardUtil.IDCARDNATURE_REISSUE;
        }

        if (idCardNature == '') {
            throw new IDCardApplicationException('Invalid application type: ' + applicationType);
        }
        return idCardNature;
    }

    // Use this method to create a IDCard object for a new Application (no contact is linked to the card before a Salesforce user approve the cases related to this new card)
    public static ID_Card__c CreateIDCardObjectFromApplication(ID_Card_Application__c objApp) {
        return CreateIDCardObjectFromApplication(objApp, null);
    }

    /**
     * Creates an ID Card object from an ID Card application
     */
    public static ID_Card__c CreateIDCardObjectFromApplication(ID_Card_Application__c objApp, Contact theContact) {

        Account theAccount;
        try {
            Case a = [ Select Account.Id from Case where Related_ID_Card_Application__c = : objApp.Id limit 1];
            theAccount = [ Select Name, ID_Card_Corporate_Validation_Date__c, IATA_Area__c, IATACode__c, Type, Id, IDCard_Key_Account__c From Account where Id = : a.Account.Id limit 1];
        }
        catch ( Exception e) {
            System.debug('**** Error doing workaround ' + e);
            theAccount = [Select a.Name, a.ID_Card_Corporate_Validation_Date__c, a.IATA_Area__c, a.IATACode__c, a.Type, IDCard_Key_Account__c From Account a where a.RecordType.Name = 'Agency' AND a.IATACode__c = : objApp.IATA_Code__c limit 1];
        }

        system.debug(LoggingLevel.ERROR, '[CreateIDCardObjectFromApplication] start! ' + objApp.Displayed_Name__c);

        try {
            ID_Card__c idCard = new ID_Card__c();
            idCard.Agency_IATA_Code__c = theAccount.IATACode__c;
            idCard.Agency_Name__c = theAccount.Name;
            idCard.Approving_Manager_s_Name__c = objApp.Approving_Manager_s_Name__c;
            idCard.Approving_Manager_s_Email__c = objApp.Approving_Manager_s_Email__c;
            idCard.Blacklisted__c = false;
            idCard.Card_Status__c = IDCardUtil.CARDSTATUS_APPROVED;
            idCard.CurrencyIsoCode = objApp.CurrencyIsoCode;
            idCard.Date_of_Birth__c = objApp.Date_of_Birth__c;
            idCard.Duties__c = objApp.Duties_in_Current_Agency__c;
            idCard.Email__c = objApp.Email_admin__c;
            idCard.Fee_Applicable__c = objApp.ID_Card_Fee__c;
            idCard.FirstName__c = objApp.First_Name__c;
            idCard.Gender__c = objApp.Gender__c;
            idCard.Hours_per_week__c = objApp.Hours_worked__c;
            idCard.ID_Card_Application__c = objApp.Id;
            idcard.Is_Expedite__c = objApp.IDCard_Expedite_Delivery__c;
            idCard.LastName__c = objApp.Last_Name__c;
            idCard.Middle_Initial__c = objApp.Middle_Initial__c;
            idCard.Name_on_ID_Card__c = objApp.Displayed_Name__c;
            idCard.Nature_of_ID_Card__c = GetIDCardNatureFromApplicationType(objApp.Type_of_application__c);
            idCard.Position__c = objApp.Position_in_Current_Agency__c;
            idCard.Photo__c = objApp.Photo__c;
            idCard.Photo_Flag__c = 'Digital';
            idCard.Phone__c = objApp.Telephone__c;
            idCard.Profit_Center__c = objApp.Profit_Center__c;
            idCard.Paid__c = 'Y';
            idCard.Payment_Type__c = objApp.Payment_Type__c;
            idCard.Renewal_From_Replace__c = objApp.Renewal_From_Replace__c;
            idCard.Start_Date_Industry__c = objApp.Start_Date_Industry__c;
            idCard.Start_Date_Agency_Month__c = objApp.Start_Date_Agency_Month__c;
            idCard.Start_Date_Agency_Year__c = objApp.Start_Date_Agency_Year__c;
            idCard.Type_of_ID_Card__c = GetAgentTypeFromAccountType(theAccount.type);
            idCard.Title__c = (objApp.Title__c != null && objApp.Title__c.length() <= 5) ? objApp.Title__c : '';
            idcard.VER_Number__c = objApp.VER_Number__c;
            //set sync to true
            idCard.MustSyncWithAIMS__c = true;

            if (IdCardAIMSrt == null)
                IdCardAIMSrt = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card__c', 'AIMS');
            idcard.RecordTypeId = IdCardAIMSrt;

            //Get Start and End date and put them on the new idcard
            idCardStartEndDate StartEndDate = getIdCardStartEndDate(theAccount, objApp, theContact);
            idCard.Valid_To_Date__c = StartEndDate.EndDate;
            idCard.Valid_From_Date__c = StartEndDate.StartDate;

            if (theAccount.ID_Card_Corporate_Validation_Date__c != null)
                idCard.Valid_To_Date__c = theAccount.ID_Card_Corporate_Validation_Date__c;
            if (idCard.Type_of_ID_Card__c == AGENTTYPE_PASSENGER) {
                idCard.Card_Code__c = 'TACB';
            } else { idCard.Card_Code__c = 'TACT'; }

            if (theContact != null) {
                idCard.Related_Contact__c = theContact.Id;
            }
            system.debug(LoggingLevel.ERROR, '[CreateIDCardObjectFromApplication] return ' + idcard);
            return idCard;
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, '[CreateIDCardObjectFromApplication] ################ ERROR : ' + ex.getStackTraceString());
            return null;
        }

    }

    //Class used to calculate start and end date for a new idcard
    public class idCardStartEndDate {
        public date EndDate;
        public date StartDate;

        //Check if the given account has a corportate id card with an In future end date
        public date EndDateCheckAccnt(Account accnt, date dStartDate, date dToday, date LastCardEndDate) {
            if (Accnt != null)
                if (accnt.IDCard_Key_Account__c && (accnt.ID_Card_Corporate_Validation_Date__c != null && accnt.ID_Card_Corporate_Validation_Date__c > dToday))
                    return accnt.ID_Card_Corporate_Validation_Date__c;
                else
                    return LastCardEndDate == null ? dStartDate.addMonths(12) : LastCardEndDate;
            else
                return LastCardEndDate == null ? dStartDate.addMonths(12) : LastCardEndDate;
        }
    }

    //Retrieve the last valid id card for a given contact
    private static ID_Card__c LastIdCardForGivenContact(Contact con) {
        if (con == null)
            return null;
        else {
            //Search for Active card
            list<ID_Card__c> lsIdCard = [select Id, Valid_To_Date__c, Valid_From_Date__c
                                         from ID_Card__c where Related_Contact__c = :con.id and Is_Active_Card__c = :true
                                                 order by Valid_From_Date__c nulls last limit 1];

            //If not active card is found, than search for card NOT canceled and NOT blacklisted
            if (lsIdCard.isEmpty()) {
                lsIdCard = [select Id, Valid_To_Date__c, Valid_From_Date__c
                            from ID_Card__c where Related_Contact__c = :con.id and Blacklisted__c = :false and Card_Status__c<>:'Cancelled ID Card'
                                    order by Valid_From_Date__c nulls last limit 1];
            }

            if (lsIdCard.isEmpty())
                return null;
            else
                return lsIdCard[0];
        }
    }

    /*Calculate the start and end date for a new idCard using the following business logic
        - If card  = reissue
            If account doesn’t have a Corporated ID card validity date IN FUTURE
                End date = the same as previous ID card
            Else
                END DATE  = account  Corporated ID card validity date

        - If card = new / replacement:
            Start date = Last day of current month
            If account doesn’t have a Corporated ID card validity date IN FUTURE
                End date = (end of 12 months from start date )
            Else
                END DATE  = account  Corporated ID card validity date

        - If renew:
            If old card . End validity  in future:
                Start date = old card. End validity + 1 day (Comment please explain the reason for the +1 day)
            Else
                Start date = Last day of current month
            If account doesn t have a Corporate ID card validity date IN FUTURE
                End date = (end of 12 months from start date )
            Else
                END DATE  = account  Corporated ID card validity date
    */
    public static idCardStartEndDate getIdCardStartEndDate(Account accnt, ID_Card_Application__c objApp, Contact con) {
        idCardStartEndDate dateReturn = new idCardStartEndDate();
        string appType = objApp.Type_of_application__c;
        date dStartDate, dEndDate = null;
        date dToday = system.Today();
        date LastDayOfCurrentMonth = Date.newInstance(dToday.year(), dToday.month(), Date.daysInMonth(dToday.year(), dToday.month()));
        if (appType == 'New' || appType == 'Replacement') {
            dStartDate = dToday;//LastDayOfCurrentMonth - INC184819
            dEndDate = dateReturn.EndDateCheckAccnt(Accnt, dStartDate, dToday, null);
        }

        if (appType == 'Reissue') {
            ID_Card__c lastIdCard = LastIdCardForGivenContact(con);
            if (lastIdCard != null) {
                dStartDate = lastIdCard.Valid_From_Date__c;//.addDays(1) - INC184819
                dEndDate = dateReturn.EndDateCheckAccnt(Accnt, dStartDate, dToday, lastIdCard.Valid_To_Date__c);
            }
        }

        if (appType == 'Renewal') {
            if (con != null) {
                ID_Card__c lastIdCard = LastIdCardForGivenContact(con);
                if (lastIdCard != null) {
                    if (lastIdCard.Valid_To_Date__c > dToday)
                        dStartDate = lastIdCard.Valid_To_Date__c;//.addDays(1) - INC184819
                    else
                        dStartDate = dToday;//LastDayOfCurrentMonth - INC184819

                    dEndDate = dateReturn.EndDateCheckAccnt(Accnt, dStartDate, dToday, null);
                }
            }
        }

        dateReturn.EndDate = dEndDate;
        dateReturn.StartDate = dStartDate;

        return dateReturn;
    }

    /**
     * Returns the account object from an IATA code
     */
    public static Account GetAccountObjectFromIATACode(String iataCode) {

        System.debug(' *** Getting Account IATA Code' + iataCode);
        System.debug(' ** Query is:  Select IATACode__c, BillingCountry,type, Id From Account where RecordType.Name =: \'Agency\' AND IATACode__c =: ' + iataCode + '  AND  (Status__c =: ' + ACCOUNT_STATUS_LISTED + ' or Status__c =: ' + ACCOUNT_STATUS_APPROVED + ' or Status__c = :' + ACCOUNT_STATUS_CHANGES_PROCESSED + ' or Status__c = :' + ACCOUNT_STATUS_UNDER_REVIEW + ' )  limit 1 ');

        Account[] theAccounts = [SELECT IATACode__c, BillingCountry, type, Id 
                                 FROM Account
                                 WHERE RecordType.Name = : 'Agency' AND IATACode__c = : iataCode
                                    AND (Status__c in : IDCARDUtil.ALLOWED_ACCOUNT_STATUS or Status__c = 'Terminated') limit 1];

        System.debug(' *** Getting Account ' + theAccounts);
        if (theAccounts == null || theAccounts.size() == 0) {
            throw new IDCardApplicationException(String.Format(Label.ID_Card_Account_Not_Found, new String[] {'<i>' + iataCode + '</i>'}));
        } else {
            return theAccounts[0];
        }
    }

    /**
    * Returns the account object from an IATA code
    */
    public static List<Account> GetAccountListFromIATACodes(Set<String> iataCodes) {
        return  [Select IATACode__c, BillingCountry, type, Id From Account
                 where RecordType.Name = : 'Agency'
                                         AND IATACode__c in :iataCodes
                                         AND  (Status__c in : IDCARDUtil.ALLOWED_ACCOUNT_STATUS)
                ];
    }

    /**
    * Returns the country ISO code of a contact based on its IATA code
    */
    public static  Map<String, IATA_ISO_Country__c> GetIATAISOCountryFromAccounts(List<Account> account) {

        Map<String, IATA_ISO_Country__c> rmap = new Map<String, IATA_ISO_Country__c> ();
        Map<String, List<String>> bCountriesPerIATACode = new Map<String, List<String>>();
        for (Account acc : account) {
            List<String> l = bCountriesPerIATACode.get(acc.BillingCountry.tolowercase());
            if (bCountriesPerIATACode.get(acc.BillingCountry) == null)
                bCountriesPerIATACode.put(acc.BillingCountry.tolowercase(), new List<String>());
            bCountriesPerIATACode.get(acc.BillingCountry.tolowercase()).add(acc.IATACode__c);
        }

        IATA_ISO_Country__c[] listCountries = IATAIsoCountryDAO.getIsoCountriesByAIMSAreaName(bCountriesPerIATACode.keySet());
 
        for (IATA_ISO_Country__c ac : listCountries) {

            try {
                for (String aiatacode : bCountriesPerIATACode.get(ac.AIMS_Area_Name__c.tolowercase())) {
                    rmap.put(aiatacode, ac);
                }
            } catch (exception e) {
                system.debug('[ID CAQRD UTIL] failed to retrive list');
                throw e;
            }
        }

        return rmap;
    }

    public static Contact CreateContactWhenNewCardIsApproved(ID_Card_Application__c application) {

        String OldPhotoName = application.Photo__c;
        Account theAccount;
        try {
            Case a = [ Select Account.Id from Case where Related_ID_Card_Application__c = : application.Id limit 1];
            theAccount = [ Select IATACode__c, BillingCountry, type, Id From Account where Id = : a.Account.Id limit 1];
        }

        catch ( Exception e) {
            System.debug('**** Error doing workaround ' + e);
            theAccount = GetAccountObjectFromIATACode(application.IATA_Code__c);
        }

        system.debug('Before UIR and VER# Generation');
        // generate a new VER and UIR (for new application)
        IDCardUtil.generateAndAssignVERandUIR(application, theAccount);


        //@@@ TODO update instead of creation of contact in case it already exists

        SavePoint sp = database.setSavepoint();
        try {
            // get the contact object associate to the agent
            Contact theContact = new Contact();
            theContact.AccountId = theAccount.Id;
            theContact.LastName = application.Last_Name__c;
            theContact.IDCard_Email__c = application.Email_admin__c;
            theContact.Approving_Manager_s_Name__c = application.Approving_Manager_s_Name__c;
            theContact.Approving_Manager_s_Email__c = application.Approving_Manager_s_Email__c;
            theContact.ID_Card_Preferred_Language__c = application.IDCard_Prefered_Language__c;
            theContact.FirstName = application.First_Name__c;
            theContact.Salutation = application.Title__c;
            theContact.Date_of_Birth__c = application.Date_of_Birth__c;
            theContact.Gender__c = application.Gender__c;
            theContact.Middle_Initial__c = application.Middle_Initial__c;
            theContact.Phone = application.Telephone__c;
            theContact.Position__c = application.Position_in_Current_Agency__c;
            theContact.Duties__c = application.Duties_in_Current_Agency__c;
            theContact.Hours_per_week__c = application.Hours_worked__c;
            theContact.Start_Date_Industry__c = Decimal.valueOf(application.Start_Date_Industry__c);
            theContact.Start_Date_Agency_Month__c = application.Start_Date_Agency_Month__c;
            theContact.Start_Date_Agency_Year__c = Decimal.valueOf(application.Start_Date_Agency_Year__c);
            theContact.Solicitation_Flag__c = application.Solicitation_Flag__c;
            theContact.Revenue_Confirmation__c = application.Revenue_Confirmation__c;
            theContact.AgencyShare_Confirmation__c = application.AgencyShare_Confirmation__c;
            theContact.UIR__c = application.UIR__c;

            if (application.VER_Number__c != '' && application.VER_Number__c != null) {
                theContact.VER_Number_2__c = application.VER_Number__c;
            } else {
                theContact.VER_Number_2__c =  generateVER(theAccount);
                application.VER_Number__c = theContact.VER_Number_2__c;
            }
            theContact.RecordTypeID = IDCardContactRecordTypeID;

            insert theContact;
            update application;

            return theContact;
        } catch (Exception ex) {
            system.debug('Error: ' + ex);
            throw new IDCardApplicationException('Contact Creation failed.' + ex.getMessage());
            database.rollback(sp);
            renameIDCardPhotoOfContact(application.ID, OldPhotoName, Userinfo.getSessionId());  // rename photo to its old name
            return null;
        }
    }

    public static Case CreateIDCardApplicationCase(ID_Card_Application__c idCardApp, Account theAccount) {
        return  CreateIDCardApplicationCase(idCardApp, theAccount, false);
    }

    public static Case CreateIDCardApplicationCase(ID_Card_Application__c idCardApp, Account theAccount, Boolean isPaidByCheque) {
        return CreateIDCardApplicationCase(idCardApp, theAccount, isPaidByCheque, true);
    }

    public static Case createKeyAccountIdCardMassApplicationCase(ID_Card_Application__c idCardApp, Account theAccount, boolean mustInsertInDB) {

        // Create the case
        Case newCase = new Case();
        newCase.RecordTypeId =  RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ID_Card_Mass_Application');
        newCase.Subject = 'Case for ID Card Mass Application ' + idCardApp.Name;

        newCase.Status = 'In progress';
        newCase.OwnerId = System.Userinfo.getUserId();

        newCase.ID_Card_Status__c = CASECARDSTATUS_APPROVED;

        newCase.AccountId = theAccount.Id;
        newCase.Origin = 'ID Card Portal';
        newCase.Related_ID_Card_Application__c = idCardApp.Id;
        newCase.SuppliedEmail = idCardApp.Email_admin__c;
        newCase.CaseArea__c = 'Accreditation';
        newCase.Reason1__c  = 'ID Card';

        if (idCardApp.IDCard_Expedite_Delivery__c)
            newCase.Priority = 'Low';

        List<IATA_ISO_Country__c> isoCountry = IATAIsoCountryDAO.getIsoCountriesByAIMSAreaName(theAccount.BillingCountry);

        if (isoCountry[0].Case_BSP_Country__c != null && isoCountry[0].Case_BSP_Country__c != '')
            newCase.BSPCountry__c = isoCountry[0].Case_BSP_Country__c;
        if (isoCountry[0].Region__c != null && isoCountry[0].Region__c != '')
            newCase.Region__c = isoCountry[0].Region__c;

        // set contact
        if (idCardApp.VER_Number__c != null && idCardApp.VER_Number__c != '') {
            Contact associatedContact = GetAssociatedContact(idCardApp.VER_Number__c);
            newCase.ContactId = associatedContact.Id;
        }
        if (mustInsertInDB)
            insert newCase;

        return newCase;
    }

    public static Case createKeyAccountIdCardApplicationCase(ID_Card_Application__c idCardApp, Account theAccount) {

        // Create the case
        Case newCase = new Case();
        newCase.RecordTypeId = IDCardcaseRecordTypeID;
        newCase.Subject = 'Case for ID Card Application ' + idCardApp.Name;

        newCase.Status = 'In progress';
        newCase.OwnerId = System.Userinfo.getUserId();


        newCase.AccountId = theAccount.Id;
        newCase.Origin = 'ID Card Portal';
        newCase.Related_ID_Card_Application__c = idCardApp.Id;
        newCase.SuppliedEmail = idCardApp.Email_admin__c;
        newCase.ID_Card_Status__c = CASECARDSTATUS_PENDING;
        newCase.CaseArea__c = 'Accreditation';
        newCase.Reason1__c  = 'ID Card';

        if (idCardApp.IDCard_Expedite_Delivery__c)
            newCase.Priority = 'Low';

        List<IATA_ISO_Country__c> isoCountry = IATAIsoCountryDAO.getIsoCountriesByAIMSAreaName(theAccount.BillingCountry);

        if (isoCountry[0].Case_BSP_Country__c != null && isoCountry[0].Case_BSP_Country__c != '')
            newCase.BSPCountry__c = isoCountry[0].Case_BSP_Country__c;
        if (isoCountry[0].Region__c != null && isoCountry[0].Region__c != '')
            newCase.Region__c = isoCountry[0].Region__c;

        // set contact
        if (idCardApp.VER_Number__c != null && idCardApp.VER_Number__c != '') {
            Contact associatedContact = GetAssociatedContact(idCardApp.VER_Number__c);
            newCase.ContactId = associatedContact.Id;
        }

        insert newCase;

        return newCase;
    }

    public static Case CreateIDCardApplicationCase(ID_Card_Application__c idCardApp, Account theAccount, Boolean isPaidByCheque, Boolean SendEmail) {
        // Get recordtype ID


        // Create the case
        Case newCase = new Case();
        newCase.RecordTypeId = IDCardcaseRecordTypeID;
        newCase.Subject = 'Case for ID Card Application ' + idCardApp.Name;
        if (SendEmail)
            newCase.Status = 'Agent to be Notified';
        else
            newCase.Status = 'Open';



        // if one of the business rules failed at any time of the application creation, we need to identify in the case that the
        // card need additional validation before approval.
        // If no validation failed, we use the default value.
        if (idCardApp.Hours_Worked_Validation_Failed__c || idCardApp.Revenue_Confirmation_Validation_Failed__c) {
            // Set ID_Card_Status to "Pending ID Card Approval - Additional Validation"
            newCase.ID_Card_Status__c = CASECARDSTATUS_PENDING_ADD_VALIDATION;
        }

        newCase.AccountId = theAccount.Id;
        newCase.Origin = 'ID Card Portal';
        newCase.Related_ID_Card_Application__c = idCardApp.Id;
        newCase.SuppliedEmail = idCardApp.Email_admin__c;
        newCase.ID_Card_Status__c = CASECARDSTATUS_PENDING;
        newCase.CaseArea__c = 'Accreditation';
        newCase.Reason1__c  = 'ID Card';

        if (idCardApp.IDCard_Expedite_Delivery__c)
            newCase.Priority = 'High';

        // if(isPaidByCheque)
        //      newCase.ID_Card_Status__c = CASECARDSTATUS_PENDING_PAYMENT;


       List<IATA_ISO_Country__c> isoCountry = IATAIsoCountryDAO.getIsoCountriesByAIMSAreaName(theAccount.BillingCountry);

        if (isoCountry[0].Case_BSP_Country__c != null && isoCountry[0].Case_BSP_Country__c != '')
            newCase.BSPCountry__c = isoCountry[0].Case_BSP_Country__c;
        if (isoCountry[0].Region__c != null && isoCountry[0].Region__c != '')
            newCase.Region__c = isoCountry[0].Region__c;


        // set contact
        if (idCardApp.VER_Number__c != null && idCardApp.VER_Number__c != '') {
            Contact associatedContact = GetAssociatedContact(idCardApp.VER_Number__c);
            newCase.ContactId = associatedContact.Id;
        }


        //Fetching the assignment rules on case
        AssignmentRule AR = new AssignmentRule();
        AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];

        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.id;

        //Setting the DMLOption on Case instance
        newCase.setOptions(dmlOpts);

        insert newCase;
        return newCase;
    }

    /**

    */
    private static Contact GetAssociatedContact(string VER) {
        // check the VER number (if associated to a contact)
        //2014-08  updated for VER 2  (String) usage
        system.debug(LoggingLevel.ERROR, '[GetAssociatedContact] ver = ' + ver);
        Contact[] contacts = [Select c.VER_Number_2__c, c.Title, c.FirstName, c.Middle_Initial__c, c.LastName, c.UIR__c, c.Account.IATACode__c, c.Hours_per_week__c, c.Duties__c, c.Position__c, c.Solicitation_Flag__c, c.Revenue_Confirmation__c, c.AgencyShare_Confirmation__c  From Contact c where c.VER_Number_2__c = : VER and c.RecordTypeID = : IDCardContactRecordTypeID limit 1];
        if (contacts == null || contacts.size() == 0) {
            throw new IDCardApplicationException(string.format(Label.ID_Card_Contact_Not_found_for_VER, new string[] { VER }));
        }
        return contacts[0];
    }


    public static List<String> ParseXMLReturn(string xmlRet) {
        List<String> retList = new List<String>();
        if (xmlRet != '') {
            System.debug(xmlRet);

            Xmlstreamreader reader = new Xmlstreamreader(xmlRet);
            while (reader.hasNext()) {
                if (reader.getEventType() == Xmltag.START_ELEMENT) {
                    if ('Result' == reader.getLocalName() || 'Detail' == reader.getLocalName()) {
                        // Parce Status Node
                        retList.add(ParseNode(reader));
                    }
                }
                reader.next();
            }
            return retList;
        } else
            retList.add('FAIL');
        retList.add('Error');

        return retList;
    }

    public static String ParseNode(Xmlstreamreader reader) {
        while (reader.hasNext()) {
            if (reader.getEventType() == XmlTag.END_ELEMENT) {
                break;
            } else if (reader.getEventType() == XmlTag.CHARACTERS) {
                return reader.getText();
            }
            reader.next();
        }
        return '';
    }

    public static void deleteUnpaidIDCardApplication() {
        String jobId = System.schedule('IDCARD__CleanUP__RenwealReminder__Scheduler',
                                       IDCard_CleanUp_RenewalReminder_Scheduler.CRON_EXP,
                                       new IDCard_CleanUp_RenewalReminder_Scheduler());
    }

    public static ID_Card__c[] getRenewableIDCard (string contactID , Integer days ) {

        //integer renewableCardDays = integer.valueOf(Label.IDCard_IsRenewableCard_Days);
        Date renewableEndDate  = date.today().addDays(days);
        ID_Card__c[] idCard = [Select Id, Valid_To_Date__c From ID_Card__c c where c.Related_Contact__r.Id = :contactID AND c.Card_Status__c = : IDCardUtil.CARDSTATUS_VALID
                               AND c.Is_Active_Card__c = : true
                                       order by c.Valid_To_Date__c desc ];


        if (idCard.size() != 0) {
            if (0 <= date.today().daysBetween(idCard[0].Valid_To_Date__c) &&  date.today().daysBetween(idCard[0].Valid_To_Date__c) <=  days)
                return idCard;
            else
                return (new list<ID_Card__c>());
        } else
            return (new list<ID_Card__c>());

    }


    public static ID_Card__c[] getRenewableIDCard (string contactID) {

        return  getRenewableIDCard(contactID, Integer.valueOf(Label.IDCard_IsRenewableCard_Days));
    }

    //Removes accents from a string an replace it with the base character
    //Returns a string without any accents.  R.A

    public static String deAccent(String str) {
        if (str == '' || str == null)
            return str;

        str = str.replaceAll('[àáâãäåăâ]', 'a');
        str = str.replaceAll('æ', 'ae');
        str = str.replaceAll('[çč]', 'c');
        str = str.replaceAll('[èéêëě]', 'e');
        str = str.replaceAll('[ìíîï]', 'i');
        str = str.replaceAll('ñ', 'n');
        str = str.replaceAll('[òóôõöø]', 'o');
        str = str.replaceAll('œ', 'oe');
        str = str.replaceAll('šșş', 's');
        str = str.replaceAll('ţț', 't');
        str = str.replaceAll('[ùúûüů]', 'u');
        str = str.replaceAll('[ýÿ]', 'y');
        str = str.replaceAll('ž', 'z');

        str = str.replaceAll('[ÀÁÂÃÄÅĂÂ]', 'A');
        str = str.replaceAll('Æ', 'AE');
        str = str.replaceAll('[ÇČ]', 'C');
        str = str.replaceAll('[ÈÉÊËĚ]', 'E');
        str = str.replaceAll('[ÌÍÎÏ]', 'I');
        str = str.replaceAll('Ñ', 'N');
        str = str.replaceAll('[ÒÓÔÕÖØ]', 'O');
        str = str.replaceAll('Œ', 'OE');
        str = str.replaceAll('ŠȘŞ', 'S');
        str = str.replaceAll('ŢȚ', 'T');
        str = str.replaceAll('[ÙÚÛÜŮ]', 'U');
        str = str.replaceAll('[ÝŸ]', 'Y');
        str = str.replaceAll('Ž', 'Z');


        str = str.replaceAll('-', ' ');
        str = str.replaceAll('\'', ' ');

        return str;

    }


    @RemoteAction
    webService static Boolean ConfirmChequePayment ( String cNum) {
        System.debug('*** Case Number received = ' + cNum);
        //change case status
        // update IDcard to paid
        try {
            Case[] c = [Select c.ID_Card_Status__c , c.Related_ID_Card_Application__c, c.OwnerId From Case c where c.CaseNumber = :cNum and c.RecordTypeId = : IDCardcaseRecordTypeID  limit 1];
            System.debug('*** Case Number cases = ' + c);
            if (c.size() > 0 ) {

                User[] currentUser = [Select ManagerId from User u where u.Id = : UserInfo.getUserId()];

                if (!Test.isRunningTest()) {
                    if (currentUser[0].ManagerId != null) {
                        c[0].ownerId = currentUser[0].ManagerId;
                    } else {
                        throw new IDCardApplicationException('Current user do not have manager.');
                    }
                }
                c[0].ID_Card_Status__c = CASECARDSTATUS_PENDING_MNG_APPROVAL;
                c[0].Status = CASESTATUS_INPROGRESS;
                Update c[0];
                // No longer valid. IDCard is created after the approve status
                /*
                ID_Card__c[] idcard = [Select i.Paid__c From ID_Card__c i where i.ID_Card_Application__r.Id = :c[0].Related_ID_Card_Application__c];
                idcard[0].Paid__c ='Y';
                Update idcard[0];
                */

                // Create an approval request for the Opportunity
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments('Submitting ID Card Application for approval automatically');
                req1.setObjectId(c[0].id);
                //req1.setNextApproverIds(new Id[] {currentUser[0].ManagerId});

                // Submit the approval request for the Opportunity
                Approval.ProcessResult result = Approval.process(req1);

                return true;
            }
            return false;
        } catch (Exception e) {
            System.debug('** Error ' + e.getMessage());
            return false;
        }
    }



    @RemoteAction
    webService static String UpdateCaseToApproved_Rejected (String cNum, Boolean isApproved) {
        System.debug(LoggingLevel.ERROR, '[UpdateCaseToApproved_Rejected]:  Case Number received = ' + cNum);

        SavePoint sp = database.setSavepoint();
        String VER;
        try {


            Case[] c = [ Select c.ContactId , c.ID_Card_Status__c, c.OwnerId, c.Related_ID_Card_Application__c, c.ID From Case c where c.CaseNumber = :cNum and c.RecordTypeId = : IDCardcaseRecordTypeID  limit 1];
            System.debug(LoggingLevel.ERROR, '[UpdateCaseToApproved_Rejected]  Size of the case ' + c.size());

            if (c.size() > 0 ) {
                if (isApproved) {
                    //Modifications Done;
                    // Case: change IDcardSatus to Approved ; Status to InProgress ; sets Contact ID
                    // Card: Create Approved Card
                    // Contact: update fields and Account.

                    c[0].ID_Card_Status__c = CASECARDSTATUS_APPROVED;
                    //c[0].Status = CASESTATUS_INPROGRESS;
                    c[0].Status = CASESTATUS_READYFORPRODUCTION;

                    //To Check if we can do this Status change now.
                    Update c[0];
                    System.debug(LoggingLevel.ERROR, '[UpdateCaseToApproved_Rejected]  Case saved with status ' + c[0].status );

                    //get IDCard and Application

                    ID_Card_Application__c application = [Select VER_Number__c, UIR__c, Type_of_application__c, Title__c, Terms_and_Conditions_Time_Stamp__c, Telephone__c, SystemModstamp, Start_Date_Industry__c, Start_Date_Agency_Year__c, Start_Date_Agency_Month__c, Solicitation_Flag__c, Selected_Preferred_Language__c, Revenue_Confirmation__c, Revenue_Confirmation_Validation_Failed__c, Renewal_From_Replace__c, Regional_Office__c, Promotion_Code__c, Profit_Center__c, Position_in_Current_Agency__c, Position_Code__c, Photo__c, Payment_Type__c, Payment_Transaction_Number__c, Payment_Date__c, Payment_Currency__c, Payment_Credit_Card_Number__c, Payment_Amount__c, Package_of_Travel_Professionals_Course_2__c, Package_of_Travel_Professionals_Course_1__c, OwnerId, Name, Middle_Initial__c, Last_Name__c, LastModifiedDate, LastModifiedById, LastActivityDate, IsDeleted, Id, ITDI_Courses_Fee__c, ID_Card_Fee__c, IDCard_Prefered_Language__c, IDCard_Expedite_Delivery__c, IDCard_Expedite_Delivery_Fee__c, IATA_numeric_code_previous_employer_4__c, IATA_numeric_code_previous_employer_3__c, IATA_numeric_code_previous_employer_2__c, IATA_numeric_code_previous_employer_1__c, IATA_Code_for_previous_agency__c, IATA_Code__c, Hours_worked__c, Hours_Worked_Validation_Failed__c, Hours_Worked_Code__c, Gender__c, First_Name__c, Email_admin__c, Duties_in_Current_Agency__c, Duties_Code__c, Displayed_Name__c, Date_of_Birth__c, CurrencyIsoCode, CreatedDate, CreatedById, ConnectionSentId, ConnectionReceivedId, Case_Number__c, Approving_Manager_s_Name__c, Approving_Manager_s_Email__c, Applicable_Fee__c, AgencyShare_Confirmation__c From ID_Card_Application__c WHERE ID = : c[0].Related_ID_Card_Application__c limit 1];

                    ID_Card__c[] existingIdCard = [Select Valid_To_Date__c, Valid_From_Date__c, Type_of_ID_Card__c, Related_Contact__c, Name_on_ID_Card__c, IsDeleted, Id, ID_Card_Application__c, Card_Status__c, Card_Code__c, Agency_IATA_Code__c From ID_Card__c WHERE ID_Card_Application__c = : application.ID limit 1];

                    System.debug(LoggingLevel.ERROR, '[UpdateCaseToApproved_Rejected]  Case Approved. Found ' + existingIdCard.size() + ' idcards');

                    //track manual case creation if VER is missing
                    VER =  application.VER_Number__c;

                    // To Avoid Creating Card/Contact more than once
                    if (existingIdCard.size() == 0) {
                        ID_Card__c idCardNew = new ID_Card__c();

                        //throw new TransformationException('APP VER = '+application.VER_Number__c);
                        //**Create Contact only for new application
                        if (application.Type_of_application__c == IDCardUtil.APPLICATIONTYPE_NEW && c[0].ContactId == null)
                            c[0].ContactId = IDCardUtil.CreateContactWhenNewCardIsApproved(application).ID;

                        Contact[] contacts = [Select c.Allow_Contact_LastName_Change__c, c.AgencyShare_Confirmation__c, c.ID_Card_Preferred_Language__c, c.VER_Number__c, c.Title, c.FirstName, c.Middle_Initial__c, c.LastName, c.UIR__c, c.Account.IATACode__c, c.Hours_per_week__c, c.Duties__c, c.Position__c, c.Solicitation_Flag__c, c.Revenue_Confirmation__c  From Contact c where c.VER_Number__c = : Decimal.valueof(application.VER_Number__c)  and Id = : c[0].ContactId  limit 1];
                        System.debug(LoggingLevel.ERROR, '[UpdateCaseToApproved_Rejected]  calling the method for id card creation');

                        idCardNew = IDCardUtil.CreateIDCardObjectFromApplication(application, contacts[0]);
                        insert idCardNew;
                    }

                    //@@ and c.RecordTypeID =: IDCardContactRecordTypeID
                    Contact theContact = [Select  c.Allow_Contact_LastName_Change__c, c.Id, c.AgencyShare_Confirmation__c, c.ID_Card_Preferred_Language__c, c.VER_Number__c, c.Title, c.FirstName, c.Middle_Initial__c, c.LastName, c.UIR__c, c.Account.IATACode__c, c.Hours_per_week__c, c.Duties__c, c.Position__c, c.Solicitation_Flag__c, c.Revenue_Confirmation__c  From Contact c where c.VER_Number__c = : Decimal.valueof(application.VER_Number__c) limit 1];

                    //Update Contact Info
                    theContact.LastName = application.Last_Name__c;
                    theContact.ID_Card_Preferred_Language__c = application.IDCard_Prefered_Language__c;
                    theContact.Phone = application.Telephone__c;
                    //theContact.Email = application.Email_admin__c;
                    theContact.IDCard_Email__c = application.Email_admin__c;
                    theContact.Position__c = application.Position_in_Current_Agency__c;
                    theContact.Duties__c = application.Duties_in_Current_Agency__c;
                    theContact.Hours_per_week__c = application.Hours_worked__c;
                    theContact.Solicitation_Flag__c = application.Solicitation_Flag__c;
                    theContact.Revenue_Confirmation__c = application.Revenue_Confirmation__c;
                    theContact.AgencyShare_Confirmation__c = application.AgencyShare_Confirmation__c;


                    //remove for clone

                    if (application.Type_of_application__c == IDCardUtil.APPLICATIONTYPE_REPLACEMENT) {
                        Account theAccount = GetAccountObjectFromIATACode(application.IATA_Code__c);
                        theContact.AccountId = theAccount.Id;
                    }

                    // Change the status of the old card to "Cancelled" (only on reissue => Lost/stolen) and change of agency
                    if (application.Type_of_application__c == IDCardUtil.APPLICATIONTYPE_REISSUE || application.Type_of_application__c == IDCardUtil.APPLICATIONTYPE_REPLACEMENT) {
                        //find old card to cancel it
                        ID_Card__c[] idCards = [Select Card_Status__c, MustSyncWithAIMS__c, Valid_To_Date__c From ID_Card__c where Related_Contact__c = :theContact.Id AND Card_Status__c = : CARDSTATUS_VALID order by CreatedDate desc];
                        if (idCards != null && idCards.size() > 0) {
                            idCards[0].Card_Status__c = IDCardUtil.CARDSTATUS_CANCELED;
                            idCards[0].Cancellation_Date__c = Date.Today();
                            //fidCards[0].MustSyncWithAIMS__c = true;
                            update idcards[0];
                        }
                    }

                    //update contact after cancelling existing card to avoid validation rule on active cards in case of name change.
                    theContact.Allow_Contact_LastName_Change__c = true;
                    update theContact;


                    // call the cropping tool web service to rename the photo filename (from a GUID to the UIR)
                    if (!application.Photo__c.startswith(application.UIR__c))
                        IDCardUtil.renameIDCardPhotoOfContact(application.ID, '', UserInfo.getSessionId());

                }

                else {
                    c[0].ID_Card_Status__c = CASECARDSTATUS_REJECTED;
                    c[0].Status = 'Closed';



                    //in case idcard is already created ex: mistake  approved then rejected
                    // delete created IDCard
                    ID_Card__c[] idCards = [Select Id, Nature_of_ID_Card__c, Sent_to_AIMS_on__c From ID_Card__c where ID_Card_Application__c = : c[0].Related_ID_Card_Application__c limit 1];

                    // for new application if its rejected after approved the created contact should be deleted
                    if (idCards.size() > 0) {
                        if (idCards[0].Nature_of_ID_Card__c  == 'New') {
                            Id contID = c[0].ContactId;
                            c[0].ContactId = null;

                            update c[0];

                            // Contact cont = [Select id From Contact where Id= : contID limit 1];

                            //delete cont;
                        }
                        if (idCards[0].Sent_to_AIMS_on__c == null)
                            delete idCards;
                    }
                    update c[0];
                    return 'true';

                }
                Update c[0];
                System.debug(LoggingLevel.ERROR, '[UpdateCaseToApproved_Rejected]  Case ' + c[0].id + 'saved for the second time with status ' + c[0].status );

                return 'true';
            }
            return 'false';
        } catch (Exception e) {

            System.debug(LoggingLevel.ERROR, '[UpdateCaseToApproved_Rejected] ################ ERROR : ' + e.getStackTraceString());



            database.rollback(sp);
            string msg =  e.getMessage().length() > 600 ? e.getMessage().Substring(0, 600) : e.getMessage();
            if (msg.contains('DupeBlocker')) {
                msg = 'Creation of new Contact with an existing email address is not allowed by the DupeBlocker Tool. To approve this case please modify the email address so it doesnt conflict with the existing Contact email address.';
                return msg;
            }
            return 'Error occured ' + msg + e.getStackTraceString();
        }

    }





    @RemoteAction
    WebService static String getIDCardApplication(String caseNumberParam) {
        System.debug('*** Case Number received = ' + caseNumberParam);
        List<Case> c = [select Related_ID_Card_Application__c from Case c where  c.CaseNumber = : caseNumberParam and c.RecordTypeId = : IDCardcaseRecordTypeID  limit 1];

        if (!c.isEmpty() && c.size() > 0) {
            return String.valueOf( new PageReference('/' + c[0].Related_ID_Card_Application__c).getUrl());
        }
        return '';
    }

    @RemoteAction
    WebService static String getIDCardApplicationCase(String IDCardApplicationID) {
        List<Case> c = [select CaseNumber  from Case  where  Related_ID_Card_Application__c = : IDCardApplicationID and RecordTypeId = : IDCardcaseRecordTypeID  limit 1];

        if (!c.isEmpty() && c.size() > 0) {
            return String.valueOf(c[0].CaseNumber);
        }
        return '';
    }

    @RemoteAction
    WebService static String setPendingAdditionalInfo(String applicationIdParam) {
        List<Case> c = [select id, ID_Card_Status__c from Case c where  c.Related_ID_Card_Application__c = : applicationIdParam and c.RecordTypeId = : IDCardcaseRecordTypeID  limit 1];

        if (!c.isEmpty() && c.size() > 0) {
            c[0].Status = IDCardUtil.CASESTATUS_PENDING_AGENT_FEEDBACK;
            update c[0];
            return c[0].id;
        }
        return '';
    }



    // Creates a new IDCard Application and a Case for Manual creation using a button on IDCard Object
    @RemoteAction
    WebService static String CreateIDCardApplicationAndCase(String typeofApplication, ID IDCardID) {

        SavePoint sp = database.setSavepoint();

        try {

            ID_Card__c idcardObject = [ Select Related_Contact__r.UIR__c, Id, CurrencyIsoCode, Related_Contact__c, Name_on_ID_Card__c, Card_Status__c, Photo_Flag__c,  Nature_of_ID_Card__c, Type_of_ID_Card__c, Agency_Name__c, Payment_Type__c, Agency_IATA_Code__c, Fee_Applicable__c, Card_Variation_Code__c, ID_Card_Application__c, Photo__c, MustSyncWithAIMS__c, Card_Variation__c, Card_Code__c, Renewal_From_Replace__c, Is_Active_Card__c, LastName__c, FirstName__c, Middle_Initial__c, Title__c, Phone__c, Duty_Code__c, Email__c, Gender__c, Position__c, Duties__c, Hours_per_week__c, Start_Date_Industry__c, Start_Date_Agency_Year__c, Start_Date_Agency_Month__c, Approving_Manager_s_Name__c, Approving_Manager_s_Email__c, VER_Number__c, Date_of_Birth__c, Position_Code__c, Is_Expedite__c, Profit_Center__c, Received_From_AIMS__c FROM ID_Card__c where id = : IDCardID Limit 1];

            ID_Card_Application__c newIDCardApplication = new ID_Card_Application__c();

            ID idcaRT = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Standard') ;

            newIDCardApplication.RecordTypeId = idcaRT;
            newIDCardApplication.Title__c = idcardObject.Title__c;
            newIDCardApplication.Displayed_Name__c = idcardObject.Name_on_ID_Card__c;
            newIDCardApplication.VER_Number__c = idcardObject.VER_Number__c;
            newIDCardApplication.Type_of_application__c  = idcardObject.Nature_of_ID_Card__c;
            newIDCardApplication.First_Name__c = idcardObject.FirstName__c;
            newIDCardApplication.Middle_Initial__c = idcardObject.Middle_Initial__c ;
            newIDCardApplication.Last_Name__c = idcardObject.LastName__c;
            newIDCardApplication.Date_of_Birth__c = idcardObject.Date_of_Birth__c;
            newIDCardApplication.Gender__c = idcardObject.Gender__c ;
            newIDCardApplication.Telephone__c = idcardObject.Phone__c;

            newIDCardApplication.Start_Date_Agency_Year__c = idcardObject.Start_Date_Agency_Year__c;
            newIDCardApplication.Start_Date_Agency_Month__c = idcardObject.Start_Date_Agency_Month__c;
            newIDCardApplication.Start_Date_Industry__c = idcardObject.Start_Date_Industry__c;
            newIDCardApplication.Approving_Manager_s_Email__c = idcardObject.Approving_Manager_s_Email__c;
            newIDCardApplication.Approving_Manager_s_Name__c = idcardObject.Approving_Manager_s_Name__c;
            newIDCardApplication.Position_in_Current_Agency__c = idcardObject.Position__c;
            newIDCardApplication.Duties_in_Current_Agency__c = idcardObject.Duties__c;
            newIDCardApplication.Hours_worked__c = idcardObject.Hours_per_week__c;
            newIDCardApplication.Photo__c = idcardObject.Photo__c ;
            newIDCardApplication.Email_admin__c = idcardObject.Email__c;


            newIDCardApplication.Payment_Type__c = PAYMENT_TYPE_FOC;
            newIDCardApplication.ID_Card_Fee__c = Decimal.valueof('0');

            //get account
            newIDCardApplication.IATA_Code__c =  idcardObject.Agency_IATA_Code__c;
            Account theAccount = GetAccountObjectFromIATACode(idcardObject.Agency_IATA_Code__c);
            newIDCardApplication.UIR__c = idcardObject.Related_Contact__r.UIR__c;

            //TODO ?Case_Number__c ??


            if (typeofApplication == 'Renew')
                newIDCardApplication.Type_of_application__c = APPLICATIONTYPE_RENEWAL;
            if (typeofApplication == 'Replace')
                newIDCardApplication.Type_of_application__c = APPLICATIONTYPE_REPLACEMENT;
            if (typeofApplication == 'Reissue')
                newIDCardApplication.Type_of_application__c = APPLICATIONTYPE_REISSUE;


            Insert newIDCardApplication;

            //to get name of IDCArd
            newIDCardApplication = [ Select Id, Name, Hours_Worked_Validation_Failed__c, Revenue_Confirmation_Validation_Failed__c, Email_admin__c, IDCard_Expedite_Delivery__c, VER_Number__c from ID_Card_Application__c where id = :newIDCardApplication.Id limit 1];

            //create case without sending an email.
            CreateIDCardApplicationCase(newIDCardApplication , theAccount, false, false);


            return newIDCardApplication.Id;
        }

        catch (Exception e) {

            database.rollback(sp);
            return 'Error : ' + e.getMessage();
        }

    }

    public static String formatNumbersWithSeparators(Decimal val,  String tSep) {
        String s, tmp;
        integer dec = 0;
        String dSep = '.';
        Integer i = 4 + dec;

        // If the number of decimals is zero (0)... prevents the first 1000s seperator from being set at the 4th.
        if (dec == 0) {
            i--;
        }

        s = val.setScale(dec).toPlainString().replace(tSep, dSep);
        while (s.length() > i) {
            tmp = s.substring(0, s.length() - i) + tSep + s.substring(s.length() - i);
            s = tmp;
            i += 4;
        }

        // If the number is negative and has a number non-decimal digits divisible by 3, it prevents putting a comma before the 1st digit (ex -300,000.00  comes out -,300,000.00)
        if (s.substring(0, 1) == '-') {
            if (s.substring(1, 2) == tSep) {
                s = '-' + s.substring(2);
            }
        }

        return s;
    }


    public static String calculateDisplayedName (String firstName, String middleInitial, String lastName) {
        String displayedName;
        if (firstName == null)
            firstName = '';
        if (lastName == null)
            lastName = '';
        if (middleInitial == null)
            middleInitial = '';

        integer firstNameLength = firstName.length();
        integer middleInitialLength = middleInitial.length();
        integer lastNameLength = lastName.length();

        firstName = (firstName + ' ' + middleInitial.toUpperCase()).trim();
        lastName = lastName.trim();
        if ((firstName.length() + lastName.length()) != 0) {
            if (lastName.length() > 22)
                return IDCardUtil.deAccent(lastName.substring(0, 22));
            else {
                // +  => (' ')
                if ((lastName.length() + 1 + firstName.length()) <= 22) {
                    if (lastName.length() != 0)
                        return IDCardUtil.deAccent(firstName + ' '  + lastName);
                    else
                        return IDCardUtil.deAccent(firstName);
                } else {
                    //+ 3 => (' ') + firstName first character + ('.')
                    if ((lastName.length() + 3) <= 22)
                        return IDCardUtil.deAccent(firstName.substring(0, 1) + '. ' + lastName);
                    else
                        return IDCardUtil.deAccent(lastName);
                }
            }
        }
        return '';
    }

    public static string GetMonthStringValue(integer aMonth) {
        if (aMonth == 1)    return 'January';
        if (aMonth == 2)    return 'February';
        if (aMonth == 3)    return 'March';
        if (aMonth == 4)    return 'April';
        if (aMonth == 5)    return 'May';
        if (aMonth == 6)    return 'June';
        if (aMonth == 8)    return 'July';
        if (aMonth == 8)    return 'August';
        if (aMonth == 9)    return 'September';
        if (aMonth == 10)    return 'October';
        if (aMonth == 11)    return 'November';
        if (aMonth == 12)    return 'December';
        else return 'ERROR';
    }

    public static String AWSImageAuthorizationLink (String strPhotoName) {
        String authorizationLink;

        if (strPhotoName != null && strPhotoName != '') {
            AmazonCredentials credential = AmazonCredentials.getCredentials(CREDENTIAL_NAME);

            Long timestamp = System.now().getTime() / 1000 + 300;
            String filename = '/' + credential.Bucket + '/' + FOLDER_NAME + '/' + strPhotoName;

            String canonical = 'GET\n\n\n' + timestamp + '\n' + filename;
            Blob bsig = Crypto.generateMac('HmacSHA1', Blob.valueOf(canonical), Blob.valueOf(credential.Secret));
            String signature = EncodingUtil.base64Encode(bsig);

            authorizationLink = credential.EndpointBaseURL + filename.removeStart('/') + '?AWSAccessKeyId=' + credential.AWSAccessKeyId + '&Expires=' + timestamp + '&Signature=' + EncodingUtil.urlEncode(signature, 'UTF-8');
        } else {
            return null;
        }

        return authorizationLink;
    }

    //INC291433
    @RemoteAction
    WebService static String setTobeapproved(String applicationIdParam) {
        List<Case> c = [select id, ID_Card_Status__c from Case c where  c.Related_ID_Card_Application__c = : applicationIdParam and c.RecordTypeId = : IDCardcaseRecordTypeID  limit 1];

        if (!c.isEmpty() && c.size() > 0) {
            c[0].Status = IDCardUtil.CASESTATUS_PENDING_TO_BE_APPROVED;
            update c[0];
            return c[0].id;
        }
        return '';
    }


}