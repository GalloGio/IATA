@isTest
public class ISSP_WS_SISAccountTest {

    @TestSetup
    static void loadData() {
        list<ISSP_Int_Error__c> listIntError = new list<ISSP_Int_Error__c>();
        for (String code: new list<String>{'001','005'}) {
            listIntError.add(new ISSP_Int_Error__c(
                Name = code,
                Error_Message__c = 'description ' + code)
            );
        }
        insert listIntError;
    }

    static testMethod void testUpdateAccount_invalidSISID() {
        ISSP_WS_SISAccount.AccountInputData inputData = new ISSP_WS_SISAccount.AccountInputData();
        inputData.sisAccountId = null;

        Test.startTest();
        ISSP_WS_SISAccount.AccountInputDataResponse response = ISSP_WS_SISAccount.updateAccount(inputData);
        System.assertEquals(false,response.isSuccess);
        System.assertEquals('001',response.responseErrorCode);
        Test.stopTest();
    }

    static testMethod void testUpdateAccount_accountNotFound() {
        ISSP_WS_SISAccount.AccountInputData inputData = new ISSP_WS_SISAccount.AccountInputData();
        inputData.sisAccountId = '12345';

        Test.startTest();
        ISSP_WS_SISAccount.AccountInputDataResponse response = ISSP_WS_SISAccount.updateAccount(inputData);
        System.assertEquals(false,response.isSuccess);
        System.assertEquals('005',response.responseErrorCode);
        Test.stopTest();
    }
    
    static testMethod void testUpdateAccount_InvalidInsert() {
        Account account = new Account(
            Name = 'TestAccount',
            SIS_ID__c = '12345'
        );
        insert account;

        ISSP_WS_SISAccount.AccountInputData inputData = new ISSP_WS_SISAccount.AccountInputData();
        inputData.sisAccountId = account.SIS_ID__c;
        inputData.sis2LetterCode = 'BBB'; //Invalid lenght, it causes an error

        Test.startTest();
        ISSP_WS_SISAccount.AccountInputDataResponse response = ISSP_WS_SISAccount.updateAccount(inputData);
        System.assertEquals('001',response.responseErrorCode);
        Test.stopTest();
    }

    static testMethod void testUpdateAccount_OK() {
        Account account = new Account(
            Name = 'TestAccount',
            SIS_ID__c = '12345'
        );
        insert account;

        ISSP_WS_SISAccount.AccountInputData inputData = new ISSP_WS_SISAccount.AccountInputData();
        inputData.sisAccountId = account.SIS_ID__c;
        inputData.sis3DigitCode = 'AAA';
        inputData.sis2LetterCode = 'BB';
        inputData.sisVerified = 'true';
        inputData.sisStatus = 'Active';
        inputData.sisSubStatus = 'IATA Office';

        Test.startTest();
        ISSP_WS_SISAccount.AccountInputDataResponse response = ISSP_WS_SISAccount.updateAccount(inputData);
        System.assert(response.isSuccess,response);
        System.assertEquals(true,response.isSuccess);
        
        account = [SELECT Id, EF_SIS_Code__c, EF_SIS_Designator__c, EF_SIS_Code_Verified__c, SIS_Status__c, SIS_Sub_Status__c
            FROM Account
            WHERE Id = :account.Id];
        System.assertEquals(inputData.sis3DigitCode,account.EF_SIS_Code__c);
        System.assertEquals(inputData.sis2LetterCode,account.EF_SIS_Designator__c);
        System.assertEquals(Boolean.valueOf(inputData.sisVerified),account.EF_SIS_Code_Verified__c);
        System.assertEquals(inputData.sisStatus,account.SIS_Status__c);
        System.assertEquals(inputData.sisSubStatus,account.SIS_Sub_Status__c);
        Test.stopTest();
    }

}