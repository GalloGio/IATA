@isTest
private class FinancialSecurityFlowHelperTest {
 
    @testSetup static void setup(){
        Account acc = new Account(Name= 'Test Account',
            Location_Type__c= 'HO',
            Location_Class__c= 'P',
            RecordTypeId= RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency'));
        insert acc;
        Contact con = new Contact(FirstName= 'Test', 
            LastName='Contact', 
            Email= 'test@mail.com', 
            User_Portal_Status__c= 'Approved Admin',
            AccountId= acc.Id);
        insert con;
        Case cse = new Case(AccountId= acc.Id,
            ContactId= con.Id
        );
        insert cse;
        Financial_Institution__c ins = new Financial_Institution__c(Name= 'Test Fin',
            Region__c= 'Europe',
            Country__c= 'Portugal',
            Institution_Type__c= 'Bank');
        insert ins;
        Financial_Security__c fin = new Financial_Security__c(Account__c= acc.Id,
            Security_Status__c= 'Active',
            Security_Type__c= 'CCG',
            Amount__c= 10000,
            Region__c= 'Europe',
            Reception_Date__c= Date.today(),
            Expiry_Date__c= Date.today().addDays(365),
            Reception_Case__c= cse.Id,
            Reasonforrequest__c= 'Financial Review',
            Financial_Institution__c= ins.Id);
        insert fin;        
    }

    @isTest static void testMethod1() {
        Test.startTest();
        List<Financial_Security__c> finSecs = [SELECT Id FROM Financial_Security__c];
        FinancialSecurityFlowHelper.sendAcknowledge(new List<Id> {finSecs[0].Id});
        Test.stopTest();
        finSecs = [SELECT Id, Acknowledgment_sent__c, Acknowledge_Sent_Date__c FROM Financial_Security__c];
        System.assertEquals(true, finSecs[0].Acknowledgment_sent__c);
        System.assertNotEquals(null, finSecs[0].Acknowledge_Sent_Date__c);
    }

}
