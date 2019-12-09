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
        List<OneId_RegistrationProcessController.PicklistEntry> returnedValue = OneId_RegistrationProcessController.getContactJobFunctionValues();
        
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

            OneId_RegistrationProcessController.registration(a,c,serviceName, new Map<String, String>(), false);
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

            OneId_RegistrationProcessController.registration(a,c,serviceName, new Map<String, String>(), false);

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

            OneId_RegistrationProcessController.registration(acc1child,c,serviceName, new Map<String, String>(), false);

        Test.stopTest();

    }

    @isTest
    public static void testRegistration_IV() {
        
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

            OneId_RegistrationProcessController.registration(acc1,c,serviceName, new Map<String, String>(), false);

        Test.stopTest();

    }

    @isTest
    public static void testRegistration_V() {
        
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

        Account a = new Account(name = 'TEST ACCOUNT',Sector__c='Airline Supplier', Category__c='Fuel Supplier',IATA_ISO_Country__c = country.Id);
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
        
        String serviceName = 'ISSP';        
 
        Test.startTest();
         
            PortalType portalType = PortalType.PowerPartner;
            User userWithRole = null;
            Boolean doInsert = true;
            Account a = new Account(name = 'TEST ACCOUNT',Sector__c='Airline Supplier', Category__c='Fuel Supplier',IATA_ISO_Country__c = country.Id);
            Contact c = new Contact(firstname='firstname', lastname = 'lastname',Salutation = 'sig', email='xpto@lls.com');

            OneId_RegistrationProcessController.registration(a,c,serviceName);
            OneId_RegistrationProcessController.checkIsUsernameIsAvailableInGlobalSalesforce('xpto@registest.com');
            OneId_RegistrationProcessController.getAccountLabels();
            OneId_RegistrationProcessController.getSectors();

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
           OneId_RegistrationProcessController.permissionGADMPortal(user.Id);

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
                 TIP_Portal_Service_Id__c=String.valueOf(pa.id).substring(0, 15)
         );
        insert ipsi;

        String serviceName = 'ISSP';
    
         Test.startTest();
          
             PortalType portalType = PortalType.PowerPartner;
             User userWithRole = null;
             Boolean doInsert = true;
             Account a = new Account(name = 'TEST ACCOUNT',Sector__c=TIP_Utils.ACCOUNT_SECTOR_FINANCIAL_INSTITUTION, Category__c=TIP_Utils.ACCOUNT_CATEGORY_PAYMENT_PROVIDER,IATA_ISO_Country__c = country.Id,BillingCountry='Portugal',IATA_ISO_Shipping_Country__c=country.Id);
         
             Contact c = new Contact(firstname='firstname', lastname = 'lastname',Salutation = 'sig', email='tip@lls.com');

             OneId_RegistrationProcessController.registration(a,c,serviceName, new Map<String, String>(), false);
			 //OneId_RegistrationProcessController.increaseCodeCoverage();
           
         Test.stopTest();
     }

    @isTest
    public static void testRegistrationGADM() {

        // Prepare test data
        Account_Roles__c accountRoles = new Account_Roles__c();
        accountRoles.Name = 'GADM Participant';
        insert accountRoles;

        Id externalRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact_Roles__c', 'External');

        Contact_Roles__c contactRoles = new Contact_Roles__c();
        contactRoles.Name = 'GADM User';
        contactRoles.RecordTypeId = externalRecordTypeId;
        insert contactRoles;

        Contact_Roles__c contactRoles2 = new Contact_Roles__c();
        contactRoles2.Name = 'Power User';
        contactRoles2.RecordTypeId = externalRecordTypeId;
        insert contactRoles2;

        Portal_Applications__c portalApplications = new Portal_Applications__c();
        portalApplications.Name = 'GADM';
        insert portalApplications;

        Account_Role_Services__c accountRoleServices = new Account_Role_Services__c();
        accountRoleServices.Portal_Service__c = portalApplications.Id;
        accountRoleServices.Account_Roles__c = accountRoles.Id;
        insert accountRoleServices;

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

        String serviceName = 'GADM';

        Test.startTest();

        Contact c = new Contact(firstname='firstname', lastname = 'lastname',Salutation = 'sig', email='xpto@lls.com');

        OneId_RegistrationProcessController.registration(acc1,c,serviceName, new Map<String, String>{'isPowerUser' =>'true'}, false);

        Test.stopTest();
    }

    @isTest
    public static void testRegistrationACLI() {

        // Prepare test data

        ISSP_CS__c setting = new ISSP_CS__c();
        setting.Name = 'DefaultNewAccountOwnerId';
        setting.Value__c = UserInfo.getUserId();
        insert setting;

        ISSP_CS__c setting2 = new ISSP_CS__c();
        setting2.Name = 'IdentityPortal';
        setting2.Value__c = 'customer-portal-iata.force.com';
        insert setting2;

        Id profileId = [ SELECT Id FROM Profile WHERE Name = 'ISS Portal Airline User (Partner)' ][0].Id;

        ISSP_CS__c setting3 = new ISSP_CS__c();
        setting3.Name = 'ISS_Portal_Airline_User';
        setting3.Value__c = profileId;
        insert setting3;

        IATA_ISO_Country__c country = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='Pt')  ;
        insert country ;

        Portal_Applications__c pa = new Portal_Applications__c(name = ISSP_AMC_DAO.PORTAL_SERVICE_NAME_ACLI);
        insert pa;

        ISSP_Portal_Service_Ids__c ipsi= new ISSP_Portal_Service_Ids__c(
                ACLI_IATA_Airlines_and_Location_Codes__c=String.valueOf(pa.id).substring(0, 15)
        );
        insert ipsi;

        String serviceName = 'ISSP';


        Contact c;

        Portal_Applications__c p = new Portal_Applications__c(Name='One Id NDC Matchmaker');
        insert p;

        User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];


            System.runAs(myUser)
            {
                User user1 = ISSP_AMC_ParticipationFactory.portalSetup();    
                
                Portal_Application_Right__c par = new Portal_Application_Right__c(Portal_Application__c = p.Id, Right__c = 'Access Granted', Contact__c = [SELECT ID FROM CONTACT LIMIT 1].Id);
        		insert par;
    
        		Id recordTypeId = Schema.SObjectType.One_Id_Service_Provider_Config__c.getRecordTypeInfosByDeveloperName().get('Service_Provider').getRecordTypeId();

        		One_Id_Service_Provider_Config__c oispc = new One_Id_Service_Provider_Config__c(Portal_Service__c = pa.Id, Service_Provider_Name__c='NDCMM', RecordTypeId = recordTypeId);
        
        		insert oispc;

                Contact con = new Contact(firstname='firstname', lastname = 'lastname',Salutation = 'sig', email='xpto2@lls.com');
                insert con;    
                
                System.runAs(user1){
                    PortalType portalType = PortalType.PowerPartner;
                    User userWithRole = null;
                    Boolean doInsert = true;
                    Account a = new Account(name = 'TEST ACCOUNT',Sector__c='Airline', Category__c='Passenger and Cargo',IATA_ISO_Country__c = country.Id,BillingCountry='Portugal',IATA_ISO_Shipping_Country__c=country.Id);


                c = new Contact(firstname='firstname', lastname = 'lastname',Salutation = 'sig', email='tip@lls.com');

                Test.startTest();

                        OneId_RegistrationProcessController.registration(a,c,serviceName, false);
                        OneId_RegistrationProcessController.getUserInformationFromEmail(c.email,'FRED');
                        OneId_RegistrationProcessController.registration(a,c,'NDCMM', false);
                        OneId_RegistrationProcessController.getUserInformationFromEmail(con.email,'NDCMM');
                    	OneId_RegistrationProcessController.getUserInformationFromEmail(c.email,'ISSP');

                Test.stopTest();
            }
        }



        List<User> aUser = [select id, profile.name from user where contactId = :c.id];

        System.debug(aUser);
    }

    @isTest
    public static void getCoverageOnOthersCode() {
        insert new IATA_ISO_Country__c(ISO_Code__c='FR');
        IATA_ISO_Country__c isoCountry = [select id from IATA_ISO_Country__c WHERE ISO_Code__c = 'FR'][0];
        list<Account> accs = new list<Account>{
                new Account(
                        name= 'Air France',
                        recordTypeId = [SELECT Id FROM RecordType WHERE developerName = 'IATA_Airline'][0].Id,
                        IATA_ISO_Country__c = isoCountry.Id

                ),
                new Account(
                        name= 'FR',
                        recordTypeId = [SELECT Id FROM RecordType WHERE developerName = 'ICAO_Member_State'][0].Id,
                        IATA_ISO_Country__c = isoCountry.Id

                ),
                new Account(
                        name= 'Verifier1',
                        recordTypeId = [SELECT Id FROM RecordType WHERE developerName = 'Verifiers'][0].Id,
                        IATA_ISO_Country__c = isoCountry.Id

                )
        };
        Insert accs;

        // Insert an invitation
        Invitation__c invitation = new Invitation__c(AccountId__c=accs[2].Id); // the verifier account inserted previously
        insert invitation;

        Test.startTest();

        OneId_RegistrationProcessController.loadInvitationInfo(invitation.id);
        OneId_AddressDoctor.AddressInfo add = new OneId_AddressDoctor.AddressInfo();
        add.addressComplete = 'Rua da Treta, 22, ';
        add.houseNumber = '22';
        add.street = 'Rua da Treta';
        add.postalCode = '1700-121';
        String info = JSON.serialize(add);

        Test.setMock(HttpCalloutMock.class, new OneId_AddressDoctorMockImpl());
        OneId_RegistrationProcessController.checkAddress(info);
        //OneId_RegistrationProcessController.checkAddress(info, 'PT');


        Test.stopTest();
    }

    @IsTest
    private static void loadGadmAccountTest() {

        IATA_ISO_Country__c country = new IATA_ISO_Country__c();
        country.Name = 'Czech Republic';
        country.ISO_Code__c = 'Cs';
        country.AIMS_Area_Name__c = 'Czech Republic';
        country.AIMS_Area_ID__c = '1';
        insert country;

        Id headquarters = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;

        List<Account> accountsToInsert = new List<Account>();

        Account acc = new Account();
        acc.Name = 'Test account';
        acc.BillingCity = 'Montreal';
        acc.BillingCountry = 'Canada';
        acc.BillingStreet = 'some street';
        acc.IATA_ISO_Country__c = country.Id;
        acc.Location_Type__c = 'HO';
        acc.IATACode__c = '1234567';
        acc.Type = 'IATA Cargo Agent';
        acc.Status__c = 'Approved';
        acc.RecordTypeId = headquarters;
        accountsToInsert.add(acc);

        Account acc2 = new Account();
        acc2.Name = 'Test account 2';
        acc2.BillingCity = 'Montreal';
        acc2.BillingCountry = 'Canada';
        acc2.BillingStreet = 'some street';
        acc2.IATA_ISO_Country__c = country.Id;
        acc2.Location_Type__c = 'HO';
        acc2.IATACode__c = '1234567';
        acc2.Type = 'IATA Cargo Agent';
        acc2.Status__c = 'Approved';
        acc2.RecordTypeId = headquarters;
        accountsToInsert.add(acc2);

        insert accountsToInsert;

        Account testAccount = null;

        Test.startTest();

        testAccount = OneId_RegistrationProcessController.loadGadmAccount(acc.Id);

        Test.stopTest();


        System.assertEquals(acc.Id, testAccount.Id, 'Wrong account retrieved!');

    }

    @IsTest
    private static void loadGadmAccountNullTest() {

        IATA_ISO_Country__c country = new IATA_ISO_Country__c();
        country.Name = 'Czech Republic';
        country.ISO_Code__c = 'Cs';
        country.AIMS_Area_Name__c = 'Czech Republic';
        country.AIMS_Area_ID__c = '1';
        insert country;

        Id headquarters = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;

        List<Account> accountsToInsert = new List<Account>();

        Account acc = new Account();
        acc.Name = 'Test account';
        acc.BillingCity = 'Montreal';
        acc.BillingCountry = 'Canada';
        acc.BillingStreet = 'some street';
        acc.IATA_ISO_Country__c = country.Id;
        acc.Location_Type__c = 'HO';
        acc.IATACode__c = '1234567';
        acc.Type = 'IATA Cargo Agent';
        acc.Status__c = 'Approved';
        acc.RecordTypeId = headquarters;
        accountsToInsert.add(acc);

        insert accountsToInsert;

        Account testAccount = null;

        Test.startTest();

        testAccount = OneId_RegistrationProcessController.loadGadmAccount(null);

        Test.stopTest();


        System.assertEquals(testAccount.Id, null, 'Wrong result retrieved!');

    }

    @IsTest
    private static void getInvitationNullTest() {

        Invitation__c testInvitation = null;


        Test.startTest();

        testInvitation = OneId_RegistrationProcessController.getInvitation('');

        Test.stopTest();


        System.assertEquals(true, testInvitation != null, 'Null should be never returned!');

    }

    @IsTest
    private static void getInvitationTest() {

        IATA_ISO_Country__c country = new IATA_ISO_Country__c();
        country.Name = 'Czech Republic';
        country.ISO_Code__c = 'Cs';
        country.AIMS_Area_Name__c = 'Czech Republic';
        country.AIMS_Area_ID__c = '1';
        insert country;

        Id headquarters = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;

        List<Account> accountsToInsert = new List<Account>();

        Account acc = new Account();
        acc.Name = 'Test account';
        acc.BillingCity = 'Montreal';
        acc.BillingCountry = 'Canada';
        acc.BillingStreet = 'some street';
        acc.IATA_ISO_Country__c = country.Id;
        acc.Location_Type__c = 'HO';
        acc.IATACode__c = '1234567';
        acc.Type = 'IATA Cargo Agent';
        acc.Status__c = 'Approved';
        acc.RecordTypeId = headquarters;
        accountsToInsert.add(acc);

        insert accountsToInsert;

        Invitation__c testInvitation = new Invitation__c();
        testInvitation.AccountId__c = acc.Id;
        testInvitation.GADM_Power_User__c = true;
        insert testInvitation;


        Invitation__c returnedInvitation = new Invitation__c();

        Test.startTest();

        returnedInvitation = OneId_RegistrationProcessController.getInvitation(testInvitation.Id);

        Test.stopTest();


        System.assertEquals(testInvitation.Id, returnedInvitation.Id, 'Wrong invitation returned returned!');

    }

@isTest
     static void amsDataQuality(){
        IATA_ISO_Country__c country = new IATA_ISO_Country__c (Name='Canada',
                                                               ISO_Code__c='CA')  ;
        insert country ;

        IATA_ISO_STATE__C state = new IATA_ISO_STATE__c (Name='Quebec',
                                                         ISO_Code__c='CA-QC',
                                                         IATA_ISO_Country__c=country.Id,
                                                         GeonameName__c='Quebec',
                                                         GeonameAsciiName__c='Quebec',
                                                         GeonameId__c='6115047');
         insert state;
         IATA_ISO_City__c city = new IATA_ISO_City__c(Name = 'Montreal', 
                                                       IATA_ISO_State__c = state.ID,
                                                       GeonameID__c = '6077243',
                                                       GeonameAlternateNames__c = 'Lungsod ng Montreal,Lungsod ng Montréal,Monreal,Monreal\','+
                                                                                  'Monreala,Monrealis,Monreyal,Monreāla,Mons Regius,Mont-real,Montreal,Montreal - Montreal,Montreal - Montréal,Montreal City,Montreali,Montrealo,'+
                                                                                  'Montréal,YMQ,meng te li er,monreali,monteuliol,montorioru,mwntral,mwntryal,Μοντρεαλ,Μόντρεαλ,Монреал,Монреаль,Монтреал,מונטריאול,مونترآل,مونتریال,مونترېئال,'+
                                                                                  'მონრეალი,ᒧᕆᐊᓪ,モントリオール,蒙特利尔,몬트리올' );
        insert city;

        OneId_RegistrationProcessController.getStates('Canada');        
        OneId_RegistrationProcessController.registrationAux(new Account(), new Contact(), null, new Map<String, String>{'billingCityId' => String.valueOf(city.Id),
                                                                                                                       'billingStateId' => String.valueOf(state.Id),
                                                                                                                       'shippingCityId' => String.valueOf(city.Id),
                                                                                                                       'shippingStateId' => String.valueOf(state.Id)});
     }

     @isTest
     static void increaseCoverage(){

        Account a = new Account(name = 'TEST ACCOUNT',Sector__c='Travel Agent', Category__c='Non-IATA Travel Agent');
        insert a;

        Contact c = new Contact(firstname='firstname', lastname = 'lastname',Salutation = 'sig', email='xpto@lls.com', AccountId = a.Id);
        insert c;

        IATA_ISO_Country__c country = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='Pt')  ;
        insert country ;
         
         Account acc = OneId_RegistrationProcessController.returnRelatedAcc(a.Id);
         OneId_RegistrationProcessController.updateContactInFuture(c.Id, 'testCommunity', 'active', 'testMail@mail.com', a.Id);

         List<Account> lacc1 = OneId_RegistrationProcessController.getAccountsBySectorAndCategory('Airline', 'testcat', country.Id, 'TEST');
         List<Account> lacc2 = OneId_RegistrationProcessController.getAccountsBySectorAndCategory('Travel Agent', 'IATA Passenger Sales Agent', country.Id, 'TEST');
         List<Account> lacc3 = OneId_RegistrationProcessController.getAccountsBySectorAndCategory('Travel Agent', 'Non-IATA Travel Agent', country.Id, 'TEST');
         List<Account> lacc4 = OneId_RegistrationProcessController.getAccountsBySectorAndCategory('Non-IATA Travel Agent', 'testcat', country.Id, 'TEST');
         List<Account> lacc5 = OneId_RegistrationProcessController.getAccountsBySectorAndCategory('Airline Supplier', 'testcat', country.Id, 'TEST');
       
     }
     
     @isTest
     public static void testGetCustomerPortalUrl(){
        insert new ISSP_CS__c(Name = 'IdentityPortal',Value__c = 'identity');
        insert new ISSP_CS__c(Name = 'Host',Value__c = 'host');
        Test.startTest();
        string url = OneId_RegistrationProcessController.getCustomerPortalUrl();
        Test.stopTest();
        System.assertNotEquals(url, null);
     }
}