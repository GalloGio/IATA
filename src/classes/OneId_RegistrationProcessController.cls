public without sharing class OneId_RegistrationProcessController {
    
    public static Boolean isNewAcc = false;   
    public static Boolean createBranch = false;
    public static String languageString = 'English';
    public static Boolean isAlreadyContact = false;

    @AuraEnabled
    public static String getHostURL(){
        return OneIdUtils.getOrgUrl();
    }

    @AuraEnabled
    public static String getCommunityName(){
        return OneIdUtils.getCommunityUrlName();
    }
    
    @AuraEnabled
    public static List<Account> getAccountsBySectorAndCategory(String sector, String cat, String country, String userInput) {
        String recordTypesSet = '';

        if(sector == 'Airline'){
            recordTypesSet = '(\'IATA_Airline\',\'Operator\')';
        }
        else if(sector == 'Travel Agent'){
            if(cat == 'IATA Passenger Sales Agent'){
                recordTypesSet = '(\'IATA_Agency\')';
            }
            else if(cat == 'Non IATA Travel Agent'){
                recordTypesSet = '(\'Non_IATA_Agency\')';
            }
        }
        else if(sector == 'Airline Supplier'){
            recordTypesSet = '(\'Others\')';
        }        

        if(recordTypesSet == ''){
            System.debug('NDCMM - invalid sector-category combination : "' + sector + '" - "' + cat + '"');
            return new List<Account>();
        }

        if(cat == 'Global Distribution System'){
            cat = 'GDS';
        }


        String queryStr = 'SELECT Id, IATACode__c, Airline_designator__c, Field_Head_Office__c, Name, BillingStreet, BillingCity, BillingCountry FROM Account WHERE ';
        queryStr += ' RecordType.DeveloperName in ' + recordTypesSet;
        queryStr += ' AND Sector__c = \'' + sector + '\'';
        queryStr += ' AND Category__c = \'' + cat + '\'';
        queryStr += ' AND IATA_ISO_Country__c = \'' + country + '\'';
        queryStr += ' AND Name like \'%' + userInput + '%\'';
        system.debug(queryStr);
        list<Account> accs = Database.query(queryStr);

        system.debug(accs);

        return accs;
    }


    @AuraEnabled
    public static String findLocation(String ipAddress){

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://ipinfo.io/' + ipAddress + '/json?token=' + ISSP_CS__c.getInstance('ipinfo_token').Value__c);
        req.setMethod('GET');
        req.setTimeout(2000);
        HttpResponse res;
        
        try{
            res = new Http().send(req);
            Map<String, String> response = (Map<String, String>)JSON.deserialize(res.getBody(), Map<String, String>.class);
            return response.get('country');

        }catch(Exception e){
            System.debug('Exception findLocation LightningRegistrationProcess...' + e);
            return e.getMessage();
        }
    }    

    @AuraEnabled
    public static UserInformation getUserInformation(String serviceName){
        UserInformation userInformation = new UserInformation();
        Integer guestUser = [SELECT count() FROM User WHERE Name = 'identity Site Guest User' AND Id =: UserInfo.getUserId()];

        userInformation.isGuest = guestUser > 0;

        // This part has to be made generic, using the serviceName parameter
        if(!userInformation.isGuest && serviceName == 'FRED'){
            Integer fredAccess = [SELECT count() FROM PermissionSetAssignment WHERE AssigneeId =: UserInfo.getUserId() AND PermissionSet.Name = 'FRED_SSO'];
            
            userInformation.isServiceUser = fredAccess > 0;

            if(!userInformation.isServiceUser){
                User usr = [SELECT AccountId FROM User where Id =: UserInfo.getUserId()];

                system.debug('DB RITS guestUser' + guestUser);
                system.debug('DB RITS ' + usr.AccountId);
                Account acc = [SELECT RecordTypeId, fredp_aircraftoperator_eligibility__c, RecordType.DeveloperName FROM Account WHERE Id =: usr.AccountId];

        
                if((acc.RecordType.DeveloperName == 'IATA_Airline' ||  acc.RecordType.DeveloperName == 'Operator') && acc.fredp_aircraftoperator_eligibility__c){
                    userInformation.isServiceEligible = true;
                }
                else if(acc.RecordType.DeveloperName == 'ICAO_Member_State' || acc.RecordType.DeveloperName == 'Verifiers'){
                    userInformation.isServiceEligible = true;
                }
                else{
                    userInformation.isServiceEligible = false;
                }
            }
        }
        // This part has to be made generic, using the serviceName parameter
        if(!userInformation.isGuest && serviceName == 'NDCMM'){
            User usr = [SELECT ContactId, AccountId 
                        FROM User 
                        WHERE Id =: UserInfo.getUserId()];
            getNDCMMUserInformation(userInformation, usr.ContactId, usr.AccountId);
        }
        return userInformation;
    }

        private static void getNDCMMUserInformation(UserInformation userInformation, Id contactId, Id accountId){
        // Step 1 : check if user requested access to NDC Matchmaker Service
        // Step 1.1 : Retrieve the NDC Matchmaker Portal Service Id
        /*One_Id_Service_Provider_Config__c oneIdService = [SELECT Portal_Service__c 
                                                          FROM One_Id_Service_Provider_Config__c 
                                                          WHERE Service_Provider_Name__c = 'NDCMM' 
                                                          AND RecordType.DeveloperName = 'Service_Provider' LIMIT 1];*/      

        // Step 1.2 : Retrieve the Portal Service Access record
        /*List<Portal_Application_Right__c> portalApplicationRights = [SELECT Right__c, Access_Pending_Detail__c 
                                                                     FROM Portal_Application_Right__c 
                                                                     WHERE Portal_Application__c =: oneIdService.Portal_Service__c 
                                                                     AND Contact__c =: contactId];*/     

        //userInformation.isServiceUser = !portalApplicationRights.isEmpty(); 

        // if access has already been requested yet, we can stop here
        if(userInformation.isServiceUser){
            //Don't return now because we need contact info to pass to email component
            //return userInformation;
        }       

        Account acc = [SELECT Name, Sector__c, Category__c, RecordType.DeveloperName FROM Account WHERE Id =: accountId];      

        // Step 2 : check if user's Account is eligible
        userInformation.isServiceEligible = isNDCMMEligible(acc);       

        // if account is not eligible, we can stop here
        if(!userInformation.isServiceEligible){
            return;
        }        

        // Step 3 : set Contact and Account
        userInformation.con = [SELECT Id, Email, Salutation, FirstName, LastName, Title, Membership_Function__c, Phone, MobilePhone, Fax
                               FROM Contact 
                               WHERE Id =: contactId];      

        userInformation.acc = acc;      
    }


    public class UserInformation {
        @AuraEnabled
        Boolean isGuest {get; set;}
        @AuraEnabled
        Boolean isEmailAddressAvailable {get; set;}
        @AuraEnabled
        Boolean isContactInserted {get; set;}
        @AuraEnabled
        Boolean isServiceUser {get; set;}
        @AuraEnabled
        Boolean isServiceEligible {get; set;}
        @AuraEnabled
        Contact con {get;set;}
        @AuraEnabled
        Account acc {get;set;}
        @AuraEnabled
        Boolean accessRequested {get; set;}
    }

    @AuraEnabled
    public static UserInformation getUserInformationFromEmail(String email, String serviceName) {
        UserInformation userInformation = new UserInformation();
        List<Contact> conList = returnExistingContact(email); // Since the email is unique we didn't expect to receive more than one email
        userInformation = getUserInformation(serviceName);
        userInformation.isEmailAddressAvailable = checkIsUsernameIsAvailableInGlobalSalesforce(email, conList);

        System.Debug('Information ::: Contact List : ' + conList + ' isEmailAddressAvailable ? ' + userInformation.isEmailAddressAvailable + ' Service Name : ' + serviceName);

        userInformation.isContactInserted = conList.size() > 0;
        //setting default value. If contact and email don't exist, user will be eligible
        userInformation.isServiceEligible = !(userInformation.isContactInserted && userInformation.isEmailAddressAvailable);       

        if((!conList.isEmpty()) && userInformation.isEmailAddressAvailable){
            //String UID = Comm_User_Helper.NewGuid();
            //Id userCreated = Comm_User_Helper.createNewUser(conList.get(0), '' , serviceName , (conList.get(0).Preferred_Language__c != null ?  conList.get(0).Preferred_Language__c : languageString) , false, false);
            //Boolean userCreated = Comm_User_Helper.createNewUser(conList.get(0), '' , serviceName , (conList.get(0).Preferred_Language__c != null ?  conList.get(0).Preferred_Language__c : languageString) , false, false) != null ? TRUE : FALSE;

            if(serviceName != 'FRED' && serviceName != 'NDCMM'){
                isAlreadyContact = true;
                Boolean userCreated = registration(returnRelatedAcc(conList.get(0).AccountId), conList.get(0), serviceName);          

                if(userCreated == true){
                    userInformation.isContactInserted = true;
                    userInformation.isServiceEligible = true;
                    userInformation.con = conList.get(0);
                    System.Debug('User CREATED with success!');
                }
                else {
                    userInformation.isContactInserted = false;
                    System.Debug('User NOT created!');
                }
            }
            else if(serviceName == 'FRED'){
                userInformation.isContactInserted = true;
                userInformation.con = conList.get(0);
                Account acc = [SELECT Name, RecordTypeId, RecordType.Name, fredp_aircraftoperator_eligibility__c, RecordType.DeveloperName FROM Account WHERE Id =: conList.get(0).Account.Id];

                if((acc.RecordType.DeveloperName == 'IATA_Airline' ||  acc.RecordType.DeveloperName == 'Operator') && acc.fredp_aircraftoperator_eligibility__c){
                    userInformation.isServiceEligible = true;
                }
                else if(acc.RecordType.DeveloperName == 'ICAO_Member_State' || acc.RecordType.DeveloperName == 'Verifiers'){
                    userInformation.isServiceEligible = true;
                }
                else{
                    userInformation.isServiceEligible = false;
                }                
                userInformation.acc = acc;                
            }
            else{
                userInformation.isContactInserted = true;
                userInformation.con = conList.get(0);
                userInformation.acc = [SELECT Name, Sector__c, Category__c, RecordType.DeveloperName FROM Account WHERE Id =: conList.get(0).Account.Id];

                getNDCMMUserInformation(userInformation, userInformation.con.Id, userInformation.acc.Id);
            }
        }

        
        if(!userInformation.isEmailAddressAvailable){
            // Retrieve existing user information
            List<User> usrs = [SELECT Id, ContactId, AccountId FROM User where Email =: email];
            if(!usrs.isEmpty()){
                User usr = usrs[0];
                Account acc = [SELECT RecordTypeId, fredp_aircraftoperator_eligibility__c, RecordType.DeveloperName FROM Account WHERE Id =: usr.AccountId];
    
                // This part has to be made generic, using the serviceName parameter
                if(serviceName == 'FRED'){
                    Integer fredAccess = [SELECT count() FROM PermissionSetAssignment WHERE AssigneeId =: usr.Id AND PermissionSet.Name = 'FRED_SSO'];
                    
                    userInformation.isServiceUser = fredAccess > 0;
                    
                    if(!userInformation.isServiceUser){
                        if((acc.RecordType.DeveloperName == 'IATA_Airline' ||  acc.RecordType.DeveloperName == 'Operator') && acc.fredp_aircraftoperator_eligibility__c){
                            userInformation.isServiceEligible = true;
                        }
                        else if(acc.RecordType.DeveloperName == 'ICAO_Member_State' || acc.RecordType.DeveloperName == 'Verifiers'){
                            userInformation.isServiceEligible = true;
                        }
                        else{
                            userInformation.isServiceEligible = false;
                        }
                    }
                }
                if(serviceName == 'NDCMM'){
                    getNDCMMUserInformation(userInformation, usrs[0].ContactId, usrs[0].AccountId);
                }
            }
            userInformation.isContactInserted = false;
        }

        System.Debug('Retrieving user information .... userInformation : ' + userInformation);
        return userInformation;            
    }

        private static Boolean isNDCMMEligible(Account acc){
        Boolean isEligible =  (acc.Sector__c == 'Airline' 
                               && (acc.RecordType.DeveloperName == 'IATA_Airline' || acc.RecordType.DeveloperName == 'Operator'))
            || (acc.Sector__c == 'Travel Agent'
                && ((acc.Category__c == 'IATA Passenger Sales Agent'&& acc.RecordType.DeveloperName == 'IATA_Agency') || (acc.Category__c == 'Non IATA Travel Agent' && acc.RecordType.DeveloperName == 'Non_IATA_Agency')))
            || (acc.Sector__c == 'Airline Supplier' 
                && (acc.Category__c == 'GDS' || acc.Category__c == 'Content Aggreagator')
                && acc.RecordType.DeveloperName == 'Others');
        return isEligible;
    }


    @AuraEnabled
    public static boolean checkIsUsernameIsAvailableInGlobalSalesforce(String email) {
        // Method to test if another user existin in all SF instances to avoid having an error at the end of the process
        Savepoint sp = Database.setSavepoint();

        try {
            User testingUser = new User(LastName = 'DUMMY',
                 FirstName='DUMMY',
                 Alias = 'DUMMY',
                 CommunityNickname = 'DUMMY',
                 Email = email,
                 Username = ISSP_Utilities.buildPortalUserName(email), //myEmail@company.com because myEmail.company.com@partner.iata.org
                 ProfileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal (Partner)' LIMIT 1].Id,
                 ContactId = [SELECT Id FROM Contact WHERE Id NOT IN (SELECT ContactId FROM User) LIMIT 1].Id,
                 TimeZoneSidKey = 'GMT',
                 LanguageLocaleKey = 'en_US',
                 EmailEncodingKey = 'UTF-8',
                 LocaleSidKey = 'en_US',
                 License_Cost_center__c = 'ISF005CH01'
            );
            system.debug(testingUser);
            insert testingUser;

            // Rollback to avoid creation of the user
            Database.rollback(sp);
            return true;

        } catch(Exception e) {
            System.debug(loggingLevel.ERROR, '____ [cls OneId_RegistrationProcessControllere - checkIsUsernameIsAvailableInGlobalSalesforce] e.getMessage() - ' + e.getMessage());
            Database.rollback(sp);
            return false;
        }
    }
    
    @AuraEnabled
    public static boolean checkIsUsernameIsAvailableInGlobalSalesforce(String email, List<Contact> conList) {
        // Method to test if another user existin in all SF instances to avoid having an error at the end of the process
        Savepoint sp = Database.setSavepoint();

        try {
            User testingUser = new User(LastName = 'DUMMY',
                 FirstName='DUMMY',
                 Alias = 'DUMMY',
                 CommunityNickname = 'DUMMY',
                 Email = email,
                 Username = ISSP_Utilities.buildPortalUserName(email), //myEmail@company.com because myEmail.company.com@partner.iata.org
                 ProfileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal (Partner)' LIMIT 1].Id,
                 ContactId = !conlist.isEmpty() ? conList.get(0).Id : [SELECT Id FROM Contact WHERE Id NOT IN (SELECT ContactId FROM User) LIMIT 1].Id,
                 TimeZoneSidKey = 'GMT',
                 LanguageLocaleKey = 'en_US',
                 EmailEncodingKey = 'UTF-8',
                 LocaleSidKey = 'en_US',
                 License_Cost_center__c = 'ISF005CH01'
            );
            system.debug(testingUser);
            insert testingUser;

            // Rollback to avoid creation of the user
            Database.rollback(sp);
            return true;

        } catch(Exception e) {
            System.debug(loggingLevel.ERROR, '____ [cls OneId_RegistrationProcessControllere - checkIsUsernameIsAvailableInGlobalSalesforce] e.getMessage() - ' + e.getMessage());
            Database.rollback(sp);
            return false;
        }
    }

    @AuraEnabled
    public static List<Contact> returnExistingContact(String email) {        

        // Method to search contact that already exists in SALESFORCE
        List<Contact> conList = [SELECT id, Preferred_Language__c, Salutation, FirstName, LastName, Email, Account.Id, Account.Sector__c, RecordTypeId, ISO_Country__c, IATA_ISO_Shipping_Country__c, Primary_Contact__c, User_Portal_Status__c, Status__c, BSP_CASS_Payment_contact__c, Invoicing_Contact__c, Title, Phone, MobilePhone, Fax, Membership_Function__c FROM Contact WHERE Email =: email];

        return conList;

    }

    public static Account returnRelatedAcc(Id accID){
        return [SELECT id, Name, ParentId, Ownerid, Recordtypeid, Category__c, Category_Other_Value__c, BillingCountry, IATA_ISO_Country__c, IATA_ISO_Shipping_Country__c, Sector__c, Reason_for_creation__c FROM Account WHERE ID =: accID];
    }


    @future
    public static void updateContactInFuture(String conId, String firstCommunity, String usPortalStatus, String email, String accId){
        Contact conToUpdate = new Contact(
            Id = conId,
            Community__c = firstCommunity,
            User_Portal_Status__c = usPortalStatus,
            Email = email,
            AccountId = accId
            );
        System.debug('::: Update Contact in future ... INFO : ' + conToUpdate);
        checkConAvailable(conToUpdate);
    }

    @AuraEnabled
    public static Map<String,String> getContactLabels() {
        List<SObjectField> contactFields = new List<Schema.SObjectField> {
           // 'Id',
            Contact.FirstName,
            Contact.LastName,
            Contact.Email,
            Contact.Salutation,
            Contact.Title,
            Contact.Phone,
            Contact.MobilePhone,
            Contact.Fax,
            Contact.Membership_Function__c
        };

        Map<String,String> labels = new Map<String,String>();
        for (SObjectField f : contactFields) {
            labels.put(f.getDescribe().getName(), f.getDescribe().getLabel());
        }
        return labels;
    }

    @AuraEnabled
    public static Map<String,String> getAccountLabels() {
        List<String> contactFields = new List<String> {
           // 'Id',
            'BillingAddress',
            'BillingCity',
            'BillingCountry',
            'BillingPostalCode',
            'BillingState',
            'BillingStreet',
            'Category__c',
            'Email__c',
            'IATACode__c',
            'Legal_name__c',
            'Name',
            'Sector__c',
            'ShippingAddress',
            'ShippingCity',
            'ShippingCountry',
            'ShippingPostalCode',
            'ShippingState',
            'ShippingStreet',
            'TradeName__c',
            'Website'
        };
        Map<String, SObjectField> accountFields = Schema.SObjectType.Account.fields.getMap();
        Map<String,String> labels = new Map<String,String>();
        for (String name : contactFields) {
            SObjectField f = accountFields.get(name);
            if (f!=null){
                labels.put(f.getDescribe().getName(), f.getDescribe().getLabel());
            }
        }
        return labels;
    }

    @AuraEnabled
    public static List<String> getContactJobFunctionValues(){
        List<String> values =  new  List<String>();

        List<Schema.PicklistEntry> controllingFieldValues = Schema.Contact.Function__c.getDescribe().getPickListValues();
        for (Schema.PicklistEntry p : controllingFieldValues){
           values.add(p.getLabel());
        }
        return values;
    }

    @AuraEnabled
    public static Map<String, PicklistEntry> getSectors(){
        Map<String, PicklistEntry> values =  new  Map<String, PicklistEntry>();
        values.put('', new PicklistEntry(System.Label.ISSP_Registration_None, ''));

        for (Schema.PicklistEntry p : Schema.Account.Sector__c.getDescribe().getPickListValues()){
            PicklistEntry e = new PicklistEntry(p.getLabel(), p.getValue());

            for(Schema.PicklistEntry dp : OneId_PicklistHelper.getDependentValues(p.getValue())){
                e.dependentValues.add(new PicklistEntry(dp.getLabel(), dp.getValue()));
            }

           values.put(e.value, e);
        }
        return values;
    }

    public class PicklistEntry {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public List<PicklistEntry> dependentValues; 

        public PicklistEntry(String label, String value){
            this.label = label;
            this.value = value;
            this.dependentValues = new List<PicklistEntry>();
        }
    }

    @AuraEnabled
    public static CountryInformation getISOCountries() {
        List<IATA_ISO_Country__c> countries = new List<IATA_ISO_Country__c>();
        for(IATA_ISO_Country__c iso : IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountries(), 'Name')){
            if (iso.Name != 'All Countries' &&  iso.Name != 'NO COUNTRY'){
                countries.add(iso);
            }
        }
        return new CountryInformation(countries);
    }

    public class CountryInformation {
        @AuraEnabled public Map<Id, IATA_ISO_Country__c> countryMap { get; private set; }
        @AuraEnabled public List<IATA_ISO_Country__c> countryList { get; private set; }

        public CountryInformation(List<IATA_ISO_Country__c> countryList){
            this.countryList = countryList;
            this.countryMap = new Map<Id, IATA_ISO_Country__c>(countryList);
        }
    }

    @AuraEnabled
    public static Boolean checkAddress(String info, String countryCode) {
        return OneId_AddressDoctor.isValidAddress((OneId_AddressDoctor.AddressInfo)JSON.deserialize(info, OneId_AddressDoctor.AddressInfo.class), countryCode);
    }


    @AuraEnabled
    public static boolean registration(Account acc, Contact con, String serviceName){
        system.debug('OneId registration process starting...');
        system.debug('account  --> ' + acc);
        system.debug('contact  --> ' + con);
        system.debug('serviceName  --> ' + serviceName);

        if(serviceName == null)
            serviceName = 'IDENTITY';

        //it's general public account? create contact / user
        if(acc.Sector__c == 'General Public'){
            List<Account> gpAccount = [SELECT id, IATA_ISO_Country__c FROM Account WHERE Sector__c = 'General Public' and  IATA_ISO_Country__c =:acc.IATA_ISO_Country__c];
            if(!gpAccount.isEmpty()) acc.Id  = gpAccount[0].Id;
        }

        //it's a branch
        if(acc.ParentId != null){
            Account pAccount = [SELECT id, IATACode__c, Airline_designator__c, Name FROM Account WHERE id = :acc.ParentId];
                system.debug('aqui pAccount ' + pAccount);
                acc.Reason_for_creation__c = 'Branch is missing';
                acc.IATACode__c = pAccount.IATACode__c;
                acc.Airline_designator__c = pAccount.Airline_designator__c;
                acc.Name = pAccount.Name;
                createBranch = true;
        }

        if(acc.Id != null) {
            // Define account fields
            if(acc.Sector__c != 'General Public')
                acc.Legal_name__c = acc.Name;                    
            
            // Define field specific to services
            if(serviceName == 'ISSP'){
                con.Community__c = 'ISS Customer Portal';
                con.User_Portal_Status__c = 'Pending Approval';                
            }

            //check if the general public account have contacts
            if(acc.Sector__c == 'General Public'){
                List<Contact> gpContact = [SELECT id, AccountId FROM Contact WHERE AccountId =:acc.Id];
                if(gpContact.isEmpty()) //in this case the Portal Status will be Pending Approval
                    con.User_Portal_Status__c = 'Active';
            }    

            if(serviceName == 'FRED'){
                //con.User_Portal_Status__c = ISSP_CONSTANT.NEW_CONTACT_STATUS;
                con.Community__c = 'FRED Customer Portal';
            }

        }else{ // account not found
            system.debug('account not found starting...');
            system.debug('account not found --> acc.IATA_ISO_Country__c ' + acc.IATA_ISO_Country__c);
            system.debug('account not found --> acc.IATA_ISO_Shipping_Country__c ' + acc.IATA_ISO_Shipping_Country__c);
            system.debug('account not found --> acc.BillingCountry ' + acc.BillingCountry);
            system.debug('account not found --> acc.ShippingCountry ' + acc.ShippingCountry);
            system.debug('account not found --> sector ' + acc.Sector__c);
            system.debug('account not found --> category ' + acc.Category__c);            
            isNewAcc = true;
            acc.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');                     

            if(serviceName == 'ISSP'){
                con.User_Portal_Status__c ='Active';
                con.Community__c = 'ISS Customer Portal';
            }

            if(acc <> null && con.AccountId <> null) acc.id = con.AccountId;
        }

        //create contact        
        con.ISO_Country__c = acc.IATA_ISO_Country__c;
        con.IATA_ISO_Shipping_Country__c = acc.IATA_ISO_Country__c;
        con.Country__c = acc.IATA_ISO_Country__c;
        con.Preferred_Language__c = languageString;
        con.IATA_ISO_Billing_State__c = acc.IATA_ISO_Billing_State__c;
        con.IATA_ISO_Shipping_State__c = acc.IATA_ISO_Shipping_State__c;

        
        Savepoint sp = Database.setSavepoint();
        try {
          
            String returnedString = createContactAndAccount(con,acc,serviceName);
            System.debug('@SMH'+returnedString);
            if (returnedString.contains('line:')){
                // Error during creation of contact and user                
                Database.rollback(sp);
                return false;
            } else {                    
                system.debug('aqui service name after ' + serviceName);
                if(serviceName == 'ISSP'){
                    permissionCSPortal(returnedString); // assign Permission Set CS Portal, give access to CS Portal Connected App
                }
                if(serviceName == 'ISSP' && isNewAcc == true && (acc.Sector__c == 'Travel Agent' || acc.Sector__c == 'Cargo Agent')){
                    permissionNewAgency(returnedString);
                    updatePortalUseProfile(returnedString);

                    if(acc.Sector__c == 'Travel Agent' || acc.Sector__c == 'Cargo Agent')                    
                        portalServiceNewAgency(con.Id);
                }
                
            }

            // We need to create a Case
            if(serviceName == 'NDCMM'){               

                //Fetching the assignment rules on case
                List<AssignmentRule> arList = [SELECT Id FROM AssignmentRule WHERE SobjectType = 'Case' AND Active = true limit 1];              

                //Creating the DMLOptions for "Assign using active assignment rules" checkbox
                Database.DMLOptions dmlOpts = new Database.DMLOptions();
                if(arList.size() > 0) {
                    dmlOpts.assignmentRuleHeader.assignmentRuleId = arList[0].id;
                }
                Case cse = new Case(
                    Subject = 'NDC Matchmaker - Validate Contact',
                    AccountId = acc.Id,
                    ContactId = con.Id,
                    Origin = 'Portal',
                    RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('NDC Management').getRecordTypeId()
                );
                cse.setOptions(dmlOpts);
                insert cse;               

                // We also need to create a Portal Application Right
                // This part has to be made generic for all services in the future
                //One_Id_Service_Provider_Config__c oneIdService = [select Portal_Service__c from One_Id_Service_Provider_Config__c where Service_Provider_Name__c = 'NDCMM' and RecordType.DeveloperName = 'Service_Provider' limit 1];              

                Portal_Application_Right__c portalApplicationRight = new Portal_Application_Right__c(
                    //Portal_Application__c = oneIdService.Portal_Service__c,
                    Right__c = 'Access Requested',
                    Contact__c = con.Id
                );
                insert portalApplicationRight;
            }          
        } catch(exception ex){            
            Database.rollback(sp);
            System.debug(ex);
            return false;
        }        
        return true;
    }
    
    private static String createContactAndAccount (Contact con, Account acc, String servName) {
        system.debug('createContactAndAccount starting contact -->  ' + con);
        system.debug('createContactAndAccount starting account -- ' + acc);
        
        Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');      

        if(con.RecordType == null){
            con.RecordTypeId = rtId;
        }        
        try {
            if(acc.Id == null) {
                //acc.phone = null;
                //acc.name = acc.Legal_name__c;
                acc.Reason_for_creation__c = 'Created by customer';
                //Since we need to create a portal user, we need to assign the account to a user with a specified role, otherwise an error is thrown
                acc.ownerid = ISSP_Constant.newAccountOwnerId;
                acc.recordtypeid = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
                
                if (!String.isBlank(acc.Category__c) && acc.Category__c != 'Other')
                    acc.Category_Other_Value__c = null;
                
                //Assign countries and states
                if (!String.isBlank(acc.BillingCountry)) {
                    List<Iata_Iso_Country__c> cn = IATAIsoCountryDAO.getIsoCountryByCountriesName(new Set<String>{acc.BillingCountry});
                    if (cn.size()!=0) {
                        acc.IATA_ISO_Country__c = acc.IATA_ISO_Shipping_Country__c = cn[0].id;
                    }
                }
            
                database.insert(acc);
            }
          
            con.AccountId = acc.Id;
            if(! String.isBlank(acc.Iata_Iso_Country__c)) {
                con.ISO_Country__c = acc.Iata_Iso_Country__c;
                if(! String.isBlank(acc.IATA_ISO_Shipping_Country__c))
                    con.IATA_ISO_Shipping_Country__c = acc.IATA_ISO_Shipping_Country__c;
            }

            // TIP PORTAL ACCESS ASSIGNMENT
            if(acc.Sector__c == TIP_Utils.ACCOUNT_SECTOR_FINANCIAL_INSTITUTION && acc.Category__c == TIP_Utils.ACCOUNT_CATEGORY_PAYMENT_PROVIDER){
                con.Primary_Contact__c = true;
                con.User_Portal_Status__c = 'Approved Admin';
                
                checkConAvailable(con);

                con.account=acc;
                //TIP-16 - Assign TIP Portal Service
                Id appListId;
                ISSP_Portal_Service_Ids__c serviceIdInstance = ISSP_Portal_Service_Ids__c.getInstance();
                if (serviceIdInstance != null && !String.isBlank(serviceIdInstance.TIP_Portal_Service_Id__c)){
                        appListId = serviceIdInstance.TIP_Portal_Service_Id__c;

                    Portal_Application_Right__c newRight = new Portal_Application_Right__c();
                    newRight.Contact__c = con.Id;
                    newRight.Right__c = 'Access Granted';
                    newRight.Portal_Application__c = appListId;
                    insert newRight;
               }

            //Start ACLI
                // ACLI Requirement: The first user registering under a new airline account will get it automatically.
            }else if(acc.Sector__c == 'Airline' && isNewAcc &&
                        acc.RecordTypeId == Schema.Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Standard Account').getRecordTypeId() ){

                System.debug('Adding ACLI service');
                con.Primary_Contact__c = true;
                con.User_Portal_Status__c = 'Approved Admin';

                checkConAvailable(con);

                con.account=acc;

                //ACLI Requirement: if first user on an Airline account then the user gets automatically the Coding Service
                Id appListId;
                ISSP_Portal_Service_Ids__c serviceIdInstance = ISSP_Portal_Service_Ids__c.getInstance();
                if (serviceIdInstance != null && !String.isBlank(serviceIdInstance.ACLI_IATA_Airlines_and_Location_Codes__c)){
                    appListId = serviceIdInstance.ACLI_IATA_Airlines_and_Location_Codes__c;

                    Portal_Application_Right__c newRight = new Portal_Application_Right__c();
                    newRight.Contact__c = con.Id;
                    newRight.Right__c = 'Access Granted';
                    newRight.Portal_Application__c = appListId;
                    insert newRight;
                }


            }
            //End ACLI
            else{
                checkConAvailable(con);
            }


            String thisNickname;
            if (String.isNotBlank(con.lastName) && con.lastName.length() > 3)
                thisNickname = con.lastName.substring(0,3)+Datetime.now().formatLong();
            else
                thisNickname = con.lastName+Datetime.now().formatLong();

            system.debug('NICKNAME 1: ' + thisNickname);
            system.debug('NICKNAME 1 length: ' + thisNickname.length());
            if (thisNickname.length() > 40){
                system.debug('more than 40');
                thisNickname = thisNickname.left(40);
            }
            else{
                system.debug('not more than 40');
                thisNickname = thisNickname;
            }   

            Boolean newAirline = false;
            if(acc.Sector__c == 'Airline' && !createBranch){
                newAirline = true;
                isNewAcc = false;
            }

            System.debug('>>con ' + con);

            string UID = Comm_User_Helper.NewGuid();
            String u = Comm_User_Helper.createNewUser(con, '',servName,languageString,isNewAcc,newAirline);
            
            system.debug('aqui userID ' + u);

            //User u = new User ( CommunityNickname= thisNickname , title=con.title, contactid = con.id, Firstname = con.firstname, lastname = con.lastname, emailencodingkey = 'UTF-8', localesidkey = 'en_US', email = con.email, username=ISSP_Utilities.buildPortalUserName(con.email), Alias = ISSP_Utilities.buildPortalUserName(con.email).left(5), timezonesidkey = 'America/Los_Angeles', languagelocalekey = 'en_US',Date_ToU_accepted__c = system.Now(), ToU_accepted__c = true, UID__c = UID);            
            /*system.debug('aqui user ' + u);
            if(servName == 'FRED') {
                // JIRA ISI-51 + ISI-14: Self registration primary or secondary 
                String profileID = '';
                list<Profile> fredProfiles = [SELECT Id FROM profile WHERE name like '%Fred%' ORDER BY Name];
                // Check if primary user exists on request account
                list<User> primaryUsers = [SELECT ProfileId FROM User WHERE Contact.AccountId =: con.accountId AND Profile_Name__c like '%Primary%'];
                if(primaryUsers.isEmpty()) {
                   // Create primary as primary exists yet
                   profileID = fredProfiles[0].Id;
                } else {
                    // Create secondary as primary exists
                    profileID = fredProfiles[1].Id;
                }
                u.ProfileID = profileID;
            }
            
            if(servName == 'ISSP' || servName == 'FRED')
                u.Community__c = servName;

            String password = Comm_User_Helper.generateRandomString(6) + '1a';
            System.debug('password ' + password);
            System.debug('con ' + con.accountId);
            System.debug('u ' + u);
            System.debug('servName ' + servName);
            //String userId = Site.createPortalUser(u, con.accountId, password, false);
            
            System.debug('userId ' + userId);
            
            sendWelcomeEmail(con, u, password, servName);*/

            return u;
            

        } catch (Exception e) {
            return e.getMessage() + '\nStack Trace:' + e.getStackTraceString() + ' \nline: ' + e.getLineNumber();
        }

    }

    /*public static void sendWelcomeEmail(Contact con, User u, String password, String serviceName){
        System.debug('sendWelcomeEmail starting... ');
        String cleanUsername = u.userName.replace('+', Comm_User_Helper.plusReplacer);
        String encodedPart ='c='+EncodingUtil.urlEncode(Comm_User_Helper.EncryptString(cleanUsername+Comm_User_Helper.SEPARATOR+password+Comm_User_Helper.SEPARATOR+u.UID__c), 'UTF-8');
        String template = 'Identity_Portal_New_User';
        string prefix = OneIdUtils.getSiteCompleteUrl();
        String link = prefix + '/s/IdentityFirstLogin?' + encodedPart;

        if(serviceName == Comm_User_Helper.ISSP){ // OneIdEnh CSP-ID002: change the login URL for the customer portal
            template = 'Identity_Portal_ISSP_New_User';
            link = 'https://' + String.ValueOF(ISSP_CS__c.getValues('Host').value__c) + '/ISSP_First_Login?'+encodedPart;
        } 

        Map<String,String> emailWrap = new Map<String,String>();
        
        emailWrap = Comm_User_Helper.ISSP_PassWordBuilMessageWrapper(con, password, link, Comm_User_Helper.ONEIDENTITY, serviceName);
        Comm_User_Helper.sendEmail(template, emailWrap, con, Comm_User_Helper.ONEIDENTITY);
    }*/

    @future
    public static void updatePortalUseProfile(String userId){
        system.debug('updateUserProfile starting... ' + userId);
        Profile isspAgentUser = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Agency User (Partner)'];                
        update new User(Id = userId, ProfileId = isspAgentUser.Id);       
    }

    @Future
    public static void permissionNewAgency(String userId){
        if (userId != null && userId != '') {
            List <PermissionSet> permList = [SELECT Id FROM PermissionSet WHERE Name = 'ISSP_New_Agency_permission_set'];            
            if (!permList.isEmpty()){
                PermissionSetAssignment newAssign = new PermissionSetAssignment();
                newAssign.AssigneeId = userId;
                newAssign.PermissionSetId = permList[0].Id;
                insert newAssign;
            }
        }
    }

    @Future
    public static void permissionCSPortal(String userId){
        if (userId != null && userId != '') {
            List <PermissionSet> permListPortal = [SELECT Id FROM PermissionSet WHERE Name = 'ISSP_SSO'];
            if(!permListPortal.isEmpty()){
                PermissionSetAssignment newAssignCS = new PermissionSetAssignment();
                newAssignCS.AssigneeId = userId;
                newAssignCS.PermissionSetId = permListPortal[0].Id;
                insert newAssignCS;
            }
        }
    }

    public static void portalServiceNewAgency(String conId){
        system.debug('aqui portalServiceNewAgency....' + conId);
        if (conId != null && conId != '') {
            List<Portal_Applications__c> pApplication = [SELECT id FROM Portal_Applications__c WHERE Name = :AMS_UTILS.IATA_ACCREDITATION_AND_CHANGES];

            if(!pApplication.isEmpty()){
                Portal_Application_Right__c appRight = new Portal_Application_Right__c();
                appRight.Contact__c = conId;
                appRight.Portal_Application__c = pApplication[0].Id;
                appRight.Right__c = 'Access Granted';
                insert appRight;
            }

        }
    }

    @AuraEnabled
    public static void checkConAvailable (Contact con){
        
        Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');   
        Contact [] ec = [Select id, email, AccountId, RecordType.Id, User_Portal_Status__c, Community__c, Invoicing_Contact__c, BSP_CASS_Payment_contact__c FROM Contact WHERE email =:con.email AND AccountId =:con.AccountId LIMIT 1];
        System.debug('Contact Information : ' + con + ' Contact query: ' + ec);

        
        if(ec.size() > 0){
            System.debug('Update Contact');
            con.Id = ec[0].Id;
            con.RecordTypeId = rtId;
            try {
                database.update(con);
            } catch(Exception e) {
                System.debug('Update Contact FAILED ::: ' +  e.getMessage());
            }

        } else {
            System.debug('Insert new contact'); 
            System.debug(con);
            try {
                database.insert(con);
            } catch(Exception e) {
                System.debug('Insert Contact FAILED ::: ' + e.getMessage());
            }                       
        }
    }

     @AuraEnabled
    public static Contact loadInvitationInfo (String invitationId){
        
        List<Invitation__c> invitation = [select id,AccountId__c, Business_Fax__c, Business_Phone__c, 
        Email__c, First_Name__c, Job_Function__c, Job_Title__c, 
        Last_Name__c, Mobile_Phone__c, Name, Salutation__c from Invitation__c WHERE Id =: invitationId];        
        if(! invitation.isEmpty()) {
            Invitation__c inv = invitation[0];
            Contact c = new Contact (
                Fax = inv.Business_Fax__c,
                Phone = inv.Business_Phone__c,
                Email = inv.Email__c,
                FirstName = inv.First_Name__c,
                Function__c = inv.Job_Function__c,
                Membership_Function__c = inv.Job_Function__c,
                Title = inv.Job_Title__c,
                LastName = inv.Last_Name__c,
                MobilePhone = inv.Mobile_Phone__c,
                Salutation = inv.Salutation__c
            );
            return c;
        }
        return null;
    }
    
    /* Manuel Conde commented this... 

    public static void increaseCodeCoverage(){
        Integer i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
    }

     */

}