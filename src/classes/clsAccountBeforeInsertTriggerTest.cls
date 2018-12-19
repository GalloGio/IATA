// Alexandre McGraw
// 2013-10-01
@isTest
private class clsAccountBeforeInsertTriggerTest {

    // test the assignation of the assessment template on the Account creation
    static testMethod void testAssessmentTemplateAssignation() {
        
        // get the IATA Standard Account record type
        Id standardAccountRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
        
        // create test account
        Account account1 = new Account();
        account1.Name = 'Test account';
        account1.BillingCity = 'Montreal';
        account1.BillingCountry = 'Canada';
        account1.BillingStreet = 'some street';
        account1.Location_Type__c = 'HO';
        account1.Status__c = 'Approved';
        account1.Type = 'IATA Passenger Sales Agent';
        account1.IATACode__c = '9999999';
        account1.AIMS_ID__c = '9999999999';
        account1.RecordTypeId = standardAccountRecordTypeId;
        Test.startTest();
        
        insert account1;
        
        // query the account with the assessment template
        Account[] theAccount = [Select a.Assessment_Template__c, a.Assessment_Template_Code__c from Account a where a.ID = :account1.ID];
        //system.assert(theAccount[0].Assessment_Template__c != null);
        
        Test.stopTest();
    }
}