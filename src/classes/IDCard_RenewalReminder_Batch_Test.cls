@isTest
global class IDCard_RenewalReminder_Batch_Test
{

    static testMethod void myUnitTest()
    {
        List<RecordType> CtsRecordTypes = [Select r.Id, r.Name From RecordType r Where r.SobjectType  = 'Contact' limit 1];
        list<Contact> AllContacts = new list<Contact>();
        Contact thisContact = new Contact();
		thisContact.RecordTypeId = CtsRecordTypes.get(0).Id;
		thisContact.LastName = 'Contact1';
		thisContact.Email = 'abc@abc.com';
		AllContacts.add(thisContact);
		     
    	test.startTest();
    	IDCard_RenewalReminder_Batch cBatch = new IDCard_RenewalReminder_Batch();
    	cBatch.ContactScope = AllContacts;
    	ID batchprocessid = Database.executeBatch(cBatch,200);
    	test.stopTest();
    }
}