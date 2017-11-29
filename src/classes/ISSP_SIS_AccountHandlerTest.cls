@isTest
private class ISSP_SIS_AccountHandlerTest {

    @TestSetup
    private static void loadData() {
        ISSP_WS_SIS_Callout_Common_Test.load_ISSP_CS();
        list<IATA_ISO_Country__c> listCountries = new list<IATA_ISO_Country__c>{
            new IATA_ISO_Country__c(Name='Spain', ISO_Code__c='SP')
        };
        insert listCountries;
        
        list<ISSP_SIS_Account_Allowed_Countries__c> listAllowedCountries = new list<ISSP_SIS_Account_Allowed_Countries__c>{
        	new ISSP_SIS_Account_Allowed_Countries__c(Name='SP')
        };
        insert listAllowedCountries;
    }

    static testMethod void test_afterInsert_NonSISAccount() {
        Account account = new Account(Name = 'test');
        Test.startTest();
        insert account;
        Test.stopTest();
        
        list<ISSP_Web_Service_Log__c> listLogs = [SELECT Id FROM ISSP_Web_Service_Log__c];
        System.assert(listLogs.isEmpty());
    }
    
    static testMethod void test_afterInsert_createValidSISAccount() {
        String testSISID = '123456';
        IATA_ISO_Country__c country = [SELECT Id FROM IATA_ISO_Country__c WHERE ISO_Code__c='SP'];
        Account account = new Account(
            RecordtypeId=ISSP_SIS_AccountHandler.RT_AGENCY,
            Status__c = '',
            IATA_ISO_Country__c = country.Id,
            Name = 'test'
        );
        ISSP_WS_SIS_Callout_CreateAccount.TEST_RESPONSE = '<Response><IsSuccess>true</IsSuccess><SISMemberID>' + testSISID + '</SISMemberID></Response>';
        
        Test.startTest();
        insert account;
        Test.stopTest();
        
        list<ISSP_Web_Service_Log__c> listLogs = [SELECT Id, Success__c, Web_Service__c, Method__c, System__c, Error_Message__c FROM ISSP_Web_Service_Log__c];
        System.assert(listLogs.size()==1, '' + listLogs);
        System.assertEquals(true, listLogs[0].Success__c, '' + listLogs[0].Error_Message__c);
        System.assertEquals('ISSP_WS_SIS_Callout', listLogs[0].Web_Service__c);
        System.assertEquals('CreateAccount', listLogs[0].Method__c);
        System.assertEquals('SIS', listLogs[0].System__c);
        
        Account result = [SELECT SIS_ID__c FROM Account WHERE id = :account.Id];
        System.assertEquals(testSISID, result.SIS_ID__c);
    }
    
    static testMethod void test_afterInsert_updateValidSISAccount() {
        String testSISID = '123456';
        IATA_ISO_Country__c country = [SELECT Id FROM IATA_ISO_Country__c WHERE ISO_Code__c='SP'];
        Account account = new Account(
            RecordtypeId=ISSP_SIS_AccountHandler.RT_AGENCY,
            Status__c = '',
            IATA_ISO_Country__c = country.Id,
            Name = 'test',
            SIS_ID__c = testSISID
        );
        
        ISSP_WS_SIS_Callout_UpdateAccount.TEST_RESPONSE = '<Response><IsSuccess>true</IsSuccess><SISMemberID>' + testSISID + '</SISMemberID></Response>';
        
        Test.startTest();
        insert account;
        Test.stopTest();
        
        list<ISSP_Web_Service_Log__c> listLogs = [SELECT Id, Success__c, Web_Service__c, Method__c, System__c, Error_Message__c FROM ISSP_Web_Service_Log__c];
        System.assert(listLogs.size()==1, '' + listLogs);
        System.assertEquals(true, listLogs[0].Success__c, '' + listLogs[0].Error_Message__c);
        System.assertEquals('ISSP_WS_SIS_Callout', listLogs[0].Web_Service__c);
        System.assertEquals('UpdateAccount', listLogs[0].Method__c);
        System.assertEquals('SIS', listLogs[0].System__c);
        Account result = [SELECT SIS_ID__c FROM Account WHERE id = :account.Id];
        System.assertEquals(testSISID, result.SIS_ID__c);
    }
        
    static testMethod void test_beforeUpdate_createValidSISAccount() {
        String testSISID = '123456';
        IATA_ISO_Country__c country = [SELECT Id FROM IATA_ISO_Country__c WHERE ISO_Code__c='SP'];
        Account account = new Account(
            Name = 'test'
        );
        insert account;
        
        ISSP_WS_SIS_Callout_CreateAccount.TEST_RESPONSE = '<Response><IsSuccess>true</IsSuccess><SISMemberID>' + testSISID + '</SISMemberID></Response>';
        
        Test.startTest();
        account.RecordtypeId=ISSP_SIS_AccountHandler.RT_AGENCY;
        account.Status__c = '';
        account.IATA_ISO_Country__c = country.Id;
        account.TradeName__c = 'TradeName';
        update account;
        Test.stopTest();
        
        list<ISSP_Web_Service_Log__c> listLogs = [SELECT Id, Success__c, Web_Service__c, Method__c, System__c, Error_Message__c FROM ISSP_Web_Service_Log__c];
        System.assert(listLogs.size()==1, '' + listLogs);
        System.assertEquals(true, listLogs[0].Success__c, '' + listLogs[0].Error_Message__c);
        System.assertEquals('ISSP_WS_SIS_Callout', listLogs[0].Web_Service__c);
        System.assertEquals('CreateAccount', listLogs[0].Method__c);
        System.assertEquals('SIS', listLogs[0].System__c);
        
        Account result = [SELECT SIS_ID__c FROM Account WHERE id = :account.Id];
        System.assertEquals(testSISID, result.SIS_ID__c);
    }
    
    static testMethod void test_beforeUpdate_updateValidSISAccount() {
        String testSISID = '123456';
        IATA_ISO_Country__c country = [SELECT Id FROM IATA_ISO_Country__c WHERE ISO_Code__c='SP'];
        Account account = new Account(
            RecordtypeId=ISSP_SIS_AccountHandler.RT_AGENCY,
            Status__c = '',
            Name = 'test',
            SIS_ID__c = testSISID
        );
        insert account;
        
        delete [SELECT Id FROM ISSP_Web_Service_Log__c];
        ISSP_WS_SIS_Callout_UpdateAccount.TEST_RESPONSE = '<Response><IsSuccess>true</IsSuccess><SISMemberID>' + testSISID + '</SISMemberID></Response>';
        
        Test.startTest();
        account.IATA_ISO_Country__c = country.Id;
        account.BillingCity = 'City';
        update account;
        Test.stopTest();
        
        list<ISSP_Web_Service_Log__c> listLogs = [SELECT Id, Success__c, Web_Service__c, Method__c, System__c, Error_Message__c FROM ISSP_Web_Service_Log__c];
        //System.assert(listLogs.size()==1, '' + listLogs);
        System.assertEquals(true, listLogs[0].Success__c, '' + listLogs[0].Error_Message__c);
        System.assertEquals('ISSP_WS_SIS_Callout', listLogs[0].Web_Service__c);
        System.assertEquals('UpdateAccount', listLogs[0].Method__c);
        System.assertEquals('SIS', listLogs[0].System__c);
        Account result = [SELECT SIS_ID__c FROM Account WHERE id = :account.Id];
        System.assertEquals(testSISID, result.SIS_ID__c);
    }
}