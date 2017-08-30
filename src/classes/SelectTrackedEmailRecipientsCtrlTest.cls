@isTest
public class SelectTrackedEmailRecipientsCtrlTest {

    static EmailTemplate staticTemplate = [select Id from EmailTemplate where IsActive = true][0];

    static void loadData() {

		Account acc = new Account(
			Name = 'account'
		);
		insert acc;

        Contact contact = new Contact (
            FirstName = 'test contact',
            LastName = 'last name',
            email = 'test@email.com',
            AccountId = acc.Id,
            Status__c = 'Active'
        );
        insert contact;

        Case cse = new Case(
            contactId = contact.Id,
            AccountId = acc.Id
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

        SelectTrackedEmailRecipientsController controller2 = new SelectTrackedEmailRecipientsController();
        
        controller2.selectedList = controller2.ACTIVE_ACCOUNT_CONTACTS;
        
        controller2.parent = controller1;
        
        controller2.recipientFilter = '<sgkadshfhvjkjzadbjh';
        controller2.applyFilter();
        System.assertEquals(true, controller2.availableRecipients.isEmpty());
        controller2.recipientFilter = '';
        controller2.applyFilter();
        
        List<SelectOption> recipientLists = controller2.getRecipientLists();

        List<SelectOption> availableRecipients = controller2.availableRecipients;

        System.assert(availableRecipients.size() > 0);

        controller2.availableRecipientsSelected = new List<String>{availableRecipients.get(0).getValue()};
        
        System.assert(controller2.availableRecipientsSelected.size() > 0);
        
        controller2.addToRecipients();
        controller2.addCcRecipients();
        controller2.addBccRecipients();
        
        List<SelectOption> additionalToRecipients = controller2.getAdditionalToRecipients();
        List<SelectOption> ccRecipients = controller2.getCcRecipients();
        List<SelectOption> bccRecipients = controller2.getBccRecipients();

        controller2.selectedToRecipients = new List<String>{additionalToRecipients.get(0).getValue()};
        controller2.selectedCcRecipients = new List<String>{ccRecipients.get(0).getValue()};
        controller2.selectedBccRecipients = new List<String>{bccRecipients.get(0).getValue()};

        controller2.removeToRecipients();
        controller2.removeCcRecipients();
        controller2.removeBccRecipients();

        controller2.cancel();

        Test.stopTest();
    }
    
    static testMethod void testSave() {

        loadData();

        Case cse = [Select Id from Case limit 1];

        ApexPages.StandardController stdController = new ApexPages.StandardController( new Tracked_Email__c());
        PageReference pageref = Page.sendSingleTrackedEmail;
        pageref.getParameters().put('case',cse.Id);
        system.Test.setCurrentPage(pageRef);


        Test.startTest();
        
        sendSingleTrackedEmailController controller1 = new sendSingleTrackedEmailController(stdController);
        
        controller1.initPage();

        SelectTrackedEmailRecipientsController controller2 = new SelectTrackedEmailRecipientsController();
        
        controller2.parent = controller1;
        
        controller2.selectedList = controller2.ACTIVE_ACCOUNT_CONTACTS;
        
        List<SelectOption> recipientLists = controller2.getRecipientLists();

        List<SelectOption> availableRecipients = controller2.availableRecipients;

        System.assert(availableRecipients.size() > 0);

        controller2.availableRecipientsSelected = new List<String>{availableRecipients.get(0).getValue()};
        
        System.assert(controller2.availableRecipientsSelected.size() > 0);
        
        controller2.addToRecipients();
        controller2.addCcRecipients();
        controller2.addBccRecipients();
        
        controller2.save();

        Test.stopTest();
    }

}