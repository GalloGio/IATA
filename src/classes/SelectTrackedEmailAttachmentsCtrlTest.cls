@isTest
public class SelectTrackedEmailAttachmentsCtrlTest {

    static void loadData() {

        Contact contact = new Contact (
            FirstName = 'test contact',
            LastName = 'last name',
            email = 'test@email.com'
        );
        insert contact;

        Case cse = new Case(
            contactId = contact.Id
        );
        insert cse;

        Sender_Tracked_Emails__c ste = new Sender_Tracked_Emails__c(
            name = 'testname',
            email__c = 'frommail@mail.com',
            Token__c = 'token'
        );
        insert ste;
        
        Document doc = new Document(
            Name = 'Document 1',
            FolderId = UserInfo.getUserId(),
            Body = Blob.valueOf('Document 1 body')
        );
        
        insert doc;
    }


    static testMethod void testSelectionDeselection() {

        loadData();

        Case cse = [Select Id from Case limit 1];

        ApexPages.StandardController stdController = new ApexPages.StandardController( new Tracked_Email__c());
        PageReference pageref = Page.sendSingleTrackedEmail;
        pageref.getParameters().put('case',cse.Id);
        system.Test.setCurrentPage(pageRef);


        Test.startTest();
        
        sendSingleTrackedEmailController controller1 = new sendSingleTrackedEmailController(stdController);
        
        controller1.initPage();

        SelectTrackedEmailAttachmentsController controller2 = new SelectTrackedEmailAttachmentsController();
        
        controller2.parent = controller1;
        
        System.assertEquals(false, controller2.isPanelDisplayed);
        System.assertEquals(null, controller2.addedDocumentMap);
        System.assert(controller2.addedDocuments.isEmpty());
        
        controller2.displayPanel();
        
        controller2.documentFilter = '<sgkadshfhvjkjzadbjh';
        controller2.applyFilter();
        System.assertEquals(true, controller2.documentsInSelectedFolderMap.isEmpty());
        controller2.documentFilter = '';
        
        
        // add a document which is in the user documents folder
        controller2.selectedFolder = UserInfo.getUserId();
        controller2.updateDocumentList();
        List<SelectOption> availableDocuments = controller2.availableDocuments;
        controller2.availableDocumentsSelected.add(availableDocuments.get(0).getValue());
        controller2.addSalesforceDocuments();
        
        // check we have one attachment so far
        System.assertEquals(controller2.addedDocuments.size(),1);
        
        controller2.parent.documentMap = new Map<String, SelectTrackedEmailAttachmentsController.DocumentSkeleton>();
        
        Map<String, SelectTrackedEmailAttachmentsController.DocumentSkeleton> aDM = controller2.addedDocumentMap;
        for(String key : aDM.keySet()){
            SelectTrackedEmailAttachmentsController.DocumentSkeleton doc = aDM.get(key);
            controller2.parent.documentMap.put(key, new SelectTrackedEmailAttachmentsController.DocumentSkeleton(doc.Name, doc.BodyLength, doc.type));        
        }
        
        // add a document which is in on the user's computer
        controller2.selectedFolder = controller2.computerId;
        controller2.updateDocumentList();
        controller2.uploadedDocument = new Document(Name = 'doc name', Body = Blob.valueOf('Body'));        
        controller2.addPersonalDocument();

        //check we have two attachments so far
        System.assertEquals(controller2.addedDocuments.size(),2);
        
        controller2.selectedFolder = UserInfo.getUserId();

        //remove one of the documents
        controller2.addedDocumentsSelected = new List<String>{controller2.addedDocuments.get(0).getValue()};
        controller2.removeDocuments();
        
        //check we have one attachment left
        System.assertEquals(controller2.addedDocuments.size(),1);
        
        Map<String, SelectTrackedEmailAttachmentsController.DocumentSkeleton> addedDocumentMap = controller2.addedDocumentMap;
        
        for(String s : addedDocumentMap.keySet()){
            System.assert(addedDocumentMap.get(s).Size != null);
        }
        
        Boolean error = controller2.generalError;
        String errorMessage = controller2.generalErrorMessage;
        
        controller2.save();
        
        controller2.addedDocumentMap = null;
        
        controller2.displayPanel();
        
        System.assertEquals(false,controller2.addedDocumentMap.isEmpty());
        
        controller2.cancel();

        Test.stopTest();
    }
}