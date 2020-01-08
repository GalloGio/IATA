@isTest
private class TestCodeCoverage{


	static testMethod void CreatecContactTest() {
		clsMassCaseCreationController.cContact c = new clsMassCaseCreationController.cContact(New Contact());
	}

	static testMethod void testMyController() {

		//Use the PageReference Apex class to instantiate a page
		PageReference pageRef = Page.Mass_Case_Creation_Page;
		//In this case, the Visualforce page named 'success' is the starting point of this test method.
		Test.setCurrentPage(pageRef);
		//Instantiate and construct the controller class.
		clsMassCaseCreationController controller = new clsMassCaseCreationController();

		String OutputStr = controller.debugSoql;

		OutputStr = controller.ProcessOutput;

		OutputStr = controller.Warning;

		OutputStr = controller.sortDir;
		OutputStr = controller.sortField;

		List<selectOption> FinancialReviewTypes = controller.lstFinReviewType;


		// Set some properties
		controller.CaseParameter.Subject = 'hi';
		controller.CaseParameter.Financial_Review_Type__c = 'Annual';

		//

		controller.MassCaseCreateSendEmail();

		Apexpages.currentPage().getParameters().put('agenttype','');
		Apexpages.currentPage().getParameters().put('agentstatus','');
		Apexpages.currentPage().getParameters().put('email','');
		Apexpages.currentPage().getParameters().put('country','');
		controller.runSearch();

		Apexpages.currentPage().getParameters().put('country','Canada');
		Apexpages.currentPage().getParameters().put('yearend','February');
		controller.runSearch();

		Apexpages.currentPage().getParameters().put('country','Canada');
		Apexpages.currentPage().getParameters().put('yearend','');
		Apexpages.currentPage().getParameters().put('agenttype','IATA Cargo Agent-IATA Passenger Sales Agent');
		Apexpages.currentPage().getParameters().put('agentstatus','Approved-Listed-Changes processed');
		controller.runSearch();

		controller.SelectAll();
		List<clsMassCaseCreationController.cContact> tmp = Controller.Contacts;
		Controller.Contacts = tmp;

		controller.CaseParameter.Subject = 'Test Case Unit Testing';
		controller.CaseParameter.Financial_Review_Type__c = 'Annual';
		controller.MassCaseCreate();


		//controller.first();
		//controller.last();
		//controller.previous();
		//controller.next();

		Boolean o = controller.openCase;
		Boolean num = controller.isNbrRecordsDisplayed;
		Integer num2 = controller.nbrSelectedRecords;
		Integer num3 = controller.nbrFoundRecords;
		controller.nbrFoundRecords = num3;
		//Integer num4 = controller.currentPage;
		//controller.currentPage = num4;

		controller.updateNbrSelectedRecords();



	   // Boolean boo = controller.hasNext;
		//boo = controller.hasPrevious;

		Integer nbPages = controller.pageNumber;

		Apexpages.currentPage().getParameters().put('email','1');
		Apexpages.currentPage().getParameters().put('agenttype','IATA Passenger Sales Agent');
		Apexpages.currentPage().getParameters().put('agentstatus','Approved');
		controller.runSearch();

		Apexpages.currentPage().getParameters().put('email','2');
		controller.runSearch();

		controller.toggleSort();
	}
/*
	static testMethod void testStuff() {

		//Instantiate and construct the controller class.
		clsMassCaseCreationController controller = new clsMassCaseCreationController();

		EmailTemplate__c bob = controller.EmailParameter;

		//List<selectOption> l = controller.lstLanguage;

		List<selectOption> l2 = controller.lstFinancialMonth;

		controller.toggleSort();

		controller.runQuery();

		PageReference pr = controller.MassCaseCreate();

		PageReference pr2 = controller.SelectAll();

		//controller.ValidateContacts();

		boolean b1 = controller.hasFirst;

		boolean b2 = controller.hasLast;

		boolean b3 = controller.hasNext;

		boolean b4 = controller.hasPrevious;

		Integer i = controller.pageNumber;

		/*controller.first();
		controller.last();
		controller.previous();
		controller.next();*/

	  /*  Boolean b5 = controller.isNbrRecordsDisplayed;

		controller.updateNbrSelectedRecords();

		Integer i2 = controller.nbrFoundRecords;

		Integer i3 = controller.currentPage;

		Integer i4 = controller.totalPage;
	}*/
}
