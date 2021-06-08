@isTest
private class IGOMNotificationUtilTest {

	private static final String SUBJECT = 'Test subject';
	private static final String BODY = 'Test body';
	public static final String UNEXP_EXC_CAUGHT = 'Unexpected exception caught ';
	public static final String IGOM_ADMIN = 'IGOM Admin';
	public static final String ACTION_REQ = 'ACTION REQUIRED';
	public static final String TEST_NAME = 'Test name 0';

	@TestSetup
	static void makeData() {
		// Generate stations
		List<List<SObject>> objectsStations = IGOMTestFactory.generateIGOMUserFactory(5, IGOMConstants.ROLES.ADMIN, IGOMConstants.STATION.TYPE.GROUND_HANDLER_HQ);
		List<SObject> objectsStation1 = objectsStations.get(0);
		List<SObject> objectsStation2 = objectsStations.get(1);
		List<SObject> objectsStation3 = objectsStations.get(2);
		List<SObject> objectsStation4 = objectsStations.get(3);
		List<SObject> objectsStation5 = objectsStations.get(4);
		// Make some stations be airlines (parents) and the rest stay as ground handlers
		IGOM_Account_Role_Detail__c station1 = (IGOM_Account_Role_Detail__c) objectsStation1.get(5);
		IGOM_Account_Role_Detail__c station2 = (IGOM_Account_Role_Detail__c) objectsStation2.get(5);
		station2.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('IGOM_Account_Role_Detail__c', IGOMConstants.STATION.TYPE.AIRLINE);
		IGOM_Account_Role_Detail__c station3 = (IGOM_Account_Role_Detail__c) objectsStation3.get(5);
		station3.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('IGOM_Account_Role_Detail__c', IGOMConstants.STATION.TYPE.AIRLINE);
		IGOM_Account_Role_Detail__c station4 = (IGOM_Account_Role_Detail__c) objectsStation4.get(5);
		IGOM_Account_Role_Detail__c station5 = (IGOM_Account_Role_Detail__c) objectsStation5.get(5);
		update new List<IGOM_Account_Role_Detail__c>{ station2, station3 };
		IGOM_Contact_Role_Detail__c contactRoleDetail1 = (IGOM_Contact_Role_Detail__c) objectsStation1.get(6);
		IGOM_Contact_Role_Detail__c contactRoleDetail2 = (IGOM_Contact_Role_Detail__c) objectsStation2.get(6);
		Account station1Account = (Account) objectsStation1.get(0);
		Account station2Account = (Account) objectsStation2.get(0);
		Account_Role__c station1AccountRole = (Account_Role__c) objectsStation1.get(3);
		Account_Role__c station2AccountRole = (Account_Role__c) objectsStation2.get(3);
		// Create relationship hierarchy
		//      station2   station3
		//         ^          ^
		//         |----------|
		//         |
		//      station1  <--- group ---> station5
		//         ^
		//         |
		//         |
		//      station4
		IGOM_Account_Role_Relationship__c toParent1 = IGOMTestFactory.createIGOMAccountRoleRelationship(station1.Id, station2.Id, station1.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.HIERARCHICAL_REL, IGOMConstants.STATION.STATUS.ACTIVE);
		IGOM_Account_Role_Relationship__c toParent2 = IGOMTestFactory.createIGOMAccountRoleRelationship(station1.Id, station3.Id, station1.Id, false, IGOMConstants.STATION.RELATIONSHIP_TYPE.HIERARCHICAL_REL, IGOMConstants.STATION.STATUS.ACTIVE);
		IGOM_Account_Role_Relationship__c toChild = IGOMTestFactory.createIGOMAccountRoleRelationship(station4.Id, station1.Id, station1.Id, false, IGOMConstants.STATION.RELATIONSHIP_TYPE.HIERARCHICAL_REL, IGOMConstants.STATION.STATUS.ACTIVE);
		IGOM_Account_Role_Relationship__c groupal = IGOMTestFactory.createIGOMAccountRoleRelationship(station1.Id, station5.Id, station1.Id, false, IGOMConstants.STATION.RELATIONSHIP_TYPE.GROUP_REL, IGOMConstants.STATION.STATUS.ACTIVE);
		insert new List<IGOM_Account_Role_Relationship__c>{ toParent1, toParent2, toChild, groupal };
		// Add a contact with a different role in the parent station and second station
		Contact newContact1 = IGOMTestFactory.contactFactoryCreation(1, station1Account.Id).get(0);
		Contact newContact2 = IGOMTestFactory.contactFactoryCreation(1, station2Account.Id).get(0);
		insert new List<Contact>{ newContact1, newContact2 };
		Account_Contact_Role__c accountContactRole1 = IGOMTestFactory.createAccountContactRole(station1Account.Id, newContact1.Id, station1AccountRole.Id);
		Account_Contact_Role__c accountContactRole2 = IGOMTestFactory.createAccountContactRole(station2Account.Id, newContact2.Id, station2AccountRole.Id);
		insert new List<Account_Contact_Role__c>{ accountContactRole1, accountContactRole2 };
		IGOM_Contact_Role_Detail__c contactRoleDetailViewer1 = IGOMTestFactory.createIGOMContactRoleDetail(accountContactRole1.Id, station1.Id, IGOMConstants.ROLES.ACKNOWLEDGER);
		IGOM_Contact_Role_Detail__c contactRoleDetailViewer2 = IGOMTestFactory.createIGOMContactRoleDetail(accountContactRole2.Id, station2.Id, IGOMConstants.ROLES.ACKNOWLEDGER);
		insert new List<IGOM_Contact_Role_Detail__c>{ contactRoleDetailViewer1, contactRoleDetailViewer2 };
		// Generate an IGOM and a GOM
		Document__c igomDocument = IGOMTestFactory.documentFactoryCreation(1, null, 'IGOM Document', 'English', IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM)[0];
		Document__c gomDocument = IGOMTestFactory.documentFactoryCreation(1, null, 'GOM Document', 'English', IGOMConstants.DOCUMENT.RECORD_TYPE.GOM)[0];
		insert new List<Document__c>{ igomDocument, gomDocument };
		// Generate IGOM parts
		Document_Part__c chapter1 = IGOMTestFactory.createDocumentPart(IGOMConstants.DOCUMENT_PART.CATEGORY.PART, igomDocument.Id, 1, 'Part 1');
		Document_Part__c chapter2 = IGOMTestFactory.createDocumentPart(IGOMConstants.DOCUMENT_PART.CATEGORY.PART, igomDocument.Id, 2, 'Part 2');
		Document_Part__c section1 = IGOMTestFactory.createDocumentPart(IGOMConstants.DOCUMENT_PART.CATEGORY.CHAPTER, igomDocument.Id, 1, 'Chapter 1');
		Document_Part__c section2 = IGOMTestFactory.createDocumentPart(IGOMConstants.DOCUMENT_PART.CATEGORY.CHAPTER, igomDocument.Id, 1, 'Chapter 2');
		Document_Part__c subchapter1 = IGOMTestFactory.createDocumentPart(IGOMConstants.DOCUMENT_PART.CATEGORY.SECTION, igomDocument.Id, 1, 'Section 1 Procedure 1');
		Document_Part__c subchapter2 = IGOMTestFactory.createDocumentPart(IGOMConstants.DOCUMENT_PART.CATEGORY.SECTION, igomDocument.Id, 1, 'Section 1 Procedure 2');
		Document_Part__c subchapter3 = IGOMTestFactory.createDocumentPart(IGOMConstants.DOCUMENT_PART.CATEGORY.SECTION, igomDocument.Id, 1, 'Section 2 Procedure 1');
		insert new List<Document_Part__c>{ chapter1, chapter2, section1, section2, subchapter1, subchapter2, subchapter3 };
		subchapter3.Parent__c = section2.Id;
		subchapter2.Parent__c = section1.Id;
		subchapter1.Parent__c = section1.Id;
		section2.Parent__c = chapter1.Id;
		section1.Parent__c = chapter1.Id;
		update new List<Document_Part__c>{  section1, section2, subchapter1, subchapter2, subchapter3 };
		// Generate compliance reviews
		Compliance_Review__c complianceReview1 = IGOMTestFactory.createComplianceReview(igomDocument.Id, station1.Account_Role__c, 'Compliance Review 1');
		Compliance_Review__c complianceReview2 = IGOMTestFactory.createComplianceReview(igomDocument.Id, station1.Account_Role__c, 'Compliance Review 2');
		complianceReview1.Publish_Status__c = IGOMConstants.COMPLIANCE_REVIEW.STATUS.PUBLISHED;
		complianceReview2.Publish_Status__c = IGOMConstants.COMPLIANCE_REVIEW.STATUS.PUBLISHED;
		List<Compliance_Review__c> complianceReviews = new List<Compliance_Review__c>{ complianceReview1, complianceReview2 };
		insert complianceReviews;
		// Generate some compliance review parts
		List<Compliance_Review_Part__c> complianceReviewParts = new List<Compliance_Review_Part__c>();
		for (Integer complianceIndex = 0; complianceIndex <= 1; complianceIndex++) {
			Id complianceReviewId = complianceReviews.get(complianceIndex).Id;
			Compliance_Review_Part__c complianceReviewPart1 = IGOMTestFactory.createComplianceReviewPart(complianceReviewId, subchapter1.Id, gomDocument.Id);
			complianceReviewPart1.Status__c = IGOMConstants.PROCEDURE_COMPLIANCE.STATUS.VARIATION;
			complianceReviewParts.add(complianceReviewPart1);
			Compliance_Review_Part__c complianceReviewPart2 = IGOMTestFactory.createComplianceReviewPart(complianceReviewId, subchapter2.Id, gomDocument.Id);
			complianceReviewParts.add(complianceReviewPart2);
			Compliance_Review_Part__c complianceReviewPart3 = IGOMTestFactory.createComplianceReviewPart(complianceReviewId, subchapter3.Id, gomDocument.Id);
			complianceReviewPart3.Status__c = IGOMConstants.PROCEDURE_COMPLIANCE.STATUS.VARIATION;
			complianceReviewParts.add(complianceReviewPart3);
		}
		insert complianceReviewParts;
		// Generate notifications
		IGOM_Contact_Role_Procedure_Compliance__c noti11 = IGOMTestFactory.createIGOMContactRoleProcedureCompliance(contactRoleDetail1.Id, complianceReviewParts.get(0).Id);
		noti11.Notification_Subject__c = 'Subject Noti11';
		noti11.Notification_Body__c = 'Body Noti11';
		noti11.Notification_Date__c = Date.today().addDays(-1);
		noti11.Notification_Status__c = IGOMConstants.NOTIFICATION.STATUS.ACKNOWLEDGED;
		IGOM_Contact_Role_Procedure_Compliance__c noti12 = IGOMTestFactory.createIGOMContactRoleProcedureCompliance(contactRoleDetail1.Id, complianceReviewParts.get(2).Id);
		noti12.Notification_Subject__c = 'Subject Noti12';
		noti12.Notification_Body__c = 'Body Noti12';
		noti12.Notification_Date__c = Date.today().addDays(-2);
		IGOM_Contact_Role_Procedure_Compliance__c noti21 = IGOMTestFactory.createIGOMContactRoleProcedureCompliance(contactRoleDetail2.Id, complianceReviewParts.get(0).Id);
		IGOM_Contact_Role_Procedure_Compliance__c noti22 = IGOMTestFactory.createIGOMContactRoleProcedureCompliance(contactRoleDetail2.Id, complianceReviewParts.get(2).Id);
		insert new List<IGOM_Contact_Role_Procedure_Compliance__c>{ noti11, noti12, noti21, noti22 };
	}

	@isTest 
	private static void testMarkAsReadOk() {
		IGOM_Contact_Role_Detail__c contactRole = [SELECT Id, Role__c, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRole.Account_Contact_Role__r.Contact__c];

		List<IGOM_Contact_Role_Procedure_Compliance__c> unreadNotifications = [SELECT Id FROM IGOM_Contact_Role_Procedure_Compliance__c WHERE Notification_Status__c = :IGOMConstants.NOTIFICATION.STATUS.UNREAD];
		System.assertEquals(3, unreadNotifications.size());
		
		Id notificationId = unreadNotifications.get(0).Id;

		Test.startTest();

		System.runAs(contactUser) {
			IGOMNotificationUtil.markAsRead(notificationId);
		}

		Test.stopTest();
   
		System.assertEquals(2, [SELECT Id FROM IGOM_Contact_Role_Procedure_Compliance__c WHERE Notification_Status__c = :IGOMConstants.NOTIFICATION.STATUS.UNREAD].size());
		System.assertEquals(2, [SELECT Id FROM IGOM_Contact_Role_Procedure_Compliance__c WHERE Notification_Status__c = :IGOMConstants.NOTIFICATION.STATUS.ACKNOWLEDGED].size());
		System.assertEquals(IGOMConstants.NOTIFICATION.STATUS.ACKNOWLEDGED, [SELECT Notification_Status__c FROM IGOM_Contact_Role_Procedure_Compliance__c WHERE Id = :notificationId].Notification_Status__c);
	}

	@isTest 
	private static void testMarkAsReadNull() {
		IGOM_Contact_Role_Detail__c contactRole = [SELECT Id, Role__c, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRole.Account_Contact_Role__r.Contact__c];

		System.assertEquals(3, [SELECT Id FROM IGOM_Contact_Role_Procedure_Compliance__c WHERE Notification_Status__c = :IGOMConstants.NOTIFICATION.STATUS.UNREAD].size());
		
		Test.startTest();

		System.runAs(contactUser) {
			try {
				IGOMNotificationUtil.markAsRead(null);
			} catch (AuraHandledException error) {
				System.assert(true);
			} catch (Exception error) {
				System.assert(false, UNEXP_EXC_CAUGHT + error);
			}
		}

		Test.stopTest();
   
		System.assertEquals(3, [SELECT Id FROM IGOM_Contact_Role_Procedure_Compliance__c WHERE Notification_Status__c = :IGOMConstants.NOTIFICATION.STATUS.UNREAD].size());
	}

	@isTest 
	private static void testMarkAsReadInvalidId() {
		IGOM_Contact_Role_Detail__c contactRole = [SELECT Id, Role__c, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRole.Account_Contact_Role__r.Contact__c];

		System.assertEquals(3, [SELECT Id FROM IGOM_Contact_Role_Procedure_Compliance__c WHERE Notification_Status__c = :IGOMConstants.NOTIFICATION.STATUS.UNREAD].size());
		
		Id accountId = [SELECT Id FROM Account LIMIT 1].Id;

		Test.startTest();

		System.runAs(contactUser) {
			try {
				IGOMNotificationUtil.markAsRead(accountId);
			} catch (AuraHandledException error) {
				System.assert(true);
			} catch (Exception error) {
				System.assert(false, UNEXP_EXC_CAUGHT + error);
			}
		}

		Test.stopTest();
   
		System.assertEquals(3, [SELECT Id FROM IGOM_Contact_Role_Procedure_Compliance__c WHERE Notification_Status__c = :IGOMConstants.NOTIFICATION.STATUS.UNREAD].size());
	}

	@isTest 
	private static void testMarkAsReadOtherUser() {
		IGOM_Contact_Role_Detail__c contactRole = [SELECT Id, Role__c, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRole.Account_Contact_Role__r.Contact__c];

		System.assertEquals(3, [SELECT Id FROM IGOM_Contact_Role_Procedure_Compliance__c WHERE Notification_Status__c = :IGOMConstants.NOTIFICATION.STATUS.UNREAD].size());
		Id notificationId = [SELECT Id FROM IGOM_Contact_Role_Procedure_Compliance__c WHERE IGOM_Contact_Role_Detail__c != :contactRole.Id LIMIT 1].Id;
		
		Test.startTest();

		System.runAs(contactUser) {
			try {
				IGOMNotificationUtil.markAsRead(notificationId);
			} catch (AuraHandledException error) {
				System.assert(true);
			} catch (Exception error) {
				System.assert(false, UNEXP_EXC_CAUGHT + error);
			}
		}

		Test.stopTest();
   
		System.assertEquals(3, [SELECT Id FROM IGOM_Contact_Role_Procedure_Compliance__c WHERE Notification_Status__c = :IGOMConstants.NOTIFICATION.STATUS.UNREAD].size());
	}

	@isTest 
	private static void testGetNotificationsOk() {
		IGOM_Contact_Role_Detail__c contactRole = [SELECT Id, Role__c, Account_Contact_Role__r.Contact__c, Account_Contact_Role__r.Contact__r.Email, Account_Contact_Role__r.Contact__r.Name FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRole.Account_Contact_Role__r.Contact__c];

		Test.startTest();

		List<IGOMNotificationUtil.Notification> notifications;
		System.runAs(contactUser) {
			notifications = IGOMNotificationUtil.getNotifications();
		}

		Test.stopTest();

		Compliance_Review__c complianceReview1 = [SELECT Id FROM Compliance_Review__c WHERE Title__c = 'Compliance Review 1'];

		Map<String, Id> complianceReviewPartDocPartNameToId = new Map<String, Id>();
		for (Compliance_Review_Part__c complianceReviewPart : [SELECT Id, Standard_Document_Part__r.Name__c FROM Compliance_Review_Part__c WHERE Compliance_Review__c = :complianceReview1.Id]) {
			complianceReviewPartDocPartNameToId.put(complianceReviewPart.Standard_Document_Part__r.Name__c, complianceReviewPart.Id);
		}

		System.assertEquals(2, notifications.size());
		Map<Id, IGOMNotificationUtil.Notification> complianceReviewPartIdToNotification = new Map<Id, IGOMNotificationUtil.Notification>();
		for (IGOMNotificationUtil.Notification notification : notifications) {
			complianceReviewPartIdToNotification.put(notification.procedureComplianceId, notification);
		}

		final IGOMNotificationUtil.Notification firstNotification = complianceReviewPartIdToNotification.get(complianceReviewPartDocPartNameToId.get('Section 1 Procedure 1'));
		System.assertEquals(true, firstNotification.acknowledged);
		System.assertEquals(contactRole.Id, firstNotification.contactRoleDetailId);
		System.assertEquals('Body Noti11', firstNotification.notificationBody);
		System.assertEquals('Subject Noti11', firstNotification.notificationSubject);
		System.assertEquals(Date.today().addDays(-1), firstNotification.notificationDate);
		System.assertEquals(contactRole.Account_Contact_Role__r.Contact__r.Email, firstNotification.userEmail);
		System.assertEquals(contactRole.Account_Contact_Role__r.Contact__r.Name, firstNotification.userName);
		final IGOMNotificationUtil.Notification secondNotification = complianceReviewPartIdToNotification.get(complianceReviewPartDocPartNameToId.get('Section 2 Procedure 1'));
		System.assertEquals(false, secondNotification.acknowledged);
		System.assertEquals(contactRole.Id, secondNotification.contactRoleDetailId);
		System.assertEquals('Body Noti12', secondNotification.notificationBody);
		System.assertEquals('Subject Noti12', secondNotification.notificationSubject);
		System.assertEquals(Date.today().addDays(-2), secondNotification.notificationDate);
		System.assertEquals(contactRole.Account_Contact_Role__r.Contact__r.Email, secondNotification.userEmail);
		System.assertEquals(contactRole.Account_Contact_Role__r.Contact__r.Name, secondNotification.userName);
	}

	@isTest 
	private static void testGetNotificationsUnauthorized() {
		// Remove role
		IGOM_Contact_Role_Detail__c contactRole = [SELECT Id, Role__c, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		contactRole.Role__c = null;
		update contactRole;
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRole.Account_Contact_Role__r.Contact__c];

		Test.startTest();

		System.runAs(contactUser) {
			try {
				IGOMNotificationUtil.getNotifications();
			} catch (AuraHandledException error) {
				System.assert(true);
			} catch (Exception error) {
				System.assert(false, UNEXP_EXC_CAUGHT + error);
			}
		}

		Test.stopTest();
	}

	@isTest 
	private static void testSendGapNotificationsOk() {
		IGOM_Contact_Role_Detail__c contactRoleDetail = 
			[SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c 
			 FROM IGOM_Contact_Role_Detail__c 
			 WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = :TEST_NAME 
				   AND Role__c = :IGOMConstants.ROLES.ADMIN
			 LIMIT 1];
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c];
		
		Compliance_Review__c complianceReview2 = [SELECT Id FROM Compliance_Review__c WHERE Title__c = 'Compliance Review 2'];

		IGOM_Contact_Role_Detail__c sameStationAcknowledgerContactRoleDetail = 
		[SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c 
		 FROM IGOM_Contact_Role_Detail__c 
		 WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = :TEST_NAME 
			   AND Role__c = :IGOMConstants.ROLES.ACKNOWLEDGER
		 LIMIT 1];
		IGOM_Contact_Role_Detail__c parentStationContactRoleDetail = 
		[SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c 
		 FROM IGOM_Contact_Role_Detail__c 
		 WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = 'Test name 1' 
			   AND Role__c = :IGOMConstants.ROLES.ADMIN
		 LIMIT 1];

		System.assertEquals(0, [SELECT Id FROM IGOM_Contact_Role_Procedure_Compliance__c WHERE Notification_Subject__c = :IGOMConstants.METADATA.NOTIFICATION_NEW_GAP_SUBJECT].size());

		Map<String, List<Id>> notificationContactsPerType = new Map<String, List<Id>>();
		notificationContactsPerType.put(IGOMConstants.NOTIFICATION.SEVERITY.ACTION_REQUIRED, new List<Id>{contactRoleDetail.Account_Contact_Role__r.Contact__c, sameStationAcknowledgerContactRoleDetail.Account_Contact_Role__r.Contact__c});
		notificationContactsPerType.put(IGOMConstants.NOTIFICATION.SEVERITY.INFORMATIVE, new List<Id>{parentStationContactRoleDetail.Account_Contact_Role__r.Contact__c});

		Test.startTest();

		System.runAs(contactUser) {
			IGOMNotificationUtil.sendGAPNotifications(complianceReview2.Id, notificationContactsPerType);
		}

		Test.stopTest();

		List<IGOM_Contact_Role_Procedure_Compliance__c> gapNotifications =
			[SELECT IGOM_Contact_Role_Detail__c, Notification_Body__c, Compliance_Review_Part__r.Compliance_Review__c, Compliance_Review_Part__r.Document__c, Compliance_Review_Part__r.Standard_Document_Part__c
			 FROM IGOM_Contact_Role_Procedure_Compliance__c 
			 WHERE Notification_Subject__c = :IGOMConstants.METADATA.NOTIFICATION_NEW_GAP_SUBJECT];
		System.assertEquals(6, gapNotifications.size());

		Map<Id, List<IGOM_Contact_Role_Procedure_Compliance__c>> contactRoleIdToNotifications = new Map<Id, List<IGOM_Contact_Role_Procedure_Compliance__c>>();
		for (IGOM_Contact_Role_Procedure_Compliance__c notification : gapNotifications) {
			List<IGOM_Contact_Role_Procedure_Compliance__c> notifications = contactRoleIdToNotifications.get(notification.IGOM_Contact_Role_Detail__c);
			if (notifications == null) {
				notifications = new List<IGOM_Contact_Role_Procedure_Compliance__c>();
				contactRoleIdToNotifications.put(notification.IGOM_Contact_Role_Detail__c, notifications);
			}
			notifications.add(notification);
			System.assertEquals(IGOMConstants.METADATA.NOTIFICATION_NEW_GAP_BODY, notification.Notification_Body__c);
		}

		Document__c gomDocument = [SELECT Id FROM Document__c WHERE RecordType.DeveloperName = :IGOMConstants.DOCUMENT.RECORD_TYPE.GOM LIMIT 1];

		Document_Part__c documentPart1 = [SELECT Id FROM Document_Part__c WHERE Name__c = 'Section 1 Procedure 1'];
		Document_Part__c documentPart2 = [SELECT Id FROM Document_Part__c WHERE Name__c = 'Section 2 Procedure 1'];
		
		Set<Id> documentParts = new Set<Id>();

		System.assertEquals(2, contactRoleIdToNotifications.get(contactRoleDetail.Id).size());
		documentParts.clear();
		for (IGOM_Contact_Role_Procedure_Compliance__c notification : contactRoleIdToNotifications.get(contactRoleDetail.Id)) {
			System.assertEquals(complianceReview2.Id, notification.Compliance_Review_Part__r.Compliance_Review__c);
			System.assertEquals(gomDocument.Id, notification.Compliance_Review_Part__r.Document__c);
			documentParts.add(notification.Compliance_Review_Part__r.Standard_Document_Part__c);
		}
		System.assert(documentParts.containsAll(new Set<Id>{ documentPart1.Id, documentPart2.Id }));

		System.assertEquals(2, contactRoleIdToNotifications.get(sameStationAcknowledgerContactRoleDetail.Id).size());
		documentParts.clear();
		for (IGOM_Contact_Role_Procedure_Compliance__c notification : contactRoleIdToNotifications.get(contactRoleDetail.Id)) {
			System.assertEquals(complianceReview2.Id, notification.Compliance_Review_Part__r.Compliance_Review__c);
			System.assertEquals(gomDocument.Id, notification.Compliance_Review_Part__r.Document__c);
			documentParts.add(notification.Compliance_Review_Part__r.Standard_Document_Part__c);
		}
		System.assert(documentParts.containsAll(new Set<Id>{ documentPart1.Id, documentPart2.Id }));

		System.assertEquals(2, contactRoleIdToNotifications.get(parentStationContactRoleDetail.Id).size());
		documentParts.clear();
		for (IGOM_Contact_Role_Procedure_Compliance__c notification : contactRoleIdToNotifications.get(contactRoleDetail.Id)) {
			System.assertEquals(complianceReview2.Id, notification.Compliance_Review_Part__r.Compliance_Review__c);
			System.assertEquals(gomDocument.Id, notification.Compliance_Review_Part__r.Document__c);
			documentParts.add(notification.Compliance_Review_Part__r.Standard_Document_Part__c);
		}
		System.assert(documentParts.containsAll(new Set<Id>{ documentPart1.Id, documentPart2.Id }));
	}

	@isTest 
	private static void testSendGapNotificationsUnnotifiableParentNonAdmin() {
		IGOM_Contact_Role_Detail__c contactRoleDetail = 
			[SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c 
			 FROM IGOM_Contact_Role_Detail__c 
			 WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = :TEST_NAME 
				   AND Role__c = :IGOMConstants.ROLES.ADMIN
			 LIMIT 1];
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c];
		
		Compliance_Review__c complianceReview2 = [SELECT Id FROM Compliance_Review__c WHERE Title__c = 'Compliance Review 2'];

		IGOM_Contact_Role_Detail__c parentStationNonAdminContactRoleDetail = 
		[SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c 
		 FROM IGOM_Contact_Role_Detail__c 
		 WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = 'Test name 1' 
			   AND Role__c = :IGOMConstants.ROLES.ACKNOWLEDGER
		 LIMIT 1];

		Test.startTest();

		Map<String, List<Id>> notifContacts = new Map<String, List<Id>>();
		notifContacts.put(IGOMConstants.NOTIFICATION.SEVERITY.INFORMATIVE, new List<Id>{ parentStationNonAdminContactRoleDetail.Account_Contact_Role__r.Contact__c});
		System.runAs(contactUser) {
			try {
				IGOMNotificationUtil.sendGAPNotifications(complianceReview2.Id, notifContacts);
			} catch (AuraHandledException error) {
				System.assert(true);
			} catch (Exception error) {
				System.assert(false, UNEXP_EXC_CAUGHT + error);
			}
		}

		Test.stopTest();
	}

	@isTest 
	private static void testSendGapNotificationsUnnotifiableByChoiceParentAdmin() {
		IGOM_Contact_Role_Detail__c contactRoleDetail = 
			[SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c 
			 FROM IGOM_Contact_Role_Detail__c 
			 WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = :TEST_NAME 
				   AND Role__c = :IGOMConstants.ROLES.ADMIN
			 LIMIT 1];
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c];
		
		Compliance_Review__c complianceReview2 = [SELECT Id FROM Compliance_Review__c WHERE Title__c = 'Compliance Review 2'];

		IGOM_Contact_Role_Detail__c parentStationAdminContactRoleDetail = 
		[SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c 
		 FROM IGOM_Contact_Role_Detail__c 
		 WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = 'Test name 2' 
			   AND Role__c = :IGOMConstants.ROLES.ADMIN
		 LIMIT 1];

		Test.startTest();

		System.runAs(contactUser) {
			Map<String, List<Id>> notifContacts = new Map<String, List<Id>>();
			notifContacts.put(IGOMConstants.NOTIFICATION.SEVERITY.INFORMATIVE, new List<Id>{ parentStationAdminContactRoleDetail.Account_Contact_Role__r.Contact__c});
			try {
				IGOMNotificationUtil.sendGAPNotifications(complianceReview2.Id, notifContacts);
			} catch (AuraHandledException error) {
				System.assert(true);
			} catch (Exception error) {
				System.assert(false, UNEXP_EXC_CAUGHT + error);
			}
		}

		Test.stopTest();
	}

	@isTest 
	private static void testSendGapNotificationsUnnotifiableChildren() {
		IGOM_Contact_Role_Detail__c contactRoleDetail = 
			[SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c 
			 FROM IGOM_Contact_Role_Detail__c 
			 WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = :TEST_NAME 
				   AND Role__c = :IGOMConstants.ROLES.ADMIN
			 LIMIT 1];
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c];
		
		Compliance_Review__c complianceReview2 = [SELECT Id FROM Compliance_Review__c WHERE Title__c = 'Compliance Review 2'];

		IGOM_Contact_Role_Detail__c parentStationAdminContactRoleDetail = 
		[SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c 
		 FROM IGOM_Contact_Role_Detail__c 
		 WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = 'Test name 3' 
			   AND Role__c = :IGOMConstants.ROLES.ADMIN
		 LIMIT 1];

		Test.startTest();

		System.runAs(contactUser) {
			Map<String, List<Id>> notifContacts = new Map<String, List<Id>>();
			notifContacts.put(IGOMConstants.NOTIFICATION.SEVERITY.INFORMATIVE, new List<Id>{ parentStationAdminContactRoleDetail.Account_Contact_Role__r.Contact__c});
			try {
				IGOMNotificationUtil.sendGAPNotifications(complianceReview2.Id, notifContacts);
			} catch (AuraHandledException error) {
				System.assert(true);
			} catch (Exception error) {
				System.assert(false, UNEXP_EXC_CAUGHT + error);
			}
		}

		Test.stopTest();
	}

	@isTest 
	private static void testSendGapNotificationsUnnotifiableGroup() {
		IGOM_Contact_Role_Detail__c contactRoleDetail = 
			[SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c 
			 FROM IGOM_Contact_Role_Detail__c 
			 WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = :TEST_NAME 
				   AND Role__c = :IGOMConstants.ROLES.ADMIN
			 LIMIT 1];
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c];
		
		Compliance_Review__c complianceReview2 = [SELECT Id FROM Compliance_Review__c WHERE Title__c = 'Compliance Review 2'];

		IGOM_Contact_Role_Detail__c parentStationAdminContactRoleDetail = 
		[SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c 
		 FROM IGOM_Contact_Role_Detail__c 
		 WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = 'Test name 4' 
			   AND Role__c = :IGOMConstants.ROLES.ADMIN
		 LIMIT 1];

		Test.startTest();

		System.runAs(contactUser) {
			Map<String, List<Id>> notifContacts = new Map<String, List<Id>>();
			notifContacts.put(IGOMConstants.NOTIFICATION.SEVERITY.INFORMATIVE, new List<Id>{ parentStationAdminContactRoleDetail.Account_Contact_Role__r.Contact__c});
			try {
				IGOMNotificationUtil.sendGAPNotifications(complianceReview2.Id, notifContacts);
			} catch (AuraHandledException error) {
				System.assert(true);
			} catch (Exception error) {
				System.assert(false, UNEXP_EXC_CAUGHT + error);
			}
		}

		Test.stopTest();
	}

	@isTest 
	private static void testSendIgomNotificationsOk() {
		Document__c igomDocument = [SELECT Id FROM Document__c WHERE RecordType.DeveloperName = :IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM LIMIT 1];

		System.assertEquals(4, [SELECT Id FROM IGOM_Contact_Role_Procedure_Compliance__c].size());
		System.assertEquals(0, [SELECT Id FROM IGOM_Contact_Role_Procedure_Compliance__c WHERE Notification_Subject__c = :IGOMConstants.METADATA.NOTIFICATION_NEW_IGOM_SUBJECT].size());

		Test.startTest();

		IGOMNotificationUtil.sendIGOMNotifications(igomDocument.Id);

		Test.stopTest();

		System.assertEquals(9, [SELECT Id FROM IGOM_Contact_Role_Procedure_Compliance__c].size());
		List<IGOM_Contact_Role_Procedure_Compliance__c> igomNotifications = [SELECT Notification_Body__c, IGOM_Contact_Role_Detail__r.Role__c FROM IGOM_Contact_Role_Procedure_Compliance__c WHERE Notification_Subject__c = :IGOMConstants.METADATA.NOTIFICATION_NEW_IGOM_SUBJECT];
		System.assertEquals(5, igomNotifications.size());
		final String todayString = String.valueOf(Date.today()) + ' 00:00:00';
		for (IGOM_Contact_Role_Procedure_Compliance__c notification : igomNotifications) {
			System.assertEquals(String.format(IGOMConstants.METADATA.NOTIFICATION_NEW_IGOM_BODY, new List<Object>{ 'IGOM Document', todayString }), notification.Notification_Body__c);
			System.assertEquals(IGOMConstants.ROLES.ADMIN, notification.IGOM_Contact_Role_Detail__r.Role__c);
		}
	}

	@isTest
	private static void testSendIgomNotificationsNull() {
		Integer previousNotifications = [SELECT Id FROM IGOM_Contact_Role_Procedure_Compliance__c].size();

		Test.startTest();

		try {
			IGOMNotificationUtil.sendIGOMNotifications(null);
		} catch (AuraHandledException error) {
			System.assert(true);
		} catch (Exception error) {
			System.assert(false, UNEXP_EXC_CAUGHT + error);
		}

		Test.stopTest();

		System.assertEquals(previousNotifications, [SELECT Id FROM IGOM_Contact_Role_Procedure_Compliance__c].size());
	}

	@isTest
	private static void testSendIgomNotificationsInvalidId() {
		Account account = [SELECT Id FROM Account LIMIT 1];

		Integer previousNotifications = [SELECT Id FROM IGOM_Contact_Role_Procedure_Compliance__c].size();

		Test.startTest();

		try {
			IGOMNotificationUtil.sendIGOMNotifications(account.Id);
		} catch (AuraHandledException error) {
			System.assert(true);
		} catch (Exception error) {
			System.assert(false, UNEXP_EXC_CAUGHT + error);
		}

		Test.stopTest();

		System.assertEquals(previousNotifications, [SELECT Id FROM IGOM_Contact_Role_Procedure_Compliance__c].size());
	}

	@isTest
	private static void testSendIgomNotificationsInvalidRecordtype() {
		Document__c gomDocument = [SELECT Id FROM Document__c WHERE RecordType.DeveloperName = :IGOMConstants.DOCUMENT.RECORD_TYPE.GOM LIMIT 1];

		Integer previousNotifications = [SELECT Id FROM IGOM_Contact_Role_Procedure_Compliance__c].size();

		Test.startTest();

		try {
			IGOMNotificationUtil.sendIGOMNotifications(gomDocument.Id);
		} catch (AuraHandledException error) {
			System.assert(true);
		} catch (Exception error) {
			System.assert(false, UNEXP_EXC_CAUGHT + error);
		}

		Test.stopTest();

		System.assertEquals(previousNotifications, [SELECT Id FROM IGOM_Contact_Role_Procedure_Compliance__c].size());
	}

	@isTest
	private static void testAcknowledgeGapNotificationsOk() {
		IGOM_Contact_Role_Detail__c contactRoleDetail = 
			[SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c 
			 FROM IGOM_Contact_Role_Detail__c 
			 WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = :TEST_NAME 
				   AND Role__c = :IGOMConstants.ROLES.ADMIN
			 LIMIT 1];
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c];
		
		Compliance_Review__c complianceReview1 = [SELECT Id FROM Compliance_Review__c WHERE Title__c = 'Compliance Review 1'];

		System.assertEquals(1, 
			[SELECT Id FROM IGOM_Contact_Role_Procedure_Compliance__c WHERE Compliance_Review_Part__r.Compliance_Review__c = :complianceReview1.Id
			   AND IGOM_Contact_Role_Detail__r.Account_Contact_Role__r.Contact__c = :contactRoleDetail.Account_Contact_Role__r.Contact__c
			   AND Notification_Status__c = :IGOMConstants.NOTIFICATION.STATUS.UNREAD].size());
		System.assertEquals(1, 
			[SELECT Id FROM IGOM_Contact_Role_Procedure_Compliance__c WHERE Compliance_Review_Part__r.Compliance_Review__c = :complianceReview1.Id
				AND IGOM_Contact_Role_Detail__r.Account_Contact_Role__r.Contact__c = :contactRoleDetail.Account_Contact_Role__r.Contact__c
				AND Notification_Status__c = :IGOMConstants.NOTIFICATION.STATUS.ACKNOWLEDGED].size());
		System.assertEquals(2, 
			[SELECT Id FROM IGOM_Contact_Role_Procedure_Compliance__c WHERE IGOM_Contact_Role_Detail__r.Account_Contact_Role__r.Contact__c != :contactRoleDetail.Account_Contact_Role__r.Contact__c
			   AND Notification_Status__c = :IGOMConstants.NOTIFICATION.STATUS.UNREAD].size());

		Test.startTest();

		System.runAs(contactUser) {
			IGOMNotificationUtil.acknowledgeGapNotifications(complianceReview1.Id);
		}

		Test.stopTest();

		System.assertEquals(0, 
			[SELECT Id FROM IGOM_Contact_Role_Procedure_Compliance__c WHERE Compliance_Review_Part__r.Compliance_Review__c = :complianceReview1.Id
			   AND IGOM_Contact_Role_Detail__r.Account_Contact_Role__r.Contact__c = :contactRoleDetail.Account_Contact_Role__r.Contact__c
			   AND Notification_Status__c = :IGOMConstants.NOTIFICATION.STATUS.UNREAD].size());
		System.assertEquals(2, 
			[SELECT Id FROM IGOM_Contact_Role_Procedure_Compliance__c WHERE Compliance_Review_Part__r.Compliance_Review__c = :complianceReview1.Id
				AND IGOM_Contact_Role_Detail__r.Account_Contact_Role__r.Contact__c = :contactRoleDetail.Account_Contact_Role__r.Contact__c
				AND Notification_Status__c = :IGOMConstants.NOTIFICATION.STATUS.ACKNOWLEDGED].size());
		System.assertEquals(2, 
			[SELECT Id FROM IGOM_Contact_Role_Procedure_Compliance__c WHERE IGOM_Contact_Role_Detail__r.Account_Contact_Role__r.Contact__c != :contactRoleDetail.Account_Contact_Role__r.Contact__c
			   AND Notification_Status__c = :IGOMConstants.NOTIFICATION.STATUS.UNREAD].size());
	}

	@isTest
	private static void testAcknowledgeGapNotificationsNull() {
		System.assertEquals(3, [SELECT Id FROM IGOM_Contact_Role_Procedure_Compliance__c WHERE Notification_Status__c = :IGOMConstants.NOTIFICATION.STATUS.UNREAD].size());

		Test.startTest();

		try {
			IGOMNotificationUtil.acknowledgeGapNotifications(null);
		} catch (AuraHandledException error) {
			System.assert(true);
		} catch (Exception error) {
			System.assert(false, UNEXP_EXC_CAUGHT + error);
		}

		Test.stopTest();

		System.assertEquals(3, [SELECT Id FROM IGOM_Contact_Role_Procedure_Compliance__c WHERE Notification_Status__c = :IGOMConstants.NOTIFICATION.STATUS.UNREAD].size());
	}

	@isTest
	private static void testAcknowledgeGapNotificationsInvalidId() {
		Account account = [SELECT Id FROM Account LIMIT 1];

		System.assertEquals(3, [SELECT Id FROM IGOM_Contact_Role_Procedure_Compliance__c WHERE Notification_Status__c = :IGOMConstants.NOTIFICATION.STATUS.UNREAD].size());

		Test.startTest();

		try {
			IGOMNotificationUtil.sendIGOMNotifications(account.Id);
		} catch (AuraHandledException error) {
			System.assert(true);
		} catch (Exception error) {
			System.assert(false, UNEXP_EXC_CAUGHT + error);
		}

		Test.stopTest();

		System.assertEquals(3, [SELECT Id FROM IGOM_Contact_Role_Procedure_Compliance__c WHERE Notification_Status__c = :IGOMConstants.NOTIFICATION.STATUS.UNREAD].size());
	}

	@isTest
	private static void testGetGAPNotifiableContactsGHInformativeOk() {
		IGOM_Contact_Role_Detail__c contactRoleDetail = 
			[SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c, Account_Contact_Role__r.Contact__r.Name
			 FROM IGOM_Contact_Role_Detail__c 
			 WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = :TEST_NAME 
				   AND Role__c = :IGOMConstants.ROLES.ADMIN];
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c];

		Compliance_Review__c complianceReview1 = [SELECT Id FROM Compliance_Review__c WHERE Title__c = 'Compliance Review 1'];

		Test.startTest();

		Map<Id, IGOMNotificationUtil.NotifiableContact> notifiableContacts;
		System.runAs(contactUser) {
			notifiableContacts = IGOMNotificationUtil.getGAPNotifiableContacts(complianceReview1.Id, 'INFORMATIVE');
		}

		Test.stopTest();

		IGOM_Contact_Role_Detail__c sameStationAcknowledgerContactRoleDetail = 
		[SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c, Account_Contact_Role__r.Contact__r.Name
		 FROM IGOM_Contact_Role_Detail__c 
		 WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = :TEST_NAME AND Role__c = :IGOMConstants.ROLES.ACKNOWLEDGER];
		IGOM_Contact_Role_Detail__c parentStationContactRoleDetail = 
		[SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c, Account_Contact_Role__r.Contact__r.Name
		 FROM IGOM_Contact_Role_Detail__c 
		 WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = 'Test name 1' AND Role__c = :IGOMConstants.ROLES.ADMIN];
		
		System.assertEquals(6, notifiableContacts.size());
		System.assert(notifiableContacts.containsKey(contactRoleDetail.Account_Contact_Role__r.Contact__c));
		System.assert(notifiableContacts.containsKey(sameStationAcknowledgerContactRoleDetail.Account_Contact_Role__r.Contact__c));
		System.assert(notifiableContacts.containsKey(parentStationContactRoleDetail.Account_Contact_Role__r.Contact__c));
		
		System.assertEquals(contactRoleDetail.Id, notifiableContacts.get(contactRoleDetail.Account_Contact_Role__r.Contact__c).id);
		System.assertEquals(contactRoleDetail.Account_Contact_Role__r.Contact__r.Name, notifiableContacts.get(contactRoleDetail.Account_Contact_Role__r.Contact__c).fullname);
		System.assertEquals(IGOM_ADMIN, notifiableContacts.get(contactRoleDetail.Account_Contact_Role__r.Contact__c).origin);

		System.assertEquals(sameStationAcknowledgerContactRoleDetail.Id, notifiableContacts.get(sameStationAcknowledgerContactRoleDetail.Account_Contact_Role__r.Contact__c).id);
		System.assertEquals(sameStationAcknowledgerContactRoleDetail.Account_Contact_Role__r.Contact__r.Name, notifiableContacts.get(sameStationAcknowledgerContactRoleDetail.Account_Contact_Role__r.Contact__c).fullname);
		System.assertEquals('Acknowledger', notifiableContacts.get(sameStationAcknowledgerContactRoleDetail.Account_Contact_Role__r.Contact__c).origin);
		
		System.assertEquals(parentStationContactRoleDetail.Id, notifiableContacts.get(parentStationContactRoleDetail.Account_Contact_Role__r.Contact__c).id);
		System.assertEquals(parentStationContactRoleDetail.Account_Contact_Role__r.Contact__r.Name, notifiableContacts.get(parentStationContactRoleDetail.Account_Contact_Role__r.Contact__c).fullname);
		System.assertEquals(IGOM_ADMIN, notifiableContacts.get(parentStationContactRoleDetail.Account_Contact_Role__r.Contact__c).origin);
		System.assertEquals('Test name 1', notifiableContacts.get(parentStationContactRoleDetail.Account_Contact_Role__r.Contact__c).stationName);
	}

	@isTest
	private static void testGetGAPNotifiableContactsGHActionRequiredOk() {
		IGOM_Contact_Role_Detail__c contactRoleDetail = 
			[SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c, Account_Contact_Role__r.Contact__r.Name
			 FROM IGOM_Contact_Role_Detail__c 
			 WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = :TEST_NAME 
				   AND Role__c = :IGOMConstants.ROLES.ADMIN];
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c];

		Compliance_Review__c complianceReview1 = [SELECT Id FROM Compliance_Review__c WHERE Title__c = 'Compliance Review 1'];

		Test.startTest();

		Map<Id, IGOMNotificationUtil.NotifiableContact> notifiableContacts;
		System.runAs(contactUser) {
			notifiableContacts = IGOMNotificationUtil.getGAPNotifiableContacts(complianceReview1.Id, ACTION_REQ);
		}

		Test.stopTest();

		IGOM_Contact_Role_Detail__c sameStationAcknowledgerContactRoleDetail = 
		[SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c, Account_Contact_Role__r.Contact__r.Name
		 FROM IGOM_Contact_Role_Detail__c 
		 WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = :TEST_NAME AND Role__c = :IGOMConstants.ROLES.ACKNOWLEDGER];
		
		System.assertEquals(2, notifiableContacts.size());
		System.assert(notifiableContacts.containsKey(contactRoleDetail.Account_Contact_Role__r.Contact__c));
		System.assert(notifiableContacts.containsKey(sameStationAcknowledgerContactRoleDetail.Account_Contact_Role__r.Contact__c));
		
		System.assertEquals(contactRoleDetail.Id, notifiableContacts.get(contactRoleDetail.Account_Contact_Role__r.Contact__c).id);
		System.assertEquals(contactRoleDetail.Account_Contact_Role__r.Contact__r.Name, notifiableContacts.get(contactRoleDetail.Account_Contact_Role__r.Contact__c).fullname);
		System.assertEquals(IGOM_ADMIN, notifiableContacts.get(contactRoleDetail.Account_Contact_Role__r.Contact__c).origin);

		System.assertEquals(sameStationAcknowledgerContactRoleDetail.Id, notifiableContacts.get(sameStationAcknowledgerContactRoleDetail.Account_Contact_Role__r.Contact__c).id);
		System.assertEquals(sameStationAcknowledgerContactRoleDetail.Account_Contact_Role__r.Contact__r.Name, notifiableContacts.get(sameStationAcknowledgerContactRoleDetail.Account_Contact_Role__r.Contact__c).fullname);
		System.assertEquals('Acknowledger', notifiableContacts.get(sameStationAcknowledgerContactRoleDetail.Account_Contact_Role__r.Contact__c).origin);
	}

	@isTest
	private static void testGetGAPNotifiableContactsAirlineInformativeOk() {
		IGOM_Contact_Role_Detail__c contactRoleDetail = 
			[SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c, Account_Contact_Role__r.Contact__r.Name, Account_Role_Detail__r.Account_Role__c
			 FROM IGOM_Contact_Role_Detail__c 
			 WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = 'Test name 1' 
				   AND Role__c = :IGOMConstants.ROLES.ADMIN];
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c];

		Compliance_Review__c complianceReview1 = [SELECT Id FROM Compliance_Review__c WHERE Title__c = 'Compliance Review 1'];
		complianceReview1.Station__c = contactRoleDetail.Account_Role_Detail__r.Account_Role__c;
		update complianceReview1;

		Test.startTest();

		Map<Id, IGOMNotificationUtil.NotifiableContact> notifiableContacts;
		System.runAs(contactUser) {
			notifiableContacts = IGOMNotificationUtil.getGAPNotifiableContacts(complianceReview1.Id, 'INFORMATIVE');
		}

		Test.stopTest();

		IGOM_Contact_Role_Detail__c childStationsAdminContactRoleDetail = 
		[SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c, Account_Contact_Role__r.Contact__r.Name
		 FROM IGOM_Contact_Role_Detail__c 
		 WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = :TEST_NAME AND Role__c = :IGOMConstants.ROLES.ADMIN];
		IGOM_Contact_Role_Detail__c grandchildStationsAdminContactRoleDetail = 
		[SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c, Account_Contact_Role__r.Contact__r.Name
		 FROM IGOM_Contact_Role_Detail__c 
		 WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = 'Test name 3' AND Role__c = :IGOMConstants.ROLES.ADMIN];
		IGOM_Contact_Role_Detail__c sameStationAcknowledgerContactRoleDetail = 
		 [SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c, Account_Contact_Role__r.Contact__r.Name
		  FROM IGOM_Contact_Role_Detail__c 
		  WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = 'Test name 1' AND Role__c = :IGOMConstants.ROLES.ACKNOWLEDGER]; 
		
		System.assertEquals(5, notifiableContacts.size());
		System.assert(notifiableContacts.containsKey(contactRoleDetail.Account_Contact_Role__r.Contact__c));
		System.assert(notifiableContacts.containsKey(childStationsAdminContactRoleDetail.Account_Contact_Role__r.Contact__c));
		System.assert(notifiableContacts.containsKey(grandchildStationsAdminContactRoleDetail.Account_Contact_Role__r.Contact__c));
		System.assert(notifiableContacts.containsKey(sameStationAcknowledgerContactRoleDetail.Account_Contact_Role__r.Contact__c));
		
		System.assertEquals(contactRoleDetail.Id, notifiableContacts.get(contactRoleDetail.Account_Contact_Role__r.Contact__c).id);
		System.assertEquals(contactRoleDetail.Account_Contact_Role__r.Contact__r.Name, notifiableContacts.get(contactRoleDetail.Account_Contact_Role__r.Contact__c).fullname);
		System.assertEquals(IGOM_ADMIN, notifiableContacts.get(contactRoleDetail.Account_Contact_Role__r.Contact__c).origin);

		System.assertEquals(sameStationAcknowledgerContactRoleDetail.Id, notifiableContacts.get(sameStationAcknowledgerContactRoleDetail.Account_Contact_Role__r.Contact__c).id);
		System.assertEquals(sameStationAcknowledgerContactRoleDetail.Account_Contact_Role__r.Contact__r.Name, notifiableContacts.get(sameStationAcknowledgerContactRoleDetail.Account_Contact_Role__r.Contact__c).fullname);
		System.assertEquals('Acknowledger', notifiableContacts.get(sameStationAcknowledgerContactRoleDetail.Account_Contact_Role__r.Contact__c).origin);
		
		System.assertEquals(childStationsAdminContactRoleDetail.Id, notifiableContacts.get(childStationsAdminContactRoleDetail.Account_Contact_Role__r.Contact__c).id);
		System.assertEquals(childStationsAdminContactRoleDetail.Account_Contact_Role__r.Contact__r.Name, notifiableContacts.get(childStationsAdminContactRoleDetail.Account_Contact_Role__r.Contact__c).fullname);
		System.assertEquals(IGOM_ADMIN, notifiableContacts.get(childStationsAdminContactRoleDetail.Account_Contact_Role__r.Contact__c).origin);
		System.assertEquals(TEST_NAME, notifiableContacts.get(childStationsAdminContactRoleDetail.Account_Contact_Role__r.Contact__c).stationName);
		
		System.assertEquals(grandchildStationsAdminContactRoleDetail.Id, notifiableContacts.get(grandchildStationsAdminContactRoleDetail.Account_Contact_Role__r.Contact__c).id);
		System.assertEquals(grandchildStationsAdminContactRoleDetail.Account_Contact_Role__r.Contact__r.Name, notifiableContacts.get(grandchildStationsAdminContactRoleDetail.Account_Contact_Role__r.Contact__c).fullname);
		System.assertEquals(IGOM_ADMIN, notifiableContacts.get(grandchildStationsAdminContactRoleDetail.Account_Contact_Role__r.Contact__c).origin);
		System.assertEquals('Test name 3', notifiableContacts.get(grandchildStationsAdminContactRoleDetail.Account_Contact_Role__r.Contact__c).stationName);
	}

	@isTest
	private static void testGetGAPNotifiableContactsAirlineActionRequiredOk() {
		IGOM_Contact_Role_Detail__c contactRoleDetail = 
			[SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c, Account_Contact_Role__r.Contact__r.Name, Account_Role_Detail__r.Account_Role__c
			 FROM IGOM_Contact_Role_Detail__c 
			 WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = 'Test name 1' 
				   AND Role__c = :IGOMConstants.ROLES.ADMIN];
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c];

		Compliance_Review__c complianceReview1 = [SELECT Id FROM Compliance_Review__c WHERE Title__c = 'Compliance Review 1'];
		complianceReview1.Station__c = contactRoleDetail.Account_Role_Detail__r.Account_Role__c;
		update complianceReview1;

		Test.startTest();

		Map<Id, IGOMNotificationUtil.NotifiableContact> notifiableContacts;
		System.runAs(contactUser) {
			notifiableContacts = IGOMNotificationUtil.getGAPNotifiableContacts(complianceReview1.Id, ACTION_REQ);
		}

		Test.stopTest();
		
		IGOM_Contact_Role_Detail__c childStationsAdminContactRoleDetail = 
		[SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c, Account_Contact_Role__r.Contact__r.Name
		 FROM IGOM_Contact_Role_Detail__c 
		 WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = :TEST_NAME AND Role__c = :IGOMConstants.ROLES.ADMIN];
		IGOM_Contact_Role_Detail__c grandchildStationsAdminContactRoleDetail = 
		[SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c, Account_Contact_Role__r.Contact__r.Name
		 FROM IGOM_Contact_Role_Detail__c 
		 WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = 'Test name 3' AND Role__c = :IGOMConstants.ROLES.ADMIN];
		IGOM_Contact_Role_Detail__c sameStationAcknowledgerContactRoleDetail = 
		 [SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c, Account_Contact_Role__r.Contact__r.Name
		  FROM IGOM_Contact_Role_Detail__c 
		  WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = 'Test name 1' AND Role__c = :IGOMConstants.ROLES.ACKNOWLEDGER]; 
		
		System.assertEquals(5, notifiableContacts.size());
		System.assert(notifiableContacts.containsKey(contactRoleDetail.Account_Contact_Role__r.Contact__c));
		System.assert(notifiableContacts.containsKey(childStationsAdminContactRoleDetail.Account_Contact_Role__r.Contact__c));
		System.assert(notifiableContacts.containsKey(grandchildStationsAdminContactRoleDetail.Account_Contact_Role__r.Contact__c));
		System.assert(notifiableContacts.containsKey(sameStationAcknowledgerContactRoleDetail.Account_Contact_Role__r.Contact__c));
		
		System.assertEquals(contactRoleDetail.Id, notifiableContacts.get(contactRoleDetail.Account_Contact_Role__r.Contact__c).id);
		System.assertEquals(contactRoleDetail.Account_Contact_Role__r.Contact__r.Name, notifiableContacts.get(contactRoleDetail.Account_Contact_Role__r.Contact__c).fullname);
		System.assertEquals(IGOM_ADMIN, notifiableContacts.get(contactRoleDetail.Account_Contact_Role__r.Contact__c).origin);

		System.assertEquals(sameStationAcknowledgerContactRoleDetail.Id, notifiableContacts.get(sameStationAcknowledgerContactRoleDetail.Account_Contact_Role__r.Contact__c).id);
		System.assertEquals(sameStationAcknowledgerContactRoleDetail.Account_Contact_Role__r.Contact__r.Name, notifiableContacts.get(sameStationAcknowledgerContactRoleDetail.Account_Contact_Role__r.Contact__c).fullname);
		System.assertEquals('Acknowledger', notifiableContacts.get(sameStationAcknowledgerContactRoleDetail.Account_Contact_Role__r.Contact__c).origin);
		
		System.assertEquals(childStationsAdminContactRoleDetail.Id, notifiableContacts.get(childStationsAdminContactRoleDetail.Account_Contact_Role__r.Contact__c).id);
		System.assertEquals(childStationsAdminContactRoleDetail.Account_Contact_Role__r.Contact__r.Name, notifiableContacts.get(childStationsAdminContactRoleDetail.Account_Contact_Role__r.Contact__c).fullname);
		System.assertEquals(IGOM_ADMIN, notifiableContacts.get(childStationsAdminContactRoleDetail.Account_Contact_Role__r.Contact__c).origin);
		System.assertEquals(TEST_NAME, notifiableContacts.get(childStationsAdminContactRoleDetail.Account_Contact_Role__r.Contact__c).stationName);
		
		System.assertEquals(grandchildStationsAdminContactRoleDetail.Id, notifiableContacts.get(grandchildStationsAdminContactRoleDetail.Account_Contact_Role__r.Contact__c).id);
		System.assertEquals(grandchildStationsAdminContactRoleDetail.Account_Contact_Role__r.Contact__r.Name, notifiableContacts.get(grandchildStationsAdminContactRoleDetail.Account_Contact_Role__r.Contact__c).fullname);
		System.assertEquals(IGOM_ADMIN, notifiableContacts.get(childStationsAdminContactRoleDetail.Account_Contact_Role__r.Contact__c).origin);
		System.assertEquals(TEST_NAME, notifiableContacts.get(childStationsAdminContactRoleDetail.Account_Contact_Role__r.Contact__c).stationName);
	}

	@isTest
	private static void testGetGAPNotifiableContactsUnauthorized() {
		IGOM_Contact_Role_Detail__c contactRoleDetail = 
			[SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c, Account_Contact_Role__r.Contact__r.Name
			 FROM IGOM_Contact_Role_Detail__c 
			 WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = 'Test name 1' 
				   AND Role__c = :IGOMConstants.ROLES.ADMIN];
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c];

		Compliance_Review__c complianceReview1 = [SELECT Id FROM Compliance_Review__c WHERE Title__c = 'Compliance Review 1'];

		Test.startTest();

		System.runAs(contactUser) {
			try {
				IGOMNotificationUtil.getGAPNotifiableContacts(complianceReview1.Id, ACTION_REQ);
			} catch (AuraHandledException error) {
				System.assert(true);
			} catch (Exception error) {
				System.assert(false, UNEXP_EXC_CAUGHT + error);
			}
		}

		Test.stopTest();
	}

	@isTest
	private static void testGetGAPNotifiableContactsNoStation() {
		IGOM_Contact_Role_Detail__c contactRoleDetail = 
			[SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c, Account_Contact_Role__r.Contact__r.Name
			 FROM IGOM_Contact_Role_Detail__c 
			 WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = :TEST_NAME 
				   AND Role__c = :IGOMConstants.ROLES.ADMIN];
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c];

		Compliance_Review__c complianceReview1 = [SELECT Id FROM Compliance_Review__c WHERE Title__c = 'Compliance Review 1'];
		complianceReview1.Station__c = null;
		update complianceReview1;

		Test.startTest();

		System.runAs(contactUser) {
			try {
				IGOMNotificationUtil.getGAPNotifiableContacts(complianceReview1.Id, ACTION_REQ);
			} catch (AuraHandledException error) {
				System.assert(true);
			} catch (Exception error) {
				System.assert(false, UNEXP_EXC_CAUGHT + error);
			}
		}

		Test.stopTest();
	}

	@isTest
	private static void testGetGAPNotifiableContactsInvalidId() {
		Account account = [SELECT Id FROM Account LIMIT 1];

		Test.startTest();

		try {
			IGOMNotificationUtil.getGAPNotifiableContacts(account.Id, 'INFORMATIVE');
		} catch (AuraHandledException error) {
			System.assert(true);
		} catch (Exception error) {
			System.assert(false, UNEXP_EXC_CAUGHT + error);
		}

		Test.stopTest();
	}

	@isTest
	private static void testGetGAPNotifiableContactsInvalidNotificationType() {
		IGOM_Contact_Role_Detail__c contactRoleDetail = 
			[SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c, Account_Contact_Role__r.Contact__r.Name
			 FROM IGOM_Contact_Role_Detail__c 
			 WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = :TEST_NAME 
				   AND Role__c = :IGOMConstants.ROLES.ADMIN];
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c];

		Compliance_Review__c complianceReview1 = [SELECT Id FROM Compliance_Review__c WHERE Title__c = 'Compliance Review 1'];

		Test.startTest();

		Map<Id, IGOMNotificationUtil.NotifiableContact> notifiableContacts;
		System.runAs(contactUser) {
			// Defaults to INFORMATIVE
			notifiableContacts = IGOMNotificationUtil.getGAPNotifiableContacts(complianceReview1.Id, 'OTHER');
		}

		Test.stopTest();

		IGOM_Contact_Role_Detail__c sameStationAcknowledgerContactRoleDetail = 
		[SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c, Account_Contact_Role__r.Contact__r.Name
		 FROM IGOM_Contact_Role_Detail__c 
		 WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = :TEST_NAME AND Role__c = :IGOMConstants.ROLES.ACKNOWLEDGER];
		IGOM_Contact_Role_Detail__c parentStationContactRoleDetail = 
		[SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c, Account_Contact_Role__r.Contact__r.Name
		 FROM IGOM_Contact_Role_Detail__c 
		 WHERE Account_Role_Detail__r.Account_Role__r.Account__r.Name = 'Test name 1' AND Role__c = :IGOMConstants.ROLES.ADMIN];
		
		System.assert(notifiableContacts.containsKey(contactRoleDetail.Account_Contact_Role__r.Contact__c));
		System.assert(notifiableContacts.containsKey(sameStationAcknowledgerContactRoleDetail.Account_Contact_Role__r.Contact__c));
		System.assert(notifiableContacts.containsKey(parentStationContactRoleDetail.Account_Contact_Role__r.Contact__c));
		
		System.assertEquals(contactRoleDetail.Id, notifiableContacts.get(contactRoleDetail.Account_Contact_Role__r.Contact__c).id);
		System.assertEquals(contactRoleDetail.Account_Contact_Role__r.Contact__r.Name, notifiableContacts.get(contactRoleDetail.Account_Contact_Role__r.Contact__c).fullname);
		System.assertEquals(IGOM_ADMIN, notifiableContacts.get(contactRoleDetail.Account_Contact_Role__r.Contact__c).origin);

		System.assertEquals(sameStationAcknowledgerContactRoleDetail.Id, notifiableContacts.get(sameStationAcknowledgerContactRoleDetail.Account_Contact_Role__r.Contact__c).id);
		System.assertEquals(sameStationAcknowledgerContactRoleDetail.Account_Contact_Role__r.Contact__r.Name, notifiableContacts.get(sameStationAcknowledgerContactRoleDetail.Account_Contact_Role__r.Contact__c).fullname);
		System.assertEquals('Acknowledger', notifiableContacts.get(sameStationAcknowledgerContactRoleDetail.Account_Contact_Role__r.Contact__c).origin);
		
		System.assertEquals(parentStationContactRoleDetail.Id, notifiableContacts.get(parentStationContactRoleDetail.Account_Contact_Role__r.Contact__c).id);
		System.assertEquals(IGOM_ADMIN, notifiableContacts.get(parentStationContactRoleDetail.Account_Contact_Role__r.Contact__c).origin);
		System.assertEquals('Test name 1', notifiableContacts.get(parentStationContactRoleDetail.Account_Contact_Role__r.Contact__c).stationName);
	}


	@isTest
	private static void testSendManualNotifications_Success(){
		Id stationId = [SELECT Id FROM IGOM_Account_Role_Detail__c LIMIT 1].Id;

		Set<Id> contactIds = new Set<Id>();
		Set<Id> contactRoleIds = new Set<Id>();
		for(IGOM_Contact_Role_Detail__c contactRole : [SELECT Id, Account_Contact_Role__r.Contact__c
		 FROM IGOM_Contact_Role_Detail__c 
		 WHERE Account_Role_Detail__c = :stationId AND (Role__c = :IGOMConstants.ROLES.ADMIN OR Role__c = :IGOMConstants.ROLES.ACKNOWLEDGER)]){
		   contactIds.add(contactRole.Account_Contact_Role__r.Contact__c);
		   contactRoleIds.add(contactRole.Id);
		}
		
		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c WHERE  Role__c = :IGOMConstants.ROLES.ADMIN LIMIT 1].Account_Contact_Role__r.Contact__c;
		User user = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];
		Test.startTest();
		System.runAs(user){
			IGOMNotificationUtil.sendManualNotifications(stationId, new List<Id>(contactIds), SUBJECT, BODY);
		}
		Test.stopTest();

		List<IGOM_Contact_Role_Procedure_Compliance__c> notifications = [SELECT Id, Notification_Subject__c, Notification_Body__c FROM IGOM_Contact_Role_Procedure_Compliance__c
		 WHERE IGOM_Contact_Role_Detail__c IN :contactRoleIds AND Severity__c = :IGOMConstants.NOTIFICATION.SEVERITY.MANUAL];
		
		System.assertEquals(contactIds.size(), notifications.size());
		for(IGOM_Contact_Role_Procedure_Compliance__c notif : notifications){
			System.assertEquals(SUBJECT, notif.Notification_Subject__c);
			System.assertEquals(BODY, notif.Notification_Body__c);
		}
	}

	@isTest
	private static void testSendManualNotifications_Error(){
		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c WHERE  Role__c = :IGOMConstants.ROLES.ADMIN LIMIT 1].Account_Contact_Role__r.Contact__c;
		User user = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];

		Id stationId = [SELECT Id FROM IGOM_Account_Role_Detail__c LIMIT 1].Id;
		Map<Id, IGOMNotificationUtil.NotifiableContact> notifiableContactsManual;
		System.runAs(user){
			notifiableContactsManual = IGOMNotificationUtil.getStationNotifiableContacts(stationId, IGOMConstants.NOTIFICATION.SEVERITY.MANUAL);
		}

		Set<Id> contactIds = new Set<Id>();
		for(IGOM_Contact_Role_Detail__c contactRole : [SELECT Id, Account_Contact_Role__r.Contact__c
		 FROM IGOM_Contact_Role_Detail__c 
		 WHERE Account_Role_Detail__c = :stationId AND Account_Contact_Role__r.Contact__c NOT IN :notifiableContactsManual.keySet()]){
		   contactIds.add(contactRole.Account_Contact_Role__r.Contact__c);
		}
		
		Test.startTest();
		try{
			System.runAs(user){
				IGOMNotificationUtil.sendManualNotifications(stationId, new List<Id>(contactIds), SUBJECT, BODY);
			}
		} catch (AuraHandledException error) {
			System.assert(true);
		} catch (Exception error) {
			System.assert(false, UNEXP_EXC_CAUGHT + error);
		}
		Test.stopTest();
	}
}