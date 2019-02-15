/**
 * Created by PC-RITS04 on 11/20/2018.
 */
@isTest
public class UploadFileToAmazonButtonCtrlTest {

	@testSetup
	public static void loadTestCredentials() {
		WrapperAttachTest.loadTestCredentials();
	}

	@isTest
	static void testCreateUploadFile() {

		Case cse = new Case();
		insert cse;
		String parentId = cse.Id;
		String filenameupload = 'testfileName.pdf';
		String contentType = 'application/pdf';
		String folder = '/folder/' + filenameupload;
		String credentialName = 'GenericAttach';

		UploadFileToAmazonButtonCtrl.WrapperCredential upf;

		Test.StartTest();
		// test error
		Long bigFilesize = UploadFileToAmazonButtonCtrl.MAX_FILE_SIZE + 1;
		upf= UploadFileToAmazonButtonCtrl.createUploadFile(parentId, filenameupload, contentType, bigFilesize, credentialName);
		System.assert(!upf.isSuccess);
		// test success

		Long filesize = 100;
		upf= UploadFileToAmazonButtonCtrl.createUploadFile(parentId, filenameupload, contentType, filesize, credentialName);
		System.assert(upf.isSuccess);


		filenameupload = 'testfileNametestfileNametestfileNametestfileNametestfileNametestfileNametestfileNametestfileNametestfileName.pdf';
		upf= UploadFileToAmazonButtonCtrl.createUploadFile(parentId, filenameupload, contentType, filesize, credentialName);
		System.assert(!upf.isSuccess);

		filenameupload = 'test&otherStuff.pdf';
		upf= UploadFileToAmazonButtonCtrl.createUploadFile(parentId, filenameupload, contentType, filesize, credentialName);
		System.assert(!upf.isSuccess);

		Test.StopTest();
	}

	static testMethod void testCreateAmazonObject_Ok() {
		Case cse = new Case();
		insert cse;
		String parentId = cse.Id;
		Long filesize = 100;
		String amazonKey = 'path/testfileName.pdf';
		String fileName='ICE POP';
		Id RTId = RecordTypeSingleton.getInstance().getRecordTypeId('AmazonFile__c','File');

		AmazonFile__c azFile = new AmazonFile__c(
				Name='ICE POP',
				RecordTypeId = RTId,
				Category__c = 'ICE POP',
				File_Identifier_picklist__c = 'ICE_POP',
				Case__c =parentId,
				Full_Name_Unique__c = '001/'+parentId+'/ICE POP'
		);

		Account acc = new Account(Name='testAcount');
		insert acc;

		Test.StartTest();
		String result = UploadFileToAmazonButtonCtrl.createAmazonFileObject(amazonKey, filesize, parentId, azFile);
		System.assert(result.length()>10);

		list<AmazonFile__c> listAmazonFile = [Select Id from AmazonFile__c where Id = :result ];
		System.assert(listAmazonFile.size() == 1);

		parentId = acc.Id;
		azFile.Name='ICE POP Account';
		azFile.Full_Name_Unique__c = '005/'+parentId+'/ICE POP Account';
		amazonKey = 'path/testAccountfileName.pdf';
		result = UploadFileToAmazonButtonCtrl.createAmazonFileObject(amazonKey, filesize, parentId, azFile);
		System.assert(result.length()>10);
		Test.StopTest();

	}



}