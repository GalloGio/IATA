@isTest
global class IDCard_RenewalReminder_Batch_Test
{

    static testMethod void myUnitTest()
    {
        Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        list<Contact> AllContacts = new list<Contact>();
        Contact thisContact = new Contact();
		thisContact.RecordTypeId = recordTypeId;
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