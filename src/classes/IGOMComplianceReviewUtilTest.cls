@isTest
public inherited sharing class IGOMComplianceReviewUtilTest {

	public static final String GAP_NAME = 'Compliance Review';
	public static final String NEW_GAP_NAME = 'New GAP analysis';
	public static final String EXC_NOT_THROWN = 'Exception not thrown';
	public static final String UNEXP_EXC_CAUGHT = 'Unexpected exception caught ';

	@TestSetup
	static void makeData() {
		// Generate stations
		List<SObject> stationObjects = IGOMTestFactory.generateIGOMUserFactory(1, IGOMConstants.ROLES.ADMIN, IGOMConstants.STATION.TYPE.GROUND_HANDLER_HQ).get(0);
		IGOM_Account_Role_Detail__c station = (IGOM_Account_Role_Detail__c) stationObjects.get(5);
		// Generate an IGOM and a GOM
		List<Document__c> documents = new List<Document__c>();
		Document__c igomDocument = IGOMTestFactory.documentFactoryCreation(1, null, 'IGOM Document', 'English', IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM)[0];
		documents.add(igomDocument);
		Document__c gomDocument = IGOMTestFactory.documentFactoryCreation(1, null, 'GOM Document', 'English', IGOMConstants.DOCUMENT.RECORD_TYPE.GOM)[0];
		documents.add(gomDocument);
		insert documents;
		// Generate IGOM parts
		List<Document_Part__c> documentParts = new List<Document_Part__c>();
		//Chapter 1
		Document_Part__c chapter1 = IGOMTestFactory.createDocumentPart(IGOMConstants.DOCUMENT_PART.CATEGORY.PART, igomDocument.Id, 1, 'Part 1');
		chapter1.External_Reference_ID__c = '0000';
		documentParts.add(chapter1);
		Document_Part__c section1_1 = IGOMTestFactory.createDocumentPart(IGOMConstants.DOCUMENT_PART.CATEGORY.CHAPTER, igomDocument.Id, 1, 'Chapter 1');
		section1_1.External_Reference_ID__c = '0001';
		documentParts.add(section1_1);
		Document_Part__c section1_2 = IGOMTestFactory.createDocumentPart(IGOMConstants.DOCUMENT_PART.CATEGORY.CHAPTER, igomDocument.Id, 1, 'Chapter 2');
		section1_2.External_Reference_ID__c = '0002';
		documentParts.add(section1_2);
		Document_Part__c subchapter1_1 = IGOMTestFactory.createDocumentPart(IGOMConstants.DOCUMENT_PART.CATEGORY.SECTION, igomDocument.Id, 1, 'Section 1 Proc. 1');
		subchapter1_1.External_Reference_ID__c = '0003';
		subchapter1_1.Version_Change_Status__c = IGOMConstants.DOCUMENT_PART.VERSION_CHANGE_STATUS.MODIFIED;
		documentParts.add(subchapter1_1);
		Document_Part__c subchapter1_2 = IGOMTestFactory.createDocumentPart(IGOMConstants.DOCUMENT_PART.CATEGORY.SECTION, igomDocument.Id, 2, 'Section 1 Proc. 2');
		subchapter1_2.External_Reference_ID__c = '0004';
		subchapter1_2.Version_Change_Status__c = IGOMConstants.DOCUMENT_PART.VERSION_CHANGE_STATUS.MODIFIED;
		documentParts.add(subchapter1_2);
		Document_Part__c subchapter1_3 = IGOMTestFactory.createDocumentPart(IGOMConstants.DOCUMENT_PART.CATEGORY.SECTION, igomDocument.Id, 1, 'Section 2 Proc. 1');
		subchapter1_3.External_Reference_ID__c = '0005';
		subchapter1_3.Version_Change_Status__c = IGOMConstants.DOCUMENT_PART.VERSION_CHANGE_STATUS.MODIFIED;
		documentParts.add(subchapter1_3);
		//Chapter 2
		Document_Part__c chapter2 = IGOMTestFactory.createDocumentPart(IGOMConstants.DOCUMENT_PART.CATEGORY.PART, igomDocument.Id, 1, 'Part 2');
		chapter2.External_Reference_ID__c = '0006';
		documentParts.add(chapter2);
		Document_Part__c section2_1 = IGOMTestFactory.createDocumentPart(IGOMConstants.DOCUMENT_PART.CATEGORY.CHAPTER, igomDocument.Id, 1, 'Chapter 1');
		section2_1.External_Reference_ID__c = '0007';
		documentParts.add(section2_1);
		Document_Part__c subchapter2_1 = IGOMTestFactory.createDocumentPart(IGOMConstants.DOCUMENT_PART.CATEGORY.SECTION, igomDocument.Id, 1, 'Section 1 Proc. 1');
		subchapter2_1.External_Reference_ID__c = '0008';
		documentParts.add(subchapter2_1);
		Document_Part__c subsubchapter2_1 = IGOMTestFactory.createDocumentPart(IGOMConstants.DOCUMENT_PART.CATEGORY.SUB_SECTION, igomDocument.Id, 1, 'Section 1 Proc. 1 Sub section 1');
		subsubchapter2_1.External_Reference_ID__c = '0009';
		subsubchapter2_1.Version_Change_Status__c = IGOMConstants.DOCUMENT_PART.VERSION_CHANGE_STATUS.MODIFIED;
		documentParts.add(subsubchapter2_1);
		insert documentParts;

		//Assign parents
		subchapter1_3.Parent__c = section1_2.Id;
		subchapter1_2.Parent__c = section1_1.Id;
		subchapter1_1.Parent__c = section1_1.Id;
		section1_2.Parent__c = chapter1.Id;
		section1_1.Parent__c = chapter1.Id;

		subsubchapter2_1.Parent__c = subchapter2_1.Id;
		subchapter2_1.Parent__c = section2_1.Id;
		section2_1.Parent__c = chapter2.Id;
		update documentParts;

		// Generate a compliance review
		Compliance_Review__c complianceReview = IGOMTestFactory.createComplianceReview(igomDocument.Id, station.Account_Role__c, GAP_NAME);
		insert complianceReview;

		// Generate the compliance review parts of the first chapter in this compliance review
		List<Compliance_Review_Part__c> complianceReviewParts = new List<Compliance_Review_Part__c>();
		Compliance_Review_Part__c complianceReviewPart1 = IGOMTestFactory.createComplianceReviewPart(complianceReview.Id, subchapter1_1.Id, gomDocument.Id);
		complianceReviewPart1.Status__c = IGOMConstants.PROCEDURE_COMPLIANCE.STATUS.VARIATION;
		complianceReviewPart1.Variation_Comments__c = 'Varies 1';
		complianceReviewParts.add(complianceReviewPart1);
		Compliance_Review_Part__c complianceReviewPart2 = IGOMTestFactory.createComplianceReviewPart(complianceReview.Id, subchapter1_2.Id, gomDocument.Id);
		complianceReviewParts.add(complianceReviewPart2);
		Compliance_Review_Part__c complianceReviewPart3 = IGOMTestFactory.createComplianceReviewPart(complianceReview.Id, subchapter1_3.Id, gomDocument.Id);
		complianceReviewPart3.Status__c = IGOMConstants.PROCEDURE_COMPLIANCE.STATUS.VARIATION;
		complianceReviewPart3.Variation_Comments__c = 'Varies 2';
		complianceReviewPart3.Variation_Alternative__c = 'Varia 2';
		complianceReviewPart3.Comment_Language__c = 'Spanish';
		complianceReviewParts.add(complianceReviewPart3);

		insert complianceReviewParts;
		
		insert new Apex_Setting__c(
			Name='RT valid to reopen attachment trigger',
			Text_1__c='CasesEurope,Cases_Global,CasesAmericas,CasesMENA,ExternalCasesIDFSglobal,Cases_China_North_Asia, ComplaintIDFS,'
			+  'Inter_DPCs,Invoicing_Collection_Cases,Cases_SIS_Help_Desk,InternalCasesEuropeSCE,CS_Process_IDFS_ISS,ID_Card_Application'
			);
	}

	/**
	 * @description Test the getSplitGapAnalysisTest method for a list of published splited compliance reviews.
	 */
	@isTest
	public static void getSplitGapAnalysisTest_isPublished(){
		//Publish existing gap analysis
		Compliance_Review__c gapAnalysis1 = [SELECT Id, Publish_Status__c FROM Compliance_Review__c WHERE Title__c = :GAP_NAME LIMIT 1];
		gapAnalysis1.Publish_Status__c = IGOMConstants.COMPLIANCE_REVIEW.STATUS.PUBLISHED;
		update gapAnalysis1;

		Document__c igomDocument = [SELECT Id FROM Document__c WHERE RecordType.DeveloperName = :IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM LIMIT 1];
		Document__c gomDocument = [SELECT Id FROM Document__c WHERE RecordType.DeveloperName = :IGOMConstants.DOCUMENT.RECORD_TYPE.GOM LIMIT 1];
		IGOM_Account_Role_Detail__c station = [SELECT Id, Account_Role__c FROM IGOM_Account_Role_Detail__c LIMIT 1];

		//Generate another compliance review with the document parts of the second chapter
		Compliance_Review__c gapAnalysis2 = IGOMTestFactory.createComplianceReview(igomDocument.Id, station.Account_Role__c, GAP_NAME);
		gapAnalysis2.Publish_Status__c = IGOMConstants.COMPLIANCE_REVIEW.STATUS.PUBLISHED;
		insert gapAnalysis2;

		//Add necessary compliance review parts
		Document_Part__c subSubSection = [SELECT Id FROM Document_Part__c WHERE Category__c = :IGOMConstants.DOCUMENT_PART.CATEGORY.SUB_SECTION LIMIT 1];
		Compliance_Review_Part__c complianceReviewPartGap2 = IGOMTestFactory.createComplianceReviewPart(gapAnalysis2.Id, subSubSection.Id, gomDocument.Id);
		complianceReviewPartGap2.Status__c = IGOMConstants.PROCEDURE_COMPLIANCE.STATUS.CONFORMITY;
		insert complianceReviewPartGap2;


		//Generate a compliance review in which there is already a covered document part
		Compliance_Review__c gapAnalysis3 = IGOMTestFactory.createComplianceReview(igomDocument.Id, station.Account_Role__c, GAP_NAME);
		gapAnalysis3.Publish_Status__c = IGOMConstants.COMPLIANCE_REVIEW.STATUS.PUBLISHED;
		insert gapAnalysis3;

		Compliance_Review_Part__c complianceReviewPartGap3 = IGOMTestFactory.createComplianceReviewPart(gapAnalysis3.Id, subSubSection.Id, gomDocument.Id);
		complianceReviewPartGap3.Status__c = IGOMConstants.PROCEDURE_COMPLIANCE.STATUS.CONFORMITY;
		insert complianceReviewPartGap3;

		List<Id> gapsInvolved = new List<Id>();
		Test.startTest();
		gapsInvolved = IGOMComplianceReviewUtil.getSplitGapAnalysis(igomDocument.Id, station.Account_Role__c, true);
		Test.stopTest();

		System.assertEquals(2, gapsInvolved.size());
		System.assert(!gapsInvolved.contains(complianceReviewPartGap3.Id));
	}

	/**
	 * @description Test the getSplitGapAnalysisTest method for a list of not published splited compliance reviews.
	 */
	@isTest
	public static void getSplitGapAnalysisTest_isNotPublished(){
		Document__c igomDocument = [SELECT Id FROM Document__c WHERE RecordType.DeveloperName = :IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM LIMIT 1];
		Document__c gomDocument = [SELECT Id FROM Document__c WHERE RecordType.DeveloperName = :IGOMConstants.DOCUMENT.RECORD_TYPE.GOM LIMIT 1];
		IGOM_Account_Role_Detail__c station = [SELECT Id, Account_Role__c FROM IGOM_Account_Role_Detail__c LIMIT 1];

		//Generate another compliance review with the document parts of the second chapter
		Compliance_Review__c gapAnalysis2 = IGOMTestFactory.createComplianceReview(igomDocument.Id, station.Account_Role__c, GAP_NAME);
		gapAnalysis2.Publish_Status__c = IGOMConstants.COMPLIANCE_REVIEW.STATUS.PUBLISHED;
		insert gapAnalysis2;

		//Add necessary compliance review parts
		Document_Part__c subSubSection = [SELECT Id FROM Document_Part__c WHERE Category__c = :IGOMConstants.DOCUMENT_PART.CATEGORY.SUB_SECTION LIMIT 1];
		Compliance_Review_Part__c complianceReviewPartGap2 = IGOMTestFactory.createComplianceReviewPart(gapAnalysis2.Id, subSubSection.Id, gomDocument.Id);
		complianceReviewPartGap2.Status__c = IGOMConstants.PROCEDURE_COMPLIANCE.STATUS.CONFORMITY;
		insert complianceReviewPartGap2;


		//Generate a compliance review in which there is already a covered document part
		Compliance_Review__c gapAnalysis3 = IGOMTestFactory.createComplianceReview(igomDocument.Id, station.Account_Role__c, GAP_NAME);
		insert gapAnalysis3;

		Compliance_Review_Part__c complianceReviewPartGap3 = IGOMTestFactory.createComplianceReviewPart(gapAnalysis3.Id, subSubSection.Id, gomDocument.Id);
		complianceReviewPartGap3.Status__c = IGOMConstants.PROCEDURE_COMPLIANCE.STATUS.CONFORMITY;
		insert complianceReviewPartGap3;

		List<Id> gapsInvolved = new List<Id>();
		Test.startTest();
		gapsInvolved = IGOMComplianceReviewUtil.getSplitGapAnalysis(igomDocument.Id, station.Account_Role__c, false);
		Test.stopTest();

		System.assertEquals(2, gapsInvolved.size());
		System.assert(!gapsInvolved.contains(complianceReviewPartGap2.Id));
	}


	/**
	 * @description Test the queryGapAnalysisById method.
	 */
	@isTest
	public static void queryGapAnalysisByIdTest(){
		Compliance_Review__c complianceRev = [SELECT Id, Name, Effective_Date__c, Publish_Status__c, Document__c,
		Document__r.Effective_Date__c, Title__c FROM Compliance_Review__c];

		Test.startTest();
		IGOMComplianceReviewUtil.ComplianceReview gap = IGOMComplianceReviewUtil.queryGapAnalysisById(complianceRev.Id);
		Test.stopTest();

		System.assertEquals(complianceRev.Id, gap.id);
		System.assertEquals(complianceRev.Document__c, gap.manualId);
		System.assertEquals(complianceRev.Title__c, gap.name);
		System.assertEquals(complianceRev.Document__r.Effective_Date__c, gap.effectiveDate);
		System.assertEquals(complianceRev.Publish_Status__c, gap.status);
		System.assertEquals(complianceRev.Effective_Date__c, gap.publishDate);
	}


	/**
	 * @description Test the getEditableGapAnalysisList method when there is a list of draft gap analyses.
	 */
	@isTest
	public static void getEditableGapAnalysisListTest_Success(){
		IGOM_Account_Role_Detail__c station = [SELECT Id, Account_Role__c FROM IGOM_Account_Role_Detail__c LIMIT 1];

		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1].Account_Contact_Role__r.Contact__c;
		User user = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];
		List<IGOMComplianceReviewUtil.ComplianceReview> compRevs;
		Test.startTest();
		System.runAs(user){
			compRevs = IGOMComplianceReviewUtil.getEditableGapAnalysisList(station.Id);
		}
		Test.stopTest();

		System.assertEquals(1, compRevs.size());
		System.assertEquals(75, compRevs.get(0).completition);
		System.assertEquals(4, compRevs.get(0).totalChildrenProcedures);
	}

	/**
	 * @description Test the getEditableGapAnalysisList method when the user has no permission.
	 */
	@isTest
	public static void getEditableGapAnalysisListTest_NoPermission(){
		//Limit profile access
		IGOM_Contact_Role_Detail__c contactRoleDetail = [SELECT Id, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		contactRoleDetail.Role__c = IGOMConstants.ROLES.ACKNOWLEDGER;
		update contactRoleDetail;
		User user = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c LIMIT 1];

		IGOM_Account_Role_Detail__c station = [SELECT Id, Account_Role__c FROM IGOM_Account_Role_Detail__c LIMIT 1];
		Test.startTest();
		System.runAs(user){
			try {
				List<IGOMComplianceReviewUtil.ComplianceReview> comps = IGOMComplianceReviewUtil.getEditableGapAnalysisList(station.Id);
				System.assert(false, EXC_NOT_THROWN);
			} catch (AuraHandledException exc) {
				System.assert(true);
			} catch (Exception error) {
				System.assert(false, UNEXP_EXC_CAUGHT + error);
			}
		}
		Test.stopTest();
	}


	/**
	 * @description Test the getImportableGapAnalysisList method.
	 */
	@isTest
	public static void getImportableGapAnalysisListTest_Success(){
		IGOM_Account_Role_Detail__c childStation = [SELECT Id, Account_Role__c FROM IGOM_Account_Role_Detail__c LIMIT 1];

		//Generate a couple of parent stations
		List<List<sObject>> stationObjectList = IGOMTestFactory.generateIGOMUserFactory(2, IGOMConstants.ROLES.ADMIN, IGOMConstants.STATION.TYPE.AIRLINE);
		List<sObject> station1Objects = stationObjectList.get(0);
		List<sObject> station2Objects = stationObjectList.get(1);

		Account_Role__c station1AccRole = (Account_Role__c)station1Objects.get(3);
		Account_Role__c station2AccRole = (Account_Role__c)station2Objects.get(3);

		IGOM_Account_Role_Detail__c station1 = (IGOM_Account_Role_Detail__c)station1Objects.get(5);
		IGOM_Account_Role_Detail__c station2 = (IGOM_Account_Role_Detail__c)station2Objects.get(5);


		//Generate relationships between accounts
		List<IGOM_Account_Role_Relationship__c> relationships = new List<IGOM_Account_Role_Relationship__c>();
		relationships.add(IGOMTestFactory.createIGOMAccountRoleRelationship(station1.Id, childStation.Id, childStation.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.HIERARCHICAL_REL, IGOMConstants.STATION.STATUS.ACTIVE));
		relationships.add(IGOMTestFactory.createIGOMAccountRoleRelationship(station2.Id, childStation.Id, childStation.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.HIERARCHICAL_REL, IGOMConstants.STATION.STATUS.ACTIVE));
		insert relationships;

		//Generate a compliance review for the parent stations
		Document__c igomDocument = [SELECT Id FROM Document__c WHERE RecordType.DeveloperName = :IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM LIMIT 1];
		List<Compliance_Review__c> parentStationsGaps = new List<Compliance_Review__c>();
		Compliance_Review__c station1Gap = IGOMTestFactory.createComplianceReview(igomDocument.Id, station1AccRole.Id, GAP_NAME);
		station1Gap.Publish_Status__c = IGOMConstants.COMPLIANCE_REVIEW.STATUS.TEMPLATE;
		parentStationsGaps.add(station1Gap);
		Compliance_Review__c station2Gap = IGOMTestFactory.createComplianceReview(igomDocument.Id, station2AccRole.Id, GAP_NAME);
		station2Gap.Publish_Status__c = IGOMConstants.COMPLIANCE_REVIEW.STATUS.TEMPLATE;
		parentStationsGaps.add(station2Gap);
		insert parentStationsGaps;

		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1].Account_Contact_Role__r.Contact__c;
		User user = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];
		List<IGOMComplianceReviewUtil.ComplianceReview> importableComplianceReviews = new List<IGOMComplianceReviewUtil.ComplianceReview>();
		Test.startTest();
		System.runAs(user){
			importableComplianceReviews = IGOMComplianceReviewUtil.getImportableGapAnalysisList(childStation.Id);
		}
		Test.stopTest();

		System.assertEquals(2, importableComplianceReviews.size());
		for (IGOMComplianceReviewUtil.ComplianceReview gap : importableComplianceReviews) {
			System.assert(gap.stationId == station1AccRole.Id || gap.stationId == station2AccRole.Id);
		}
	}

	/**
	 * @description Test the getImportableGapAnalysisList method when the user has no permission.
	 */
	@isTest
	public static void getImportableGapAnalysisListTest_NoPermission(){
		//Limit profile access
		IGOM_Contact_Role_Detail__c contactRoleDetail = [SELECT Id, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		contactRoleDetail.Role__c = IGOMConstants.ROLES.ACKNOWLEDGER;
		update contactRoleDetail;
		User user = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c LIMIT 1];

		IGOM_Account_Role_Detail__c station = [SELECT Id, Account_Role__c FROM IGOM_Account_Role_Detail__c LIMIT 1];
		Test.startTest();
		System.runAs(user){
			try {
				IGOMComplianceReviewUtil.getImportableGapAnalysisList(station.Id);
				System.assert(false, EXC_NOT_THROWN);
			} catch (AuraHandledException exc) {
				System.assert(true);
			} catch (Exception error) {
				System.assert(false, UNEXP_EXC_CAUGHT + error);
			}
		}
		Test.stopTest();
	}


	/**
	 * @description Test the deleteComplianceReview method.
	 */
	@isTest
	public static void deleteComplianceReviewTest_Success(){
		Compliance_Review__c gap = [SELECT Id FROM Compliance_Review__c LIMIT 1];

		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1].Account_Contact_Role__r.Contact__c;
		User user = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];
		Test.startTest();
		System.runAs(user){
			IGOMComplianceReviewUtil.deleteComplianceReview(gap.Id);
		}
		Test.stopTest();

		List<Compliance_Review__c> gapsLeft = [SELECT Id FROM Compliance_Review__c];
		System.assertEquals(0, gapsLeft.size());

	}

	/**
	 * @description Test the deleteComplianceReview method when the user has no permission.
	 */
	@isTest
	public static void deleteComplianceReviewTest_NoPermission(){
		//Limit profile access
		IGOM_Contact_Role_Detail__c contactRoleDetail = [SELECT Id, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		contactRoleDetail.Role__c = IGOMConstants.ROLES.ACKNOWLEDGER;
		update contactRoleDetail;
		User user = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c LIMIT 1];

		Compliance_Review__c gap = [SELECT Id FROM Compliance_Review__c LIMIT 1];
		Test.startTest();
		System.runAs(user){
			try {
				IGOMComplianceReviewUtil.deleteComplianceReview(gap.Id);
				System.assert(false, EXC_NOT_THROWN);
			} catch (AuraHandledException exc) {
				System.assert(true);
			} catch (Exception error) {
				System.assert(false, UNEXP_EXC_CAUGHT + error);
			}
		}
		Test.stopTest();
	}


	/**
	 * @description Test the importIGOMProceduresAsConformity method.
	 */
	@isTest
	public static void importIGOMProceduresAsConformityTest_Success(){
		Compliance_Review__c gap = [SELECT Id FROM Compliance_Review__c LIMIT 1];

		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1].Account_Contact_Role__r.Contact__c;
		User user = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];
		List<Compliance_Review_Part__c> partsFromGap_Old = [SELECT Status__c FROM Compliance_Review_Part__c WHERE Compliance_Review__c = :gap.Id];
		Test.startTest();
		System.runAs(user){
			IGOMComplianceReviewUtil.importIGOMProceduresAsConformity(gap.Id);
		}
		Test.stopTest();

		Set<Id> partIds = new Set<Id>();
		for (Compliance_Review_Part__c crp : partsFromGap_Old) {
			partIds.add(crp.Id);
		}
		List<Compliance_Review_Part__c> partsFromGap = [SELECT Status__c FROM Compliance_Review_Part__c WHERE Compliance_Review__c = :gap.Id AND Id NOT IN :partIds];
		System.assertEquals(4, partsFromGap.size());
		System.assertEquals(IGOMConstants.PROCEDURE_COMPLIANCE.STATUS.CONFORMITY, partsFromGap.get(0).Status__c);
	}

	/**
	 * @description Test the importIGOMProceduresAsConformity method when the user has no permission.
	 */
	@isTest
	public static void importIGOMProceduresAsConformityTest_NoPermission(){
		//Limit profile access
		IGOM_Contact_Role_Detail__c contactRoleDetail = [SELECT Id, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		contactRoleDetail.Role__c = IGOMConstants.ROLES.ACKNOWLEDGER;
		update contactRoleDetail;
		User user = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c LIMIT 1];

		Compliance_Review__c gap = [SELECT Id FROM Compliance_Review__c LIMIT 1];
		Test.startTest();
		System.runAs(user){
			try {
				IGOMComplianceReviewUtil.importIGOMProceduresAsConformity(gap.Id);
				System.assert(false, EXC_NOT_THROWN);
			} catch (AuraHandledException exc) {
				System.assert(true);
			} catch (Exception error) {
				System.assert(false, UNEXP_EXC_CAUGHT + error);
			}
		}
		Test.stopTest();
	}


	/**
	 * @description Test the getFullGapAnalysis method.
	 */
	@isTest
	public static void getFullGapAnalysisTest_Success(){
		// insert new Apex_Setting__c(
		// Name='RT valid to reopen attachment trigger',
		// Text_1__c='CasesEurope,Cases_Global,CasesAmericas,CasesMENA,ExternalCasesIDFSglobal,Cases_China_North_Asia, ComplaintIDFS,'
		// +  'Inter_DPCs,Invoicing_Collection_Cases,Cases_SIS_Help_Desk,InternalCasesEuropeSCE,CS_Process_IDFS_ISS,ID_Card_Application'
		// );
		Compliance_Review__c gap = [SELECT Id FROM Compliance_Review__c LIMIT 1];
		Compliance_Review_Part__c complianceRevPartToAddAttachment = [SELECT Id FROM Compliance_Review_Part__c LIMIT 1];
		insert new Attachment(
			Name = 'Test Attachment',
			Body = Blob.valueOf('Test body for the attachment'),
			ParentId = complianceRevPartToAddAttachment.Id
		);

		IGOM_Contact_Role_Detail__c contactRoleDetail = [SELECT Id, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		contactRoleDetail.Role__c = IGOMConstants.ROLES.ADMIN;
		update contactRoleDetail;
		User user = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c LIMIT 1];

		IGOMComplianceReviewUtil.ComplianceReview compRev;
		Test.startTest();
		System.runAs(user){
			compRev = IGOMComplianceReviewUtil.getFullGapAnalysis(gap.Id);
		}
		Test.stopTest();

		System.assertEquals(3, compRev.references.size());
		System.assertEquals(IGOMConstants.COMPLIANCE_REVIEW.STATUS.DRAFT, compRev.status);
		System.assertEquals(0, compRev.completedProcedureNumber);
	}

	/**
	 * @description Test the getFullGapAnalysis method when the user has no permission.
	 */
	@isTest
	public static void getFullGapAnalysisTest_NoPermission(){
		//Limit profile access
		IGOM_Contact_Role_Detail__c contactRoleDetail = [SELECT Id, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		contactRoleDetail.Role__c = IGOMConstants.ROLES.ACKNOWLEDGER;
		update contactRoleDetail;
		User user = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c LIMIT 1];

		Compliance_Review__c gap = [SELECT Id FROM Compliance_Review__c LIMIT 1];
		IGOMComplianceReviewUtil.ComplianceReview compRev;
		Test.startTest();
		System.runAs(user){
			try {
				compRev = IGOMComplianceReviewUtil.getFullGapAnalysis(gap.Id);
				System.assert(false, EXC_NOT_THROWN);
			} catch (AuraHandledException exc) {
				System.assert(true);
			} catch (Exception error) {
				System.assert(false, UNEXP_EXC_CAUGHT + error);
			}
		}
		Test.stopTest();
	}


	/**
	 * @description Test the createNewGapAnalysis method.
	 */
	@isTest
	public static void createNewGapAnalysisTest_Success(){
		IGOM_Account_Role_Detail__c station = [SELECT Id, Account_Role__c FROM IGOM_Account_Role_Detail__c LIMIT 1];
		Document__c igomDocument = [SELECT Id FROM Document__c WHERE RecordType.DeveloperName = :IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM LIMIT 1];

		List<Compliance_Review__c> complianceReviewsOld = [SELECT Id FROM Compliance_Review__c];
		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1].Account_Contact_Role__r.Contact__c;
		User user = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];

		IGOMComplianceReviewUtil.ComplianceReview createdGap;
		Test.startTest();
		System.runAs(user){
			createdGap = IGOMComplianceReviewUtil.createNewGapAnalysis(station.Id, NEW_GAP_NAME, igomDocument.Id);
		}
		Test.stopTest();

		System.assertNotEquals(null, createdGap);
		System.assertEquals(station.Account_Role__c, createdGap.stationId);
		System.assertEquals(igomDocument.Id, createdGap.manualId);
	}

	/**
	 * @description Test the createNewGapAnalysis method when the user has no permission.
	 */
	@isTest
	public static void createNewGapAnalysisTest_NoPermission(){
		//Limit profile access
		IGOM_Contact_Role_Detail__c contactRoleDetail = [SELECT Id, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		contactRoleDetail.Role__c = IGOMConstants.ROLES.ACKNOWLEDGER;
		update contactRoleDetail;
		User user = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c LIMIT 1];

		IGOM_Account_Role_Detail__c station = [SELECT Id, Account_Role__c FROM IGOM_Account_Role_Detail__c LIMIT 1];
		Document__c igomDocument = [SELECT Id FROM Document__c WHERE RecordType.DeveloperName = :IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM LIMIT 1];
		IGOMComplianceReviewUtil.ComplianceReview createdGap;
		Test.startTest();
		System.runAs(user){
			try {
				createdGap = IGOMComplianceReviewUtil.createNewGapAnalysis(station.Id, NEW_GAP_NAME, igomDocument.Id);
				System.assert(false, EXC_NOT_THROWN);
			} catch (AuraHandledException exc) {
				System.assert(true);
			} catch (Exception error) {
				System.assert(false, UNEXP_EXC_CAUGHT + error);
			}
		}
		Test.stopTest();
	}


	/**
	 * @description Test the importGapAnalysis method when the compliance review to retrieve is a template.
	 */
	@isTest
	public static void importGapAnalysisTest_TemplateSuccess(){
		IGOM_Account_Role_Detail__c station = [SELECT Id, Account_Role__c FROM IGOM_Account_Role_Detail__c LIMIT 1];

		Compliance_Review__c complianceReviewToCopy = [SELECT Id FROM Compliance_Review__c LIMIT 1];

		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1].Account_Contact_Role__r.Contact__c;
		User user = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];
		IGOMComplianceReviewUtil.ComplianceReview createdGap;
		Test.startTest();
		System.runAs(user){
			createdGap = IGOMComplianceReviewUtil.importGapAnalysis(station.Id, complianceReviewToCopy.Id, NEW_GAP_NAME);
		}
		Test.stopTest();

		System.assertNotEquals(null, createdGap);
		System.assertEquals(station.Account_Role__c, createdGap.stationId);
		//Check the copied compliance review part (the same amount as created in test setup)
		System.assertEquals(3, createdGap.references.size());
	}

	/**
	 * @description Test the importGapAnalysis method when the compliance review to retrieve is not a template.
	 */
	@isTest
	public static void importGapAnalysisTest_PublishSuccess(){
		IGOM_Account_Role_Detail__c station = [SELECT Id, Account_Role__c FROM IGOM_Account_Role_Detail__c LIMIT 1];

		Compliance_Review__c complianceReviewToCopy = [SELECT Id FROM Compliance_Review__c LIMIT 1];
		complianceReviewToCopy.Publish_Status__c = IGOMConstants.COMPLIANCE_REVIEW.STATUS.PUBLISHED;
		update complianceReviewToCopy;

		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1].Account_Contact_Role__r.Contact__c;
		User user = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];
		IGOMComplianceReviewUtil.ComplianceReview createdGap;
		Test.startTest();
		System.runAs(user){
			createdGap = IGOMComplianceReviewUtil.importGapAnalysis(station.Id, complianceReviewToCopy.Id, NEW_GAP_NAME);
		}
		Test.stopTest();

		System.assertNotEquals(null, createdGap);
		System.assertEquals(station.Account_Role__c, createdGap.stationId);
		//Check the copied compliance review part (the same amount as created in test setup)
		System.assertEquals(3, createdGap.references.size());
	}

	/**
	 * @description Test the importGapAnalysis method when the importable gap analysis is not related to the station (and not a parent of
	 * the station) that is trying to copy it.
	 */
	@isTest
	public static void importGapAnalysisTest_DifferentStation(){
		List<sObject> stationObjects = IGOMTestFactory.generateIGOMUserFactory(1, IGOMConstants.ROLES.ACKNOWLEDGER, IGOMConstants.STATION.TYPE.AIRLINE).get(0);
		IGOM_Account_Role_Detail__c station = (IGOM_Account_Role_Detail__c)stationObjects.get(5);

		Compliance_Review__c complianceReviewToCopy = [SELECT Id FROM Compliance_Review__c LIMIT 1];

		IGOMComplianceReviewUtil.ComplianceReview createdGap;
		Test.startTest();
		try {
			createdGap = IGOMComplianceReviewUtil.importGapAnalysis(station.Id, complianceReviewToCopy.Id, NEW_GAP_NAME);
			System.assert(false, EXC_NOT_THROWN);
		} catch (AuraHandledException exc) {
			System.assert(true);
		} catch (Exception error) {
			System.assert(false, UNEXP_EXC_CAUGHT + error);
		}
		Test.stopTest();
	}

	/**
	 * @description Test the importGapAnalysis method when the user does not have the right permissions.
	 */
	@isTest
	public static void importGapAnalysisTest_NoPermission(){
		//Limit profile access
		IGOM_Contact_Role_Detail__c contactRoleDetail = [SELECT Id, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		contactRoleDetail.Role__c = IGOMConstants.ROLES.ACKNOWLEDGER;
		update contactRoleDetail;
		User user = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c LIMIT 1];
		IGOM_Account_Role_Detail__c station = [SELECT Id, Account_Role__c FROM IGOM_Account_Role_Detail__c LIMIT 1];
		Compliance_Review__c complianceReviewToCopy = [SELECT Id FROM Compliance_Review__c LIMIT 1];

		IGOMComplianceReviewUtil.ComplianceReview createdGap;
		Test.startTest();
		System.runAs(user){
			try {
				createdGap = IGOMComplianceReviewUtil.importGapAnalysis(station.Id, complianceReviewToCopy.Id, NEW_GAP_NAME);
				System.assert(false, EXC_NOT_THROWN);
			} catch (AuraHandledException exc) {
				System.assert(true);
			} catch (Exception error) {
				System.assert(false, UNEXP_EXC_CAUGHT + error);
			}
		}
		Test.stopTest();
	}


	/**
	 * @description Test the publishGapAnalysis method when the entire compliance review is published.
	 */
	@isTest
	public static void publishGapAnalysisTest_FullPublish(){
		Date today = Date.today();

		Compliance_Review__c gapAnalysis = [SELECT Id FROM Compliance_Review__c LIMIT 1];
		List<Id> chaptersToPublish = new List<Id>();
		for(Document_Part__c chapter : [SELECT Id FROM Document_Part__c WHERE Category__c = :IGOMConstants.DOCUMENT_PART.CATEGORY.PART]){
			chaptersToPublish.add(chapter.Id);
		}

		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1].Account_Contact_Role__r.Contact__c;
		User user = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];
		IGOMComplianceReviewUtil.ComplianceReview createdGap;
		Date effectiveDate = Date.newInstance(today.year()+1, today.month(), today.day());
		Test.startTest();
		System.runAs(user){
			createdGap = IGOMComplianceReviewUtil.publishGapAnalysis(gapAnalysis.Id, chaptersToPublish, effectiveDate, effectiveDate.addDays(-9), new Map<String, List<Id>>());
		}
		Test.stopTest();

		System.assertEquals(IGOMConstants.COMPLIANCE_REVIEW.STATUS.PUBLISHED, createdGap.status);
		System.assertEquals(effectiveDate, createdGap.publishDate);
		System.assertEquals(gapAnalysis.Id, createdGap.id);
		Date reminderDate = [SELECT Notification_Date__c FROM Compliance_Review__c WHERE Id = :createdGap.id LIMIT 1].get(0).Notification_Date__c;
		System.assertEquals(effectiveDate.addDays(-9), reminderDate);
	}

	/**
	 * @description Test the publishGapAnalysis method when a part of the compliance review is published.
	 */
	@isTest
	public static void publishGapAnalysisTest_PartialPublish(){
		Date today = Date.today();
		Compliance_Review__c gapAnalysis = [SELECT Id FROM Compliance_Review__c LIMIT 1];
		List<Id> chaptersToPublish = new List<Id>();
		for(Document_Part__c chapter : [SELECT Id FROM Document_Part__c
		WHERE Category__c = :IGOMConstants.DOCUMENT_PART.CATEGORY.PART LIMIT 1]){
			chaptersToPublish.add(chapter.Id);
		}

		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1].Account_Contact_Role__r.Contact__c;
		User user = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];
		IGOMComplianceReviewUtil.ComplianceReview createdGap;
		Date effectiveDate = Date.newInstance(today.year()+1, today.month(), today.day());
		Test.startTest();
		System.runAs(user){
			createdGap = IGOMComplianceReviewUtil.publishGapAnalysis(gapAnalysis.Id, chaptersToPublish, effectiveDate, effectiveDate.addDays(-9), new Map<String, List<Id>>());
		}
		Test.stopTest();

		System.assertEquals(IGOMConstants.COMPLIANCE_REVIEW.STATUS.PUBLISHED, createdGap.status);
		System.assertEquals(effectiveDate, createdGap.publishDate);
		System.assertNotEquals(gapAnalysis.Id, createdGap.id);
		Date reminderDate = [SELECT Notification_Date__c FROM Compliance_Review__c WHERE Id = :createdGap.id LIMIT 1].get(0).Notification_Date__c;
		System.assertEquals(effectiveDate.addDays(-9), reminderDate);
	}

	/**
	 * @description Test the publishGapAnalysis method when the user does not have the right permissions.
	 */
	@isTest
	public static void publishGapAnalysisTest_NoPermission(){
		//Limit profile access
		IGOM_Contact_Role_Detail__c contactRoleDetail = [SELECT Id, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		contactRoleDetail.Role__c = IGOMConstants.ROLES.ACKNOWLEDGER;
		update contactRoleDetail;

		User user = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c LIMIT 1];
		Compliance_Review__c gapAnalysis = [SELECT Id FROM Compliance_Review__c LIMIT 1];
		List<Id> chaptersToPublish = new List<Id>();
		for(Document_Part__c chapter : [SELECT Id FROM Document_Part__c WHERE Category__c = :IGOMConstants.DOCUMENT_PART.CATEGORY.PART]){
			chaptersToPublish.add(chapter.Id);
		}
		Date today = Date.today();
		Date effectiveDate = Date.newInstance(today.year()+1, today.month(), today.day());

		IGOMComplianceReviewUtil.ComplianceReview createdGap;
		Test.startTest();
		System.runAs(user){
			try {
				createdGap = IGOMComplianceReviewUtil.publishGapAnalysis(gapAnalysis.Id, chaptersToPublish, effectiveDate, effectiveDate.addDays(-9), new Map<String, List<Id>>());
				System.assert(false, EXC_NOT_THROWN);
			} catch (AuraHandledException exc) {
				System.assert(true);
			} catch (Exception error) {
				System.assert(false, UNEXP_EXC_CAUGHT + error);
			}
		}
		Test.stopTest();
	}


	/**
	 * @description Test the getActualGapAnalyses method.
	 */
	@isTest
	public static void getActualGapAnalysesTest_Success(){
		IGOM_Account_Role_Detail__c station = [SELECT Id, Account_Role__c FROM IGOM_Account_Role_Detail__c LIMIT 1];
		Document__c igom = [SELECT Id FROM Document__c WHERE RecordType.Name = :IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM LIMIT 1];

		List<IGOMComplianceReviewUtil.ComplianceReview> retrievedGaps = new List<IGOMComplianceReviewUtil.ComplianceReview>();
		Test.startTest();
		retrievedGaps = IGOMComplianceReviewUtil.getActualGapAnalyses(station.Account_Role__c, igom.Id, false);
		Test.stopTest();

		List<Compliance_Review__c> complianceReviewsFromTestSetup = [SELECT Id FROM Compliance_Review__c WHERE Document__c = :igom.Id AND Station__c = :station.Account_Role__c];
		System.assertEquals(complianceReviewsFromTestSetup.size(), retrievedGaps.size());
	}

	/**
	 * @description Test the getActualGapAnalyses method with only the published gaps.
	 */
	@isTest
	public static void getActualGapAnalysesTest_Published_Success(){
		IGOM_Contact_Role_Detail__c contactRoleDetail = [SELECT Id, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		contactRoleDetail.Role__c = IGOMConstants.ROLES.ADMIN;
		update contactRoleDetail;
		User user = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c LIMIT 1];

		IGOM_Account_Role_Detail__c station = [SELECT Id, Account_Role__c FROM IGOM_Account_Role_Detail__c LIMIT 1];
		Document__c igom = [SELECT Id FROM Document__c WHERE RecordType.Name = :IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM LIMIT 1];

		List<IGOMComplianceReviewUtil.ComplianceReview> retrievedGaps = new List<IGOMComplianceReviewUtil.ComplianceReview>();
		Test.startTest();
		System.runAs(user){
			retrievedGaps = IGOMComplianceReviewUtil.getActualGapAnalyses(station.Account_Role__c, igom.Id, true);
		}
		Test.stopTest();

		List<Compliance_Review__c> complianceReviewsFromTestSetup = [SELECT Id FROM Compliance_Review__c WHERE Document__c = :igom.Id
		AND Station__c = :station.Account_Role__c AND Publish_Status__c = :IGOMConstants.COMPLIANCE_REVIEW.STATUS.PUBLISHED];
		System.assertEquals(complianceReviewsFromTestSetup.size(), retrievedGaps.size());
	}


	/**
	 * @description Test the getAllPublishedGapAnalyses method.
	 */
	@isTest
	public static void getAllPublishedGapAnalysesTest_Success(){
		Compliance_Review__c gapAnalysis = [SELECT Id, Station__c FROM Compliance_Review__c LIMIT 1];
		gapAnalysis.Publish_Status__c = IGOMConstants.COMPLIANCE_REVIEW.STATUS.PUBLISHED;
		update gapAnalysis;

		IGOM_Account_Role_Detail__c station = [SELECT Id, Account_Role__c FROM IGOM_Account_Role_Detail__c LIMIT 1];
		Document__c igomDocument = [SELECT Id FROM Document__c WHERE RecordType.DeveloperName = :IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM LIMIT 1];

		Compliance_Review__c gapAnalysis_New = IGOMTestFactory.createComplianceReview(igomDocument.Id, station.Account_Role__c, 'Newly published gap');
		gapAnalysis_New.Publish_Status__c = IGOMConstants.COMPLIANCE_REVIEW.STATUS.PUBLISHED;
		insert gapAnalysis_New;

		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1].Account_Contact_Role__r.Contact__c;
		User user = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];
		List<IGOMComplianceReviewUtil.ComplianceReview> gaps = new List<IGOMComplianceReviewUtil.ComplianceReview>();
		Test.startTest();
		System.runAs(user){
			gaps = IGOMComplianceReviewUtil.getAllPublishedGapAnalyses(station.Id);	
		}
		gaps = IGOMComplianceReviewUtil.getAllPublishedGapAnalyses(station.Id);
		Test.stopTest();

		System.assertEquals(2, gaps.size());
	}

	/**
	 * @description Test the getAllPublishedGapAnalyses method when the user does not have the right permissions.
	 */
	@isTest
	public static void getAllPublishedGapAnalysesTest_NoPermission(){
		//Limit profile access
		IGOM_Contact_Role_Detail__c contactRoleDetail = [SELECT Id, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		contactRoleDetail.Role__c = null;
		update contactRoleDetail;

		User user = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c LIMIT 1];

		IGOM_Account_Role_Detail__c station = [SELECT Id, Account_Role__c FROM IGOM_Account_Role_Detail__c LIMIT 1];
		List<IGOMComplianceReviewUtil.ComplianceReview> gaps = new List<IGOMComplianceReviewUtil.ComplianceReview>();
		Test.startTest();
		System.runAs(user){
			try {
				gaps = IGOMComplianceReviewUtil.getAllPublishedGapAnalyses(station.Id);
				System.assert(false, EXC_NOT_THROWN);
			} catch (AuraHandledException exc) {
				System.assert(true);
			} catch (Exception error) {
				System.assert(false, UNEXP_EXC_CAUGHT + error);
			}
		}
		Test.stopTest();
	}


	/**
	 * @description Test the checkPermissionOnComplianceReview method when the user has the permission.
	 */
	@isTest
	public static void checkPermissionOnComplianceReviewTest_Success(){
		//Limit profile access
		IGOM_Contact_Role_Detail__c contactRoleDetail = [SELECT Id, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		contactRoleDetail.Role__c = IGOMConstants.ROLES.ACKNOWLEDGER;
		update contactRoleDetail;

		User user = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c LIMIT 1];

		Compliance_Review__c gapAnalysis = [SELECT Id, Station__c FROM Compliance_Review__c LIMIT 1];
		Id stationId;
		Test.startTest();
		System.runAs(user){
			stationId = IGOMComplianceReviewUtil.checkPermissionOnComplianceReview(gapAnalysis.Id, IGOMConstants.PERMISSIONS.VIEW_OWN_DASHBOARD);
		}
		Test.stopTest();
		IGOM_Account_Role_Detail__c station = [SELECT Id, Account_Role__c FROM IGOM_Account_Role_Detail__c LIMIT 1];

		System.assertEquals(station.Id, stationId);
	}

	/**
	 * @description Test the checkPermissionOnComplianceReview method when the user does not have the permission.
	 */
	@isTest
	public static void checkPermissionOnComplianceReviewTest_Error(){
		//Limit profile access
		IGOM_Contact_Role_Detail__c contactRoleDetail = [SELECT Id, Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1];
		contactRoleDetail.Role__c = IGOMConstants.ROLES.ACKNOWLEDGER;
		update contactRoleDetail;
		User user = [SELECT Id FROM User WHERE ContactId = :contactRoleDetail.Account_Contact_Role__r.Contact__c LIMIT 1];

		Compliance_Review__c gapAnalysis = [SELECT Id, Station__c FROM Compliance_Review__c LIMIT 1];
		Id stationId;
		Test.startTest();
		System.runAs(user){
			try {
				stationId = IGOMComplianceReviewUtil.checkPermissionOnComplianceReview(gapAnalysis.Id, IGOMConstants.PERMISSIONS.EDIT_GAP);
				System.assert(false, EXC_NOT_THROWN);
			} catch (AuraHandledException exc) {
				System.assert(true);
			} catch (Exception error) {
				System.assert(false, UNEXP_EXC_CAUGHT + error);
			}
		}
		Test.stopTest();
	}
}