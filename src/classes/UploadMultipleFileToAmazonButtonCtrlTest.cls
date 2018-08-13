@isTest
public class UploadMultipleFileToAmazonButtonCtrlTest {


	@testSetup
	public static void loadTestCredentials() {
		WrapperAttachTest.loadTestCredentials();
	}

	static testMethod void testController() {
		Test.StartTest();
		UploadMultipleFileToAmazonButtonCtrl controller = new UploadMultipleFileToAmazonButtonCtrl();
		controller.parentId = null;
		controller.folder = '';
		Test.StopTest();
	}
	
	static testMethod void testCreateUploadFile() {
		
		Case cse = new Case();
		insert cse;
		String parentId = cse.Id;
		String filenameupload = 'testfileName.pdf';
		String contentType = 'application/pdf';
		String folder = '/folder/' + filenameupload;
		String credentialName = 'GenericAttach';
		
		UploadMultipleFileToAmazonButtonCtrl.UploadFile upf;
		
		Test.StartTest();
		// test error
		Long bigFilesize = UploadMultipleFileToAmazonButtonCtrl.MAX_FILE_SIZE + 1;
		upf = UploadMultipleFileToAmazonButtonCtrl.createUploadFile(parentId, filenameupload, contentType, bigFilesize, folder, credentialName);
		System.assert(!upf.isSuccess);
		// test success
		Long filesize = 100;
		upf = UploadMultipleFileToAmazonButtonCtrl.createUploadFile(parentId, filenameupload, contentType, filesize, folder, credentialName);
		System.assert(upf.isSuccess);
		
		Test.StopTest();
		
	}
	
	
	static testMethod void testCreateAmazonObject_Ok() {
		Case cse = new Case();
		insert cse;
		String parentId = cse.Id;
		Long filesize = 100;
		String amazonKey = 'path/testfileName.pdf';
		
		Test.StartTest();
		Boolean result = UploadMultipleFileToAmazonButtonCtrl.createAmazonFileObject(amazonKey, filesize, parentId, null, null, null);
		Test.StopTest();
		
		System.assert(result);
		list<AmazonFile__c> listAmazonFile = [Select Id from AmazonFile__c where Case__c = :cse.Id ];
		System.assert(listAmazonFile.size() == 1);
	}
	
	static testMethod void testCreateAmazonObject_Error() {
		String parentId = '';
		Long filesize = 100;
		String amazonKey = null;
		
		Test.StartTest();
		Boolean result = UploadMultipleFileToAmazonButtonCtrl.createAmazonFileObject(amazonKey, filesize, parentId, null, null, null);
		Test.StopTest();
		
		System.assert(!result);
	}

	static testMethod void testSendOwnerNotification() {
		Case cse = new Case();
		insert cse;
		Test.StartTest();
		String result = UploadMultipleFileToAmazonButtonCtrl.notifyOscarOwner(cse.Id, 'test');

		system.debug(result);
		Test.StopTest();
	}
	
}