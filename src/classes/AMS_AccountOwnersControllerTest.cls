@isTest
private class AMS_AccountOwnersControllerTest {

	static testMethod void test1() {
		Account acc = new Account(Name= 'Test');
		insert acc;

		Test.startTest();
		ApexPages.StandardController stdController = new ApexPages.StandardController(acc);
		AMS_AccountOwnersController accOwnersController = new AMS_AccountOwnersController(stdController);

		PageReference pageRef = Page.AMS_AccountOwners;
		pageRef.getParameters().put('id', acc.Id);
		Test.setCurrentPage(pageRef);

		List<AMS_Account_Role__c> owners = accOwnersController.owners;
		Test.stopTest();
	}
		
}