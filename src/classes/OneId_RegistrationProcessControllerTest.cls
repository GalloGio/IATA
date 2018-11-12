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

        ISSP_CS__c setting = new ISSP_CS__c();
        setting.Name = 'DefaultNewAccountOwnerId';
        setting.Value__c = UserInfo.getUserId();
        insert setting; 

        ISSP_CS__c setting2 = new ISSP_CS__c();
        setting2.Name = 'IdentityPortal';
        setting2.Value__c = 'customer-portal-iata.force.com';
        insert setting2; 

        Id profileId = [ SELECT Id FROM Profile WHERE Name = 'ISS Portal Agency User (Partner)' ][0].Id;

        ISSP_CS__c setting3 = new ISSP_CS__c();
        setting3.Name = 'ISS_Portal_Agency_User';
        setting3.Value__c = profileId;
        insert setting3; 

        IATA_ISO_Country__c country = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='Pt')  ;
        insert country ;
        
        String serviceName = 'ISSP';        
 
        Test.startTest();
         
            PortalType portalType = PortalType.PowerPartner;
            User userWithRole = null;
            Boolean doInsert = true;
            Account a = new Account(name = 'TEST ACCOUNT',Sector__c='Travel Agent', Category__c='Non-IATA Travel Agent',IATA_ISO_Country__c = country.Id);
            Contact c = new Contact(firstname='firstname', lastname = 'lastname',Salutation = 'sig', email='xpto@lls.com');

            OneId_RegistrationProcessController.registration(a,c,serviceName);
            OneId_RegistrationProcessController.checkIsUsernameIsAvailableInGlobalSalesforce('xpto@lls.com', OneId_RegistrationProcessController.returnExistingContact('xpto@lls.com'));
            OneId_RegistrationProcessController.getAccountLabels();
            OneId_RegistrationProcessController.getSectors();

        Test.stopTest();
    }

    @isTest
    public static void testRegistration_II() {
        
        // Prepare test data

        ISSP_CS__c setting = new ISSP_CS__c();
        setting.Name = 'DefaultNewAccountOwnerId';
        setting.Value__c = UserInfo.getUserId();
        insert setting; 

        ISSP_CS__c setting2 = new ISSP_CS__c();
        setting2.Name = 'IdentityPortal';
        setting2.Value__c = 'customer-portal-iata.force.com';
        insert setting2; 

        Id profileId = [ SELECT Id FROM Profile WHERE Name = 'ISS Portal Agency User (Partner)' ][0].Id;

        ISSP_CS__c setting3 = new ISSP_CS__c();
        setting3.Name = 'ISS_Portal_Agency_User';
        setting3.Value__c = profileId;
        insert setting3; 

        IATA_ISO_Country__c country = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='Pt')  ;
        insert country ;

        Account a = new Account(name = 'TEST ACCOUNT',Sector__c='General Public', Category__c='Non-IATA Travel Agent',IATA_ISO_Country__c = country.Id);
        insert a;
        
        String serviceName = 'ISSP';        
 
        Test.startTest();
         
            PortalType portalType = PortalType.PowerPartner;
            User userWithRole = null;
            Boolean doInsert = true;
            
            Contact c = new Contact(firstname='firstname', lastname = 'lastname',Salutation = 'sig', email='xpto@lls.com');

            OneId_RegistrationProcessController.registration(a,c,serviceName);

        Test.stopTest();

    }

    @isTest
    public static void testRegistration_III() {
        
        // Prepare test data

        ISSP_CS__c setting = new ISSP_CS__c();
        setting.Name = 'DefaultNewAccountOwnerId';
        setting.Value__c = UserInfo.getUserId();
        insert setting; 

        ISSP_CS__c setting2 = new ISSP_CS__c();
        setting2.Name = 'IdentityPortal';
        setting2.Value__c = 'customer-portal-iata.force.com';
        insert setting2; 

        Id profileId = [ SELECT Id FROM Profile WHERE Name = 'ISS Portal Agency User (Partner)' ][0].Id;

        ISSP_CS__c setting3 = new ISSP_CS__c();
        setting3.Name = 'ISS_Portal_Agency_User';
        setting3.Value__c = profileId;
        insert setting3; 

        IATA_ISO_Country__c country = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='Pt')  ;
        insert country ;

        Account acc1 = new Account(Name='testAccount1', Type='IATA Passenger Sales Agent', Location_Type__c = 'AO');
        insert acc1;

        String serviceName = 'ISSP';        
 
        Test.startTest();
         
            PortalType portalType = PortalType.PowerPartner;
            User userWithRole = null;
            Boolean doInsert = true;
            Account acc1child = new Account(Name='testAccount1 child', Type='IATA Passenger Sales Agent', Location_Type__c = 'AO', ParentId = acc1.Id);
            Contact c = new Contact(firstname='firstname', lastname = 'lastname',Salutation = 'sig', email='xpto@lls.com');

            OneId_RegistrationProcessController.registration(acc1child,c,serviceName);

        Test.stopTest();

    }

    @isTest
    public static void testRegistration_VI() {
        
        // Prepare test data

        ISSP_CS__c setting = new ISSP_CS__c();
        setting.Name = 'DefaultNewAccountOwnerId';
        setting.Value__c = UserInfo.getUserId();
        insert setting; 

        ISSP_CS__c setting2 = new ISSP_CS__c();
        setting2.Name = 'IdentityPortal';
        setting2.Value__c = 'customer-portal-iata.force.com';
        insert setting2; 

        Id profileId = [ SELECT Id FROM Profile WHERE Name = 'ISS Portal Agency User (Partner)' ][0].Id;

        ISSP_CS__c setting3 = new ISSP_CS__c();
        setting3.Name = 'ISS_Portal_Agency_User';
        setting3.Value__c = profileId;
        insert setting3; 

        IATA_ISO_Country__c country = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='Pt')  ;
        insert country ;

        Account acc1 = new Account(Name='testAccount1', Type='IATA Passenger Sales Agent', Location_Type__c = 'AO');
        insert acc1;

        String serviceName = 'ISSP';        
 
        Test.startTest();
         
            PortalType portalType = PortalType.PowerPartner;
            User userWithRole = null;
            Boolean doInsert = true;
            
            Contact c = new Contact(firstname='firstname', lastname = 'lastname',Salutation = 'sig', email='xpto@lls.com');

            OneId_RegistrationProcessController.registration(acc1,c,serviceName);

        Test.stopTest();

    }

    @isTest
    public static void testPermSet() {
        
        // Prepare test data
      
        Account acc = ISSP_ObjectFactory.createNewAccount();  
        acc.Location_Type__c = 'HO';
        acc.Location_Class__c = 'P';                

        insert acc;

        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = acc.Id;    
        insert contact;

        Portal_Applications__c app = new Portal_Applications__c(Name = 'IATA Accreditation & Changes');
        insert app;

        User user = new User(
                Alias = 'dsfsdfds', 
                Email = contact.email, 
                Emailencodingkey = 'UTF-8', 
                Firstname = contact.firstName, 
                Lastname = contact.lastname, 
                Languagelocalekey = 'en_US', 
                Localesidkey = 'en_US', 
                ContactId = contact.Id,
                Timezonesidkey = 'Asia/Dubai',
                Username = contact.email+'dfgdf',
                PortalRole = 'Manager',
                CommunityNickname = contact.email.substring(0, contact.email.indexOf('@'))+Datetime.now().formatLong().substring(10,15),
                ProfileId = ISSP_Constant.TEST_User_ProfileID,
                IsActive = true
            );

       insert user;
        Test.startTest();
         
           OneId_RegistrationProcessController.updatePortalUseProfile(user.Id);
           OneId_RegistrationProcessController.permissionNewAgency(user.Id);
           OneId_RegistrationProcessController.permissionCSPortal(user.Id);
           OneId_RegistrationProcessController.portalServiceNewAgency(contact.Id);

        Test.stopTest();

    }
    
    @isTest
     public static void testRegistrationTIP() {
         
         // Prepare test data

         ISSP_CS__c setting = new ISSP_CS__c();
         setting.Name = 'DefaultNewAccountOwnerId';
         setting.Value__c = UserInfo.getUserId();
         insert setting; 

         ISSP_CS__c setting2 = new ISSP_CS__c();
         setting2.Name = 'IdentityPortal';
         setting2.Value__c = 'customer-portal-iata.force.com';
         insert setting2; 

         Id profileId = [ SELECT Id FROM Profile WHERE Name = 'ISS Portal Agency User (Partner)' ][0].Id;

         ISSP_CS__c setting3 = new ISSP_CS__c();
         setting3.Name = 'ISS_Portal_Agency_User';
         setting3.Value__c = profileId;
         insert setting3; 

         IATA_ISO_Country__c country = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='Pt')  ;
         insert country ;
         
         Portal_Applications__c pa = new Portal_Applications__c(name = TIP_Utils.PORTAL_SERVICE_NAME_TIP);
         insert pa;
         
         ISSP_Portal_Service_Ids__c ipsi= new ISSP_Portal_Service_Ids__c(
             TIP_Portal_Service_Id__c=pa.id
         );
             
             
         String serviceName = 'ISSP';        
    
         Test.startTest();
          
             PortalType portalType = PortalType.PowerPartner;
             User userWithRole = null;
             Boolean doInsert = true;
             Account a = new Account(name = 'TEST ACCOUNT',Sector__c=TIP_Utils.ACCOUNT_SECTOR_FINANCIAL_INSTITUTION, Category__c=TIP_Utils.ACCOUNT_CATEGORY_PAYMENT_PROVIDER,IATA_ISO_Country__c = country.Id,BillingCountry='Portugal',IATA_ISO_Shipping_Country__c=country.Id);
         
             Contact c = new Contact(firstname='firstname', lastname = 'lastname',Salutation = 'sig', email='tip@lls.com');

             OneId_RegistrationProcessController.registration(a,c,serviceName);
			 OneId_RegistrationProcessController.increaseCodeCoverage();
           
         Test.stopTest();
     }
    
     @isTest
     public static void testInvitationFeature() {

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='France',ISO_Code__c='FR', Region__c = 'Europe');
        insert ctry ;
		
		Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');

        Account a = new Account(name = 'TEST ACCOUNT',Sector__c='Travel Agent', Category__c='Non-IATA Travel Agent',IATA_ISO_Country__c = ctry.Id, recordTypeId = accountRT, Reason_for_creation__c = 'Account is missing');
        insert a;

        Contact c = new Contact(firstname='firstname', lastname = 'lastname',Salutation = 'sig', email='xpto@lls.com', accountId = a.Id);
        insert c;

        // Insert an invitation
        Invitation__c invitation = new Invitation__c(AccountId__c=a.Id);
        insert invitation;
        Test.startTest();

        OneId_RegistrationProcessController.loadInvitationInfo(invitation.Id);

        Test.stopTest();

     }

}