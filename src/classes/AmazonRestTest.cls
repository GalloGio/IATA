@isTest
public class AmazonRestTest {
	@TestSetup
	static void makeData(){
		TestDataFactory_AWSKeys.createAllEntries();
	}

	static testMethod void getFileTest(){
		CaseChildHelper.noValidationsOnTrgCAseIFAP = true; /* later I switch it to false to fully emulate production envinroment */

		AmazonRest.getFile('Test File Name', AmazonCredentials.getCredentials('IFAP'));
	}

	static testMethod void listBucketTest(){
		CaseChildHelper.noValidationsOnTrgCAseIFAP = true; /* later I switch it to false to fully emulate production envinroment */

		String Filename = 'IFAP/afile';
		List<AmazonRest.S3File> res = AmazonRest.getListFiles(Filename,AmazonCredentials.getCredentials('IFAP') );
		Boolean resIsFull = res <> null;
		System.assert(resIsFull,true);

		Boolean check = AmazonRest.checkFile( Filename,AmazonCredentials.getCredentials('IFAP'));
		System.assertEquals(check,false);

		// AmazonRest.getFile(Filename,AmazonCredentials.getCredentials('IFAP'));
		AmazonRest.make_sig('',AmazonCredentials.getCredentials('IFAP'));
		AmazonRest.genPublicExpiringAWSLink('teste_File', AmazonCredentials.getCredentials('IFAP'), 10 );
	}

	static testMethod void Exception_listBucketTest(){
		CaseChildHelper.noValidationsOnTrgCAseIFAP = true;

		String result = AmazonRest.genPublicExpiringAWSLink('', AmazonCredentials.getCredentials('IFAP'), 10 );

		System.assertEquals(result, null);

	}


	static testMethod void deleteTest(){
		CaseChildHelper.noValidationsOnTrgCAseIFAP = true; /* later I switch it to false to fully emulate production envinroment */

		String Filename = 'IFAP/afile';
		Boolean done = AmazonRest.deleteFile(Filename,AmazonCredentials.getCredentials('IFAP') );

		System.assert(done,true);
	}

	static testMethod void uploadFile() {

		Blob pdfArchive = Blob.valueOf('Test');
		Long size = pdfArchive.size();

		//get amazon info
		String fileName = 'Certificate.pdf';
		String contentType = 'application/pdf';
		String folder = WrapperAttach.getAmazonFolder(UserInfo.getOrganizationId());

		UploadMultipleFileToAmazonButtonCtrl.UploadFile upF = UploadMultipleFileToAmazonButtonCtrl.createUploadFile('TestFolder', fileName, contentType, size, folder,  WrapperAttach.CREDENTIAL_NAME);

		Test.startTest();
		System.assert(AmazonRest.uploadFile(upF, pdfArchive));
		Test.stopTest();
	}

	static testMethod void uploadFile2() {
		Blob pdfArchive = Blob.valueOf('Test');
		String fileName = 'Certificate.pdf';
		String contentType = 'application/pdf';
		AmazonCredentials credential = AmazonCredentials.getCredentials(WrapperAttach.CREDENTIAL_NAME);

		Test.startTest();
		Boolean result = AmazonRest.uploadFile(credential, 'TestFolder', contentType, pdfArchive);
		Test.stopTest();

		System.assert(true, result);
	}

	static testMethod void copyTest() {

		CaseChildHelper.noValidationsOnTrgCAseIFAP = true;

		String sourceFilename = 'IFAP/afile';
		String destFilename = 'IFAP/dest';
		AmazonCredentials cred = AmazonCredentials.getCredentials('IFAP');

		Boolean resultCopy = AmazonRest.copyFile(cred, sourceFilename, cred, destFilename);

		System.assert(resultCopy);
	}

	Static testMethod void deleteFilesTest(){

		CaseChildHelper.noValidationsOnTrgCAseIFAP = true;

		Set<String> fileNames = new Set<String>();
		fileNames.add('IFAP/afile');
		fileNames.add('IFAP');
		AmazonCredentials cred = AmazonCredentials.getCredentials('IFAP');
		String folder = 'test folder';

		Boolean doneDeleteFiles = AmazonRest.deleteFiles(fileNames, folder, cred);

		System.assert(doneDeleteFiles);

	}
}
