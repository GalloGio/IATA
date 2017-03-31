@isTest
private class CountryProfileInlineAttachmentsCtrlTest {

	static Country_Profile__c cp;

	private static void init(){

		Test.startTest();
        cp = new Country_Profile__c();
        cp.Name = 'Test Country';
        insert cp;
        List<Attachment> aList = new List<Attachment>();
        Attachment a1 = new Attachment(ParentId=cp.Id,Name='test',
        								Body=Blob.valueof('some text'),
        								Description='0__###__Currency__###__Sample Description'
        								);
        Attachment a2 = new Attachment(ParentId=cp.Id,Name='test',
        								Body=Blob.valueof('some text'),
        								Description='0__###__Airlines Charges__###__test1'
        								);
        Attachment a3 = new Attachment(ParentId=cp.Id,Name='test',
        								Body=Blob.valueof('test2')
        								);
        aList.add(a1);
        aList.add(a2);
        aList.add(a3);
        insert aList;
        Test.stopTest();

	}
	
	@isTest static void checkAttachments() {
		PageReference pageRef = Page.CountryProfileInlineAttachments;
        Test.setCurrentPage(pageRef);

        init();

        ApexPages.StandardController con = new ApexPages.StandardController(cp);
        CountryProfileInlineAttachmentsCtrl extension = new CountryProfileInlineAttachmentsCtrl(con);

        List<SelectOption> temp = extension.getSections();

        //we should have 3 attachments from init method
        system.assertEquals(3,extension.attWrapperList.size());
	}

	@isTest static void checkUploadAttachment() {
		PageReference pageRef = Page.CountryProfileInlineAttachments;
        Test.setCurrentPage(pageRef);

        init();

        ApexPages.StandardController con = new ApexPages.StandardController(cp);
        CountryProfileInlineAttachmentsCtrl extension = new CountryProfileInlineAttachmentsCtrl(con);

        extension.showUpload();

        extension.file = Blob.valueOf('some text for file content');
        extension.fileName = 'dummyAtt';
        extension.fileDescription = 'testDesc';
        extension.fileSection = 'Currency';
        extension.uploadFile();

        //we should have 4 attachments
        List<Attachment> newAttList = [SELECT Id from Attachment where ParentId =: cp.Id];
        system.assertEquals(4,newAttList.size());

        //check with null file
        con = new ApexPages.StandardController(cp);
        extension = new CountryProfileInlineAttachmentsCtrl(con);

        extension.showUpload();
        extension.file = null;
        extension.uploadFile();
	}

	@isTest static void testEnableDisableAtt() {
		PageReference pageRef = Page.CountryProfileInlineAttachments;
        Test.setCurrentPage(pageRef);
        init();
        ApexPages.StandardController con = new ApexPages.StandardController(cp);
        CountryProfileInlineAttachmentsCtrl extension = new CountryProfileInlineAttachmentsCtrl(con);

        extension.toggleAttId = extension.attList[0].Id;
        Test.setCurrentPage(extension.enableAtt());
        con = new ApexPages.StandardController(cp);
        extension = new CountryProfileInlineAttachmentsCtrl(con);
        system.assertEquals(true,extension.attWrapperList[0].visible);

        extension.toggleAttId = extension.attList[0].Id;
        Test.setCurrentPage(extension.disableAtt());
        con = new ApexPages.StandardController(cp);
        extension = new CountryProfileInlineAttachmentsCtrl(con);
        system.assertEquals(false,extension.attWrapperList[0].visible);
	}
	
}