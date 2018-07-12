@isTest
public class GenericAttachmentListControllerTest {

	@testSetup
	public static void loadTestCredentials() {
		WrapperAttachTest.loadTestCredentials();
	}

	static testMethod void testController() {
		Case cse = new Case();
		insert cse;
		
		Test.startTest();
		GenericAttachmentListController controller = new GenericAttachmentListController();
		controller.isForPortal = false;
		controller.id = cse.Id;
		
		System.assert(controller.amazonURL!=null);
		System.assert(controller.credentialName!=null);
		System.assert(controller.amazonPath!=null);
		System.assert(controller.editAttachmentId==null);
		System.assert(controller.isAdminUser);
		System.assert(controller.getTransferAttachmentsUrl() != null);
		controller.cancelPopupAttach();
		controller.getCanAttachFilesToCase();
		controller.goToAttachmentPage();
		Test.stopTest();
		
	}
	
	static testMethod void testGetExpiringLink() {
		Test.startTest();
		GenericAttachmentListController.getExpiringLink('testname');
		Test.stopTest();
	}
	
	static testMethod void testDeleteAttachment() {

		Case cse = new Case();
		insert cse;
		
		Attachment att = new Attachment(
			ParentId = cse.Id,
			Name = 'testname',
			Body = Blob.ValueOf('')
		);
		insert att;
		
		Test.startTest();
		Boolean resulterror = GenericAttachmentListController.deleteAttachment(cse.Id,null);
		System.assert(!resultError);
		Boolean resultTrue = GenericAttachmentListController.deleteAttachment(att.Id,'testname');
		System.assert(resultTrue);
		Test.stopTest();
		
		list<Attachment> listAttach = [Select Id from Attachment where id = :att.id];
		System.assert(listAttach.isEmpty());
	}
	
	static testMethod void testDeleteArchivedAttachment() {
		Case cse = new Case();
		insert cse;
		
		Archived_Attachment__c att = new Archived_Attachment__c(
			Case__c = cse.Id,
			Bucket__c = 'bucket',
			Name = 'testname'
		);
		insert att;
		
		Test.startTest();
		Boolean resultOk = GenericAttachmentListController.deleteAttachment(att.Id,null);
		System.assert(!resultOk);
		Boolean resultError = GenericAttachmentListController.deleteAttachment(att.Id,null);
		System.assert(!resultError);
		Test.stopTest();
	}
	
	static testMethod void testDeleteAmazonAttachment() {
		Case cse = new Case();
		insert cse;
		AmazonFile amazonFile = WrapperAttachTest.createAmazonFile(cse);
		
		Test.startTest();
		Boolean resulterror = GenericAttachmentListController.deleteAttachment(amazonFile.getId(),null);
		System.assert(!resultError);
		AmazonRest.TESTSTRING = 'OK';
		Boolean resultTrue = GenericAttachmentListController.deleteAttachment(amazonFile.getId(),amazonFile.getFullName());
		Test.stopTest();
	}
	
	static testMethod void testRefreshList() {
		Case cse = new Case();
		insert cse;
		
		WrapperAttachTest.createAttachment(cse);
		WrapperAttachTest.createAmazonFile(cse);
		
		GenericAttachmentListController controller = new GenericAttachmentListController();
		controller.isForPortal = true;
		controller.id = cse.Id;
		
		Test.startTest();
		controller.refreshList();
		
		controller.makeAllPublic();
		controller.makeAllPrivate();
		
		Test.stopTest();
	}
	
	static testMethod void testEditAttachment() {
		Case cse = new Case();
		insert cse;
		
		Attachment attachment = WrapperAttachTest.createAttachment(cse);
		
		GenericAttachmentListController controller = new GenericAttachmentListController();
		controller.isForPortal = false;
		controller.id = cse.Id;
		WrapperAttach att = new WrapperAttach(attachment, null);
		
		Test.startTest();
		controller.callEditAttachment();
		controller.editAttachment = att;
		att.description = 'test description';
		controller.updateAttach();
		controller.cancelPopupAttach();
		Test.stopTest();
	}

	static testMethod void testGetAllExpiringLink1() {
		Case cse = new Case();
		insert cse;

		Attachment attachment = WrapperAttachTest.createAttachment(cse);

		GenericAttachmentListController controller = new GenericAttachmentListController();
		controller.isForPortal = false;
		controller.id = cse.Id;
		WrapperAttach att = new WrapperAttach(attachment, null);

		Test.startTest();
		GenericAttachmentListController.getAllExpiringLink(cse.Id);
		Test.stopTest();
	}

	static testMethod void testGetAllExpiringLink2() {
		Case cse = new Case();
		insert cse;

		Attachment attachment = WrapperAttachTest.createAttachment(cse);

		GenericAttachmentListController controller = new GenericAttachmentListController();
		controller.isForPortal = true;
		controller.id = cse.Id;
		WrapperAttach att = new WrapperAttach(attachment, null);

		Test.startTest();
		GenericAttachmentListController.getAllExpiringLink(cse.Id);
		Test.stopTest();
	}

	static testMethod void testIsOscarParent() {
		ID rtOSCAR = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

		Case parentCase = new Case();
		parentCase.recordTypeId = rtOSCAR;
		insert parentCase;

		Case cse = new Case();
		cse.ParentId = parentCase.Id;
		insert cse;
		
		GenericAttachmentListController controller = new GenericAttachmentListController();
		controller.isForPortal = false;
		controller.id = cse.Id;
		controller.relatedCase.recordTypeId = rtOSCAR;
		
		Test.startTest();
		controller.getParentIsOscar();
		Test.stopTest();
	}

	static testMethod void testIsOscarParent2() {
		ID rtOSCAR = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'CasesEurope');

		Case parentCase = new Case();
		parentCase.recordTypeId = rtOSCAR;
		insert parentCase;

		Case cse = new Case();
		cse.ParentId = parentCase.Id;
		insert cse;

		GenericAttachmentListController controller2 = new GenericAttachmentListController();
		controller2.isForPortal = false;
		controller2.id = cse.Id;
		controller2.relatedCase.recordTypeId = rtOSCAR;
		
		Test.startTest();
		controller2.getParentIsOscar();
		Test.stopTest();
	}

	static testMethod void testGetCanAttachFilesToCase() {
		ID rtOSCAR = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'CasesEurope');

		Case parentCase = new Case();
		parentCase.recordTypeId = rtOSCAR;
		insert parentCase;

		Case cse = new Case();
		cse.ParentId = parentCase.Id;
		cse.Status = 'Draft';
		cse.Reason1__c = 'CLO - Closure';
		insert cse;

		GenericAttachmentListController controller = new GenericAttachmentListController();
		controller.isForPortal = false;
		controller.id = cse.Id;
		controller.relatedCase.recordTypeId = rtOSCAR;
		
		Test.startTest();
		controller.getCanAttachFilesToCase();
		Test.stopTest();
	}

	static testMethod void testGetCanAttachFilesToCase2() {
		ID rtOSCAR = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'CasesEurope');

		Case parentCase = new Case();
		parentCase.recordTypeId = rtOSCAR;
		insert parentCase;

		Case cse = new Case();
		cse.ParentId = parentCase.Id;
		cse.Status = 'Draft';
		insert cse;

		GenericAttachmentListController controller = new GenericAttachmentListController();
		controller.isForPortal = false;
		controller.id = cse.Id;
		controller.relatedCase.recordTypeId = rtOSCAR;
		
		Test.startTest();
		controller.getCanAttachFilesToCase();
		Test.stopTest();
	}

	static testMethod void testgoToAttachmentPage() {
		ID rtOSCAR = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'CasesEurope');

		Case parentCase = new Case();
		parentCase.recordTypeId = rtOSCAR;
		insert parentCase;

		Case cse = new Case();
		cse.ParentId = parentCase.Id;
		cse.Status = 'In Progress';
		cse.Reason1__c = 'CLO - Closure';
		insert cse;

		GenericAttachmentListController controller = new GenericAttachmentListController();
		controller.isForPortal = false;
		controller.id = cse.Id;
		controller.relatedCase.recordTypeId = rtOSCAR;
		
		Test.startTest();
		controller.goToAttachmentPage();
		Test.stopTest();
	}


}