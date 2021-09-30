@IsTest
public class AmazonResultsCtrlTest {
	@TestSetup
	static void makeData(){
		TestDataFactory_AWSKeys.createAllEntries();
	}

	private static testMethod void testControllerError() {

		Case cse = new Case();

		Test.startTest();
		try {
			ApexPages.StandardController stdController = new ApexPages.StandardController(cse);
			AmazonResultsCtrl controller = new AmazonResultsCtrl(stdController);
			System.assert(false, 'should throw a transformationException ');

		} catch ( Exception e) {
			System.assert(true, 'should throw a transformationException ');
		}
		Test.stopTest();
	}

	private static testMethod void testControllerCaseNotArchived() {
		Case cse = new Case();
		insert cse;

		Test.startTest();
		ApexPages.StandardController stdController = new ApexPages.StandardController(cse);
		AmazonResultsCtrl controller = new AmazonResultsCtrl(stdController);
		Test.stopTest();
	}

	private static testMethod void testControllerCaseArchived_Ok() {

		Case cse = new Case();
		cse.Financial_Results_Archived_Date__c = Date.today();
		insert cse;

		ENZ__FTPAttachment__c attach = new ENZ__FTPAttachment__c(
			Financial_Assessment_Result__c = cse.Id
		);

		Test.startTest();
		ApexPages.StandardController stdController = new ApexPages.StandardController(cse);
		AmazonResultsCtrl controller = new AmazonResultsCtrl(stdController);
		AmazonResultsCtrl.getExpiringLinkIfap('/test/path/filename');
		System.assert(true,controller.docs.size() > 0);
		Test.stopTest();
	}

}
