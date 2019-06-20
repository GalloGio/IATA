@isTest
private  class AttachmentListCtrlTest {
    @testSetup
	public static void loadTestCredentials() {
		WrapperAttachTest.loadTestCredentials();
        

        insert new list <AWSKey__c>{
            new AWSKey__c(
				name = 'sandbox',
				Key__c = 'asd',
				Secret__c = 'asd',
				IAS_configuration_name__c = 'asdas',
				IAS_Access_Point__c = 'asd',
				Bucket__c = 'asd',
				AWS_ENDPOINT_URL__c = 'asd'
			),
            new AWSKey__c(
				name = 'production',
				Key__c = 'asd',
				Secret__c = 'asd',
				IAS_configuration_name__c = 'asdas',
				IAS_Access_Point__c = 'asd',
				Bucket__c = 'asd',
				AWS_ENDPOINT_URL__c = 'asd'
			)};

        
	}

	static testMethod void testGetters() {

       List<AttachmentListCtrl.PickListWrapper> identifierList=  AttachmentListCtrl.getFileIdentifierPickValues();
       List<AttachmentListCtrl.PickListWrapper> reviewStatusList=  AttachmentListCtrl.getReviewStatusPickValues();

 
    }
    static testMethod void testChangeAttachmentVisibility() {
         Case cse = new Case();
        insert cse;

        Attachment att = new Attachment(
            ParentId = cse.Id,
            Name = 'testname',
            Body = Blob.ValueOf('')
        );
        insert att;

        AttachmentListCtrl.PropertiesWrapper pw= AttachmentListCtrl.getPanelProperties(cse.id, false, '');

        List<WrapperAttach>wrlist= AttachmentListCtrl.getAllAttachmentsByParentIdAndPortal(cse.id, false,false);
        
        wrapperAttach wa= wrlist.get(0);
        AttachmentListCtrl.ReturnWrapper rw=AttachmentListCtrl.changeAttachVisibility(cse.id, wa.id, false, false);
        system.assertEquals(rw.severity,'SUCCESS');
        wrlist= AttachmentListCtrl.getAllAttachmentsByParentIdAndPortal(cse.id, false,false);
        system.assertEquals(wrlist.get(0).permission.ShowToPortalUsers__c,true);

    }
    static testMethod void testUpdateAttachment() {
        Case cse = new Case();
        insert cse;

        AmazonFile__c aFile = new AmazonFile__c(
            Full_Name_Unique__c = 'testnameAMZ',
            Case__c = cse.Id
        );
        insert aFile;

        AttachmentListCtrl.PropertiesWrapper pw= AttachmentListCtrl.getPanelProperties(cse.id, false, '');

        List<WrapperAttach>wrlist= AttachmentListCtrl.getAllAttachmentsByParentIdAndPortal(cse.id, false,false);
        
        wrapperAttach wa= wrlist.get(0);
        
        AttachmentListCtrl.ReturnWrapper rw=AttachmentListCtrl.updateAttachment(cse.id, wa.id, false,'New Description', null, null, false);
    
        String pr= AttachmentListCtrl.getTransferAttachmentsUrl(cse.id);
    }

    static testMethod void testCtrlVisibilityAllRecords() {
        Case cse = new Case();
        insert cse;

        list<Attachment> attList = new list<Attachment>{
             new Attachment(
                ParentId = cse.Id,
                Name = 'testname',
                Body = Blob.ValueOf('')
            ),
            new Attachment(
                ParentId = cse.Id,
                Name = 'testname2',
                Body = Blob.ValueOf('')
            )};
        insert attList;

            

        AttachmentListCtrl.PropertiesWrapper pw= AttachmentListCtrl.getPanelProperties(cse.id, false, '');

      
        AttachmentListCtrl.ReturnWrapper rw=AttachmentListCtrl.makeAllAttachPublic(cse.id, false, false);

        integer c=0;
        for(wrapperAttach wa: AttachmentListCtrl.getAllAttachmentsByParentIdAndPortal(cse.id, false,false)){
            if(wa.permission.ShowToPortalUsers__c)c++;
        }
        system.assertEquals(c,2);

        rw=AttachmentListCtrl.makeAllAttachPrivate(cse.id, false, false);    
    }
    static testMethod void testDeleteAttachments() {
        Case cse = new Case();
        insert cse;

       
        Attachment att= new Attachment(
            ParentId = cse.Id,
            Name = 'testname',
            Body = Blob.ValueOf('')
        );
        insert att;

        AmazonFile__c aFile = AmazonFileTest.createAmazonAttachment();

        Archived_Attachment__c arch = new Archived_Attachment__c();
        arch.Case__c = cse.Id;
        arch.Bucket__c = 'testNameAA';
        arch.AWS_S3_URL__c = 'testurl';
        insert arch;

         

        AttachmentListCtrl.PropertiesWrapper pw= AttachmentListCtrl.getPanelProperties(cse.id, false, '');
        AttachmentListCtrl.ReturnWrapper rw= AttachmentListCtrl.deleteAttachment(att.id, att.name);
        system.assertEquals(rw.severity,'SUCCESS');

        AttachmentListCtrl.ReturnWrapper rw2= AttachmentListCtrl.deleteAttachment(aFile.id, aFile.Full_Name_Unique__c);
        AttachmentListCtrl.ReturnWrapper rw3= AttachmentListCtrl.deleteAttachment(arch.id,'');
    }
    static testMethod void testAmazonFileExpirylink() {
        AmazonFile__c aFile = AmazonFileTest.createAmazonAttachment();

        String link=AttachmentListCtrl.getExpiringLink(aFile.Full_Name_Unique__c);
        String link2=AttachmentListCtrl.getExpiringLinkWithRecId(aFile.id);

        //get all expiringLinks
        list<AttachmentListCtrl.FileDef> filelist=AttachmentListCtrl.getAllExpiringLink(aFile.case__c,false);
        system.assertEquals(filelist.size()>0,true);
    }

     static testMethod void testUploadFile() {
        Case cse = new Case();
        insert cse;
        
        
        //filename too big
        string filename='7Ss2YCdGrhtP5SO3688fnGsLjhDeoZmpOWzSY8k5GMccAZIoDDjPoP8bYntk9KTNu8G5Oydfs1KRqShek';
        AttachmentListCtrl.UploadFile file2=AttachmentListCtrl.createUploadFile(cse.id,filename, 'asd',219, '', 'GenericAttach');
        system.assertEquals(file2.isSuccess,false);
        system.assertEquals(file2.errorMessage,Label.File_name_too_long);

       AttachmentListCtrl.UploadFile file3=AttachmentListCtrl.createUploadFile(cse.id,'testname', 'asd',219, '', 'GenericAttach');
        system.assertEquals(file3.isSuccess,true);



        boolean fileAmazon=AttachmentListCtrl.createAmazonFileObject('aaaakkk', 12, cse.id, 'File', '', '');
        system.assertEquals(fileAmazon,true);

     }

     static testMethod void testTransferAttachments() {
         case cparent= new case();

         insert cparent;

         case sb1 =new case(parentId=cparent.id);
         case sb2 =new case(parentId=cparent.id);

         insert new list<case>{sb1,sb2};

         case childcase = new case(parentId=sb1.id);
         insert childcase;

         Attachment att= new Attachment(
            ParentId = sb1.Id,
            Name = 'testname',
            Body = Blob.ValueOf('')
        );
        insert att;

        AmazonFile__c aFile = new AmazonFile__c(
			Full_Name_Unique__c = 'testname',
			Case__c = sb1.Id
		);
		insert aFile;

        Test.startTest();

            list<AttachmentListCtrl.CaseWrapper> caseList= AttachmentListCtrl.getParentCaseRelatedCases(sb1.id,cparent.id);
            system.assertEquals(caseList.size(),3);

            string targetAtt= System.JSON.serialize(new set<string>{att.id,aFile.id});

            string targetCaseStr= System.JSON.serialize(new set<string>{cparent.id,sb2.id});
            AttachmentListCtrl.transferAttachments(targetAtt,null,targetCaseStr,sb1.id,false,false,cparent.id);

        Test.stopTest();

     }

     static testMethod void testCreateAttachmentRecord() {
        Case cse = new Case();
        insert cse;

        ApexMessageHandling attMsg=AttachmentListCtrl.createAttachment(cse.id, 'asdasd', 'File1',12, 'text');
     }
}