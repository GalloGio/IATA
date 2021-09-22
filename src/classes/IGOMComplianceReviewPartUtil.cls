/**
 * @description	  Class to contain all the functions related to the Compliance_Review_Part__c object
 */
public without sharing class IGOMComplianceReviewPartUtil {

	/**
	 * DAO Object containing the data from a Compliance_Review_Part__c record
	 */
	public class ComplianceReviewPart {
		// Writable
		@AuraEnabled public Id id { get; set; }
		@AuraEnabled public Id gapAnalysisId { get; set; }
		@AuraEnabled public Id document { get; set; }
		@AuraEnabled public String statusValue { get; set; }
		@AuraEnabled public Boolean isReviewed { get; set; }
		@AuraEnabled public String variationStatus { get; set; }
		@AuraEnabled public String notes { get; set; }
		@AuraEnabled public String variation { get; set; }
		@AuraEnabled public String variationComments { get; set; }
		@AuraEnabled public String variationCommentLang { get; set; }
		@AuraEnabled public String variationAlternativeComments { get; set; }
		@AuraEnabled public String userProvisionProcedure { get; set; }
		@AuraEnabled public Id igomAuditableProcedureId { get; set; }
		@AuraEnabled public IGOMDocumentUtil.Index index;
		// Read-only
		@AuraEnabled public String userProvisionDocument;
		@AuraEnabled public Boolean modified;
		@AuraEnabled public Id chapterId;
		@AuraEnabled public String chapterName;
		@AuraEnabled public String igomAuditableProcedureName;
		@AuraEnabled public Boolean igomAuditableProcedureIsCritical;
		@AuraEnabled public List<Attachment> attachments;
		// Apex-only
		public String documentPartPermId;

		public ComplianceReviewPart() {
			this.isReviewed = true;
			this.attachments = new List<Attachment>();
		}

		public ComplianceReviewPart(Compliance_Review_Part__c procedureCompliance) {
			this();
			this.id = procedureCompliance.Id;
			this.modified = procedureCompliance.Standard_Document_Part__r.Version_Change_Status__c == 'Modified' ;
			this.statusValue = procedureCompliance.Validity__c;
			this.isReviewed = procedureCompliance.Is_Reviewed__c;
			this.variationStatus = procedureCompliance.Status__c;
			this.userProvisionProcedure = procedureCompliance.User_Provision_Procedure__c != null ? procedureCompliance.User_Provision_Procedure__c : '';
			this.document = procedureCompliance.Document__c;
 			this.variationComments = procedureCompliance.Variation_Comments__c;
 			this.variationAlternativeComments = procedureCompliance.Variation_Alternative__c;
 			this.variationCommentLang = procedureCompliance.Comment_Language__c;
			this.gapAnalysisId = procedureCompliance.Compliance_Review__c;
			this.igomAuditableProcedureId = procedureCompliance.Standard_Document_Part__c;
			this.documentPartPermId = procedureCompliance.Standard_Document_Part__r.External_Reference_ID__c;
			this.igomAuditableProcedureName = procedureCompliance.Standard_Document_Part__r.Name__c;
			this.igomAuditableProcedureIsCritical = procedureCompliance.Standard_Document_Part__r.Is_Safety_Critical__c;
			if (Test.isRunningTest() || IGOMPermissions.hasPermission(IGOMConstants.PERMISSIONS.VIEW_COMMENTS_GAP)) {
				this.notes = procedureCompliance.Comments__c;
			}
			if (procedureCompliance.Document__c != null) {
				Document__c doc = new Document__c(
					Id = procedureCompliance.Document__c,
					Abbreviated_Name__c = procedureCompliance.Document__r.Abbreviated_Name__c,
					Edition__c = procedureCompliance.Document__r.Edition__c,
					Version__c = procedureCompliance.Document__r.Version__c,
					Revision__c = procedureCompliance.Document__r.Revision__c
				);
				String provisionDocument = String.isBlank(procedureCompliance.Standard_Document_Part__c) ? IGOMConstants.GLOBALS.NONE : IGOMDocumentUtil.getDocumentReference(doc);
				this.userProvisionDocument = provisionDocument;
				this.variation = provisionDocument + ' - ' + procedureCompliance.User_Provision_Procedure__c;
			}
			this.attachments.addAll(procedureCompliance.Attachments);
		}

		public void addIndex(IGOMDocumentUtil.Index index) {
			this.chapterId = index.chapterId;
			this.chapterName = index.chapterName;
			this.index = index;
		}

		//Method to check if the current compliance review part is notifiable
		public Boolean isNotifiable(ComplianceReviewPart other) {
			return this.variationStatus == IGOMConstants.PROCEDURE_COMPLIANCE.STATUS.VARIATION ||
			other?.variationStatus == IGOMConstants.PROCEDURE_COMPLIANCE.STATUS.VARIATION ||
			(other != null && other?.variationStatus != IGOMConstants.PROCEDURE_COMPLIANCE.STATUS.VARIATION && this.variationStatus != other?.variationStatus);
		}

		public Compliance_Review_Part__c toSalesforce(Boolean keepId) {
			Compliance_Review_Part__c sfObject = new Compliance_Review_Part__c(
				Id = keepId ? this.id : null,
				Is_Reviewed__c = this.isReviewed,
				Status__c = this.variationStatus,
				User_Provision_Procedure__c = this.userProvisionProcedure != '' ? this.userProvisionProcedure : null,
				Document__c = this.document,
				Variation_Comments__c = this.variationComments,
				Variation_Alternative__c = this.variationAlternativeComments,
				Comment_Language__c = this.variationCommentLang,
				Compliance_Review__c = this.gapAnalysisId,
				Standard_Document_Part__c = this.igomAuditableProcedureId
			);
			if (IGOMPermissions.hasPermission(IGOMConstants.PERMISSIONS.VIEW_COMMENTS_GAP)) {
				sfObject.Comments__c = this.notes;
			}
			return sfObject;
		}
	}

	/**
	 * @description	Recover a list of ComplianceReviewPart objects from a list of Compliance_Review_Part__c records.
	 * @param		queriedSObjects <List of Compliance_Review_Part__c records>
	 * @return		List<ComplianceReviewPart> <List of ComplianceReviewPart objects>
	 */
	private static List<ComplianceReviewPart> fromList(List<Compliance_Review_Part__c> queriedSObjects) {
		List<ComplianceReviewPart> complianceReviewParts = new List<ComplianceReviewPart>();
		for (Compliance_Review_Part__c sfComplianceReview : queriedSObjects) {
			complianceReviewParts.add(new ComplianceReviewPart(sfComplianceReview));
		}
		return complianceReviewParts;
	}

	/**
	 * @description	Recover a list of ComplianceReviewPart objects from their ids.
	 * @param		complianceReviewPartIds <List of ids of compliance review parts>
	 * @return		List<ComplianceReviewPart> <List of ComplianceReviewPart objects>
	 */
	public static List<ComplianceReviewPart> getComplianceReviewPartById(List<Id> complianceReviewPartIds) {
		return fromList(
			[SELECT Id, Name, Comments__c,  Document__c, Document__r.Edition__c, Document__r.Version__c, Document__r.Revision__c,
					Validity__c, Status__c, Variation_Comments__c, Variation_Alternative__c, Document__r.Abbreviated_Name__c,
					Comment_Language__c, Compliance_Review__c, User_Provision_Procedure__c, Standard_Document_Part__r.External_Reference_ID__c ,
					Standard_Document_Part__c, Standard_Document_Part__r.Category__c, Standard_Document_Part__r.Name__c, Standard_Document_Part__r.Version_Change_Status__c,
					Standard_Document_Part__r.Document__r.Abbreviated_Name__c, Standard_Document_Part__r.Document__r.Edition__c,
					Standard_Document_Part__r.Document__r.Version__c, Standard_Document_Part__r.Document__r.Revision__c,
					Standard_Document_Part__r.Is_Safety_Critical__c, Is_Reviewed__c
			 FROM Compliance_Review_Part__c
			 WHERE Id IN :complianceReviewPartIds]
		);
	}

	/**
	 * @description	Recover a list of ComplianceReviewPart objects from their related compliance review ids.
	 * @param		complianceReviewIds <List of ids of compliance review parts>
	 * @return		List<ComplianceReviewPart> <List of ComplianceReviewPart objects>
	 */
	public static List<ComplianceReviewPart> getComplianceReviewPartByComplianceReview(List<Id> complianceReviewIds) {
		return fromList(
			[SELECT Id, Name, Comments__c,  Document__c, Document__r.Edition__c, Document__r.Version__c, Document__r.Revision__c,
					Validity__c, Status__c, Variation_Comments__c, Variation_Alternative__c,Document__r.Abbreviated_Name__c,
					Comment_Language__c, Compliance_Review__c, User_Provision_Procedure__c, Standard_Document_Part__r.External_Reference_ID__c ,
					Standard_Document_Part__c, Standard_Document_Part__r.Category__c, Standard_Document_Part__r.Name__c, Standard_Document_Part__r.Version_Change_Status__c,
					Standard_Document_Part__r.Document__r.Abbreviated_Name__c, Standard_Document_Part__r.Document__r.Edition__c,
					Standard_Document_Part__r.Document__r.Version__c, Standard_Document_Part__r.Document__r.Revision__c,
					Standard_Document_Part__r.Is_Safety_Critical__c, Is_Reviewed__c, Standard_Document_Part__r.Document__c,
					(SELECT Id, Name FROM Attachments)
			FROM Compliance_Review_Part__c
			WHERE Compliance_Review__c IN :complianceReviewIds]
		);
	}

	/**
	 * @description	Get the compliance review parts that are variations for a specific compiance review
	 * @param		complianceReviewId <Compliance review id>
	 * @return		Map<Id, IGOMDocumentUtil.Index> <Indexes per document part id>
	 */
	@AuraEnabled(cacheable=true)
	public static List<ComplianceReviewPart> getVariations(Id complianceReviewId) {
		// Validate permissions
		if (!IGOMPermissions.hasPermission(IGOMConstants.PERMISSIONS.VIEW_ALL_VARIATIONS)) {
			IGOMComplianceReviewUtil.checkPermissionOnComplianceReview(complianceReviewId, IGOMConstants.PERMISSIONS.VIEW_OWN_VARIATIONS);
		}
		// Get the manual preindexed
		Id manualId = [SELECT Document__c FROM Compliance_Review__c WHERE Id = :complianceReviewId].Document__c;
		Map<Id, IGOMDocumentUtil.Index> indexById = IGOMDocumentUtil.getIGOMManualIndex(manualId);
		// Get all the variations
		List<ComplianceReviewPart> variations = new List<ComplianceReviewPart>();
		for (ComplianceReviewPart complianceReviewPart : getComplianceReviewPartByComplianceReview(new List<Id>{ complianceReviewId })) {
			if (complianceReviewPart.variationStatus == IGOMConstants.PROCEDURE_COMPLIANCE.STATUS.VARIATION) {
				final IGOMDocumentUtil.Index index = indexById.get(complianceReviewPart.igomAuditableProcedureId);
				complianceReviewPart.addIndex(index);
				variations.add(complianceReviewPart);
			}
		}
		return variations;
	}

	/**
	 * @description	Method to upsert a compliance review part.
	 * @param		complianceReviewPart <Compliance review part to be upserted>
	 * @return		ComplianceReviewPart <The upserted compliance review part>
	 */
	@AuraEnabled
	public static ComplianceReviewPart upsertProcedureCompliance(ComplianceReviewPart complianceReviewPart)
	{
		IGOMComplianceReviewUtil.checkPermissionOnComplianceReview(complianceReviewPart.gapAnalysisId, IGOMConstants.PERMISSIONS.EDIT_GAP);
		complianceReviewPart.isReviewed = true;
		Compliance_Review_Part__c procedureCompliance = complianceReviewPart.toSalesforce(true);
		Database.upsert(procedureCompliance);
		return getComplianceReviewPartById(new List<Id>{ procedureCompliance.Id })[0];
	}

	/**
	 * @description	Method to delete a compliance review part by its id.
	 * @param		complianceReviewPartId <Compliance review part to be deleted>
	 */
	@AuraEnabled
	public static void deleteProcedureCompliance(Id compliaceReviewPartId)
	{
		if (compliaceReviewPartId.getSObjectType() === Compliance_Review_Part__c.getSObjectType())
		{
			checkPermissionOnComplianceReviewPart(compliaceReviewPartId, IGOMConstants.PERMISSIONS.EDIT_GAP);
			delete new Compliance_Review_Part__c(Id = compliaceReviewPartId);
		}
	}

	/**
	 * @description	Method to mark a compliance review part as Reviewed by its id.
	 * @param		compliaceReviewPartId <Compliance review part to be upserted>
	 */
	@AuraEnabled
	public static ComplianceReviewPart markAsReviewed(Id compliaceReviewPartId)
	{
		if (compliaceReviewPartId.getSObjectType() === Compliance_Review_Part__c.getSObjectType())
		{
			checkPermissionOnComplianceReviewPart(compliaceReviewPartId, IGOMConstants.PERMISSIONS.EDIT_GAP);
			Compliance_Review_Part__c procedureCompliance = new Compliance_Review_Part__c(Id = compliaceReviewPartId);
			procedureCompliance.Is_Reviewed__c = true;
			update procedureCompliance;
			return getComplianceReviewPartById(new List<Id>{ procedureCompliance.Id })[0];
		}
		return null;
	}

	/**
	 * @description	Confirm all the references that are not varying.
	 * @param		referencesToReview <Compliance review parts to be mark as reviewed>
	 */
	@AuraEnabled
	public static void confirmAllNonVariatingReferences(List<ComplianceReviewPart> referencesToReview) {
		if (referencesToReview == null || referencesToReview.isEmpty()) {
			throw new AuraHandledException(IGOMConstants.ERRORS.NO_REFERENCES_TO_REVIEW_ERROR);
		}
		Id gapAnalysisId = referencesToReview.get(0).gapAnalysisId;
		IGOMComplianceReviewUtil.checkPermissionOnComplianceReview(referencesToReview.get(0).gapAnalysisId, IGOMConstants.PERMISSIONS.EDIT_GAP);

		List<Compliance_Review_Part__c> reviewedReferences = new List<Compliance_Review_Part__c>();
		for (ComplianceReviewPart reference : referencesToReview) {
			if (gapAnalysisId == reference.gapAnalysisId) {
				if (reference.variationStatus != IGOMConstants.PROCEDURE_COMPLIANCE.STATUS.VARIATION) {
					Compliance_Review_Part__c updatedRef = reference.toSalesforce(true);

					updatedRef.Is_Reviewed__c = true;
					reviewedReferences.add(updatedRef);
				}
			} else {
				throw new AuraHandledException(IGOMConstants.ERRORS.CANT_MIX_REFERENCES_FROM_DIFF_GAPS_ERROR);
			}
		}

		upsert reviewedReferences;
	}

	/**
	 * @description	Obtain all the languages in the Picklist value set "Languages"
	 * @return		List<String> <List of available Languages>
	 */
	@AuraEnabled(cacheable=true)
	public static List<String> getVariationCommentAvailableLanguages() {
		List<String> picklistLabels = new List<String>();
		for(Schema.PicklistEntry pickListVal : Utility.getPicklistEntries('Compliance_Review_Part__c', 'Comment_Language__c')){
			picklistLabels.add(pickListVal.getLabel());
		}
		return picklistLabels;
	}

	/**
	 * @description	Checks a specific permission on a station from a compliance review part id.
	 * @param		complianceReviewPartId <Compliance review part id>
	 * @param		permissionName <Name of the specific permission>
	 * @return		Id of the related station
	 */
	public static Id checkPermissionOnComplianceReviewPart(Id complianceReviewPartId, String permissionName) {
		Compliance_Review_Part__c complianceReviewPart = [SELECT Compliance_Review__r.Station__c FROM Compliance_Review_Part__c WHERE Id = :complianceReviewPartId];
		List<IGOM_Account_Role_Detail__c> stations = [SELECT Id FROM IGOM_Account_Role_Detail__c WHERE Account_Role__c = :complianceReviewPart.Compliance_Review__r.Station__c];
		if (stations.isEmpty() || !IGOMPermissions.hasPermission(stations.get(0).Id, permissionName)) {
			throw new AuraHandledException(String.format(IGOMConstants.ERRORS.REQUIRED_PERMISSIONS_MISSING_ERROR, new List<Object>{'view variations for this station'}));
		}
		return stations.get(0).Id;
	}


	/**
	 * @description		Recover a list of ComplianceReviewPart objects from their related compliance review ids.
	 * @param			complianceReviewIds <List of ids of compliance review parts>
	 * @return			List<ComplianceReviewPart> <List of ComplianceReviewPart objects>
	 */
	public static List<ComplianceReviewPart> getComplianceReviewParts(List<Id> complianceReviewIds) {
		return fromList(
			[SELECT Id, Name, Comments__c,  Document__c, Document__r.Edition__c, Document__r.Version__c, Document__r.Revision__c,
					Validity__c, Status__c, Variation_Comments__c, Variation_Alternative__c,Document__r.Abbreviated_Name__c,
					Comment_Language__c, Compliance_Review__c, User_Provision_Procedure__c, Standard_Document_Part__r.External_Reference_ID__c ,
					Standard_Document_Part__c, Standard_Document_Part__r.Category__c, Standard_Document_Part__r.Name__c, Standard_Document_Part__r.Version_Change_Status__c,
					Standard_Document_Part__r.Document__r.Abbreviated_Name__c, Standard_Document_Part__r.Document__r.Edition__c,
					Standard_Document_Part__r.Document__r.Version__c, Standard_Document_Part__r.Document__r.Revision__c,
					Standard_Document_Part__r.Is_Safety_Critical__c, Is_Reviewed__c, Standard_Document_Part__r.Document__c
			FROM Compliance_Review_Part__c
			WHERE Compliance_Review__c IN :complianceReviewIds]
		);
	}

	/**
	 * @description Compares two different compliance reviews and return the compliance review parts of the new one that can be notified based on
	 * the modifications found between these compliance reviews
	 * note: parts of the old one that don't appear in the new one won't be returned, as only the parts from the new one will be returned.
	 * @param		complianceReviewOldId <Id of the old compliance review>
	 * @param		complianceReviewNewId <Id of the new compliance review>
	 * @return		List<ComplianceReviewPart> <List of compliance review parts that can be notified>
	 */
	public static List<ComplianceReviewPart> getNotifiableParts(Id complianceReviewOldId, Id complianceReviewNewId) {
		List<ComplianceReviewPart> complianceReviewPartsToNotify = new List<ComplianceReviewPart>();
		// Get every compliance review part of the compliance reviews
		List<ComplianceReviewPart> complianceReviewPartsOld = getComplianceReviewParts(new List<Id>{complianceReviewOldId});
		List<ComplianceReviewPart> complianceReviewPartsNew = getComplianceReviewParts(new List<Id>{complianceReviewNewId});
		// Group the compliance review parts by the permid
		Map<String, List<ComplianceReviewPart>> permIdToComplianceReviewPartOld = new Map<String, List<ComplianceReviewPart>>();
		for (ComplianceReviewPart part : complianceReviewPartsOld) {
			List<ComplianceReviewPart> complianceReviewParts = permIdToComplianceReviewPartOld.get(part.documentPartPermId);
			if (complianceReviewParts == null) {
				complianceReviewParts = new List<ComplianceReviewPart>();
				permIdToComplianceReviewPartOld.put(part.documentPartPermId, complianceReviewParts);
			}
			complianceReviewParts.add(part);
		}
		Map<String, List<ComplianceReviewPart>> permIdToComplianceReviewPartNew = new Map<String, List<ComplianceReviewPart>>();
		for (ComplianceReviewPart part : complianceReviewPartsNew) {
			List<ComplianceReviewPart> complianceReviewParts = permIdToComplianceReviewPartNew.get(part.documentPartPermId);
			if (complianceReviewParts == null) {
				complianceReviewParts = new List<ComplianceReviewPart>();
				permIdToComplianceReviewPartNew.put(part.documentPartPermId, complianceReviewParts);
			}
			complianceReviewParts.add(part);
		}
		// Compare the content
		for (String permId : permIdToComplianceReviewPartNew.keySet()) {
			final List<ComplianceReviewPart> newComplianceReviewParts = permIdToComplianceReviewPartNew.get(permId);
			Boolean isNotifiable = areComplianceReviewPartContentsNotifiable(newComplianceReviewParts, permIdToComplianceReviewPartOld.get(permId));
			if (isNotifiable) {
				complianceReviewPartsToNotify.addAll(newComplianceReviewParts);
			}
		}
		// Return the content with the differences
		return complianceReviewPartsToNotify;
	}

	/**
	 * @description Helper function to compare the content of two Compliance review part lists and know if first compliance review parts are notifiable.
	 * @param		first <List of compliance review parts to be compared>
	 * @param		second <List of compliance review parts to be compared>
	 * @return		Boolean <Result that states if the compliance review part is notifiable>
	 */
	private static Boolean areComplianceReviewPartContentsNotifiable(List<ComplianceReviewPart> first, List<ComplianceReviewPart> second) {
		for (ComplianceReviewPart part1 : first) {
			if(second != null){
				for (ComplianceReviewPart part2 : second) {
					if(part1.isNotifiable(part2)){
						return true;
					}
				}
			}else{
				if(part1.isNotifiable(null)){
					return true;
				}
			}
		}
		return false;
	}
}