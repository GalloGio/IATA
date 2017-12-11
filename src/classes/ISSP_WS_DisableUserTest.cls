@isTest
private class ISSP_WS_DisableUserTest {

    private static final Profile AIRLINE_PORTAL_PROFILE = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Airline User (Partner)'];
    private static final RecordType IATA_AIRLINE_RT = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'IATA_Airline'];
    private static ID APP_SIS_ID;

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
        
        //insert SIS app
        Portal_Applications__c SISapp = new Portal_Applications__c(Name = 'SIS');
        insert SISapp;
        APP_SIS_ID = SISapp.Id;
        
        // insert Portal service CS
        ISSP_Portal_Service_Ids__c portalServiceCs = new ISSP_Portal_Service_Ids__c(
            SIS__c = SISapp.id
        );
        insert portalServiceCs;
        
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
        contact.Email = 'test@email.com';
        insert contact;
        
        User user = ISSP_WS_Utilities.createUser(contact.FirstName, contact.LastName, contact.email, IATA_AIRLINE_RT.developerName, contact.Id, false);
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
    
    static testMethod void reactivateUser_OK2() {
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
        
        if (APP_SIS_ID==null) {
            APP_SIS_ID = [SELECT Id FROM Portal_Applications__c].id;
        }
        
        Portal_Application_Right__c newAppRight = new Portal_Application_Right__c(
            Portal_Application__c = APP_SIS_ID,
            Contact__c = contact.Id,
            Right__c = 'Access Denied');
        insert newAppRight;
        
        User user = ISSP_WS_Utilities.createUser(contact.FirstName, contact.LastName, contact.email, IATA_AIRLINE_RT.developerName, contact.Id, false);
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
        
        User user = ISSP_WS_Utilities.createUser(contact.FirstName, contact.LastName, contact.email, IATA_AIRLINE_RT.developerName, contact.Id, false);
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

}