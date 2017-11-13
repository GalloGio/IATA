@isTest
private class ISSP_WS_SIS_ActivateUser_Test {
    
    private static final Profile AIRLINE_PORTAL_PROFILE = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Airline User (Partner)'];
    private static final RecordType IATA_AIRLINE_RT = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'IATA_Airline'];

    @TestSetup
    private static void setup() {
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
        insert listIsspCs;
    }

    private static ISSP_WS_SIS_ActivateUser.InputData createInputData() {
        ISSP_WS_SIS_ActivateUser.InputData inputData = new ISSP_WS_SIS_ActivateUser.InputData();
        inputData.FederationID = '123456';
        inputData.TypeOfService = 'SIS';
        return inputData;
    }

    static testMethod void activateUser_noFederationId() {
        ISSP_WS_SIS_ActivateUser.InputData inputData = createInputData();
        
        Test.startTest();
        inputData.FederationID = '';
        ISSP_WS_SIS_ActivateUser.ResponseData response = ISSP_WS_SIS_ActivateUser.ActivateUser(inputData);
        Test.stopTest();
        
        System.assertEquals(false, response.IsSuccess);
        System.assertEquals('021', response.ErrorCode);
    }
    
    static testMethod void activateUser_noTypeOfService() {
        ISSP_WS_SIS_ActivateUser.InputData inputData = createInputData();
        
        Test.startTest();
        inputData.TypeOfService = '';
        ISSP_WS_SIS_ActivateUser.ResponseData response = ISSP_WS_SIS_ActivateUser.ActivateUser(inputData);
        Test.stopTest();
        
        System.assertEquals(false, response.IsSuccess);
        System.assertEquals('010', response.ErrorCode);
    }
    
    static testMethod void activateUser_NoUser() {
        ISSP_WS_SIS_ActivateUser.InputData inputData = createInputData();
        
        Test.startTest();
        inputData.FederationID = '123456';
        ISSP_WS_SIS_ActivateUser.ResponseData response = ISSP_WS_SIS_ActivateUser.ActivateUser(inputData);
        Test.stopTest();
        
        System.assertEquals(false, response.IsSuccess);
        System.assertEquals('011', response.ErrorCode);
    }
    
    static testMethod void activateUser_OK() {
        ISSP_WS_SIS_ActivateUser.InputData inputData = createInputData();
        
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
        
        Test.startTest();
        inputData.FederationID = user.FederationIdentifier;
        ISSP_WS_SIS_ActivateUser.ResponseData response1 = ISSP_WS_SIS_ActivateUser.ActivateUser(inputData);
        System.assertEquals(true, response1.IsSuccess);
        
        ISSP_WS_SIS_ActivateUser.ResponseData response2 = ISSP_WS_SIS_ActivateUser.DeactivateUser(inputData);
        System.assertEquals(true, response2.IsSuccess);
        Test.stopTest();
    }
    
    static testMethod void activateUser_OK2() {
        ISSP_WS_SIS_ActivateUser.InputData inputData = createInputData();
        
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
        
        Portal_Application_Right__c newAppRight = new Portal_Application_Right__c(
            Portal_Application__c = ISSP_WS_SIS_ActivateUser.SIS_ID_PORTAL_APP,
            Contact__c = contact.Id,
            Right__c = 'Access Denied');
        insert newAppRight;
        
        User user = ISSP_WS_Utilities.createUser(contact.FirstName, contact.LastName, contact.email, IATA_AIRLINE_RT.developerName, contact.Id, false);
        user.FederationIdentifier = String.valueOf(contact.Id).substring(0, 15);
        insert user;
        
        Test.startTest();
        inputData.FederationID = user.FederationIdentifier;
        ISSP_WS_SIS_ActivateUser.ResponseData response1 = ISSP_WS_SIS_ActivateUser.ActivateUser(inputData);
        System.assertEquals(true, response1.IsSuccess);
        Test.stopTest();
    }

}