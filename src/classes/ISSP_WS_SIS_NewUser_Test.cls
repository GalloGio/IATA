@isTest
private class ISSP_WS_SIS_NewUser_Test {
    
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

    public static ISSP_WS_SIS_NewUser.InputData createInputData() {
        ISSP_WS_SIS_NewUser.InputData inputData = new ISSP_WS_SIS_NewUser.InputData();
        inputData.SISMemberID = 'SISID';
        inputData.FirstName = 'firstName';
        inputData.LastName = 'lastName';
        inputData.EmailAddress = 'test@email.com';
        inputData.UserType = 'S';
        inputData.TypeOfService = 'SIS';
        inputData.Description = '';
        return inputData;
    }

    static testMethod void newUser_noSISID() {
        ISSP_WS_SIS_NewUser.InputData inputData = createInputData();
        
        Test.startTest();
        inputData.SISMemberID = '';
        ISSP_WS_SIS_NewUser.ResponseData response = ISSP_WS_SIS_NewUser.newUser(inputData);
        Test.stopTest();
        
        System.assertEquals(false, response.IsSuccess);
        System.assertEquals('018', response.ErrorCode);
    }
    
    static testMethod void newUser_noFirstName() {
        ISSP_WS_SIS_NewUser.InputData inputData = createInputData();
        
        Test.startTest();
        inputData.FirstName = '';
        ISSP_WS_SIS_NewUser.ResponseData response = ISSP_WS_SIS_NewUser.newUser(inputData);
        Test.stopTest();
        
        System.assertEquals(false, response.IsSuccess);
        System.assertEquals('019', response.ErrorCode);
    }
    
    static testMethod void newUser_noLastName() {
        ISSP_WS_SIS_NewUser.InputData inputData = createInputData();
        
        Test.startTest();
        inputData.LastName = '';
        ISSP_WS_SIS_NewUser.ResponseData response = ISSP_WS_SIS_NewUser.newUser(inputData);
        Test.stopTest();
        
        System.assertEquals(false, response.IsSuccess);
        System.assertEquals('003', response.ErrorCode);
    }

    static testMethod void newUser_noEmail() {
        ISSP_WS_SIS_NewUser.InputData inputData = createInputData();
        
        Test.startTest();
        inputData.EmailAddress = '';
        ISSP_WS_SIS_NewUser.ResponseData response = ISSP_WS_SIS_NewUser.newUser(inputData);
        Test.stopTest();
        
        System.assertEquals(false, response.IsSuccess);
        System.assertEquals('002', response.ErrorCode);
    }
    
    static testMethod void newUser_invalidEmail() {
        ISSP_WS_SIS_NewUser.InputData inputData = createInputData();
        
        Test.startTest();
        inputData.EmailAddress = 'wrongemail';
        ISSP_WS_SIS_NewUser.ResponseData response = ISSP_WS_SIS_NewUser.newUser(inputData);
        Test.stopTest();
        
        System.assertEquals(false, response.IsSuccess);
        System.assertEquals('006', response.ErrorCode);
    }
    
    static testMethod void newUser_invalidUserType() {
        ISSP_WS_SIS_NewUser.InputData inputData = createInputData();
        
        Test.startTest();
        inputData.UserType = '';
        ISSP_WS_SIS_NewUser.ResponseData response = ISSP_WS_SIS_NewUser.newUser(inputData);
        Test.stopTest();
        
        System.assertEquals(false, response.IsSuccess);
        System.assertEquals('020', response.ErrorCode);
    }
    
    static testMethod void newUser_invalidTypeOfService() {
        ISSP_WS_SIS_NewUser.InputData inputData = createInputData();
        
        Test.startTest();
        inputData.TypeOfService = '';
        ISSP_WS_SIS_NewUser.ResponseData response = ISSP_WS_SIS_NewUser.newUser(inputData);
        Test.stopTest();
        
        System.assertEquals(false, response.IsSuccess);
        System.assertEquals('010', response.ErrorCode);
    }
    
    static testMethod void createSISUser_NoContactOrUser() {
        ISSP_WS_SIS_NewUser.InputData inputData = createInputData();
        
        Test.startTest();
        ISSP_WS_SIS_NewUser.ResponseData response = ISSP_WS_SIS_NewUser.newUser(inputData);
        Test.stopTest();
        
        System.assertEquals(false, response.IsSuccess);
        System.assertEquals('011', response.ErrorCode);
    }
    
    static testMethod void createSISUser_NoUser() {
        ISSP_WS_SIS_NewUser.InputData inputData = createInputData();
        
        Account account = ISSP_ObjectFactory.createNewAccount();
        account.SIS_ID__c = inputData.SISMemberID;
        account.RecordTypeId = IATA_AIRLINE_RT.Id;
        insert account;
        
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = account.Id;
        contact.FirstName = inputData.FirstName;
        contact.LastName = inputData.LastName;
        contact.User_Portal_Status__c = ISSP_Constant.APPROVED_CONTACT_STATUS;
        contact.Email = inputData.EmailAddress;
        insert contact;

        Test.startTest();
        ISSP_WS_SIS_NewUser.ResponseData response = ISSP_WS_SIS_NewUser.newUser(inputData);
        Test.stopTest();
        
        System.assertEquals(true, response.IsSuccess);
        System.assertEquals(contact.Id, response.FederationID);
    }
    
    static testMethod void createSISUser_ExistingUser() {
        ISSP_WS_SIS_NewUser.InputData inputData = createInputData();
        
        Account account = ISSP_ObjectFactory.createNewAccount();
        account.SIS_ID__c = inputData.SISMemberID;
        account.RecordTypeId = IATA_AIRLINE_RT.Id;
        insert account;
        
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = account.Id;
        contact.FirstName = inputData.FirstName;
        contact.LastName = inputData.LastName;
        contact.User_Portal_Status__c = ISSP_Constant.APPROVED_CONTACT_STATUS;
        contact.Email = inputData.EmailAddress;
        insert contact;
        
        //this call creates a user
        ISSP_WS_SIS_NewUser.ResponseData response = ISSP_WS_SIS_NewUser.newUser(inputData);
        System.assertEquals(true, response.IsSuccess);
        //this call removes access to SIS
        List <Portal_Application_Right__c> appRightList = [
            SELECT Id, Right__c
            FROM Portal_Application_Right__c
            WHERE Contact__c = :contact.Id
            AND Portal_Application__c = :ISSP_WS_SIS_Common.SIS_ID_PORTAL_APP];
        for (Portal_Application_Right__c right: appRightList) {
            right.Right__c = 'Access Denied';
        }
        update appRightList;

        Test.startTest();
        // second call detects exisitng user 
        response = ISSP_WS_SIS_NewUser.newUser(inputData);
        Test.stopTest();
        
        System.assertEquals(true, response.IsSuccess);
        System.assertEquals(contact.Id, response.FederationID);
    }

}