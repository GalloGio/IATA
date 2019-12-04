@isTest
private class AutomateCaseEmailMessageToParentCaseTest {
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
			ParentId = newCase.Id);

		EmailMessage message2 = new EmailMessage(FromAddress = 'test@test2.com',
			FromName = 'Test2',
			ToAddress = 'test2@test2.com',
			Subject = 'Test Subject2',
			TextBody = 'Test Body For Email2',
			ParentId = newCase2.Id);

		insert new List<EmailMessage>{message,message2};
	}

	@isTest
	public static void shouldFail(){
		Test.startTest();
		List<Boolean> result = AutomateCaseEmailMessageToParentCase.copyEmailMessageToParent(new List<Id>());
		List<EmailMessage> messages = [SELECT Id FROM EmailMessage WHERE  ParentId IN (SELECT Id FROM Case WHERE Subject = 'Case Test')];
		Test.stopTest();
		System.assertEquals(1, result.size());
		System.assertEquals(false, result.get(0));
		System.assertEquals(1, messages.size());
	}

	@isTest
	public static void shouldFail2(){
		Test.startTest();
		EmailMessage message = [SELECT Id FROM EmailMessage WHERE Subject='Test Subject'];
		List<Boolean> result = AutomateCaseEmailMessageToParentCase.copyEmailMessageToParent(new List<Id>{message.Id});
		List<EmailMessage> messages = [SELECT Id FROM EmailMessage WHERE Subject = 'Test Subject2' AND ParentId IN (SELECT Id FROM Case WHERE Subject = 'Case Test')];
		Test.stopTest();
		System.assertEquals(1, result.size());
		System.assertEquals(false, result.get(0));
		System.assertEquals(0, messages.size());
	}

	@isTest
	public static void shouldSucceed(){
		Test.startTest();
		EmailMessage message = [SELECT Id FROM EmailMessage WHERE Subject='Test Subject2'];
		List<Boolean> result = AutomateCaseEmailMessageToParentCase.copyEmailMessageToParent(new List<Id>{message.Id});
		List<EmailMessage> messages = [SELECT Id FROM EmailMessage WHERE ParentId IN (SELECT Id FROM Case WHERE Subject = 'Case Test')];
		Test.stopTest();
		System.assertEquals(1, result.size());
		System.assertEquals(true, result.get(0));
		System.assertEquals(2, messages.size());
	}
}