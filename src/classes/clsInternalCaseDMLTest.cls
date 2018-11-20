@isTest
private class clsInternalCaseDMLTest {

    @isTest static void test_method_one() {
        
        // Get Record Type Cases - SIS Help Desk ID
        ID CasesRegionRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'CasesEurope');
        ID IDFSISSRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'InternalCasesEuropeSCE');
        test.startTest();
        Account account1 = new Account();
        account1.Name = 'Test account';
        account1.BillingCity = 'Lisbon';
        account1.BillingCountry = 'Portugal';
        account1.BillingStreet = 'some street';
        account1.IATACode__c = '1234567';
        insert account1;
        
        // create test contact
        Contact contact1 = new Contact();
        contact1.FirstName = 'John';
        contact1.LastName = 'Doe';
        contact1.AccountId = account1.Id;
        contact1.Email = 'some@email.org';
        insert contact1;

        BusinessHours bh = [select Id from BusinessHours limit 1];

        Case parentCase = new Case();
        parentCase.Status = 'Open';
        parentCase.Origin = 'Phone';
        parentCase.BusinessHours = bh;
        parentCase.ContactId = contact1.Id;
        parentCase.RecordTypeId = CasesRegionRecordTypeID;
        insert parentCase;

        Case childCase = new Case();
        childCase.Status = 'Open';
        childCase.Origin = 'Phone';
        childCase.BusinessHours = bh;
        childCase.ContactId= contact1.Id;
        childCase.parentId = parentCase.Id;
        childCase.RecordTypeId = IDFSISSRecordTypeID;
        insert childCase;

        childCase.Status = 'Closed';
        update childCase;
        
        test.stoptest();
        
        
        case result = [select id, status from case where id =: parentCase.id];
        
        system.assertEquals(result.status,'Action Needed');
    }
    
}