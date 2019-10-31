@isTest
private class DetailPageMessagesTest {

    @testSetup static void setup() {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c();
        country.Name = 'Test Country';
        country.ISO_Code__c = 'XT';
        country.ISO_Code_Numeric__c = 1;
        insert country;
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        acc.Sector__c = 'Travel Agent';
        acc.Location_Type__c = 'HO';
        acc.Location_Class__c = 'P';
        acc.IATA_ISO_Country__c = country.Id;
        insert acc;    
        Case cse = new Case();
        cse.AccountId = acc.Id;
        cse.Subject = 'Test Case';
        cse.CaseArea__c = 'Accreditation Process';
        cse.Reason1__c = 'Commissioner Review';
        cse.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ProcessEuropeSCE');
        cse.Origin = 'Email';
        insert cse;
    }

    @isTest static void testMethod1() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        List<Object> messages = DetailPageMessages.getMessages(acc.Id, 'Account');
        System.assertEquals(1, messages.size());
        Test.stopTest();
    }

}