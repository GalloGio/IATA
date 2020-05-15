/**
 * Created by ReDesign
 */
@isTest
public class ISSP_DragAndDropTest {


	@testSetup
	public static void loadTestCredentials() {

		insert new UtilityCS__c(name='ifapBatchSize', Value__c = '5');

		Amazon_Cred__c Amazon_Cred =  new Amazon_Cred__c(
				name = IfapToolManager.IFAPCONFIGARATIONNAME,
				Prod_Configuration__c = IfapToolManager.IFAPCONFIGARATIONNAME,
				Dev_Configuration__c = IfapToolManager.IFAPCONFIGARATIONNAME
		);
		insert Amazon_Cred;

		AWSKey__c credential = new AWSKey__c(
				name = IfapToolManager.IFAPCONFIGARATIONNAME,
				Key__c = 'asd',
				Secret__c = 'asd',
				IAS_configuration_name__c = 'asdas',
				IAS_Access_Point__c = 'asd',
				Bucket__c = 'asd',
				AWS_ENDPOINT_URL__c = 'asd'
		);
		insert credential;


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

		ISSP_DragAndDrop.WrapperCredential upf;

		Test.StartTest();
		// test error
		Long bigFilesize = ISSP_DragAndDrop.MAX_FILE_SIZE + 1;
		upf= ISSP_DragAndDrop.createUploadFile(parentId, filenameupload, contentType, bigFilesize);
		System.assert(!upf.isSuccess);
		// test success

		Long filesize = 100;
		upf= ISSP_DragAndDrop.createUploadFile(parentId, filenameupload, contentType, filesize);
		System.assert(upf.isSuccess);


		filenameupload = 'testfileNametestfileNametestfileNametestfileNametestfileNametestfileNametestfileNametestfileNametestfileName.pdf';
		upf= ISSP_DragAndDrop.createUploadFile(parentId, filenameupload, contentType, filesize);
		System.assert(!upf.isSuccess);

		filenameupload = 'test&otherStuff.pdf';
		upf= ISSP_DragAndDrop.createUploadFile(parentId, filenameupload, contentType, filesize);
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
		RecordTypeInfo rtInfo = Schema.SObjectType.AmazonFile__c.getRecordTypeInfosByName().get('File');
		Id RTId = rtInfo.getRecordTypeId();

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
		String result = ISSP_DragAndDrop.createAmazonFileObject(amazonKey, filesize, parentId, azFile);
		System.assert(result.length()>10);

		list<AmazonFile__c> listAmazonFile = [Select Id from AmazonFile__c where Id = :result ];
		//System.assert(listAmazonFile.size() == 1);

		parentId = acc.Id;
		azFile.Name='ICE POP Account';
		azFile.Full_Name_Unique__c = '005/'+parentId+'/ICE POP Account';
		amazonKey = 'path/testAccountfileName.pdf';
		result = ISSP_DragAndDrop.createAmazonFileObject(amazonKey, filesize, parentId, azFile);
		System.assert(result.length()>10);

		boolean deletresult = ISSP_DragAndDrop.deleteFile(acc.Id , azFile.Name);

		Test.StopTest();

	}

	static testMethod void testWrapperClass() {

		Account acc = new Account(Name='testAcount');
		insert acc;

		AmazonFile__c afile = new AmazonFile__c(
			Account__c = acc.Id,
			Name = 'ICE',
			Full_Name_Unique__c = '/001/ICE-312321',
			Size_MB__c = 1
		);
		insert afile;

		ISSP_DragAndDrop aux = new ISSP_DragAndDrop();
		aux.parentId = acc.Id;
		aux.amazonFName = 'ICE';

		Test.startTest();
		List<ISSP_DragAndDrop.WrapperAmazonFile> listWrapper = aux.amazFileList;
		Test.stopTest();

		System.assert(aux.amazFileList.size()>0);
	}

	/*
	static testMethod void testCreateAmazonObject_ComponentTst() {

		Account acc = new Account(Name='testAcount');
		insert acc;

		ISSP_DragAndDrop aux = new ISSP_DragAndDrop();
		aux.parentId = acc.Id;
		aux.amazonFName = 'ICE POP';
		String actualD = aux.actualDate;
		String actualU = aux.actualUser;

		List<ISSP_DragAndDrop.WrapperAmazonFile> amazFileListAux = aux.amazFileList;

	}
	*/

}