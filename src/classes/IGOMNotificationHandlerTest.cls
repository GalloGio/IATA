@isTest
private class IGOMNotificationHandlerTest {
	public static final String NOTIF_SUBJ = 'Example notification';
	public static final String NOTIF_BODY = 'This is an example notification';
	public static final String EX_SUBJ = 'Example subject';
	public static final String EX_BODY = 'Example body';
	public static final String EX_HTML_BODY = '<p>Example HTML body</p>';
	public static final String SECTION_PROC = 'Section 1 Procedure 1';
	public static final String TEST_NAME = 'Test name 0';
	
	
	// When set to 200 an external process crashes
	private final static Integer BATCH_NUM = 30;

	@TestSetup
	static void makeData() {
		IGOMTestFactory.createExampleComplianceReviewData();
	}

	private static List<Messaging.SingleEmailMessage> insertNotificationsByHandler(List<IGOM_Contact_Role_Procedure_Compliance__c> notificationList) {
		insert notificationList;
		// Create handler and execute it in the triggers fashion
		IGOMNotificationHandler.bypassEmailsOnTest = false;
		IGOMNotificationHandler notificationHandler = new IGOMNotificationHandler();
		notificationHandler.afterInsert(notificationList);
		notificationHandler.andFinally();
		return notificationHandler.emails;
	}

	@isTest
	private static void testHasTemplates() {
		// These templates are required for processes
		System.assertEquals(1, [SELECT Id FROM EmailTemplate WHERE DeveloperName = :IGOMConstants.GLOBALS.EMAIL_TEMPLATE_GAP_ANALYSIS].size());
		System.assertEquals(1, [SELECT Id FROM EmailTemplate WHERE DeveloperName = :IGOMConstants.GLOBALS.EMAIL_TEMPLATE_GAP_REMINDER].size());
	}

	@isTest 
	private static void testSendRegularNotificationTemplateless() {
		IGOM_Contact_Role_Detail__c contactRoleDetail = 
			[SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c 
			 FROM IGOM_Contact_Role_Detail__c 
			 WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = :TEST_NAME 
				   AND Role__c = :IGOMConstants.ROLES.ADMIN
			 LIMIT 1];

		// Generate notification
		List<IGOM_Contact_Role_Procedure_Compliance__c> notifications = new List<IGOM_Contact_Role_Procedure_Compliance__c>();
		IGOM_Contact_Role_Procedure_Compliance__c noti = IGOMTestFactory.createIGOMContactRoleProcedureCompliance(contactRoleDetail.Id, null);
		noti.Notification_Subject__c = NOTIF_SUBJ;
		noti.Notification_Body__c = NOTIF_BODY;
		noti.Notification_Date__c = System.today();
		
		Test.startTest();
		
		List<Messaging.SingleEmailMessage> sentEmails = insertNotificationsByHandler(new List<IGOM_Contact_Role_Procedure_Compliance__c>{ noti });
		Integer emailInvocations = Limits.getEmailInvocations();

		Test.stopTest();

		System.assertEquals(1, emailInvocations);
		System.assertEquals(1, sentEmails.size());
		System.assertEquals(contactRoleDetail.Account_Contact_Role__r.Contact__c, sentEmails.get(0).getTargetObjectId());
		System.assertEquals('New notification: Example notification', sentEmails.get(0).getSubject());
		System.assertEquals('You have received a new notification\n\nThis is an example notification', sentEmails.get(0).getPlainTextBody());
	}

	@isTest 
	private static void testSendRegularNotificationWithTemplate() {
		IGOM_Contact_Role_Detail__c contactRoleDetail = 
			[SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c 
			 FROM IGOM_Contact_Role_Detail__c 
			 WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = :TEST_NAME 
				   AND Role__c = :IGOMConstants.ROLES.ADMIN
			 LIMIT 1];

		EmailTemplate emailTemplate = new EmailTemplate(
			IsActive = true,
			Name = 'IGOM Notification - Example notification',
			DeveloperName = 'IGOM_Notification_Example_Notification', 
			FolderId = UserInfo.getUserId(), 
			TemplateType = 'custom', 
			Subject = EX_SUBJ,
			Body = EX_BODY,
			HtmlValue = EX_HTML_BODY
		);
		System.runAs(new User(Id=UserInfo.getUserId())) {
			insert emailTemplate;
		}

		// Generate notification
		List<IGOM_Contact_Role_Procedure_Compliance__c> notifications = new List<IGOM_Contact_Role_Procedure_Compliance__c>();
		IGOM_Contact_Role_Procedure_Compliance__c noti = IGOMTestFactory.createIGOMContactRoleProcedureCompliance(contactRoleDetail.Id, null);
		noti.Notification_Subject__c = NOTIF_SUBJ;
		noti.Notification_Body__c = NOTIF_BODY;
		noti.Notification_Date__c = System.today();
		
		Test.startTest();
		
		List<Messaging.SingleEmailMessage> sentEmails = insertNotificationsByHandler(new List<IGOM_Contact_Role_Procedure_Compliance__c>{ noti });
		Integer emailInvocations = Limits.getEmailInvocations();

		Test.stopTest();

		System.assertEquals(1, emailInvocations);
		System.assertEquals(1, sentEmails.size());
		System.assertEquals(contactRoleDetail.Account_Contact_Role__r.Contact__c, sentEmails.get(0).getTargetObjectId());        
		System.assertEquals(emailTemplate.Id, sentEmails.get(0).getTemplateId());        
		System.assertEquals(emailTemplate.Name, sentEmails.get(0).getTemplateName());        
		System.assertEquals(EX_SUBJ, sentEmails.get(0).getSubject());
		System.assertEquals(EX_BODY, sentEmails.get(0).getPlainTextBody());
		System.assertEquals(EX_HTML_BODY, sentEmails.get(0).getHtmlBody());
	}

	@isTest 
	private static void testSendIGOMVariationNotificationSingle() {
		IGOM_Contact_Role_Detail__c contactRoleDetail = 
			[SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c 
			 FROM IGOM_Contact_Role_Detail__c 
			 WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = :TEST_NAME 
				   AND Role__c = :IGOMConstants.ROLES.ADMIN
			 LIMIT 1];

		Id complianceReview1Id = [SELECT Id FROM Compliance_Review__c WHERE Title__c = 'Compliance Review 1'].Id;

		Map<String, Id> complianceReviewPartNameToId = new Map<String, Id>();
		for (Compliance_Review_Part__c complianceReviewPart : [SELECT Id, Standard_Document_Part__r.Name__c FROM Compliance_Review_Part__c WHERE Compliance_Review__c = :complianceReview1Id]) {
			complianceReviewPartNameToId.put(complianceReviewPart.Standard_Document_Part__r.Name__c, complianceReviewPart.Id);
		}

		// Generate notification
		List<IGOM_Contact_Role_Procedure_Compliance__c> notifications = new List<IGOM_Contact_Role_Procedure_Compliance__c>();
		IGOM_Contact_Role_Procedure_Compliance__c noti = IGOMTestFactory.createIGOMContactRoleProcedureCompliance(contactRoleDetail.Id, complianceReviewPartNameToId.get(SECTION_PROC));
		noti.Notification_Subject__c = IGOMConstants.METADATA.NOTIFICATION_NEW_GAP_SUBJECT;
		noti.Notification_Body__c = IGOMConstants.METADATA.NOTIFICATION_NEW_GAP_BODY;
		noti.Notification_Date__c = System.today();

		Test.startTest();
		
		List<Messaging.SingleEmailMessage> sentEmails = insertNotificationsByHandler(new List<IGOM_Contact_Role_Procedure_Compliance__c>{ noti });
		Integer emailInvocations = Limits.getEmailInvocations();

		Test.stopTest();

		EmailTemplate gapEmailTemplate = [SELECT Id, Name, DeveloperName, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = :IGOMConstants.GLOBALS.EMAIL_TEMPLATE_GAP_ANALYSIS];

		System.assertEquals(1, emailInvocations);
		System.assertEquals(1, sentEmails.size());

		System.assertEquals(contactRoleDetail.Account_Contact_Role__r.Contact__c, sentEmails.get(0).getTargetObjectId());
		System.assertEquals(gapEmailTemplate.Subject, sentEmails.get(0).getSubject());
		final String textResult = gapEmailTemplate.Body.replace('{!Notifications}', '- Section 1 Procedure 1: Varies GOM Ed.1.0 V.0.0 R.Test revision 0 - Test provision procedure text').replace('{!StationName}', TEST_NAME).remove('{!ConfirmationText}');
		System.assertEquals(textResult, sentEmails.get(0).getPlainTextBody());
		final String htmlResult = gapEmailTemplate.HtmlValue.replace('{!Notifications}', '- Section 1 Procedure 1: Varies GOM Ed.1.0 V.0.0 R.Test revision 0 - Test provision procedure text').replace('{!StationName}', TEST_NAME).remove('{!ConfirmationText}');
		System.assertEquals(htmlResult, sentEmails.get(0).getHtmlBody());
	}

	@isTest 
	private static void testSendIGOMVariationNotificationMultiple() {
		IGOM_Contact_Role_Detail__c contactRoleDetail = 
			[SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c 
			 FROM IGOM_Contact_Role_Detail__c 
			 WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = :TEST_NAME 
				   AND Role__c = :IGOMConstants.ROLES.ADMIN
			 LIMIT 1];

		Id complianceReview1Id = [SELECT Id FROM Compliance_Review__c WHERE Title__c = 'Compliance Review 1'].Id;

		Map<String, Id> complianceReviewPartNameToId = new Map<String, Id>();
		for (Compliance_Review_Part__c complianceReviewPart : [SELECT Id, Standard_Document_Part__r.Name__c FROM Compliance_Review_Part__c WHERE Compliance_Review__c = :complianceReview1Id]) {
			complianceReviewPartNameToId.put(complianceReviewPart.Standard_Document_Part__r.Name__c, complianceReviewPart.Id);
		}

		// Generate notifications
		List<IGOM_Contact_Role_Procedure_Compliance__c> notifications = new List<IGOM_Contact_Role_Procedure_Compliance__c>();
		IGOM_Contact_Role_Procedure_Compliance__c noti = IGOMTestFactory.createIGOMContactRoleProcedureCompliance(contactRoleDetail.Id, complianceReviewPartNameToId.get(SECTION_PROC));
		noti.Notification_Subject__c = IGOMConstants.METADATA.NOTIFICATION_NEW_GAP_SUBJECT;
		noti.Notification_Body__c = IGOMConstants.METADATA.NOTIFICATION_NEW_GAP_BODY;
		noti.Notification_Date__c = System.today();
		IGOM_Contact_Role_Procedure_Compliance__c noti2 = IGOMTestFactory.createIGOMContactRoleProcedureCompliance(contactRoleDetail.Id, complianceReviewPartNameToId.get('Section 2 Procedure 1'));
		noti2.Notification_Subject__c = IGOMConstants.METADATA.NOTIFICATION_NEW_GAP_SUBJECT;
		noti2.Notification_Body__c = IGOMConstants.METADATA.NOTIFICATION_NEW_GAP_BODY;
		noti2.Notification_Date__c = System.today();


		Test.startTest();
		
		List<Messaging.SingleEmailMessage> sentEmails = insertNotificationsByHandler(new List<IGOM_Contact_Role_Procedure_Compliance__c>{ noti, noti2 });
		Integer emailInvocations = Limits.getEmailInvocations();

		Test.stopTest();

		EmailTemplate gapEmailTemplate = [SELECT Id, Name, DeveloperName, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = :IGOMConstants.GLOBALS.EMAIL_TEMPLATE_GAP_ANALYSIS];

		System.assertEquals(1, emailInvocations);
		System.assertEquals(1, sentEmails.size());

		System.assertEquals(contactRoleDetail.Account_Contact_Role__r.Contact__c, sentEmails.get(0).getTargetObjectId());
		System.assertEquals(gapEmailTemplate.Subject, sentEmails.get(0).getSubject());
		final String textResult = gapEmailTemplate.Body.replace('{!Notifications}', '- Section 1 Procedure 1: Varies GOM Ed.1.0 V.0.0 R.Test revision 0 - Test provision procedure text\n- Section 2 Procedure 1: Varies GOM Ed.1.0 V.0.0 R.Test revision 0 - Test provision procedure text').replace('{!StationName}', TEST_NAME).remove('{!ConfirmationText}');
		System.assertEquals(textResult, sentEmails.get(0).getPlainTextBody());
		final String htmlResult = gapEmailTemplate.HtmlValue.replace('{!Notifications}', '- Section 1 Procedure 1: Varies GOM Ed.1.0 V.0.0 R.Test revision 0 - Test provision procedure text<br/>- Section 2 Procedure 1: Varies GOM Ed.1.0 V.0.0 R.Test revision 0 - Test provision procedure text').replace('{!StationName}', TEST_NAME).remove('{!ConfirmationText}');
		System.assertEquals(htmlResult, sentEmails.get(0).getHtmlBody());
	}

	@isTest 
	private static void testSendRegularNotificationTemplatelessBatch() {
		IGOM_Contact_Role_Detail__c contactRoleDetail = 
			[SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c 
			 FROM IGOM_Contact_Role_Detail__c 
			 WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = :TEST_NAME 
				   AND Role__c = :IGOMConstants.ROLES.ADMIN
			 LIMIT 1];

		// Generate notification
		List<IGOM_Contact_Role_Procedure_Compliance__c> notifications = new List<IGOM_Contact_Role_Procedure_Compliance__c>();
		for (Integer i = 0; i < BATCH_NUM; i++) {
			IGOM_Contact_Role_Procedure_Compliance__c noti = IGOMTestFactory.createIGOMContactRoleProcedureCompliance(contactRoleDetail.Id, null);
			noti.Notification_Subject__c = NOTIF_SUBJ;
			noti.Notification_Body__c = NOTIF_BODY;
			noti.Notification_Date__c = System.today();
			notifications.add(noti);
		}
		
		Test.startTest();
		
		List<Messaging.SingleEmailMessage> sentEmails = insertNotificationsByHandler(notifications);
		Integer emailInvocations = Limits.getEmailInvocations();

		Test.stopTest();

		System.assertEquals(1, emailInvocations);
		System.assertEquals(BATCH_NUM, sentEmails.size());
		for (Integer i = 0; i < BATCH_NUM; i++) {
			System.assertEquals(contactRoleDetail.Account_Contact_Role__r.Contact__c, sentEmails.get(i).getTargetObjectId());
			System.assertEquals('New notification: Example notification', sentEmails.get(i).getSubject());
			System.assertEquals('You have received a new notification\n\nThis is an example notification', sentEmails.get(i).getPlainTextBody());    
		}
	}

	@isTest 
	private static void testSendRegularNotificationWithTemplateBatch() {
		IGOM_Contact_Role_Detail__c contactRoleDetail = 
			[SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c 
			 FROM IGOM_Contact_Role_Detail__c 
			 WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = :TEST_NAME 
				   AND Role__c = :IGOMConstants.ROLES.ADMIN
			 LIMIT 1];

		EmailTemplate emailTemplate = new EmailTemplate(
			IsActive = true,
			Name = 'IGOM Notification - Example notification',
			DeveloperName = 'IGOM_Notification_Example_Notification', 
			FolderId = UserInfo.getUserId(), 
			TemplateType = 'custom', 
			Subject = EX_SUBJ,
			Body = EX_BODY,
			HtmlValue = EX_HTML_BODY
		);
		System.runAs(new User(Id=UserInfo.getUserId())) {
			insert emailTemplate;
		}

		// Generate notification
		List<IGOM_Contact_Role_Procedure_Compliance__c> notifications = new List<IGOM_Contact_Role_Procedure_Compliance__c>();
		for (Integer i = 0; i < BATCH_NUM; i++) {
			IGOM_Contact_Role_Procedure_Compliance__c noti = IGOMTestFactory.createIGOMContactRoleProcedureCompliance(contactRoleDetail.Id, null);
			noti.Notification_Subject__c = NOTIF_SUBJ;
			noti.Notification_Body__c = NOTIF_BODY;
			noti.Notification_Date__c = System.today();
			notifications.add(noti);
		}
		
		Test.startTest();
		
		List<Messaging.SingleEmailMessage> sentEmails = insertNotificationsByHandler(notifications);
		Integer emailInvocations = Limits.getEmailInvocations();

		Test.stopTest();

		System.assertEquals(1, emailInvocations);
		System.assertEquals(BATCH_NUM, sentEmails.size());
		for (Integer i = 0; i < BATCH_NUM; i++) {
			System.assertEquals(contactRoleDetail.Account_Contact_Role__r.Contact__c, sentEmails.get(1).getTargetObjectId());        
			System.assertEquals(emailTemplate.Id, sentEmails.get(1).getTemplateId());        
			System.assertEquals(emailTemplate.Name, sentEmails.get(1).getTemplateName());        
			System.assertEquals(EX_SUBJ, sentEmails.get(1).getSubject());
			System.assertEquals(EX_BODY, sentEmails.get(1).getPlainTextBody());
			System.assertEquals(EX_HTML_BODY, sentEmails.get(1).getHtmlBody());
		}
	}

	@isTest 
	private static void testSendIGOMVariationNotificationMultipleBatch() {
		IGOM_Contact_Role_Detail__c contactRoleDetail = 
			[SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c 
			 FROM IGOM_Contact_Role_Detail__c 
			 WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = :TEST_NAME 
				   AND Role__c = :IGOMConstants.ROLES.ADMIN
			 LIMIT 1];

		Id complianceReview1Id = [SELECT Id FROM Compliance_Review__c WHERE Title__c = 'Compliance Review 1'].Id;

		Map<String, Id> complianceReviewPartNameToId = new Map<String, Id>();
		for (Compliance_Review_Part__c complianceReviewPart : [SELECT Id, Standard_Document_Part__r.Name__c FROM Compliance_Review_Part__c WHERE Compliance_Review__c = :complianceReview1Id]) {
			complianceReviewPartNameToId.put(complianceReviewPart.Standard_Document_Part__r.Name__c, complianceReviewPart.Id);
		}

		// Generate notifications
		List<IGOM_Contact_Role_Procedure_Compliance__c> notifications = new List<IGOM_Contact_Role_Procedure_Compliance__c>();
		for (Integer i = 0; i < BATCH_NUM; i++) {
			IGOM_Contact_Role_Procedure_Compliance__c noti = IGOMTestFactory.createIGOMContactRoleProcedureCompliance(contactRoleDetail.Id, complianceReviewPartNameToId.get(SECTION_PROC));
			noti.Notification_Subject__c = IGOMConstants.METADATA.NOTIFICATION_NEW_GAP_SUBJECT;
			noti.Notification_Body__c = IGOMConstants.METADATA.NOTIFICATION_NEW_GAP_BODY;
			noti.Notification_Date__c = System.today();
			IGOM_Contact_Role_Procedure_Compliance__c noti2 = IGOMTestFactory.createIGOMContactRoleProcedureCompliance(contactRoleDetail.Id, complianceReviewPartNameToId.get('Section 2 Procedure 1'));
			noti2.Notification_Subject__c = IGOMConstants.METADATA.NOTIFICATION_NEW_GAP_SUBJECT;
			noti2.Notification_Body__c = IGOMConstants.METADATA.NOTIFICATION_NEW_GAP_BODY;
			noti2.Notification_Date__c = System.today();
			notifications.addAll(new List<IGOM_Contact_Role_Procedure_Compliance__c>{ noti, noti2 });
		}


		Test.startTest();
		
		List<Messaging.SingleEmailMessage> sentEmails = insertNotificationsByHandler(notifications);
		Integer emailInvocations = Limits.getEmailInvocations();

		Test.stopTest();

		EmailTemplate gapEmailTemplate = [SELECT Id, Name, DeveloperName, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = :IGOMConstants.GLOBALS.EMAIL_TEMPLATE_GAP_ANALYSIS];

		System.assertEquals(1, emailInvocations);
		System.assertEquals(1, sentEmails.size());

		String emailNotifiesText = '- Section 1 Procedure 1: Varies GOM Ed.1.0 V.0.0 R.Test revision 0 - Test provision procedure text\n- Section 2 Procedure 1: Varies GOM Ed.1.0 V.0.0 R.Test revision 0 - Test provision procedure text\n'.repeat(BATCH_NUM).removeEnd('\n');
		String emailNotifiesHtml = '- Section 1 Procedure 1: Varies GOM Ed.1.0 V.0.0 R.Test revision 0 - Test provision procedure text<br/>- Section 2 Procedure 1: Varies GOM Ed.1.0 V.0.0 R.Test revision 0 - Test provision procedure text<br/>'.repeat(BATCH_NUM).removeEnd('<br/>');
		//for (var )
		System.assertEquals(contactRoleDetail.Account_Contact_Role__r.Contact__c, sentEmails.get(0).getTargetObjectId());
		System.assertEquals(gapEmailTemplate.Subject, sentEmails.get(0).getSubject());
		final String textResult = gapEmailTemplate.Body.replace('{!Notifications}', emailNotifiesText).replace('{!StationName}', TEST_NAME).remove('{!ConfirmationText}');
		System.assertEquals(textResult, sentEmails.get(0).getPlainTextBody());
		final String htmlResult = gapEmailTemplate.HtmlValue.replace('{!Notifications}', emailNotifiesHtml).replace('{!StationName}', TEST_NAME).remove('{!ConfirmationText}');
		System.assertEquals(htmlResult, sentEmails.get(0).getHtmlBody());
	}

}