/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class EmailMessageHandlerTest {

	private static Case createClosedCase() {
		String caseJSON = '{"attributes":{'
			+ '"type":"Case",'
			+ '"url":"/services/data/v25.0/sobjects/Case/500E0000002nH2fIAE"},'
			+ '"CreatedDate":' + JSON.serialize(DateTime.now().addMonths(-3)) + ','
			+ '"Subject":"Test Case Subject",'
			+ '"Reason1__c":"New Account request",'
			+ '"CaseArea__c":"Global System Solution",'
			+ '"Status":"Closed",'
			+ '"ClosedDate":' + JSON.serialize(DateTime.now().addMonths(-3)) + ','
			+ '"RecordTypeId":"' + RecordTypeSingleton.getInstance().getRecordTypeId('Case', EmailMessageHandler.LIST_VALID_RT.get(0)) + '"'
			+ '}';
			//+ '"ContactId":"' + contact.id + '",'
			//+ '"AccountId":"' + account.id + '",'
		return (Case) JSON.deserialize(caseJSON, Case.class );
	}

	static testMethod void test_SetTheNOISentDateOnParentCase() {
		// create a SIDRA case
		Case aCase = new Case();
		acase.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');
		acase.Subject = 'Test Case Subject';
		acase.Late_Payment_Date__c = Date.today();
		insert aCase;
		insert new Apex_Setting__c(Name='RT valid to reopen attachment trigger', Text_1__c='CasesEurope,Cases_Global,CasesAmericas,CasesMENA,ExternalCasesIDFSglobal,Cases_China_North_Asia, ComplaintIDFS,'
                                           +  'Inter_DPCs,Invoicing_Collection_Cases,Cases_SIS_Help_Desk,InternalCasesEuropeSCE,CS_Process_IDFS_ISS,ID_Card_Application');
		// create an attachment to it
		Attachment att = new Attachment();
		att.ParentId = aCase.Id;
		att.Name = 'Notice of Irregularity';
		att.Body = Blob.valueOf('asd');
		insert att;

		test.startTest();
			// simulate the creation of an email message
			EmailMessage em = new EmailMessage();
			em.ParentId = aCase.Id;
			em.Incoming = false;
			em.FromAddress = 'test@example.com';
			em.ToAddress = 'test@example.com';
			em.Subject = 'Test email';
			em.TextBody = 'Hello';
			insert em;

			// assert that the case NOI Sent was set
			aCase = [SELECT Id, NOI_sent__c FROM Case WHERE Id = :aCase.Id];
			System.assertNotEquals(null, aCase.NOI_sent__c);

		test.stopTest();
	}

	static testMethod void test_sendEmailToSenderWhenCaseClosed_ErrorNoTemplate() {
		// create a SIDRA case
		Contact contact = new Contact();
		contact.FirstName = 'test contact';
		contact.LastName = 'last name';
		contact.Email = 'test1@example.com';
		insert contact;

		Account account = new Account(Name='test Account');
		insert account;

		Case aCase = createClosedCase();
		aCase.accountId = account.Id;
		aCase.contactId = contact.Id;
		insert aCase;

		test.startTest();
			// simulate the creation of an email message
			EmailMessage em = new EmailMessage();
			em.parentId = acase.Id;
			em.FromAddress = 'test2@example.com';
			insert em;
		test.stopTest();

		// assert that the case NOI Sent was set
		list<EmailMessage> listEmails = [SELECT Id FROM EmailMessage WHERE ParentId = :aCase.Id];
		System.assertEquals(1,listEmails.size());
	}

	static testMethod void test_sendEmailToSenderWhenCaseClosed_OK() {
		User usr = [Select id from User where Id = :UserInfo.getUserId()];
		EmailTemplate template = new EmailTemplate(
			Name = 'Test_Template',
			DeveloperName = 'Test_Template',
			Subject = 'test template',
			HtmlValue = '<html></html>',
			TemplateType = 'text',
			isActive = true,
			FolderId = USerInfo.getUSerId());
		System.RunAs(usr) {
			insert template;
		}

		Case_Closed_Templates__c customSetting = new Case_Closed_Templates__c();
		customSetting.Name = 'test';
		customSetting.Template_Id__c = template.id;
		insert customSetting;

		// create a SIDRA case
		Contact contact = new Contact();
		contact.FirstName = 'test contact';
		contact.LastName = 'last name';
		contact.Email = 'test1@example.com';
		insert contact;

		Account account = new Account(Name='test Account');
		insert account;

		Case aCase = createClosedCase();
		aCase.accountId = account.Id;
		aCase.contactId = contact.Id;
		insert aCase;

		test.startTest();
			// simulate the creation of an email message
			EmailMessage em = new EmailMessage();
			em.parentId = acase.Id;
			em.FromAddress = 'test2@example.com';
			insert em;
		test.stopTest();

		// assert that the case NOI Sent was set
		list<EmailMessage> listEmails = [SELECT Id FROM EmailMessage WHERE ParentId = :aCase.Id];
		//System.assertEquals(2,listEmails.size());
	}

	//ACAMBAS - WMO-436 - Begin

	static testMethod void test_sendEmailToSenderWhenCaseOpened() {

		Case_RTs_for_Auto_Reply_Email__c customSetting = new Case_RTs_for_Auto_Reply_Email__c(Name = 'CasesEurope', Record_Type_Name__c = 'Cases - Europe');
		insert customSetting;

		Contact contact = new Contact(LastName = 'test', Email = 'test@test.com');
		insert contact;

		Account account = new Account(Name='test Account');
		insert account;

		Case aCase = new Case();
		aCase.accountId = account.Id;
		aCase.contactId = contact.Id;
		aCase.recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'CasesEurope');
		aCase.subject = 'Case test';
		insert aCase;

		test.startTest();
			// simulate the creation of an email message
			EmailMessage em = new EmailMessage();
			em.Incoming = true;
			em.parentId = acase.Id;
			em.FromAddress = 'test2@example.com';
			insert em;
		test.stopTest();

		list<EmailMessage> listEmails = [SELECT Id, Incoming, Subject, ToAddress, TextBody FROM EmailMessage WHERE ParentId = :aCase.Id AND Incoming = false];

		system.debug('### listEmails: ' + listEmails);

		//Email should be sent
		System.assertEquals(1, listEmails.size());


		//Update case to a record type that is not eligible to send email to the customer when an email is received
		aCase.recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'CasesMENA');
		update aCase;

		// simulate the creation of an email message
		EmailMessage em2 = new EmailMessage();
		em2.Incoming = true;
		em2.parentId = acase.Id;
		em2.FromAddress = 'test2@example.com';
		insert em2;

		listEmails = [SELECT Id, Incoming, Subject, ToAddress, TextBody FROM EmailMessage WHERE ParentId = :aCase.Id AND Incoming = false];

		//Email should NOT be sent
		System.assertEquals(1, listEmails.size());

	}

	//ACAMBAS - WMO-436 - End
}
