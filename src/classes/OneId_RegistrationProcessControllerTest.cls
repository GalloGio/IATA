@isTest
private class OneId_RegistrationProcessControllerTest {

     /**
     * Attribute
     */
    enum PortalType { CSPLiteUser, PowerPartner, PowerCustomerSuccess, CustomerSuccess }
    
     /**
     * Methods to help for portal user creation
     */
    /*private static testmethod void usertest() {
        User pu = getPortalUser(PortalType.PowerPartner, null, true);
        System.assert([select isPortalEnabled 
                         from user 
                        where id = :pu.id].isPortalEnabled,
                      'User was not flagged as portal enabled.');
        
        System.RunAs(pu) {
            System.assert([select isPortalEnabled 
                             from user 
                            where id = :UserInfo.getUserId()].isPortalEnabled, 
                          'User wasnt portal enabled within the runas block. ');
        }
    }*/
    
    @isTest
    public static void testGetHostURL() {
        
        // Start the test
        Test.startTest();
        
        // Call linked method
        String returnedValue = OneId_RegistrationProcessController.getHostURL();
        
        // Stop the test
        Test.stopTest();
        
        // Check that we have data
        System.assertNotEquals(returnedValue, null);
        
    }

    @isTest
    public static void testGetCommunityName() {
        
        // Start the test
        Test.startTest();
        
        // Call linked method
        String returnedValue = OneId_RegistrationProcessController.getCommunityName();
        
        // Stop the test
        Test.stopTest();
        
        // Check that we have data
        System.assertNotEquals(returnedValue, null);
        
    }

    @isTest
    public static void testFindLocation() {
        
        // Prepare test data
        String ipAddress = '92.104.157.175';
		ISSP_CS__c setting = new ISSP_CS__c();
		setting.Name = 'ipinfo_token';
		setting.Value__c = '871e08ecd39325';
		insert setting;
        
        // Start the test
        Test.startTest();
        
        // Call linked method
        Test.setMock(HttpCalloutMock.class, new IpinfoioMockImpl());
        String returnedValue = OneId_RegistrationProcessController.findLocation(ipAddress);
        
        // Stop the test
        Test.stopTest();
        
        // Check that we have data
        System.assertNotEquals(returnedValue, null);
        
    }

    @isTest
    public static void testCheckIsUsernameIsAvailableInGlobalSalesforce() {
        
        // Prepare test data
        String email = 'admin@iata.org';
        
        // Start the test
        Test.startTest();
        
        // Call linked method
        //Boolean returnedValue = OneId_RegistrationProcessController.checkIsUsernameIsAvailableInGlobalSalesforce(email);
        
        // Stop the test
        Test.stopTest();
        
        // Check that we have data
        //System.assertNotEquals(returnedValue, null);
        
    }

    @isTest
    public static void testGetContactLabels() {
        
        // Start the test
        Test.startTest();
        
        // Call linked method
        Map<String,String> returnedValue = OneId_RegistrationProcessController.getContactLabels();
        
        // Stop the test
        Test.stopTest();
        
        // Check that we have data
        System.assertNotEquals(returnedValue, null);
        
    }

    @isTest
    public static void testGetContactJobFunctionValues() {
        
        // Start the test
        Test.startTest();
        
        // Call linked method
        List<String> returnedValue = OneId_RegistrationProcessController.getContactJobFunctionValues();
        
        // Stop the test
        Test.stopTest();
        
        // Check that we have data
        System.assertNotEquals(returnedValue, null);
        
    }

    @isTest
    public static void testGetISOCountries() {
        
        // Start the test
        Test.startTest();
        
        // Call linked method
        OneId_RegistrationProcessController.CountryInformation returnedValue = OneId_RegistrationProcessController.getISOCountries();
        
        // Stop the test
        Test.stopTest();
        
        // Check that we have data
        System.assertNotEquals(returnedValue, null);
        
    }

    @isTest
    public static void testRegistration() {
        
        // Prepare test data
        //UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' LIMIT 1];
		//Profile profile = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Agency User (Partner)'];
		//Account account = new Account(Name = 'TestAccount');
        //insert account;
        //Contact contact = new Contact(LastName = 'TestLastName');
        //insert contact;
		// User user = new User(Alias = 'TestAl', LastName = 'TestLastName', Username = 'admin@iata.org', Email = 'admin@iata.org', TimeZoneSidKey = 'America/Los_Angeles', Localesidkey = 'en_US', Emailencodingkey = 'UTF-8', Languagelocalekey = 'en_US', ProfileId = profile.Id, License_Cost_Center__c = 'ISF005CH01', ContactId = contact.Id);
        //User user = [Select Id from User WHERE Profile_Name__c = 'ISS Portal Agency User (Partner)' LIMIT 1];
        //User user = [Select Id from User WHERE UserRoleId = :portalRole.Id AND Profile_Name__c = 'ISS Portal Agency User (Partner)' LIMIT 1];
        //insert user;
		//String password = '123123';
        String serviceName = 'ISSP';
        //String languageString = 'en_US';
        
        // Start the test
        Test.startTest();
        
        // ...
         
        PortalType portalType = PortalType.PowerPartner;
        User userWithRole = null;
        Boolean doInsert = true;

        Account a = new Account(name = 'TEST ACCOUNT');
        Contact c = new Contact(AccountId = a.id, lastname = 'lastname');
        
        /* Get any profile for the given type.*/
        Profile p = [select id 
                     from profile 
                     where usertype = :portalType.name() 
                     limit 1];
        
        /*User pu = new User(profileId = p.id, username = 'testemail', email = 'testemail@test.com', 
                           emailencodingkey = 'UTF-8', localesidkey = 'en_US', 
                           languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles', 
                           alias='cspu', lastname='lastname', contactId = c.id);*/
        
                UserRole r = new UserRole(name = 'TEST ROLE');
        Database.insert(r);
        
        userWithRole = new User(alias = 'hasrole', email='userwithrole@roletest1.com', userroleid = r.id,
                                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                localesidkey='en_US', profileid = UserInfo.getProfileId(), 
                                timezonesidkey='America/Los_Angeles', username='userwithrole@testorg.com',
                                License_Cost_Center__c = 'ISF005CH01', contactId = c.id);
        
        //System.runAs(userWithRole) {
        System.runAs(new User(Id = Userinfo.getUserId())) {

            
            Database.insert(a);
            
            
            Database.insert(c);

        
        Database.insert(userWithRole);
            
        }
        
        ////////////////////////
        
		//List<User> userContacts = [SELECT Id FROM User WHERE ContactId = :pu.Id LIMIT 1];
        //Contact contact = [SELECT Id FROM Contact WHERE Id = :userContacts[0].Id];
        //Account account = contact.Account;
        
        // Call linked methods
        Boolean returnedValue = OneId_RegistrationProcessController.registration(a, c, serviceName);
        
        //OneId_RegistrationProcessController.sendWelcomeEmail(contact, user, password, serviceName);
        //OneId_RegistrationProcessController.updatePortalUseProfile((String)user.Id);
        //OneId_RegistrationProcessController.permissionNewAgency((String)user.Id);
        //OneId_RegistrationProcessController.permissionCSPortal((String)user.Id);
        //OneId_RegistrationProcessController.portalServiceNewAgency((String)contact.Id);
        
        // Stop the test
        Test.stopTest();
        
        // Check that we have data
        //System.assertNotEquals(returnedValue, null);
        
    }

}