@isTest
private class AutomateCaseCommentToChildCaseTest {

	@TestSetup
	static void testSetup(){
		Case newCase = new Case(Subject = 'Case Test', Region__c = 'Africa & Middle East',
								Origin = 'Portal', CaseArea__c = 'Accreditation',E2CP__Most_Recent_Public_Comment__c='test comment body');
		Case newCase1 = new Case(Subject = 'Case Test2', Region__c = 'Africa & Middle East',
								Origin = 'Portal', CaseArea__c = 'Accreditation');
		insert new List<Case>{newCase,newCase1};

		Case newCase2 = new Case(Subject = 'Case Test 1', Region__c = 'Africa & Middle East',
								 Origin = 'Portal', CaseArea__c = 'Accreditation',
								 E2CP__AdditionalCC__c = 'testqa.tcosta@yopmail.com.inactive.inactive', ParentId= newCase.Id);

		insert newCase2;
	}

	@isTest
	public static void shouldFail(){
		Test.startTest();
		List<Boolean> result = AutomateCaseCommentToChildCase.copyCommentToChilds(new List<Id>());
		List<CaseComment> comments = [SELECT Id, CommentBody FROM CaseComment WHERE ParentId IN (SELECT Id FROM Case WHERE Subject = 'Case Test 1')];
		Test.stopTest();
		System.assertEquals(1, result.size());
		System.assertEquals(false, result.get(0));
		System.assertEquals(0, comments.size());
	}

	@isTest
	public static void shouldFail2(){
		Test.startTest();
		Case testCase = [SELECT Id FROM Case WHERE Subject='Case Test2'][0];
		List<Boolean> result = AutomateCaseCommentToChildCase.copyCommentToChilds(new List<Id>{testCase.Id});
		List<CaseComment> comments = [SELECT Id, CommentBody FROM CaseComment WHERE ParentId IN (SELECT Id FROM Case WHERE Subject = 'Case Test 1')];
		Test.stopTest();
		System.assertEquals(1, result.size());
		System.assertEquals(false, result.get(0));
		System.assertEquals(0, comments.size());
	}

	@isTest
	public static void shouldSucceed(){
		Test.startTest();
		Case testCase = [SELECT Id FROM Case WHERE Subject='Case Test'][0];
		List<Boolean> result = AutomateCaseCommentToChildCase.copyCommentToChilds(new List<Id>{testCase.Id});
		List<CaseComment> comments = [SELECT Id, CommentBody FROM CaseComment WHERE ParentId IN (SELECT Id FROM Case WHERE Subject = 'Case Test 1')];
		Test.stopTest();

		System.assertEquals(1, result.size());
		System.assertEquals(true, result.get(0));
		System.assertEquals(1, comments.size());
		System.assertEquals('test comment body', comments.get(0).CommentBody);
	}
}