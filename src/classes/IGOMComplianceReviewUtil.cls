/**
 * @description	  Class to contain all the functions related to the Compliance_Review__c object
 */
public without sharing class IGOMComplianceReviewUtil {

	/**
	 * DAO Object containing the data from a Compliance_Review__c record
	 */
	public class ComplianceReview {
		// Writable
		@AuraEnabled public Id id { get; set; }
		@AuraEnabled public String name { get; set; }
		@AuraEnabled public Id manualId { get; set; }
		@AuraEnabled public Id stationId { get; set; }
		@AuraEnabled public Id previousVersionId { get; set; }
		@AuraEnabled public String status { get; set; }
		@AuraEnabled public List<IGOMComplianceReviewPartUtil.ComplianceReviewPart> references { get; set; }
		// Read-only
		@AuraEnabled public Date publishDate;
		@AuraEnabled public Date effectiveDate;
		@AuraEnabled public String complianceDocumentVersion;
		@AuraEnabled public Decimal completition;
		@AuraEnabled public Decimal completedProcedureNumber;
		@AuraEnabled public Decimal totalChildrenProcedures;

		public ComplianceReview() {
			this.name = 'GAP Analysis Draft';
			this.status = IGOMConstants.COMPLIANCE_REVIEW.STATUS.DRAFT;
			this.references = new List<IGOMComplianceReviewPartUtil.ComplianceReviewPart>();
		}

		public ComplianceReview(Compliance_Review__c complianceReview) {
			this();
			this.id = complianceReview.Id;
			this.manualId = complianceReview.Document__c;
			this.stationId = complianceReview.Station__c;
			this.previousVersionId = complianceReview.Previous_Version__c;
			this.name = complianceReview.Title__c;
			this.status = complianceReview.Publish_Status__c;
			this.publishDate = complianceReview.Effective_Date__c;
			this.completition = 0;
			this.completedProcedureNumber = 0;
			this.totalChildrenProcedures = 0;
			if (complianceReview.Document__r != null) {
				this.complianceDocumentVersion = IGOMDocumentUtil.getDocumentReference(new Document__c(
					Abbreviated_Name__c = complianceReview.Document__r.Abbreviated_Name__c,
					Edition__c = complianceReview.Document__r.Edition__c,
					Version__c = complianceReview.Document__r.Version__c,
					Revision__c = complianceReview.Document__r.Revision__c
				));
				this.effectiveDate = complianceReview.Document__r.Effective_Date__c;
			}
		}

		public Compliance_Review__c toSalesforce(Boolean includeId) {
			return new Compliance_Review__c(
				Id = includeId ? this.id : null,
				RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Compliance_Review__c', IGOMConstants.COMPLIANCE_REVIEW.RECORD_TYPE.IGOM),
				Publish_Status__c = this.status,
				Title__c = this.name,
				Document__c = this.manualId,
				Station__c = this.stationId,
				Previous_Version__c = this.previousVersionId
			);
		}
	}

	/**
	 * @description	Retrieve a list of Ids form a complete GAP Analysis, since it can be published by chapters (2 chapters, 2 gap analysis ids)
	 * @param		manualId <Document id representing the IGOM document>
	 * @param		stationId <Active station id>
	 * @param		isPublished <Indicate if the gap analysis status is published or not>
	 * @return		List<Id> <List of Ids that are considered the "same" GAP Analysis>
	 */
	public static List<Id> getSplitGapAnalysis(Id manualId, Id stationId, Boolean isPublished) {
		List<Id> gapAnalysisIds = new List<Id>();
		List<String> gapAnalysisExpectedStatus;
		if (isPublished) {
			gapAnalysisExpectedStatus = new List<String>{ IGOMConstants.COMPLIANCE_REVIEW.STATUS.PUBLISHED };
		} else {
			gapAnalysisExpectedStatus = new List<String>{
				IGOMConstants.COMPLIANCE_REVIEW.STATUS.DRAFT,
				IGOMConstants.COMPLIANCE_REVIEW.STATUS.PUBLISHED
			};
		}
		Set<String> addedChapterPermIds = new Set<String>();
		Map<String, String> permidsToChapter = IGOMDocumentUtil.getPermidsToChapter(manualId);
		// Get the last one from each chapter
		for (Compliance_Review__c complianceReview :
			 [SELECT Id, Title__c, (SELECT Id, Standard_Document_Part__c, Standard_Document_Part__r.External_Reference_ID__c FROM Compliance_Review_Parts__r)
			  FROM Compliance_Review__c
			  WHERE Document__c = :manualId AND Station__c = :stationId AND Publish_Status__c IN :gapAnalysisExpectedStatus
			  ORDER BY CreatedDate DESC])
		{
			Set<String> containsChapterPermIds = new Set<String>();
			// Get all the chapter ids of the compliance review
			for (Compliance_review_part__c complianceReviewPart : complianceReview.Compliance_Review_Parts__r) {
				String chapter = permidsToChapter.get(complianceReviewPart.Standard_Document_Part__r.External_Reference_ID__c);
				if (chapter != null) {
					containsChapterPermIds.add(chapter);
				}
			}
			List<String> chaptersToAddFromGap = new List<String>();
			// If any of the chapters is added leave this gap
			for (String chapterPermId : containsChapterPermIds) {
				if (!addedChapterPermIds.contains(chapterPermId)) {
					gapAnalysisIds.add(complianceReview.Id);
					addedChapterPermIds.addAll(containsChapterPermIds);
				}
			}
		}
		return gapAnalysisIds;
	}

	/**
	 * @description	Retrieve the basic information associated just to the Compliance Review object
	 * @param		gapAnalysisId <Id of the compliance review>
	 * @return		ComplianceReview <Compliance Review object with info but not the references or the information associated to childs>
	 */
	public static ComplianceReview queryGapAnalysisById(Id gapAnalysisId) {
		return new ComplianceReview(
			[SELECT Id, Name, Effective_Date__c, Publish_Status__c, Document__c, Document__r.Effective_Date__c, Title__c, Station__c,
				   Previous_Version__c, Document__r.Abbreviated_Name__c, Document__r.Edition__c, Document__r.Version__c, Document__r.Revision__c
			FROM Compliance_Review__c
			WHERE Id = :gapAnalysisId AND RecordType.Name = :IGOMConstants.COMPLIANCE_REVIEW.RECORD_TYPE.IGOM
			LIMIT 1].get(0));
	}

	/**
	 * @description	Retrieve the complete information associated to a Compliance Review object, as a Salesforce object
	 * @param		gapAnalysisId <Id of the compliance review>
	 * @return		Compliance_Review__c <Complete Compliance_Review__c object with every reference>
	 */
	public static Compliance_Review__c queryFullGapAnalysisById(Id gapAnalysisId) {
		return [SELECT Id, Name, Publish_Status__c, Document__c, Document__r.Effective_Date__c, Title__c, Document__r.Abbreviated_Name__c,
		Document__r.Edition__c, Document__r.Version__c, Document__r.Revision__c, Effective_Date__c, Station__c, Previous_Version__c
			FROM Compliance_Review__c
			WHERE Id = :gapAnalysisId AND RecordType.Name = :IGOMConstants.COMPLIANCE_REVIEW.RECORD_TYPE.IGOM
			LIMIT 1];
	}

	/**
	 * @description	Retrieve all the compliance review parts of a compliance review by it's id
	 * @param		gapAnalysisId <Id of the compliance review>
	 * @return		List<Compliance_Review_Part__c> <List of all the compliance review parts related to the compliance review>
	 */
	private static List<Compliance_Review_Part__c> queryGapAnalysisPartsByGapId(Id gapAnalysisId) {
		return [SELECT Id, Name, Comments__c, Document__c, Validity__c, Status__c, Variation_Comments__c, Standard_Document_Part__r.Document__r.Revision__c,
			Document__r.Abbreviated_Name__c, Document__r.Edition__c, Document__r.Version__c, Document__r.Revision__c,
			Variation_Alternative__c, Comment_Language__c, Compliance_Review__c, User_Provision_Procedure__c, Standard_Document_Part__r.Document__r.Abbreviated_Name__c,
			Standard_Document_Part__c, Standard_Document_Part__r.Category__c, Standard_Document_Part__r.Name__c, Standard_Document_Part__r.Version_Change_Status__c,
			Standard_Document_Part__r.Is_Safety_Critical__c, Standard_Document_Part__r.External_Reference_ID__c, Standard_Document_Part__r.Document__c,
			Standard_Document_Part__r.Document__r.Is_Active__c, Is_Reviewed__c, Standard_Document_Part__r.Document__r.Edition__c, Standard_Document_Part__r.Document__r.Version__c
			FROM Compliance_Review_Part__c WHERE Compliance_Review__c = :gapAnalysisId AND Compliance_Review__r.RecordType.Name = :IGOMConstants.COMPLIANCE_REVIEW.RECORD_TYPE.IGOM];
	}

	/**
	 * @description	Recovers the list of draft gap analysis that are managed by the active user
	 * @param		stationId <Active station id>
	 * @return		List<ComplianceReview> <List of GAPAnalysisInfo objects representing the gap analysis that have a Draft status>
	 */
	@AuraEnabled(cacheable=true)
	public static List<ComplianceReview> getEditableGapAnalysisList(Id stationId) {
		if (!IGOMPermissions.hasPermission(stationId, IGOMConstants.PERMISSIONS.EDIT_GAP)) {
			throw new AuraHandledException(String.format(IGOMConstants.ERRORS.REQUIRED_PERMISSIONS_MISSING_ERROR, new List<Object>{'create a GAP Analysis'}));
		}

		IGOMStationUtil.Station ownStation =IGOMStationUtil.getOwnStation(stationId);

		List<Compliance_Review__c> allDraftGapAnalysis =
			[SELECT Id, Name, Effective_Date__c, Publish_Status__c, Station__c, Document__c, Previous_Version__c,
					Document__r.Effective_Date__c, Title__c, Document__r.Abbreviated_Name__c, Document__r.Edition__c, Document__r.Version__c, Document__r.Revision__c
			 FROM Compliance_Review__c
			 WHERE Publish_Status__c = :IGOMConstants.COMPLIANCE_REVIEW.STATUS.DRAFT AND Station__c = :ownStation.accountRoleId AND Document__r.Is_Active__c = true];

    	Map<Id, Compliance_Review__c> complianceReviewMap = new Map<Id, Compliance_Review__c>();
		for (Compliance_Review__c complianceReview : allDraftGapAnalysis) {
			complianceReviewMap.put(complianceReview.Id, complianceReview);
		}

		Map<Id, List<IGOMComplianceReviewPartUtil.ComplianceReviewPart>> complianceReviewIdToParts =
			new Map<Id, List<IGOMComplianceReviewPartUtil.ComplianceReviewPart>>();
		for (IGOMComplianceReviewPartUtil.ComplianceReviewPart complianceReviewPart : IGOMComplianceReviewPartUtil.getComplianceReviewPartByComplianceReview(new List<Id>(complianceReviewMap.keySet()))) {
			List<IGOMComplianceReviewPartUtil.ComplianceReviewPart> complianceReviewParts = complianceReviewIdToParts.get(complianceReviewPart.gapAnalysisId);
			if (complianceReviewParts == null) {
				complianceReviewParts = new List<IGOMComplianceReviewPartUtil.ComplianceReviewPart>();
			}
			complianceReviewParts.add(complianceReviewPart);
			complianceReviewIdToParts.put(complianceReviewPart.gapAnalysisId, complianceReviewParts);
		}

		//Start with completition percentage calculation
		//Recover the compliance review parts per gap analysis
		List<ComplianceReview> gapAnalysisList = new List<ComplianceReview>();
		Set<Id> manualIds = new Set<Id>();
		Map<Id, Set<Id>> proceduresCompletedPerGapAnalysis = new Map<Id, Set<Id>>();
		Map<Id, Id> manualIdPerGapAnalysis = new Map<Id, Id>();
		for(Compliance_Review__c cr : complianceReviewMap.values()) {
			gapAnalysisList.add(new ComplianceReview(cr));

			manualIds.add(cr.Document__c);
			manualIdPerGapAnalysis.put(cr.Id, cr.Document__c);

			Set<Id> proceduresIds = proceduresCompletedPerGapAnalysis.get(cr.Id) != null ?
			proceduresCompletedPerGapAnalysis.get(cr.Id) : new Set<Id>();
			List<IGOMComplianceReviewPartUtil.ComplianceReviewPart> complianceReviewParts = complianceReviewIdToParts.get(cr.Id);
			if (complianceReviewParts != null) {
				for(IGOMComplianceReviewPartUtil.ComplianceReviewPart reference : complianceReviewParts){
					proceduresIds.add(reference.igomAuditableProcedureId);
				}
			}
			proceduresCompletedPerGapAnalysis.put(cr.Id, proceduresIds);
		}

		Map<Id, Set<Id>> childrenProcsInManual = getChildrenDocumentParts(new List<Id> (manualIds));

		/**
		 * Get the completition percentage
		 * It is the number of procedures that have a reference in the gap analysis
		 */
		for (ComplianceReview gapInfo : gapAnalysisList) {
			Id manualId = manualIdPerGapAnalysis.get(gapInfo.id);
			Decimal completedProcedures = 0;
			Decimal totalProcedures = 0;
			Set<Id> childrenProcs = new Set<Id>();
			if(childrenProcsInManual.get(manualId) != null){
				childrenProcs = childrenProcsInManual.get(manualId);
				totalProcedures = childrenProcs.size();
			}

			if(proceduresCompletedPerGapAnalysis.get(gapInfo.id) != null){
				for(Id procId : childrenProcs){
					if(proceduresCompletedPerGapAnalysis.get(gapInfo.id).contains(procId)){
						completedProcedures++;
					}
				}
			}
			gapInfo.totalChildrenProcedures = totalProcedures;
			gapInfo.completedProcedureNumber = completedProcedures;
			gapInfo.completition =  completedProcedures == 0 ? 0 : ((completedProcedures/totalProcedures) * 100).setScale(2, System.RoundingMode.DOWN);
		}
		return gapAnalysisList;
	}

	/**
	 * @description	Recovers all the children document parts (the ones that are not parent of any other document part) for a list of documents.
	 * @param		documentIds <List of Document__c ids to find the children document parts from.>
	 * @return		Map<Id, Set<Id>> <Set of ids of the child document parts per document id.>
	 */
	public static Map<Id, Set<Id>> getChildrenDocumentParts(List<Id> documentIds){
		//Find all the parent procedures
		Set<Id> parentProcedures = new Set<Id>();
		List<SObject> allDocumentPartsInIGOM = [SELECT Id, Parent__c, Document__c FROM Document_Part__c WHERE Document__c IN :documentIds
		AND Version_Change_Status__c != :IGOMConstants.DOCUMENT_PART.VERSION_CHANGE_STATUS.DELETED];
		for(Document_Part__c procedure : (List<Document_Part__c>) allDocumentPartsInIGOM)
		{
			if (procedure.Parent__c == null) {
				parentProcedures.add(procedure.Id);
			} else {
				parentProcedures.add(procedure.Parent__c);
			}
		}

		//Get the related igom list
		List<Document__c> manuals = [SELECT Id FROM Document__c WHERE Id IN :documentIds AND RecordType.Name = :IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM];

		Map<Id, List<Document_Part__c>> childDocumentPartPerDocument = new Map<Id, List<Document_Part__c>>();
		for(Document_Part__c dp : (List<Document_Part__c>) IGOMCommunityUtil.removeItemsFromListByField(allDocumentPartsInIGOM, parentProcedures, 'Id')){
			List<Document_Part__c> docParts = childDocumentPartPerDocument.get(dp.Document__c);
			if(docParts == null){
				docParts = new List<Document_Part__c>();
			}
			docParts.add(dp);
			childDocumentPartPerDocument.put(dp.Document__c, docParts);
		}

		//Get the number of children procedures per manual
		Map<Id, Set<Id>> childrenProcsInManual = new Map<Id, Set<Id>>();
		for(Document__c manual : manuals)
		{
			List<Document_Part__c> manualParts = childDocumentPartPerDocument.get(manual.Id);
			//Create a map with all the children procs per manual
			Set<Id> procSet = new Set<Id>();
			for (Document_Part__c proc : manualParts) {
				procSet.add(proc.Id);
			}
			childrenProcsInManual.put(manual.Id, procSet);
		}
		return childrenProcsInManual;
	}

	/**
	 * @description	Recovers the list of previously publiched gap analysis that are managed by the active user
	 * @param		stationId <Active station id>
	 * @return		List<ComplianceReview> <List of GAPAnalysisInfo objects representing the gap analysis that have a Published status>
	 */
	@AuraEnabled(cacheable=true)
	public static List<ComplianceReview> getImportableGapAnalysisList(Id stationId) {
		if (!IGOMPermissions.hasPermission(stationId, IGOMConstants.PERMISSIONS.CREATE_GAP)) {
			throw new AuraHandledException(String.format(IGOMConstants.ERRORS.REQUIRED_PERMISSIONS_MISSING_ERROR, new List<Object>{'create a GAP Analysis'}));
		}
		// Get the own station
		IGOMStationUtil.Station ownStation =IGOMStationUtil.getOwnStation(stationId);
		// Get all the relationships between account roles
		 IGOMAccountRoleRelationshipsUtil.AllRelationships relationshipsInfo = IGOMAccountRoleRelationshipsUtil.getAllRelationships(ownStation.id);
		// Extract parent station ids
		Set<Id> parentStationIds = new Set<Id>();
		for(IGOMStationUtil.RelatedStation parentStation : relationshipsInfo.parentStations){
			parentStationIds.add(parentStation.stationInfo.accountRoleId);
		}

		// Recover the template compliance revs. from the same station
		parentStationIds.add(ownStation.accountRoleId);
		
		// Retrieve every published gap analysis related to the station and templates from parent stations
		List<Compliance_Review__c> allPublishedGapAnalysis =
			[SELECT Id, Name, Effective_Date__c, Publish_Status__c, Station__c, Previous_Version__c,
					Document__c, Document__r.Effective_Date__c, Title__c, Document__r.Abbreviated_Name__c, Document__r.Edition__c, Document__r.Version__c, Document__r.Revision__c
			 FROM Compliance_Review__c
			 WHERE (Publish_Status__c = :IGOMConstants.COMPLIANCE_REVIEW.STATUS.PUBLISHED AND
			 	   Station__c = :ownStation.accountRoleId) OR (Publish_Status__c = :IGOMConstants.COMPLIANCE_REVIEW.STATUS.TEMPLATE AND
			 	   Station__c IN :parentStationIds)
			 ORDER BY CreatedDate DESC];

		List<ComplianceReview> gapAnalysisList = new List<ComplianceReview>();
		for (Compliance_Review__c cr : allPublishedGapAnalysis) {
			gapAnalysisList.add(new ComplianceReview(cr));
		}
		return gapAnalysisList;
	}

	/**
	 * @description	Deletes a compliance review record given its Id
	 * @param		gapAnalysisId <Id of the compliance review>
	 */
	@AuraEnabled
	public static void deleteComplianceReview(Id gapAnalysisId) {
		// Check permissions
		checkPermissionOnComplianceReview(gapAnalysisId, IGOMConstants.PERMISSIONS.CREATE_GAP);
		if (gapAnalysisId != null && gapAnalysisId.getSObjectType() === Compliance_Review__c.getSObjectType()) {
			delete new Compliance_Review__c(Id = gapAnalysisId);
		}
	}

	/**
	 * @description	Copies an IGOM Manual to a Compliance Review marking everything as Conformity
	 * @param		gapAnalysisId <Id of the compliance review>
	 */
	@AuraEnabled
	public static void importIGOMProceduresAsConformity(Id gapAnalysisId) {
		// Check permissions
		checkPermissionOnComplianceReview(gapAnalysisId, IGOMConstants.PERMISSIONS.DOCUMENT_GAP);
		checkPermissionOnComplianceReview(gapAnalysisId, IGOMConstants.PERMISSIONS.EDIT_GAP);
		if (gapAnalysisId != null && gapAnalysisId.getSObjectType() === Compliance_Review__c.getSObjectType()) {
			// Query the related compliance review
			ComplianceReview gapAnalysis = queryGapAnalysisById(gapAnalysisId);

			// Get the related IGOM manual
			IGOMDocumentUtil.Document igomManual = IGOMDocumentUtil.getIGOMManualById(gapAnalysis.manualId);

			// Copy the related IGOM manual to the stations manuals
			IGOMDocumentUtil.Document igomAsGom = IGOMDocumentUtil.importGomDocuments(new List<IGOMDocumentUtil.Document>{ igomManual }, gapAnalysis.stationId).values().get(0);

			// Get every auditable procedure id that is a parent
			Set<Id> parentProcedureComplianceIds = new Set<Id>();
			List<SObject> allAuditableProcedures = [SELECT Id, Name__c, Parent__c, Version_Change_Status__c FROM Document_Part__c WHERE Document__c = :gapAnalysis.manualId 
			AND Version_Change_Status__c != :IGOMConstants.DOCUMENT_PART.VERSION_CHANGE_STATUS.DELETED];
			for (Document_Part__c auditableProcedure : (List<Document_Part__c>) allAuditableProcedures)
			{
				parentProcedureComplianceIds.add(auditableProcedure.Parent__c);
			}

			// Create a procedure compliance for each manual entry that is a leaf
			List<Compliance_Review_Part__c> igomProcedureCompliances = new List<Compliance_Review_Part__c>();
			for (Document_Part__c auditableProcedure : (List<Document_Part__c>) IGOMCommunityUtil.removeItemsFromListByField(allAuditableProcedures, parentProcedureComplianceIds, 'Id'))
			{
				IGOMComplianceReviewPartUtil.ComplianceReviewPart complianceReviewPart = new IGOMComplianceReviewPartUtil.ComplianceReviewPart();
				complianceReviewPart.gapAnalysisId = gapAnalysis.id;
				complianceReviewPart.igomAuditableProcedureId = auditableProcedure.Id;
				complianceReviewPart.document = igomAsGom.id;
				complianceReviewPart.userProvisionProcedure = auditableProcedure.Name__c;
				complianceReviewPart.statusValue = IGOMConstants.PROCEDURE_COMPLIANCE.VALIDITY.REVIEWED;
				complianceReviewPart.variationStatus = IGOMConstants.PROCEDURE_COMPLIANCE.STATUS.CONFORMITY;
				complianceReviewPart.notes = '(automatically imported from the IGOM)';
				igomProcedureCompliances.add(complianceReviewPart.toSalesforce(true));
			}
			insert igomProcedureCompliances;
		}
	}

	/**
	 * @description	Recovers all the necessary information from an specific gap analysis
	 * @param		gapAnalysisId <Id of the compliance review>
	 * @return		ComplianceReview <A GAPAnalysis object containing all the information of the specified gap analysis and it's children objects>
	 */
	@AuraEnabled(cacheable=true)
	public static ComplianceReview getFullGapAnalysis(Id gapAnalysisId) {
		// Check permissions
		Id stationId = checkPermissionOnComplianceReview(gapAnalysisId, IGOMConstants.PERMISSIONS.EDIT_GAP);
		// Initialize variables
		Set<Id> procedureCompliances = new Set<Id>();
		Map<Id, Compliance_Review_Part__c> procedureCompliancesPerId = new Map<Id, Compliance_Review_Part__c>();
		Map<Id, List<IGOM_Contact_Role_Procedure_Compliance__c>> contactRolesPerProcedureComplianceId = new Map<Id, List<IGOM_Contact_Role_Procedure_Compliance__c>>();
		// Get the own station
		IGOMStationUtil.Station ownStation =IGOMStationUtil.getOwnStation(stationId);
		// Query all the compliance review object
		Compliance_Review__c gapAnalysis = queryFullGapAnalysisById(gapAnalysisId);
		if (gapAnalysis.Station__c != ownStation.accountRoleId) {
			throw new AuraHandledException(String.format(IGOMConstants.ERRORS.STATION_NOT_RELATED_TO_USER_ERROR, new List<String>{ gapAnalysis.Station__c }));
		}

		ComplianceReview gapAnalysisApex = new ComplianceReview(gapAnalysis);

		List<Compliance_Review_Part__c> gapAnalysisItems = queryGapAnalysisPartsByGapId(gapAnalysisId);
		for (Compliance_Review_Part__c procedureCompliance : gapAnalysisItems) {
			procedureCompliances.add(procedureCompliance.Id);
			procedureCompliancesPerId.put(procedureCompliance.Id, procedureCompliance);
		}

		//Load the Referenced documents in a map by the ParentId
		List<Attachment> attachments =
			[SELECT Id, Name, ParentId, ContentType, Body, CreatedDate, BodyLength
			 FROM Attachment
			 WHERE ParentId IN :procedureCompliances];

		Map<Id, List<Attachment>> attachmentsPerParent = new Map<Id, List<Attachment>>();
		for (Attachment attachment : attachments){
			List<Attachment> attachmentList = attachmentsPerParent.get(attachment.ParentId) != null ? attachmentsPerParent.get(attachment.ParentId) : new List<Attachment>();
			attachmentList.add(attachment);
			attachmentsPerParent.put(attachment.ParentId, attachmentList);
		}

		// Get the index of the referenced IGOM Manual
		Map<Id, IGOMDocumentUtil.Index> documentPartIdToIndex = IGOMDocumentUtil.getIGOMManualIndex(gapAnalysis.Document__c);

		// Create GAP analisis object
		for (Compliance_Review_Part__c procedureCompliance : gapAnalysisItems) {
			IGOMDocumentUtil.Index documentPartIndex = documentPartIdToIndex.get(procedureCompliance.Standard_Document_Part__c);

			IGOMComplianceReviewPartUtil.ComplianceReviewPart procedureApex = new IGOMComplianceReviewPartUtil.ComplianceReviewPart(procedureCompliance);
			procedureApex.addIndex(documentPartIndex);
			List<Attachment> relatedAttachments = attachmentsPerParent.get(procedureCompliance.Id);
			if (relatedAttachments != null) {
				for (Attachment attachment : relatedAttachments){
					procedureApex.attachments.add(attachment);
				}
			}
			gapAnalysisApex.references.add(procedureApex);
		}
		return gapAnalysisApex;
	}

	/**
	 * @description Inserts a new Gap analysis in a draft status and returns it.
	 * @param		stationId <Active station id>
	 * @param		name <Name for the Compliance review>
	 * @param		igomManual <IGOM documentId>
	 * @return		ComplianceReview <A new GAPAnalysis with empty information>
	 */
	@AuraEnabled
	public static ComplianceReview createNewGapAnalysis(Id stationId, String name, Id igomManual) {
		if (!IGOMPermissions.hasPermission(stationId, IGOMConstants.PERMISSIONS.CREATE_GAP)) {
			throw new AuraHandledException(String.format(IGOMConstants.ERRORS.REQUIRED_PERMISSIONS_MISSING_ERROR, new List<Object>{'create a GAP Analysis'}));
		}
		// Get the own station
		IGOMStationUtil.Station ownStation =IGOMStationUtil.getOwnStation(stationId);

		// Create a new empty gap analysis related to the station
		ComplianceReview newGapAnalysis = new ComplianceReview();
		newGapAnalysis.name = name;
		newGapAnalysis.manualId = igomManual;
		newGapAnalysis.stationId = ownStation.accountRoleId;

		Compliance_Review__c gapAnalysis = newGapAnalysis.toSalesforce(false);
		insert gapAnalysis;

		return new ComplianceReview(gapAnalysis);
	}

	/**
	 * @description	Creates a new GAP analysis based on the information of a previously published one
	 * @param		stationId <Id of the station for which the compliance review will be created, as an account role id>
	 * @param		gapAnalysisId <Id of the compliance review to be cloned>
	 * @param		name <Name to set on the new compliance review>
	 * @return		A GAPAnalysis created based on the object containing all the information of the specified gap
	 * analysis. This new GAPAnalysis will not take the attachments from the specified GAP Analysis.
	 */
	@AuraEnabled
	public static ComplianceReview importGapAnalysis(Id stationId, Id gapAnalysisId, String name) {
		// Check permissions to create a GAP
		if (!IGOMPermissions.hasPermission(stationId, IGOMConstants.PERMISSIONS.CREATE_GAP)) {
			throw new AuraHandledException(String.format(IGOMConstants.ERRORS.REQUIRED_PERMISSIONS_MISSING_ERROR, new List<Object>{'create a GAP Analysis'}));
		}

		// - 1. Query and map the relevant data
		// Query the importable gap analysis
		Compliance_Review__c importableGapAnalysis = queryFullGapAnalysisById(gapAnalysisId);
		// Check permissions to import a GAP (gap analysis should belong to a parent or to self)
		IGOMAccountRoleRelationshipsUtil.AllRelationships allRelationships = IGOMAccountRoleRelationshipsUtil.getAllRelationships(stationId);
		IGOM_Account_Role_Detail__c station = [SELECT Account_Role__c FROM IGOM_Account_Role_Detail__c WHERE Id = :stationId];
		if (importableGapAnalysis.Station__c != station.Account_Role__c && !allRelationships.isParentStation(station.Id)) {
			throw new AuraHandledException(String.format(IGOMConstants.ERRORS.REQUIRED_PERMISSIONS_MISSING_ERROR, new List<Object>{'import a GAP Analysis from this station'}));
		}
		// Create a map of the current auditable procedures for the auditable procedures that are in the selected gap analysis
		Map<Id, Id> oldStandardProcedureIdToCurrent = new Map<Id, Id>();
		Map<Id, Compliance_Review_Part__c> procedureCompliancesPerId = new Map<Id, Compliance_Review_Part__c>();
		Set<Id> modifiedAuditableProcedures = new Set<Id>();
		Set<Id> documentIds = new Set<Id>();
		List<Compliance_Review_Part__c> gapAnalysisItems = queryGapAnalysisPartsByGapId(gapAnalysisId);
		if (!gapAnalysisItems.isEmpty()){
			Set<String> procedurePermIds = new Set<String>();
			// Create sets of ids and data from the importable gap
			for (Compliance_Review_Part__c reference : gapAnalysisItems) {
				procedurePermIds.add(reference.Standard_Document_Part__r.External_Reference_ID__c);
				documentIds.add(reference.Document__c);
				procedureCompliancesPerId.put(reference.Id, reference);
			}
			// Query the procedures, that were not deleted, whose permids are in set and manual is active
			for (Document_Part__c currentProcedure : [SELECT Id, External_Reference_ID__c, Name__c, Is_Safety_Critical__c, Version_Change_Status__c 
			FROM Document_Part__c WHERE Version_Change_Status__c != :IGOMConstants.DOCUMENT_PART.VERSION_CHANGE_STATUS.DELETED AND Document__r.Is_Active__c = true
			AND Document__r.Language__c = :IGOMConstants.GLOBALS.LANGUAGE_ENGLISH AND External_Reference_ID__c IN :procedurePermIds]){
				for (Compliance_Review_Part__c oldReference : gapAnalysisItems) {
					if (currentProcedure.External_Reference_ID__c == oldReference.Standard_Document_Part__r.External_Reference_ID__c) {
						oldStandardProcedureIdToCurrent.put(oldReference.Standard_Document_Part__c, currentProcedure.Id);
						if (currentProcedure.Version_Change_Status__c == IGOMConstants.DOCUMENT_PART.VERSION_CHANGE_STATUS.MODIFIED) {
							modifiedAuditableProcedures.add(currentProcedure.Id);
						}
					}
				}
			}
		}

		// - 2. Create the new GAP Analysis
		ComplianceReview newGapAnalysis = new ComplianceReview();
		newGapAnalysis.name = name;
		newGapAnalysis.manualId = IGOMDocumentUtil.getLastActiveIGOMManual().id;
		newGapAnalysis.stationId = station.Account_Role__c;
		newGapAnalysis.previousVersionId = importableGapAnalysis.Previous_Version__c;
		// Insert the new gap analysis
		Compliance_Review__c gapAnalysisNew = newGapAnalysis.toSalesforce(false);
		insert gapAnalysisNew;
		// Create apex object to return
		ComplianceReview gapAnalysisApex = new ComplianceReview(gapAnalysisNew);
		// When using a template import all the related documents to the station
		Map<Id, IGOMDocumentUtil.Document> oldDocIdToUsedDoc;
		List<IGOMDocumentUtil.Document> relatedDocuments = IGOMDocumentUtil.queryDocumentById(new List<Id>(documentIds));
		if (importableGapAnalysis.Publish_Status__c == IGOMConstants.COMPLIANCE_REVIEW.STATUS.TEMPLATE) {
			oldDocIdToUsedDoc = IGOMDocumentUtil.importGomDocuments(relatedDocuments, newGapAnalysis.stationId);
		} else {
			oldDocIdToUsedDoc = new Map<Id, IGOMDocumentUtil.Document>();
			for (IGOMDocumentUtil.Document document : relatedDocuments) {
				oldDocIdToUsedDoc.put(document.id, document);
			}
		}

		// - 3. Copy all the references
		Map<Id, Compliance_Review_Part__c> oldReferenceIdToNewReference = new Map<Id, Compliance_Review_Part__c>();
		Map<Id, Compliance_Review_Part__c> oldReferenceIdToOldReference = new Map<Id, Compliance_Review_Part__c>();
		for (Compliance_Review_Part__c reference : gapAnalysisItems) {
			Id newManualPartId = oldStandardProcedureIdToCurrent.get(reference.Standard_Document_Part__c);
			// The referenced old IGOM manual part needs to appear in the new manual
			if (newManualPartId != null) {
				IGOMComplianceReviewPartUtil.ComplianceReviewPart newReference = new IGOMComplianceReviewPartUtil.ComplianceReviewPart(reference);
				if (reference.Document__c != null) {
					newReference.document = oldDocIdToUsedDoc.get(reference.Document__c).Id;
				}
				newReference.igomAuditableProcedureId = newManualPartId;
				newReference.variationStatus = modifiedAuditableProcedures.contains(newManualPartId) && importableGapAnalysis.Publish_Status__c == IGOMConstants.COMPLIANCE_REVIEW.STATUS.PUBLISHED ? IGOMConstants.PROCEDURE_COMPLIANCE.STATUS.VARIATION : reference.Status__c;
				newReference.gapAnalysisId = gapAnalysisNew.Id;
				// When importing from a published gap analysis, the references are pending review
				if (importableGapAnalysis.Publish_Status__c == IGOMConstants.COMPLIANCE_REVIEW.STATUS.PUBLISHED) {
					newReference.isReviewed = false;
				}
				oldReferenceIdToNewReference.put(reference.Id, newReference.toSalesforce(false));
				oldReferenceIdToOldReference.put(reference.Id, reference);
			}
		}
		// Insert the new references
		insert oldReferenceIdToNewReference.values();

		// - 4. Copy all the attachments
		List<Attachment> attachmentsToClone = [SELECT Id, Name, ParentId, ContentType, Body, CreatedDate, BodyLength, Description FROM Attachment WHERE ParentId = :procedureCompliancesPerId.keySet()];
		// Prepare the old id to new id map
		Map<Id, Id> oldParentIdToNewParentId = new Map<Id, Id>();
		for (Id oldReferenceId : oldReferenceIdToNewReference.keySet()) {
			oldParentIdToNewParentId.put(oldReferenceId, oldReferenceIdToNewReference.get(oldReferenceId).Id);
		}
		List<Attachment> clonedAttachments = IGOMAttachmentUtil.duplicateAttachments(attachmentsToClone, oldParentIdToNewParentId);
		Map<Object, List<Attachment>> newReferenceIdToAttachments = (Map<Object, List<Attachment>>) IGOMCommunityUtil.groupSObjects(clonedAttachments, 'ParentId');

		// - 5. Build the returned object
		// Calculate a map with every new reference id to its old reference
		Map<Id, Compliance_Review_Part__c> newReferenceIdToOldReference = new Map<Id, Compliance_Review_Part__c>();
		for (Id oldId : oldReferenceIdToNewReference.keySet()) {
			newReferenceIdToOldReference.put(oldReferenceIdToNewReference.get(oldId).Id, oldReferenceIdToOldReference.get(oldId));
		}
		// Get the index of the referenced IGOM Manual
		Map<Id, IGOMDocumentUtil.Index> documentPartIdToIndex = IGOMDocumentUtil.getIGOMManualIndex(gapAnalysisApex.manualId);
		// Add copied references to apex obj
		for (Compliance_Review_Part__c ref : oldReferenceIdToNewReference.values()) {
			IGOMComplianceReviewPartUtil.ComplianceReviewPart gapItem = new IGOMComplianceReviewPartUtil.ComplianceReviewPart(ref);
			gapItem.addIndex(documentPartIdToIndex.get(ref.Standard_Document_Part__c));
			if (newReferenceIdToAttachments.containsKey(ref.Id)) {
				gapItem.Attachments.addAll(newReferenceIdToAttachments.get(ref.Id));
			}
			// Fill the formulas (userProvisionDocument) since they are not queried
			gapItem.userProvisionDocument = newReferenceIdToOldReference.get(ref.Id).Document__c != null ? oldDocIdToUsedDoc.get(newReferenceIdToOldReference.get(ref.Id).Document__c).reference : '-';
			gapAnalysisApex.references.add(gapItem);
		}
		return gapAnalysisApex;
	}

	/**
	 * @description	Publish a compliance review
	 * @param		gapAnalysisId <Id of the compliance review>
	 * @param		chapterIds <Id of the manual's chapters to be published>
	 * @param		effectiveDate <Compliance review's effective date>
	 * @param		notificationReminderDate <Date to send a reminder notification to the users>
	 * @param		notifyUsers <Map of all the list of users to notify per notification type>
	 * @return		The information of the published compliance review.
	 */
	@AuraEnabled
	public static ComplianceReview publishGapAnalysis(Id gapAnalysisId, List<Id> chapterIds, Date effectiveDate, Date notificationReminderDate, Map<String, List<Id>> notifyUsers) {
		ComplianceReview queriedGapAnalysis = queryGapAnalysisById(gapAnalysisId);
		// V.1 Validate the publishing permission
		Id accountRoleDetailId = [SELECT Id FROM IGOM_Account_Role_Detail__c WHERE Account_Role__c = :queriedGapAnalysis.stationId].Id;
		if (!IGOMPermissions.hasPermission(accountRoleDetailId, IGOMConstants.PERMISSIONS.PUBLISH_GAP)) {
			throw new AuraHandledException(String.format(IGOMConstants.ERRORS.REQUIRED_PERMISSIONS_MISSING_ERROR, new List<Object>{'publish a GAP Analysis'}));
		}
		// 1. Check the manual to see if its a full publish
		Map<Id, IGOMDocumentUtil.Index> indexById = IGOMDocumentUtil.getIGOMManualIndex(queriedGapAnalysis.manualId);
		Set<Id> manualChapterIds = new Set<Id>();
		for (IGOMDocumentUtil.Index index : indexById.values()) {
			manualChapterIds.add(index.chapterId);
		}
		final Boolean isFullPublish = chapterIds.size() == manualChapterIds.size();
		// 2. Create the gap analysis to publish
		Compliance_Review__c gapToPublish = queriedGapAnalysis.toSalesforce(isFullPublish);
		// 3. Check the station doing the publish, for "leaf stations" (ground handlers) allow publishing, the rest can only template
		IGOMAccountRoleRelationshipsUtil.AllRelationships allRelationships = IGOMAccountRoleRelationshipsUtil.getAllRelationships(accountRoleDetailId);
		gapToPublish.Publish_Status__c = allRelationships.childStations.isEmpty() ? IGOMConstants.COMPLIANCE_REVIEW.STATUS.PUBLISHED : IGOMConstants.COMPLIANCE_REVIEW.STATUS.TEMPLATE;
		// 4. Set the effective date, mark that it's a latest published gap and the reminder date if theres more than 7 days
		gapToPublish.Effective_Date__c = effectiveDate;
		gapToPublish.Is_Latest_Published__c = true;
		if (notificationReminderDate != null && notificationReminderDate.daysBetween(effectiveDate) >= 7) {
			gapToPublish.Notification_Date__c = notificationReminderDate;
		}
		// 5. Distinguish between a full publish (just updating the document) and a partial one (creating a new gap)
		if (isFullPublish) {
			// 6A. Full publish only changes the status of the GAP analysis
			update gapToPublish;
		} else {
			// 6A. Create the new GAP
			insert gapToPublish;
			// 6B. Get all the references from the selected chapters
			List<Compliance_Review_Part__c> gapReferences = new List<Compliance_Review_Part__c>();
			for (IGOMComplianceReviewPartUtil.ComplianceReviewPart complianceReviewPart : IGOMComplianceReviewPartUtil.getComplianceReviewPartByComplianceReview(new List<Id>{ queriedGapAnalysis.Id })) {
				final IGOMDocumentUtil.Index index = indexById.get(complianceReviewPart.igomAuditableProcedureId);
				// 6B. Only add compliance reviews that are part of the published chapters
				if (chapterIds.contains(index.chapterId)) {
					gapReferences.add(new Compliance_Review_Part__c(
						Id = complianceReviewPart.Id,
						Document__c = complianceReviewPart.document,
						Compliance_Review__c = gapToPublish.Id
					));
				}
			}
			// 6C. Reparent references to new gap and reassign documents
			update gapReferences;

		}
		// Post-creation send the notifications
		IGOMNotificationUtil.sendGAPNotifications(gapToPublish.Id, notifyUsers);
		// Last step: wrap the information and return it
		return new ComplianceReview(gapToPublish);
	}

	/**
	 * @description	List all the compliance reviews from a station for the active document
	 * @param		stationId <Id of the station as an account role id>
	 * @return		List with every gap analysis' information.
	 */
	@AuraEnabled
	public static List<ComplianceReview> getActualGapAnalyses(Id stationId, Id documentId, Boolean retrievePublishedGaps) {
		if (retrievePublishedGaps && !IGOMPermissions.hasPermission(IGOMConstants.PERMISSIONS.VIEW_ALL_VARIATIONS) &&
			!IGOMPermissions.hasPermission(stationId, IGOMConstants.PERMISSIONS.VIEW_OWN_VARIATIONS)) {
			throw new AuraHandledException(String.format(IGOMConstants.ERRORS.REQUIRED_PERMISSIONS_MISSING_ERROR, new List<String>{'publish a GAP Analysis'}));
		}
		// validate permissions
		List<ComplianceReview> complianceReviews = new List<ComplianceReview>();

		String query = 'SELECT Id, Name, Effective_Date__c, Publish_Status__c, Document__c, Previous_Version__c, Document__r.Effective_Date__c, '+
		'Title__c, Station__c, Document__r.Abbreviated_Name__c, Document__r.Edition__c, Document__r.Version__c, Document__r.Revision__c ' + 
		'FROM Compliance_Review__c WHERE Station__c = :stationId AND Document__c = :documentId ';
		if(retrievePublishedGaps){
			String publishedStatus = IGOMConstants.COMPLIANCE_REVIEW.STATUS.PUBLISHED;
			query += 'AND Publish_Status__c = :publishedStatus ';
		}
		query += 'ORDER BY Effective_Date__c DESC';

		for (Compliance_Review__c sfComplianceReview : (List<Compliance_Review__c>) Database.query(query))
		{
			complianceReviews.add(new ComplianceReview(sfComplianceReview));
		}
		return complianceReviews;
	}

	/**
	 * @description	List all the published compliance reviews from a station
	 * @param		stationId <Id of the station as an account role id>
	 * @return		List with every gap analysis' information.
	 */
	@AuraEnabled(cacheable=true)
	public static List<ComplianceReview> getAllPublishedGapAnalyses(Id stationId) {
		if (!IGOMPermissions.hasPermission(IGOMConstants.PERMISSIONS.VIEW_ALL_VARIATIONS) &&
			!IGOMPermissions.hasPermission(stationId, IGOMConstants.PERMISSIONS.VIEW_OWN_VARIATIONS)) {
			throw new AuraHandledException(String.format(IGOMConstants.ERRORS.REQUIRED_PERMISSIONS_MISSING_ERROR, new List<String>{'publish a GAP Analysis'}));
		}
		Id accountRoleId = [SELECT Account_Role__c FROM IGOM_Account_Role_Detail__c WHERE Id = :stationId].Account_Role__c;
		List<ComplianceReview> complianceReviews = new List<ComplianceReview>();
		for (Compliance_Review__c sfComplianceReview :
			 [SELECT Id, Name, Effective_Date__c, Publish_Status__c, Document__c, Previous_Version__c,
					  Document__r.Effective_Date__c, Title__c, Station__c, Document__r.Abbreviated_Name__c, Document__r.Edition__c, Document__r.Version__c, Document__r.Revision__c
			  FROM Compliance_Review__c
			  WHERE Station__c = :accountRoleId AND Publish_Status__c = :IGOMConstants.COMPLIANCE_REVIEW.STATUS.PUBLISHED
			  ORDER BY Effective_Date__c DESC])
		{
			complianceReviews.add(new ComplianceReview(sfComplianceReview));
		}
		return complianceReviews;
	}

	/**
	 * @description	Get the station Id based on a compliance review id
	 * @param		complianceReviewId <Compliance Review Id>
	 * @return		Id <station id>
	 */
	private static Id getStationId(Id complianceReviewId) {
		ComplianceReview complianceReview = queryGapAnalysisById(complianceReviewId);
		IGOM_Account_Role_Detail__c station = [SELECT Id FROM IGOM_Account_Role_Detail__c WHERE Account_Role__c = :complianceReview.stationId];
		return station.id;
	}

	/**
	 * Checks a specific permission on a station from a compliance review.
	 * @param		complianceReviewId <Compliance Review Id>
	 * @param		permissionName <Name of the permission>
	 * @return Id of the related station
	 */
	public static Id checkPermissionOnComplianceReview(Id complianceReviewId, String permissionName) {
		Id stationId = getStationId(complianceReviewId);
		if (!IGOMPermissions.hasPermission(stationId, permissionName)) {
			throw new AuraHandledException(String.format(IGOMConstants.ERRORS.REQUIRED_PERMISSIONS_MISSING_ERROR, new List<Object>{'view variations for this station'}));
		}
		return stationId;
	}
}