@isTest
private class AutomateCaseCommentToParentCaseTest {
	@TestSetup
	static void testSetup(){

		Case newCase = new Case(Subject = 'Case Test', Region__c = 'Africa & Middle East',
								Origin = 'Portal', CaseArea__c = 'Accreditation',E2CP__Most_Recent_Public_Comment__c='test comment body');

		insert newCase;

		Case newCase2 = new Case(Subject = 'Case Test 1', Region__c = 'Africa & Middle East',
								 Origin = 'Portal', CaseArea__c = 'Accreditation',
								 E2CP__AdditionalCC__c = 'testqa.tcosta@yopmail.com.inactive.inactive', ParentId= newCase.Id);

		insert newCase2;

		EmailMessage message = new EmailMessage(FromAddress = 'test@test.com',
			FromName = 'Test',
			ToAddress = 'test2@test.com',
			Subject = 'Test Subject',
			TextBody = 'Test Body For Email',
			ParentId = newCase2.Id);

		EmailMessage message2 = new EmailMessage(FromAddress = 'test@test2.com',
			FromName = 'Test2',
			ToAddress = 'test2@test2.com',
			Subject = 'Test Subject2',
			TextBody = 'Test Body For Email2',
			ParentId = newCase.Id);

		insert new List<EmailMessage>{message,message2};
	}

	@isTest
	public static void shoouldFail(){
		Test.startTest();
		List<Boolean> result = AutomateCaseCommentToParentCase.copyCommentToParent(new List<Id>());
		Test.stopTest();
		System.assertEquals(1, result.size());
		System.assertEquals(false, result.get(0));
	}

	@isTest
	public static void shoouldFail2(){
		Test.startTest();
		EmailMessage message = [SELECT Id FROM EmailMessage WHERE Subject='Test Subject2'][0];
		List<Boolean> result = AutomateCaseCommentToParentCase.copyCommentToParent(new List<Id>{message.Id});
		Test.stopTest();
		System.assertEquals(1, result.size());
		System.assertEquals(false, result.get(0));
	}

	@isTest
	public static void shoouldSucced(){
		Test.startTest();
		EmailMessage message = [SELECT Id FROM EmailMessage WHERE Subject='Test Subject'][0];
		List<Boolean> result = AutomateCaseCommentToParentCase.copyCommentToParent(new List<Id>{message.Id});
		Test.stopTest();

		System.assertEquals(1, result.size());
		System.assertEquals(true, result.get(0));
	}
}