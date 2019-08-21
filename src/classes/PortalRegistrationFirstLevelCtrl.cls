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

    public class RegistrationResult{
        @AuraEnabled
        public Boolean isSuccess{get;set;}
        @AuraEnabled
        public String message{get;set;}
        @AuraEnabled
        public Id portalUserId{get;set;}
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
            Account.Services_Rendered_Country__c,
            Account.Preferred_Language__c
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
        system.debug('email: ' + email);
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
        system.debug('userInfo: ' + userInfo);
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
        system.debug('check username availability');
        Savepoint sp = Database.setSavepoint();
        List<Profile> profileList = [SELECT Id, Name FROM Profile];
        system.debug('profileList: ' + profileList);
        system.debug('ProfileId: ' + [SELECT Id FROM Profile WHERE Name = 'ISS Portal (Partner)' LIMIT 1].Id);
        map<ID, Profile> profileMap = new map<ID, Profile> (
        [SELECT Id, Name,
                UserLicenseId,
                UserLicense.Name
        FROM Profile
        WHERE (UserLicense.Name = 'Partner Community' OR UserLicense.Name = 'Identity')]);
        system.debug('profileMap: ' + profileMap);

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
    public static RegistrationResult register(string registrationForm, string contactId, string accountId){
        RegistrationResult result = new RegistrationResult();
        //AddOrderItemComponentController.pricebookEntrySelected pbe = (AddOrderItemComponentController.pricebookEntrySelected)JSON.deserialize(pbeStr,AddOrderItemComponentController.pricebookEntrySelected.class);
        system.debug('registrationForm: ' + registrationForm);
        Map<String, Object> inputMap = (Map<String, Object>)JSON.deserializeUntyped(registrationForm);
        Contact con;
        Savepoint sp = Database.setSavepoint();

        try{

            if(contactId == null){
                //todo: find the general public account for input customer type
                Id generalPublicAccId = '0014E000012f6cm';
                con = new Contact();
                con.AccountId = generalPublicAccId;
                con.ISO_Country__c = string.valueOf(inputMap.get('country'));
                con.firstName = string.valueOf(inputMap.get('firstName'));
                con.lastName = string.valueOf(inputMap.get('lastName'));
                con.Phone = string.valueOf(inputMap.get('phone'));
                con.Email = string.valueOf(inputMap.get('email'));
                con.Preferred_Language__c = string.valueOf(inputMap.get('language'));
                con.Community__c = 'ISS Customer Portal';
                con.User_Portal_Status__c = 'Pending';
                //todo: perform field check before insert
                DataBase.SaveResult sr = DataBase.Insert(con);
                system.debug('PortalRegistrationFirstLevelCtrl -> Contact Save Result: ' + sr);
                if(sr.isSuccess() == false){
                    result.issuccess = false;
                    for(Database.Error objErr : sr.getErrors()) {
                        System.debug('The following error has occurred.');
                        System.debug(objErr.getStatusCode() + ': ' + objErr.getMessage());
                        result.message = objErr.getMessage();
                    }
                    return result;
                }

            }else{
                con = [SELECT Id, AccountId, firstName, LastName, Phone, Email FROM Contact WHERE ID=: contactId LIMIT 1];
            }

            OneIdUtils.Mode mode = OneIdUtils.MODE.CSP;
            Id userId = createNewUser(con, string.valueOf(mode), string.valueOf(inputMap.get('language')));
            system.debug('userId: ' + userId);
            if(userId!= null) {
                result.isSuccess = true;
                result.portalUserId = userId;
                return result;
            }else{
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

    public static Id createNewUser(Contact con, string community, string lang){

        String userId = null;

        try {

            String accountId = '';
            string log;
            // prepare new User
            string UID = Comm_User_Helper.NewGuid();
            string userName = ISSP_Utilities.buildPortalUserName(con.email);
            User u = new User();
            //u.Username = con.email;
            u.Community__c = community;
            u.UID__c = UID;
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
            system.debug('NICKNAME 2: ' + thisNickname);
            system.debug('NICKNAME 2 length: ' + thisNickname.length());
            u.CommunityNickname = thisNickname;

            string profileName = 'ISS Portal (Partner)';


            system.debug('profileName: ' + profileName);
            u.ProfileId = [SELECT Id FROM Profile WHERE Name =: profileName LIMIT 1].Id;
            system.debug('u.ProfileId: ' + u.ProfileId);

            //throw new transformationException('u.ProfileId: ' + u.ProfileId);

            string password;


            if(con.accountId != null)
                accountId = con.accountId;
            password = Comm_User_Helper.generateRandomString(6) + '1a';

            system.debug('u: ' + u);
            system.debug('password: ' + password);
            system.debug('accountId: ' + accountId);
            String link ;
            String cleanUsername = u.userName.replace('+', Comm_User_Helper.plusReplacer);

            if (lang != null && lang != ''){
                system.debug('LANG IN CREATE USER: ' + lang);
                if (!ISSP_Constant.languageMap.containsKey(lang)){
                    lang = 'en_US';
                    system.debug('LANG IN CREATE USER DEFAULT: ' + lang);
                }
                u.languagelocalekey = lang;
            }

            userId = Site.createPortalUser(u, accountId, password, false);
            system.debug('USERID: ' + userId);
            if (userId != null) {

                String encodedPart = 'c='+EncodingUtil.urlEncode(EncryptString(cleanUsername+Comm_User_Helper.SEPARATOR+password+Comm_User_Helper.SEPARATOR+UID), 'UTF-8');

                String template ='';
                Map<String,String> emailWrap = new Map<String,String>();

                link = OneIdUtils.getSiteCompleteUrl(OneIdUtils.Mode.IDENTITY) + '/IdentityFirstLogin?' + encodedPart;
                link += '&serviceName=ISSP';
                template = 'Identity_Portal_ISSP_New_User';
                system.debug('aqui link :::' + link);
                emailWrap = Comm_User_Helper.ISSP_PassWordBuilMessageWrapper( con ,  password ,  link,Comm_User_Helper.ONEIDENTITY, community);
                Comm_User_Helper.sendEmail( template ,emailWrap, con, community);

                List<PermissionSet> permissionList = [SELECT Id FROM PermissionSet WHERE Name = 'ISSP_SSO'];
                if(permissionList.size() > 0){
                    addPermissionToUser(permissionList.get(0).Id,userId);
                }
            }

            //this does not fit in for bucket account scenario, should be handled on L2 registration?
            //Comm_User_Helper.addDefaultAppRights(con,con.Account);

            return userId;


        } catch (exception ex) {
            system.debug('Portal Level 1 registration - Site.createPortalUser(u, accountId,null, true):');
            //transformationHelper.sendSFDevsAlertMessage('error ' ,  '   con  ' +    con +  '   ' +ex.getmessage() + '   '+ ex.getstackTraceString(),  new list<string>{'sfdcadmin@iata.org'});
            return userId;
        }

    }

    @future
    public static void addPermissionToUser(Id permissionSetId, Id userId){

        PermissionSetAssignment oPermissionSetAssignment = new PermissionSetAssignment();
        oPermissionSetAssignment.AssigneeId = userId;
        oPermissionSetAssignment.PermissionSetId = permissionSetId;
        insert oPermissionSetAssignment;
    }

    public static String EncryptString( String str) {
        Blob dataToEncrypt = Blob.valueOf(str);
        Blob encryptedData = Crypto.encryptWithManagedIV('AES128', EncodingUtil.base64Decode(Comm_User_Helper.KEYTODECODE), dataToEncrypt);
        return EncodingUtil.base64Encode(encryptedData);
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
                system.debug('customerType: ' + customerType);
                system.debug('customerType.subCategorizationLabel: ' + customerType.subCategorizationLabel);
                system.debug('customerType.metadataCustomerType: ' + customerType.metadataCustomerType);
                system.debug('customerType.metadataCustomerType.DeveloperName: ' + customerType.metadataCustomerType.DeveloperName);

                if (!customerType.children.isEmpty()) {
                    CustomerTypePicklist picklist = new CustomerTypePicklist(customerType.subCategorizationLabel);
                    picklist.picklistName = customerType.metadataCustomerType.sub_categorization_custom_label__c;
                    picklist.picklistOptions.add(new CustomerTypePicklistOption(customerType.metadataCustomerType.DeveloperName, customerType.subCategorizationPlaceholder, previousCustomerType == null));

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