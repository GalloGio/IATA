/**
 * Created by ukaya01 on 29/07/2019.
 */

public without sharing class PortalRegistrationFirstLevelCtrl {

    public class CountryInformation {
        @AuraEnabled public Map<Id, IATA_ISO_Country__c> countryMap { get; private set; }
        @AuraEnabled public List<IATA_ISO_Country__c> countryList { get; private set; }

        public CountryInformation(List<IATA_ISO_Country__c> countryList){
            this.countryList = countryList;
            this.countryMap = new Map<Id, IATA_ISO_Country__c>(countryList);
        }
    }

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
        @AuraEnabled
        public string troubleShootingUrl{get;set;}
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
        @AuraEnabled
        public boolean isGeneralPublic{get;set;}
        @AuraEnabled
        public string troubleShootingUrl{get;set;}
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
        @AuraEnabled
        public boolean isGeneralPublicAccount{get;set;}
    }

    public class NewUserDetail{
        public Id userId{get;set;}
        public String userName{get;set;}
    }

    public class BucketAccountDetail{
        public Account acc {get;set;}
        public boolean isNewAccount {get;set;}
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
        public boolean isNewAccount{get;set;}
        public string selectedCustomerType {get;set;}
        public string registrationTime {get;set;}
    }

    public class UserInformation {
        @AuraEnabled
        public Boolean hasExistingContact {get; set;}
        @AuraEnabled
        public Boolean hasExistingUser{get;set;}
        @AuraEnabled
        public Boolean isEmailAddressAvailable{get; set;}
        @AuraEnabled
        public Id contactId{get;set;}
        @AuraEnabled
        public Id accountId{get;set;}
    }

    @AuraEnabled(cacheable=true)
    public static RegistrationConfig getConfig(){
        RegistrationConfig config = new RegistrationConfig();
        Auth.AuthConfiguration authConfig = PortalLoginCtrl.getAuthConfig();
        config.isSelfRegistrationEnabled = authConfig.getSelfRegistrationEnabled();
        config.contactLabelMap = getContactLabels();
        config.accountLabelMap = getAccountLabels();
        config.countryInfo = getISOCountries();
        config.languageList = new List<CSP_Utils.PickListWrapper>();
        for(CSP_Utils.PickListWrapper wrapper : CSP_Utils.getCommunityAvailableLanguages(null,null)){
            wrapper.value = wrapper.value.toLowerCase();
            config.languageList.add(wrapper);
        }
        config.troubleShootingUrl = Label.CSP_PortalPath + 'faq-article?language=en_US&q=troubleshooting';
        ISSP_CS__c cs = ISSP_CS__c.getInstance('TroubleShootingArticleId');
        if(cs != null){
            config.troubleShootingUrl = config.troubleShootingUrl + '&id1=' + cs.value__c;
        }
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
            Contact.Membership_Function__c,
            Contact.ISO_country__c,
            Contact.Country__c
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
        IATA_ISO_Country__c noCountry;
        for(IATA_ISO_Country__c iso : IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountries(), 'Name')){
            //todo align with Marc - Second Level Registration
            if (iso.Name != 'All Countries' &&  iso.Name != 'NO COUNTRY'){
                countries.add(iso);
            }else{
                if(iso.Name == 'NO COUNTRY'){
                    noCountry = iso;
                    noCountry.Name = '';
                }
            }
        }
        //add no country to the top
        if(noCountry != null){
            List<IATA_ISO_Country__c> countriesTemp = new List<IATA_ISO_Country__c>();
            countriesTemp.add(noCountry);
            countriesTemp.addAll(countries);
            countries = countriesTemp;
        }
        return new CountryInformation(countries);
    }

    @AuraEnabled//(cacheable=true)
    public static RegistrationConfirmationConfig getRegistrationConfirmationConfig(){
        RegistrationConfirmationConfig config = new RegistrationConfirmationConfig();

        User loggedUser = CSP_Utils.getLoggedUser();
        List<Contact> contactList = [SELECT Id, Email, FirstName, LastName, Phone, Preferred_Language__c, ISO_Country__c, Account.Sector__c, Account.Category__c, Account.is_General_Public_Account__c FROM Contact WHERE Id =:loggedUser.contactId LIMIT 1];
        if(!contactList.isEmpty()){
            config.contact = contactList.get(0);
            config.selectedCustomerType = getCustomerTypeFromSectorAndCategory(config.contact.Account.Sector__c, config.contact.Account.Category__c);
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
                //check for general public..
                config.sector = selectedMetadataCustomerType.Parent__c;
                config.category = selectedMetadataCustomerType.Filter_on_Category__c;
                config.extraChoice = selectedMetadataCustomerType.DeveloperName;
            }
            config.isGeneralPublic = config.contact.Account.is_General_Public_Account__c;
        }
        config.contactLabelMap = getContactLabels();
        config.accountLabelMap = getAccountLabels();
        config.countryInfo = getISOCountries();
        config.languageList = new List<CSP_Utils.PickListWrapper>();

        for(Preferred_Language_on_ISS_Portal__c portalLang : Preferred_Language_on_ISS_Portal__c.getAll().values()) {
            CSP_Utils.PickListWrapper wrapper = new CSP_Utils.PickListWrapper(portalLang.Language__c, portalLang.Language__c);
            config.languageList.add(wrapper);
        }
        config.troubleShootingUrl = Label.CSP_PortalPath + 'faq-article?language=en_US&q=troubleshooting';
        ISSP_CS__c cs = ISSP_CS__c.getInstance('TroubleShootingArticleId');
        if(cs != null){
            config.troubleShootingUrl = config.troubleShootingUrl + '&id1=' + cs.value__c;
        }
        return config;

    }

    @AuraEnabled
    public static String getCustomerTypeFromSectorAndCategory(String sector, String category){
        if(sector == null || category == null){
            return null;
        }

        List<GCS_CustomerType> customerTypesList = GCS_CustomerType.getCustomerTypesMap().values();
        for(GCS_CustomerType customerType : customerTypesList){
            if((customerType.metadataCustomerType.Created_Account_Sector__c == sector && customerType.metadataCustomerType.Created_Account_Category__c == category)
                    || (customerType.metadataCustomerType.Filter_on_Sector__c == sector && customerType.metadataCustomerType.Filter_on_Category__c == category)){
                return customerType.metadataCustomerType.DeveloperName;
            }
        }
        return null;
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

    public static boolean sendConfirmationEmailVF(RegistrationParameters params, string lang){
        Boolean result = false;
        string oneTimeUrl = generateOneTimeUrl(params);
        string userId = UserInfo.getUserId();

        Map<String, String> emailMap = generateEmailBodyParamsForConfirmation(params, oneTimeUrl);

        string langKey = 'en_US';
        if (lang != null && lang != ''){
            for(Preferred_Language_on_ISS_Portal__c portalLang : Preferred_Language_on_ISS_Portal__c.getAll().values()){
                if(portalLang.language__c == lang){
                    langKey = portalLang.languageLocalKey__c;
                }
            }
        }

        List<User> userList =  [SELECT Id FROM User WHERE languagelocalekey =:langKey LIMIT 1];
        if(!userList.isEmpty()){
            userId = userList.get(0).Id;
        }

        result = sendEmailVF(params.email, 'CSP_New_Member_Confirmation_Email_VF', emailMap, userId);
        return result;
    }

    public static boolean sendRegistrationEmailVF(RegistrationParameters params, string userId){
        Boolean result = false;
        String portalUrl = '';
        if(Network.getNetworkId() != null) portalUrl = Network.getLoginURL(Network.getNetworkId()).substring(0,Network.getLoginURL(Network.getNetworkId()).indexOf('/login'));
        string profileUrl = portalUrl + '/my-profile?triggerL2=true';

        if (userId == null || userId == ''){
            userId = UserInfo.getUserId();
            List<User> userList =  [SELECT Id FROM User WHERE languagelocalekey =:params.language LIMIT 1];
            if(!userList.isEmpty()){
                userId = userList.get(0).Id;
            }
        }

        Map<String, String> emailMap = generateEmailBodyParamsForRegistration(params, portalUrl, profileUrl);
        result = sendEmailVF(params.email, 'CSP_New_Member_Welcome_Email_VF', emailMap, userId);
        return result;
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
            params.selectedCustomerType = (inputMap.get('selectedCustomerType') != null) ? string.valueOf(inputMap.get('selectedCustomerType')) : '';
            params.registrationTime = string.valueOf(DateTime.Now());


            if(params.contactId.length() < 1){
                if(params.email.length() < 1 || params.firstName.length() < 1 || params.lastName.length() < 1){
                    result.isSuccess = false;
                    result.message = 'Missing required fields';
                    return result;
                }
            }

            //Find Bucket Account
            if(params.accountId.length() < 1){
                BucketAccountDetail bucketAccount = getBucketAccount(selectedMetadataCustomerType, params.country);
                if(bucketAccount.acc == null){
                    result.isSuccess = false;
                    result.message = 'Failed to find bucket account';
                    return result;
                }else{
                    params.accountId = bucketAccount.acc.Id;
                    params.isNewAccount = bucketAccount.isNewAccount;
                }
            }


            //Create or find Contact
            Contact con;
            if(params.contactId.length() < 1){
                con = createContact(params);
            }else{
                con = [SELECT Id, AccountId, firstName, LastName, Phone, Email, Preferred_Language__c FROM Contact WHERE ID=: contactId LIMIT 1];
                params.firstName = con.firstName;
            }

            if(con == null){
                result.isSuccess = false;
                result.message = 'Failed to create contact';
                return result;
            }


            //Create User
            OneIdUtils.Mode mode = OneIdUtils.MODE.CSP;
            NewUserDetail usr = createNewUser(con, string.valueOf(mode), con.Preferred_Language__c, null, false, true);
            system.debug('usr: ' + usr);
            if(usr.userId!= null) {
                Database.rollback(sp);
                result.isSuccess = true;
                result.portalUserId = usr.userId;
                result.userName = usr.userName;

                //Send Confirmation Email
                result.isSuccess = sendConfirmationEmailVF(params, con.Preferred_Language__c);
                if(result.isSuccess == false){
                    result.message = 'Error sending Confirmation Email';
                }
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

            //Check for Bucket Account
            if(params.isNewAccount == true){
                GCS_Customer_Type_For_Registration__mdt selectedMetadataCustomerType = getMetadataCustomerType(params.selectedCustomerType);
                BucketAccountDetail bucketAccount = getBucketAccount(selectedMetadataCustomerType, params.country);
                if(bucketAccount.acc == null){
                    result.isSuccess = false;
                    result.message = 'Failed to find bucket account';
                    return result;
                }else{
                    params.accountId = bucketAccount.acc.Id;
                }
            }

            //Create or find Contact
            Contact con;
            Boolean registrationRequired = false;
            if(params.contactId == null || params.contactId == ''){
                con = createContact(params);
            }else{
                con = [SELECT Id, AccountId, firstName, LastName, Phone, Email, Preferred_Language__c FROM Contact WHERE ID=: params.contactId LIMIT 1];
                params.firstName = con.firstName;
                //if the account is a bucket account, force user to confirm L1 on the portal when loggedin
                //Boolean isGeneralPublic = [SELECT is_General_Public_Account__c FROM Account WHERE Id = :params.accountId LIMIT 1].is_General_Public_Account__c;
                //if(isGeneralPublic == true){
                registrationRequired = true;
                //}
            }

            if(con == null){
                result.isSuccess = false;
                result.message = 'Failed to create contact';
                return result;
            }

            result.isGeneralPublicAccount = [SELECT is_general_public_account__c FROM Account WHERE ID =: params.accountId LIMIT 1].is_general_public_account__c;

            //Create User
            OneIdUtils.Mode mode = OneIdUtils.MODE.CSP;
            NewUserDetail usr = createNewUser(con, string.valueOf(mode), con.Preferred_Language__c, password, registrationRequired, false);

            if(usr.userId != null) {
                result.isSuccess = true;
                result.portalUserId = usr.userId;
                result.userName = usr.userName;

                //Send Confirmation Email
                //result.isSuccess = sendRegistrationEmail(params);
                result.isSuccess = sendRegistrationEmailVF(params, usr.userId);
                if(result.isSuccess == false){
                    result.message = 'Error sending Registration Email';
                }
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
    public static RegistrationResult updateContactInfo(string registrationForm, string customerType, boolean customerTypeChanged){

        RegistrationResult result = new RegistrationResult();
        Savepoint sp = Database.setSavepoint();
        //update contact info & bucket account relation

        try{

            Map<String, Object> inputMap = (Map<String, Object>)JSON.deserializeUntyped(registrationForm);
            GCS_Customer_Type_For_Registration__mdt selectedMetadataCustomerType = (GCS_Customer_Type_For_Registration__mdt) JSON.deserialize(customerType, GCS_Customer_Type_For_Registration__mdt.class);

            Id contactId = string.valueOf(inputMap.get('contactId'));

            if(contactId == null){
                result.isSuccess = false;
                result.message = 'Error Finding Contact';
                return result;
            }

			Contact con = [SELECT Id, Community__c FROM Contact WHERE Id =: contactId LIMIT 1];

            if(customerTypeChanged == true){
                //Find Bucket Account
                string country = (inputMap.get('country') != null) ? string.valueOf(inputMap.get('country')) : '';
                BucketAccountDetail bucketAccount = getBucketAccount(selectedMetadataCustomerType, country);
                if(bucketAccount.acc == null){
                    result.isSuccess = false;
                    result.message = 'Failed to find bucket account';
                    return result;
                }else{
                    con.AccountId = bucketAccount.acc.Id;
                }
            }

            if(inputMap.get('country') != null && inputMap.get('country') != ''){
                con.ISO_Country__c = string.valueOf(inputMap.get('country'));
            }else{
                List<IATA_ISO_Country__c> countryList = [SELECT ID FROM IATA_ISO_Country__c WHERE Name = 'NO COUNTRY' LIMIT 1];
                if(!countryList.isEmpty()){
                    con.ISO_Country__c = countryList.get(0).Id;
                }
            }

            if((inputMap.get('firstName') != null)){
                con.FirstName = string.valueOf(inputMap.get('firstName'));
            }

            if((inputMap.get('lastName') != null)){
                con.LastName = string.valueOf(inputMap.get('lastName'));
            }

            if((inputMap.get('phone') != null)){
                con.Phone = string.valueOf(inputMap.get('phone'));
            }

            if(String.isBlank(con.Community__c)){
                con.Community__c = 'ISS Customer Portal';
            }

            con.User_Portal_Status__c = 'Pending Approval';

            if((inputMap.get('language') != null)){
                con.Preferred_Language__c = string.valueOf(inputMap.get('language'));
                string langKey = 'en_US';
                for(Preferred_Language_on_ISS_Portal__c portalLang : Preferred_Language_on_ISS_Portal__c.getAll().values()){
                    if(portalLang.language__c == con.Preferred_Language__c){
                        langKey = portalLang.languageLocalKey__c;
                    }
                }

                User usr = new User(Id = UserInfo.getUserId());
                usr.LanguageLocaleKey = langKey;
                usr.LocaleSidKey = langKey;
                DataBase.SaveResult sr = DataBase.update(usr);
                if(sr.isSuccess() == false){
                    for(Database.Error objErr : sr.getErrors()) {
                        System.debug('Portal Level 1 registration Confirmation - update user: ' + objErr.getStatusCode() + ': ' + objErr.getMessage());
                    }
                    result.isSuccess = false;
                    result.message = 'Failed to update user';
                    return result;
                }
            }

            DataBase.SaveResult sr = DataBase.update(con);
            if(sr.isSuccess() == false){
                for(Database.Error objErr : sr.getErrors()) {
                    System.debug('Portal Level 1 registration Confirmation - update contact: ' + objErr.getStatusCode() + ': ' + objErr.getMessage());
                }
                Database.rollback(sp);
                result.isSuccess = false;
                result.message = 'Failed to update Contact';
                return result;
            }else{
                result.isSuccess = true;
                return result;
            }


        }catch(Exception e){
            Database.rollback(sp);
            result.isSuccess = false;
            result.message = e.getMessage();
            return result;
        }

    }

    public static BucketAccountDetail getBucketAccount(GCS_Customer_Type_For_Registration__mdt selectedMetadataCustomerType, string country){

        BucketAccountDetail accDetail = new BucketAccountDetail();

        String sector = '';
        String category = '';

        if(selectedMetadataCustomerType.Can_Account_Be_Created__c == true){
            sector = selectedMetadataCustomerType.Created_Account_Sector__c;
            category = selectedMetadataCustomerType.Created_Account_Category__c;
        }else{
            sector = selectedMetadataCustomerType.Filter_on_Sector__c;
            category = selectedMetadataCustomerType.Filter_on_Category__c;
        }

        String accountQuery = '';
        accountQuery +='SELECT Id, Sector__c, Category__c';
        accountQuery +=' FROM Account';
        accountQuery +=' WHERE Id != null AND Is_General_Public_Account__c = true';

        if(!String.isEmpty(country)){
            accountQuery +=' AND IATA_ISO_Country__c =\''+ country +'\'';
        }else{
            //if country field is empty, look for NO COUNTRY record
            List<IATA_ISO_Country__c> countryList = [SELECT Id FROM IATA_ISO_Country__c WHERE Name = 'NO COUNTRY' LIMIT 1];
            if(!countryList.isEmpty()){
                accountQuery +=' AND IATA_ISO_Country__c =\''+ countryList.get(0).Id +'\'';
            }

        }

        if(!String.isEmpty(sector)){
            accountQuery +=' AND Sector__c =\''+ sector +'\'';
        }
        if(!String.isEmpty(category)){
            accountQuery +=' AND Category__c =\''+ category +'\'';
        }

        List<Account> accList = new List<Account>();

        accList = Database.query(accountQuery);

        if(accList.isEmpty()){
            Account acc = new Account();
            acc.Reason_for_creation__c = 'Created by customer';
            //acc.Comments_Reason_for_creation__c = 'General Public Account';
            acc.ownerid = ISSP_Constant.newAccountOwnerId;
            acc.recordtypeid = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
            acc.Name = sector + ' - ' + category;
            acc.Sector__c = sector;
            acc.Category__c = category;
            acc.Is_General_Public_Account__c = true;
            //acc.IsPartner = true;

            if(!String.isEmpty(country)) {
                String countryCode = [SELECT ISO_Code__c FROM IATA_ISO_Country__c WHERE ID =: country LIMIT 1].ISO_Code__c;
                acc.Name = acc.Name + ' - ' + countryCode;
                acc.Site = countryCode;
                acc.IATA_ISO_Country__c = country;
            }else{
                List<IATA_ISO_Country__c> countryList = [SELECT Id, ISO_Code__c FROM IATA_ISO_Country__c WHERE Name = 'NO COUNTRY' LIMIT 1];
                if(!countryList.isEmpty()){
                    acc.Name = acc.Name + ' - ' + countryList.get(0).ISO_Code__c;
                    acc.Site = countryList.get(0).ISO_Code__c;
                    acc.IATA_ISO_Country__c = countryList.get(0).Id;
                }

            }

            DataBase.SaveResult sr = DataBase.insert(acc);
            if(sr.isSuccess() == false){
                for(Database.Error objErr : sr.getErrors()) {
                    System.debug('Portal Level 1 registration Confirmation - create bucket account: ' + objErr.getStatusCode() + ': ' + objErr.getMessage());
                }
                accDetail.acc = null;
                accDetail.isNewAccount = false;
                return accDetail;
            }else{
                acc.IsPartner = true;
                update acc;
                accDetail.acc = acc;
                accDetail.isNewAccount = true;
                return accDetail;
            }


        }else{
            accDetail.acc = accList.get(0);
            accDetail.isNewAccount = false;
            return accDetail;
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

            if(params.country == null || params.country == ''){
                List<IATA_ISO_Country__c> countryList = [SELECT Id FROM IATA_ISO_Country__c WHERE Name = 'NO COUNTRY' LIMIT 1];
                if(!countryList.isEmpty()){
                    params.country = countryList.get(0).Id;
                }
            }


            con.AccountId = params.accountId;
            con.ISO_Country__c = params.country;
            con.firstName = params.firstName;
            con.lastName = params.lastName;
            con.Phone = params.phone;
            con.Email = params.email;
            con.Community__c = 'ISS Customer Portal';
			con.User_Portal_Status__c = 'Pending Approval';
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

    public static NewUserDetail createNewUser(Contact con, string community, string lang, string password, boolean registrationRequired, boolean simulation){

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
            u.Portal_Registration_Required__c = registrationRequired;
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

            string langKey = 'en_US';
            if (lang != null && lang != ''){
                for(Preferred_Language_on_ISS_Portal__c portalLang : Preferred_Language_on_ISS_Portal__c.getAll().values()){
                    if(portalLang.language__c == lang){
                        langKey = portalLang.languageLocalKey__c;
                    }
                }
            }

            u.languagelocalekey = langKey;
            usr.userId = Site.createPortalUser(u, accountId, password, false);
            if(Test.isRunningTest()){
                u.ContactId = con.Id;
                u.alias = u.CommunityNickname.left(8);
                u.TimeZoneSidKey = 'America/Los_Angeles';
                u.localesidkey = 'en_US';
                u.emailencodingkey = 'UTF-8';
                DataBase.SaveResult sr = DataBase.insert(u);
                system.debug('sr: ' + sr);
                usr.userId = u.Id;
            }
            usr.userName = u.username;

            if(simulation == false){
                List<PermissionSet> permissionList = [SELECT Id FROM PermissionSet WHERE Name = 'ISSP_SSO'];
                if(permissionList.size() > 0){
                    addPermissionToUser(permissionList.get(0).Id, usr.userId);
                }

                //Check user permissions for FAQs, reassign if needed
                PortalFAQsSharingCtrl.validateUserFAQsPermissions(usr.userId);
            }

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

    public static Map<String,String> generateEmailBodyParamsForConfirmation(RegistrationParameters params, string oneTimeLink){

        String headerImageName = Label.CSP_Email_Header_Image;
        String footerImageName = Label.CSP_Email_Footer_Image;
        String headerImageUrl;
        String footerImageUrl;
        Map<String,Id> docNameIdMap = new Map<String,Id>();

        for(Document doc : [Select id, name From Document Where name = :headerImageName or name= :footerImageName]){
            docNameIdMap.put(doc.name,doc.id);
        }

        if(docNameIdMap.get(headerImageName) != null) headerImageUrl = URL.getSalesforceBaseUrl().getProtocol()+'://'+System.URL.getSalesforceBaseUrl().getHost().remove('-api' )+'/servlet/servlet.ImageServer?id='+docNameIdMap.get(headerImageName)+'&oid='+userinfo.getorganizationid();
        if(docNameIdMap.get(footerImageName) != null) footerImageUrl = URL.getSalesforceBaseUrl().getProtocol()+'://'+System.URL.getSalesforceBaseUrl().getHost().remove('-api' )+'/servlet/servlet.ImageServer?id='+docNameIdMap.get(footerImageName)+'&oid='+userinfo.getorganizationid();

        Map<String, String> mapBodyParams = new map<String, String>{
                '{!HeaderUrl}'                                   => headerImageUrl,
                '{!FooterUrl}'                                   => footerImageUrl,
                '{!Receiving_User.FirstName}'                    => params.Firstname,
                '{!Community_Url}'                               => oneTimeLink,
                '{!$Label.CSP_Email_Here}'                       => Label.CSP_Email_Here,
                '{!$Label.ISSP_Email_do_not_reply}'              => Label.ISSP_Email_do_not_reply,
                '{!$Label.CSP_Dear}'                             => Label.CSP_Dear,
                '{!$Label.CSP_Email_Confirmation_Body_Part_1}'   => Label.CSP_Email_Confirmation_Body_Part_1,
                '{!$Label.CSP_Email_Confirmation_Body_Part_2}'   => Label.CSP_Email_Confirmation_Body_Part_2,
                '{!$Label.CSP_Email_Confirmation_Body_Part_3}'   => Label.CSP_Email_Confirmation_Body_Part_3,
                '{!$Label.CSP_Email_Signature_Part_1}'           => Label.CSP_Email_Signature_Part_1,
                '{!$Label.CSP_Email_Signature_Part_2}'           => Label.CSP_Email_Signature_Part_2
        };

        return mapBodyParams;

    }

    public static Map<String,String> generateEmailBodyParamsForRegistration(RegistrationParameters params, string portalUrl, string profileUrl) {

        String headerImageName = Label.CSP_Email_Header_Image;
        String footerImageName = Label.CSP_Email_Footer_Image;
        String headerImageUrl;
        String footerImageUrl;
        Map<String,Id> docNameIdMap = new Map<String,Id>();

        for(Document doc : [Select id, name From Document Where name = :headerImageName or name= :footerImageName]){
            docNameIdMap.put(doc.name,doc.id);
        }

        if(docNameIdMap.get(headerImageName) != null) headerImageUrl = URL.getSalesforceBaseUrl().getProtocol()+'://'+System.URL.getSalesforceBaseUrl().getHost().remove('-api' )+'/servlet/servlet.ImageServer?id='+docNameIdMap.get(headerImageName)+'&oid='+userinfo.getorganizationid();
        if(docNameIdMap.get(footerImageName) != null) footerImageUrl = URL.getSalesforceBaseUrl().getProtocol()+'://'+System.URL.getSalesforceBaseUrl().getHost().remove('-api' )+'/servlet/servlet.ImageServer?id='+docNameIdMap.get(footerImageName)+'&oid='+userinfo.getorganizationid();

        Map<String, String> mapBodyParams = new map<String, String>{
                '{!HeaderUrl}'                                   => headerImageUrl,
                '{!FooterUrl}'                                   => footerImageUrl,
                '{!Receiving_User.FirstName}'                    => params.Firstname,
                '{!Community_Url}'                               => profileUrl,
                '{!Portal_Url}'                                  => portalUrl,
                '{!$Label.CSP_Email_Here}'                       => Label.CSP_Email_Here,
                '{!$Label.ISSP_Email_do_not_reply}'              => Label.ISSP_Email_do_not_reply,
                '{!$Label.CSP_Dear}'                             => Label.CSP_Dear,
                '{!$Label.CSP_Email_Welcome_Part_1}'             => Label.CSP_Email_Welcome_Part_1,
                '{!$Label.CSP_Email_Welcome_Part_2}'             => Label.CSP_Email_Welcome_Part_2,
                '{!$Label.CSP_Email_Welcome_Part_3}'             => Label.CSP_Email_Welcome_Part_3,
                '{!$Label.CSP_Email_Welcome_Part_4}'             => Label.CSP_Email_Welcome_Part_4,
                '{!$Label.CSP_Email_Welcome_Part_5}'             => Label.CSP_Email_Welcome_Part_5,
                '{!$Label.CSP_Email_Signature_Part_1}'           => Label.CSP_Email_Signature_Part_1,
                '{!$Label.CSP_Email_Signature_Part_2}'           => Label.CSP_Email_Signature_Part_2
        };

        return mapBodyParams;

    }

    public static boolean sendEmailVF(String receiver, String template ,Map<String,String> mapBodyParams, string userId){

        boolean success = true;

        try{
            List<Messaging.SendEmailResult>    listEmailResult = null;
            List<Messaging.SingleEmailmessage> listSingleEmailMessages = new List<Messaging.SingleEmailmessage>();

            EmailTemplate emailTemplate = [SELECT Id,Subject,HtmlValue,Body FROM EmailTemplate WHERE DeveloperName=:template];
            Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(emailTemplate.Id, userId, null);

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

            String plainBody = message.getPlainTextBody();


            for(String key : mapBodyParams.keySet()) {
                if(plainBody <> null){
                    plainBody = plainBody.replace(key, (mapBodyParams.get(key) == null) ? '' : mapBodyParams.get(key));
                }
            }


            if(plainBody <> null){

                mail.setHtmlBody(plainBody);
            }

            mail.setSaveAsActivity(false);
            //mail.setPlainTextBody(plainBody);
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
        system.debug('oPermissionSetAssignment: ' + oPermissionSetAssignment);
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