@isTest
private class AirlineSuspensionChildCasesControllerTst {

	@testSetup static void setup() {

		//Data preparation
		List<Case> childList = new List<Case>();
		Case parentCase = new Case(Subject = 'parentCase');
		insert parentCase;

		Case childCase1 = new Case(ParentID = parentCase.ID, Subject = 'childCase1');
		Case childCase2 = new Case(ParentID = parentCase.ID, Subject = 'childCase2');
		childList.add(childCase1);
		childList.add(childCase2);
		insert childList;

		CaseComment comment = new CaseComment(ParentId = childCase1.Id, CommentBody = 'test CaseComment');
		insert comment;
		
	}

	@isTest static void testCaseList() {

		Case parentCase = [SELECT Subject FROM Case WHERE Subject = 'parentCase'];
		Test.startTest();

		AirlineSuspensionChildCasesController controller = new AirlineSuspensionChildCasesController(new ApexPages.StandardController(parentCase));
		List<AirlineSuspensionChildCasesController.ChildCaseWrapper> childCaseList = controller.caseList;

		Test.stopTest();

		System.assertEquals(2, childCaseList.size());

	}


	@isTest static void testCaseListNoCaseID() {
		
		PageReference pageRef = new PageReference('AirlineSuspensionChildCases');
		Test.setCurrentPage(pageRef);

		AirlineSuspensionChildCasesController controller = new AirlineSuspensionChildCasesController(new ApexPages.StandardController(new Case()));

		System.assertNotEquals(0, ApexPages.getMessages().size());
		System.assertEquals('Invalid Case', ApexPages.getMessages().get(0).getDetail());
	}


	@isTest static void testSortTable() {

		Case parentCase = [SELECT Subject FROM Case WHERE Subject = 'parentCase'];

		Test.startTest();

		AirlineSuspensionChildCasesController controller = new AirlineSuspensionChildCasesController(new ApexPages.StandardController(parentCase));
		controller.strPreviousSortField = 'ParentID';
		controller.SortTable();

		Test.stopTest();

		System.assert(controller.isSortASC);

	}

	
}