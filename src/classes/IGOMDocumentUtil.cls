/**
 * @description	  Class containing multiple methods related to the Document use cases regarding the IGOM project.
 */
public without sharing class IGOMDocumentUtil {
	/**
	 * Apex Object containing the data from an IGOM document object
	 */
	public class IGOMManual {
		@AuraEnabled
		public Document__c manual {get;set;}
		@AuraEnabled 
		public List<IGOMProcedure> chapters {get;set;}
		public IGOMManual(Document__c m) {
			chapters = new List<IGOMProcedure>();
			manual = m;
		}
	}

	/**
	 * Apex Object containing the data from an IGOM document parts' object
	 */
	public class IGOMProcedure {
		@AuraEnabled 
		public Document_Part__c procedure {get;set;}
		@AuraEnabled 
		public String index {get;set;}
		@AuraEnabled 
		public Boolean modified {get;set;}
		@AuraEnabled 
		public List<IGOMProcedure> subprocedures {get;set;}
		public IGOMProcedure(Document_Part__c p) {
			procedure = p;
			subprocedures = new List<IGOMProcedure>();
		}
	}

	/**
	 * DAO Object containing the data from a Document__c record
	 */
	public class Document {
		// Writable
		@AuraEnabled public Id id  { get; set; }
		@AuraEnabled public Id stationId;
		@AuraEnabled public String recordType { get; set; }
		@AuraEnabled public String name { get; set; }
		@AuraEnabled public String abbreviation { get; set; }
		@AuraEnabled public String type { get; set; }
		@AuraEnabled public Date publishDate { get; set; }
		@AuraEnabled public Date reviewDate { get; set; }
		@AuraEnabled public Date effectiveDate { get; set; }
		@AuraEnabled public String version { get; set; }
		@AuraEnabled public String edition { get; set; }
		@AuraEnabled public String revision { get; set; }
		// Read-only
		@AuraEnabled public String reference;
		@AuraEnabled public List<Attachment> attachments;

		public Document() {
			this.attachments = new List<Attachment>();
		}

		public Document(Document__c gapAnalysisDocument) {
			this();
			this.id = gapAnalysisDocument.Id;
			this.stationId = gapAnalysisDocument.Station__c;
			this.recordType = gapAnalysisDocument.RecordType.Name;
			this.name = gapAnalysisDocument.Document_Name__c;
			this.abbreviation = gapAnalysisDocument.Abbreviated_Name__c;
			this.type = gapAnalysisDocument.Type__c;
			this.publishDate = gapAnalysisDocument.Published_Date__c;
			this.reviewDate = gapAnalysisDocument.Review_date__c;
			this.effectiveDate = gapAnalysisDocument.Effective_date__c;
			this.version = gapAnalysisDocument.Version__c;
			this.edition = gapAnalysisDocument.Edition__c;
			this.revision = gapAnalysisDocument.Revision__c;

			this.reference = getDocumentReference(gapAnalysisDocument);
			if (gapAnalysisDocument.Attachments != null) {
				this.attachments = gapAnalysisDocument.Attachments;
			}
		}

		public Document__c toSalesforce(Boolean keepId) {
			return new Document__c(
				Id = keepId ? this.id : null,
				Document_Name__c = this.name,
				Station__c = this.stationId,
				RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Document__c', this.recordType),
				Abbreviated_Name__c = this.abbreviation,
				Type__c = this.type,
				Published_Date__c = this.publishDate,
				Review_date__c = this.reviewDate,
				Effective_date__c = this.effectiveDate,
				Version__c = this.version,
				Edition__c = this.edition,
				Revision__c = this.revision
			);
		}
	}

	/**
	 * Apex Object to create the indexes of the document parts
	 */
	public class Index {
		@AuraEnabled public String chapterName;
		@AuraEnabled public String sectionName;
		@AuraEnabled public String subsectionName;
		@AuraEnabled public Id chapterId;
		@AuraEnabled public Id sectionId;
		@AuraEnabled public Id subsectionId;
		@AuraEnabled public Decimal chapterNum;
		@AuraEnabled public Decimal sectionNum;
		@AuraEnabled public Decimal subsectionNum;

		public Index(Index previousIndex) {
			this.chapterId = previousIndex.chapterId;
			this.chapterName = previousIndex.chapterName;
			this.chapterNum = previousIndex.chapterNum;
			this.sectionId = previousIndex.sectionId;
			this.sectionName = previousIndex.sectionName;
			this.sectionNum = previousIndex.sectionNum;
			this.subsectionId = previousIndex.subsectionId;
			this.subsectionName = previousIndex.subsectionName;
			this.subsectionNum = previousIndex.subsectionNum;
		}
		// Build index from previous index
		public Index(Document_Part__c documentPart, Index parentIndex) {
			if (parentIndex != null) {
				this(parentIndex);
			}
			if (documentPart.Category__c == IGOMConstants.DOCUMENT_PART.CATEGORY.PART) {
				this.chapterId = documentPart.Id;
				this.chapterName = documentPart.Name__c;
				this.chapterNum = documentPart.Index__c;
			} else if (documentPart.Category__c == IGOMConstants.DOCUMENT_PART.CATEGORY.CHAPTER) {
				this.sectionId = documentPart.Id;
				this.sectionName = documentPart.Name__c;
				this.sectionNum = documentPart.Index__c;
			} else if (documentPart.Category__c == IGOMConstants.DOCUMENT_PART.CATEGORY.SECTION) {
				this.subsectionId = documentPart.Id;
				this.subsectionName = documentPart.Name__c;
				this.subsectionNum = documentPart.Index__c;
			}
		}
	}

	/**
	 * @description	Create a list of Document objects from a list of Document__c records
	 * @param		queriedSObjects <The list of Document__c records>
	 * @return		List<Document> <The list of Document objects>
	 */
	private static List<Document> fromList(List<Document__c> queriedSObjects) {
		List<Document> documents = new List<Document>();
		for (Document__c sfDocument : queriedSObjects) {
			documents.add(new Document(sfDocument));
		}
		return documents;
	}
	
	/**
	 * @description	Get a list of Documents from the Document__c record ids
	 * @param		documentIds <Document Ids>
	 * @return		List<Document> <The list of Document objects>
	 */
	public static List<Document> queryDocumentById(List<Id> documentIds) {
		return fromList(
			[SELECT Id, Name, RecordType.Name, Type__c, Abbreviated_Name__c, Edition__c, Version__c, Revision__c,
			Published_Date__c, Review_date__c, Effective_Date__c, Station__c, Document_Name__c
			 FROM Document__c
			 WHERE Id IN :documentIds]
		);
	}

	/**
	 * @description	Get the list of GOM Documents from a station
	 * @param		stationId <Active station id>
	 * @return		List<Document> <The list of Document objects>
	 */
	public static List<Document> getDocumentsByStationId(Id stationId) {
		return fromList(
			[SELECT Id, Name, RecordType.Name, Type__c, Abbreviated_Name__c, Edition__c, Version__c, Revision__c,
					Published_Date__c, Review_date__c, Effective_Date__c, Station__c, Document_Name__c, (SELECT Id, Name, BodyLength FROM Attachments)
			 FROM Document__c
			 WHERE Station__c = :stationId AND RecordType.Name = :IGOMConstants.DOCUMENT.RECORD_TYPE.GOM]
		);
	}

	/**
	 * @description	Get the IGOM by its id
	 * @param		igomManualId <IGOM id>
	 * @return		Document <IGOM Document>
	 */
	public static Document getIGOMManualById(Id igomManualId) {
		Document igomManual = queryDocumentById(new List<Id>{  igomManualId }).get(0);
		if (igomManual.recordType != IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM) {
			throw new AuraHandledException(String.format(IGOMConstants.ERRORS.DOCUMENT_WRONG_TYPE_ERROR, new List<Object>{'IGOM'}));
		}
		return igomManual;
	}

	/**
	 * @description	Get the last active IGOM
	 * @return		Document <IGOM Document>
	 */
	private static Document lastActiveIGOMManual;
	public static Document getLastActiveIGOMManual() {
		if (lastActiveIGOMManual == null) {
			List<Document__c> lastManual =
				[SELECT Id, Name, RecordType.Name, Abbreviated_Name__c, Edition__c, Version__c, Revision__c, Document_Name__c,
						Published_Date__c, Review_date__c, Station__c, Effective_Date__c, Type__c
				 FROM Document__c
				 WHERE Is_Active__c = true AND Language__c = :IGOMConstants.GLOBALS.LANGUAGE_ENGLISH AND  RecordType.Name = :IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM
				 ORDER BY Published_Date__c DESC];
			lastActiveIGOMManual = new Document(lastManual.get(0));
		}
		return lastActiveIGOMManual;
	}

	/**
	 * @description	Get the list of GOM Documents from a station
	 * @param		stationId <Active station id>
	 * @return		List<Document> <The list of station's Document objects>
	 */
	@AuraEnabled(cacheable=true)
	public static List<Document> getMyStationsDocuments(Id stationId) {
		if (!IGOMPermissions.hasPermission(stationId, IGOMConstants.PERMISSIONS.DOCUMENT_GAP) &&
			!IGOMPermissions.hasPermission(stationId, IGOMConstants.PERMISSIONS.EDIT_GAP)) {
			throw new AuraHandledException(String.format(IGOMConstants.ERRORS.REQUIRED_PERMISSIONS_MISSING_ERROR, new List<Object>{'manage GOM documents'}));
		}
		IGOMStationUtil.Station myStation = IGOMStationUtil.getOwnStation(stationId);
		return getDocumentsByStationId(myStation.accountRoleId);
	}

	/**
	 * @description	Get the list of languages that are being used in current IGOM document.
	 * @return		List<String> <List of current IGOM languages>
	 */
	@AuraEnabled(cacheable=true)
	public static List<String> getCurrentIGOMLanguages() {
		List<String> availableLanguages = new List<String>();
		for (Document__c activeManual : [SELECT Id, Language__c FROM Document__c WHERE Is_Active__c = true AND RecordType.Name = :IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM ORDER BY Language__c]) {
			availableLanguages.add(activeManual.Language__c);
		}
		return availableLanguages;
	}

	/**
	 * @description	Get the chapter names that each document part belong to for an IGOM document.
	 * @param		manualId <IGOM document id>
	 * @return		Map<String, String> <Map containing the chapters that each document part belong to>
	 */
	public static Map<String, String> getPermidsToChapter(Id manualId) {
		Map<String, String> permidsToChapter = new Map<String, String>();
		for (Document_part__c documentPart : [SELECT Id, Name__c, Parent__r.External_Reference_ID__c, Category__c, External_Reference_ID__c FROM Document_part__c WHERE Document__c = :manualId ORDER BY Category__c]) {
			if (documentPart.Category__c == IGOMConstants.DOCUMENT_PART.CATEGORY.PART) {
				permidsToChapter.put(documentPart.External_Reference_ID__c, documentPart.Name__c);
			} else {
				permIdsToChapter.put(documentPart.External_Reference_ID__c, permidsToChapter.get(documentPart.Parent__r.External_Reference_ID__c));
			}
		}
		return permidsToChapter;
	}

	/**
	 * @description	Calls the getIGOMProcedures method to recover
	 * 				the latest inserted igom on the IGOMManual format with all
	 * 				it's children procedures.
	 * @param		language <Selected language>
	 * @return		IGOMManual <An IGOM Manual with it's children with the IGOMManual format>
	 */
	@AuraEnabled(cacheable=true)
	public static IGOMManual getCurrentIGOMFormatted(String language) {
		// Retrieve all active manual ids
		Map<String, Id> activeManualIdsByLanguage = new Map<String, Id>();
		Document__c mainActiveManual;
		for (Document__c activeManual : [SELECT Id, Language__c, Is_Active__c, Edition__c FROM Document__c WHERE Is_Active__c = true AND RecordType.Name = :IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM]) {
			activeManualIdsByLanguage.put(activeManual.Language__c, activeManual.Id);
			if (activeManual.Is_Active__c && activeManual.Language__c == IGOMConstants.GLOBALS.LANGUAGE_ENGLISH) {
				mainActiveManual = activeManual;
			}
		}
		if (activeManualIdsByLanguage.keySet().isEmpty()) {
			throw new AuraHandledException(IGOMConstants.ERRORS.NO_ACTIVE_MANUAL_ERROR);
		}
		if (mainActiveManual == null) {
			throw new AuraHandledException(IGOMConstants.ERRORS.NO_MAIN_IN_ACTIVE_MANUALS_ERROR);
		}
		// Retrieve the active manual
		IGOMManual manual = getIGOMProcedures(mainActiveManual.Id);
		for (IGOMProcedure proc: manual.chapters) {
			proc = refactorSection(proc);
		}
		// Retrieve the "dummy" manual with the texts if the language is not the same as the main
		if (String.isNotBlank(language) && mainActiveManual.Language__c != language) {
			if (!activeManualIdsByLanguage.keySet().contains(language)) {
				throw new AuraHandledException(String.format(IGOMConstants.ERRORS.NO_MANUAL_FOR_LANG_ERROR, new List<Object>{language}));
			}
			// Map the translation manual
			Id translationManualId = activeManualIdsByLanguage.get(language);
			IGOMManual translationManual = getIGOMProcedures(translationManualId);
			Map<String, IGOMProcedure> translationMap =
				new Map<String, IGOMProcedure>();
			for (IGOMProcedure proc : translationManual.chapters) {
				translationMap.putAll(mapProceduresByPermid(new Map<String, IGOMProcedure>(), proc));
			}
			if (translationMap.isEmpty()) {
				throw new AuraHandledException(String.format(IGOMConstants.ERRORS.EMPTY_TRANSLATION_MAP_ERROR, new List<Object>{translationManualId}));
			}
			// Apply the translations
			for (IGOMProcedure proc : manual.chapters) {
				proc = translateSection(proc, translationMap);
			}
		}
		return manual;
	}

	/**
	 * @description	Method to upsert a GOM document.
	 * @param		stationId <Active station id>
	 * @param		gomDocument <Document to upsert>
	 * @return		Document <Upserted document>
	 */
	@AuraEnabled
	public static Document upsertGomDocument(Id stationId, Document gomDocument)
	{
		if (!IGOMPermissions.hasPermission(stationId, IGOMConstants.PERMISSIONS.DOCUMENT_GAP)) {
			throw new AuraHandledException(String.format(IGOMConstants.ERRORS.REQUIRED_PERMISSIONS_MISSING_ERROR, new List<Object>{'manage GOM documents'}));
		}
		// Create the object from the passed data
		IGOMStationUtil.Station ownStation = IGOMStationUtil.getOwnStation(stationId);
		gomDocument.stationId = ownStation.accountRoleId;
		gomDocument.recordType = IGOMConstants.DOCUMENT.RECORD_TYPE.GOM;
		Document__c sfDocument = gomDocument.toSalesforce(true);
		// Upsert the document
		upsert sfDocument;
		// Return it with the wrapper
		return new Document(sfDocument);
	}

	/**
	 * @description	Method to import GOM documents to a station.
	 * @param		originalDocuments <Documents to import>
	 * @param		toStation <Station id>
	 * @return		Map<Id, Document> <New documents per old document id>
	 */
	public static Map<Id, Document> importGomDocuments(List<Document> originalDocuments, Id toStation) {
		Map<Document, Document__c> originalDocToSfNewDoc = new Map<Document, Document__c>();
		Set<Id> documentIds = new Set<Id>();
		Map<Id, Id> oldDocIdToNewDocId = new Map<Id, Id>();
		// Duplicate all the documents
		for (Document document : originalDocuments) {
			documentIds.add(document.id);
			document.stationId = toStation;
			document.recordType = IGOMConstants.DOCUMENT.RECORD_TYPE.GOM;
			Document__c sfNewDoc = document.toSalesforce(false);
			originalDocToSfNewDoc.put(document, sfNewDoc);
		}
		insert new List<Document__c>(originalDocToSfNewDoc.values());
		// Premap the new parent ids
		for (Document originalDocument : originalDocToSfNewDoc.keySet()) {
			final Document__c sfNewDocument = originalDocToSfNewDoc.get(originalDocument);
			oldDocIdToNewDocId.put(originalDocument.id, sfNewDocument.Id);
		}
		// Get the attachments
		List<Attachment> attachments = [SELECT Id, ParentId, Name, Description, Body FROM Attachment WHERE ParentId IN :documentIds];
		// Duplicate the associated attachments
		List<Attachment> clonedAttachments = IGOMAttachmentUtil.duplicateAttachments(attachments, oldDocIdToNewDocId);
		// Prepare the map to return
		Map<Id, Document> oldIdToNewDocs = new Map<Id, Document>();
		for (Document originalDocument : originalDocToSfNewDoc.keySet()) {
			final Document__c sfNewDocument = originalDocToSfNewDoc.get(originalDocument);
			Document newDocument = new Document(sfNewDocument);
			oldIdToNewDocs.put(originalDocument.id, newDocument);
			for (Attachment attachment : clonedAttachments) {
				if (attachment.ParentId == newDocument.id) {
					newDocument.attachments.add(attachment);
				}
			}
		}
		return oldIdToNewDocs;
	}

	/**
	 * @description	Method to delete a GOM document.
	 * @param		gomDocumentId <Document to delete>
	 */
	@AuraEnabled
	public static void deleteGomDocument(Id gomDocumentId) {
		// Validate the id type
		if (gomDocumentId.getSObjectType() != Document__c.getSObjectType()) {
			throw new AuraHandledException(IGOMConstants.ERRORS.ID_IS_NOT_DOCUMENT_ERROR);
		}
		List<Document> docs = queryDocumentById(new List<Id>{ gomDocumentId });
		// Validate that an item is retrieved
		if (docs.isEmpty()) {
			throw new AuraHandledException(String.format(IGOMConstants.ERRORS.NO_ITEM_FOR_ID_ERROR, new List<Object>{'Document', gomDocumentId}));
		}
		Document document = docs.get(0);
		// Validate the record type
		if (document.recordType != IGOMConstants.DOCUMENT.RECORD_TYPE.GOM) {
			throw new AuraHandledException(String.format(IGOMConstants.ERRORS.NO_ITEM_FOR_ID_ERROR, new List<Object>{'Document', gomDocumentId}));
		}
		// Query the station data
		Id accountRoleId = docs.get(0).stationId;
		Id stationId = [SELECT Id FROM IGOM_Account_Role_Detail__c WHERE Account_Role__c = :accountRoleId].Id;
		// Validate the documenting permissions
		if (!IGOMPermissions.hasPermission(stationId, IGOMConstants.PERMISSIONS.DOCUMENT_GAP)) {
			throw new AuraHandledException(String.format(IGOMConstants.ERRORS.REQUIRED_PERMISSIONS_MISSING_ERROR, new List<Object>{'manage GOM documents at this station'}));
		}
		// Remove the related compliance review parts
		List<Compliance_Review_Part__c> complianceReviewParts = [SELECT Id FROM Compliance_Review_Part__c WHERE Document__c = :gomDocumentId];
		delete complianceReviewParts;
		// Remove the document
		delete new Document__c(Id = gomDocumentId);
	}

	/**
	 * @description	Obtain all the indexes of the document parts of an igom document.
	 * @param		igomDocumentId <Document to delete>
	 * @return		Map<Id, Index> <Map with an Index per document part id>
	 */
	public static Map<Id, Index> getIGOMManualIndex(Id igomDocumentId) {
		Map<Id, Index> procedureIdToIndex = new Map<Id, Index>();
		for (Document_Part__c procedure :
			[SELECT Id, Name__c, Parent__c, Category__c, Is_Safety_Critical__c, Version_Change_Status__c, Index__c
			 FROM Document_Part__c
			 WHERE Document__c = :igomDocumentId AND Document__r.RecordType.Name = :IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM
			 ORDER BY Category__c])
		{
			final Index parentIndex = procedureIdToIndex.get(procedure.Parent__c);
			procedureIdToIndex.put(procedure.Id, new Index(procedure, parentIndex));
		}
		return procedureIdToIndex;
	}
	
	/**
	 * @description	Upload an IGOM document from an XML document.
	 * @return		Id <Document id>
	 */
	@AuraEnabled
	public static Id uploadIGOMDocument(String xmlDoc) {
		if (!IGOMPermissions.hasPermission(IGOMConstants.PERMISSIONS.UPLOAD_MANUAL)) {
			throw new AuraHandledException(String.format(IGOMConstants.ERRORS.REQUIRED_PERMISSIONS_MISSING_ERROR, new List<Object>{'upload a new manual'}));
		}
		Id igomDocumentId = IGOMParser.parse(xmlDoc);
		return igomDocumentId;
	}

	/**
	 * @description	Update an IGOM document with certain parameters and activate it.
	 * @param		manualId <Document Id>
	 * @param		documentName <Document name>
	 * @param		version <Document version>
	 * @param		publishedDate <Document published date>
	 */
	@AuraEnabled
	public static void activateIGOMManual(Id manualId) {
		// Validate the permissions
		if (!IGOMPermissions.hasPermission(IGOMConstants.PERMISSIONS.UPLOAD_MANUAL)) {
			throw new AuraHandledException(String.format(IGOMConstants.ERRORS.REQUIRED_PERMISSIONS_MISSING_ERROR, new List<Object>{'upload a new manual'}));
		}
		try {
			// Update the document object
			Document__c igom = [SELECT Language__c, Revision__c FROM Document__c WHERE RecordType.Name = :IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM AND Id = :manualId];
			igom.Is_Active__c = true;
			update igom;
			// Deactivate all old manuals if there is a new manual in english active
			if (igom.Language__c == IGOMConstants.GLOBALS.LANGUAGE_ENGLISH) {
				List<Document__c> oldManuals = [SELECT Id FROM Document__c WHERE Id != :manualId AND Is_Active__c = true AND RecordType.Name = :IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM];
				for (Document__c man : oldManuals){
					man.Is_Active__c = false;
				}
				update oldManuals;
				// Send notifications on new IGOM in english (the main one)
				IGOMNotificationUtil.sendIGOMNotifications(manualId);
			}
		} catch (Exception ex) {
			// In case of error delete the manual
			delete new Document__c(Id = manualId);
			throw new AuraHandledException(String.format(IGOMConstants.ERRORS.AN_ERROR_OCURRED_WHILE_ERROR, new List<Object>{'updating the manual data', ex.getMessage()}));
		}
	}

	/**
	 * @description	Get the IGOM Document parts of the active IGOM document.
	 * @param		manualId <Document Id>
	 * @return		IGOMManual <IGOM object>
	 */
	@AuraEnabled
	public static IGOMManual getIGOMProcedures(Id manualId) {
		// Default manual id to last one existing
		List<Document__c> lastManual = [SELECT Id FROM Document__c WHERE Is_Active__c = true AND Language__c = :IGOMConstants.GLOBALS.LANGUAGE_ENGLISH AND RecordType.Name = :IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM ORDER BY CreatedDate DESC LIMIT 1];
		if (lastManual.isEmpty()) {
			throw new AuraHandledException(IGOMConstants.ERRORS.NO_ACTIVE_AND_MAIN_MANUAL_ERROR);
		}
		Id lastManualId = lastManual[0].Id;
		if (manualId == null) {
			manualId = lastManualId;
		}
		if (manualId == lastManualId) {
			if (!IGOMPermissions.hasPermission(IGOMConstants.PERMISSIONS.VIEW_LAST_MANUAL)) {
				throw new AuraHandledException(String.format(IGOMConstants.ERRORS.REQUIRED_PERMISSIONS_MISSING_ERROR, new List<Object>{'view the current active manual'}));
			}
		} else {
			if (!IGOMPermissions.hasPermission(IGOMConstants.PERMISSIONS.VIEW_ALL_MANUALS)) {
				throw new AuraHandledException(String.format(IGOMConstants.ERRORS.REQUIRED_PERMISSIONS_MISSING_ERROR, new List<Object>{'view all the manuals'}));
			}
		}
		// Create the manual object
		List<Document__c> sfManual = 
			[SELECT Document_Name__c, Published_Date__c, Effective_Date__c, Review_Date__c, Version__c, Edition__c
			 FROM Document__c 
			 WHERE Id = :manualId AND RecordType.Name = :IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM LIMIT 1];
		if (sfManual.isEmpty()) {
			throw new AuraHandledException(String.format(IGOMConstants.ERRORS.NO_ITEM_FOR_ID_ERROR, new List<Object>{'IGOM Manual', manualId}));
		}
		IGOMManual manual = new IGOMManual(sfManual.get(0));
		// Save the wrappers in a map by Id and link the chapters
		Map<Id, IGOMProcedure> igomProcedureById = new Map<Id, IGOMProcedure>();
		for (Document_Part__c sfIgomProcedure : 
			[SELECT Id, Name__c, Category__c, Parent__c, Index__c, Version_Change_Status__c, Is_Safety_Critical__c, External_Reference_ID__c, Document__c
			 FROM Document_Part__c 
			 WHERE Document__c = :manualId
			 ORDER BY Index__c]) {
			IGOMProcedure procedure = new IGOMProcedure(sfIgomProcedure);
			igomProcedureById.put(sfIgomProcedure.Id, procedure);
			if (sfIgomProcedure.Parent__c == null) {
				manual.chapters.add(procedure);
			}
		}
		// Link every procedure with its parent
		for (IGOMProcedure currentProcedure : igomProcedureById.values()) {
			if (currentProcedure.procedure.Parent__c != null) {
				IGOMProcedure parentProcedure = igomProcedureById.get(currentProcedure.procedure.Parent__c);
				if(parentProcedure != null){
					if(parentProcedure.subprocedures == null){
						parentProcedure.subprocedures = new List<IGOMProcedure>(); 
					}
					parentProcedure.subprocedures.add(currentProcedure);
				}
			}
		}
		// Precalculate the full index
		List<IGOMProcedure> childs = new List<IGOMProcedure>();
		for (IGOMProcedure chapter : manual.chapters) {
			chapter.index = (chapter.procedure.Index__c == null ? 'x' : String.valueOf(chapter.procedure.Index__c));
			childs.addAll(chapter.subprocedures);
		}
		while (childs.size() > 0) {
			IGOMProcedure currentProcedure = childs.remove(0);
			currentProcedure.index = igomProcedureById.get(currentProcedure.procedure.Parent__c).index 
				+ '.' + (currentProcedure.procedure.Index__c == null ? 'x' : String.valueOf(currentProcedure.procedure.Index__c));
			childs.addAll(currentProcedure.subprocedures);
		}
		return manual;
	}

	/**
	 * @description	Get the entire list of IGOM documents.
	 * @return		List<Document__c> <IGOM Document list>
	 */
	@AuraEnabled(cacheable=true)
	public static List<Document__c> getIGOMManuals() {
		return 
			[SELECT Id, Document_Name__c, Edition__c, Version__c, CreatedDate 
			 FROM Document__c
			 WHERE RecordType.Name = :IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM
			 ORDER BY CreatedDate DESC];
	}

	/**
	 * @description	Calculate document reference
	 * @param		doc <Document to create the reference from>
	 * @return		String <The calculated reference>
	 */
	public static String getDocumentReference(Document__c doc){
		String ref = doc.Abbreviated_Name__c;
		if (!String.isBlank(doc.Edition__c)) {
			ref += ' Ed.' + doc.Edition__c;
		}
		if (!String.isBlank(doc.Version__c)) {
			ref += ' V.' + doc.Version__c;
		}
		if (!String.isBlank(doc.Revision__c)) {
			ref += ' R.' + doc.Revision__c;
		}
		return ref;
	}
	
	/**
	 * @description	Transform an IGOMProcedure to see if it has been modified.
	 * @param		procedure <IGOM procedure to transform>
	 * @return		IGOMProcedure <Transformed object>
	 */
	private static IGOMProcedure refactorSection(IGOMProcedure procedure){
		if (procedure.subprocedures != null && !procedure.subprocedures.isEmpty()) {
			// Go to lower lv and set flag modified
			for (IGOMProcedure proc : procedure.subprocedures) {
				proc = refactorSection(proc);
			}
			// Once all procedures have gone through refactor sections
			for (Integer i = (procedure.subprocedures.size()-1); i>=0; i--) {
				IGOMProcedure proc = procedure.subprocedures.get(i);
				// If it does not have subprocedures, do not leave an empty list
				if (proc.procedure.Version_Change_Status__c == IGOMConstants.DOCUMENT_PART.VERSION_CHANGE_STATUS.DELETED) {
					procedure.subprocedures.remove(i);
				}
				// If one child has been modified, make parent show modification
				if (proc.modified != null && proc.modified) {
					procedure.modified = true;
				}
				//If it does not have subprocedures, do not leave an empty list
				if (proc.subprocedures != null && proc.subprocedures.size() == 0) {
					proc.subprocedures = null;
				}
			}
		} else {
			procedure.modified = 
				(procedure.procedure.Version_Change_Status__c != IGOMConstants.DOCUMENT_PART.VERSION_CHANGE_STATUS.NONE 
				 && procedure.procedure.Version_Change_Status__c != IGOMConstants.DOCUMENT_PART.VERSION_CHANGE_STATUS.DELETED);
		}
		return procedure;
	}

	/**
	 * @description	Map the document part into a map of document parts per external id.
	 * @param		partialResult <Built map so far>
	 * @param		procedure <Document part>
	 * @return		Map<String, IGOMProcedure> <Document parts per external id>
	 */
	private static Map<String, IGOMProcedure> mapProceduresByPermid(
		Map<String, IGOMProcedure> partialResult, 
		IGOMProcedure procedure
	) {
		partialResult.put(procedure.procedure.External_Reference_ID__c, procedure);
		if (procedure.subprocedures != null && !procedure.subprocedures.isEmpty()) {
			for(IGOMProcedure subproc : procedure.subprocedures){
				mapProceduresByPermid(partialResult, subproc);
			}
		}
		return partialResult;
	}

	/**
	 * @description	Translate a document part 
	 * @param		procedure <Document part>
	 * @param		translations <Map of a Document part translation per external id>
	 * @return		IGOMProcedure <Translated Document part>
	 */
	private static IGOMProcedure translateSection(
		IGOMProcedure procedure,
		Map<String, IGOMProcedure> translations
	) {
		// Translate current procedure
		Document_Part__c originalProcedure = procedure.procedure;
		if (!translations.keySet().contains(originalProcedure.External_Reference_ID__c)) {
			String translationManualId = translations.isEmpty() ? '[empty translations]' : translations.values()[0].procedure.Document__c;
			throw new AuraHandledException(String.format(IGOMConstants.ERRORS.PROCEDURE_WITH_NO_TRANSLATION_IN_MANUAL_ERROR, new List<Object>{originalProcedure.External_Reference_ID__c, translationManualId}));
		}
		Document_Part__c translationProcedure = translations.get(originalProcedure.External_Reference_ID__c).procedure;
		// ------------ TRANSLATION MAPPING ----------------
		//originalProcedure.Id = translationProcedure.Id;
		originalProcedure.Name__c = translationProcedure.Name__c;
		// ------------ TRANSLATION MAPPING ----------------
		// Translate childs
		if (procedure.subprocedures != null && !procedure.subprocedures.isEmpty()) {
			for (IGOMProcedure subproc : procedure.subprocedures) {
				translateSection(subproc, translations);
			}
		}
		return procedure;
    }
}