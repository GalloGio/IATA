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
                    iataIsoStates.put(state.Name.toLowerCase(), state);
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
                    iataIsoCountries.put(country.Name.toLowerCase(), country);
                }
                System.debug(loggingLevel.Debug, '____ [cls AMS_Utils - iataIsoCountries] iataIsoCountries - ' + iataIsoCountries);
            }

            return iataIsoCountries;
        }
        set;
    }

    public static List<AMS_ChangeCodes__c> CUSTOM_CHANGECODES {
        get { 
            if(CUSTOM_CHANGECODES == null){
                CUSTOM_CHANGECODES = [SELECT Change_Code__c,Integration_RecId__c,Account_status_change__c,Billable__c,Bulletin_Memo_Text__c,
                                                                Reason_Code__c, Reason_Code_Description__c
                                                        FROM AMS_ChangeCodes__c];
            }
            return CUSTOM_CHANGECODES;
        }
        private set;
    }
    
    public static List<AMS_ChangeCodes_Integration__c> CUSTOM_CHANGECODES_INTEGRATION {
        get {
            if(CUSTOM_CHANGECODES_INTEGRATION == null){
                CUSTOM_CHANGECODES_INTEGRATION = [SELECT RecId_A__c,RecId_B__c,RecId_Res__c FROM AMS_ChangeCodes_Integration__c];
                
            }
            return CUSTOM_CHANGECODES_INTEGRATION;
        }
        private set;
    }

    private static Map<String, RecordType> currentCache = null;

    public static String userSessionId = UserInfo.getSessionId();

    public static final String SANITYCHECK = 'Perform Sanity Check';
    public static final String APPROVAL = 'Manager Approval';
    public static final String WITHDRAWAL = 'Application Withdrawal';
    public static final String SUSPENSION = 'Process suspension';
    public static final String TERMINATION = 'Process termination';

    public static final String PASSED = 'Passed';
    public static final String FAILED = 'Failed';
    public static final String NOT_APPLICABLE = 'Not Applicable';

    public static final String AUTH_APPROVAL = 'Authorize Approval';
    public static final String AUTH_DISAPPROVAL ='Authorize Disapproval';
    public static final String LOCATION_TYPE = 'Location type';
    public static final String LOCATION = 'Location';
    public static final String LOCATION_INSPECTION = 'Location with inspection';
    public static final String OWNERSHIP_IATA = 'Ownership to IATA Agent';
    public static final String OWNERSHIP_NON_IATA = 'Ownership to non-IATA Agent';
    public static final String MAJ_SHAREHOLDING = 'Major Shareholding';
    public static final String MIN_SHAREHOLDING = 'Minor Shareholding';
    public static final String NAME = 'Name';
    public static final String LEGAL_STATUS = 'Legal Status';
    public static final String VFMR = 'VMFR';


    public static final String OSCAR_CLOSED = 'Closed (Closed)';

    public static final String BR = 'BR';
    public static final String HO = 'HO';
    public static final String AO = 'AO';
    public static final String SA = 'SA';

    //Processes of type NEW
    public static final String new_HO           = 'NEW.HO.1.0'      ;
    public static final String new_BR           = 'NEW.BR'          ;
    public static final String new_BR_ABROAD    = 'NEW.BR.ABROAD'   ;
    public static final String new_TIDS         = 'NEW.TIDS.1.0'    ;
    public static final String new_MSO          = 'NEW.MSO.1.0'     ;
    public static final String new_GSA          = 'NEW.GSA.1.0'     ;
    public static final String new_GSA_BSP      = 'NEW.GSA.1.0.BSP' ;
    public static final String new_GSSA         = 'NEW.GSSA.1.0'    ;
    public static final String new_AHA          = 'NEW.AHA.1.0'     ;
    public static final String new_AHA_BSP      = 'NEW.AHA.1.0.BSP' ;
    public static final String new_SA           = 'NEW.SA.1.0'      ;

    //Processes of type CHANGES
    public static final String COR              = 'CORRECTION.1.0'  ;
    public static final String AGENCYCHANGES    = 'MAJOR.CHANGES'   ;
    public static final String VOLRELINQUISH    = 'VR.1.0'          ;
    public static final String VOLRELINQUISH_CA = 'VR.1.0.CA'       ;
    public static final String BANKACCCHANGES   = 'BANK.ACCOUNT.CHANGES';
    public static final String CERTIFICATION    = 'CERTIFICATION.1.0';

    //other types of process
    public static final String CERTIFICATE      = 'CER.1.0'         ;

    //Types of Certificate
    public static final String CERT_DGR         = 'DGR';
    public static final String CERT_DGA         = 'DGA';

    //Record Types
    public static final String RECTYPE_NEW      = Schema.AMS_OSCAR__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('NEW').getRecordTypeId();
    public static final String RECTYPE_CHANGE   = Schema.AMS_OSCAR__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('CHANGE').getRecordTypeId();
    public static final String RECTYPE_CERT     = Schema.AMS_OSCAR__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('CERTIFICATION').getRecordTypeId();
    public static final String RECTYPE_OSCARCOMM= Schema.SObjectType.Case.getRecordTypeInfosByName().get('OSCAR Communication').getRecordTypeId();

    public static final Set<String> oscarAMSProcesses = new Set <String>{new_HO,new_BR,new_BR_ABROAD,new_TIDS,new_MSO,new_GSA,new_GSA_BSP,new_GSSA,new_AHA,new_AHA_BSP,new_SA, COR};


    public static final Set<String> oscarProcessesWithAppointments = new Set <String>{new_GSA,new_GSA_BSP,new_AHA,new_AHA_BSP,new_GSSA,new_MSO};

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
     
    public static final String CHLOCTYPEBEHAVIOR_NOSWAP = 'Don’t change the parent';        
    public static final String CHLOCTYPEBEHAVIOR_SWAP = 'Swap with the parent';
    public static final String CHLOCTYPEBEHAVIOR_STANDARD = CHLOCTYPEBEHAVIOR_SWAP;
    public static final String SECTOR_CARGO = 'Cargo Agent';
    public static final String SECTOR_PASSENGER = 'Travel Agent';

    public static final String TYPECHANGE_OWNERIATA2IATA = 'Ownership to IATA Agent';
    public static final String TYPECHANGE_OWNERIATA2NONIATA = 'Ownership to non-IATA Agent';
    public static final String TYPECHANGE_LOCATION = 'Location';
    public static final String TYPECHANGE_LOCATIONWITHINSPECTION = 'Location with inspection'; 
    public static final Id AccreditationContactPersonRT = Schema.SObjectType.AMS_Accreditation_Contact__c.getRecordTypeInfosByName().get('Person').getRecordTypeId();
    public static final Id AccreditationContactCompanyRT = Schema.SObjectType.AMS_Accreditation_Contact__c.getRecordTypeInfosByName().get('Company').getRecordTypeId();
    public static final Id AccreditationContactTrainedStaffRT = Schema.SObjectType.AMS_Accreditation_Contact__c.getRecordTypeInfosByName().get('Trained Staff').getRecordTypeId();
    public static final Id AccountRoleOwnershipRT = Schema.SObjectType.AMS_Account_Role__c.getRecordTypeInfosByName().get('Ownership').getRecordTypeId();

    public static final Set<String> LocationClassIFAPAllowed = new Set<String>{'P','C','R'};
    public static final Set<String> LocationClassCARGO = new Set<String>{'C','I','Q','R'};
    public static final Set<String> LocationClassPASSENGER = new Set<String>{'P','T','M','X'};
    public static final Set<String> LocationTypeAllHOTypes = new Set<String>{'EP','AO','SP','AA','HO'};


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

    public static Map<String, String> categoryCustomerMap = new Map<String, String> {
        'IATA Passenger Sales Agent' => 'IATA Travel Agent',
        'IATA Cargo Agent' =>   'IATA Cargo Agent',
        'Import Agent' =>   'IATA Cargo Agent',
        'CASS Associate' => 'CASS Associates',
        'Courier' =>    'IATA Cargo Agent',
        'Handling Agent' => 'IATA Travel Agent',
        'MSO Member Sales Office' => 'IATA Travel Agent',
        'TIDS Agent' => 'TIDS',
        'GSA General Sales Agent' =>    'General Sales Agent (GSA)',
        'GSSA Cargo' => 'GSSA Cargo'
    };   

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

    public static String getStatusDescFromChangeCode(String sChangeCode) {

        String sRes = '';

        if (sChangeCode.equalsIgnoreCase('NEW')) {
            sRes = 'in progress';
        } else if (sChangeCode.equalsIgnoreCase('FIN')) {
            sRes = 'finalized';
        }
        else if (sChangeCode.equalsIgnoreCase('DIS')) {
            sRes = 'disapproved';
        }
        
        return sRes;
    }
    /**
    //Based on the Change code passed we get the Rec ID
    Indicates if record is A=Added, C=Changed or D=Deleted.
    */
    public static String getRecIdFromChangeCode(String sChangeCode) {

        //Validates the Changes codes for "A=Added" and "D=Deleted", all other Change Codes not mentioned return "C=Changed"

        String sRes = '';

        for (AMS_ChangeCodes__c cc : CUSTOM_CHANGECODES ){

            if(cc.Change_Code__c.equalsIgnoreCase(sChangeCode)){
                sRes = cc.Integration_RecId__c;
                break;
            }

        }

        //Just in case we don't get a result, we set the value for the most common RecId - "C"
        if( sRes == ''){
            sRes = 'C';
        }
/*
        // «A» Section
        if (sChangeCode.equalsIgnoreCase('NEW')) {
            sRes = 'A';
        } else if (sChangeCode.equalsIgnoreCase('FIN')) {
            sRes = 'A';
        } else if (sChangeCode.equalsIgnoreCase('CON')) {
            sRes = 'A';
        } else if (sChangeCode.equalsIgnoreCase('NCA')) {
            sRes = 'A';
        } else if (sChangeCode.equalsIgnoreCase('NFN')) {
            sRes = 'A';
        } else if (sChangeCode.equalsIgnoreCase('NWH')) {
            sRes = 'A';
        } else if (sChangeCode.equalsIgnoreCase('REC')) {
            sRes = 'A';
        } else if (sChangeCode.equalsIgnoreCase('NEP')) {
            sRes = 'A';
        } else if (sChangeCode.equalsIgnoreCase('NAC')) {
            sRes = 'A';
        } 
        // «D» Section
        else if (sChangeCode.equalsIgnoreCase('DIS')) {
            sRes = 'D';
        } else if (sChangeCode.equalsIgnoreCase('NWD')) {
            sRes = 'D';
        } else if (sChangeCode.equalsIgnoreCase('TER')) {
            sRes = 'D';
        } else if (sChangeCode.equalsIgnoreCase('CLO')) {
            sRes = 'D';
        } 
        // «C» Section
        else {
            sRes = 'C';
        }
*/
        return sRes;
    }
/**
    //Based on the Change code passed we get the Rec ID
    Indicates if record is A=Added, C=Changed or D=Deleted.
    */
    public static String getRecIdFromIntegrationMatriz(String sRecIdA, String sRecIdB) {

        //Validates the Changes codes for "A=Added" and "D=Deleted", all other Change Codes not mentioned return "C=Changed"

        String sRes = '';

        for (AMS_ChangeCodes_Integration__c cc : CUSTOM_CHANGECODES_INTEGRATION ){

            if(cc.RecId_A__c.equalsIgnoreCase(sRecIdA)){
                if(cc.RecId_B__c.equalsIgnoreCase(sRecIdB)){
                    sRes = cc.RecId_Res__c;
                    break;
                }
            }

        }

        //Just in case we don't get a result, we set the value for the most common RecId - "C"
        if( sRes == ''){
            sRes = 'C';
        }

        return sRes;
    }

    public static Boolean isAddressEmpty(Account acc, String addressType) {

        //System.debug(loggingLevel.Debug, '____ [cls AMS_Utils - isAddressEmpty] acc.BillingStreet - ' + acc.BillingStreet);
        //System.debug(loggingLevel.Debug, '____ [cls AMS_Utils - isAddressEmpty] acc.BillingCity - ' + acc.BillingCity);
        //System.debug(loggingLevel.Debug, '____ [cls AMS_Utils - isAddressEmpty] acc.BillingPostalCode - ' + acc.BillingPostalCode);
        //System.debug(loggingLevel.Debug, '____ [cls AMS_Utils - isAddressEmpty] acc.IATA_ISO_Country__c - ' + acc.IATA_ISO_Country__c);
        //System.debug(loggingLevel.Debug, '____ [cls AMS_Utils - isAddressEmpty] acc.Iso_State__c - ' + acc.Iso_State__c);
        //System.debug(loggingLevel.Debug, '____ [cls AMS_Utils - isAddressEmpty] acc.ShippingStreet - ' + acc.ShippingStreet);
        //System.debug(loggingLevel.Debug, '____ [cls AMS_Utils - isAddressEmpty] acc.ShippingCity - ' + acc.ShippingCity);
        //System.debug(loggingLevel.Debug, '____ [cls AMS_Utils - isAddressEmpty] acc.ShippingPostalCode - ' + acc.ShippingPostalCode);
        
        if(addressType.equalsIgnoreCase('Billing')){
            //R3.1 - removed the state validation
            //return ((acc.BillingStreet == null && acc.BillingCity == null && acc.BillingPostalCode == null) || acc.IATA_ISO_Country__c == null || acc.Iso_State__c == null);
            //return ((acc.BillingStreet == null && acc.BillingCity == null && acc.BillingPostalCode == null) || acc.IATA_ISO_Country__c == null );
            return ((acc.BillingStreet == null && acc.BillingCity == null ) || acc.IATA_ISO_Country__c == null );
        }
        if(addressType.equalsIgnoreCase('Shipping')){
            //return ((acc.ShippingStreet == null && acc.ShippingCity == null && acc.ShippingPostalCode == null) );
            return ((acc.ShippingStreet == null && acc.ShippingCity == null) );
        }
        
        return false;   
    }

    //VALID = TRUE; INVALID = FALSE
    public static Boolean isValidState(String state) {
        if(String.isEmpty(state)){
            return false;
        }
        state = state.toLowerCase().trim();
        if(AMS_Utils.iataIsoStates.get(state) == null){
            return false;
        }        
        return true;
    }

    //VALID = TRUE; INVALID = FALSE
    public static Boolean isValidCountry(String country) {
        if(String.isEmpty(country)){
            return false;
        }
        country = country.toLowerCase().trim();
        if(AMS_Utils.iataIsoCountries.get(country) == null){
            return false;
        }        
        return true;
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



    public static List<Account> createAAChangeCodes(List<AMS_OSCAR_JSON.ChangeCode> changeCodes, List<AMS_OSCAR__c> oscars, List<Account> oscarAgencies, Boolean isToUpdateAccounts) {

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

        List<Account> accountsToUpdateList = new List<Account>(accountsToUpdate);

        if (!accountsToUpdate.isEmpty() && (!Trigger.isExecuting || isToUpdateAccounts)) {
            System.debug('The list of Accounts to update is ' + accountsToUpdate.size());
            update accountsToUpdateList;
        }

        if (!aaccToInsert.isEmpty()) {

            System.debug('The list of Change Codes to add is ' + aaccToInsert.size());

            insert aaccToInsert;
        }

        return accountsToUpdateList;

    }

    //Change Code Utils
    private static ChangeCodeStruct createAAChangeCode(AMS_OSCAR_JSON.ChangeCode changeCode, AMS_OSCAR__c oscar, Account oscarAgency, Boolean isActive) {

        Account toReturn = null;

        Id oscarId = null;

        if (oscar != null)
            oscarId = oscar.Id;

        System.debug('Creating a new Agency Applied Change Code for Account ' + oscarAgency.Id + ' with flag active set to ' + isActive);

        String source = UserInfo.getUserType() == 'PowerPartner' ? 'Portal' : 'Internal';

        Agency_Applied_Change_code__c aacNEW = new Agency_Applied_Change_code__c(
            Active__c = isActive
            , Account__c = oscarAgency.Id
            , Change_Code__c = changeCode.name
            , OSCAR__c = oscarId
            , Bulletin_Information__c = changeCode.memoText
            , Reason_Code__c = changeCode.reasonCode
            , Reason_Description__c = changeCode.reasonDesc
            , Source__c = source
        );

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

        if(oscar != null){
            if(aacNEW.Change_Code__c == 'FIN' && new Set<String>{'C','P'}.contains(oscar.Location_Class__c)){
                oscarAgency.Annual_Renewal_Certificates__c = true;
                toReturn = oscarAgency;
            }
        }       

        if(aacNew.Change_Code__c == 'CER'){
            oscarAgency.Annual_Renewal_Certificates__c = true;
            oscarAgency.Certificate_Generated_Current_Year__c = true;
            toReturn = oscarAgency;
        }

        if( aacNEW.Change_Code__c == 'FIN' ){
            
            oscarAgency.Is_AIMS_Account__c = true;
            oscarAgency.Accreditation_Date__c = Date.Today();            
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


    public static void copyDataToAccount(List<AMS_OSCAR__c> oscars) {
        copyDataToAccount(oscars, true);
    }


    //Map data from staging area (AMS Online Accreditation) to account
    public static void copyDataToAccount(List<AMS_OSCAR__c> oscars, Boolean runOwnershipMigration) {

        AMS_AccountTriggerHandler.processMinorChangesValidationFlag = false;

        ID changeRT = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('CHANGE').getRecordTypeId();

        System.debug('Copying Data from Staging to Account');

        List<Account> accountsToUpdate = new List<Account>();
        List<AMS_Pax_Accreditation_Form__c> onlineAccToCreateAccountRole = new List<AMS_Pax_Accreditation_Form__c>();
        Map<Id, Set<Id>> stagingToAccount = new Map<Id, Set<Id>>();
        
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
                                                                    //,'BillingState' => 'Billing_State__c'
                                                                    ,'BillingCity' => 'Branch_Office_City__c'
                                                                    ,'IATA_ISO_Country__c' => 'Branch_Office_Country__c'
                                                                    ,'Iso_State__c' => 'IATA_ISO_State__c'
                                                                    //,'ShippingCountry' => 'Shipping_Country__c'
                                                                    ,'ShippingStreet' => 'Shipping_Street__c'
                                                                    ,'ShippingPostalCode' => 'Shipping_Postal_Code__c'
                                                                    //,'ShippingState' => 'Shipping_State__c'
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
                                                                    ,'IATA_ISO_Shipping_State__c' => 'Shipping_ISO_State__c'
                                                                    ,'Link_agent_name__c' => 'Link_agent_name__c'};

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
                ,IATA_ISO_Billing_State__c, IATA_ISO_Shipping_Country__c, IATA_ISO_Shipping_Country__r.Name, IATA_ISO_Shipping_State__c, IATA_ISO_Shipping_State__r.Name, ISO_State__r.Name,
                Link_agent_name__c
                FROM Account
                WHERE Id IN :oscarAccountIds]);

        Map<Id, AMS_Pax_Accreditation_Form__c> onlineAccreditations = new Map<Id, AMS_Pax_Accreditation_Form__c>([SELECT Account_Name__c, IATACode__c, ISSP_AMS_Legal_Status__c, Short_Name__c, Trade_Name__c, ISSP_AMS_License_No__c, ISSP_AMS_VAT_number__c,
                ISSP_AMS_GDS_with_signed_contract__c, Operation__c, Branch_Office_Country__r.Name, Branch_Office_Street_name_number__c, Branch_Office_Postal_code__c,
                Billing_State__c, Branch_Office_City__c, ISO_Country__c, IATA_ISO_State__c, Shipping_Country__c, Shipping_Street__c, Shipping_Postal_Code__c,
                Shipping_State__c, Shipping_City__c, Branch_Office_Email__c, Website__c, Branch_Office_Phone__c, Branch_Office_FAX__c, ISSP_AMS_Premises_located_at_airport__c,
                Abbreviated_name__c, Abbreviated_address__c, Remittance_frequency__c, Solicitation_Flag__c, VAT_Number_2__c, CASS_Number__c, Location_Class__c, Location_Type__c, Mobile__c, Is_your_firm_handling_Dangerous_Goods__c
                ,Shipping_ISO_Country__c,Shipping_ISO_State__c, Shipping_ISO_Country__r.Name, Shipping_ISO_State__r.Name, IATA_ISO_State__r.Name, Link_agent_name__c
                FROM AMS_Pax_Accreditation_Form__c
                WHERE Id IN :oscarOnlineAccredIds]);

        List<Map<String, String>> configs = AMS_AgencyChangesConfigHelper.getAgencyChangesConfigData();

        for (AMS_OSCAR__c oscar : oscars) {

            Account acc = accounts.get(oscar.Account__c);

            AMS_Pax_Accreditation_Form__c onlineAcc = onlineAccreditations.get(oscar.AMS_Online_Accreditation__c);

            Map<Id, List<AMS_Agencies_relationhip__c>> accountHierarchyRelationships = AMS_HierarchyHelper.getAccountsHierarchies(new Set<Id>{acc.Id});

            if (acc != null && onlineAcc != null) {

                for (String key : fieldsMapping.keySet()) {
                    String value = fieldsMapping.get(key);
                    acc.put(key, onlineAcc.get(value));
                    System.debug(key + ':' + onlineAcc.get(value));
                }

                acc.In_a_Airport__c = (onlineAcc.ISSP_AMS_Premises_located_at_airport__c == 'Yes') ? true : false;
                acc.Company_Type__c = transformCompanyType(onlineAcc.ISSP_AMS_Legal_Status__c);
                acc.GDS__c = transformGDS(onlineAcc.ISSP_AMS_GDS_with_signed_contract__c);
                acc.BillingCountry = onlineAcc.Branch_Office_Country__r.Name;
                acc.ShippingCountry = onlineAcc.Shipping_ISO_Country__r.Name;
                acc.ShippingState = onlineAcc.Shipping_ISO_State__r.Name;
                acc.BillingState = onlineAcc.IATA_ISO_State__r.Name;
                onlineAccToCreateAccountRole.add(onlineAcc);

                accountsToUpdate.add(acc);
                stagingToAccount.put(onlineAcc.Id, new Set<Id>{oscar.Account__c});

            }

        }

        Savepoint sp = Database.setSavepoint();

        try {

            if (!accountsToUpdate.isEmpty())
                update accountsToUpdate;

            if(!stagingToAccount.isEmpty() && runOwnershipMigration)
                AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(stagingToAccount, true);

        } catch (Exception ex) {
            System.debug('Exception: ' + ex);
            Database.rollback(sp);
            throw ex;
        }
        
    }

    private static boolean isEmptyAccountHierarchyRelationshipsMap(Map<Id, List<AMS_Agencies_relationhip__c>> accountHierarchyRelationships){

        if(accountHierarchyRelationships.isEmpty())
            return true;

        if(accountHierarchyRelationships.values().isEmpty())
            return true;

        for(List<AMS_Agencies_relationhip__c> agency:accountHierarchyRelationships.values()){
            if(!agency.isEmpty())
                return false;
        }

        return true;
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
                                                                    //,'BillingState' => 'Billing_State__c'
                                                                    ,'BillingCity' => 'Branch_Office_City__c'
                                                                    ,'IATA_ISO_Country__c' => 'Branch_Office_Country__c'
                                                                    ,'Iso_State__c' => 'IATA_ISO_State__c'
                                                                    //,'ShippingCountry' => 'Shipping_Country__c'
                                                                    ,'ShippingStreet' => 'Shipping_Street__c'
                                                                    ,'ShippingPostalCode' => 'Shipping_Postal_Code__c'
                                                                    //,'ShippingState' => 'Shipping_State__c'
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
                                                                    ,'IATA_ISO_Shipping_State__c' => 'Shipping_ISO_State__c'
                                                                    ,'Link_agent_name__c' => 'Link_agent_name__c'};

        if (fieldsToMigrate != null && oscarOnlineAccreditation != null) {
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
                if (fieldsToMigrate.contains('Shipping_ISO_Country__c'))
                    accountFieldNewValue.put('ShippingCountry', oscarOnlineAccreditation.Shipping_ISO_Country__r.Name);
                if (fieldsToMigrate.contains('Shipping_ISO_State__c'))
                    accountFieldNewValue.put('ShippingState', oscarOnlineAccreditation.Shipping_ISO_State__r.Name);
                if (fieldsToMigrate.contains('IATA_ISO_State__c'))
                    accountFieldNewValue.put('BillingState', oscarOnlineAccreditation.IATA_ISO_State__r.Name);
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
                        
//Map data from staging area (AMS Online Accreditation) to account
    public static AMS_Pax_Accreditation_Form__c CopyDataFromAccountToStaging(String typesOfChange, Account account, AMS_Pax_Accreditation_Form__c onlineAccreditation) {
                        
        System.debug('AGENCY CHANGES: Types of Change (' + typesOfChange + ') ');

        Set<String> fieldsToMigrate = AMS_AgencyChangesConfigHelper.getFieldsToMigrate(typesOfChange);
                     
        System.debug('AGENCY CHANGES: fields to migrate (' + fieldsToMigrate + ') for accounts: ' + account);
                           
        Map<String, String> fieldsMapping = new Map<String, String> {'Name' => 'Account_Name__c'
                                                                    ,'IATACode__c' => 'IATACode__c'
                                                                    ,'Short_Name__c' => 'Short_Name__c'
                                                                    ,'TradeName__c' => 'Trade_Name__c'
                                                                    ,'License_Number__c' => 'ISSP_AMS_License_No__c'
                                                                    ,'VAT_Number__c' => 'ISSP_AMS_VAT_number__c'
                                                                    ,'BillingStreet' => 'Branch_Office_Street_name_number__c'
                                                                    ,'Website' => 'Website__c'
                                                                    ,'BillingPostalCode' => 'Branch_Office_Postal_code__c'
                                                                    ,'BillingCity' => 'Branch_Office_City__c'
                                                                    ,'IATA_ISO_Country__c' => 'Branch_Office_Country__c'
                                                                    ,'Iso_State__c' => 'IATA_ISO_State__c'
                                                                    ,'ShippingStreet' => 'Shipping_Street__c'
                                                                    ,'ShippingPostalCode' => 'Shipping_Postal_Code__c'
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
                        
        if (fieldsToMigrate != null && onlineAccreditation != null) {
                Map<String, Object> onlineAccreditationFieldNewValue = new Map<String,Object>();
                            
                for (String key : fieldsMapping.keySet()) {
                    String value = fieldsMapping.get(key);
                    if (fieldsToMigrate.contains(value)) {

                        onlineAccreditationFieldNewValue.put(value, account.get(key));
                        System.debug('copying stuff from target agency ' + value + ':' + account.get(key));
                    }
                    }

                //fields that require transformation
                if (fieldsToMigrate.contains('ISSP_AMS_Premises_located_at_airport__c'))
                    onlineAccreditationFieldNewValue.put('ISSP_AMS_Premises_located_at_airport__c', (account.In_a_Airport__c == true) ? 'Yes' : 'No');
                if (fieldsToMigrate.contains('ISSP_AMS_Legal_Status__c'))
                    onlineAccreditationFieldNewValue.put('ISSP_AMS_Legal_Status__c', account.Company_Type__c);
                if (fieldsToMigrate.contains('ISSP_AMS_GDS_with_signed_contract__c'))
                    onlineAccreditationFieldNewValue.put('ISSP_AMS_GDS_with_signed_contract__c', account.GDS__c);


                for(String accredFieldApiName: onlineAccreditationFieldNewValue.keySet())
                {
                    
                    Schema.SObjectField field = Schema.SObjectType.AMS_Pax_Accreditation_Form__c.fields.getMap().get(accredFieldApiName);
                    Schema.DisplayType fldType = field.getDescribe().getType();
                        
                    system.debug('Field value to migrate to online accreditation: ' + accredFieldApiName);
                    system.debug('Field Type to migrate to online accreditation: ' + fldType);

                    onlineAccreditation.put(accredFieldApiName, onlineAccreditationFieldNewValue.get(accredFieldApiName));
                }

        }

        system.debug('Online Accreditation fields populated: ' + onlineAccreditation);

        return onlineAccreditation;

}

//Deprecated necessary rework because status no longer changes only after change code generation
//get Inspections from oscar
    /*public static void UpdateInspectionsFromOscar(List<AMS_OSCAR__c> oscars){

        //query the the AMS Inspections to update the Account
        List<AMS_Inspection__c> lsInsToUpdate = new List<AMS_Inspection__c>();

        //Update Account Id on Inspections
        for(AMS_Inspection__c amsIns : [SELECT Id, Account__c,OSCAR__c,OSCAR__r.Account__c, Date_Organisation_Status_attained__c,Last_synchronization__c,Accreditation_Endorsement_Status_code__c FROM AMS_Inspection__c WHERE OSCAR__c IN :oscars])
        {

            amsIns.Account__c = amsIns.OSCAR__r.Account__c;
            
            amsIns.Date_Organisation_Status_attained__c = (amsIns.Date_Organisation_Status_attained__c == null) ? system.today() : amsIns.Date_Organisation_Status_attained__c;
            amsIns.Accreditation_Endorsement_Status_code__c = '9';
            amsIns.Last_synchronization__c = system.today();
            
            lsInsToUpdate.add(amsIns);
        }
        
        try {
            update lsInsToUpdate;
        } catch (DmlException e) {
            system.debug('Exception updating Inspection: ' + e.getMessage());
        }

    }*/

    public static List<AMS_Inspection__c> modifyInspectionStatus(List<AMS_Inspection__c> inspections, String statusToApply){

        List<AMS_Inspection__c> modifiedInspections = new List<AMS_Inspection__c>();

        if(inspections != null)
            for(AMS_Inspection__c insp: inspections)
            {

                insp.Account__c = insp.OSCAR__r.Account__c;
                
                insp.Date_Organisation_Status_attained__c = (insp.Date_Organisation_Status_attained__c == null) ? system.today() : insp.Date_Organisation_Status_attained__c;
                insp.Accreditation_Endorsement_Status_code__c = statusToApply;
                insp.Last_synchronization__c = system.today();
                
                modifiedInspections.add(insp);
            }

        return modifiedInspections;

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
    String searchString2 = '##';
    System.debug('EXCEPTION!! ' + ex.getMessage() + '\n ' + ex.getStackTraceString());
    if (ex.getMessage().containsIgnoreCase(searchString)) {
        System.debug(ex.getMessage().indexOfIgnoreCase(searchString));
        Integer startOfErrorMessage = ex.getMessage().indexOfIgnoreCase(searchString) + searchString.length() + 2;
        errorString = ex.getMessage().substring(startOfErrorMessage, ex.getMessage().length());
        errorString = errorString.substringBefore(': [');
    }else if(ex.getMessage().containsIgnoreCase(searchString2)){
        System.debug(ex.getMessage().indexOfIgnoreCase(searchString2));
        Integer startOfErrorMessage = ex.getMessage().indexOfIgnoreCase(searchString2) + searchString2.length();
        errorString = ex.getMessage().substring(startOfErrorMessage, ex.getMessage().length());
        errorString = errorString.substringBefore('##');
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

//Get Change Code memo Text (All this configs should be passed for a Custom Setting)
public static String getChangeCodeMemoText(String process,String changeCodeId) {

    String memoText = 'New application';

    if (process == AMS_Utils.new_HO || process == AMS_Utils.new_BR_ABROAD)

        memoText = 'New application - Head Office';
    else if (process == AMS_Utils.new_BR)
        memoText = 'New application - Branch';
    else if (process == AMS_Utils.new_TIDS)
        memoText = 'New application - TIDS';
    else if (process == AMS_Utils.new_SA)
        memoText = 'New application - SA';
    else if (process == AMS_Utils.new_GSSA)
        memoText = 'New application - GSSA';
    else if (process == AMS_Utils.new_GSA_BSP || process == AMS_Utils.new_GSA)
        memoText = 'New application - GSA';
    else if (process == AMS_Utils.new_AHA_BSP || process == AMS_Utils.new_AHA)
        memoText = 'New application - AHA';
 
    return memoText + ' ' + getStatusDescFromChangeCode(changeCodeId);
}


// Converts a base64 string into a list of integers representing the encoded bytes
public static List<Integer> B64ToBytes (String sIn) {
    Map<Integer,Integer> base64 = new Map<Integer,Integer>{65=>0,66=>1,67=>2,68=>3,69=>4,70=>5,71=>6,72=>7,73=>8,74=>9,75=>10,76=>11,77=>12,78=>13,79=>14,80=>15,81=>16,82=>17,83=>18,84=>19,85=>20,86=>21,87=>22,88=>23,89=>24,90=>25
                                                           ,97=>26,98=>27,99=>28,100=>29,101=>30,102=>31,103=>32,104=>33,105=>34,106=>35,107=>36,108=>37,109=>38,110=>39,111=>40,112=>41,113=>42,114=>43,115=>44,116=>45,117=>46,118=>47,119=>48,120=>49,121=>50,122=>51
                                                           ,48=>52,49=>53,50=>54,51=>55,52=>56,53=>57,54=>58,55=>59,56=>60,57=>61,43=>62,47=>63};

    List<Integer> lstOut = new List<Integer>();
    if ( sIn == null || sIn == '' ) return lstOut;
    
    sIn += '='.repeat( 4 - Math.mod( sIn.length(), 4) );

    for ( Integer idx=0; idx < sIn.length(); idx += 4 ) {
        if ( base64.get(sIn.charAt(idx+1)) != null ) lstOut.add( (base64.get(sIn.charAt(idx)) << 2) | (base64.get(sIn.charAt(idx+1)) >>> 4) );
        if ( base64.get(sIn.charAt(idx+2)) != null ) lstOut.add( ((base64.get(sIn.charAt(idx+1)) & 15)<<4) | (base64.get(sIn.charAt(idx+2)) >>> 2) );
        if ( base64.get(sIn.charAt(idx+3)) != null ) lstOut.add( ((base64.get(sIn.charAt(idx+2)) & 3)<<6) | base64.get(sIn.charAt(idx+3)) );
    }

    //System.Debug('B64ToBytes: [' + sIn + '] = ' + lstOut);
    return lstOut;
}//B64ToBytes
public static List<Integer> BlobToBytes (Blob input) {
    return B64ToBytes( EncodingUtil.base64Encode(input) );
}//BlobToBytes

// Converts a base64 string into a list of integers indicating at which position the bits are on
public static List<Integer> cnvBits (String b64Str) {
    List<Integer> lstOut = new List<Integer>();
    if ( b64Str == null || b64Str == '' ) return lstOut;

    List<Integer> lstBytes = B64ToBytes(b64Str);

    Integer i, b, v;
    for ( i = 0; i < lstBytes.size(); i++ ) {
        v = lstBytes[i];
        //System.debug ( 'i['+i+'] v['+v+']' );
        for ( b = 1; b <= 8; b++ ) {
            //System.debug ( 'i['+i+'] b['+b+'] v['+v+'] = ['+(v & 128)+']' );
            if ( ( v & 128 ) == 128 ) lstOut.add( (i*8) + b );
            v <<= 1;
        }
    }

    //System.Debug('cnvBits: [' + b64Str + '] = ' + lstOut);
    return lstOut;
}//cnvBits

public class TPicklistEntry{
    public string active {get;set;}
    public string defaultValue {get;set;}
    public string label {get;set;}
    public string value {get;set;}
    public string validFor {get;set;}
    public TPicklistEntry(){
    }
}//TPicklistEntry
 

/**
Process Dependent Picklists (Apex workaround)
*/
public static Map<String,List<String>> GetDependentOptions(String pObjName, String pControllingFieldName, String pDependentFieldName) {
    Map<String,List<String>> mapResults = new Map<String,List<String>>();

    //verify/get object schema
    Schema.SObjectType pType = Schema.getGlobalDescribe().get(pObjName);
    if ( pType == null ) return mapResults;
    Map<String, Schema.SObjectField> objFieldMap = pType.getDescribe().fields.getMap();

    //verify field names
    if (!objFieldMap.containsKey(pControllingFieldName) || !objFieldMap.containsKey(pDependentFieldName)) return mapResults;     

    //get the control & dependent values   
    List<Schema.PicklistEntry> ctrl_ple = objFieldMap.get(pControllingFieldName).getDescribe().getPicklistValues();
    List<Schema.PicklistEntry> dep_ple = objFieldMap.get(pDependentFieldName).getDescribe().getPicklistValues();

    //clear heap
    objFieldMap = null;

    //initialize results mapping
    for(Integer pControllingIndex=0; pControllingIndex<ctrl_ple.size(); pControllingIndex++){           
        mapResults.put( ctrl_ple[pControllingIndex].getLabel(), new List<String>());
    }
    //cater for null and empty
    mapResults.put('', new List<String>());
    mapResults.put(null, new List<String>());

    //serialize dep entries        
    List<TPicklistEntry> objDS_Entries = new List<TPicklistEntry>();
    objDS_Entries = (List<TPicklistEntry>)JSON.deserialize(JSON.serialize(dep_ple), List<TPicklistEntry>.class);

    List<Integer> validIndexes;
    for (TPicklistEntry objDepPLE : objDS_Entries){

        validIndexes = cnvBits(objDepPLE.validFor);
        //System.Debug('cnvBits: [' + objDepPLE.label + '] = ' + validIndexes);

        for (Integer validIndex : validIndexes){                
            mapResults.get( ctrl_ple[validIndex-1].getLabel() ).add( objDepPLE.label );
        }
    }

    //clear heap
    objDS_Entries = null;

    return mapResults;
}

//used to fill the Type_of_Customer__c field on the Oscar Comunication Case
public static String fetchTypeOfCustomer (String locationType , String category) {

    if(locationType == null)
        return null;

    if(locationType == 'SA')
        return 'IATA Travel Agent';

    if(category == null)
        return null;

    return categoryCustomerMap.get(category);

}

    public static final Date knownSunday = date.newInstance(2012, 7, 1);
    
    private static Map<String, Set<Integer>> weekendDaysPerBusinessHours{
        get{
            if(weekendDaysPerBusinessHours == null) weekendDaysPerBusinessHours = new Map<String, Set<Integer>>();
            return weekendDaysPerBusinessHours;
        }
        set;
    }

    private static Set<Integer> addBusinessHours(String businessHours){
        String findBusinessHours = (businessHours == null ? 'Default' : businessHours);

        if(!weekendDaysPerBusinessHours.containsKey(findBusinessHours)){
            List<BusinessHours> hs = [SELECT Id, Name, isDefault, isActive, SundayStartTime, MondayStartTime, TuesdayStartTime, WednesdayStartTime, ThursdayStartTime, FridayStartTime, SaturdayStartTime FROM BusinessHours WHERE isActive = true AND (Name = :findBusinessHours OR isDefault = true)];

            Set<Integer> weekendDays = new Set<Integer>();
            if(hs.isEmpty()){
                System.debug(loggingLevel.ERROR, '____ [cls AMS_Utils - addBusinessHours] ************ no businessHours found -- using Sunday and Saturday ');
                weekendDays.add(0);
                weekendDays.add(6);
                weekendDaysPerBusinessHours.put(findBusinessHours, weekendDays);
            }else{
                for(BusinessHours h : hs){
                    weekendDays = new Set<Integer>();
                    if(h.SundayStartTime == null) weekendDays.add(0);
                    if(h.MondayStartTime == null) weekendDays.add(1);
                    if(h.TuesdayStartTime == null) weekendDays.add(2);
                    if(h.WednesdayStartTime == null) weekendDays.add(3);
                    if(h.ThursdayStartTime == null) weekendDays.add(4);
                    if(h.FridayStartTime == null) weekendDays.add(5);
                    if(h.SaturdayStartTime == null) weekendDays.add(6);
                    
                    if(h.Name == findBusinessHours) weekendDaysPerBusinessHours.put(h.Name, weekendDays);
                    else if(h.isDefault) weekendDaysPerBusinessHours.put('Default', weekendDays);
                }
                //if we went through all business hours and didn't find the desired one, copy the default
                if(!weekendDaysPerBusinessHours.containsKey(findBusinessHours)){
                System.debug(loggingLevel.ERROR, '____ [cls AMS_Utils - addBusinessHours] ************ no businessHours found for region -- copying default one ');
                    weekendDaysPerBusinessHours.put(findBusinessHours, weekendDaysPerBusinessHours.get('Default'));
                }
            }           
        }

        return weekendDaysPerBusinessHours.get(findBusinessHours);
    }
    

    public static Boolean IsWeekendDay(Date dateParam, String businessHours){
        return IsWeekendDay(DateTime.newInstance(dateParam, Time.newInstance(0, 0, 0, 0)), businessHours);
    }

    public static Boolean IsWeekendDay(Datetime dateParam, String businessHours){
       //Integer dayOfWeek  = Integer.valueOf(dateParam.format('u'));
       //Integer dayOfWeek = dateParam.date().toStartOfWeek().daysBetween(dateParam.date());
       Integer dayOfWeek = Math.mod(knownSunday.daysBetween(dateParam.date()), 7);

       System.debug(loggingLevel.Debug, '____ [cls AMS_Utils - AddBusinessDays] dateParam - ' + dateParam);
       System.debug(loggingLevel.Debug, '____ [cls AMS_Utils - IsWeekendDay] dayOfWeek - ' + dayOfWeek);

       Set<Integer> weekendDays = new Set<Integer>();
       if(weekendDaysPerBusinessHours.containsKey(businessHours)) weekendDays = weekendDaysPerBusinessHours.get(businessHours);
       else weekendDays = addBusinessHours(businessHours);

       System.debug(loggingLevel.Debug, '____ [cls AMS_Utils - IsWeekendDay] weekendDays - ' + weekendDays);

       return weekendDays.contains(dayOfWeek);
    }

    public static Date AddBusinessDays(Date d, Integer businessDaysToAdd, String businessHours){
        return AddBusinessDays(Datetime.newInstance(d, Time.newInstance(0, 0, 0, 0)), businessDaysToAdd, businessHours).date();
    }

    public static Datetime AddBusinessDays(Datetime d, Integer businessDaysToAdd, String businessHours){
        System.debug(loggingLevel.Debug, '____ [cls AMS_Utils - AddBusinessDays] d - ' + d);
        System.debug(loggingLevel.Debug, '____ [cls AMS_Utils - AddBusinessDays] businessHours - ' + businessHours);

        Datetime finalDate = d;

        //Add or decrease in businessDaysToAdd days 
        Integer direction = businessDaysToAdd < 0 ? -1 : 1;

        while(businessDaysToAdd != 0){
            finalDate = finalDate.AddDays(direction);
            if (!isWeekendDay(finalDate, businessHours)) businessDaysToAdd -= direction;
        }

        System.debug(loggingLevel.Debug, '____ [cls AMS_Utils - AddBusinessDays] finalDate - ' + finalDate);
        return finalDate;
    } 

    public static Date lastDayOfMonth(Date dateField) {
        return dateField.addMonths(1).toStartOfMonth().addDays(-1);
    }

}