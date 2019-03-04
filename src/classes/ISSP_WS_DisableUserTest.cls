@isTest
private class ISSP_WS_DisableUserTest {

    private static final Profile AIRLINE_PORTAL_PROFILE = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Airline User (Partner)'];
    private static final RecordType IATA_AIRLINE_RT = RecordTypeSingleton.getInstance().getRecordType('Account', 'IATA_Airline');
    private static ISSP_Portal_Service_Ids__c APP_IDS;
    private static list<String> LIST_APP_NAMES = new list<String>{'CASS01', 'CASS02', 'CASS03', 'CASS04', 'SIS', 'ASD', 'BSPLINK'};

    @TestSetup
    private static void setup() {
        ISSP_WS_SIS_Callout_Common_Test.load_ISSP_CS();
        // insert errors in Custom Setting
        list<ISSP_Int_Error__c> listError = new list<ISSP_Int_Error__c>();
        for (Integer i=1; i<=50; i++) {
            String name = i.format().leftPad(3, '0');
            ISSP_Int_Error__c newError = new ISSP_Int_Error__c(
                Name = name,
                Error_Message__c = name
            );
            listError.add(newError);
        }
        insert listError;
        
        //insert Portal apps
        list<Portal_Applications__c> listApps = new list<Portal_Applications__c>();
        for (String appname: LIST_APP_NAMES) {
            listApps.add(new Portal_Applications__c(Name = appname));
        }
        insert listApps;
        APP_IDS = new ISSP_Portal_Service_Ids__c(Name='Apps');
        for (Portal_Applications__c app: listApps) {
            if (app.Name == 'CASS01'){
                //app = 'CASSLink Export';
                APP_IDS.CASSLinkExport__c = app.Id;
            }
            else if (app.Name == 'CASS02'){
                //app = 'CASSLink Import';
                APP_IDS.CASSLinkImport__c = app.Id;
            }
            else if (app.Name == 'CASS03'){
                //app = 'CASSLink Analytics';
                APP_IDS.CASSLinkRouteAnalyzer__c = app.Id;
            }
            else if (app.Name == 'CASS04'){
                APP_IDS.CNS_CassLink__c = app.Id;
            }
            else if (app.Name == 'SIS'){
                APP_IDS.SIS__c = app.Id;
            }
            else if (app.Name == 'ASD'){
                APP_IDS.ASD__c = app.Id;
            }
            else if (app.Name == 'BSPLINK'){
                APP_IDS.BSPLink__c = app.Id;
            }
        }
        insert APP_IDS;
        APP_IDS = ISSP_Portal_Service_Ids__c.getInstance();
        System.assert(APP_IDS!=null);
        System.assert(APP_IDS.CASSLinkExport__c!=null);
        
        //insert ISSP CS
        list<ISSP_CS__c> listIsspCs = new list<ISSP_CS__c>();
        listIsspCs.add(new ISSP_CS__c(
                Name = 'ISS_Portal_Airline_User',
                Value__c = AIRLINE_PORTAL_PROFILE.Id));
        listIsspCs.add(new ISSP_CS__c(
                Name = 'Host',
                Value__c = 'portal.iata.org'));
        listIsspCs.add(new ISSP_CS__c(
                Name = 'SIS_WebService_ON',
                Value__c = 'true'));
        insert listIsspCs;
    }
    
    private static void checkLogs(Boolean isSuccess,String method) {
        list<ISSP_Web_Service_Log__c> listLogs = [SELECT Id, Success__c, Web_Service__c, Method__c, System__c, Error_Message__c FROM ISSP_Web_Service_Log__c];
        System.assert(listLogs.size()==1, '' + listLogs);
        System.assertEquals(isSuccess, listLogs[0].Success__c, '' + listLogs[0].Error_Message__c);
        System.assertEquals('ISSP_WS_DisableUser', listLogs[0].Web_Service__c);
        System.assertEquals(method, listLogs[0].Method__c);
        System.assertEquals('SIS', listLogs[0].System__c);
    }

    private static ISSP_WS_DisableUser.UserInputData createInputData() {
        ISSP_WS_DisableUser.UserInputData inputData = new ISSP_WS_DisableUser.UserInputData();
        inputData.fedId = '123456';
        inputData.services = 'SIS';
        return inputData;
    }

    static testMethod void reactivateUser_noFederationId() {
        ISSP_WS_DisableUser.UserInputData inputData = createInputData();
        
        Test.startTest();
        inputData.fedId = '';
        ISSP_WS_DisableUser.ResponseOne response = ISSP_WS_DisableUser.reactivateUser(inputData);
        Test.stopTest();
        
        System.assertEquals(false, response.IsSuccess);
        System.assertEquals('012', response.responseErrorCode);
        
        checkLogs(false,'reactivateUser');
    }
    
    static testMethod void reactivateUser_noTypeOfService() {
        ISSP_WS_DisableUser.UserInputData inputData = createInputData();
        
        Test.startTest();
        inputData.services = '';
        ISSP_WS_DisableUser.ResponseOne response = ISSP_WS_DisableUser.reactivateUser(inputData);
        Test.stopTest();
        
        System.assertEquals(false, response.IsSuccess);
        System.assertEquals('010', response.responseErrorCode);
        
        list<ISSP_Web_Service_Log__c> listLogs = [SELECT Id, Success__c, Web_Service__c, Method__c, System__c, Error_Message__c FROM ISSP_Web_Service_Log__c];
        System.assert(listLogs.size()==1, '' + listLogs);
        System.assertEquals(false, listLogs[0].Success__c, '' + listLogs[0].Error_Message__c);
        System.assertEquals('ISSP_WS_DisableUser', listLogs[0].Web_Service__c);
        System.assertEquals('reactivateUser', listLogs[0].Method__c);
        System.assertEquals(null, listLogs[0].System__c);
    }
    
    static testMethod void reactivateUser_NoUser() {
        ISSP_WS_DisableUser.UserInputData inputData = createInputData();
        
        Test.startTest();
        inputData.fedId = '123456';
        ISSP_WS_DisableUser.ResponseOne response = ISSP_WS_DisableUser.reactivateUser(inputData);
        Test.stopTest();
        
        System.assertEquals(false, response.IsSuccess);
        System.assertEquals('011', response.responseErrorCode);
        
        checkLogs(false,'reactivateUser');
    }
    
    static testMethod void reactivateUser_OK() {
        ISSP_WS_DisableUser.UserInputData inputData = createInputData();
        
        Account account = ISSP_ObjectFactory.createNewAccount();
        account.RecordTypeId = IATA_AIRLINE_RT.Id;
        insert account;
        
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = account.Id;
        contact.FirstName = 'firstname';
        contact.LastName = 'lastname';
        contact.User_Portal_Status__c = ISSP_Constant.NEW_CONTACT_STATUS;
        contact.Email = 'test@email.com' + (Math.random()*1000000000);
        insert contact;
        
        User user = ISSP_WS_Utilities.createUser(contact.FirstName, contact.LastName, contact.email + (Math.random()*1000000000), IATA_AIRLINE_RT.developerName, contact.Id, false);
        user.FederationIdentifier = String.valueOf(contact.Id).substring(0, 15);
		insert user;
        
        delete [SELECT Id FROM ISSP_Web_Service_Log__c];
        
        Test.startTest();
        inputData.fedId = user.FederationIdentifier;
        ISSP_WS_DisableUser.ResponseOne response1 = ISSP_WS_DisableUser.reactivateUser(inputData);
        System.assertEquals(true, response1.IsSuccess);
        Test.stopTest();
        
        checkLogs(true,'reactivateUser');
    }
    
    static testMethod void reactivateUser_OK_CASS01() {
        ISSP_WS_DisableUser.UserInputData inputData = createInputData();
        
        Account account = ISSP_ObjectFactory.createNewAccount();
        account.RecordTypeId = IATA_AIRLINE_RT.Id;
        insert account;
        
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = account.Id;
        contact.FirstName = 'firstname';
        contact.LastName = 'lastname';
        contact.User_Portal_Status__c = ISSP_Constant.NEW_CONTACT_STATUS;
        contact.Email = 'test@email.com';
        insert contact;
        
        APP_IDS = ISSP_Portal_Service_Ids__c.getInstance();
        System.assert(APP_IDS!=null);
        System.assert(APP_IDS.CASSLinkExport__c!=null);
        
        Portal_Application_Right__c appRight =
            new Portal_Application_Right__c(
                Portal_Application__c = APP_IDS.CASSLinkExport__c,
                Contact__c = contact.Id,
                Right__c = 'Access Denied');
        insert appRight;
        
        User user = ISSP_WS_Utilities.createUser(contact.FirstName, contact.LastName, contact.email + (Math.random()*1000000000), IATA_AIRLINE_RT.developerName, contact.Id, false);
        user.FederationIdentifier = String.valueOf(contact.Id).substring(0, 15);
        insert user;
        
        delete [SELECT Id FROM ISSP_Web_Service_Log__c];
        
        Test.startTest();
        inputData.fedId = user.FederationIdentifier;
        inputData.services = 'CASS01';
        ISSP_WS_DisableUser.ResponseOne response1 = ISSP_WS_DisableUser.reactivateUser(inputData);
        System.assertEquals(true, response1.IsSuccess);
        Test.stopTest();
    }
    static testMethod void reactivateUser_OK_CASS02() {
        ISSP_WS_DisableUser.UserInputData inputData = createInputData();
        
        Account account = ISSP_ObjectFactory.createNewAccount();
        account.RecordTypeId = IATA_AIRLINE_RT.Id;
        insert account;
        
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = account.Id;
        contact.FirstName = 'firstname';
        contact.LastName = 'lastname';
        contact.User_Portal_Status__c = ISSP_Constant.NEW_CONTACT_STATUS;
        contact.Email = 'test@email.com';
        insert contact;
        
        APP_IDS = ISSP_Portal_Service_Ids__c.getInstance();
        System.assert(APP_IDS!=null);
        System.assert(APP_IDS.CASSLinkExport__c!=null);
        
        Portal_Application_Right__c appRight =
            new Portal_Application_Right__c(
                Portal_Application__c = APP_IDS.CASSLinkImport__c,
                Contact__c = contact.Id,
                Right__c = 'Access Denied');
        insert appRight;
        
        User user = ISSP_WS_Utilities.createUser(contact.FirstName, contact.LastName, contact.email + (Math.random()*1000000000), IATA_AIRLINE_RT.developerName, contact.Id, false);
        user.FederationIdentifier = String.valueOf(contact.Id).substring(0, 15);
        insert user;
        
        delete [SELECT Id FROM ISSP_Web_Service_Log__c];
        
        Test.startTest();
        inputData.fedId = user.FederationIdentifier;
        inputData.services = 'CASS02';
        ISSP_WS_DisableUser.ResponseOne response1 = ISSP_WS_DisableUser.reactivateUser(inputData);
        System.assertEquals(true, response1.IsSuccess);
        Test.stopTest();
    }
    static testMethod void reactivateUser_OK_CASS03() {
        ISSP_WS_DisableUser.UserInputData inputData = createInputData();
        
        Account account = ISSP_ObjectFactory.createNewAccount();
        account.RecordTypeId = IATA_AIRLINE_RT.Id;
        insert account;
        
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = account.Id;
        contact.FirstName = 'firstname';
        contact.LastName = 'lastname';
        contact.User_Portal_Status__c = ISSP_Constant.NEW_CONTACT_STATUS;
        contact.Email = 'test@email.com';
        insert contact;
        
        APP_IDS = ISSP_Portal_Service_Ids__c.getInstance();
        System.assert(APP_IDS!=null);
        System.assert(APP_IDS.CASSLinkExport__c!=null);
        
        Portal_Application_Right__c appRight =
            new Portal_Application_Right__c(
                Portal_Application__c = APP_IDS.CASSLinkRouteAnalyzer__c,
                Contact__c = contact.Id,
                Right__c = 'Access Denied');
        insert appRight;
        
        User user = ISSP_WS_Utilities.createUser(contact.FirstName, contact.LastName, contact.email + (Math.random()*1000000000), IATA_AIRLINE_RT.developerName, contact.Id, false);
        user.FederationIdentifier = String.valueOf(contact.Id).substring(0, 15);
        insert user;
        
        delete [SELECT Id FROM ISSP_Web_Service_Log__c];
        
        Test.startTest();
        inputData.fedId = user.FederationIdentifier;
        inputData.services = 'CASS03';
        ISSP_WS_DisableUser.ResponseOne response1 = ISSP_WS_DisableUser.reactivateUser(inputData);
        System.assertEquals(true, response1.IsSuccess);
        Test.stopTest();
    }
    static testMethod void reactivateUser_OK_CASS04() {
        ISSP_WS_DisableUser.UserInputData inputData = createInputData();
        
        Account account = ISSP_ObjectFactory.createNewAccount();
        account.RecordTypeId = IATA_AIRLINE_RT.Id;
        insert account;
        
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = account.Id;
        contact.FirstName = 'firstname';
        contact.LastName = 'lastname';
        contact.User_Portal_Status__c = ISSP_Constant.NEW_CONTACT_STATUS;
        contact.Email = 'test@email.com';
        insert contact;
        
        APP_IDS = ISSP_Portal_Service_Ids__c.getInstance();
        System.assert(APP_IDS!=null);
        System.assert(APP_IDS.CASSLinkExport__c!=null);
        
        Portal_Application_Right__c appRight =
            new Portal_Application_Right__c(
                Portal_Application__c = APP_IDS.CNS_CassLink__c,
                Contact__c = contact.Id,
                Right__c = 'Access Denied');
        insert appRight;
        
        User user = ISSP_WS_Utilities.createUser(contact.FirstName, contact.LastName, contact.email + (Math.random()*1000000000), IATA_AIRLINE_RT.developerName, contact.Id, false);
        user.FederationIdentifier = String.valueOf(contact.Id).substring(0, 15);
        insert user;
        
        delete [SELECT Id FROM ISSP_Web_Service_Log__c];
        
        Test.startTest();
        inputData.fedId = user.FederationIdentifier;
        inputData.services = 'CASS04';
        ISSP_WS_DisableUser.ResponseOne response1 = ISSP_WS_DisableUser.reactivateUser(inputData);
        System.assertEquals(true, response1.IsSuccess);
        Test.stopTest();
    }
    static testMethod void reactivateUser_OK_SIS() {
        ISSP_WS_DisableUser.UserInputData inputData = createInputData();
        
        Account account = ISSP_ObjectFactory.createNewAccount();
        account.RecordTypeId = IATA_AIRLINE_RT.Id;
        insert account;
        
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = account.Id;
        contact.FirstName = 'firstname';
        contact.LastName = 'lastname';
        contact.User_Portal_Status__c = ISSP_Constant.NEW_CONTACT_STATUS;
        contact.Email = 'test@email.com';
        insert contact;
        
        APP_IDS = ISSP_Portal_Service_Ids__c.getInstance();
        System.assert(APP_IDS!=null);
        System.assert(APP_IDS.CASSLinkExport__c!=null);
        
        Portal_Application_Right__c appRight =
            new Portal_Application_Right__c(
                Portal_Application__c = APP_IDS.SIS__c,
                Contact__c = contact.Id,
                Right__c = 'Access Denied');
        insert appRight;
        
        User user = ISSP_WS_Utilities.createUser(contact.FirstName, contact.LastName, contact.email + (Math.random()*1000000000), IATA_AIRLINE_RT.developerName, contact.Id, false);
        user.FederationIdentifier = String.valueOf(contact.Id).substring(0, 15);
        insert user;
        
        delete [SELECT Id FROM ISSP_Web_Service_Log__c];
        
        Test.startTest();
        inputData.fedId = user.FederationIdentifier;
        inputData.services = 'SIS';
        ISSP_WS_DisableUser.ResponseOne response1 = ISSP_WS_DisableUser.reactivateUser(inputData);
        System.assertEquals(true, response1.IsSuccess);
        Test.stopTest();
    }
    static testMethod void reactivateUser_OK_ASD() {
        ISSP_WS_DisableUser.UserInputData inputData = createInputData();
        
        Account account = ISSP_ObjectFactory.createNewAccount();
        account.RecordTypeId = IATA_AIRLINE_RT.Id;
        insert account;
        
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = account.Id;
        contact.FirstName = 'firstname';
        contact.LastName = 'lastname';
        contact.User_Portal_Status__c = ISSP_Constant.NEW_CONTACT_STATUS;
        contact.Email = 'test@email.com';
        insert contact;
        
        APP_IDS = ISSP_Portal_Service_Ids__c.getInstance();
        System.assert(APP_IDS!=null);
        System.assert(APP_IDS.CASSLinkExport__c!=null);
        
        Portal_Application_Right__c appRight =
            new Portal_Application_Right__c(
                Portal_Application__c = APP_IDS.ASD__c,
                Contact__c = contact.Id,
                Right__c = 'Access Denied');
        insert appRight;
        
        User user = ISSP_WS_Utilities.createUser(contact.FirstName, contact.LastName, contact.email + (Math.random()*1000000000), IATA_AIRLINE_RT.developerName, contact.Id, false);
        user.FederationIdentifier = String.valueOf(contact.Id).substring(0, 15);
        insert user;
        
        delete [SELECT Id FROM ISSP_Web_Service_Log__c];
        
        Test.startTest();
        inputData.fedId = user.FederationIdentifier;
        inputData.services = 'ASD';
        ISSP_WS_DisableUser.ResponseOne response1 = ISSP_WS_DisableUser.reactivateUser(inputData);
        System.assertEquals(true, response1.IsSuccess);
        Test.stopTest();
    }
    static testMethod void reactivateUser_OK_BSPLINK() {
        ISSP_WS_DisableUser.UserInputData inputData = createInputData();
        
        Account account = ISSP_ObjectFactory.createNewAccount();
        account.RecordTypeId = IATA_AIRLINE_RT.Id;
        insert account;
        
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = account.Id;
        contact.FirstName = 'firstname';
        contact.LastName = 'lastname';
        contact.User_Portal_Status__c = ISSP_Constant.NEW_CONTACT_STATUS;
        contact.Email = 'test@email.com';
        insert contact;
        
        APP_IDS = ISSP_Portal_Service_Ids__c.getInstance();
        System.assert(APP_IDS!=null);
        System.assert(APP_IDS.CASSLinkExport__c!=null);
        
        Portal_Application_Right__c appRight =
            new Portal_Application_Right__c(
                Portal_Application__c = APP_IDS.BSPLink__c,
                Contact__c = contact.Id,
                Right__c = 'Access Denied');
        insert appRight;
        
        User user = ISSP_WS_Utilities.createUser(contact.FirstName, contact.LastName, contact.email + (Math.random()*1000000000), IATA_AIRLINE_RT.developerName, contact.Id, false);
        user.FederationIdentifier = String.valueOf(contact.Id).substring(0, 15);
        insert user;
        
        delete [SELECT Id FROM ISSP_Web_Service_Log__c];
        
        Test.startTest();
        inputData.fedId = user.FederationIdentifier;
        inputData.services = 'BSPLINK';
        ISSP_WS_DisableUser.ResponseOne response1 = ISSP_WS_DisableUser.reactivateUser(inputData);
        System.assertEquals(true, response1.IsSuccess);
        Test.stopTest();
    }
    
    static testMethod void reactivateUser_BadApp() {
        ISSP_WS_DisableUser.UserInputData inputData = createInputData();
        
        Account account = ISSP_ObjectFactory.createNewAccount();
        account.RecordTypeId = IATA_AIRLINE_RT.Id;
        insert account;
        
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = account.Id;
        contact.FirstName = 'firstname';
        contact.LastName = 'lastname';
        contact.User_Portal_Status__c = ISSP_Constant.NEW_CONTACT_STATUS;
        contact.Email = 'test@email.com';
        insert contact;
        
        APP_IDS = ISSP_Portal_Service_Ids__c.getInstance();
        // removing CASS01 app to test a missing app
        delete [SELECT Id FROM Portal_Applications__c WHERE Id=:APP_IDS.CASSLinkExport__c];
        
        User user = ISSP_WS_Utilities.createUser(contact.FirstName, contact.LastName, contact.email + (Math.random()*1000000000), IATA_AIRLINE_RT.developerName, contact.Id, false);
        user.FederationIdentifier = String.valueOf(contact.Id).substring(0, 15);
        insert user;
        
        delete [SELECT Id FROM ISSP_Web_Service_Log__c];
        
        Test.startTest();
        inputData.fedId = user.FederationIdentifier;
        inputData.services = 'CASS01'; // calling the missing app
        ISSP_WS_DisableUser.ResponseOne response1 = ISSP_WS_DisableUser.reactivateUser(inputData);
        System.assertEquals(false, response1.IsSuccess);
        Test.stopTest();
    }
    
    static testMethod void reactivateUser_AlreadyActive() {
        ISSP_WS_DisableUser.UserInputData inputData = createInputData();
        
        Account account = ISSP_ObjectFactory.createNewAccount();
        account.RecordTypeId = IATA_AIRLINE_RT.Id;
        insert account;
        
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = account.Id;
        contact.FirstName = 'firstname';
        contact.LastName = 'lastname';
        contact.User_Portal_Status__c = ISSP_Constant.NEW_CONTACT_STATUS;
        contact.Email = 'test@email.com';
        insert contact;
        
        APP_IDS = ISSP_Portal_Service_Ids__c.getInstance();
        insert new Portal_Application_Right__c(
            Portal_Application__c = APP_IDS.CASSLinkExport__c,
            Contact__c = contact.Id,
            Right__c = 'Access Granted');
        
        User user = ISSP_WS_Utilities.createUser(contact.FirstName, contact.LastName, contact.email + (Math.random()*1000000000), IATA_AIRLINE_RT.developerName, contact.Id, false);
        user.FederationIdentifier = String.valueOf(contact.Id).substring(0, 15);
        insert user;
        
        delete [SELECT Id FROM ISSP_Web_Service_Log__c];
        
        Test.startTest();
        inputData.fedId = user.FederationIdentifier;
        inputData.services = 'CASS01';
        ISSP_WS_DisableUser.ResponseOne response1 = ISSP_WS_DisableUser.reactivateUser(inputData);
        System.assertEquals(true, response1.IsSuccess);
        Test.stopTest();
    }
    
    static testMethod void disableUser_noFederationId() {
        ISSP_WS_DisableUser.UserInputData inputData = createInputData();
        
        Test.startTest();
        inputData.fedId = '';
        ISSP_WS_DisableUser.ResponseOne response = ISSP_WS_DisableUser.disableUser(inputData);
        Test.stopTest();
        
        System.assertEquals(false, response.IsSuccess);
        System.assertEquals('012', response.responseErrorCode);
        
        checkLogs(false,'disableUser');
    }
    
    static testMethod void disableUser_noTypeOfService() {
        ISSP_WS_DisableUser.UserInputData inputData = createInputData();
        
        Test.startTest();
        inputData.services = '';
        ISSP_WS_DisableUser.ResponseOne response = ISSP_WS_DisableUser.disableUser(inputData);
        Test.stopTest();
        
        System.assertEquals(false, response.IsSuccess);
        System.assertEquals('010', response.responseErrorCode);
    }
    
    static testMethod void disableUser_NoUser() {
        ISSP_WS_DisableUser.UserInputData inputData = createInputData();
        
        Test.startTest();
        inputData.fedId = '123456';
        ISSP_WS_DisableUser.ResponseOne response = ISSP_WS_DisableUser.disableUser(inputData);
        Test.stopTest();
        
        System.assertEquals(false, response.IsSuccess);
        System.assertEquals('011', response.responseErrorCode);
        
        checkLogs(false,'disableUser');
    }
    
    static testMethod void disableUser_InactiveUser() {
        ISSP_WS_DisableUser.UserInputData inputData = createInputData();
        
        Account account = ISSP_ObjectFactory.createNewAccount();
        account.RecordTypeId = IATA_AIRLINE_RT.Id;
        insert account;
        
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = account.Id;
        contact.FirstName = 'firstname';
        contact.LastName = 'lastname';
        contact.User_Portal_Status__c = ISSP_Constant.NEW_CONTACT_STATUS;
        contact.Email = 'test@email.com';
        insert contact;
        
        User user = ISSP_WS_Utilities.createUser(contact.FirstName, contact.LastName, contact.email + (Math.random()*1000000000), IATA_AIRLINE_RT.developerName, contact.Id, false);
        user.FederationIdentifier = String.valueOf(contact.Id).substring(0, 15);
        user.isActive = false;
        user.Portal_User_Frozen_Checkbox__c = false;
        insert user;
        
        delete [SELECT Id FROM ISSP_Web_Service_Log__c];
        
        Test.startTest();
        inputData.fedId = user.FederationIdentifier;
        ISSP_WS_DisableUser.ResponseOne response2 = ISSP_WS_DisableUser.disableUser(inputData);
        System.assertEquals(false, response2.IsSuccess);
        Test.stopTest();
        
        checkLogs(false,'disableUser');
    }
    
    static testMethod void disableUser_OK() {
        ISSP_WS_DisableUser.UserInputData inputData = createInputData();
        
        Account account = ISSP_ObjectFactory.createNewAccount();
        account.RecordTypeId = IATA_AIRLINE_RT.Id;
        insert account;
        
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = account.Id;
        contact.FirstName = 'firstname';
        contact.LastName = 'lastname';
        contact.User_Portal_Status__c = ISSP_Constant.NEW_CONTACT_STATUS;
        contact.Email = 'test@email.com';
        insert contact;
        
        User user = ISSP_WS_Utilities.createUser(contact.FirstName, contact.LastName, contact.email + (Math.random()*1000000000), IATA_AIRLINE_RT.developerName, contact.Id, false);
        user.FederationIdentifier = String.valueOf(contact.Id).substring(0, 15);
        insert user;
        
        inputData.fedId = user.FederationIdentifier;
        ISSP_WS_DisableUser.ResponseOne response1 = ISSP_WS_DisableUser.reactivateUser(inputData);
        System.assertEquals(true, response1.IsSuccess);
        
        delete [SELECT Id FROM ISSP_Web_Service_Log__c];
        
        Test.startTest();
        ISSP_WS_DisableUser.ResponseOne response2 = ISSP_WS_DisableUser.disableUser(inputData);
        System.assertEquals(true, response2.IsSuccess);
        Test.stopTest();
        
        checkLogs(true,'disableUser');
    }
    
	/*
    static testMethod void disableUser_OK_AlreadyDisabled() {
        ISSP_WS_DisableUser.UserInputData inputData = createInputData();
        
        Account account = ISSP_ObjectFactory.createNewAccount();
        account.RecordTypeId = IATA_AIRLINE_RT.Id;
        insert account;
        
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = account.Id;
        contact.FirstName = 'firstname';
        contact.LastName = 'lastname';
        contact.User_Portal_Status__c = ISSP_Constant.NEW_CONTACT_STATUS;
        contact.Email = 'test@email.com';
        insert contact;
        
        User user = ISSP_WS_Utilities.createUser(contact.FirstName, contact.LastName, contact.email + (Math.random()*1000000000), IATA_AIRLINE_RT.developerName, contact.Id, false);
        user.FederationIdentifier = String.valueOf(contact.Id).substring(0, 15);
        insert user;
        
        inputData.fedId = user.FederationIdentifier;
        ISSP_WS_DisableUser.ResponseOne response1 = ISSP_WS_DisableUser.reactivateUser(inputData);
        System.assertEquals(true, response1.IsSuccess);
        
        APP_IDS = ISSP_Portal_Service_Ids__c.getInstance();
        insert new Portal_Application_Right__c(
            Portal_Application__c = APP_IDS.CASSLinkExport__c,
            Contact__c = contact.Id,
            Right__c = 'Access Denied');
        
        delete [SELECT Id FROM ISSP_Web_Service_Log__c];
        
        Test.startTest();
        inputData.services = 'CASS01';
        ISSP_WS_DisableUser.ResponseOne response2 = ISSP_WS_DisableUser.disableUser(inputData);
        System.assertEquals(false, response2.IsSuccess);
        Test.stopTest();
    }
	*/
    
    static testMethod void disableUser_OK_CASS01() {
        ISSP_WS_DisableUser.UserInputData inputData = createInputData();
        
        Account account = ISSP_ObjectFactory.createNewAccount();
        account.RecordTypeId = IATA_AIRLINE_RT.Id;
        insert account;
        
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = account.Id;
        contact.FirstName = 'firstname';
        contact.LastName = 'lastname';
        contact.User_Portal_Status__c = ISSP_Constant.NEW_CONTACT_STATUS;
        contact.Email = 'test@email.com';
        insert contact;
        
        User user = ISSP_WS_Utilities.createUser(contact.FirstName, contact.LastName, contact.email + (Math.random()*1000000000), IATA_AIRLINE_RT.developerName, contact.Id, false);
        user.FederationIdentifier = String.valueOf(contact.Id).substring(0, 15);
        insert user;

        APP_IDS = ISSP_Portal_Service_Ids__c.getInstance();
        System.assert(APP_IDS!=null);
        System.assert(APP_IDS.CASSLinkExport__c!=null);
        
        Portal_Application_Right__c appRight = new Portal_Application_Right__c(
            Portal_Application__c = APP_IDS.CASSLinkExport__c,
            Contact__c = contact.Id,
            Right__c = 'Access Granted');
        ISSP_UserTriggerHandler.preventTrigger = true;
        ISSP_UserTriggerHandler.preventSISIntegration = true;
        insert appRight;
        
        delete [SELECT Id FROM ISSP_Web_Service_Log__c];
        
        Test.startTest();
        inputData.fedId = user.FederationIdentifier;
        inputData.services = 'CASS01';
        ISSP_WS_DisableUser.ResponseOne response2 = ISSP_WS_DisableUser.disableUser(inputData);
        System.assertEquals(true, response2.IsSuccess);
        Test.stopTest();
    }
    static testMethod void disableUser_OK_CASS02() {
        ISSP_WS_DisableUser.UserInputData inputData = createInputData();
        
        Account account = ISSP_ObjectFactory.createNewAccount();
        account.RecordTypeId = IATA_AIRLINE_RT.Id;
        insert account;
        
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = account.Id;
        contact.FirstName = 'firstname';
        contact.LastName = 'lastname';
        contact.User_Portal_Status__c = ISSP_Constant.NEW_CONTACT_STATUS;
        contact.Email = 'test@email.com';
        insert contact;
        
        User user = ISSP_WS_Utilities.createUser(contact.FirstName, contact.LastName, contact.email + (Math.random()*1000000000), IATA_AIRLINE_RT.developerName, contact.Id, false);
        user.FederationIdentifier = String.valueOf(contact.Id).substring(0, 15);
        insert user;

        APP_IDS = ISSP_Portal_Service_Ids__c.getInstance();
        System.assert(APP_IDS!=null);
        System.assert(APP_IDS.CASSLinkExport__c!=null);
        
        Portal_Application_Right__c appRight = new Portal_Application_Right__c(
            Portal_Application__c = APP_IDS.CASSLinkImport__c,
            Contact__c = contact.Id,
            Right__c = 'Access Granted');
        ISSP_UserTriggerHandler.preventTrigger = true;
        ISSP_UserTriggerHandler.preventSISIntegration = true;
        insert appRight;
        
        delete [SELECT Id FROM ISSP_Web_Service_Log__c];
        
        Test.startTest();
        inputData.fedId = user.FederationIdentifier;
        inputData.services = 'CASS02';
        ISSP_WS_DisableUser.ResponseOne response2 = ISSP_WS_DisableUser.disableUser(inputData);
        System.assertEquals(true, response2.IsSuccess);
        Test.stopTest();
    }
    static testMethod void disableUser_OK_CASS03() {
        ISSP_WS_DisableUser.UserInputData inputData = createInputData();
        
        Account account = ISSP_ObjectFactory.createNewAccount();
        account.RecordTypeId = IATA_AIRLINE_RT.Id;
        insert account;
        
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = account.Id;
        contact.FirstName = 'firstname';
        contact.LastName = 'lastname';
        contact.User_Portal_Status__c = ISSP_Constant.NEW_CONTACT_STATUS;
        contact.Email = 'test@email.com';
        insert contact;
        
        User user = ISSP_WS_Utilities.createUser(contact.FirstName, contact.LastName, contact.email + (Math.random()*1000000000), IATA_AIRLINE_RT.developerName, contact.Id, false);
        user.FederationIdentifier = String.valueOf(contact.Id).substring(0, 15);
        insert user;

        APP_IDS = ISSP_Portal_Service_Ids__c.getInstance();
        System.assert(APP_IDS!=null);
        System.assert(APP_IDS.CASSLinkExport__c!=null);
        
        Portal_Application_Right__c appRight = new Portal_Application_Right__c(
            Portal_Application__c = APP_IDS.CASSLinkRouteAnalyzer__c,
            Contact__c = contact.Id,
            Right__c = 'Access Granted');
        ISSP_UserTriggerHandler.preventTrigger = true;
        ISSP_UserTriggerHandler.preventSISIntegration = true;
        insert appRight;
        
        delete [SELECT Id FROM ISSP_Web_Service_Log__c];
        
        Test.startTest();
        inputData.fedId = user.FederationIdentifier;
        inputData.services = 'CASS03';
        ISSP_WS_DisableUser.ResponseOne response2 = ISSP_WS_DisableUser.disableUser(inputData);
        System.assertEquals(true, response2.IsSuccess);
        Test.stopTest();
    }
    static testMethod void disableUser_OK_CASS04() {
        ISSP_WS_DisableUser.UserInputData inputData = createInputData();
        
        Account account = ISSP_ObjectFactory.createNewAccount();
        account.RecordTypeId = IATA_AIRLINE_RT.Id;
        insert account;
        
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = account.Id;
        contact.FirstName = 'firstname';
        contact.LastName = 'lastname';
        contact.User_Portal_Status__c = ISSP_Constant.NEW_CONTACT_STATUS;
        contact.Email = 'test@email.com';
        insert contact;
        
        User user = ISSP_WS_Utilities.createUser(contact.FirstName, contact.LastName, contact.email + (Math.random()*1000000000), IATA_AIRLINE_RT.developerName, contact.Id, false);
        user.FederationIdentifier = String.valueOf(contact.Id).substring(0, 15);
        insert user;

        APP_IDS = ISSP_Portal_Service_Ids__c.getInstance();
        System.assert(APP_IDS!=null);
        System.assert(APP_IDS.CASSLinkExport__c!=null);
        
        Portal_Application_Right__c appRight = new Portal_Application_Right__c(
            Portal_Application__c = APP_IDS.CNS_CassLink__c,
            Contact__c = contact.Id,
            Right__c = 'Access Granted');
        ISSP_UserTriggerHandler.preventTrigger = true;
        ISSP_UserTriggerHandler.preventSISIntegration = true;
        insert appRight;
        
        delete [SELECT Id FROM ISSP_Web_Service_Log__c];
        
        Test.startTest();
        inputData.fedId = user.FederationIdentifier;
        inputData.services = 'CASS04';
        ISSP_WS_DisableUser.ResponseOne response2 = ISSP_WS_DisableUser.disableUser(inputData);
        System.assertEquals(true, response2.IsSuccess);
        Test.stopTest();
    }
    static testMethod void disableUser_OK_SIS() {
        ISSP_WS_DisableUser.UserInputData inputData = createInputData();
        
        Account account = ISSP_ObjectFactory.createNewAccount();
        account.RecordTypeId = IATA_AIRLINE_RT.Id;
        insert account;
        
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = account.Id;
        contact.FirstName = 'firstname';
        contact.LastName = 'lastname';
        contact.User_Portal_Status__c = ISSP_Constant.NEW_CONTACT_STATUS;
        contact.Email = 'test@email.com';
        insert contact;
        
        User user = ISSP_WS_Utilities.createUser(contact.FirstName, contact.LastName, contact.email + (Math.random()*1000000000), IATA_AIRLINE_RT.developerName, contact.Id, false);
        user.FederationIdentifier = String.valueOf(contact.Id).substring(0, 15);
        insert user;

        APP_IDS = ISSP_Portal_Service_Ids__c.getInstance();
        System.assert(APP_IDS!=null);
        System.assert(APP_IDS.CASSLinkExport__c!=null);
        
        Portal_Application_Right__c appRight = new Portal_Application_Right__c(
            Portal_Application__c = APP_IDS.SIS__c,
            Contact__c = contact.Id,
            Right__c = 'Access Granted');
        ISSP_UserTriggerHandler.preventTrigger = true;
        ISSP_UserTriggerHandler.preventSISIntegration = true;
        insert appRight;
        
        delete [SELECT Id FROM ISSP_Web_Service_Log__c];
        
        Test.startTest();
        inputData.fedId = user.FederationIdentifier;
        inputData.services = 'SIS';
        ISSP_WS_DisableUser.ResponseOne response2 = ISSP_WS_DisableUser.disableUser(inputData);
        System.assertEquals(true, response2.IsSuccess);
        Test.stopTest();
    }
    static testMethod void disableUser_OK_ASD() {
        ISSP_WS_DisableUser.UserInputData inputData = createInputData();
        
        Account account = ISSP_ObjectFactory.createNewAccount();
        account.RecordTypeId = IATA_AIRLINE_RT.Id;
        insert account;
        
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = account.Id;
        contact.FirstName = 'firstname';
        contact.LastName = 'lastname';
        contact.User_Portal_Status__c = ISSP_Constant.NEW_CONTACT_STATUS;
        contact.Email = 'test@email.com';
        insert contact;
        
        User user = ISSP_WS_Utilities.createUser(contact.FirstName, contact.LastName, contact.email + (Math.random()*1000000000), IATA_AIRLINE_RT.developerName, contact.Id, false);
        user.FederationIdentifier = String.valueOf(contact.Id).substring(0, 15);
        insert user;

        APP_IDS = ISSP_Portal_Service_Ids__c.getInstance();
        System.assert(APP_IDS!=null);
        System.assert(APP_IDS.CASSLinkExport__c!=null);
        
        Portal_Application_Right__c appRight = new Portal_Application_Right__c(
            Portal_Application__c = APP_IDS.ASD__c,
            Contact__c = contact.Id,
            Right__c = 'Access Granted');
        ISSP_UserTriggerHandler.preventTrigger = true;
        ISSP_UserTriggerHandler.preventSISIntegration = true;
        insert appRight;
        
        delete [SELECT Id FROM ISSP_Web_Service_Log__c];
        
        Test.startTest();
        inputData.fedId = user.FederationIdentifier;
        inputData.services = 'ASD';
        ISSP_WS_DisableUser.ResponseOne response2 = ISSP_WS_DisableUser.disableUser(inputData);
        System.assertEquals(true, response2.IsSuccess);
        Test.stopTest();
    }
    static testMethod void disableUser_OK_BSPLINK() {
        ISSP_WS_DisableUser.UserInputData inputData = createInputData();
        
        Account account = ISSP_ObjectFactory.createNewAccount();
        account.RecordTypeId = IATA_AIRLINE_RT.Id;
        insert account;
        
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = account.Id;
        contact.FirstName = 'firstname';
        contact.LastName = 'lastname';
        contact.User_Portal_Status__c = ISSP_Constant.NEW_CONTACT_STATUS;
        contact.Email = 'test@email.com';
        insert contact;
        
        User user = ISSP_WS_Utilities.createUser(contact.FirstName, contact.LastName, contact.email + (Math.random()*1000000000), IATA_AIRLINE_RT.developerName, contact.Id, false);
        user.FederationIdentifier = String.valueOf(contact.Id).substring(0, 15);
        insert user;

        APP_IDS = ISSP_Portal_Service_Ids__c.getInstance();
        System.assert(APP_IDS!=null);
        System.assert(APP_IDS.CASSLinkExport__c!=null);
        
        Portal_Application_Right__c appRight = new Portal_Application_Right__c(
            Portal_Application__c = APP_IDS.BSPLINK__c,
            Contact__c = contact.Id,
            Right__c = 'Access Granted');
        ISSP_UserTriggerHandler.preventTrigger = true;
        ISSP_UserTriggerHandler.preventSISIntegration = true;
        insert appRight;
        
        delete [SELECT Id FROM ISSP_Web_Service_Log__c];
        
        Test.startTest();
        inputData.fedId = user.FederationIdentifier;
        inputData.services = 'BSPLINK';
        ISSP_WS_DisableUser.ResponseOne response2 = ISSP_WS_DisableUser.disableUser(inputData);
        System.assertEquals(true, response2.IsSuccess);
        Test.stopTest();
    }

    static testMethod void disableUser_BadApp() {
        ISSP_WS_DisableUser.UserInputData inputData = createInputData();
        
        Account account = ISSP_ObjectFactory.createNewAccount();
        account.RecordTypeId = IATA_AIRLINE_RT.Id;
        insert account;
        
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = account.Id;
        contact.FirstName = 'firstname';
        contact.LastName = 'lastname';
        contact.User_Portal_Status__c = ISSP_Constant.NEW_CONTACT_STATUS;
        contact.Email = 'test@email.com';
        insert contact;
        
        APP_IDS = ISSP_Portal_Service_Ids__c.getInstance();
        
        User user = ISSP_WS_Utilities.createUser(contact.FirstName, contact.LastName, contact.email + (Math.random()*1000000000), IATA_AIRLINE_RT.developerName, contact.Id, false);
		user.FederationIdentifier = String.valueOf(contact.Id).substring(0, 15);
        insert user;
        
        delete [SELECT Id FROM ISSP_Web_Service_Log__c];
        
        Test.startTest();
        inputData.fedId = user.FederationIdentifier;
        inputData.services = 'fakeapp';
        ISSP_WS_DisableUser.ResponseOne response2 = ISSP_WS_DisableUser.disableUser(inputData);
        System.assertEquals(false, response2.IsSuccess);
        Test.stopTest();
    }
    
    static testMethod void disableUser_withoutRights() {
        ISSP_WS_DisableUser.UserInputData inputData = createInputData();
        
        Account account = ISSP_ObjectFactory.createNewAccount();
        account.RecordTypeId = IATA_AIRLINE_RT.Id;
        insert account;
        
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = account.Id;
        contact.FirstName = 'firstname';
        contact.LastName = 'lastname';
        contact.User_Portal_Status__c = ISSP_Constant.NEW_CONTACT_STATUS;
        contact.Email = 'test@email.com';
        insert contact;
        
        APP_IDS = ISSP_Portal_Service_Ids__c.getInstance();
        
        User user = ISSP_WS_Utilities.createUser(contact.FirstName, contact.LastName, contact.email + (Math.random()*1000000000), IATA_AIRLINE_RT.developerName, contact.Id, false);
        user.FederationIdentifier = String.valueOf(contact.Id).substring(0, 15);
        insert user;
        
        ISSP_UserTriggerHandler.preventTrigger = true;
        ISSP_UserTriggerHandler.preventSISIntegration = true;
        delete [SELECT Id FROM Portal_Application_Right__c WHERE Contact__c = :contact.Id];
        
        delete [SELECT Id FROM ISSP_Web_Service_Log__c];
        
        Test.startTest();
        inputData.fedId = user.FederationIdentifier;
        inputData.services = 'CASS01';
        ISSP_WS_DisableUser.ResponseOne response2 = ISSP_WS_DisableUser.disableUser(inputData);
        System.assertEquals(false, response2.IsSuccess);
        Test.stopTest();
    }
    
    static testMethod void dummyTest() {
        Test.startTest();
        ISSP_WS_DisableUser.dummyFunction();
        Test.stopTest();
    }
}