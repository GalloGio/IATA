/**
 * Created by ukaya01 on 29/07/2019.
 */

public without sharing class PortalRegistrationFirstLevelCtrl {
    
    public class RegistrationConfig{
        @AuraEnabled
        public Boolean isSelfRegistrationEnabled{get;set;}
        @AuraEnabled
        public Map<String,String> contactLabelMap{get;set;}
        @AuraEnabled
        public Map<String,String> accountLabelMap{get;set;}
        @AuraEnabled
        public CountryInformation countryInfo{get;set;}
        @AuraEnabled
        public List<CSP_Utils.PickListWrapper> languageList{get;set;}
    }

    public class RegistrationConfirmationConfig{
        @AuraEnabled
        public Map<String,String> contactLabelMap{get;set;}
        @AuraEnabled
        public Map<String,String> accountLabelMap{get;set;}
        @AuraEnabled
        public CountryInformation countryInfo{get;set;}
        @AuraEnabled
        public List<CSP_Utils.PickListWrapper> languageList{get;set;}
        @AuraEnabled
        public Contact contact{get;set;}
        @AuraEnabled
        public string selectedCustomerType{get;set;}
        @AuraEnabled
        public string sector{get;set;}
        @AuraEnabled
        public string category{get;set;}
        @AuraEnabled
        public string extraChoice{get;set;}
    }

    public class RegistrationResult{
        @AuraEnabled
        public Boolean isSuccess{get;set;}
        @AuraEnabled
        public String message{get;set;}
        @AuraEnabled
        public Id portalUserId{get;set;}
        @AuraEnabled
        public String userName{get;set;}
    }

    public class NewUserDetail{
        public Id userId{get;set;}
        public String userName{get;set;}
    }

    public class RegistrationParameters{
        public string email{get;set;}
        public string firstName{get;set;}
        public string lastName{get;set;}
        public string country{get;set;}
        public string phone{get;set;}
        public string language{get;set;}
        public string contactId{get;set;}
        public string accountId{get;set;}
    }

    @AuraEnabled(cacheable=true)
    public static RegistrationConfig getConfig(){
        RegistrationConfig config = new RegistrationConfig();
        Auth.AuthConfiguration authConfig = PortalLoginCtrl.getAuthConfig();
        config.isSelfRegistrationEnabled = authConfig.getSelfRegistrationEnabled();
        config.contactLabelMap = getContactLabels();
        config.accountLabelMap = getAccountLabels();
        config.countryInfo = getISOCountries();
        config.languageList = CSP_Utils.getCommunityAvailableLanguages(null,null);
        return config;
    }


    public static Map<String,String> getContactLabels() {

        List<SObjectField> contactFields = new List<Schema.SObjectField> {
            Contact.FirstName,
            Contact.LastName,
            Contact.Email,
            Contact.Salutation,
            Contact.Title,
            Contact.Phone,
            Contact.MobilePhone,
            Contact.Fax,
            Contact.Preferred_Language__c,
            Contact.Membership_Function__c
        };

        Map<String,String> labels = new Map<String,String>();
        for (SObjectField f : contactFields) {
            labels.put(f.getDescribe().getName(), f.getDescribe().getLabel());
        }
        return labels;

    }

    public static Map<String,String> getAccountLabels() {

        List<SObjectField> accountFields = new List<Schema.SObjectField> {
            Account.Sector__c,
            Account.Category__c,
            Account.IATA_ISO_Country__c,
            Account.Services_Rendered_Country__c
        };

        Map<String,String> labels = new Map<String,String>();
        for (SObjectField f : accountFields) {
            labels.put(f.getDescribe().getName(), f.getDescribe().getLabel());
        }
        return labels;

    }

    public static CountryInformation getISOCountries() {
        List<IATA_ISO_Country__c> countries = new List<IATA_ISO_Country__c>();
        for(IATA_ISO_Country__c iso : IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountries(), 'Name')){
            //todo align with Marc - Second Level Registration
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

    @AuraEnabled//(cacheable=true)
    public static RegistrationConfirmationConfig getRegistrationConfirmationConfig(){
        RegistrationConfirmationConfig config = new RegistrationConfirmationConfig();

        User loggedUser = CSP_Utils.getLoggedUser();
        List<Contact> contactList = [SELECT Id, Email, FirstName, LastName, Phone, Preferred_Language__c, ISO_Country__c, Account.Sector__c, Account.Category__c FROM Contact WHERE Id =:loggedUser.contactId LIMIT 1];
        if(!contactList.isEmpty()){
            config.contact = contactList.get(0);
            config.selectedCustomerType = GCS_CustomerType.getCustomerTypeFromSectorAndCategory(config.contact.Account.Sector__c, config.contact.Account.Category__c);
            GCS_Customer_Type_For_Registration__mdt selectedMetadataCustomerType = getMetadataCustomerType(config.selectedCustomerType);
            if(selectedMetadataCustomerType.Type__c == 'Category'){
                config.category = selectedMetadataCustomerType.DeveloperName;
                config.sector = selectedMetadataCustomerType.Parent__c;
                selectedMetadataCustomerType = getMetadataCustomerType(selectedMetadataCustomerType.Parent__c);
                if(selectedMetadataCustomerType.Parent__c == 'Other'){
                    config.extraChoice = config.sector;
                    config.sector = 'Other';
                }

            }else{
                //todo check for general public..
            }
        }
        config.contactLabelMap = getContactLabels();
        config.accountLabelMap = getAccountLabels();
        config.countryInfo = getISOCountries();
        config.languageList = CSP_Utils.getCommunityAvailableLanguages(null,null);
        return config;

    }


    public class UserInformation {
        @AuraEnabled
        Boolean hasExistingContact {get; set;}
        @AuraEnabled
        Boolean hasExistingUser{get;set;}
        @AuraEnabled
        Boolean isEmailAddressAvailable{get; set;}
        @AuraEnabled
        Id contactId{get;set;}
        @AuraEnabled
        Id accountId{get;set;}
    }

    @AuraEnabled
    public static UserInformation getUserInformationFromEmail(String email){
        UserInformation userInfo = new UserInformation();
        List<Contact> conList = returnExistingContact(email); // Since the email is unique we didn't expect to receive more than one email
        userInfo.hasExistingContact = true ? conList.size() > 0 : false;
        if( userInfo.hasExistingContact){
            userInfo.contactId = conList.get(0).Id;
            userInfo.accountId = conList.get(0).AccountId;
        }
        Set<Id> contactIds = (new Map<Id,SObject>(conList)).keySet();
        List<User> userList = returnExistingUser(contactIds, email);
        userInfo.hasExistingUser = true ? userList.size() > 0 :false;
        userInfo.isEmailAddressAvailable = checkIsUsernameIsAvailableInGlobalSalesforce(email, conList);
        return userInfo;
    }

    public static List<Contact> returnExistingContact(String email) {
        // Method to search contact that already exists in SALESFORCE
        List<Contact> conList = new List<Contact>();
        conList = [SELECT id, AccountId FROM Contact WHERE Email =: email];
        return conList;
    }

    public static List<User> returnExistingUser(Set<Id> contactIds, string email){
        //check if there is an existing user associated to the contact(s) found OR associated to the email provided
        List<User> userList = new List<User>();
        userList = [SELECT Id FROM User WHERE contactId IN :contactIds OR email = :email];
        return userList;
    }

    public static boolean checkIsUsernameIsAvailableInGlobalSalesforce(String email, List<Contact> conList) {
        // Method to test if another user existin in all SF instances to avoid having an error at the end of the process
        Savepoint sp = Database.setSavepoint();
        List<Profile> profileList = [SELECT Id, Name FROM Profile];
        map<ID, Profile> profileMap = new map<ID, Profile> (
        [SELECT Id, Name,
                UserLicenseId,
                UserLicense.Name
        FROM Profile
        WHERE (UserLicense.Name = 'Partner Community' OR UserLicense.Name = 'Identity')]);

        try {
            User testingUser = new User(LastName = 'DUMMY',
                    FirstName='DUMMY',
                    Alias = 'DUMMY',
                    CommunityNickname = 'DUMMY',
                    Email = email,
                    Username = ISSP_Utilities.buildPortalUserName(email), //myEmail@company.com because myEmail.company.com@partner.iata.org
                    ProfileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal (Partner)' LIMIT 1].Id,
                    ContactId =  !conlist.isEmpty() ? conList.get(0).Id : [SELECT Id FROM Contact WHERE Id NOT IN (SELECT ContactId FROM User) LIMIT 1].Id,
                    TimeZoneSidKey = 'GMT',
                    LanguageLocaleKey = 'en_US',
                    EmailEncodingKey = 'UTF-8',
                    LocaleSidKey = 'en_US',
                    License_Cost_center__c = 'ISF005CH01'
            );
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
    public static RegistrationResult simulateRegister(string registrationForm, string customerType, string contactId, string accountId){

        RegistrationResult result = new RegistrationResult();
        Savepoint sp = Database.setSavepoint();

        try{

            Map<String, Object> inputMap = (Map<String, Object>)JSON.deserializeUntyped(registrationForm);
            GCS_Customer_Type_For_Registration__mdt selectedMetadataCustomerType = (GCS_Customer_Type_For_Registration__mdt) JSON.deserialize(customerType, GCS_Customer_Type_For_Registration__mdt.class);

            //cannot proceed unless agreed with terms and usage
            boolean terms = boolean.valueOf(inputMap.get('termsAndUsage'));
            if(terms != true){
                result.isSuccess = false;
                result.message = 'Missing required fields';
                return result;
            }

            RegistrationParameters params = new RegistrationParameters();
            params.email     = (inputMap.get('email') != null) ? string.valueOf(inputMap.get('email')) : '';
            params.firstName = (inputMap.get('firstName') != null) ? string.valueOf(inputMap.get('firstName')) : '';
            params.lastName  = (inputMap.get('lastName') != null) ? string.valueOf(inputMap.get('lastName')) : '';
            params.phone     = (inputMap.get('phone') != null) ? string.valueOf(inputMap.get('phone')) : '';
            params.country   = (inputMap.get('country') != null) ? string.valueOf(inputMap.get('country')) : '';
            params.language  = (inputMap.get('language') != null) ? string.valueOf(inputMap.get('language')) : '';
            params.contactId = contactId != null ? contactId : '';
            params.accountId = accountId != null ? accountId : '';



            if(params.contactId.length() < 1){
                if(params.email.length() < 1 || params.firstName.length() < 1 || params.lastName.length() < 1){
                    result.isSuccess = false;
                    result.message = 'Missing required fields';
                    return result;
                }
            }

            //Find Bucket Account
            if(params.accountId.length() < 1){
                Account bucketAccount = getBucketAccount(selectedMetadataCustomerType);
                system.debug('bucketAccount: ' + bucketAccount);
                if(bucketAccount == null){
                    result.isSuccess = false;
                    result.message = 'Failed to find bucket account';
                    return result;
                }else{
                    params.accountId = bucketAccount.Id;
                }
            }


            //Create or find Contact
            Contact con;
            if(params.contactId.length() < 1){
                con = createContact(params);
            }else{
                con = [SELECT Id, AccountId, firstName, LastName, Phone, Email FROM Contact WHERE ID=: contactId LIMIT 1];
            }

            if(con == null){
                result.isSuccess = false;
                result.message = 'Failed to create contact';
                return result;
            }


            //Create User
            OneIdUtils.Mode mode = OneIdUtils.MODE.CSP;
            NewUserDetail usr = createNewUser(con, string.valueOf(mode), params.language, null);

            if(usr.userId!= null) {
                Database.rollback(sp);
                result.isSuccess = true;
                result.portalUserId = usr.userId;
                result.userName = usr.userName;

                string oneTimeUrl = generateOneTimeUrl(params);

                Map<String, String> emailMap = generateEmailBodyParams(params, oneTimeUrl);

                result.isSuccess = sendEmail(params.email, 'CSP_New_Member_Welcome_Email', emailMap);
                if(result.isSuccess == false){
                    result.message = 'Error sending Welcome Email';
                }
                //todo: add site name
                return result;
            }else{
                Database.rollback(sp);
                result.isSuccess = false;
                result.message = 'User Creation failed!';
                return result;
            }
        }catch(Exception e){
            Database.rollback(sp);
            result.isSuccess = false;
            result.message = e.getMessage();
            return result;
        }

    }

    @AuraEnabled
    public static RegistrationResult register(RegistrationParameters params, string password){

        RegistrationResult result = new RegistrationResult();
        Savepoint sp = Database.setSavepoint();

        try{

            //Create or find Contact
            Contact con;
            if(params.contactId == null || params.contactId == ''){
                con = createContact(params);
            }else{
                con = [SELECT Id, AccountId, firstName, LastName, Phone, Email FROM Contact WHERE ID=: params.contactId LIMIT 1];
            }

            if(con == null){
                result.isSuccess = false;
                result.message = 'Failed to create contact';
                return result;
            }

            //Create User
            OneIdUtils.Mode mode = OneIdUtils.MODE.CSP;
            NewUserDetail usr = createNewUser(con, string.valueOf(mode), params.language, password);

            system.debug('userId: ' + usr.userId);
            if(usr.userId != null) {
                result.isSuccess = true;
                result.portalUserId = usr.userId;
                result.userName = usr.userName;
                return result;
            }else{
                Database.rollback(sp);
                result.isSuccess = false;
                result.message = 'User Creation failed!';
                return result;
            }
        }catch(Exception e){
            Database.rollback(sp);
            result.isSuccess = false;
            result.message = e.getMessage();
            return result;
        }


    }

    @AuraEnabled
    public static RegistrationResult updateContactInfo(string registrationForm, string customerType, string contactId, string accountId){

        RegistrationResult result = new RegistrationResult();
        //todo:update contact info & bucket account relation
        return result;

    }

    public static Account getBucketAccount(GCS_Customer_Type_For_Registration__mdt selectedMetadataCustomerType){

        String sector = '';
        String category = '';
        String recordType = '';

        if(selectedMetadataCustomerType.Can_Account_Be_Created__c == true){
            sector = selectedMetadataCustomerType.Created_Account_Sector__c;
            category = selectedMetadataCustomerType.Created_Account_Category__c;
        }else{
            sector = selectedMetadataCustomerType.Filter_on_Sector__c;
            category = selectedMetadataCustomerType.Filter_on_Category__c;
        }
        recordType = selectedMetadataCustomerType.Filter_on_Record_Type__c;

        String accountQuery = '';
        accountQuery +='SELECT Id, Sector__c, Category__c';
        accountQuery +=' FROM Account';
        accountQuery +=' WHERE Id != null AND Is_General_Public_Account__c = true';


        if(!String.isEmpty(recordType)) {

            List<String> recordTypes = new List<String>();
            for(String rcType : recordType.split(',')){
                recordTypes.add('\'' + rcType.trim() + '\'');
            }

            accountQuery += ' AND RecordType.DeveloperName in (' + String.join(recordTypes, ',') + ')';

        }
        if(!String.isEmpty(sector)){
            accountQuery +=' AND Sector__c =\''+ sector +'\'';
        }
        if(!String.isEmpty(category)){
            accountQuery +=' AND Category__c =\''+ category +'\'';
        }

        List<Account> accs = new List<Account>();

        accs = Database.query(accountQuery);

        if(accs.isEmpty()){
            //todo: create bucket account? to be confirmed by IATA
            return null;
        }else{
            return accs.get(0);
        }

    }

    public static Contact createContact(RegistrationParameters params){

        Contact con = new Contact();

        try{

            if(params.language.length() > 0){
                List<Preferred_Language_on_ISS_Portal__c> pLangcs = Preferred_Language_on_ISS_Portal__c.getall().values();

                if(pLangcs!= null || !pLangcs.isEmpty()){
                    for(Preferred_Language_on_ISS_Portal__c language : pLangcs){
                        if(language.languageLocalKey__c == params.language){
                            con.Preferred_Language__c = language.Language__c;
                        }
                    }
                }
            }

            con.AccountId = params.accountId;
            con.ISO_Country__c = params.country;
            con.firstName = params.firstName;
            con.lastName = params.lastName;
            con.Phone = params.phone;
            con.Email = params.email;
            con.Community__c = 'ISS Customer Portal';
            con.User_Portal_Status__c = 'Pending';
            //todo: perform field check before insert
            DataBase.SaveResult sr = DataBase.Insert(con);
            if(sr.isSuccess() == false){
                for(Database.Error objErr : sr.getErrors()) {
                    System.debug('Portal Level 1 registration - createNewContact: ' + objErr.getStatusCode() + ': ' + objErr.getMessage());
                }
                return null;
            }else{
                return con;
            }

        }catch(Exception e){
            system.debug('Portal Level 1 registration - createNewContact: ' + e.getMessage());
            return null;
        }

    }

    public static NewUserDetail createNewUser(Contact con, string community, string lang, string password){

        NewUserDetail usr = new NewUserDetail();
        usr.userId = null;
        usr.userName = null;

        try {

            String accountId = '';
            // prepare new User
            string userName = ISSP_Utilities.buildPortalUserName(con.email);
            User u = new User();
            u.Community__c = community;
            u.Username =  userName;//AEF
            u.Email = con.email;
            u.FirstName = con.firstName;
            u.LastName = con.lastName;
            u.Date_ToU_accepted__c = system.Now();//TF - Accept Terms
            u.ToU_accepted__c = true;//TF - Accept Terms
            String thisNickname;
            if (con.lastName.length() > 3)
                thisNickname = con.lastName.substring(0,3)+Datetime.now().formatLong();
            else
                thisNickname = con.lastName+Datetime.now().formatLong();
            if (thisNickname.length() > 40){
                thisNickname = thisNickname.left(40);
            }
            else{
                thisNickname = thisNickname;
            }
            u.CommunityNickname = thisNickname;

            string profileName = 'ISS Portal (Partner)';
            u.ProfileId = [SELECT Id FROM Profile WHERE Name =: profileName LIMIT 1].Id;

            if(con.accountId != null){
                accountId = con.accountId;
            }

            if(password == null){
                password = Comm_User_Helper.generateRandomString(6) + '1a';
            }

            if (lang != null && lang != ''){
                Map<string,string> langMap = ISSP_Constant.languageMap;
                Map<string,string> lowercaseLangMap = new Map<string,string>();
                for(string key : langMap.keySet()){
                    lowercaseLangMap.put(key.toLowerCase(),key);
                }

                if (!lowercaseLangMap.containsKey(lang)){
                    lang = 'en_US';
                }else{
                    u.languagelocalekey = lowercaseLangMap.get(lang);
                }

            }

            system.debug('user to be created: ' + u);
            usr.userId = Site.createPortalUser(u, accountId, password, false);
            usr.userName = u.username;
            system.debug('USERID: ' + usr.userId);

            List<PermissionSet> permissionList = [SELECT Id FROM PermissionSet WHERE Name = 'ISSP_SSO'];
            if(permissionList.size() > 0){
                addPermissionToUser(permissionList.get(0).Id, usr.userId);
            }

            //this does not fit in for bucket account scenario, should be handled on L2 registration?
            //Comm_User_Helper.addDefaultAppRights(con,con.Account);

            return usr;


        } catch (exception e) {
            system.debug('Portal Level 1 registration - createNewUser: ' + e.getMessage());
            //transformationHelper.sendSFDevsAlertMessage('error ' ,  '   con  ' +    con +  '   ' +ex.getmessage() + '   '+ ex.getstackTraceString(),  new list<string>{'sfdcadmin@iata.org'});
            return usr;
        }

    }

    public static string generateOneTimeUrl(RegistrationParameters params){

        string paramsJson = JSON.serialize(params);
        paramsJson = paramsJson.replace('+', PortalPasswordHandler.plusReplacer);
        string encryptedStr = PortalPasswordHandler.EncryptString(paramsJson);
        String encodedPart = 'c=' + EncodingUtil.urlEncode(encryptedStr, 'UTF-8');

        String prefix = '';
        if(Network.getNetworkId() != null) prefix = Network.getLoginURL(Network.getNetworkId()).substring(0,Network.getLoginURL(Network.getNetworkId()).indexOf('/login'));
        String oneTimeUrl = prefix + '/' + 'createPassword' + '?' + encodedPart;
        return oneTimeUrl;

    }

    public static Map<String,String> generateEmailBodyParams(RegistrationParameters params, string oneTimeLink){

        Map<String, String> mapBodyParams = new map<String, String>{
                '{!Contact.Salutation}' => '',
                '{!Contact.Password}' => '',
                '{!Receiving_User.FirstName}' => params.firstName,
                '{!Receiving_User.LastName}' => params.lastName,
                '{!Receiving_User.Email}' => params.email,
                '{!Community_Name}' => '',
                '{!Community_Url}' => oneTimeLink,
                '{!$Label.ISSP_Email_Here}' => 'here',
                '{!$Label.ISSP_Email_do_not_reply}' => Label.ISSP_Email_do_not_reply
        };

        return mapBodyParams;

    }

    public static boolean sendEmail(String receiver, String template, Map<String,String> mapBodyParams) {
        boolean success = true;

        try{
            List<Messaging.SendEmailResult>    listEmailResult = null;
            List<Messaging.SingleEmailmessage> listSingleEmailMessages = new List<Messaging.SingleEmailmessage>();

            EmailTemplate emailTemplate = [SELECT Id,Subject,HtmlValue,Body FROM EmailTemplate WHERE DeveloperName=:template];

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            OrgWideEmailAddress orgWideEmail  = [SELECT Id,Address FROM OrgWideEmailAddress WHERE Address='noreply@iata.org' Limit 1];
            if(orgWideEmail != null){
                mail.setOrgWideEmailAddressId(orgWideEmail.Id);
            }
            else{
                mail.setSenderDisplayName('IATA Noreply');
            }


            List<String> receiverList = new List<String>();
            receiverList.add(receiver);
            mail.setToAddresses(receiverList);
            mail.setReplyTo('noreply@iata.org');
            //mail.setTargetObjectId(userId);
            mail.setSubject(emailTemplate.Subject);

            String htmlBody  = emailTemplate.HtmlValue;
            String plainBody = emailTemplate.Body;
            for(String key : mapBodyParams.keySet()) {
                if(htmlBody <> null && mapBodyParams <> null) {
                    htmlBody  = htmlBody.replace(key, (mapBodyParams.get(key) == null)  ? '' : mapBodyParams.get(key));
                    plainBody = plainBody.replace(key, (mapBodyParams.get(key) == null) ? '' : mapBodyParams.get(key));
                }
            }

            if(htmlBody <> null){
                mail.setHtmlBody(htmlBody);
            }

            mail.setSaveAsActivity(false);
            mail.setPlainTextBody(plainBody);
            listSingleEmailMessages.add(mail);

            if(!Test.isRunningTest()) {
                listEmailResult = Messaging.sendEmail(listSingleEmailMessages);
            }
        }
        catch(Exception ex){
            success = false;
            system.debug(ex.getMessage());
        }

        return success;
    }

    @future
    public static void addPermissionToUser(Id permissionSetId, Id userId){

        PermissionSetAssignment oPermissionSetAssignment = new PermissionSetAssignment();
        oPermissionSetAssignment.AssigneeId = userId;
        oPermissionSetAssignment.PermissionSetId = permissionSetId;
        insert oPermissionSetAssignment;
    }

    private static Map<String,GCS_CustomerType> customerTypesMap {
        get{
            if(customerTypesMap == null){
                customerTypesMap = GCS_CustomerType.getCustomerTypesMap();
            }
            return customerTypesMap;
        }
        private set;
    }

    public class CustomerTypePicklist{
        @AuraEnabled
        String picklistName {get; set;}

        @AuraEnabled
        String picklistLabel { get; private set; }

        @AuraEnabled
        List<CustomerTypePicklistOption> picklistOptions { get; private set; }

        public CustomerTypePicklist(String picklistLabel){
            this.picklistLabel = picklistLabel;
            picklistOptions = new List<CustomerTypePicklistOption>();
        }
    }

    public class CustomerTypePicklistOption{
        @AuraEnabled
        String key { get; private set; }

        @AuraEnabled
        String label { get; private set; }

        @AuraEnabled
        Boolean isSelected { get; private set; }

        public CustomerTypePicklistOption(String key, String label, Boolean isSelected){
            this.key = key;
            this.label = label;
            this.isSelected = isSelected;
        }
    }

    @AuraEnabled(cacheable=true)
    public static GCS_Customer_Type_For_Registration__mdt getMetadataCustomerType(String customerTypeKey) {
        if(customerTypeKey == null){
            return null;
        }
        return customerTypesMap.get(customerTypeKey).metadataCustomerType;
    }

    @AuraEnabled(cacheable=true)
    public static List<CustomerTypePicklist> getCustomerTypePicklists(String leaf){
        List<CustomerTypePicklist> picklists = new List<CustomerTypePicklist>();

        String selectedItem;

        Boolean keepLooping = true;

        String currentCustomerType = leaf;
        String previousCustomerType = null;

        while(keepLooping){
            // Top level
            if(currentCustomerType == null){
                // need to retrieve the records without parents

                CustomerTypePicklist picklist = new CustomerTypePicklist(GCS_CustomerType.customLabels.get('Sector'));
                picklist.picklistName = 'Sector';
                picklist.picklistOptions.add(new CustomerTypePicklistOption(null, GCS_CustomerType.customLabels.get('Select'), previousCustomerType == null));

                for(GCS_CustomerType child : GCS_CustomerType.getCustomerTypesList()){
                    picklist.picklistOptions.add(new CustomerTypePicklistOption(child.metadataCustomerType.DeveloperName, child.label, child.metadataCustomerType.DeveloperName == previousCustomerType));
                }

                picklists.add(picklist);

                keepLooping = false;
            }
            else {
                GCS_CustomerType customerType = customerTypesMap.get(currentCustomerType);

                if (!customerType.children.isEmpty()) {
                    CustomerTypePicklist picklist = new CustomerTypePicklist(customerType.subCategorizationLabel);
                    picklist.picklistName = customerType.metadataCustomerType.sub_categorization_custom_label__c;
                    picklist.picklistOptions.add(new CustomerTypePicklistOption(null, customerType.subCategorizationPlaceholder, previousCustomerType == null));
                    //picklist.picklistOptions.add(new CustomerTypePicklistOption(customerType.metadataCustomerType.DeveloperName, customerType.subCategorizationPlaceholder, previousCustomerType == null));
                    for (GCS_CustomerType child : customerType.children) {
                        picklist.picklistOptions.add(new CustomerTypePicklistOption(child.metadataCustomerType.DeveloperName, child.label, child.metadataCustomerType.DeveloperName == previousCustomerType));
                    }

                    picklists.add(picklist);
                }

                previousCustomerType = currentCustomerType;
                currentCustomerType = customerType.parent != null ? customerType.parent.metadataCustomerType.DeveloperName : null;
            }
        }

        List<CustomerTypePicklist> orderedPicklists = new List<CustomerTypePicklist>();

        for(Integer i = picklists.size()- 1 ; i >= 0; i--){
            orderedPicklists.add(picklists[i]);
        }

        return orderedPicklists;
    }


}