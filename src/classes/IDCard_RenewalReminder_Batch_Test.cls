@isTest
global class IDCard_RenewalReminder_Batch_Test
{

	static testMethod void myUnitTest()
	{
		Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
		Contact thisContact = new Contact();
		thisContact.RecordTypeId = recordTypeId;
		thisContact.LastName = 'Contact1';
		thisContact.Email = 'abc@abc.com';
		thisContact.VER_Number_2__c = '124412';
		insert thisContact;
		Set<String> vern = new Set<String>();
		vern.add('124412');
		test.startTest();
		IDCard_RenewalReminder_Batch cBatch = new IDCard_RenewalReminder_Batch();
		cBatch.vernumbers = vern;
		ID batchprocessid = Database.executeBatch(cBatch,200);
		test.stopTest();
	}
}
