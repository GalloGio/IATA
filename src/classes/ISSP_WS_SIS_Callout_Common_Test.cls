@isTest
public class ISSP_WS_SIS_Callout_Common_Test {
    
    public static void load_ISSP_CS() {
        list<ISSP_CS__c> listCS = new list<ISSP_CS__c>{
        	new ISSP_CS__c(Name='SIS_WebService_HOST_PROD', Value__c = 'host'),
        	new ISSP_CS__c(Name='SIS_WebService_USER_PROD', Value__c = 'user'),
        	new ISSP_CS__c(Name='SIS_WebService_PASS_PROD', Value__c = 'pass'),
        	new ISSP_CS__c(Name='SIS_WebService_HOST_QA', Value__c = 'host'),
        	new ISSP_CS__c(Name='SIS_WebService_USER_QA', Value__c = 'user'),
        	new ISSP_CS__c(Name='SIS_WebService_PASS_QA', Value__c = 'pass'),
            new ISSP_CS__c(Name='SIS_WebService_ON', Value__c = 'true')
        };
        insert listCS;
    }

    @TestSetup
    private static void loadData() {
        load_ISSP_CS();
    }
    
    static testMethod void test_RetrieveAccountInformation_OK() {
        ISSP_WS_SIS_Callout_AccountInfo.TEST_RESPONSE = '<Response><IsSuccess>true</IsSuccess></Response>';
        String SISMemberID = '1';
        
        Test.startTest();
        ISSP_WS_SIS_Callout_AccountInfo.ResponseData response = ISSP_WS_SIS_Callout_AccountInfo.RetrieveAccountInformation(SISMemberID);
        ISSP_Web_Service_Log__c log = ISSP_WS_SIS_Callout_AccountInfo.createLog(response);
        Test.stopTest();
        
        System.assertEquals('ISSP_WS_SIS_Callout', log.Web_Service__c);
        System.assertEquals('RetrieveAccountInformation', log.Method__c);
        System.assertEquals(true, log.Success__c);
    }
    
    static testMethod void test_RetrieveAccountInformation_ERROR() {
        ISSP_WS_SIS_Callout_AccountInfo.TEST_RESPONSE = null;
        String SISMemberID = '1';
        
        Test.startTest();
        ISSP_WS_SIS_Callout_AccountInfo.ResponseData response = ISSP_WS_SIS_Callout_AccountInfo.RetrieveAccountInformation(SISMemberID);
        ISSP_Web_Service_Log__c log = ISSP_WS_SIS_Callout_AccountInfo.createLog(response);
        Test.stopTest();
        
        System.assertEquals('ISSP_WS_SIS_Callout', log.Web_Service__c);
        System.assertEquals('RetrieveAccountInformation', log.Method__c);
        System.assertEquals(false, log.Success__c, 'log: ' + log.Error_Message__c);
    }
    
    static testMethod void test_CreateAccount_OK1() {
        ISSP_WS_SIS_Callout_CreateAccount.TEST_RESPONSE = '<Response><IsSuccess>true</IsSuccess></Response>';
        Account account = new Account( Name = 'Test');
        
        Test.startTest();
        ISSP_WS_SIS_Callout_CreateAccount.ResponseData response = ISSP_WS_SIS_Callout_CreateAccount.createAccount(account);
        ISSP_Web_Service_Log__c log = ISSP_WS_SIS_Callout_CreateAccount.createLog(response);
        Test.stopTest();
        
        System.assertEquals('ISSP_WS_SIS_Callout', log.Web_Service__c);
        System.assertEquals('CreateAccount', log.Method__c);
        //System.assertEquals(true, log.Success__c, 'log: ' + log);
    }
    
    static testMethod void test_CreateAccount_OK2() {
        ISSP_WS_SIS_Callout_CreateAccount.TEST_RESPONSE = '<Response><IsSuccess>true</IsSuccess></Response>';
        Account account = new Account(
            IATACode__c = 'AA',
            Airline_designator__c = 'AA',
            Name = 'Test',
            TradeName__c = 'Test',
            BillingStreet = 'Street',
            BillingCity = 'City',
            BillingState = 'State',
            BillingPostalCode = '8888'
        );
        insert account;
/*
        account = Database.query(
            'SELECT Id, Recordtype.DeveloperName, BillingAddress, Sector__c, Category__c, Country_ISO_Code__c,'
            +' Airline_designator__c, IATACode__c, SIS_Status__c, Name, SIS_Sub_Status__c, TradeName__c, VAT_Number_2__c,'
            +' VAT_Number__c, BillingStreet, BillingState, BillingPostalCode, BillingLongitude, BillingLatitude, BillingCountry,'
            +' BillingCity'
            +' FROM Account WHERE id = \'' + account.Id + '\'');
        
        Test.startTest();
        ISSP_WS_SIS_Callout_CreateAccount.ResponseData response = ISSP_WS_SIS_Callout_CreateAccount.createAccount(account);
        ISSP_Web_Service_Log__c log = ISSP_WS_SIS_Callout_CreateAccount.createLog(response);
        Test.stopTest();
        
        System.assertEquals('ISSP_WS_SIS_Callout', log.Web_Service__c);
        System.assertEquals('CreateAccount', log.Method__c);
        System.assertEquals(true, log.Success__c, 'log: ' + log);
		*/
    }
    
    static testMethod void test_CreateAccount_ERROR() {
        ISSP_WS_SIS_Callout_CreateAccount.TEST_RESPONSE = null;
        Account account = null;
        
        Test.startTest();
        ISSP_WS_SIS_Callout_CreateAccount.ResponseData response = ISSP_WS_SIS_Callout_CreateAccount.createAccount(account);
        ISSP_Web_Service_Log__c log = ISSP_WS_SIS_Callout_CreateAccount.createLog(response);
        Test.stopTest();
        
        System.assertEquals('ISSP_WS_SIS_Callout', log.Web_Service__c);
        System.assertEquals('CreateAccount', log.Method__c);
        System.assertEquals(false, log.Success__c, '' + log.Error_Message__c);
    }
    
    static testMethod void test_UpdateAccount_OK1() {
        ISSP_WS_SIS_Callout_UpdateAccount.TEST_RESPONSE = '<Response><IsSuccess>true</IsSuccess></Response>';
        Account account = new Account(
            Name = 'test'
        );
        
        Test.startTest();
        ISSP_WS_SIS_Callout_UpdateAccount.ResponseData response = ISSP_WS_SIS_Callout_UpdateAccount.UpdateAccount(account);
        ISSP_Web_Service_Log__c log = ISSP_WS_SIS_Callout_UpdateAccount.createLog(response);
        Test.stopTest();
        
        System.assertEquals('ISSP_WS_SIS_Callout', log.Web_Service__c);
        //System.assertEquals('UpdateAccount', log.Method__c);
        //System.assertEquals(true, log.Success__c, 'log: ' + log);
    }
    
    static testMethod void test_UpdateAccount_OK2() {
        ISSP_WS_SIS_Callout_UpdateAccount.TEST_RESPONSE = '<Response><IsSuccess>true</IsSuccess></Response>';
        Account account = new Account(
            Name = 'test',
            BillingStreet = 'Street',
            BillingCity = 'City',
            BillingState = 'State',
            BillingPostalCode = '8888',
            SIS_ID__c = '123456'
        );
        insert account;
        /*
        account = Database.query(
            'SELECT Id, Country_ISO_Code__c, Airline_designator__c, IATACode__c, SIS_Status__c, Name, Status__c, '
            + ' SIS_Sub_Status__c, TradeName__c, VAT_Number_2__c, VAT_Number__c, BillingAddress, BillingStreet, BillingState, BillingCity,'
            + ' BillingPostalCode, BillingLongitude, BillingLatitude, BillingCountry, SIS_ID__c'
            +' FROM Account WHERE id = \'' + account.Id + '\'');
        
        Test.startTest();
        ISSP_WS_SIS_Callout_UpdateAccount.ResponseData response = ISSP_WS_SIS_Callout_UpdateAccount.UpdateAccount(account);
        ISSP_Web_Service_Log__c log = ISSP_WS_SIS_Callout_UpdateAccount.createLog(response);
        Test.stopTest();
        
        System.assertEquals('ISSP_WS_SIS_Callout', log.Web_Service__c);
        System.assertEquals('UpdateAccount', log.Method__c);
        System.assertEquals(true, log.Success__c, 'log: ' + log);
		*/
    }
    
    static testMethod void test_UpdateAccount_Terminated_OK() {
        ISSP_WS_SIS_Callout_UpdateAccount.TEST_RESPONSE = '<Response><IsSuccess>true</IsSuccess></Response>';
        Account account = new Account(
            Name = 'test',
            BillingStreet = 'Street',
            BillingCity = 'City',
            BillingState = 'State',
            BillingPostalCode = '8888',
            SIS_ID__c = '123456',
            Status__c = 'Terminated'
        );
        insert account;
        /*
        account = Database.query(
            'SELECT Id, Country_ISO_Code__c, Airline_designator__c, IATACode__c, SIS_Status__c, Name, Status__c, '
            + ' SIS_Sub_Status__c, TradeName__c, VAT_Number_2__c, VAT_Number__c, BillingAddress, BillingStreet, BillingState, BillingCity,'
            + ' BillingPostalCode, BillingLongitude, BillingLatitude, BillingCountry, SIS_ID__c'
            +' FROM Account WHERE id = \'' + account.Id + '\'');
        
        Test.startTest();
        ISSP_WS_SIS_Callout_UpdateAccount.ResponseData response = ISSP_WS_SIS_Callout_UpdateAccount.UpdateAccount(account);
        ISSP_Web_Service_Log__c log = ISSP_WS_SIS_Callout_UpdateAccount.createLog(response);
        Test.stopTest();
        
        System.assertEquals('ISSP_WS_SIS_Callout', log.Web_Service__c);
        System.assertEquals('UpdateAccount', log.Method__c);
        System.assertEquals(true, log.Success__c, 'log: ' + log);
		*/
    }
    
    static testMethod void test_UpdateAccount_ERROR() {
        ISSP_WS_SIS_Callout_UpdateAccount.TEST_RESPONSE = null;
        Account account = null;
        
        Test.startTest();
        ISSP_WS_SIS_Callout_UpdateAccount.ResponseData response = ISSP_WS_SIS_Callout_UpdateAccount.UpdateAccount(account);
        ISSP_Web_Service_Log__c log = ISSP_WS_SIS_Callout_UpdateAccount.createLog(response);
        Test.stopTest();
        
        System.assertEquals('ISSP_WS_SIS_Callout', log.Web_Service__c);
        System.assertEquals('UpdateAccount', log.Method__c);
        System.assertEquals(false, log.Success__c, 'log: ' + log.Error_Message__c);
    }
    
    static testMethod void test_CreateUser_OK() {
        ISSP_WS_SIS_Callout_CreateUser.TEST_RESPONSE = '<Response><IsSuccess>true</IsSuccess></Response>';
        User user = new User(
            FederationIdentifier = '1234567',
            FirstName = 'firstname',
            LastName = 'lastname',
            Email = 'test@email.com'
        );
        Contact contact = new Contact(
            SIS_Contact_Type__c = 'type'
        );
        
        Test.startTest();
        ISSP_WS_SIS_Callout_CreateUser.ResponseData response = ISSP_WS_SIS_Callout_CreateUser.CreateUser(user, contact);
        ISSP_Web_Service_Log__c log = ISSP_WS_SIS_Callout_CreateUser.createLog(response);
        Test.stopTest();
        
        System.assertEquals('ISSP_WS_SIS_Callout', log.Web_Service__c);
        System.assertEquals('CreateUser', log.Method__c);
        System.assertEquals(true, log.Success__c, 'log: ' + log);
    }
    
    static testMethod void test_CreateUser_ERROR() {
        ISSP_WS_SIS_Callout_CreateUser.TEST_RESPONSE = null;
        User user = null;
        Contact contact = null;
        
        Test.startTest();
        ISSP_WS_SIS_Callout_CreateUser.ResponseData response = ISSP_WS_SIS_Callout_CreateUser.CreateUser(user, contact);
        ISSP_Web_Service_Log__c log = ISSP_WS_SIS_Callout_CreateUser.createLog(response);
        Test.stopTest();
        
        System.assertEquals('ISSP_WS_SIS_Callout', log.Web_Service__c);
        System.assertEquals('CreateUser', log.Method__c);
        System.assertEquals(false, log.Success__c, 'log: ' + log.Error_Message__c);
    }
    
    static testMethod void test_UpdateUser_OK() {
        ISSP_WS_SIS_Callout_UpdateUser.TEST_RESPONSE = '<Response><IsSuccess>true</IsSuccess></Response>';
        User user = new User(
            FederationIdentifier = '1234567',
            FirstName = 'firstname',
            LastName = 'lastname',
            Email = 'test@email.com'
        );
        Contact contact = new Contact(
            FirstName = 'firstname',
            LastName = 'lastname',
            Email = 'test@email.com'
        );
        
        Test.startTest();
        ISSP_WS_SIS_Callout_UpdateUser.ResponseData response = ISSP_WS_SIS_Callout_UpdateUser.UpdateUser(user, contact);
        ISSP_Web_Service_Log__c log = ISSP_WS_SIS_Callout_UpdateUser.createLog(response);
        Test.stopTest();
        
        System.assertEquals('ISSP_WS_SIS_Callout', log.Web_Service__c);
        System.assertEquals('UpdateUser', log.Method__c);
        System.assertEquals(true, log.Success__c, 'log: ' + log);
    }
    
    static testMethod void test_UpdateUser_ERROR() {
        ISSP_WS_SIS_Callout_UpdateUser.TEST_RESPONSE = null;
        User user = null;
        Contact contact = null;
        
        Test.startTest();
        ISSP_WS_SIS_Callout_UpdateUser.ResponseData response = ISSP_WS_SIS_Callout_UpdateUser.UpdateUser(user,contact);
        ISSP_Web_Service_Log__c log = ISSP_WS_SIS_Callout_UpdateUser.createLog(response);
        Test.stopTest();
        
        System.assertEquals('ISSP_WS_SIS_Callout', log.Web_Service__c);
        System.assertEquals('UpdateUser', log.Method__c);
        System.assertEquals(false, log.Success__c, 'log: ' + log.Error_Message__c);
    }
    
    static testMethod void test_ActivateUser_OK() {
        ISSP_WS_SIS_Callout_ActivateUser.TEST_RESPONSE = '<Response><IsSuccess>true</IsSuccess></Response>';
        User user = new User(
            FederationIdentifier = '1234567'
        );
        
        Test.startTest();
        ISSP_WS_SIS_Callout_ActivateUser.ResponseData response = ISSP_WS_SIS_Callout_ActivateUser.ActivateUser(user);
        ISSP_Web_Service_Log__c log = ISSP_WS_SIS_Callout_ActivateUser.createLog(response);
        Test.stopTest();
        
        System.assertEquals('ISSP_WS_SIS_Callout', log.Web_Service__c);
        System.assertEquals('ActivateUser', log.Method__c);
        System.assertEquals(true, log.Success__c, 'log: ' + log);
    }
    
    static testMethod void test_ActivateUser_ERROR() {
        ISSP_WS_SIS_Callout_ActivateUser.TEST_RESPONSE = null;
        User user = null;
        
        Test.startTest();
        ISSP_WS_SIS_Callout_ActivateUser.ResponseData response = ISSP_WS_SIS_Callout_ActivateUser.ActivateUser(user);
        ISSP_Web_Service_Log__c log = ISSP_WS_SIS_Callout_ActivateUser.createLog(response);
        Test.stopTest();
        
        System.assertEquals('ISSP_WS_SIS_Callout', log.Web_Service__c);
        System.assertEquals('ActivateUser', log.Method__c);
        System.assertEquals(false, log.Success__c, 'log: ' + log.Error_Message__c);
    }
    
    static testMethod void test_DeactivateUser_OK() {
        ISSP_WS_SIS_Callout_ActivateUser.TEST_RESPONSE = '<Response><IsSuccess>true</IsSuccess></Response>';
        User user = new User(
            FederationIdentifier = '1234567'
        );
        
        Test.startTest();
        ISSP_WS_SIS_Callout_ActivateUser.ResponseData response = ISSP_WS_SIS_Callout_ActivateUser.DeactivateUser(user);
        ISSP_Web_Service_Log__c log = ISSP_WS_SIS_Callout_ActivateUser.createLog(response);
        Test.stopTest();
        
        System.assertEquals('ISSP_WS_SIS_Callout', log.Web_Service__c);
        System.assertEquals('DeactivateUser', log.Method__c);
        System.assertEquals(true, log.Success__c, 'log: ' + log);
    }
    
    static testMethod void test_DeactivateUser_ERROR() {
        ISSP_WS_SIS_Callout_ActivateUser.TEST_RESPONSE = null;
        User user = null;
        
        Test.startTest();
        ISSP_WS_SIS_Callout_ActivateUser.ResponseData response = ISSP_WS_SIS_Callout_ActivateUser.DeactivateUser(user);
        ISSP_Web_Service_Log__c log = ISSP_WS_SIS_Callout_ActivateUser.createLog(response);
        Test.stopTest();
        
        System.assertEquals('ISSP_WS_SIS_Callout', log.Web_Service__c);
        System.assertEquals('DeactivateUser', log.Method__c);
        System.assertEquals(false, log.Success__c, 'log: ' + log.Error_Message__c);
    }
    
    static testMethod void test_InfoAccount_Exception() {
        ISSP_WS_SIS_Callout_ActivateUser.TEST_RESPONSE = null;
        delete [SELECT Id FROM ISSP_CS__c];
        
        Test.startTest();
        ISSP_WS_SIS_Callout_AccountInfo.ResponseData response = ISSP_WS_SIS_Callout_AccountInfo.RetrieveAccountInformation(null);
        System.assertEquals(false, response.IsSuccess, '' + response);
        Test.stopTest();
    }
    
    static testMethod void test_CreateAccount_Exception() {
        ISSP_WS_SIS_Callout_ActivateUser.TEST_RESPONSE = null;
        delete [SELECT Id FROM ISSP_CS__c];
        
        Test.startTest();
        ISSP_WS_SIS_Callout_CreateAccount.ResponseData response = ISSP_WS_SIS_Callout_CreateAccount.CreateAccount(null);
        System.assertEquals(false, response.IsSuccess);
        Test.stopTest();
    }
    
    static testMethod void test_UpdateAccount_Exception() {
        ISSP_WS_SIS_Callout_ActivateUser.TEST_RESPONSE = null;
        delete [SELECT Id FROM ISSP_CS__c];
        
        Test.startTest();
        ISSP_WS_SIS_Callout_UpdateAccount.ResponseData response = ISSP_WS_SIS_Callout_UpdateAccount.UpdateAccount(null);
        System.assertEquals(false, response.IsSuccess);
        Test.stopTest();
    }
    
    
    static testMethod void test_CreateUser_Exception() {
        ISSP_WS_SIS_Callout_ActivateUser.TEST_RESPONSE = null;
        delete [SELECT Id FROM ISSP_CS__c];
        
        Test.startTest();
        ISSP_WS_SIS_Callout_CreateUser.ResponseData response = ISSP_WS_SIS_Callout_CreateUser.CreateUser(null,null);
        System.assertEquals(false, response.IsSuccess);
        Test.stopTest();
    }
    
    static testMethod void test_UpdateUser_Exception() {
        ISSP_WS_SIS_Callout_ActivateUser.TEST_RESPONSE = null;
        delete [SELECT Id FROM ISSP_CS__c];
        
        Test.startTest();
        ISSP_WS_SIS_Callout_UpdateUser.ResponseData response = ISSP_WS_SIS_Callout_UpdateUser.UpdateUser(null, null);
        System.assertEquals(false, response.IsSuccess);
        Test.stopTest();
    }
    
    static testMethod void test_ActivateUser_Exception() {
        ISSP_WS_SIS_Callout_ActivateUser.TEST_RESPONSE = null;
        delete [SELECT Id FROM ISSP_CS__c];
        
        Test.startTest();
        ISSP_WS_SIS_Callout_ActivateUser.ResponseData response = ISSP_WS_SIS_Callout_ActivateUser.DeactivateUser(null);
        System.assertEquals(false, response.IsSuccess);
        Test.stopTest();
    }
    
    static testMethod void test_CalloutClass() {
        Test.startTest();
        new ISSP_WS_SIS_Callout.ActivateUserResponse_element();
        new ISSP_WS_SIS_Callout.UpdateAccountResponse_element();
        new ISSP_WS_SIS_Callout.RetrieveAccountInformation_element();
        new ISSP_WS_SIS_Callout.UpdateAccount_element();
        new ISSP_WS_SIS_Callout.RetrieveAccountInformationResponse_element();
        new ISSP_WS_SIS_Callout.UpdateSisUserResponse_element();
        new ISSP_WS_SIS_Callout.ActivateUser_element();
        new ISSP_WS_SIS_Callout.CreateUser_element();
        new ISSP_WS_SIS_Callout.CreateUserResponse_element();
        new ISSP_WS_SIS_Callout.DeactivateUser_element();
        new ISSP_WS_SIS_Callout.UpdateSisUser_element();
        new ISSP_WS_SIS_Callout.CreateAccount_element();
        new ISSP_WS_SIS_Callout.CreateAccountResponse_element();
        new ISSP_WS_SIS_Callout.DeactivateUserResponse_element();
        new ISSP_WS_SIS_Callout.IcpWsInterfaceSoap();
        ISSP_WS_SIS_Callout.IcpWsInterfaceSoap ws = new ISSP_WS_SIS_Callout.IcpWsInterfaceSoap();
        try{ws.RetrieveAccountInformation('');} catch(Exception e){}
        try{ws.UpdateSisUser('');} catch(Exception e){}
        try{ws.ActivateUser('');} catch(Exception e){}
        try{ws.DeactivateUser('');} catch(Exception e){}
        try{ws.CreateUser('');} catch(Exception e){}
        try{ws.CreateAccount('');} catch(Exception e){}
        try{ws.UpdateAccount('');} catch(Exception e){}
        Test.stopTest();
    }
}