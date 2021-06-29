@isTest
private class IGOMDashboardDataUtilTest {

	private static String TEST_NAME = 'Test name ';
	public static final String EXC_NOT_THROWN = 'Exception not thrown';
	public static final String UNEXP_EXC_CAUGHT = 'Unexpected exception caught ';

	@TestSetup
	static void makeData() {
		List<Compliance_Review_Part__c> complianceReviewParts = IGOMTestFactory.createExampleComplianceReviewData();

		List<IGOM_Contact_Role_Detail__c> contactRoleDetails = [SELECT Id FROM IGOM_Contact_Role_Detail__c LIMIT 2];
		// Generate notifications
		List<IGOM_Contact_Role_Procedure_Compliance__c> notifications = new List<IGOM_Contact_Role_Procedure_Compliance__c>();
		IGOM_Contact_Role_Procedure_Compliance__c noti11 = IGOMTestFactory.createIGOMContactRoleProcedureCompliance(contactRoleDetails.get(0).Id, complianceReviewParts.get(3).Id);
		IGOM_Contact_Role_Procedure_Compliance__c noti12 = IGOMTestFactory.createIGOMContactRoleProcedureCompliance(contactRoleDetails.get(0).Id, complianceReviewParts.get(5).Id);
		notI11.Notification_Status__c = IGOMConstants.NOTIFICATION.STATUS.ACKNOWLEDGED;
		IGOM_Contact_Role_Procedure_Compliance__c noti21 = IGOMTestFactory.createIGOMContactRoleProcedureCompliance(contactRoleDetails.get(1).Id, complianceReviewParts.get(6).Id);
		IGOM_Contact_Role_Procedure_Compliance__c noti22 = IGOMTestFactory.createIGOMContactRoleProcedureCompliance(contactRoleDetails.get(1).Id, complianceReviewParts.get(8).Id);
		notifications.addAll(new List<IGOM_Contact_Role_Procedure_Compliance__c>{ notI11, noti12, noti21, noti22 });
		insert notifications;
	}

	@isTest 
	private static void testGetStationSummaryOk() {
		Map<String, Id> accountRoleNameToId = new Map<String, Id>();
		for (Account_Role__c accountRole : [SELECT Id, Account__r.Name FROM Account_Role__c]) {
			accountRoleNameToId.put(accountRole.Account__r.Name, accountRole.Id);
		}

		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c WHERE  Role__c = :IGOMConstants.ROLES.ADMIN LIMIT 1].Account_Contact_Role__r.Contact__c;
		User user = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];
		Test.startTest();
		Map<Id, IGOMDashboardDataUtil.StationSummary> stationIdToSummary;
		System.runAs(user){
			stationIdToSummary = IGOMDashboardDataUtil.getStationSummary(accountRoleNameToId.values());
		}
		Test.stopTest();

		IGOMDashboardDataUtil.StationSummary stationSummary1 = stationIdToSummary.get(accountRoleNameToId.get(TEST_NAME + '0'));
		IGOMDashboardDataUtil.StationSummary stationSummary2 = stationIdToSummary.get(accountRoleNameToId.get(TEST_NAME + '1'));
		IGOMDashboardDataUtil.StationSummary stationSummary3 = stationIdToSummary.get(accountRoleNameToId.get(TEST_NAME + '2'));
		System.assertEquals(2, stationSummary1.lastGapAnalysisVariations);
		System.assertEquals(1, stationSummary2.lastGapAnalysisVariations);
		System.assertEquals(null, stationSummary3.lastGapAnalysisVariations);
		System.assertEquals(Date.today(), stationSummary1.lastGapAnalysisDate);
		System.assertEquals(Date.today().addDays(1), stationSummary2.lastGapAnalysisDate);
		System.assertEquals(null, stationSummary3.lastGapAnalysisDate);
		System.assertEquals(1, stationSummary1.readAcknowledgements);
		System.assertEquals(0, stationSummary2.readAcknowledgements);
		System.assertEquals(null, stationSummary3.readAcknowledgements);
		System.assertEquals(2, stationSummary1.totalAcknowledgements);
		System.assertEquals(2, stationSummary2.totalAcknowledgements);
		System.assertEquals(null, stationSummary3.totalAcknowledgements);
	}

	@isTest 
	private static void testUserToProcedureToAcknowledgementStatusOk() {
		Id complianceReview2Id = [SELECT Id FROM Compliance_Review__c WHERE Title__c = 'Compliance Review 2'].Id;

		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c WHERE  Role__c = :IGOMConstants.ROLES.ADMIN LIMIT 1].Account_Contact_Role__r.Contact__c;
		User user = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];
		Test.startTest();
		Map<String, Map<String, String>> result;
		System.runAs(user){
			String userAcknowledgements = IGOMDashboardDataUtil.userToProcedureToAcknowledgementStatus(complianceReview2Id);
			result = (Map<String, Map<String, String>>)JSON.deserialize(userAcknowledgements, Map<String, Map<String, String>>.class);
		}
		Test.stopTest();

		Map<String, Id> accountRoleNameToId = new Map<String, Id>();
		for (Account_Role__c accountRole : [SELECT Id, Account__r.Name FROM Account_Role__c]) {
			accountRoleNameToId.put(accountRole.Account__r.Name, accountRole.Id);
		}
		Id stationId = accountRoleNameToId.get(TEST_NAME + '0');

		Map<String, Id> complianceReviewPartNameToId = new Map<String, Id>();
		for (Compliance_Review_Part__c complianceReviewPart : [SELECT Id, Standard_Document_Part__r.Name__c FROM Compliance_Review_Part__c WHERE Compliance_Review__c = :complianceReview2Id]) {
			complianceReviewPartNameToId.put(complianceReviewPart.Standard_Document_Part__r.Name__c, complianceReviewPart.Id);
		}

		Map<Id, IGOM_Contact_Role_Detail__c> accountRoleIdToContactRoleDetail = new Map<Id, IGOM_Contact_Role_Detail__c>();
		for (IGOM_Contact_Role_Detail__c contactRoleDetail : [SELECT Id, Account_Role_Detail__r.Account_Role__c, Account_Contact_Role__r.Contact__r.Name FROM IGOM_Contact_Role_Detail__c]) {
			accountRoleIdToContactRoleDetail.put(contactRoleDetail.Account_Role_Detail__r.Account_Role__c, contactRoleDetail);
		}

		Map<String, String> notificationStatuses = result.get(accountRoleIdToContactRoleDetail.get(stationId).Id + ':' + accountRoleIdToContactRoleDetail.get(stationId).Account_Contact_Role__r.Contact__r.Name);
		System.assertNotEquals(null, notificationStatuses);
		System.assertEquals(2, notificationStatuses.size());
		System.assertEquals(IGOMConstants.NOTIFICATION.STATUS.ACKNOWLEDGED, notificationStatuses.get(complianceReviewPartNameToId.get('Section 1 Procedure 1') + ':Section 1 Procedure 1'));
		System.assertEquals(IGOMConstants.NOTIFICATION.STATUS.UNREAD, notificationStatuses.get(complianceReviewPartNameToId.get('Section 2 Procedure 1') + ':Section 2 Procedure 1'));
	}
	
	@isTest
	private static void testUserToProcedureToAcknowledgementStatusUnauthorized() {
		// Change role to have no permissions
		IGOM_Contact_Role_Detail__c contactRole = [SELECT Id, Role__c, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		contactRole.Role__c = null;
		update contactRole;
		
		Id complianceReview2Id = [SELECT Id FROM Compliance_Review__c WHERE Title__c = 'Compliance Review 2'].Id;

		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRole.Account_Contact_Role__r.Contact__c];

		Test.startTest();

		System.runAs(contactUser) {
			try {
				String userAcknowledgements = IGOMDashboardDataUtil.userToProcedureToAcknowledgementStatus(complianceReview2Id);
				System.assert(false, EXC_NOT_THROWN);
			} catch (AuraHandledException error) {
				System.assert(true);
			} catch (Exception error) {
				System.assert(false, UNEXP_EXC_CAUGHT + error);
			}
		}

		Test.stopTest();
	}

	@isTest 
	private static void testStatusPerStationOk() {
		
		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c WHERE  Role__c = :IGOMConstants.ROLES.ADMIN LIMIT 1].Account_Contact_Role__r.Contact__c;
		User user = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];
		Test.startTest();
		Map<String, String> statusPerStation;
		System.runAs(user){
			statusPerStation = IGOMDashboardDataUtil.statusPerStation();
		}
		Test.stopTest();

		Map<String, Id> accountRoleNameToId = new Map<String, Id>();
		for (IGOM_Account_Role_Detail__c accountRoleDetail : [SELECT Id, Account_Role__r.Account__r.Name FROM IGOM_Account_Role_Detail__c]) {
			accountRoleNameToId.put(accountRoleDetail.Account_Role__r.Account__r.Name, accountRoleDetail.Id);
		}

		System.assertEquals(3, statusPerStation.size());
		System.assertEquals('Pending review', statusPerStation.get(accountRoleNameToId.get(TEST_NAME + '0') + ':' + TEST_NAME + '0'));
		System.assertEquals('Reviewed', statusPerStation.get(accountRoleNameToId.get(TEST_NAME + '1') + ':' + TEST_NAME + '1'));
		System.assertEquals('Non-existing', statusPerStation.get(accountRoleNameToId.get(TEST_NAME + '2') + ':' + TEST_NAME + '2'));
	}

	@isTest
	private static void testStatusPerStationNoRole() {
		// Remove role globally
		IGOM_Contact_Role_Detail__c contactRole = [SELECT Id, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		delete contactRole;

		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRole.Account_Contact_Role__r.Contact__c];

		Test.startTest();

		System.runAs(contactUser) {
			try {
				Map<String, String> statusPerStation = IGOMDashboardDataUtil.statusPerStation();
				System.assert(false, EXC_NOT_THROWN);
			} catch (AuraHandledException error) {
				System.assert(true);
			} catch (Exception error) {
				System.assert(false, UNEXP_EXC_CAUGHT + error);
			}
		}

		Test.stopTest();
	}

	@isTest
	private static void testStatusPerStationOnlyOwn() {
		// Change role to view only own stations
		IGOM_Contact_Role_Detail__c contactRole = [SELECT Id, Role__c, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		contactRole.Role__c = IGOMConstants.ROLES.VIEWER;
		update contactRole;

		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRole.Account_Contact_Role__r.Contact__c];

		Test.startTest();

		Map<String, String> statusPerStation;
		System.runAs(contactUser) {
			statusPerStation = IGOMDashboardDataUtil.statusPerStation();
		}

		Test.stopTest();

		Map<String, Id> accountRoleNameToId = new Map<String, Id>();
		for (IGOM_Account_Role_Detail__c accountRoleDetail : [SELECT Id, Account_Role__r.Account__r.Name FROM IGOM_Account_Role_Detail__c]) {
			accountRoleNameToId.put(accountRoleDetail.Account_Role__r.Account__r.Name, accountRoleDetail.Id);
		}

		System.assertEquals(1, statusPerStation.size());
		System.assertEquals('Pending review', statusPerStation.get(accountRoleNameToId.get(TEST_NAME + '0') + ':' + TEST_NAME + '0'));
	}

	@isTest
	private static void testStatusPerStationUnauthorized() {
		// Change role to have no permissions
		IGOM_Contact_Role_Detail__c contactRole = [SELECT Id, Role__c, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		contactRole.Role__c = null;
		update contactRole;

		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRole.Account_Contact_Role__r.Contact__c];

		Test.startTest();

		System.runAs(contactUser) {
			try {
				Map<String, String> statusPerStation = IGOMDashboardDataUtil.statusPerStation();
				System.assert(false, EXC_NOT_THROWN);
			} catch (AuraHandledException error) {
				System.assert(true);
			} catch (Exception error) {
				System.assert(false, UNEXP_EXC_CAUGHT + error);
			}
		}

		Test.stopTest();
	}

	@isTest
	private static void testGetStationSummaryUnauthorized() {
		// Change role to have no permissions
		IGOM_Contact_Role_Detail__c contactRole = [SELECT Id, Role__c, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		contactRole.Role__c = null;
		update contactRole;
		
		Map<String, Id> accountRoleNameToId = new Map<String, Id>();
		for (Account_Role__c accountRole : [SELECT Id, Account__r.Name FROM Account_Role__c]) {
			accountRoleNameToId.put(accountRole.Account__r.Name, accountRole.Id);
		}

		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRole.Account_Contact_Role__r.Contact__c];

		Test.startTest();

		System.runAs(contactUser) {
			try {
				Map<Id, IGOMDashboardDataUtil.StationSummary> stationIdToSummary = IGOMDashboardDataUtil.getStationSummary(accountRoleNameToId.values());
				System.assert(false, EXC_NOT_THROWN);
			} catch (AuraHandledException error) {
				System.assert(true);
			} catch (Exception error) {
				System.assert(false, UNEXP_EXC_CAUGHT + error);
			}
		}

		Test.stopTest();
	}

	@isTest 
	private static void testVariationStatusPerChapterOk() {
		Id complianceReview2Id = [SELECT Id FROM Compliance_Review__c WHERE Title__c = 'Compliance Review 2'].Id;
		
		IGOM_Contact_Role_Detail__c contactRoleDetail = [SELECT Id, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		contactRoleDetail.Role__c = IGOMConstants.ROLES.ADMIN;
		update contactRoleDetail;
		User user = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c LIMIT 1];
		Test.startTest();

		Map<String, Map<Object, Integer>> variationStatusPerChapter;
		System.runAs(user){
			variationStatusPerChapter = IGOMDashboardDataUtil.variationStatusPerChapter(complianceReview2Id);
		}

		Test.stopTest();

		System.assertNotEquals(null, variationStatusPerChapter);
		System.assertEquals(1, variationStatusPerChapter.size());
		Map<Object, Integer> variationStatuses = variationStatusPerChapter.get('Part 1');
		System.assertNotEquals(null, variationStatuses);
		System.assertEquals(1, variationStatuses.get(IGOMConstants.PROCEDURE_COMPLIANCE.STATUS.CONFORMITY));
		System.assertEquals(2, variationStatuses.get(IGOMConstants.PROCEDURE_COMPLIANCE.STATUS.VARIATION));
	}
	
	@isTest
	private static void testVariationStatusPerChapterUnauthorized() {
		// Change role to have no permissions
		IGOM_Contact_Role_Detail__c contactRole = [SELECT Id, Role__c, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		contactRole.Role__c = null;
		update contactRole;
		
		Id complianceReview2Id = [SELECT Id FROM Compliance_Review__c WHERE Title__c = 'Compliance Review 2'].Id;

		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRole.Account_Contact_Role__r.Contact__c];

		Test.startTest();

		System.runAs(contactUser) {
			try {
				Map<String, Map<Object, Integer>> variationStatusPerChapter = IGOMDashboardDataUtil.variationStatusPerChapter(complianceReview2Id);
				System.assert(false, EXC_NOT_THROWN);
			} catch (AuraHandledException error) {
				System.assert(true);
			} catch (Exception error) {
				System.assert(false, UNEXP_EXC_CAUGHT + error);
			}
		}

		Test.stopTest();
	}

	@isTest 
	private static void testItemStatusPerChapterOk() {
		Id complianceReview2Id = [SELECT Id FROM Compliance_Review__c WHERE Title__c = 'Compliance Review 2'].Id;
		

		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c WHERE  Role__c = :IGOMConstants.ROLES.ADMIN LIMIT 1].Account_Contact_Role__r.Contact__c;
		User user = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];
		Test.startTest();
		Map<String, Map<Object, Integer>> itemStatusPerChapter;
		System.runAs(user){
			itemStatusPerChapter = IGOMDashboardDataUtil.itemStatusPerChapter(complianceReview2Id);
		}
		Test.stopTest();

		System.assertNotEquals(null, itemStatusPerChapter);
		System.assertEquals(1, itemStatusPerChapter.size());
		Map<Object, Integer> itemStatuses = itemStatusPerChapter.get('Part 1');
		System.assertNotEquals(null, itemStatuses);
		System.assertEquals(1, itemStatuses.get(true));
		System.assertEquals(2, itemStatuses.get(false));
	}
	@isTest
	private static void testItemStatusPerChapterUnauthorized() {
		// Remove role globally
		IGOM_Contact_Role_Detail__c contactRole = [SELECT Id, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		delete contactRole;
		
		Id complianceReview2Id = [SELECT Id FROM Compliance_Review__c WHERE Title__c = 'Compliance Review 2'].Id;

		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRole.Account_Contact_Role__r.Contact__c];

		Test.startTest();

		System.runAs(contactUser) {
			try {
				Map<String, Map<Object, Integer>> itemStatusPerChapter = IGOMDashboardDataUtil.itemStatusPerChapter(complianceReview2Id);
				System.assert(false, EXC_NOT_THROWN);
			} catch (AuraHandledException error) {
				System.assert(true);
			} catch (Exception error) {
				System.assert(false, UNEXP_EXC_CAUGHT + error);
			}
		}

		Test.stopTest();
	}

}