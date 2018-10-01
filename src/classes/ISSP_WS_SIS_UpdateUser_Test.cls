@isTest
private class ISSP_WS_SIS_UpdateUser_Test {
    
    private static final Profile AIRLINE_PORTAL_PROFILE = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Airline User (Partner)'];
    private static final RecordType IATA_AIRLINE_RT = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'IATA_Airline'];

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

    private static ISSP_WS_SIS_UpdateUser.InputData createInputData() {
        ISSP_WS_SIS_UpdateUser.InputData inputData = new ISSP_WS_SIS_UpdateUser.InputData();
        inputData.FederationID = '123456';
        inputData.SISMemberID = 'SISID';
        inputData.UserType = 'S';
        inputData.TypeOfService = 'SIS';
        inputData.RequestType = 'O';
        return inputData;
    }

    private static void checkLogs(Boolean isSuccess) {
        list<ISSP_Web_Service_Log__c> listLogs = [SELECT Id, Success__c, Web_Service__c, Method__c, System__c, Error_Message__c FROM ISSP_Web_Service_Log__c];
        System.assert(listLogs.size()==1, '' + listLogs);
        System.assertEquals(isSuccess, listLogs[0].Success__c, '' + listLogs[0].Error_Message__c);
        System.assertEquals('ISSP_WS_SIS_UpdateUser', listLogs[0].Web_Service__c);
        System.assertEquals('updateSISUser', listLogs[0].Method__c);
        System.assertEquals('SIS', listLogs[0].System__c);
    }
    
    static testMethod void updateUser_noFederationId() {
        ISSP_WS_SIS_UpdateUser.InputData inputData = createInputData();
        
        Test.startTest();
        inputData.FederationID = '';
        ISSP_WS_SIS_UpdateUser.ResponseData response = ISSP_WS_SIS_UpdateUser.updateUser(inputData);
        Test.stopTest();
        
        System.assertEquals(false, response.IsSuccess);
        System.assertEquals('021', response.ErrorCode);
        
        checkLogs(false);
    }
    
    static testMethod void updateUser_noSISMemberID() {
        ISSP_WS_SIS_UpdateUser.InputData inputData = createInputData();
        
        Test.startTest();
        inputData.SISMemberID = '';
        ISSP_WS_SIS_UpdateUser.ResponseData response = ISSP_WS_SIS_UpdateUser.updateUser(inputData);
        Test.stopTest();
        
        System.assertEquals(false, response.IsSuccess);
        System.assertEquals('018', response.ErrorCode);
        
        checkLogs(false);
    }
    
    static testMethod void updateUser_noUserType() {
        ISSP_WS_SIS_UpdateUser.InputData inputData = createInputData();
        
        Test.startTest();
        inputData.UserType = '';
        ISSP_WS_SIS_UpdateUser.ResponseData response = ISSP_WS_SIS_UpdateUser.updateUser(inputData);
        Test.stopTest();
        
        System.assertEquals(false, response.IsSuccess);
        System.assertEquals('020', response.ErrorCode);
        
        checkLogs(false);
    }
    
    static testMethod void updateUser_noTypeOfService() {
        ISSP_WS_SIS_UpdateUser.InputData inputData = createInputData();
        
        Test.startTest();
        inputData.TypeOfService = '';
        ISSP_WS_SIS_UpdateUser.ResponseData response = ISSP_WS_SIS_UpdateUser.updateUser(inputData);
        Test.stopTest();
        
        System.assertEquals(false, response.IsSuccess);
        System.assertEquals('010', response.ErrorCode);
        
        list<ISSP_Web_Service_Log__c> listLogs = [SELECT Id, Success__c, Web_Service__c, Method__c, System__c, Error_Message__c FROM ISSP_Web_Service_Log__c];
        System.assert(listLogs.size()==1, '' + listLogs);
        System.assertEquals(false, listLogs[0].Success__c, '' + listLogs[0].Error_Message__c);
        System.assertEquals('ISSP_WS_SIS_UpdateUser', listLogs[0].Web_Service__c);
        System.assertEquals('updateSISUser', listLogs[0].Method__c);
        System.assertEquals(null, listLogs[0].System__c);
    }
    
    static testMethod void updateUser_noRequestType() {
        ISSP_WS_SIS_updateUser.InputData inputData = createInputData();
        
        Test.startTest();
        inputData.RequestType = '';
        ISSP_WS_SIS_UpdateUser.ResponseData response = ISSP_WS_SIS_UpdateUser.updateUser(inputData);
        Test.stopTest();
        
        System.assertEquals(false, response.IsSuccess);
        System.assertEquals('022', response.ErrorCode);
        
        checkLogs(false);
    }
    
    static testMethod void updateSISUser_NoUser() {
        ISSP_WS_SIS_updateUser.InputData inputData = createInputData();
        
        Test.startTest();
        ISSP_WS_SIS_updateUser.ResponseData response = ISSP_WS_SIS_updateUser.updateUser(inputData);
        Test.stopTest();
        
        System.assertEquals(false, response.IsSuccess);
        System.assertEquals('011', response.ErrorCode);
        
        checkLogs(false);
    }
    
    static testMethod void updateSISUser_OK() {
        ISSP_WS_SIS_updateUser.InputData inputData = createInputData();
        
        Account account = ISSP_ObjectFactory.createNewAccount();
        account.SIS_ID__c = inputData.SISMemberID;
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
        ISSP_WS_SIS_updateUser.ResponseData response = ISSP_WS_SIS_updateUser.updateUser(inputData);
        Test.stopTest();
        
        System.assertEquals(true, response.IsSuccess);
        System.assertEquals(inputData.FederationID, response.FederationID);
        
        checkLogs(true);
    }
    
    static testMethod void updateSISUser_SISIdError() {
        ISSP_WS_SIS_updateUser.InputData inputData = createInputData();
        
        Account account = ISSP_ObjectFactory.createNewAccount();
        account.SIS_ID__c = inputData.SISMemberID + 'X';
        account.RecordTypeId = IATA_AIRLINE_RT.Id;
        insert account;
        
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = account.Id;
        contact.FirstName = 'firstname';
        contact.LastName = 'lastname';
        contact.User_Portal_Status__c = ISSP_Constant.APPROVED_CONTACT_STATUS;
        contact.Email = 'test@email.com';
        insert contact;
        
        User user = ISSP_WS_Utilities.createUser(contact.FirstName, contact.LastName, contact.email, IATA_AIRLINE_RT.developerName, contact.Id, false);
        user.FederationIdentifier = String.valueOf(contact.Id).substring(0, 15);
        insert user;
        
        Test.startTest();
        inputData.FederationID = user.FederationIdentifier;
        ISSP_WS_SIS_updateUser.ResponseData response = ISSP_WS_SIS_updateUser.updateUser(inputData);
        Test.stopTest();
        
        System.assertEquals(false, response.IsSuccess);
        System.assertEquals('024', response.ErrorCode);
        
        checkLogs(false);
    }
    
    static testMethod void updateSISUser_checkSISIDInHierarchy() {
        ISSP_WS_SIS_updateUser.InputData inputData = createInputData();

        Account topAccount = ISSP_ObjectFactory.createNewAccount();
        topAccount.SIS_ID__c = inputData.SISMemberID + 'Y';
        topAccount.RecordTypeId = IATA_AIRLINE_RT.Id;
        insert topAccount;

        Account account = ISSP_ObjectFactory.createNewAccount();
        account.SIS_ID__c = inputData.SISMemberID + 'X';
        account.RecordTypeId = IATA_AIRLINE_RT.Id;
        account.ParentId = topAccount.Id;
        
        Account account2 = ISSP_ObjectFactory.createNewAccount();
        account2.SIS_ID__c = inputData.SISMemberID;
        account2.RecordTypeId = IATA_AIRLINE_RT.Id;
        account2.ParentId = topAccount.Id;
        
        insert new list<Account>{account, account2};
        
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = account.Id;
        contact.FirstName = 'firstname';
        contact.LastName = 'lastname';
        contact.User_Portal_Status__c = ISSP_Constant.APPROVED_CONTACT_STATUS;
        contact.Email = 'test@email.com';
        insert contact;
        
        User user = ISSP_WS_Utilities.createUser(contact.FirstName, contact.LastName, contact.email, IATA_AIRLINE_RT.developerName, contact.Id, false);
        user.FederationIdentifier = String.valueOf(contact.Id).substring(0, 15);
        insert user;
        
        Test.startTest();
        inputData.FederationID = user.FederationIdentifier;
        ISSP_WS_SIS_updateUser.ResponseData response = ISSP_WS_SIS_updateUser.updateUser(inputData);
        Test.stopTest();
        
        System.assertEquals(true, response.IsSuccess,'Should be a success but was ' + response.ErrorCode);
        
        checkLogs(true);
    }
    
    static testMethod void updateSISUser_InactiveUserError() {
        ISSP_WS_SIS_updateUser.InputData inputData = createInputData();
        
        Account account = ISSP_ObjectFactory.createNewAccount();
        account.SIS_ID__c = inputData.SISMemberID;
        account.RecordTypeId = IATA_AIRLINE_RT.Id;
        insert account;
        
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = account.Id;
        contact.FirstName = 'firstname';
        contact.LastName = 'lastname';
        contact.User_Portal_Status__c = 'Rejected';
        contact.Email = 'test@email.com';
        insert contact;
        
        User user = ISSP_WS_Utilities.createUser(contact.FirstName, contact.LastName, contact.email, IATA_AIRLINE_RT.developerName, contact.Id, false);
        user.FederationIdentifier = String.valueOf(contact.Id).substring(0, 15);
        insert user;
        
        Test.startTest();
        inputData.FederationID = user.FederationIdentifier;
        ISSP_WS_SIS_updateUser.ResponseData response = ISSP_WS_SIS_updateUser.updateUser(inputData);
        Test.stopTest();
        
        System.assertEquals(false, response.IsSuccess);
        System.assertEquals('015', response.ErrorCode);
        
        checkLogs(false);
    }

}