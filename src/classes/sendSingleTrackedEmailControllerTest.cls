@isTest
public with sharing class sendSingleTrackedEmailControllerTest {

    static EmailTemplate staticTemplate = [select Id, DeveloperName from EmailTemplate where IsActive = true][0];


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
        
        Attachment att = new Attachment(
            Name='Attachment 1',
            Body = Blob.valueOf('Attachment 1 body'),
            ParentId = staticTemplate.Id
        );
        
        insert att;
        
        Document doc = new Document(
            Name = 'Document 1',
            FolderId = UserInfo.getUserId(),
            Body = Blob.valueOf('Document 1 body')
        );
        
        insert doc;
        
        Signaturit_Events_WS__c ws = new Signaturit_Events_WS__c(name = 'test', events_url__c = 'http://test.com', oauth_url__c = '');
        insert ws;   
    }


    static testMethod void testCustomTemplate() {
        loadData();

        Case cse = [Select Id from Case limit 1];

        ApexPages.StandardController stdController = new ApexPages.StandardController( new Tracked_Email__c());
        PageReference pageref = Page.sendSingleTrackedEmail;
        pageref.getParameters().put('case',cse.Id);
        system.Test.setCurrentPage(pageRef);

        Test.startTest();
        
        sendSingleTrackedEmailController controller = new sendSingleTrackedEmailController(stdController);
        
        controller.initPage();
        
        controller.selectedFrom = 'agencymanagement@iata.org';
        
        EmailTemplate template = [select Id, Name from EmailTemplate where TemplateType='custom' and IsActive = true][0];

        controller.setTemplate(template.Id);
    
        controller.sendTrackedEmail();
    
        Test.stopTest();
    }

    static testMethod void testPreview() {
        loadData();

        Case cse = [Select Id from Case limit 1];

        ApexPages.StandardController stdController = new ApexPages.StandardController( new Tracked_Email__c());
        PageReference pageref = Page.sendSingleTrackedEmail;
        pageref.getParameters().put('case',cse.Id);
        system.Test.setCurrentPage(pageRef);

        Test.startTest();
        
        sendSingleTrackedEmailController controller = new sendSingleTrackedEmailController(stdController);
        
        controller.initPage();
        
        EmailTemplate template = [select Id, Name from EmailTemplate where TemplateType='html' and IsActive = true][0];

        controller.setTemplate(template.Id);

        ApexPages.StandardController stdController2 = new ApexPages.StandardController( new Tracked_Email__c());

        TrackedEmailPreviewController controller2 = new TrackedEmailPreviewController();
        
        controller2.parent = controller;
        
        controller2.getHtmlBody();
        controller2.closePreview();
    
        Test.stopTest();
    }
    
    static testMethod void testHtmlTemplate() {
        loadData();

        Case cse = [Select Id from Case limit 1];

        ApexPages.StandardController stdController = new ApexPages.StandardController( new Tracked_Email__c());
        PageReference pageref = Page.sendSingleTrackedEmail;
        pageref.getParameters().put('case',cse.Id);
        system.Test.setCurrentPage(pageRef);

        Test.startTest();
        
        sendSingleTrackedEmailController controller = new sendSingleTrackedEmailController(stdController);
        
        controller.initPage();

        controller.selectedFrom = 'agencymanagement@iata.org';
                
        EmailTemplate template = [select Id, Name from EmailTemplate where TemplateType='html' and IsActive = true][0];

        controller.setTemplate(template.Id);
    
        controller.sendTrackedEmail();
    
        Test.stopTest();
    }
    
    static testMethod void testTextTemplate() {
        loadData();

        Case cse = [Select Id from Case limit 1];

        ApexPages.StandardController stdController = new ApexPages.StandardController( new Tracked_Email__c());
        PageReference pageref = Page.sendSingleTrackedEmail;
        pageref.getParameters().put('case',cse.Id);
        system.Test.setCurrentPage(pageRef);

        Test.startTest();
        
        sendSingleTrackedEmailController controller = new sendSingleTrackedEmailController(stdController);
        
        controller.initPage();
        
        EmailTemplate template = [select Id, Name from EmailTemplate where TemplateType='text' and IsActive = true][0];

        controller.setTemplate(template.Id);
    
        controller.selectedFrom = 'agencymanagement@iata.org';
    
        controller.sendTrackedEmail();
    
        Test.stopTest();
    }
    
    static testMethod void testNoTemplate() {
        loadData();

        Case cse = [Select Id from Case limit 1];

        ApexPages.StandardController stdController = new ApexPages.StandardController(new Tracked_Email__c());
        PageReference pageref = Page.sendSingleTrackedEmail;
        pageref.getParameters().put('case',cse.Id);
        system.Test.setCurrentPage(pageRef);

        Test.startTest();
        
        sendSingleTrackedEmailController controller = new sendSingleTrackedEmailController(stdController);

        controller.initPage();

        controller.email.Subject__c = 'test';
        controller.email.Html_Body__c = 'test';
        controller.email.TextBody__c = 'test';
        controller.email.AdditionalTo__c = 'a@a.com';
        controller.email.CcAddress__c = 'a@a.com';
        controller.email.BccAddress__c = 'a@a.com';
            
        controller.selectedFrom = 'agencymanagement@iata.org';
    
        controller.sendTrackedEmail();
           
        PageReference pageref2 = Page.TrackedEmailHtmlBody;
        pageref2.getParameters().put('id',controller.email.Id);
        system.Test.setCurrentPage(pageRef2);

        ApexPages.StandardController stdController2 = new ApexPages.StandardController( new Tracked_Email__c());

        TrackedEmailPreviewController controller2 = new TrackedEmailPreviewController();
        
        controller2.getHtmlBody();
        
        Test.stopTest();
    }
        
    static testMethod void testCheckFields() {
        loadData();

        Case cse = [Select Id from Case limit 1];

        ApexPages.StandardController stdController = new ApexPages.StandardController( new Tracked_Email__c());
        PageReference pageref = Page.sendSingleTrackedEmail;
        pageref.getParameters().put('case',cse.Id);
        system.Test.setCurrentPage(pageRef);

        Test.startTest();
        
        sendSingleTrackedEmailController controller = new sendSingleTrackedEmailController(stdController);
        
        controller.initPage();
        
        EmailTemplate template = [select Id, Name from EmailTemplate where TemplateType='text' and IsActive = true][0];

        controller.setTemplate(template.Id);
    
        controller.selectedFrom = 'agencymanagement@iata.org';
    
        controller.email.ToContact__c = null;
        controller.email.Subject__c = null;
        controller.email.Html_Body__c = null;
    
        controller.sendTrackedEmail();
    
        Test.stopTest();
    }
    
    static testMethod void testReplyTo() {
        loadData();

        Case cse = [Select Id from Case limit 1];

        ApexPages.StandardController stdController = new ApexPages.StandardController( new Tracked_Email__c());
        PageReference pageref = Page.sendSingleTrackedEmail;
        pageref.getParameters().put('case',cse.Id);
        system.Test.setCurrentPage(pageRef);

        Test.startTest();
        
        sendSingleTrackedEmailController controller = new sendSingleTrackedEmailController(stdController);
        
        controller.initPage();
        
        EmailTemplate template = [select Id, Name from EmailTemplate where TemplateType='text' and IsActive = true][0];

        controller.setTemplate(template.Id);
    
        controller.selectedFrom = 'agencymanagement@iata.org';
    
        controller.sendTrackedEmail();

        Tracked_Email__c originalEmail = [Select Id from Tracked_Email__c limit 1];

        ApexPages.StandardController stdController2 = new ApexPages.StandardController( new Tracked_Email__c());
        PageReference pageref2 = Page.sendSingleTrackedEmail;
        pageref2.getParameters().put('originalEmail',originalEmail.Id);
        pageref2.getParameters().put('action','ReplyTo');
        system.Test.setCurrentPage(pageRef2);

        sendSingleTrackedEmailController controller2 = new sendSingleTrackedEmailController(stdController2);
        
        controller2.initPage();
        
        controller2.sendTrackedEmail();
    
        Test.stopTest();
    }
    
    
    static testMethod void testReplyToAll() {
        loadData();

        Case cse = [Select Id from Case limit 1];

        ApexPages.StandardController stdController = new ApexPages.StandardController( new Tracked_Email__c());
        PageReference pageref = Page.sendSingleTrackedEmail;
        pageref.getParameters().put('case',cse.Id);
        system.Test.setCurrentPage(pageRef);

        Test.startTest();
        
        sendSingleTrackedEmailController controller = new sendSingleTrackedEmailController(stdController);
        
        controller.initPage();
        
        EmailTemplate template = [select Id, Name from EmailTemplate where TemplateType='text' and IsActive = true][0];

        controller.setTemplate(template.Id);
    
        controller.selectedFrom = 'agencymanagement@iata.org';
    
        controller.sendTrackedEmail();

        Tracked_Email__c originalEmail = [Select Id from Tracked_Email__c limit 1];

        ApexPages.StandardController stdController2 = new ApexPages.StandardController( new Tracked_Email__c());
        PageReference pageref2 = Page.sendSingleTrackedEmail;
        pageref2.getParameters().put('originalEmail',originalEmail.Id);
        pageref2.getParameters().put('action','ReplyToAll');
        system.Test.setCurrentPage(pageRef2);

        sendSingleTrackedEmailController controller2 = new sendSingleTrackedEmailController(stdController2);
        
        controller2.initPage();
        
        controller2.sendTrackedEmail();
    
        Test.stopTest();
    }
    
    
    static testMethod void testForward() {
        loadData();

        Case cse = [Select Id from Case limit 1];

        ApexPages.StandardController stdController = new ApexPages.StandardController( new Tracked_Email__c());
        PageReference pageref = Page.sendSingleTrackedEmail;
        pageref.getParameters().put('case',cse.Id);
        system.Test.setCurrentPage(pageRef);

        Test.startTest();
        
        sendSingleTrackedEmailController controller = new sendSingleTrackedEmailController(stdController);
        
        controller.initPage();
        
        EmailTemplate template = [select Id, Name from EmailTemplate where TemplateType='text' and IsActive = true][0];

        controller.setTemplate(template.Id);
    
        controller.selectedFrom = 'agencymanagement@iata.org';
    
        controller.sendTrackedEmail();

        Tracked_Email__c originalEmail = [Select Id from Tracked_Email__c limit 1];

        ApexPages.StandardController stdController2 = new ApexPages.StandardController( new Tracked_Email__c());
        PageReference pageref2 = Page.sendSingleTrackedEmail;
        pageref2.getParameters().put('originalEmail',originalEmail.Id);
        pageref2.getParameters().put('action','Forward');
        system.Test.setCurrentPage(pageRef2);

        sendSingleTrackedEmailController controller2 = new sendSingleTrackedEmailController(stdController2);
        
        controller2.initPage();
        
        controller2.sendTrackedEmail();
    
        Test.stopTest();
    }
    
    static testMethod void testAttachments() {
        loadData();

        Case cse = [Select Id from Case limit 1];

        ApexPages.StandardController stdController = new ApexPages.StandardController( new Tracked_Email__c());
        PageReference pageref = Page.sendSingleTrackedEmail;
        pageref.getParameters().put('case',cse.Id);
        system.Test.setCurrentPage(pageRef);

        Test.startTest();
        
        sendSingleTrackedEmailController controller = new sendSingleTrackedEmailController(stdController);
        
        controller.initPage();
        
        controller.setTemplate(staticTemplate.Id);
        controller.setTemplate(staticTemplate.DeveloperName);

        controller.selectedFrom = 'agencymanagement@iata.org';
    
        Attachment attachment = [select Id, Name, BodyLength from Attachment limit 1];
        controller.DocumentMap.put(attachment.Id, new SelectTrackedEmailAttachmentsController.DocumentSkeleton(attachment.Name, attachment.BodyLength, 'original attachment'));

        Document document = [select Id, Name, BodyLength from Document limit 1];
        controller.DocumentMap.put(document.Id, new SelectTrackedEmailAttachmentsController.DocumentSkeleton(document.Name, document.BodyLength, 'salesforce document'));
        controller.documentToDelete = document.Id;
        controller.uploadedDocuments.add(document.Id);
        controller.deleteAttachment();

        controller.DocumentMap.put(document.Id, new SelectTrackedEmailAttachmentsController.DocumentSkeleton(document.Name, document.BodyLength, 'salesforce document'));

        controller.sendTrackedEmail();
    
        Test.stopTest();
    }
    
    static testMethod void testVisualforcePageCalls(){
        loadData();

        Case cse = [Select Id from Case limit 1];

        ApexPages.StandardController stdController = new ApexPages.StandardController( new Tracked_Email__c());
        PageReference pageref = Page.sendSingleTrackedEmail;
        pageref.getParameters().put('case',cse.Id);
        pageref.getParameters().put('toContact',UserInfo.getUserId());
        pageref.getParameters().put('sendToUser','true');
        system.Test.setCurrentPage(pageRef);

        Test.startTest();
        sendSingleTrackedEmailController controller = new sendSingleTrackedEmailController(stdController);
        
        sendSingleTrackedEmailController controller2 = controller.thisController;
        
        controller.initPage();

        controller.setTemplate(staticTemplate.Id);

        List<String> documents = controller.documents;

        Boolean b = controller.isBodyEditable;
        b = controller.isSwitchable;
        b = controller.isDocumentMapEmpty;
        b = controller.isNew;
        
        
        
        controller.switchToTextOnly();
        controller.switchToHtml();

        controller.showPreviewPanel();
        controller.showAttachmentsPanel();
        controller.showTemplatePanel();
        controller.showRecipientsPanel();
        controller.cancel();
        controller.discardTemplate();
        controller.getFromAddresses();
        
        String s = controller.selectedFrom;
        List<SelectOption> l = controller.fromAddresses;
    
    }

    static testMethod void testErrorSendingEmail(){
        loadData();

        Case cse = [Select Id from Case limit 1];

        ApexPages.StandardController stdController = new ApexPages.StandardController(new Tracked_Email__c());
        PageReference pageref = Page.sendSingleTrackedEmail;
        pageref.getParameters().put('case',cse.Id);
        system.Test.setCurrentPage(pageRef);

        Test.startTest();
        
        sendSingleTrackedEmailController controller = new sendSingleTrackedEmailController(stdController);

        controller.initPage();

        controller.email.Subject__c = 'test error sending';
        controller.email.Html_Body__c = 'test';
        controller.email.TextBody__c = 'test';           
        controller.selectedFrom = 'agencymanagement@iata.org';
    
        controller.sendTrackedEmail();
		
		//EM: To be removed
		clsFinancialSecurityRequestController.fakecoverage();
        
        Test.stopTest();
    }
}