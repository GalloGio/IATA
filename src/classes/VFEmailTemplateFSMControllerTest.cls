@isTest
public class VFEmailTemplateFSMControllerTest {

	private static Case createCase() {
		EmailTemplate__c template = new EmailTemplate__c();
		template.Greeting_Line__c = 'greeting';
		template.Body_Section_1__c = 'section1';
		template.Body_Section_2__c = 'section2';
		template.Body_Section_3__c = 'section3';
		template.Signature_Details__c = 'signature';
		template.Text_1__c = 'text1';
		insert template;

		Case caseObj = new Case();
		caseObj.Reminder_EmailTemplate__c = template.id;
		caseObj.Financial_Security_Amount_2__c = 100;
		caseObj.CurrencyISOCode = 'EUR';
		insert caseObj;
		return caseObj;
	}

	static testMethod void testInit() {
		Case caseObj = createCase();

		Test.StartTest();
		VFEmailTemplateFSMController ctrl = new VFEmailTemplateFSMController();
		ctrl.caseObjId = caseObj.Id;
		ctrl.init();
		Test.StopTest();

	}

	static testMethod void testImageHeader() {
		//Folder folder = [Select Id from Folder limit 1];
		Folder folder = [Select Id from Folder WHERE AccessType = 'Public' AND Type = 'Document' limit 1];
		//system.debug('DTULLO Folder --> ' + folder);
		//system.debug('DTULLO Folder id --> ' + folder.id);
		Document doc = new Document( Name = 'FSM Email Template Header', FolderId = folder.Id);
		//DTULLO: Workaround for folder id: use personal folder...
		//Document doc = new Document( Name = 'FSM Email Template Header', FolderId = UserInfo.getUserId());
		insert doc;

		Test.StartTest();
		VFEmailTemplateFSMController ctrl = new VFEmailTemplateFSMController();
		ctrl.getImageHeader();
		Test.StopTest();
	}
}
