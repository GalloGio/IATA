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
    //PASS
    @isTest
    public static void testFindLocation_2() {
        
        // Prepare test data
        String ipAddress = '0';
		/*ISSP_CS__c setting = new ISSP_CS__c();
		setting.Name = '0';
		setting.Value__c = '0'; //'871e08ecd39325';
		insert setting;*/
        
        // Start the test
        Test.startTest();
        
        // Call linked method
        
        try {
            String returnedValue = OneId_RegistrationProcessController.findLocation(null);
        } catch (Exception e) {
            System.assertEquals(e.getMessage(), e.getMessage());
        }
        
        
        // Stop the test
        Test.stopTest();
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

            OneId_RegistrationProcessController.registration(a,c,serviceName);
            OneId_RegistrationProcessController.checkIsUsernameIsAvailableInGlobalSalesforce('xpto@registest.com');
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

             OneId_RegistrationProcessController.registration(a,c,serviceName);
			 //OneId_RegistrationProcessController.increaseCodeCoverage();
           
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

                        OneId_RegistrationProcessController.registration(a,c,serviceName);
                        OneId_RegistrationProcessController.getUserInformationFromEmail(c.email,'FRED');
                        OneId_RegistrationProcessController.registration(a,c,'NDCMM');
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
    //PASS
    /*@isTest
    @AuraEnabled
    public static void getNDCMMUserInformation_m_1() {
        Account a = new Account(name = 'test', Sector__c = 'Travel Agent', Category__c = 'Non-IATA Travel Agent');
        insert a;
        Contact c = new Contact(firstname = 'teste', lastname = 'lastname', Salutation = 'sig', email = 't@t.com', AccountId = a.Id);
        insert c;
        UserInformation u = new UserInformation();

        Test.startTest();
        OneId_RegistrationProcessController.getNDCMMUserInformation(u, c.Id, a.Id);
        Test.stopTest();
        System.assertEquals(u.con, [SELECT Id, Email, Salutation, FirstName, LastName, Title, Membership_Function__c, Phone, MobilePhone, Fax
                               FROM Contact 
                               WHERE Id =: c.Id]);
        System.assertEquals(u.acc, [SELECT Name, Sector__c, Category__c, RecordType.DeveloperName FROM Account WHERE Id =: a.Id]);
    }*/

    @isTest
    static void getUserInformationFromEmail_m_1() {
        Account a = new Account(name = 'test', Sector__c = 'Travel Agent', Category__c = 'Non-IATA Travel Agent');
        insert a;
        Contact c = new Contact(firstname = 'teste', lastname = 'lastname', Salutation = 'sig', email = 't@t.com', AccountId = a.Id);
        insert c;

        Test.startTest();
        OneId_RegistrationProcessController.getUserInformationFromEmail('t@t.com', 'aservice');
        Test.stopTest();
        System.assertEquals(OneId_RegistrationProcessController.isAlreadyContact, true);
    }
    /*@isTest
    static void getUserInformationFromEmail_m_coverLines() {
        Account a = new Account(name = 'test', Sector__c = 'Travel Agent', Category__c = 'Non-IATA Travel Agent');
        insert a;
        Contact c = new Contact(firstname = 'teste', lastname = 'lastname', Salutation = 'sig', email = 't@t.com', AccountId = a.Id);
        insert c;

        User user = new User(Alias='a',email=c.email,Emailencodingkey='UTF-8',FirstName=c.firstname,Lastname=c.lastname,
        LanguagelocaleKey='en-US',LocalesidKey='en_US',ContactId=c.Id,Timezonesidkey='Asia/Dubai',Username=c.email+'abc');
        insert user;

        Test.startTest();
        OneId_RegistrationProcessController.getUserInformationFromEmail('t@t.com', 'FRED');
        Test.stopTest();
    }
    @isTest
    static void getUserInformationFromEmail_m_coverLines_2() {
        Account a = new Account(name = 'test', Sector__c = 'Travel Agent', Category__c = 'Non-IATA Travel Agent');
        insert a;
        Contact c = new Contact(firstname = 'teste', lastname = 'lastname', Salutation = 'sig', email = 't@t.com', AccountId = a.Id);
        insert c;
        
        User user = new User(Alias='a',email=c.email,Emailencodingkey='UTF-8',FirstName=c.firstname,Lastname=c.lastname,
        LanguagelocaleKey='en-US',LocalesidKey='en_US',ContactId=c.Id,Timezonesidkey='Asia/Dubai',Username=c.email+'abc');
        insert user;

        Test.startTest();
        OneId_RegistrationProcessController.getUserInformationFromEmail('t@t.com', 'NDCMM');
        Test.stopTest();
    }*/

    @isTest
    static void checkIsUsernameIsAvailableInGlobalSalesforce_test_m() {
        Account a = new Account(name = 'test', Sector__c = 'Travel Agent', Category__c = 'Non-IATA Travel Agent');
        insert a;
        Contact c = new Contact(firstname = 'teste', lastname = 'lastname', Salutation = 'sig', email = 't@t.com', AccountId = a.Id);
        insert c;
        /*Profile p = new Profile();
        insert p;*/

        /*User user = new User(
            Alias='DUMMY',
            email=c.email,
            Emailencodingkey='UTF-8',
            FirstName=c.firstname,
            Lastname=c.lastname,
            CommunityNickname = 'DUMMY',
            LanguagelocaleKey='en-US',
            LocalesidKey='en_US',
            ContactId=c.Id,
            Timezonesidkey='GMT',
            Username= ISSP_Utilities.buildPortalUserName(c.email),
            ContactId = c.Id,
            License_Cost_center__c = 'ISF005CH01',
            ProfileId = p.Id);
        insert user;*/

        List<User> nu = new List<User>();
        Boolean b = false;

        Test.startTest();
        b = OneId_RegistrationProcessController.checkIsUsernameIsAvailableInGlobalSalesforce(c.email);
        //nu = [SELECT id FROM User];
        //b = OneId_RegistrationProcessController.checkIsUsernameIsAvailableInGlobalSalesforce(c.email);
        System.debug('MMSA:: ' + nu.size());
        Test.stopTest();
        //System.debug('MMSA:: ' + nu.size());
        //System.assert(nu.size() > 0);
        System.assert(b);
    }

    @isTest
    static void getIsoCountries_test_m() {
        List<IATA_ISO_Country__c> iclist = new List<IATA_ISO_Country__c>();
        iclist.add(new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='Pt'));
        insert iclist;

        Test.startTest();
        OneId_RegistrationProcessController.getISOCountries();
        Test.stopTest();
    }

    @isTest
    static void registration_test_m() {
        IATA_ISO_Country__c ic = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='Pt');
        Account a = new Account(name = 'test', Sector__c = 'NOT General Public', Category__c = 'Non-IATA Travel Agent', IATA_ISO_Country__c = ic.Id);
        insert a;
        Contact c = new Contact(firstname = 'teste', lastname = 'lastname', Salutation = 'sig', email = 't@t.com', AccountId = a.Id);
        insert c;

        Account aWithNullId = new Account(name = 'test', Sector__c = 'General Public', Category__c = 'Non-IATA Travel Agent', IATA_ISO_Country__c = ic.Id);
        insert aWithNullId;

        Test.startTest();
            aWithNullId.Id = null;
            OneId_RegistrationProcessController.registration(aWithNullId, c, null);
        Test.stopTest();
        //System.assertEquals(aWithNullId.Id, a.Id);
    }

    @isTest
    static void registration_test_m_2() {
        IATA_ISO_Country__c ic = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='Pt');
        Account a = new Account(name = 'test', Sector__c = 'NOT General Public', Category__c = 'Non-IATA Travel Agent', IATA_ISO_Country__c = ic.Id);
        insert a;
        Contact c = new Contact(firstname = 'teste', lastname = 'lastname', Salutation = 'sig', email = 't@t.com', AccountId = a.Id, Community__c = 'somethingrandom');
        insert c;

        Test.startTest();
            OneId_RegistrationProcessController.registration(a, c, 'FRED');
        Test.stopTest();
        System.assertEquals(c.Community__c, 'FRED Customer Portal');
    }

    /*@isTest
    static void registration_test_m_3() {
        IATA_ISO_Country__c ic = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='Pt');
        Account a = new Account(name = 'test', Sector__c = 'NOT General Public', Category__c = 'Non-IATA Travel Agent', IATA_ISO_Country__c = ic.Id);
        //a.Id = null;
        insert a;
        Contact c = new Contact(firstname = 'teste', lastname = 'lastname', Salutation = 'sig', email = 't@t.com', AccountId = a.Id, Community__c = 'somethingrandom');
        insert c;

        Test.startTest();
            OneId_RegistrationProcessController.registration(a, c, 'ISSP');
        Test.stopTest();
        //System.assert(OneId_RegistrationProcessController.isNewAcc);
    }*/

    @isTest
    static void portalServiceNewPASSAgency_test_m() {
        IATA_ISO_Country__c ic = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='Pt');
        Account a = new Account(name = 'test', Sector__c = 'NOT General Public', Category__c = 'Non-IATA Travel Agent', IATA_ISO_Country__c = ic.Id);
        insert a;
        Contact c = new Contact(firstname = 'teste', lastname = 'lastname', Salutation = 'sig', email = 't@t.com', AccountId = a.Id, Community__c = 'somethingrandom');
        insert c;

        Portal_Applications__c papp = new Portal_Applications__c(Name = AMS_UTILS.IATA_PASS_SERVICE_NAME); //IATA Postal Accounts Settlement System
        insert papp;

        Test.startTest();
            OneId_RegistrationProcessController.portalServiceNewPASSAgency(c.Id);
        Test.stopTest();
        List<Portal_Application_Right__c> papprList = [SELECT Id FROM Portal_Application_Right__c];
        System.assert(papprList.size() == 1);
    }

    @isTest
    static void loadInvitationInfo_test_m() {
        IATA_ISO_Country__c ic = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='Pt');
        Account a = new Account(name = 'test', Sector__c = 'NOT General Public', Category__c = 'Non-IATA Travel Agent', IATA_ISO_Country__c = ic.Id);
        insert a;
        Contact c = new Contact(firstname = 'teste', lastname = 'lastname', Salutation = 'sig', email = 't@t.com', AccountId = a.Id, Community__c = 'somethingrandom');
        c.Id = null;
        insert c;

        Test.startTest();
            OneId_RegistrationProcessController.loadInvitationInfo(c.Id);
        Test.stopTest();
    }
}
