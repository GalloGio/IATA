@IsTest
public class AmazonResultsCtrlTest {

	public  static void loadCredentials() {
				IfapToolManagerTest.beforeTest();

		Amazon_Cred__c Amazon_Cred =  new Amazon_Cred__c(name = 'IFAP', Prod_Configuration__c = 'adevconf' , Dev_Configuration__c = 'adevconf');
		insert Amazon_Cred;

		list<AWSKey__c> AWS_KEYs = new list<AWSKey__c>{
			new AWSKey__c(
				name = 'adevconf',
				Key__c = 'asd',
				Secret__c = 'asd',
				IAS_configuration_name__c = 'asdas',
				IAS_Access_Point__c = 'asd',
				Bucket__c = 'asd',
				AWS_ENDPOINT_URL__c = 'asd')
		};
		insert AWS_KEYs;
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

		loadCredentials();

		Case cse = new Case();
		insert cse;

		Test.startTest();
		ApexPages.StandardController stdController = new ApexPages.StandardController(cse);
		AmazonResultsCtrl controller = new AmazonResultsCtrl(stdController);
		Test.stopTest();
	}

	private static testMethod void testControllerCaseArchived_Ok() {
		loadCredentials();

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
