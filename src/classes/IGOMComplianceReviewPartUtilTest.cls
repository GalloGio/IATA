@isTest
private class IGOMComplianceReviewPartUtilTest {
	public static final String SECT1_PROC1 = 'Section 1 Procedure 1';
	public static final String SECT2_PROC1 = 'Section 2 Procedure 1';
	public static final String SECT1_PROC2 = 'Section 1 Procedure 2';
	public static final String TEST_PROV_TEXT = 'Test provision procedure text';
	public static final String EXC_NOT_THROWN = 'Exception not thrown';
	public static final String UNEX_EXC = 'Unexpected exception caught ';
	public static final String UNKNOWN_EXC = 'Unknown exception caught ';

	@TestSetup
	static void makeData() {
		IGOMTestFactory.createExampleComplianceReviewData();
	}

	@isTest
	private static void testGetComplianceReviewPartByIdOk() {
		Compliance_Review__c complianceReview = [SELECT Id FROM Compliance_Review__c LIMIT 1];
		Document__c gomDocument = [SELECT Id FROM Document__c WHERE RecordType.DeveloperName = :IGOMConstants.DOCUMENT.RECORD_TYPE.GOM LIMIT 1];
		
		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1].Account_Contact_Role__r.Contact__c;
		User user = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];

		List<Id> complianceReviewPartIds = new List<Id>();
		for (Compliance_Review_Part__c complianceReviewPart : [SELECT Id FROM Compliance_Review_Part__c WHERE Compliance_Review__c = :complianceReview.Id]) {
			complianceReviewPartIds.add(complianceReviewPart.Id);
		}

		Test.startTest();
		List<IGOMComplianceReviewPartUtil.ComplianceReviewPart> complianceReviewParts;
		System.runAs(user){
			complianceReviewParts = IGOMComplianceReviewPartUtil.getComplianceReviewPartById(complianceReviewPartIds);
		}
		Test.stopTest();

		Map<String, IGOMComplianceReviewPartUtil.ComplianceReviewPart> procedureToComplianceReviewPart = new Map<String, IGOMComplianceReviewPartUtil.ComplianceReviewPart>();
		for (IGOMComplianceReviewPartUtil.ComplianceReviewPart complianceReviewPart : complianceReviewParts) {
			procedureToComplianceReviewPart.put(complianceReviewPart.igomAuditableProcedureName, complianceReviewPart);
		}
		System.assertEquals(procedureToComplianceReviewPart.keySet().size(), 3);
		System.assertEquals(procedureToComplianceReviewPart.get(SECT1_PROC1).variationStatus, IGOMConstants.PROCEDURE_COMPLIANCE.STATUS.VARIATION);
		System.assertEquals(procedureToComplianceReviewPart.get(SECT2_PROC1).variationStatus, IGOMConstants.PROCEDURE_COMPLIANCE.STATUS.VARIATION);
		System.assertEquals(procedureToComplianceReviewPart.get(SECT1_PROC2).variationStatus, IGOMConstants.PROCEDURE_COMPLIANCE.STATUS.CONFORMITY);
		System.assertEquals(procedureToComplianceReviewPart.get(SECT1_PROC1).userProvisionProcedure, TEST_PROV_TEXT);
		System.assertEquals(procedureToComplianceReviewPart.get(SECT2_PROC1).userProvisionProcedure, TEST_PROV_TEXT);
		System.assertEquals(procedureToComplianceReviewPart.get(SECT1_PROC2).userProvisionProcedure, TEST_PROV_TEXT);
		System.assertEquals(procedureToComplianceReviewPart.get(SECT1_PROC1).gapAnalysisId, complianceReview.Id);
		System.assertEquals(procedureToComplianceReviewPart.get(SECT2_PROC1).gapAnalysisId, complianceReview.Id);
		System.assertEquals(procedureToComplianceReviewPart.get(SECT1_PROC2).gapAnalysisId, complianceReview.Id);
		System.assertEquals(procedureToComplianceReviewPart.get(SECT1_PROC1).document, gomDocument.Id);
		System.assertEquals(procedureToComplianceReviewPart.get(SECT2_PROC1).document, gomDocument.Id);
		System.assertEquals(procedureToComplianceReviewPart.get(SECT1_PROC2).document, gomDocument.Id);
	}

	@isTest
	private static void testGetComplianceReviewPartByIdBatch() {
		Compliance_Review__c complianceReview = [SELECT Id FROM Compliance_Review__c LIMIT 1];
		Document__c gomDocument = [SELECT Id FROM Document__c WHERE RecordType.DeveloperName = :IGOMConstants.DOCUMENT.RECORD_TYPE.GOM LIMIT 1];
		Document_Part__c documentPart = [SELECT Id FROM Document_Part__c LIMIT 1];
		
		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1].Account_Contact_Role__r.Contact__c;
		User user = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];
		// Generate 200 total compliance review parts
		List<Compliance_Review_Part__c> sfComplianceReviewParts = new List<Compliance_Review_Part__c>();
		for (Integer i = 3; i < 200; i++) {
			sfComplianceReviewParts.add(IGOMTestFactory.createComplianceReviewPart(complianceReview.Id, documentPart.Id, gomDocument.Id));
		}
		insert sfComplianceReviewParts;
		
		List<Id> complianceReviewPartIds = new List<Id>();
		for (Compliance_Review_Part__c complianceReviewPart : [SELECT Id FROM Compliance_Review_Part__c]) {
			complianceReviewPartIds.add(complianceReviewPart.Id);
		}

		Test.startTest();
		List<IGOMComplianceReviewPartUtil.ComplianceReviewPart> complianceReviewParts;
		System.runAs(user){
			complianceReviewParts = IGOMComplianceReviewPartUtil.getComplianceReviewPartById(complianceReviewPartIds);
		}
		Test.stopTest();

		System.assertEquals(210, complianceReviewParts.size());
	}

	@isTest
	private static void testGetComplianceReviewPartByComplianceReviewOk() {
		Compliance_Review__c complianceReview = [SELECT Id FROM Compliance_Review__c LIMIT 1];
		Document__c gomDocument = [SELECT Id FROM Document__c WHERE RecordType.DeveloperName = :IGOMConstants.DOCUMENT.RECORD_TYPE.GOM LIMIT 1];
		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1].Account_Contact_Role__r.Contact__c;
		User user = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];
		Test.startTest();
		List<IGOMComplianceReviewPartUtil.ComplianceReviewPart> complianceReviewParts;
		System.runAs(user){
			complianceReviewParts = IGOMComplianceReviewPartUtil.getComplianceReviewPartByComplianceReview(new List<Id>{complianceReview.Id});
		}
		Test.stopTest();

		Map<String, IGOMComplianceReviewPartUtil.ComplianceReviewPart> procedureToComplianceReviewPart = new Map<String, IGOMComplianceReviewPartUtil.ComplianceReviewPart>();
		for (IGOMComplianceReviewPartUtil.ComplianceReviewPart complianceReviewPart : complianceReviewParts) {
			procedureToComplianceReviewPart.put(complianceReviewPart.igomAuditableProcedureName, complianceReviewPart);
		}
		System.assertEquals(procedureToComplianceReviewPart.keySet().size(), 3);
		System.assertEquals(procedureToComplianceReviewPart.get(SECT1_PROC1).variationStatus, IGOMConstants.PROCEDURE_COMPLIANCE.STATUS.VARIATION);
		System.assertEquals(procedureToComplianceReviewPart.get(SECT2_PROC1).variationStatus, IGOMConstants.PROCEDURE_COMPLIANCE.STATUS.VARIATION);
		System.assertEquals(procedureToComplianceReviewPart.get(SECT1_PROC2).variationStatus, IGOMConstants.PROCEDURE_COMPLIANCE.STATUS.CONFORMITY);
		System.assertEquals(procedureToComplianceReviewPart.get(SECT1_PROC1).userProvisionProcedure, TEST_PROV_TEXT);
		System.assertEquals(procedureToComplianceReviewPart.get(SECT2_PROC1).userProvisionProcedure, TEST_PROV_TEXT);
		System.assertEquals(procedureToComplianceReviewPart.get(SECT1_PROC2).userProvisionProcedure, TEST_PROV_TEXT);
		System.assertEquals(procedureToComplianceReviewPart.get(SECT1_PROC1).gapAnalysisId, complianceReview.Id);
		System.assertEquals(procedureToComplianceReviewPart.get(SECT2_PROC1).gapAnalysisId, complianceReview.Id);
		System.assertEquals(procedureToComplianceReviewPart.get(SECT1_PROC2).gapAnalysisId, complianceReview.Id);
		System.assertEquals(procedureToComplianceReviewPart.get(SECT1_PROC1).document, gomDocument.Id);
		System.assertEquals(procedureToComplianceReviewPart.get(SECT2_PROC1).document, gomDocument.Id);
		System.assertEquals(procedureToComplianceReviewPart.get(SECT1_PROC2).document, gomDocument.Id);
	}

	@isTest
	private static void testGetComplianceReviewPartByComplianceReviewBatch() {
		Compliance_Review__c complianceReview = [SELECT Id FROM Compliance_Review__c LIMIT 1];
		Document__c gomDocument = [SELECT Id FROM Document__c WHERE RecordType.DeveloperName = :IGOMConstants.DOCUMENT.RECORD_TYPE.GOM LIMIT 1];
		Document_Part__c documentPart = [SELECT Id FROM Document_Part__c LIMIT 1];
		// Generate 200 total compliance review parts
		List<Compliance_Review_Part__c> sfComplianceReviewParts = new List<Compliance_Review_Part__c>();
		for (Integer i = 3; i < 200; i++) {
			sfComplianceReviewParts.add(IGOMTestFactory.createComplianceReviewPart(complianceReview.Id, documentPart.Id, gomDocument.Id));
		}
		insert sfComplianceReviewParts;
		
		List<Id> complianceReviewPartIds = new List<Id>();
		for (Compliance_Review_Part__c complianceReviewPart : [SELECT Id FROM Compliance_Review_Part__c]) {
			complianceReviewPartIds.add(complianceReviewPart.Id);
		}
		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1].Account_Contact_Role__r.Contact__c;
		User user = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];
		Test.startTest();
		List<IGOMComplianceReviewPartUtil.ComplianceReviewPart> complianceReviewParts;
		System.runAs(user){
			complianceReviewParts = IGOMComplianceReviewPartUtil.getComplianceReviewPartByComplianceReview(new List<Id>{complianceReview.Id});
		}
		Test.stopTest();

		System.assertEquals(200, complianceReviewParts.size());
	}

	@isTest
	private static void testGetVariationsOk() {
		Compliance_Review__c complianceReview = [SELECT Id FROM Compliance_Review__c LIMIT 1];
		Document__c gomDocument = [SELECT Id FROM Document__c WHERE RecordType.DeveloperName = :IGOMConstants.DOCUMENT.RECORD_TYPE.GOM LIMIT 1];

		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1].Account_Contact_Role__r.Contact__c;
		User user = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];
		Test.startTest();
		List<IGOMComplianceReviewPartUtil.ComplianceReviewPart> variations;
		System.runAs(user){
			variations = IGOMComplianceReviewPartUtil.getVariations(complianceReview.Id);
		}
		Test.stopTest();

		Map<String, IGOMComplianceReviewPartUtil.ComplianceReviewPart> procedureToVariation = new Map<String, IGOMComplianceReviewPartUtil.ComplianceReviewPart>();
		for (IGOMComplianceReviewPartUtil.ComplianceReviewPart complianceReviewPart : variations) {
			procedureToVariation.put(complianceReviewPart.igomAuditableProcedureName, complianceReviewPart);
		}
		System.assertEquals(2, procedureToVariation.keySet().size());
		System.assertEquals(IGOMConstants.PROCEDURE_COMPLIANCE.STATUS.VARIATION, procedureToVariation.get(SECT1_PROC1).variationStatus);
		System.assertEquals(IGOMConstants.PROCEDURE_COMPLIANCE.STATUS.VARIATION, procedureToVariation.get(SECT2_PROC1).variationStatus);
		System.assertEquals(TEST_PROV_TEXT, procedureToVariation.get(SECT1_PROC1).userProvisionProcedure);
		System.assertEquals(TEST_PROV_TEXT, procedureToVariation.get(SECT2_PROC1).userProvisionProcedure);
		System.assertEquals(complianceReview.Id, procedureToVariation.get(SECT1_PROC1).gapAnalysisId);
		System.assertEquals(complianceReview.Id, procedureToVariation.get(SECT2_PROC1).gapAnalysisId);
		System.assertEquals(gomDocument.Id, procedureToVariation.get(SECT1_PROC1).document);
		System.assertEquals(gomDocument.Id, procedureToVariation.get(SECT2_PROC1).document);
		System.assertEquals('Part 1', procedureToVariation.get(SECT1_PROC1).index.chapterName);
		System.assertEquals('Chapter 1', procedureToVariation.get(SECT1_PROC1).index.sectionName);
		System.assertEquals(SECT1_PROC1, procedureToVariation.get(SECT1_PROC1).index.subsectionName);
		System.assertEquals('Part 1', procedureToVariation.get(SECT2_PROC1).index.chapterName);
		System.assertEquals('Chapter 2', procedureToVariation.get(SECT2_PROC1).index.sectionName);
		System.assertEquals(SECT2_PROC1, procedureToVariation.get(SECT2_PROC1).index.subsectionName);
		System.assertEquals(false, procedureToVariation.get(SECT1_PROC1).igomAuditableProcedureIsCritical);
		System.assertEquals(false, procedureToVariation.get(SECT2_PROC1).igomAuditableProcedureIsCritical);
		System.assertEquals(false, procedureToVariation.get(SECT1_PROC1).isReviewed);
		System.assertEquals(false, procedureToVariation.get(SECT2_PROC1).isReviewed);
		System.assertEquals(false, procedureToVariation.get(SECT1_PROC1).modified);
		System.assertEquals(false, procedureToVariation.get(SECT2_PROC1).modified);
		System.assertEquals(null, procedureToVariation.get(SECT1_PROC1).notes);
		System.assertEquals(null, procedureToVariation.get(SECT2_PROC1).notes);
		System.assertEquals(null, procedureToVariation.get(SECT1_PROC1).statusValue);
		System.assertEquals(null, procedureToVariation.get(SECT2_PROC1).statusValue);
		System.assertEquals('GOM Ed.1.0 V.0.0 R.Test revision 0', procedureToVariation.get(SECT1_PROC1).userProvisionDocument);
		System.assertEquals('GOM Ed.1.0 V.0.0 R.Test revision 0', procedureToVariation.get(SECT2_PROC1).userProvisionDocument);
		System.assertEquals('GOM Ed.1.0 V.0.0 R.Test revision 0 - Test provision procedure text', procedureToVariation.get(SECT1_PROC1).variation);
		System.assertEquals('GOM Ed.1.0 V.0.0 R.Test revision 0 - Test provision procedure text', procedureToVariation.get(SECT2_PROC1).variation);
		System.assertEquals('Varies 1', procedureToVariation.get(SECT1_PROC1).variationComments);
		System.assertEquals('Varies 2', procedureToVariation.get(SECT2_PROC1).variationComments);
		System.assertEquals(null, procedureToVariation.get(SECT1_PROC1).variationCommentLang);
		System.assertEquals('Spanish', procedureToVariation.get(SECT2_PROC1).variationCommentLang);
		System.assertEquals(null, procedureToVariation.get(SECT1_PROC1).variationAlternativeComments);
		System.assertEquals('Varia 2', procedureToVariation.get(SECT2_PROC1).variationAlternativeComments);
	}

	@isTest
	private static void testGetVariationsUnauthorized() {
		// Remove role globally
		IGOM_Contact_Role_Detail__c contactRole = [SELECT Id, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		contactRole.Role__c = null;
        update contactRole;
		
		Compliance_Review__c complianceReview = [SELECT Id FROM Compliance_Review__c LIMIT 1];
		IGOM_Account_Role_Detail__c station = [SELECT Id FROM IGOM_Account_Role_Detail__c LIMIT 1];
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRole.Account_Contact_Role__r.Contact__c];

		Test.startTest();

		System.runAs(contactUser) {
			try {
				List<IGOMComplianceReviewPartUtil.ComplianceReviewPart> variations = IGOMComplianceReviewPartUtil.getVariations(complianceReview.Id);
				System.assert(false, EXC_NOT_THROWN);
			} catch (AuraHandledException error) {
				System.assert(true);
			} catch (Exception error) {
				System.assert(false, UNEX_EXC + error);
			}
		}

		Test.stopTest();
	}

	@isTest
	private static void testGetVariationsSinglePermission() {
		// Remove role from station
		IGOM_Contact_Role_Detail__c contactRole = [SELECT Id, Role__c, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		contactRole.Role__c = IGOMConstants.ROLES.ACKNOWLEDGER;
		update contactRole;
		
		Compliance_Review__c complianceReview = [SELECT Id FROM Compliance_Review__c LIMIT 1];
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRole.Account_Contact_Role__r.Contact__c];

		Test.startTest();

		System.runAs(contactUser) {
			try {
				List<IGOMComplianceReviewPartUtil.ComplianceReviewPart> variations = IGOMComplianceReviewPartUtil.getVariations(complianceReview.Id);
				System.assert(true);
			} catch (AuraHandledException error) {
				System.assert(false, UNEX_EXC + error);
			}
		}

		Test.stopTest();
	}

	@isTest
	private static void testUpsertProcedureComplianceInsertOk() {
		Compliance_Review__c complianceReview = [SELECT Id FROM Compliance_Review__c LIMIT 1];
		Document__c gomDocument = [SELECT Id FROM Document__c WHERE RecordType.DeveloperName = :IGOMConstants.DOCUMENT.RECORD_TYPE.GOM LIMIT 1];
		Document_Part__c documentPart = [SELECT Id FROM Document_Part__c WHERE Name__c = :SECT1_PROC2];

		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1].Account_Contact_Role__r.Contact__c;
		User user = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];
		Test.startTest();
		IGOMComplianceReviewPartUtil.ComplianceReviewPart upsertedComplianceReviewPart;
		System.runAs(user){
			IGOMComplianceReviewPartUtil.ComplianceReviewPart complianceReviewPart = new IGOMComplianceReviewPartUtil.ComplianceReviewPart();
			complianceReviewPart.gapAnalysisId = complianceReview.Id;
			complianceReviewPart.document = gomDocument.Id;
			complianceReviewPart.igomAuditableProcedureId = documentPart.Id;
			upsertedComplianceReviewPart = IGOMComplianceReviewPartUtil.upsertProcedureCompliance(complianceReviewPart);
		}
		Test.stopTest();

		List<Compliance_Review_Part__c> afterComplianceReviewParts = [SELECT Id FROM Compliance_Review_Part__c ORDER BY CreatedDate DESC];
		System.assertEquals(14, afterComplianceReviewParts.size());

		Compliance_Review_Part__c newComplianceReviewPart = afterComplianceReviewParts.get(0);
		System.assertEquals(newComplianceReviewPart.Id, upsertedComplianceReviewPart.id);

		System.assertEquals(complianceReview.Id, upsertedComplianceReviewPart.gapAnalysisId);
		System.assertEquals(gomDocument.Id, upsertedComplianceReviewPart.document);
		System.assertEquals(documentPart.Id, upsertedComplianceReviewPart.igomAuditableProcedureId);
		System.assertEquals(true, upsertedComplianceReviewPart.isReviewed);
	}

	@isTest
	private static void testUpsertProcedureComplianceUpdateOk() {
		Compliance_Review__c complianceReview = [SELECT Id FROM Compliance_Review__c LIMIT 1];
		Document__c gomDocument = [SELECT Id FROM Document__c WHERE RecordType.DeveloperName = :IGOMConstants.DOCUMENT.RECORD_TYPE.GOM LIMIT 1];
		Document_Part__c documentPart = [SELECT Id FROM Document_Part__c WHERE Name__c = :SECT1_PROC2];

		Compliance_Review_Part__c existingPart = [SELECT Id, Is_Reviewed__c, Variation_Comments__c FROM Compliance_Review_Part__c LIMIT 1];
		System.assertEquals(false, existingPart.Is_Reviewed__c);
		System.assertEquals('Varies 1', existingPart.Variation_Comments__c);

		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1].Account_Contact_Role__r.Contact__c;
		User user = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];
		Test.startTest();
		IGOMComplianceReviewPartUtil.ComplianceReviewPart upsertedComplianceReviewPart;
		IGOMComplianceReviewPartUtil.ComplianceReviewPart complianceReviewPart = new IGOMComplianceReviewPartUtil.ComplianceReviewPart();
		complianceReviewPart.id = existingPart.Id;
		complianceReviewPart.gapAnalysisId = complianceReview.Id;
		complianceReviewPart.document = gomDocument.Id;
		complianceReviewPart.igomAuditableProcedureId = documentPart.Id;
		complianceReviewPart.variationComments = 'Example variation comments';
		System.runAs(user){
			upsertedComplianceReviewPart = IGOMComplianceReviewPartUtil.upsertProcedureCompliance(complianceReviewPart);
		}
		Test.stopTest();

		List<Compliance_Review_Part__c> afterComplianceReviewParts = [SELECT Id FROM Compliance_Review_Part__c ORDER BY LastModifiedDate DESC];
		System.assertEquals(13, afterComplianceReviewParts.size());

		Compliance_Review_Part__c newComplianceReviewPart = afterComplianceReviewParts.get(0);
		System.assertEquals(newComplianceReviewPart.Id, upsertedComplianceReviewPart.id);

		System.assertEquals(complianceReview.Id, upsertedComplianceReviewPart.gapAnalysisId);
		System.assertEquals(gomDocument.Id, upsertedComplianceReviewPart.document);
		System.assertEquals(documentPart.Id, upsertedComplianceReviewPart.igomAuditableProcedureId);
		System.assertEquals(true, upsertedComplianceReviewPart.isReviewed);
		System.assertEquals('Example variation comments', upsertedComplianceReviewPart.variationComments);
	}

	@isTest
	private static void testUpsertProcedureComplianceInvalidId() {
		Compliance_Review__c complianceReview = [SELECT Id FROM Compliance_Review__c LIMIT 1];
		Account account = [SELECT Id FROM Account LIMIT 1];

		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1].Account_Contact_Role__r.Contact__c;
		User user = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];
		Test.startTest();
		
		IGOMComplianceReviewPartUtil.ComplianceReviewPart complianceReviewPart = new IGOMComplianceReviewPartUtil.ComplianceReviewPart();
		complianceReviewPart.id = account.Id;
		complianceReviewPart.gapAnalysisId = complianceReview.Id;
		try {
			IGOMComplianceReviewPartUtil.ComplianceReviewPart upsertedComplianceReviewPart;
			System.runAs(user){
				upsertedComplianceReviewPart = IGOMComplianceReviewPartUtil.upsertProcedureCompliance(complianceReviewPart);
			}
		} catch (TypeException error) {
			System.assert(true);
		} catch (Exception error) {
			System.assert(false, UNEX_EXC + error);
		}

		Test.stopTest();
	}

	@isTest
	private static void testUpsertProcedureComplianceUnauthorized() {
		// Remove role from station
		IGOM_Contact_Role_Detail__c contactRole = [SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		contactRole.Account_Role_Detail__c = null;
		update contactRole;
		
		Compliance_Review__c complianceReview = [SELECT Id FROM Compliance_Review__c LIMIT 1];
		Document__c gomDocument = [SELECT Id FROM Document__c WHERE RecordType.DeveloperName = :IGOMConstants.DOCUMENT.RECORD_TYPE.GOM LIMIT 1];
		Document_Part__c documentPart = [SELECT Id FROM Document_Part__c WHERE Name__c = :SECT1_PROC2];
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRole.Account_Contact_Role__r.Contact__c];

		Test.startTest();

		System.runAs(contactUser) {
			try {
				IGOMComplianceReviewPartUtil.ComplianceReviewPart complianceReviewPart = new IGOMComplianceReviewPartUtil.ComplianceReviewPart();
				complianceReviewPart.gapAnalysisId = complianceReview.Id;
				complianceReviewPart.document = gomDocument.Id;
				complianceReviewPart.igomAuditableProcedureId = documentPart.Id;
				IGOMComplianceReviewPartUtil.ComplianceReviewPart upsertedComplianceReviewPart = IGOMComplianceReviewPartUtil.upsertProcedureCompliance(complianceReviewPart);
				System.assert(false, EXC_NOT_THROWN);
			} catch (AuraHandledException error) {
				System.assert(true);
			} catch (Exception error) {
				System.assert(false, UNKNOWN_EXC + error);
			}
		}

		Test.stopTest();
	}

	@isTest
	private static void testDeleteProcedureComplianceOk() {
		Compliance_Review_Part__c existingPart = [SELECT Id, Is_Reviewed__c FROM Compliance_Review_Part__c LIMIT 1];

		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1].Account_Contact_Role__r.Contact__c;
		User user = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];
		Test.startTest();
		System.runAs(user){
			IGOMComplianceReviewPartUtil.deleteProcedureCompliance(existingPart.Id);
		}

		Test.stopTest();

		List<Compliance_Review_Part__c> afterComplianceReviewParts = [SELECT Id FROM Compliance_Review_Part__c ORDER BY LastModifiedDate DESC];
		System.assertEquals(12, afterComplianceReviewParts.size());
	}

	@isTest
	private static void testDeleteProcedureComplianceInvalidId() {
		Account account = [SELECT Id FROM Account LIMIT 1];

		Test.startTest();
		
		IGOMComplianceReviewPartUtil.deleteProcedureCompliance(account.Id);

		Test.stopTest();

		List<Compliance_Review_Part__c> afterComplianceReviewParts = [SELECT Id FROM Compliance_Review_Part__c];
		System.assertEquals(13, afterComplianceReviewParts.size());
		List<Account> afterAccounts = [SELECT Id FROM Account];
		System.assertEquals(3, afterAccounts.size());
	}

	@isTest
	private static void testDeleteProcedureComplianceUnauthorized() {
		// Remove role from station
		IGOM_Contact_Role_Detail__c contactRole = [SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		contactRole.Account_Role_Detail__c = null;
		update contactRole;
		
		Compliance_Review__c complianceReview = [SELECT Id FROM Compliance_Review__c LIMIT 1];
		Compliance_Review_Part__c existingPart = [SELECT Id, Is_Reviewed__c FROM Compliance_Review_Part__c LIMIT 1];
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRole.Account_Contact_Role__r.Contact__c];

		Test.startTest();

		System.runAs(contactUser) {
			try {
				IGOMComplianceReviewPartUtil.deleteProcedureCompliance(existingPart.Id);
				System.assert(false, EXC_NOT_THROWN);
			} catch (AuraHandledException error) {
				System.assert(true);
			} catch (Exception error) {
				System.assert(false, UNKNOWN_EXC + error);
			}
		}

		Test.stopTest();
	}

	@isTest
	private static void testDeleteProcedureComplianceInsufficientPermissions() {
		// Remove role from station
		IGOM_Contact_Role_Detail__c contactRole = [SELECT Id, Role__c, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		contactRole.Role__c = IGOMConstants.ROLES.ACKNOWLEDGER;
		update contactRole;
		
		Compliance_Review__c complianceReview = [SELECT Id FROM Compliance_Review__c LIMIT 1];
		Compliance_Review_Part__c existingPart = [SELECT Id, Is_Reviewed__c FROM Compliance_Review_Part__c LIMIT 1];
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRole.Account_Contact_Role__r.Contact__c];

		Test.startTest();

		System.runAs(contactUser) {
			try {
				IGOMComplianceReviewPartUtil.deleteProcedureCompliance(existingPart.Id);
				System.assert(false, EXC_NOT_THROWN);
			} catch (AuraHandledException error) {
				System.assert(true);
			} catch (Exception error) {
				System.assert(false, UNKNOWN_EXC + error);
			}
		}

		Test.stopTest();
	}


	@isTest
	private static void testMarkAsReviewedOk() {
		Compliance_Review_Part__c existingPart = [SELECT Id, Is_Reviewed__c, Variation_Comments__c FROM Compliance_Review_Part__c LIMIT 1];
		System.assertEquals(false, existingPart.Is_Reviewed__c);

		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1].Account_Contact_Role__r.Contact__c;
		User user = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];
		Test.startTest();
		IGOMComplianceReviewPartUtil.ComplianceReviewPart reviewedComplianceReview;
		System.runAs(user){
			reviewedComplianceReview = IGOMComplianceReviewPartUtil.markAsReviewed(existingPart.Id);
		}
		Test.stopTest();

		List<Compliance_Review_Part__c> afterComplianceReviewParts = [SELECT Id FROM Compliance_Review_Part__c ORDER BY LastModifiedDate DESC];

		Compliance_Review_Part__c newComplianceReviewPart = afterComplianceReviewParts.get(0);
		System.assertEquals(newComplianceReviewPart.Id, reviewedComplianceReview.id);

		System.assertEquals(true, reviewedComplianceReview.isReviewed);
	}

	@isTest
	private static void testMarkAsReviewedInvalidId() {
		Account account = [SELECT Id FROM Account LIMIT 1];

		Test.startTest();

		IGOMComplianceReviewPartUtil.ComplianceReviewPart reviewedComplianceReview = IGOMComplianceReviewPartUtil.markAsReviewed(account.Id);

		Test.stopTest();

		System.assert(reviewedComplianceReview == null, 'Mark as reviewed should return null');
	}

	@isTest
	private static void testMarkAsReviewedUnauthorized() {
		// Remove role from station
		IGOM_Contact_Role_Detail__c contactRole = [SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		contactRole.Account_Role_Detail__c = null;
		update contactRole;

		Compliance_Review_Part__c existingPart = [SELECT Id, Is_Reviewed__c, Variation_Comments__c FROM Compliance_Review_Part__c LIMIT 1];
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRole.Account_Contact_Role__r.Contact__c];

		Test.startTest();

		System.runAs(contactUser) {
			try {
				IGOMComplianceReviewPartUtil.ComplianceReviewPart reviewedComplianceReview = IGOMComplianceReviewPartUtil.markAsReviewed(existingPart.Id);
				System.assert(false, EXC_NOT_THROWN);
			} catch (AuraHandledException error) {
				System.assert(true);
			} catch (Exception error) {
				System.assert(false, UNKNOWN_EXC + error);
			}
		}

		Test.stopTest();
	}

	@isTest
	private static void testConfirmAllOk() {
		Compliance_Review__c complianceReview = [SELECT Id FROM Compliance_Review__c LIMIT 1];

		List<IGOMComplianceReviewPartUtil.ComplianceReviewPart> existingParts = IGOMComplianceReviewPartUtil.getComplianceReviewPartByComplianceReview(new List<Id>{ complianceReview.Id });
		for (IGOMComplianceReviewPartUtil.ComplianceReviewPart existingPart : existingParts) {
			System.assertEquals(false, existingPart.isReviewed);
		}

		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1].Account_Contact_Role__r.Contact__c;
		User user = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];
		Test.startTest();
		System.runAs(user){
			IGOMComplianceReviewPartUtil.confirmAllNonVariatingReferences(existingParts);
		}

		Test.stopTest();

		List<IGOMComplianceReviewPartUtil.ComplianceReviewPart> modifiedParts = IGOMComplianceReviewPartUtil.getComplianceReviewPartByComplianceReview(new List<Id>{ complianceReview.Id });
		Map<String, IGOMComplianceReviewPartUtil.ComplianceReviewPart> procedureToComplianceReviewPart = new Map<String, IGOMComplianceReviewPartUtil.ComplianceReviewPart>();
		for (IGOMComplianceReviewPartUtil.ComplianceReviewPart complianceReviewPart : modifiedParts) {
			procedureToComplianceReviewPart.put(complianceReviewPart.igomAuditableProcedureName, complianceReviewPart);
		}
		System.assertEquals(procedureToComplianceReviewPart.keySet().size(), 3);
		System.assertEquals(IGOMConstants.PROCEDURE_COMPLIANCE.STATUS.VARIATION, procedureToComplianceReviewPart.get(SECT1_PROC1).variationStatus);
		System.assertEquals(IGOMConstants.PROCEDURE_COMPLIANCE.STATUS.VARIATION, procedureToComplianceReviewPart.get(SECT2_PROC1).variationStatus);
		System.assertEquals(IGOMConstants.PROCEDURE_COMPLIANCE.STATUS.CONFORMITY, procedureToComplianceReviewPart.get(SECT1_PROC2).variationStatus);
		System.assertEquals(false, procedureToComplianceReviewPart.get(SECT1_PROC1).isReviewed);
		System.assertEquals(false, procedureToComplianceReviewPart.get(SECT2_PROC1).isReviewed);
		System.assertEquals(true, procedureToComplianceReviewPart.get(SECT1_PROC2).isReviewed);
	}

	@isTest
	private static void testConfirmAllMixedGaps() {
		Compliance_Review__c complianceReview = [SELECT Id FROM Compliance_Review__c LIMIT 1];
		Id otherGapAnalysisId = [SELECT Id FROM Compliance_Review__c WHERE Id != :complianceReview.Id LIMIT 1].Id;

		List<IGOMComplianceReviewPartUtil.ComplianceReviewPart> existingParts = IGOMComplianceReviewPartUtil.getComplianceReviewPartByComplianceReview(new List<Id>{ complianceReview.Id });
		existingParts[1].gapAnalysisId = otherGapAnalysisId;
		System.assertNotEquals(existingParts[1].gapAnalysisId, existingParts[0].gapAnalysisId);

		Test.startTest();
		
		try {
			IGOMComplianceReviewPartUtil.confirmAllNonVariatingReferences(existingParts);
		} catch (AuraHandledException error) {
			System.assert(true);
		} catch (Exception error) {
			System.assert(false, UNEX_EXC + error);
		}

		Test.stopTest();
	}

	@isTest
	private static void testConfirmAllEmpty() {
		Test.startTest();
		
		try {
			IGOMComplianceReviewPartUtil.confirmAllNonVariatingReferences(new List<IGOMCOmplianceReviewPartUtil.ComplianceReviewPart>());
		} catch (AuraHandledException error) {
			System.assert(true);
		} catch (Exception error) {
			System.assert(false, UNEX_EXC + error);
		}

		Test.stopTest();
	}

	@isTest
	private static void testConfirmAllUnauthorized() {
		// Remove role from station
		IGOM_Contact_Role_Detail__c contactRole = [SELECT Id, Account_Role_Detail__c, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		contactRole.Account_Role_Detail__c = null;
		update contactRole;

		Compliance_Review__c complianceReview = [SELECT Id FROM Compliance_Review__c LIMIT 1];
		List<IGOMComplianceReviewPartUtil.ComplianceReviewPart> existingParts = IGOMComplianceReviewPartUtil.getComplianceReviewPartByComplianceReview(new List<Id>{ complianceReview.Id });
		User contactUser = [SELECT Id FROM User WHERE ContactId = :contactRole.Account_Contact_Role__r.Contact__c];

		Test.startTest();

		System.runAs(contactUser) {
			try {
				IGOMComplianceReviewPartUtil.confirmAllNonVariatingReferences(existingParts);
				System.assert(false, EXC_NOT_THROWN);
			} catch (AuraHandledException error) {
				System.assert(true);
			} catch (Exception error) {
				System.assert(false, UNKNOWN_EXC + error);
			}
		}

		Test.stopTest();
	}

	@isTest
	private static void testGetVariationCommentAvailableLanguages() {
		Set<String> fieldLanguages = new Set<String>();
		for (Schema.PicklistEntry picklistValue : Compliance_Review_Part__c.Comment_Language__c.getDescribe().getPicklistValues()) {
			fieldLanguages.add(picklistValue.getLabel());
		}

		Test.startTest();

		List<String> languages = IGOMComplianceReviewPartUtil.getVariationCommentAvailableLanguages();
		
		Test.stopTest();
		
		System.assert(fieldLanguages.equals(new Set<String>(languages)));
	}
}