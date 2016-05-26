public without sharing class AMS_Utils {

    public static Set<Id> AMSPROFILES {
        get {
            Set<Id> toReturn = new Set<Id>();

            List<Profile> profiles = [select ID from profile where Name IN ('FDS Hub Analyst ARM', 'FDS – Agency Management - Supervisor (Approver)', 'IDFS Americas - Hub CS Management', 'IDFS Americas - Hub Staff')];

            for (Profile p : profiles)
                toReturn.add(p.Id);

            return toReturn;
        }
    }

    public static Map<String, IATA_ISO_State__c> iataIsoStates{
        get{
            if(iataIsoStates == null){
                iataIsoStates = new Map<String, IATA_ISO_State__c>();
                for(IATA_ISO_State__c state : [SELECT Id, Name, ISO_Code__c FROM IATA_ISO_State__c]){
                    iataIsoStates.put(state.Name, state);
                }
                System.debug(loggingLevel.Debug, '____ [cls AMS_Utils - iataIsoStates] iataIsoStates - ' + iataIsoStates);
            }

            return iataIsoStates;
        }
        set;
    }

    public static Map<String, IATA_ISO_Country__c> iataIsoCountries{
        get{
            if(iataIsoCountries == null){
                iataIsoCountries = new Map<String, IATA_ISO_Country__c>();
                for(IATA_ISO_Country__c country : [SELECT Id, Name FROM IATA_ISO_Country__c]){
                    iataIsoCountries.put(country.Name, country);
                }
                System.debug(loggingLevel.Debug, '____ [cls AMS_Utils - iataIsoCountries] iataIsoCountries - ' + iataIsoCountries);
            }

            return iataIsoCountries;
        }
        set;
    }

    private static Map<String, RecordType> currentCache = null;

    public static String userSessionId = UserInfo.getSessionId();

    public static final String SANITYCHECK = 'Perform Sanity Check';
    public static final String APPROVAL = 'Manager Approval';
    public static final String WITHDRAWAL = 'Application Withdrawal';

    public static final String PASSED = 'Passed';
    public static final String AUTH_APPROVAL = 'Authorize Approval';

    public static final String LOCATION_TYPE = 'Location type';
    public static final String OWNERSHIP_IATA = 'Ownership to IATA Agent';
    public static final String OWNERSHIP_NON_IATA = 'Ownership to non-IATA Agent';

    public static final String OSCAR_CLOSED = 'Closed (Closed)';

    public static final String BR = 'BR';
    public static final String HO = 'HO';


    public static final String ACC_S0_TERMINATED = 'Terminated';
    public static final String ACC_S1_NOTACCREDITED = 'Not accreditated';
    public static final String ACC_S2_NEWAPPLICATIONPENDING = 'New application pending';
    public static final String ACC_S3_NOTINOPERATION = 'Not in operation';
    public static final String ACC_S4_LISTED = 'Listed';
    public static final String ACC_S5_CASHNOCOMMISSION = 'Cash basis/no commission';
    public static final String ACC_S6_CASHWITHCOMMISSION = 'Cash basis/with commission';
    public static final String ACC_S7_UNDERREVIEW = 'Under review';
    public static final String ACC_S8_CHANGESPROCESSED = 'Changes processed';
    public static final String ACC_S9_APPROVED = 'Approved';

    public static final Id AccreditationContactPersonRT = Schema.SObjectType.AMS_Accreditation_Contact__c.getRecordTypeInfosByName().get('Person').getRecordTypeId();
    public static final Id AccreditationContactCompanyRT = Schema.SObjectType.AMS_Accreditation_Contact__c.getRecordTypeInfosByName().get('Company').getRecordTypeId();

    public static final Set<String> LocationClassIFAPAllowed = new Set<String>{'P','C','R'};

    static {
        refreshCache();
    }

    public static String ENCRYPTION_KEY {
        get {
            return Test.isRunningTest() ? 'hasd==aSDFclDDGasjdhfclx' : AMS_SAP_Settings__c.getOrgDefaults().Encryption_Key__c;
        }
    }

    public static String ENCRYPTION_ALGORYTHM {
        get {
            return Test.isRunningTest() ? 'AES128' : AMS_SAP_Settings__c.getOrgDefaults().Encryption_Algorythm__c;
        }
    }

    public AMS_Utils() {}
    //private static final String ENCRYPTION_ALGORYTHM = 'AES128';

    @future
    public static void sendEmailAmsSupport( string subject, string message) {

        if (Test.isRunningTest() ) {
            System.debug('AMS_ApplicationException.SendEmailSupport skipped because this is a Test. Subject: ' + subject + ', message: ' + message);
            return;
        }

        //List<ID> userIDs = getUserIds(getSupportEmails());
        List<ID> userIDs = new List<ID>();
        userIDs.add('0057E000000HpGoQAK');


        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

        try {
            system.debug('Try to send message . ' + subject + ' ******  ' + message);



            for (ID userId : userIDs) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                //mail.setTargetObjectId(userId);
                //String[] toAddresses = new String[] {'mouzinhof@iata.org'};
                String[] toAddresses = new String[] {'fernando.mouzinho@gmail.com'};
                mail.setToAddresses(toAddresses);
                mail.setSenderDisplayName('Apex error message');
                mail.setSubject(subject);
                mail.setSaveAsActivity(false);
                mail.setPlainTextBody(message);
                emailsToSend.add(mail);

            }

            Messaging.sendEmail(emailsToSend);

        } catch (Exception  e1) {
            system.debug('Failed to send email to users:' + e1.getMessage());
            system.debug('Failed to send email to users:' + e1.getStackTraceString());
        }

    }

    /**
     * Encrypts a string to be used as a GET parameter
     * @param sValue The string parameter to encrypt
     * @return The Encrypted parameter
     */
    public static String EncryptParameter(String sValue) {
        if (sValue == null || sValue == '')
            throw new AMS_ApplicationException('Value parameter is null or empty');
        return EncryptString(ENCRYPTION_KEY, sValue);
    }

    /**
     * Encrypts and URL encode a string to be used as a GET parameter
     * @param sValue The string parameter to encrypt and encode
     * @return The Encrypted/encoded parameter
     */
    public static String EncryptEncodeParameter(String sValue) {
        if (sValue == null || sValue == '')
            throw new AMS_ApplicationException('Value parameter is null or empty');
        return EncodingUtil.urlEncode(EncryptString(ENCRYPTION_KEY, sValue), 'UTF-8');
    }

    /**
     * Decrypts a string
     * @param sValue The string parameter to decrypt
     * @return The decrypted parameter
     */
    public static String DecryptParameter(String sValue) {
        if (Test.isRunningTest()) {sValue = sValue == '' ? 'X9Ecl9XVLvZQH6g5RP6PmjNOzNIOUsfLYtxbGkfxlfE=' : sValue;} //=test_password

        if (sValue == null || sValue == '')
            throw new AMS_ApplicationException('Nothing to decrypt');

        try {
            return DecryptString(ENCRYPTION_KEY, sValue);
        } catch (Exception ex) {
            throw new AMS_ApplicationException('Invalid parameter. Error: ' + ex.getMessage() + ' Stacktrace: ' + ex.getStackTraceString());
        }
    }

    /**
     * URL decode and decrypts a string
     * @param sValue The string parameter to decrypt/decode
     * @return The decrypted/decoded parameter
     */
    public static String DecodeDecryptParameter(String sValue) {
        if (Test.isRunningTest()) {sValue = sValue == '' ? 'X9Ecl9XVLvZQH6g5RP6PmjNOzNIOUsfLYtxbGkfxlfE=' : sValue;}

        if (sValue == null || sValue == '')
            throw new AMS_ApplicationException('Nothing to decrypt');

        try {
            return DecryptString(ENCRYPTION_KEY, Encodingutil.urlDecode(sValue, 'UTF-8'));
        } catch (Exception ex) {
            throw new AMS_ApplicationException('Invalid parameter. Error: ' + ex.getMessage());
        }
    }

    //public static Integer createEmployeePersonFromAccountContact(String agencyId){ #AMSFTS SE FOR NECESSARIO USAR A VF PAGE DOS CONTACTOS DA CONSOLA ESTE METODO TEM DE MUDAR PARA A ACCOUNT ROLE
    public static Integer createEmployeePersonFromAccountContact(String accountId) {
        Integer result = 0;
        /*List<AMS_Employee__c> newEmployees = new List<AMS_Employee__c>();
        Map<String,AMS_Person__c> mapContactPerson= new Map<String,AMS_Person__c>();

        //Map<String,Contact> contactsAccount = new Map<String,Contact>([select id, Person__c, Name, FirstName, LastName, Phone, MobilePhone, Birthdate, Email from Contact where AccountId IN (select Account__c from AMS_Agency__c where id =:agencyId) and Person__c = null]);#AMSFTS
        Map<String,Contact> contactsAccount = new Map<String,Contact>([select id, Person__c, Name, FirstName, LastName, Phone, MobilePhone, Birthdate, Email from Contact where AccountId = :accountId and Person__c = null]);
        if(contactsAccount.size() > 0){
            for(Contact c:contactsAccount.values()){
                AMS_Person__c p = new AMS_Person__c(Name=c.Name,First_Name__c=c.FirstName,Lastname__c=c.LastName,Phone__c=c.Phone,Mobile__c=c.MobilePhone,DOB__c=c.Birthdate,Email__c=c.Email, Contact__c=c.id);
                mapContactPerson.put(c.id,p);
            }
        }

        try{
            if(mapContactPerson.size() > 0){
                insert mapContactPerson.values();
                result += mapContactPerson.size();
            }
        }catch(DMLException e){
            system.debug('***************************** Failed to insert Persons ' + e.getMessage());
            return result;
        }

        for(String c:mapContactPerson.keySet()){
            //AMS_Employee__c e = new AMS_Employee__c(Name=mapContactPerson.get(c).Name,Agency__c=agencyid,Person__c=mapContactPerson.get(c).id,Contact__c=c);#AMSFTS
            AMS_Employee__c e = new AMS_Employee__c(Name=mapContactPerson.get(c).Name,Account__c=accountId,Person__c=mapContactPerson.get(c).id,Contact__c=c);
            newEmployees.add(e);
            contactsAccount.get(c).Person__c = mapContactPerson.get(c).id;
        }

        try{
            if(newEmployees.size() > 0){
                insert newEmployees;
                update contactsAccount.values();
                result += newEmployees.size();
            }
        }catch(DMLException e){
            system.debug('Failed to insert Employees ' + e.getMessage());
            return result;
        }
        */
        return result;
    }


    /**
    //Based on the Change code passed we get the Rec ID
    Indicates if record is A=Added, C=Changed or D=Deleted.
    */
    public static String getRecIdFromChangeCode(String sChangeCode) {

        String sRes = '';

        //Validates the Changes codes for "A=Added" and "D=Deleted", all other Change Codes not mentioned return "C=Changed"
        if (sChangeCode.equalsIgnoreCase('NEW')) {
            sRes = 'A';
        } else if (sChangeCode.equalsIgnoreCase('FIN')) {
            sRes = 'A';
        } else if (sChangeCode.equalsIgnoreCase('DIS')) {
            sRes = 'D';
        } else if (sChangeCode.equalsIgnoreCase('NWD')) {
            sRes = 'D';
        } else if (sChangeCode.equalsIgnoreCase('TER')) {
            sRes = 'D';
        } else if (sChangeCode.equalsIgnoreCase('CLO')) {
            sRes = 'D';
        } else {
            sRes = 'C';
        }

        return sRes;
    }

    public static Boolean isAddressEmpty(Account acc, String addressType) {

        System.debug(loggingLevel.Debug, '____ [cls AMS_Utils - isAddressEmpty] acc.BillingStreet - ' + acc.BillingStreet);
        System.debug(loggingLevel.Debug, '____ [cls AMS_Utils - isAddressEmpty] acc.BillingCity - ' + acc.BillingCity);
        System.debug(loggingLevel.Debug, '____ [cls AMS_Utils - isAddressEmpty] acc.BillingPostalCode - ' + acc.BillingPostalCode);
        System.debug(loggingLevel.Debug, '____ [cls AMS_Utils - isAddressEmpty] acc.IATA_ISO_Country__c - ' + acc.IATA_ISO_Country__c);
        System.debug(loggingLevel.Debug, '____ [cls AMS_Utils - isAddressEmpty] acc.Iso_State__c - ' + acc.Iso_State__c);
        System.debug(loggingLevel.Debug, '____ [cls AMS_Utils - isAddressEmpty] acc.ShippingStreet - ' + acc.ShippingStreet);
        System.debug(loggingLevel.Debug, '____ [cls AMS_Utils - isAddressEmpty] acc.ShippingCity - ' + acc.ShippingCity);
        System.debug(loggingLevel.Debug, '____ [cls AMS_Utils - isAddressEmpty] acc.ShippingPostalCode - ' + acc.ShippingPostalCode);
        
        if(addressType.equalsIgnoreCase('Billing')){
            return ((acc.BillingStreet == null && acc.BillingCity == null && acc.BillingPostalCode == null) || acc.IATA_ISO_Country__c == null || acc.Iso_State__c == null);
        }
        if(addressType.equalsIgnoreCase('Shipping')){
            return ((acc.ShippingStreet == null && acc.ShippingCity == null && acc.ShippingPostalCode == null) );
        }
        
        return false;   
    }


    public static List<String> splitAccName(String sText) {

        //String sText = 'LIDA BERLIN TRAVEL SERVICES UG (HAFTUNGSBESCHRANKT) (HAFTUNGSBESCHRANKT)';

        List<String> parts = sText.split(' ');
        List<String> res = new List<String>();

        String s1 = '';
        String s2 = '';
        String s3 = '';
        Boolean b1 = false;
        Boolean b2 = false;
        Boolean b3 = false;

        for (String s : parts) {
            String sAux = '';

            if (s.length() > 32) {
                s = s.mid(0, 32);
            }

            if (!b1) {
                sAux = s1 + s;
                if (sAux.length() > 32) {
                    b1 = True;
                    s1.removeEnd(' ');
                } else {
                    s1 = sAux.length() == 32 ? sAux : sAux + ' ';
                }
            }

            if (b1 && !b2) {
                sAux = s2 + s;
                if (sAux.length() > 32) {
                    b2 = True;
                    s2.removeEnd(' ');
                } else {
                    s2 = sAux.length() == 32 ? sAux : sAux + ' ';
                }
            }

            if (b1 && b2 && !b3) {
                sAux = s3 + s;
                if (sAux.length() > 32) {
                    b3 = True;
                    s3.removeEnd(' ');
                } else {
                    s3 = sAux.length() == 32 ? sAux : sAux + ' ';
                }
            }

        }

        res.add(s1);
        res.add(s2);
        res.add(s3);

        return res;
    }

    public static List<String> splitAccTradeName(String sText) {

        //String sText = 'LIDA BERLIN TRAVEL SERVICES UG (HAFTUNGSBESCHRANKT) (HAFTUNGSBESCHRANKT)';

        List<String> parts = sText.split(' ');
        List<String> res = new List<String>();

        String s1 = '';
        String s2 = '';
        Boolean b1 = false;
        Boolean b2 = false;

        for (String s : parts) {
            String sAux = '';

            if (s.length() > 32) {
                s = s.mid(0, 32);
            }

            if (!b1) {
                sAux = s1 + s;
                if (sAux.length() > 32) {
                    b1 = True;
                    s1.removeEnd(' ');
                } else {
                    s1 = sAux.length() == 32 ? sAux : sAux + ' ';
                }
            }

            if (b1 && !b2) {
                sAux = s2 + s;
                if (sAux.length() > 32) {
                    b2 = True;
                    s2.removeEnd(' ');
                } else {
                    s2 = sAux.length() == 32 ? sAux : sAux + ' ';
                }
            }

        }

        res.add(s1);
        res.add(s2);

        return res;
    }

    public static void createAAChangeCodes(List<AMS_OSCAR_JSON.ChangeCode> changeCodes, List<AMS_OSCAR__c> oscars, List<Account> oscarAgencies, Boolean isToUpdateAccounts) {

        Map<Account, Boolean> accountsChecker = new Map<Account, Boolean>();

        Integer index = 0;

        Set<Account> accountsToUpdate = new Set<Account>();

        List<Agency_Applied_Change_code__c> aaccToInsert = new List<Agency_Applied_Change_code__c>();

        for (AMS_OSCAR_JSON.ChangeCode cc : changeCodes) {

            Boolean isActive = false;

            if (!accountsChecker.containsKey(oscarAgencies.get(index))) {
                accountsChecker.put(oscarAgencies.get(index), false);
                isActive = true;
            }

            ChangeCodeStruct changeCodeResult = createAAChangeCode(cc, oscars.get(index), oscarAgencies.get(index), isActive);

            aaccToInsert.add(changeCodeResult.changeCode);

            if (changeCodeResult.acct != null && !accountsToUpdate.contains(changeCodeResult.acct))
                accountsToUpdate.add(changeCodeResult.acct);

            index++;

        }

        if (!accountsToUpdate.isEmpty() && (!Trigger.isExecuting || isToUpdateAccounts)) {
            System.debug('The list of Accounts to update is ' + accountsToUpdate.size());
            update new List<Account>(accountsToUpdate);
        }

        if (!aaccToInsert.isEmpty()) {

            System.debug('The list of Change Codes to add is ' + aaccToInsert.size());

            insert aaccToInsert;
        }

    }

    //Change Code Utils
    private static ChangeCodeStruct createAAChangeCode(AMS_OSCAR_JSON.ChangeCode changeCode, AMS_OSCAR__c oscar, Account oscarAgency, Boolean isActive) {

        Account toReturn = null;

        Id oscarId = null;

        if (oscar != null)
            oscarId = oscar.Id;

        System.debug('Creating a new Agency Applied Change Code for Account ' + oscarAgency.Id + ' with flag active set to ' + isActive);

        Agency_Applied_Change_code__c aacNEW = new Agency_Applied_Change_code__c(Active__c = isActive, Account__c = oscarAgency.Id, Change_Code__c = changeCode.name,
                OSCAR__c = oscarId, Bulletin_Information__c = changeCode.memoText,
                Reason_Code__c = changeCode.reasonCode, Reason_Description__c = changeCode.reasonDesc);

        //insert aacNEW;


        //update Agency Status
        String newVal = getIATAReadableStatus(changeCode.status);


        System.debug('Change code status is ' + changeCode.status);
        System.debug('Account status is ' + oscarAgency.Status__c);
        System.debug('New val is ' + newVal);


        if (newVal <> oscarAgency.Status__c && newVal != null) {

            oscarAgency.Status__c = newVal;
            toReturn = oscarAgency;
        }

        return new ChangeCodeStruct(aacNEW, toReturn);
    }

    public static String getIATAReadableStatus(String endorsmentCode) {

        if (endorsmentCode == '0')
            return ACC_S0_TERMINATED;
        if (endorsmentCode == '1')
            return ACC_S1_NOTACCREDITED;
        if (endorsmentCode == '2')
            return ACC_S2_NEWAPPLICATIONPENDING;
        if (endorsmentCode == '3')
            return ACC_S3_NOTINOPERATION;
        if (endorsmentCode == '4')
            return ACC_S4_LISTED;
        if (endorsmentCode ==  '5')
            return ACC_S5_CASHNOCOMMISSION;
        if (endorsmentCode == '6')
            return ACC_S6_CASHWITHCOMMISSION;
        if (endorsmentCode == '7')
            return ACC_S7_UNDERREVIEW;
        if (endorsmentCode == '8')
            return ACC_S8_CHANGESPROCESSED;
        if (endorsmentCode == '9')
            return ACC_S9_APPROVED;

        return null;
    }

    public static String getIATANumericStatus(String statusDesc) {

        if (statusDesc == ACC_S0_TERMINATED)
            return '0';
        if (statusDesc == ACC_S1_NOTACCREDITED)
            return '1';
        if (statusDesc == ACC_S2_NEWAPPLICATIONPENDING)
            return '2';
        if (statusDesc == ACC_S3_NOTINOPERATION)
            return '3';
        if (statusDesc == ACC_S4_LISTED)
            return '4';
        if (statusDesc == ACC_S5_CASHNOCOMMISSION)
            return '5';
        if (statusDesc == ACC_S6_CASHWITHCOMMISSION)
            return '6';
        if (statusDesc == ACC_S7_UNDERREVIEW)
            return '7';
        if (statusDesc == ACC_S8_CHANGESPROCESSED)
            return '8';
        if (statusDesc == ACC_S9_APPROVED)
            return '9';

        return null;
    }

    public static String getIATANReadableStatus(String endorsmentCode) {

        if (endorsmentCode == '0') {
            return 'Terminated';
        }
        if (endorsmentCode == '2') {
            return 'New application pending';
        }

        if (endorsmentCode == '4') {
            return 'Listed';
        }

        if (endorsmentCode ==  '5') {
            return 'Listed(BSP)';
        }

        if (endorsmentCode == '6') {
            return 'Under review';
        }

        if (endorsmentCode == '7') {
            return 'Approved';
        }

        return null;
    }

    //OSCAR UTILS

    public static void syncOSCARwithIFAP(Case previousIFAPCase, Case updatedIFAPCase) {

        Boolean mustUpdateOSCAR = false;
        List<AMS_OSCAR__c> oscar = [select Financial_Assessment_requested__c, Financial_Assessment_deadline__c, Assessment_Performed_Date__c, Financial_Review_Result__c from AMS_OSCAR__c where Id = : updatedIFAPCase.OSCAR__c];
        if (oscar != null || oscar.size() > 0) {

            if (previousIFAPCase.Financial_Assessment_requested__c <> updatedIFAPCase.Financial_Assessment_requested__c) {
                oscar[0].Financial_Assessment_requested__c = updatedIFAPCase.Financial_Assessment_requested__c;
                mustUpdateOSCAR = true;
            }

            if (previousIFAPCase.Deadline_Date__c <> updatedIFAPCase.Deadline_Date__c) {
                oscar[0].Financial_Assessment_deadline__c = updatedIFAPCase.Deadline_Date__c;
                mustUpdateOSCAR = true;
            }

            if (previousIFAPCase.Assessment_Performed_Date__c <> updatedIFAPCase.Assessment_Performed_Date__c) {
                oscar[0].Assessment_Performed_Date__c = updatedIFAPCase.Assessment_Performed_Date__c;
                mustUpdateOSCAR = true;
            }

            if (previousIFAPCase.Financial_Review_Result__c <> updatedIFAPCase.Financial_Review_Result__c) {
                oscar[0].Financial_Review_Result__c = updatedIFAPCase.Financial_Review_Result__c;
                mustUpdateOSCAR = true;
            }

            if (previousIFAPCase.Financial_Security_Amount__c <> updatedIFAPCase.Financial_Security_Amount__c) {
                oscar[0].Bank_Guarantee_amount__c = updatedIFAPCase.Financial_Security_Amount__c;
                mustUpdateOSCAR = true;
            }

            if (previousIFAPCase.Financial_Security_Currency__c <> updatedIFAPCase.Financial_Security_Currency__c) {
                oscar[0].Bank_Guarantee_Currency__c = updatedIFAPCase.Financial_Security_Currency__c;
                mustUpdateOSCAR = true;
            }

            if (previousIFAPCase.FS_Deadline_Date__c <> updatedIFAPCase.FS_Deadline_Date__c) {
                oscar[0].Bank_Guarantee_deadline__c = updatedIFAPCase.FS_Deadline_Date__c;
                mustUpdateOSCAR = true;
            }

            if (mustUpdateOSCAR)
                update oscar[0];
        }

    }


    //Map data from staging area (AMS Online Accreditation) to account
    public static void copyDataToAccount(List<AMS_OSCAR__c> oscars) {

        AMS_AccountTriggerHandler.processMinorChangesValidationFlag = false;

        ID changeRT = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('CHANGE').getRecordTypeId();

        System.debug('Copying Data from Staging to Account');

        List<Account> accountsToUpdate = new List<Account>();
        List<AMS_Pax_Accreditation_Form__c> onlineAccToCreateAccountRole = new List<AMS_Pax_Accreditation_Form__c>();
		
		//DT: reindented and added 3 fields for iso shipping/billin
        Map<String, String> fieldsMapping = new Map<String, String> {'Name' => 'Account_Name__c'
																	,'IATACode__c' => 'IATACode__c'
																	,'Short_Name__c' => 'Short_Name__c'
																	,'TradeName__c' => 'Trade_Name__c'
																	,'License_Number__c' => 'ISSP_AMS_License_No__c'
																	,'VAT_Number__c' => 'ISSP_AMS_VAT_number__c'
																	,'BillingStreet' => 'Branch_Office_Street_name_number__c'
																	,'Website' => 'Website__c'
																	,'BillingPostalCode' => 'Branch_Office_Postal_code__c'
																	,'BillingState' => 'Billing_State__c'
																	,'BillingCity' => 'Branch_Office_City__c'
																	,'IATA_ISO_Country__c' => 'Branch_Office_Country__c'
																	,'Iso_State__c' => 'IATA_ISO_State__c'
																	,'ShippingCountry' => 'Shipping_Country__c'
																	,'ShippingStreet' => 'Shipping_Street__c'
																	,'ShippingPostalCode' => 'Shipping_Postal_Code__c'
																	,'ShippingState' => 'Shipping_State__c'
																	,'Email__c' => 'Branch_Office_Email__c'
																	,'Phone' => 'Branch_Office_Phone__c'
																	,'Fax' => 'Branch_Office_FAX__c'
																	,'ShippingCity' => 'Shipping_City__c'
																	,'Operation__c' => 'Operation__c'
																	,'Abbreviated_name__c' => 'Abbreviated_name__c'
																	,'Abbreviated_address__c' => 'Abbreviated_Address__c'
																	,'Remittance_frequency__c' => 'Remittance_frequency__c'
																	,'Solicitation_Flag__c' => 'Solicitation_Flag__c'
																	,'VAT_Number_2__c' => 'VAT_Number_2__c'
																	,'CASS_Number__c' => 'CASS_Number__c'
																	,'Location_Class__c' => 'Location_Class__c'
																	,'Location_Type__c' => 'Location_Type__c'
																	,'Mobile__c' => 'Mobile__c'
																	,'Is_your_firm_handling_Dangerous_Goods__c' => 'Is_your_firm_handling_Dangerous_Goods__c'
																	,'IATA_ISO_Billing_State__c' => 'IATA_ISO_State__c'
																	,'IATA_ISO_Shipping_Country__c' => 'Shipping_ISO_Country__c'
																	,'IATA_ISO_Shipping_State__c' => 'Shipping_ISO_State__c'};

        //Need to get Accounts and AMS Online Accreditation related to these oscars
        Set<Id> oscarAccountIds = new Set<Id>();
        Set<Id> oscarOnlineAccredIds = new Set<Id>();

        for (AMS_OSCAR__c oscar : oscars) {
            oscarAccountIds.add(oscar.Account__c);
            oscarOnlineAccredIds.add(oscar.AMS_Online_Accreditation__c);
        }

        Map<Id, Account> accounts = new Map<Id, Account>([SELECT Name, IATACode__c, Company_Type__c, Short_Name__c, TradeName__c, License_Number__c, VAT_Number__c, GDS__c, Operation__c,
                BillingCountry, BillingStreet, BillingPostalCode, BillingState, BillingCity, IATA_ISO_Country__c, Iso_State__c, ShippingCountry,
                ShippingStreet, ShippingPostalCode, ShippingState, ShippingCity, Email__c, Website, Phone, Fax, In_a_Airport__c, Abbreviated_name__c, Abbreviated_address__c,
                Remittance_frequency__c, Solicitation_Flag__c, VAT_Number_2__c, CASS_Number__c, Location_Class__c, Location_Type__c, Mobile__c, Is_your_firm_handling_Dangerous_Goods__c
                ,IATA_ISO_Billing_State__c, IATA_ISO_Shipping_Country__c, IATA_ISO_Shipping_State__c
                FROM Account
                WHERE Id IN :oscarAccountIds]);

        Map<Id, AMS_Pax_Accreditation_Form__c> onlineAccreditations = new Map<Id, AMS_Pax_Accreditation_Form__c>([SELECT Account_Name__c, IATACode__c, ISSP_AMS_Legal_Status__c, Short_Name__c, Trade_Name__c, ISSP_AMS_License_No__c, ISSP_AMS_VAT_number__c,
                ISSP_AMS_GDS_with_signed_contract__c, Operation__c, Branch_Office_Country__r.Name, Branch_Office_Street_name_number__c, Branch_Office_Postal_code__c,
                Billing_State__c, Branch_Office_City__c, ISO_Country__c, IATA_ISO_State__c, Shipping_Country__c, Shipping_Street__c, Shipping_Postal_Code__c,
                Shipping_State__c, Shipping_City__c, Branch_Office_Email__c, Website__c, Branch_Office_Phone__c, Branch_Office_FAX__c, ISSP_AMS_Premises_located_at_airport__c,
                Abbreviated_name__c, Abbreviated_address__c, Remittance_frequency__c, Solicitation_Flag__c, VAT_Number_2__c, CASS_Number__c, Location_Class__c, Location_Type__c, Mobile__c, Is_your_firm_handling_Dangerous_Goods__c
                ,Shipping_ISO_Country__c,Shipping_ISO_State__c
                FROM AMS_Pax_Accreditation_Form__c
                WHERE Id IN :oscarOnlineAccredIds]);

        List<Map<String, String>> configs = AMS_AgencyChangesConfigHelper.getAgencyChangesConfigData();

        for (AMS_OSCAR__c oscar : oscars) {

            Account acc = accounts.get(oscar.Account__c);
            AMS_Pax_Accreditation_Form__c onlineAcc = onlineAccreditations.get(oscar.AMS_Online_Accreditation__c);

            if (acc != null && onlineAcc != null) {

                /*Set<String> fieldsToMigrate;
                if (oscar.recordTypeID == changeRT) {

                    fieldsToMigrate = AMS_AgencyChangesConfigHelper.getFieldsToMigrate(oscar, configs);

                    if (fieldsToMigrate != null) {

                        for (String key : fieldsMapping.keySet()) {
                            String value = fieldsMapping.get(key);
                            if (fieldsToMigrate.contains(value)) {
                                acc.put(key, onlineAcc.get(value));
                                System.debug(key + ':' + onlineAcc.get(value));
                            }
                        }

                        //fields that require transformation
                        if (fieldsToMigrate.contains('ISSP_AMS_Premises_located_at_airport__c'))
                            acc.In_a_Airport__c = (onlineAcc.ISSP_AMS_Premises_located_at_airport__c == 'Yes') ? true : false;
                        if (fieldsToMigrate.contains('ISSP_AMS_Legal_Status__c'))
                            acc.Company_Type__c = transformCompanyType(onlineAcc.ISSP_AMS_Legal_Status__c);
                        if (fieldsToMigrate.contains('ISSP_AMS_GDS_with_signed_contract__c'))
                            acc.GDS__c = transformGDS(onlineAcc.ISSP_AMS_GDS_with_signed_contract__c);
                        if (fieldsToMigrate.contains('Branch_Office_Country__c'))
                            acc.BillingCountry = onlineAcc.Branch_Office_Country__r.Name;
                        if (fieldsToMigrate.contains('ISSP_AMS_Total_Ownership__c'))
                            onlineAccToCreateAccountRole.add(onlineAcc);

                    }

                } else {*/

                    for (String key : fieldsMapping.keySet()) {
                        String value = fieldsMapping.get(key);
                        acc.put(key, onlineAcc.get(value));
                        System.debug(key + ':' + onlineAcc.get(value));
                    }

                    acc.In_a_Airport__c = (onlineAcc.ISSP_AMS_Premises_located_at_airport__c == 'Yes') ? true : false;
                    acc.Company_Type__c = transformCompanyType(onlineAcc.ISSP_AMS_Legal_Status__c);
                    acc.GDS__c = transformGDS(onlineAcc.ISSP_AMS_GDS_with_signed_contract__c);
                    acc.BillingCountry = onlineAcc.Branch_Office_Country__r.Name;
                    onlineAccToCreateAccountRole.add(onlineAcc);
                //}

                accountsToUpdate.add(acc);

            }

            if (!accountsToUpdate.isEmpty()) {
                update accountsToUpdate;
            }
            if (!onlineAccToCreateAccountRole.isEmpty())
                AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(onlineAccToCreateAccountRole);

        }
    }

    public static Boolean ownershipIsToBeMigrated(String typesOfChange){

        Set<String> fieldsToMigrate = AMS_AgencyChangesConfigHelper.getFieldsToMigrate(typesOfChange);
        if (fieldsToMigrate.contains('ISSP_AMS_Total_Ownership__c'))
            return true;

        return false;

    }

    //Map data from staging area (AMS Online Accreditation) to account
    public static List<Account> copyDataToAccountForAgencyChanges(AMS_OSCAR__c oscar, Set<Id> accountsAffected, String typesOfChange, Map<Id, Account> accounts, AMS_Pax_Accreditation_Form__c oscarOnlineAccreditation) {

        Set<String> fieldsToMigrate = AMS_AgencyChangesConfigHelper.getFieldsToMigrate(typesOfChange);

        System.debug('AGENCY CHANGES: fields to migrate (' + fieldsToMigrate + ') for accounts: ' + accountsAffected);

        List<Account> accountsToUpdate = new List<Account>();
		
		//DT: Reindented and added 3 fields for addresses
        Map<String, String> fieldsMapping = new Map<String, String> {'Name' => 'Account_Name__c'
																	,'IATACode__c' => 'IATACode__c'
																	,'Short_Name__c' => 'Short_Name__c'
																	,'TradeName__c' => 'Trade_Name__c'
																	,'License_Number__c' => 'ISSP_AMS_License_No__c'
																	,'VAT_Number__c' => 'ISSP_AMS_VAT_number__c'
																	,'BillingStreet' => 'Branch_Office_Street_name_number__c'
																	,'Website' => 'Website__c'
																	,'BillingPostalCode' => 'Branch_Office_Postal_code__c'
																	,'BillingState' => 'Billing_State__c'
																	,'BillingCity' => 'Branch_Office_City__c'
																	,'IATA_ISO_Country__c' => 'Branch_Office_Country__c'
																	,'Iso_State__c' => 'IATA_ISO_State__c'
																	,'ShippingCountry' => 'Shipping_Country__c'
																	,'ShippingStreet' => 'Shipping_Street__c'
																	,'ShippingPostalCode' => 'Shipping_Postal_Code__c'
																	,'ShippingState' => 'Shipping_State__c'
																	,'Email__c' => 'Branch_Office_Email__c'
																	,'Phone' => 'Branch_Office_Phone__c'
																	,'Fax' => 'Branch_Office_FAX__c'
																	,'ShippingCity' => 'Shipping_City__c'
																	,'Operation__c' => 'Operation__c'
																	,'Abbreviated_name__c' => 'Abbreviated_name__c'
																	,'Abbreviated_address__c' => 'Abbreviated_Address__c'
																	,'Remittance_frequency__c' => 'Remittance_frequency__c'
																	,'Solicitation_Flag__c' => 'Solicitation_Flag__c'
																	,'VAT_Number_2__c' => 'VAT_Number_2__c'
																	,'CASS_Number__c' => 'CASS_Number__c'
																	,'Location_Class__c' => 'Location_Class__c'
																	,'Location_Type__c' => 'Location_Type__c'
																	,'Mobile__c' => 'Mobile__c'
																	,'Is_your_firm_handling_Dangerous_Goods__c' => 'Is_your_firm_handling_Dangerous_Goods__c'
																	,'IATA_ISO_Billing_State__c' => 'IATA_ISO_State__c'
																	,'IATA_ISO_Shipping_Country__c' => 'Shipping_ISO_Country__c'
																	,'IATA_ISO_Shipping_State__c' => 'Shipping_ISO_State__c'};

        if (fieldsToMigrate != null) {
                Map<String, Object> accountFieldNewValue = new Map<String,Object>();

                for (String key : fieldsMapping.keySet()) {
                    String value = fieldsMapping.get(key);
                    if (fieldsToMigrate.contains(value)) {
                    
                        accountFieldNewValue.put(key, oscarOnlineAccreditation.get(value));
                        System.debug(key + ':' + oscarOnlineAccreditation.get(value));
                    }
                }

                //fields that require transformation
                if (fieldsToMigrate.contains('ISSP_AMS_Premises_located_at_airport__c'))
                    accountFieldNewValue.put('In_a_Airport__c', (oscarOnlineAccreditation.ISSP_AMS_Premises_located_at_airport__c == 'Yes') ? true : false);
                if (fieldsToMigrate.contains('ISSP_AMS_Legal_Status__c'))
                    accountFieldNewValue.put('Company_Type__c', transformCompanyType(oscarOnlineAccreditation.ISSP_AMS_Legal_Status__c));
                if (fieldsToMigrate.contains('ISSP_AMS_GDS_with_signed_contract__c'))
                    accountFieldNewValue.put('GDS__c', transformGDS(oscarOnlineAccreditation.ISSP_AMS_GDS_with_signed_contract__c));
                if (fieldsToMigrate.contains('Branch_Office_Country__c'))
                    accountFieldNewValue.put('BillingCountry', oscarOnlineAccreditation.Branch_Office_Country__r.Name);
                //if (fieldsToMigrate.contains('ISSP_AMS_Total_Ownership__c'))
                    //AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(new List<AMS_Pax_Accreditation_Form__c>{onlineAcc}, accountsAffected);

                for(Id accId: accountsAffected){
                    Account acc = accounts.get(accId);

                    for(String accFieldApiName: accountFieldNewValue.keySet())
                        acc.put(accFieldApiName, accountFieldNewValue.get(accFieldApiName));

                    accountsToUpdate.add(acc);
                }

        }

    return accountsToUpdate;

}


/**
    Method to help the transformation between Specify Legal Status (AMS Online Accreditation) and Company Type (Acccount)
    */
public static String transformCompanyType(String companyType) {

    if (companyType == null)
        return null;

    if (companyType.equalsIgnoreCase('Association'))
        return 'A';
    if (companyType.equalsIgnoreCase('Corporation'))
        return 'C';
    if (companyType.equalsIgnoreCase('State Owned Enterprise'))
        return 'E';
    if (companyType.equalsIgnoreCase('Joint Venture'))
        return 'J';
    if (companyType.equalsIgnoreCase('Limited Company'))
        return 'L';
    if (companyType.equalsIgnoreCase('Other'))
        return 'O';
    if (companyType.equalsIgnoreCase('Partnership'))
        return 'P';
    if (companyType.equalsIgnoreCase('Limited Partnership'))
        return 'R';
    if (companyType.equalsIgnoreCase('Sole Proprietorship'))
        return 'S';
    if (companyType.equalsIgnoreCase('Trust Company'))
        return 'T';
    if (companyType.equalsIgnoreCase('Co-operative'))
        return 'V';

    return null;

}

/**
Method to help the transformation between Specify GDS with signed contract (AMS Online Accreditation) and GDS (Acccount)
*/
public static String transformGDS(String gds) {

    String result = gds;

    if (result == null)
        return null;

    if (result.containsIgnoreCase('Abacus'))
        result = result.replace('Abacus', 'ABAC');
    if (result.containsIgnoreCase('Amadeus'))
        result = result.replace('Amadeus', 'AGTD');
    if (result.containsIgnoreCase('Axess'))
        result = result.replace('Axess', 'AXSS');
    if (result.containsIgnoreCase('Kiu System'))
        result = result.replace('Kiu System', 'CMAS');
    if (result.containsIgnoreCase('Deutsche Reiseburo'))
        result = result.replace('Deutsche Reiseburo', 'DERD');
    if (result.containsIgnoreCase('Farelogix'))
        result = result.replace('Farelogix', 'FLGX');
    if (result.containsIgnoreCase('Travelport (Galileo)'))
        result = result.replace('Travelport (Galileo)', 'GDSL');
    if (result.containsIgnoreCase('Infini'))
        result = result.replace('Infini', 'INFI');
    if (result.containsIgnoreCase('Kotis Travel Info SE'))
        result = result.replace('Kotis Travel Info SE', 'KOTI');
    if (result.containsIgnoreCase('Travelsky'))
        result = result.replace('Travelsky', 'MINS');
    if (result.containsIgnoreCase('Resiber'))
        result = result.replace('Resiber', 'RESI');
    if (result.containsIgnoreCase('Sabre'))
        result = result.replace('Sabre', 'SABR');
    if (result.containsIgnoreCase('SITA'))
        result = result.replace('SITA', 'SITA');
    if (result.containsIgnoreCase('Sirena'))
        result = result.replace('Sirena', 'STRA');
    if (result.containsIgnoreCase('Topas'))
        result = result.replace('Topas', 'TOPAS');
    if (result.containsIgnoreCase('Travelport (Apollo)'))
        result = result.replace('Travelport (Apollo)', 'UALA');
    if (result.containsIgnoreCase('Travelport (Worldspan)'))
        result = result.replace('Travelport (Worldspan)', 'WSPN');

    return result;

}

public static String errorMessageBeautifyer(Exception ex) {
    String errorString = ex.getMessage();
    String searchString = 'FIELD_CUSTOM_VALIDATION_EXCEPTION';
    System.debug('EXCEPTION!! ' + ex.getMessage() + '\n ' + ex.getStackTraceString());
    if (ex.getMessage().containsIgnoreCase(searchString)) {
        System.debug(ex.getMessage().indexOfIgnoreCase(searchString));
        Integer startOfErrorMessage = ex.getMessage().indexOfIgnoreCase(searchString) + searchString.length() + 2;
        errorString = ex.getMessage().substring(startOfErrorMessage, ex.getMessage().length());
        errorString = errorString.substringBefore(':');
    }
    return 'ERROR: ' + errorString;
}

public static RecordType getRecordType(String sObjectType, String developerName) {
    RecordType result = currentCache.get(developerName + '%%' + sObjectType);
    if (result == null) {
        throw new AMS_ApplicationException('Could not find RecordType for ' + sObjectType + ', ' + developerName);
    }
    return result;
}

public static RecordType getRecordType(Id recordTypeId) {
    if (currentCache == null) {
        refreshCache();
    }

    RecordType result = currentCache.get(recordTypeId);
    if (result == null) {
        refreshCache();
        result = currentCache.get(recordTypeId);
    }
    return result;
}

/**
 * Get the recordTypeId for the given sObjectType and developerName
 */
public static Id getId(String sObjectType, String developerName) {
    RecordType rt = getRecordType(sObjectType, developerName);
    if (rt != null) {
        return rt.id;
    }
    return null;
}

/////////////////////////////////////////////////////////////////////////////////////
// Private methods

/**
 * Encrypts a string
 * @param key The key to use to encrypt
 * @param str The String to encrypt
 * @return The encrypted string
 */
private static String EncryptString(String key, String str) {
    Blob dataToEncrypt = Blob.valueOf(str);
    Blob encryptedData = Crypto.encryptWithManagedIV(ENCRYPTION_ALGORYTHM, EncodingUtil.base64Decode(key), dataToEncrypt);
    return EncodingUtil.base64Encode(encryptedData);
}

/**
 * Decrypts a string
 * @param key The key to use to decrypt
 * @param str The encrypted string
 * @return The decrypted string
 */
private static String DecryptString(String key, String str) {
    Blob encryptedData = Encodingutil.base64Decode(str);
    Blob decryptedData = Crypto.decryptWithManagedIV(ENCRYPTION_ALGORYTHM, EncodingUtil.base64Decode(key), encryptedData);
    return decryptedData.toString();
}

private static void refreshCache() {
    Map<String, RecordType> newCache = new Map<String, RecordType>();

    for (RecordType rt : [ select id, name, developerName, SObjectType from RecordType ]) {
        newCache.put(rt.developerName + '%%' + rt.SObjectType, rt);
        newCache.put(rt.Id, rt);
    }
    currentCache = newCache;
}

public static String findObjectNameFromRecordIdPrefix(String recordIdOrPrefix) {

    System.debug('Input to find Record is ' + recordIdOrPrefix);

    String objectName = '';
    try {
        //Get prefix from record ID
        //This assumes that you have passed at least 3 characters
        String myIdPrefix = String.valueOf(recordIdOrPrefix).substring(0, 3);

        //Get schema information
        Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe();

        //Loop through all the sObject types returned by Schema
        for (Schema.SObjectType stype : gd.values()) {
            Schema.DescribeSObjectResult r = stype.getDescribe();
            String prefix = r.getKeyPrefix();

            //Check if the prefix matches with requested prefix
            if (prefix != null && prefix.equals(myIdPrefix)) {
                objectName = r.getName();
                System.debug('Found Object - Name:' + objectName);
                break;
            }
        }
    } catch (Exception e) {
        System.debug(e);

    }
    return objectName;
}

public static Map<String, String> getObjectLabels(String objectApiName) {

    Map<String, String> toReturn = new Map<String, String>();

    Map<String, Schema.SObjectField> fieldMap = getObjectFields(objectApiName);

    for (String fieldName : fieldMap.keySet()) {

        toReturn.put(fieldName.toLowerCase(), fieldMap.get(fieldName).getDescribe().getLabel());
    }

    return toReturn;

}


public static Map<String, Schema.SObjectField> getObjectFields(String objectApiName) {

    Map<String, String> toReturn = new Map<String, String>();

    Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();

    Schema.SObjectType leadSchema = schemaMap.get(objectApiName);

    return leadSchema.getDescribe().fields.getMap();

}



public class ChangeCodeStruct {

    private Agency_Applied_Change_code__c changeCode {get; set;}
    private Account acct {get; set;}

    public ChangeCodeStruct(Agency_Applied_Change_code__c changeCode, Account acct) {

        this.changeCode = changeCode;
        this.acct = acct;

    }

}

//will carry change codes
public class Container {

    public List<AMS_OSCAR_JSON.ChangeCode> changeCodes;
    public List<Account> accts;
    public List<AMS_OSCAR__c> oscars;
    //public AMS_HierarchyHelper.HierarchyStruct relationshipsToManage;

    public Container(List<AMS_OSCAR_JSON.ChangeCode> changeCodes, List<Account> accts, List<AMS_OSCAR__c> oscars/*, AMS_HierarchyHelper.HierarchyStruct relationshipsToManage*/) {

        this.changeCodes = changeCodes;
        this.accts = accts;
        this.oscars = oscars;
        //this.relationshipsToManage = relationshipsToManage;

    }
}

//Agency Changes Config structure
public class AgChangesConfig {

    public String typesOfChange;
    public Map<String, String> config;

    public AgChangesConfig(String typesOfChange, Map<String, String> config) {
        this.typesOfChange = typesOfChange;
        this.config = config;
    }
}

public static boolean isAMSProfile(Id profileId) {
    return AMSPROFILES.contains(profileId);
}

}