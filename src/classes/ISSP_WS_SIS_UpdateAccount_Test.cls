@isTest
private class ISSP_WS_SIS_UpdateAccount_Test {
    
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

    private static ISSP_WS_SIS_UpdateAccount.InputData createInputData() {
        ISSP_WS_SIS_UpdateAccount.InputData inputData = new ISSP_WS_SIS_UpdateAccount.InputData();
        inputData.SISMemberID = '123456';
        inputData.MemberAccountingCode = '123';
        inputData.MemberDesignator = '12';
        inputData.ISMembershipStatus = 'Active';
        inputData.IsMembershipSubStatus = 'IATA Office';
        inputData.ISEntryDate = '01-OCT-2004';
        inputData.ICHMembershipStatus = 'true';
        inputData.ACHMembershipStatus = 'true';
        inputData.TypeOfService = 'SIS';
        inputData.RequestType = 'O';
        return inputData;
    }

    static testMethod void updateAccount_noSISMemberID() {
        ISSP_WS_SIS_UpdateAccount.InputData inputData = createInputData();
        
        Test.startTest();
        inputData.SISMemberID = '';
        ISSP_WS_SIS_UpdateAccount.ResponseData response = ISSP_WS_SIS_UpdateAccount.updateAccount(inputData);
        Test.stopTest();
        
        System.assertEquals(false, response.IsSuccess);
        System.assertEquals('018', response.ErrorCode);
    }
    
    static testMethod void updateAccount_noAccountingCode() {
        ISSP_WS_SIS_UpdateAccount.InputData inputData = createInputData();
        
        Test.startTest();
        inputData.MemberAccountingCode = '';
        ISSP_WS_SIS_UpdateAccount.ResponseData response = ISSP_WS_SIS_UpdateAccount.updateAccount(inputData);
        Test.stopTest();
        
        System.assertEquals(false, response.IsSuccess);
        System.assertEquals('023', response.ErrorCode);
    }
    
    static testMethod void updateAccount_noMemberDesignator() {
        ISSP_WS_SIS_UpdateAccount.InputData inputData = createInputData();
        
        Test.startTest();
        inputData.MemberDesignator = '';
        ISSP_WS_SIS_UpdateAccount.ResponseData response = ISSP_WS_SIS_UpdateAccount.updateAccount(inputData);
        Test.stopTest();
        
        System.assertEquals(false, response.IsSuccess);
        System.assertEquals('023', response.ErrorCode);
    }
    
    static testMethod void updateAccount_noStatus() {
        ISSP_WS_SIS_UpdateAccount.InputData inputData = createInputData();
        
        Test.startTest();
        inputData.ISMembershipStatus = '';
        ISSP_WS_SIS_UpdateAccount.ResponseData response = ISSP_WS_SIS_UpdateAccount.updateAccount(inputData);
        Test.stopTest();
        
        System.assertEquals(false, response.IsSuccess);
        System.assertEquals('023', response.ErrorCode);
    }
    
    static testMethod void updateAccount_noSubstatus() {
        ISSP_WS_SIS_UpdateAccount.InputData inputData = createInputData();
        
        Test.startTest();
        inputData.IsMembershipSubStatus = '';
        ISSP_WS_SIS_UpdateAccount.ResponseData response = ISSP_WS_SIS_UpdateAccount.updateAccount(inputData);
        Test.stopTest();
        
        System.assertEquals(false, response.IsSuccess);
        System.assertEquals('023', response.ErrorCode);
    }
    
    static testMethod void updateAccount_invalidISEntryDate() {
        ISSP_WS_SIS_UpdateAccount.InputData inputData = createInputData();
        
        Test.startTest();
        inputData.ISEntryDate = '01-XXX-2017'; //wrong date
        ISSP_WS_SIS_UpdateAccount.ResponseData response = ISSP_WS_SIS_UpdateAccount.updateAccount(inputData);
        Test.stopTest();
        
        System.assertEquals(false, response.IsSuccess);
        System.assertEquals('025', response.ErrorCode);
    }

    static testMethod void updateAccount_noICH() {
        ISSP_WS_SIS_UpdateAccount.InputData inputData = createInputData();
        
        Test.startTest();
        inputData.ICHMembershipStatus = '';
        ISSP_WS_SIS_UpdateAccount.ResponseData response = ISSP_WS_SIS_UpdateAccount.updateAccount(inputData);
        Test.stopTest();
        
        System.assertEquals(false, response.IsSuccess);
        System.assertEquals('023', response.ErrorCode);
    }
    
    static testMethod void updateAccount_noACH() {
        ISSP_WS_SIS_UpdateAccount.InputData inputData = createInputData();
        
        Test.startTest();
        inputData.ACHMembershipStatus = '';
        ISSP_WS_SIS_UpdateAccount.ResponseData response = ISSP_WS_SIS_UpdateAccount.updateAccount(inputData);
        Test.stopTest();
        
        System.assertEquals(false, response.IsSuccess);
        System.assertEquals('023', response.ErrorCode);
    }
    
    static testMethod void updateAccount_noTypeOfService() {
        ISSP_WS_SIS_UpdateAccount.InputData inputData = createInputData();
        
        Test.startTest();
        inputData.TypeOfService = '';
        ISSP_WS_SIS_UpdateAccount.ResponseData response = ISSP_WS_SIS_UpdateAccount.updateAccount(inputData);
        Test.stopTest();
        
        System.assertEquals(false, response.IsSuccess);
        System.assertEquals('010', response.ErrorCode);
    }
    
    static testMethod void updateAccount_noRequestType() {
        ISSP_WS_SIS_UpdateAccount.InputData inputData = createInputData();
        
        Test.startTest();
        inputData.RequestType = '';
        ISSP_WS_SIS_UpdateAccount.ResponseData response = ISSP_WS_SIS_UpdateAccount.updateAccount(inputData);
        Test.stopTest();
        
        System.assertEquals(false, response.IsSuccess);
        System.assertEquals('022', response.ErrorCode);
    }
    
    static testMethod void updateAccount_AccountNotFound() {
        ISSP_WS_SIS_UpdateAccount.InputData inputData = createInputData();
        
        Test.startTest();
        ISSP_WS_SIS_UpdateAccount.ResponseData response = ISSP_WS_SIS_UpdateAccount.updateAccount(inputData);
        Test.stopTest();
        
        System.assertEquals(false, response.IsSuccess);
        System.assertEquals('005', response.ErrorCode);
    }
    
    static testMethod void updateAccount_OK() {
        ISSP_WS_SIS_UpdateAccount.InputData inputData = createInputData();
        
        Account account = ISSP_ObjectFactory.createNewAccount();
        account.SIS_ID__c = inputData.SISMemberID;
        account.RecordTypeId = IATA_AIRLINE_RT.Id;
        insert account;
        
        Test.startTest();
        ISSP_WS_SIS_UpdateAccount.ResponseData response = ISSP_WS_SIS_UpdateAccount.updateAccount(inputData);
        Test.stopTest();
        
        System.assertEquals(true, response.IsSuccess);
        System.assertEquals(account.SIS_ID__c, response.SISMemberID);
    }

}