@isTest
private class Community360CtrlTest {

	@TestSetup
	static void makeData(){

		Account newAcc = new Account(Name='Account Test CSP Utils');
		insert newAcc;

		Contact newCon1 = new Contact(AccountId = newAcc.Id, FirstName = 'John', LastName = 'Doe', Email = 'testemail1@community.testclass', User_Portal_Status__c = 'Approved Admin');
		insert newCon1;

		User newUser = ISSP_ObjectFactory.createPortalUser(newCon1);

		Id caseRT_FDS_ICCS_Email_to_Case = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'FDS_ICCS_Email_to_Case');

		Case newCase = new Case(Subject = 'Bla', Region__c = 'Africa & Middle East',
							Origin = 'Portal', CaseArea__c = 'Accreditation',
							E2CP__AdditionalCC__c = 'testqa.tcosta@yopmail.com.inactive.inactive',
							RecordTypeId = caseRT_FDS_ICCS_Email_to_Case,
							Visible_on_ISS_Portal__c = true, ContactId = newCon1.Id);
		insert newCase;
	}

	@isTest
	static void testCreateReadEntry(){
		User user  = [SELECT Id FROM User WHERE Email LIKE 'testemail1@community.testclass' LIMIT 1];
		Case viewedCase = [SELECT Id FROM Case WHERE Subject = 'Bla' LIMIT 1];
		Test.startTest();
			System.runAs(user){
				Community360Ctrl.createCommunity360ReadEntry(viewedCase.Id);
			}
		Test.stopTest();
		List<NetworkUserHistoryRecent> history = [SELECT Id FROM NetworkUserHistoryRecent WHERE NetworkUserId = :user.Id];
		System.assertEquals(1, history.size());

	}
}