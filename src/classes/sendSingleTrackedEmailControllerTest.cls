@isTest
public with sharing class sendSingleTrackedEmailControllerTest {

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

	static testMethod void testController() {
		loadData();

		Case cse = [Select Id from Case limit 1];

		ApexPages.StandardController stdController = new ApexPages.StandardController( new Tracked_Email__c());
		PageReference pageref = Page.sendSingleTrackedEmail;
		pageref.getParameters().put('case',cse.Id);
		system.Test.setCurrentPage(pageRef);

		Test.startTest();
		sendSingleTrackedEmailController controller = new sendSingleTrackedEmailController(stdController);

		System.assert(controller.isNew);
		System.assert(controller.cancel() != null);
		system.assert(controller.thisController == controller);

		list<SelectOption> listFrom = controller.getFromAddresses();
		System.assert(listFrom!=null);
		System.assert(listFrom.size()==1);

		Test.stopTest();
	}

	static testMethod void testApplyTemplateError() {
		loadData();

		Case cse = [Select Id from Case limit 1];

		ApexPages.StandardController stdController = new ApexPages.StandardController( new Tracked_Email__c());
		PageReference pageref = Page.sendSingleTrackedEmail;
		pageref.getParameters().put('case',cse.Id);
		system.Test.setCurrentPage(pageRef);

		Test.startTest();
		sendSingleTrackedEmailController controller = new sendSingleTrackedEmailController(stdController);
		controller.applyTemplate();
		System.assert(controller.email.Html_Body__c == '');
		Test.stopTest();
	}

	static testMethod void testApplyTemplateOk() {
		loadData();

		Case cse = [Select Id from Case limit 1];

		EmailTemplate template = [Select Id from EmailTemplate limit 1];
		System.assert(template!=null);

		ApexPages.StandardController stdController = new ApexPages.StandardController( new Tracked_Email__c());
		PageReference pageref = Page.sendSingleTrackedEmail;
		pageref.getParameters().put('case',cse.Id);
		pageref.getParameters().put('template',template.Id);
		system.Test.setCurrentPage(pageRef);

		Test.startTest();
		sendSingleTrackedEmailController controller = new sendSingleTrackedEmailController(stdController);
		controller.applyTemplate();
		//System.assert(controller.email.Html_Body__c != '');
		Test.stopTest();
	}

	static testMethod void testSendEmail_ValidationError() {
		loadData();

		Case cse = [Select Id from Case limit 1];

		ApexPages.StandardController stdController = new ApexPages.StandardController( new Tracked_Email__c());
		PageReference pageref = Page.sendSingleTrackedEmail;
		pageref.getParameters().put('case',cse.Id);
		system.Test.setCurrentPage(pageRef);

		Test.startTest();
		sendSingleTrackedEmailController controller = new sendSingleTrackedEmailController(stdController);

		controller.email.ToContact__c = null;
		controller.email.Subject__c = null;
		controller.email.Html_Body__c = null;

		Pagereference result = controller.sendTrackedEmail();
		System.assert(result == null);

		Test.stopTest();
	}

	static testMethod void testSendEmail_sendError() {
		loadData();

		Case cse = [Select Id, contactId from Case limit 1];

		ApexPages.StandardController stdController = new ApexPages.StandardController( new Tracked_Email__c());
		PageReference pageref = Page.sendSingleTrackedEmail;
		pageref.getParameters().put('case',cse.Id);
		system.Test.setCurrentPage(pageRef);

		Test.startTest();
		sendSingleTrackedEmailController controller = new sendSingleTrackedEmailController(stdController);

		controller.email.ToContact__c = cse.contactId;
		controller.email.Subject__c = 'testSubject';
		controller.email.Html_Body__c = 'testBody';

		Pagereference savepageref = controller.sendTrackedEmail();
		System.assert(savepageref == null);

		Test.stopTest();
	}

	static testMethod void testSendEmail_Ok() {
		loadData();

		Case cse = [Select Id, contactId from Case limit 1];

		ApexPages.StandardController stdController = new ApexPages.StandardController( new Tracked_Email__c());
		PageReference pageref = Page.sendSingleTrackedEmail;
		pageref.getParameters().put('case',cse.Id);
		system.Test.setCurrentPage(pageRef);

		Test.startTest();
		sendSingleTrackedEmailController controller = new sendSingleTrackedEmailController(stdController);

		controller.email.ToContact__c = cse.contactId;
		controller.email.Subject__c = 'testSubject';
		controller.email.Html_Body__c = 'testBody';

		SignaturitRest.TESTSTRING = SignaturitRestTest.testString;
		Pagereference savepageref = controller.sendTrackedEmail();
		System.assert(savepageref != null);

		Test.stopTest();
	}

}