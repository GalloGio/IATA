@isTest
private class EF_AttachmentListControllerTest {

	@testSetup
	public static void setupTest() {

		//     Case cse = new Case();
		//     insert cse;
		//
		//     Attachment att = new Attachment(
		//         ParentId = cse.Id,
		//         Name = 'testname',
		//         Body = Blob.ValueOf('')
		//         ParentId = cse.id;
		//     );
		//     insert att;
		//Create public group

		Group efPrivateGroup = null;
		List<Group> efPrivateGroups = [select Name, DeveloperName from Group where DeveloperName = 'EF_Private_Document_Access' limit 1];
		if(efPrivateGroups.size() == 0)
		{
			efPrivateGroup = new Group();
			efPrivateGroup.Name='EF Private Document Access';
			efPrivateGroup.DeveloperName='EF_Private_Document_Access';
			insert efPrivateGroup;
		} else
		{
			 efPrivateGroup = efPrivateGroups.get(0);
		}

		GroupMember efGM = new GroupMember();
		efGM.UserOrGroupId = UserInfo.getUserId();
		efGM.GroupId= efPrivateGroup.Id;
		//insert efGM;

		TestDataFactory_AWSKeys.createAllEntries();

		EF_Amazonfile_Private__c ap = new EF_Amazonfile_Private__c();
		ap.Name = 'Case';
		ap.SObject_3_first_chars__c = '500';
		ap.EF_Private__c = false;
		insert ap;
	}

	static testMethod void testEF_AttachmentListController() {

		Case cse = new Case();
		insert cse;
		insert new Apex_Setting__c(Name='RT valid to reopen attachment trigger', Text_1__c='CasesEurope,Cases_Global,CasesAmericas,CasesMENA,ExternalCasesIDFSglobal,Cases_China_North_Asia, ComplaintIDFS,'
                                           +  'Inter_DPCs,Invoicing_Collection_Cases,Cases_SIS_Help_Desk,InternalCasesEuropeSCE,CS_Process_IDFS_ISS,ID_Card_Application');

		Attachment att = new Attachment(
			ParentId = cse.Id,
			Name = 'testname',
			Body = Blob.ValueOf('')
		);
		insert att;

		EF_AttachmentListController controller = new EF_AttachmentListController();

		controller.id = cse.Id;

		System.assert(controller.isAdminUser);

		PageReference pgNull = controller.refreshList();

		System.assert(controller.listAttachments.size() > 0);

		String s = controller.sapNumberRequiredJSON;
		s = controller.expiryDateRequiredJSON;
		s = controller.expiredRequiredJSON;

		// s = controller.MAX_FILE_SIZE;
		s = controller.amazonURL;
		s = controller.credentialName;
		s = controller.amazonPath;
		s = controller.expiredRequiredJSON;
		s = controller.getTransferAttachmentsUrl();
		s = controller.uploader;
		s = controller.source;
		Boolean b = controller.scroll;
		// 0018E00000Gfake

		PageReference p = controller.refreshList();
		p = controller.cancelPopupAttach();
		p = controller.updateAttach();
		p = controller.goToAttachmentPage();
		p = controller.cancelPopupAttach();

		controller.callEditAttachment();

		AmazonFile__c af = controller.amazonFileToUpload;

		String credentialName = controller.credentialName;
		EF_AttachmentListController.UploadFile u = EF_AttachmentListController.createUploadFile('0018E00000Gfake', 'filenameupload',  'contentType', 1000000, '001', credentialName);

		boolean c = EF_AttachmentListController.createAmazonFileObject('String amazonKey', 10000000, 'String parentId', 'String recordType',
														'String efCategory', 'String efSubCategory', 'String efExpiryDate', false, 'String efSapNumber',
														'String additionalInformation', false);
	}

	static testMethod void testRemoteActions() {

		Case cse = new Case();
		insert cse;
		insert new Apex_Setting__c(Name='RT valid to reopen attachment trigger', Text_1__c='CasesEurope,Cases_Global,CasesAmericas,CasesMENA,ExternalCasesIDFSglobal,Cases_China_North_Asia, ComplaintIDFS,'
                                           +  'Inter_DPCs,Invoicing_Collection_Cases,Cases_SIS_Help_Desk,InternalCasesEuropeSCE,CS_Process_IDFS_ISS,ID_Card_Application');
		Attachment att = new Attachment(
			ParentId = cse.Id,
			Name = 'testNameSFA',
			Body = Blob.ValueOf('')
		);
		insert att;

		Archived_Message__c mess = new Archived_Message__c();
		mess.Case__c = cse.Id;
		mess.EmailMessage__c = '1234';
		insert mess;

		Archived_Attachment__c arch = new Archived_Attachment__c();
		arch.ArchivedMessage__c = mess.Id;
		arch.Case__c = cse.Id;
		arch.Bucket__c = 'testNameAA';
		arch.AWS_S3_URL__c = 'testurl';
		insert arch;

		AmazonFile__c aFile = new AmazonFile__c(
			Full_Name_Unique__c = 'testnameAMZ',
			Case__c = cse.Id
		);
		insert aFile;

		System.assert(EF_AttachmentListController.getExpiringLink('testName') != null);

		EF_AttachmentListController.deleteAttachment(String.valueOf(att.Id), null);
		EF_AttachmentListController.deleteAttachment(String.valueOf(arch.Id), null);
		EF_AttachmentListController.deleteAttachment(String.valueOf(aFile.Id), 'asd');
	}

}
