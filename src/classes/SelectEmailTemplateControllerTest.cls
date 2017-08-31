@isTest
public class SelectEmailTemplateControllerTest {

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
        
    }

    static testMethod void testController_OK() {

        Test.startTest();

        loadData();

        Case cse = [Select Id from Case limit 1];

        ApexPages.StandardController stdController = new ApexPages.StandardController( new Tracked_Email__c());
        PageReference pageref = Page.sendSingleTrackedEmail;
        pageref.getParameters().put('case',cse.Id);
        system.Test.setCurrentPage(pageRef);
        
        sendSingleTrackedEmailController controller1 = new sendSingleTrackedEmailController(stdController);
        
        controller1.initPage();

        SelectEmailTemplateController controller = new SelectEmailTemplateController();

        controller.parent = controller1;

        System.assert(controller.selectedFolderId!=null);

		List<String> folderIds = new List<String>();
		for(SelectOption option : controller.getListFolder()){
			folderIds.add(option.getValue());
		}

		EmailTemplate template = [select id, folderId, name from EmailTemplate where isActive = true and folderId in : folderIds][0];

        controller.selectedFolderId = template.folderId;
        
        controller.fillListTemplate();
       
        controller.selectedTemplate = controller.listTemplate.get(0).Id;
        
        System.assert(controller1.cse != null);
        
        controller.setTemplate();
        controller.cancel();

        String url = controller.getCurrentURL();

        Test.stopTest();
    }

}