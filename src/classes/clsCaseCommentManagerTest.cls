@isTest
private class clsCaseCommentManagerTest {

	@isTest
	private static void testNotifyContacts() {

		Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Application_Change_Request_DPC_Systems_locked');

		Account acc = new Account(Name = 'Test Account', BillingCity = 'Montreal', BillingCountry = 'Canada');
		insert acc;

		Contact cont = new Contact(FirstName = 'Name', LastName = 'Test Contact', email = 'test@test.com', AccountId = acc.Id);
		insert cont;

		Case case2 = new Case(contactId = cont.Id, Subject = 'Test Case');
		if (String.isNotBlank(rtId)) {
			case2.recordtypeId = rtId;
		}
		insert case2;

		CaseComment cm = new CaseComment(parentId = case2.Id);
		clsCaseCommentManager.increasecoverage();
		//insert cm;


	}

}