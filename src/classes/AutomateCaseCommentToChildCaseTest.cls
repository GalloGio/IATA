@isTest
private class AutomateCaseCommentToChildCaseTest {

	@TestSetup
	static void testSetup(){

		Id queueId = [SELECT Id FROM Group WHERE DeveloperName = 'GCS_iiNet' AND Type = 'Queue'].Id;

		Case newCase = new Case(Subject = 'Case Test', Region__c = 'Africa & Middle East',
								Origin = 'Portal', CaseArea__c = 'Accreditation',E2CP__Most_Recent_Public_Comment__c='test comment body');
		Case newCase1 = new Case(Subject = 'Case Test1', Region__c = 'Africa & Middle East',
								Origin = 'Portal', CaseArea__c = 'Accreditation',E2CP__Most_Recent_Public_Comment__c='',
								OwnerId=queueId);
		insert new List<Case>{newCase,newCase1};

		Case newCase2 = new Case(Subject = 'Case Test 2', Region__c = 'Africa & Middle East',
								 Origin = 'Portal', CaseArea__c = 'Accreditation',
								 E2CP__AdditionalCC__c = 'testqa.tcosta@yopmail.com.inactive.inactive', ParentId= newCase.Id);
		Case newCase3 = new Case(Subject = 'Case Test 3', Region__c = 'Africa & Middle East',
								 Origin = 'Portal', CaseArea__c = 'Accreditation',
								 E2CP__AdditionalCC__c = 'testqa.tcosta@yopmail.com.inactive.inactive', ParentId= newCase1.Id);

		insert new List<Case>{newCase2,newCase3};
	}

	@isTest
	public static void shouldFail(){
		Test.startTest();
		AutomateCaseCommentToChildCase.copyCommentToChilds(new List<Id>());
		List<CaseComment> comments = [SELECT Id, CommentBody FROM CaseComment WHERE ParentId IN (SELECT Id FROM Case WHERE Subject = 'Case Test 1')];
		Test.stopTest();
		System.assertEquals(0, comments.size());
	}

	@isTest
	public static void shouldSucceed(){
		Test.startTest();
		Case testCase = [SELECT Id FROM Case WHERE Subject='Case Test'];
		AutomateCaseCommentToChildCase.copyCommentToChilds(new List<Id>{testCase.Id});
		List<CaseComment> comments = [SELECT Id, CommentBody FROM CaseComment WHERE ParentId IN (SELECT Id FROM Case WHERE Subject = 'Case Test 2')];
		Test.stopTest();
		System.assertEquals(1, comments.size());
		System.assertEquals('test comment body', comments.get(0).CommentBody);
	}

	@isTest
	public static void shouldSucceed2(){
		Test.startTest();
		Case testCase = [SELECT Id FROM Case WHERE Subject='Case Test1'];
		testCase.E2CP__Most_Recent_Public_Comment__c = 'testing for case after trigger';
		update testCase;
		//AutomateCaseCommentToChildCase.copyCommentToChilds(new List<Id>{testCase.Id});
		List<CaseComment> comments = [SELECT Id, CommentBody FROM CaseComment WHERE ParentId IN (SELECT Id FROM Case WHERE Subject = 'Case Test 3')];
		Test.stopTest();
		System.assertEquals(1, comments.size());
		System.assertEquals('testing for case after trigger', comments.get(0).CommentBody);
	}
}
