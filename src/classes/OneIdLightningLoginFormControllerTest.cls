@IsTest(SeeAllData = false)
private class  OneIdLightningLoginFormControllerTest {

    public static User userFrozen;
    public static User userUnfrozen;
/*
  @IsTest
  static void createTestData() {
    
    RecordType rt = [SELECT Id FROM RecordType WHERE SobjectType='Account' AND Name = 'MACS Sales Account' LIMIT 1];
    
    // Frozen User Account
    Account accountFrozen = new Account (name= 'New TAP Account Frozen', RecordType = rt);
    upsert accountFrozen;

    // Unfrozen User Account
    Account accountUnfrozen = new Account (name= 'New TAP Account Unfrozen', RecordType = rt);
    upsert accountUnfrozen;
    
    // Frozen Contact
    Contact contactFrozen = new Contact(
      Accountid = accountFrozen.id, 
      FirstName = 'FirstNameFrozen', 
      LastName = 'LastNameFrozen', 
      Phone = 'phone', 
      Fax = 'fax', 
      Title='jobtitle', 
      Membership_Function__c='functionpick', 
      Preferred_Language__c='preferredlanguage'
    );
    upsert contactFrozen;

    Contact contactUnfrozen = new Contact(
      Accountid = accountUnfrozen.id, 
      FirstName = 'FirstNameUnFrozen', 
      LastName = 'LastNameUnFrozen', 
      Phone = 'phone', 
      Fax = 'fax', 
      Title='jobtitle', 
      Membership_Function__c='functionpick', 
      Preferred_Language__c='preferredlanguage'
    );
    upsert contactUnfrozen;

    userFrozen = new User(
     ProfileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal (Partner)'].Id,
     LastName = 'lastFrozen',
     Email = 'puser.frozen000@salesforce.com',
     Username = 'puser.frozen000@salesforce.com' + System.currentTimeMillis(),
     CompanyName = 'TestCompany',
     Title = 'Title',
     Alias = 'frozen',
     TimeZoneSidKey = 'America/Los_Angeles',
     EmailEncodingKey = 'UTF-8',
     LanguageLocaleKey = 'en_US',
     LocaleSidKey = 'en_US',
     UserRoleId = [SELECT Id  FROM UserRole WHERE DeveloperName = 'TAPPartnerUser'].Id,
     Portal_User_Frozen_Checkbox__c = true,
     ContactId=contactFrozen.Id,
     License_Cost_Center__c ='ITO005CH01'
    );
    insert userFrozen;

    userUnfrozen = new User(
     ProfileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal (Partner)'].Id,
     LastName = 'lastFrozen',
     Email = 'puser.frozen000@salesforce.com',
     Username = 'puser.frozen000@salesforce.com' + System.currentTimeMillis(),
     CompanyName = 'TestCompany',
     Title = 'Title',
     Alias = 'Unfrozen',
     TimeZoneSidKey = 'America/Los_Angeles',
     EmailEncodingKey = 'UTF-8',
     LanguageLocaleKey = 'en_US',
     LocaleSidKey = 'en_US',
     UserRoleId = [SELECT Id  FROM UserRole WHERE DeveloperName = 'TAPPartnerUser'].Id,
     Portal_User_Frozen_Checkbox__c = false,
     ContactId=contactUnfrozen.Id,
     License_Cost_Center__c ='ITO005CH01'
    );
    insert userUnfrozen;

   
 }
*/

    @testSetup static void customSettingSetup() {
        insert new ISSP_CS__c(Name = 'ipinfo_token',Value__c = '^(http:\\/\\/|https:\\/\\/)?(www.)([a-zA-Z0-9\\-]+)([.])(([a-zA-Z]{3})|([a-zA-Z]{2}))');
        insert new ISSP_CS__c(Name = 'IdentityPortal',Value__c = 'identity');
        IATA_ISO_Country__c country_i = new IATA_ISO_Country__c(Name = 'Ireland', ISO_Code__c = 'FR');
        insert country_i;

        IATA_ISO_Country__c country_r = new IATA_ISO_Country__c(Name = 'Russian Federation', ISO_Code__c = 'RU');
        insert country_r;
        ApexPages.currentPage().getHeaders().put('X-Salesforce-SIP','83.240.229.11');
        ISSP_IP_Locator__c newIP = new ISSP_IP_Locator__c();
        newIP.Start1__c = 83;
        newIP.Start2__c = 240;
        newIP.Start3__c = 229;
        newIP.Start4__c = 11;
        newIP.End1__c = 83;
        newIP.End2__c = 240;
        newIP.End3__c = 229;
        newIP.End4__c = 11;
        newIP.Country_Code__c = 'RU';
        insert newIP;

        IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(ISO_Code__c='12',Name='Italy',Region__c='Europe');
        insert isoCountry;

        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test11';
        parent.Name = 'test11';
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.ParentId = parent.Id;
        child.IATA_ISO_Country__c = isoCountry.Id ;
        child.BillingCity = 'test2';
        child.Name = 'test2111';
        child.Site = 'headSite11';
        child.Top_Parent__c = parent.Id;
        child.Sector__c = 'Airline';
        child.BillingCountry = 'Italy';
        insert child;
        System.debug('child Id: ' + child.Id);
        Contact con = ISSP_ObjectFactory.createNewContact();

        con.AccountId= child.Id;
        con.Email = 'Test@test11111.com';
        con.User_Portal_Status__c = 'Approved Admin';
        insert con;
        System.debug('con Id: ' + con.Id);
    }

    @IsTest
    static void testLoginWithInvalidCredentials() {
        OneIdLightningLoginFormController.login('testUser', 'fakepwd', null);
    }
    @IsTest
    static void testLoginWithInvalidCredentials1() {
        OneIdLightningLoginFormController.login('', 'fakepwd', null);
    }
    @IsTest
    static void testLoginWithInvalidCredentials2() {
        OneIdLightningLoginFormController.login('asas', '', null);
    }
    @IsTest
    static void testgetIsSelfRegistrationEnabled() {
        OneIdLightningLoginFormController.getIsSelfRegistrationEnabled();
    }

    @isTest
    static void testLoginWithValidCredentials() {

        IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(ISO_Code__c='PT',Name='Portugal',Region__c='Europe');
        insert isoCountry;

        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.ParentId = parent.Id;
        child.IATA_ISO_Country__c = isoCountry.Id ;
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.Top_Parent__c = parent.Id;
        child.Sector__c = 'Airline';
        child.BillingCountry = 'Italy';
        insert child;
        System.debug('child Id: ' + child.Id);
        Contact con = ISSP_ObjectFactory.createNewContact();

        /*
        con.AccountId= child.Id;
        con.Email = 'Test@test11.com';
        con.User_Portal_Status__c = 'Approved Admin';
        insert con;
        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
        con.OwnerId = newUser.Id;
        update con;

        User ui  = [SELECT id, username  FROM User where id = :newUser.id];

        //createTestData();

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        OneIdLightningLoginFormController.login(ui.username, 'fakepwd', 'https://iata--OneIdConde.cs83.my.salesforce.com/oneidentity');
        Test.stopTest();
        */

    }

    @isTest
    static void testLoginWithValidCredentialsFrozen() {
    /*
        IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(ISO_Code__c='PT',Name='Portugal',Region__c='Europe');
        insert isoCountry;

        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.ParentId = parent.Id;
        child.IATA_ISO_Country__c = isoCountry.Id ;
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.Top_Parent__c = parent.Id;
        child.Sector__c = 'Airline';
        child.BillingCountry = 'Italy';
        insert child;
        System.debug('child Id: ' + child.Id);
        Contact con = ISSP_ObjectFactory.createNewContact();

        con.AccountId= child.Id;
        con.Email = 'Test@test11.com';
        con.User_Portal_Status__c = 'Approved Admin';
        insert con;
        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
        con.OwnerId = newUser.Id;
        update con;

        User ui  = [SELECT id, username  FROM User where id = :newUser.id];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        OneIdLightningLoginFormController.login(ui.username, 'fakepwd', 'https://iata--OneIdConde.cs83.my.salesforce.com/oneidentity');
        Test.stopTest();
        */

    }

    @IsTest
    static void testReactivateUser() {



        Contact con = [select id,email,accountid,firstname,lastname from contact where email ='Test@test11111.com'];
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);

        User ui  = [SELECT id, username  FROM User where id = :newUser.id];
        OneIdLightningLoginFormController.reactivateUser(ui);
    }

    @IsTest
    static void OneIdLightningLoginFormControllerInstantiation() {
        OneIdLightningLoginFormController controller = new OneIdLightningLoginFormController();
        System.assertNotEquals(controller, null);
    }

    @IsTest
    static void testGetSiteCompleteUrl() {
        OneIdLightningLoginFormController.getSiteCompleteUrl();
    }
    @IsTest
    static void testGetSanctionCountryFalse() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        OneIdLightningLoginFormController.getSanctionCountry('83.240.229.11');
        Test.stopTest();
        System.assertEquals(false, OneIdLightningLoginFormController.getSanctionCountry('83.240.229.11'));
    }

    @IsTest
    static void testGetShow90Days() {
        OneIdLightningLoginFormController.show90Days = true;
        System.assertEquals(true, OneIdLightningLoginFormController.getShow90Days());
    }

    @IsTest
    static void testIsUsernamePasswordEnabled() {
        System.assertEquals(true, OneIdLightningLoginFormController.getIsUsernamePasswordEnabled());
    }


    @IsTest
    static void testGetSelfRegistrationURL() {
        OneIdLightningLoginFormController.getSelfRegistrationUrl();
        OneIdLightningLoginFormController.getSelfRegistrationUrl();
    }


    @IsTest
    static void testGetForgotPasswordUrl() {
        OneIdLightningLoginFormController.getForgotPasswordUrl();
    }

    @IsTest
    static void testAuthConfig() {
        Auth.AuthConfiguration authConfig = OneIdLightningLoginFormController.getAuthConfig();
        System.assertNotEquals(null, authConfig);
    }


}