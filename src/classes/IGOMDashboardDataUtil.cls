public without sharing class IGOMDashboardDataUtil {

	/**
	 * Result object for the procedureToChapter method
	 */
	private class ProcedureToChapterResult {
		public Map<Id, Id> procedureIdToChapterId;
		public Map<Id, String> chapterIdToName;
		public ProcedureToChapterResult() {
			this.procedureIdToChapterId = new Map<Id, Id>();
			this.chapterIdToName = new Map<Id, String>();
		}
	}

	/**
	 * Station summary object for the getStationSummary method
	 */
	@TestVisible
	private class StationSummary {
		@AuraEnabled public Date lastGapAnalysisDate;
		@AuraEnabled public Integer lastGapAnalysisVariations;
		@AuraEnabled public Integer totalAcknowledgements;
		@AuraEnabled public Integer readAcknowledgements;
	}

	/**
	 * @description	Auxiliar method to retrieve information regarding a manual's chapters.
	 * @param		manualId <Id of the manual>
	 * @return		ProcedureToChapterResult <Object containing a map with the chapter for each procedure and the name of the chapters>
	 */
	private static ProcedureToChapterResult procedureToChapter(Id manualId) {
		// Get procedureId to chapterId map
		IGOMDocumentUtil.IGOMManual manual = IGOMDocumentUtil.getIGOMProcedures(manualId);
		ProcedureToChapterResult resultWrapper = new ProcedureToChapterResult();
		for (IGOMDocumentUtil.IGOMProcedure chapter : manual.chapters) {
			resultWrapper.chapterIdToName.put(chapter.procedure.Id, chapter.procedure.Name__c);
			List<IGOMDocumentUtil.IGOMProcedure> childs = new List<IGOMDocumentUtil.IGOMProcedure>();
			childs.addAll(chapter.subprocedures);
			while (childs.size() > 0) {
				IGOMDocumentUtil.IGOMProcedure currentProcedure = childs.remove(0);
				resultWrapper.procedureIdToChapterId.put(currentProcedure.procedure.Id, chapter.procedure.Id);
				childs.addAll(currentProcedure.subprocedures);
			}
		}
		return resultWrapper;
	}

	/**
	 * @description	Auxiliar method to get the summary data of some stations.
	 * @param		List<Id> <List of stations as account role ids>
	 * @return		Map<Id, StationSummary> <A map with the station ids and summaries>
	 */ 
	@AuraEnabled(cacheable=true)
	public static Map<Id, StationSummary> getStationSummary(List<Id> stationIds) {
		if (!IGOMPermissions.hasPermission(IGOMConstants.PERMISSIONS.VIEW_OWN_VARIATIONS) &&
			!IGOMPermissions.hasPermission(IGOMConstants.PERMISSIONS.VIEW_OWN_DASHBOARD)) {
			throw new AuraHandledException(String.format(IGOMConstants.ERRORS.REQUIRED_PERMISSIONS_MISSING_ERROR, new List<Object>{'see station summaries'}));
		}
		Map<Id, StationSummary> stationSummaries = new Map<Id, StationSummary>();
		IGOMDocumentUtil.Document activeManual = IGOMDocumentUtil.getLastActiveIGOMManual();
		Set<Id> allPublishedGapIds = new Set<Id>();
		Map<Id, Id> complianceReviewIdToStationId = new Map<Id, Id>();
		// Get every published gap id from the given stations
		for (Id stationId : stationIds) {
			stationSummaries.put(stationId, new StationSummary());
			List<Id> publishedGapIds = IGOMComplianceReviewUtil.getSplitGapAnalysis(activeManual.id, stationId, true);
			allPublishedGapIds.addAll(publishedGapIds);
		}
		// Get the compliance reviews for the date
		for(Compliance_Review__c complianceReview :
			[SELECT Id, Effective_Date__c, Station__c FROM Compliance_Review__c WHERE Id IN :allPublishedGapIds])
		{
			complianceReviewIdToStationId.put(complianceReview.Id, complianceReview.Station__c);
			StationSummary stationSummary = stationSummaries.get(complianceReview.Station__c);
			if (stationSummary.lastGapAnalysisDate == null) {
				stationSummary.lastGapAnalysisDate = complianceReview.Effective_Date__c;
			} else if (stationSummary.lastGapAnalysisDate < complianceReview.Effective_Date__c) {
				stationSummary.lastGapAnalysisDate = complianceReview.Effective_Date__c;
			}
		}
		// Get the variation counts
		for (AggregateResult groupedResult : 
			 [SELECT Count(Id) variationCount, Compliance_Review__c
			  FROM Compliance_Review_Part__c 
			  WHERE Compliance_Review__c IN :allPublishedGapIds 
					AND Status__c = :IGOMConstants.PROCEDURE_COMPLIANCE.STATUS.VARIATION
			  GROUP BY Compliance_Review__c]) 
		{
			final Id complianceReview = (Id)groupedResult.get('Compliance_Review__c');
			final Decimal variationCount = (Decimal)groupedResult.get('variationCount');
			final Id stationId = complianceReviewIdToStationId.get(complianceReview);
			StationSummary stationSummary = stationSummaries.get(stationId);
			if (stationSummary.lastGapAnalysisVariations == null) {
				stationSummary.lastGapAnalysisVariations = 0;
			}
			stationSummary.lastGapAnalysisVariations += (Integer)variationCount;
		}
		// Get the acknowledgement counts
		for (AggregateResult groupedResult :
			 [SELECT COUNT(id) notificationCount, Notification_Status__c, Compliance_Review_Part__r.Compliance_Review__c 
			  FROM IGOM_Contact_Role_Procedure_Compliance__c 
			  WHERE Compliance_Review_Part__r.Compliance_Review__c IN :allPublishedGapIds
			  GROUP BY Notification_Status__c, Compliance_Review_Part__r.Compliance_Review__c]) 
		{
			final Id complianceReview = (Id)groupedResult.get('Compliance_Review__c');
			final Decimal notificationCount = (Decimal)groupedResult.get('notificationCount');
			final String notificationStatus = (String)groupedResult.get('Notification_Status__c');
			final Id stationId = complianceReviewIdToStationId.get(complianceReview);
			StationSummary stationSummary = stationSummaries.get(stationId);
			// Initialize variables (in case read is 0 too)
			if (stationSummary.readAcknowledgements == null) {
				stationSummary.readAcknowledgements = 0;
			}
			if (stationSummary.totalAcknowledgements == null) {
				stationSummary.totalAcknowledgements = 0;
			}
			// Count read ones
			if (notificationStatus == IGOMConstants.NOTIFICATION.STATUS.ACKNOWLEDGED) {
				stationSummary.readAcknowledgements = (Integer)notificationCount;
			}
			// Add totals
			stationSummary.totalAcknowledgements += (Integer)notificationCount;
		}
		return stationSummaries;
	}

	/**
	 * @description	Method for the dashboard to retrieve information regarding a GAP Analysis.
	 *              The information retrieved shows the acknowledgements of the GAP Analysis and the status of each of them.
	 * @param		gapAnalysisId <Id of the GAP Analysis>
	 * @return		String <A JSON formatted string containing a Map<String, Map<String, String>> where the map contains per each User the Acknowledgement and its status, the keys are 'id:name' strings>
	 */
	@AuraEnabled(cacheable=true)
	public static String userToProcedureToAcknowledgementStatus(Id gapAnalysisId) {
		// Check permissions
		checkDashboardPermissionOnComplianceReview(gapAnalysisId);
		// Query all the notifications and for each user save all its statuses
		Map<String, Map<String, String>> userToAcknowledgementToStatus = new Map<String, Map<String, String>>();
		for (IGOM_Contact_Role_Procedure_Compliance__c notification : 
			[SELECT Notification_Status__c, IGOM_Contact_Role_Detail__c, Compliance_Review_Part__c,
					Compliance_Review_Part__r.Standard_Document_Part__r.Name__c,
					IGOM_Contact_Role_Detail__r.Account_Contact_Role__r.Contact__r.Name
			 FROM IGOM_Contact_Role_Procedure_Compliance__c
			  WHERE Compliance_Review_Part__r.Compliance_Review__c = :gapAnalysisId AND IGOM_Contact_Role_Detail__c != null])
		{
			final String contactRoleDetailString = notification.IGOM_Contact_Role_Detail__c + ':' + notification.IGOM_Contact_Role_Detail__r.Account_Contact_Role__r.Contact__r.Name;
			Map<String, String> acknowledgementToStatus = userToAcknowledgementToStatus.get(contactRoleDetailString);
			if (acknowledgementToStatus == null) {
				acknowledgementToStatus = new Map<String, String>();
				userToAcknowledgementToStatus.put(contactRoleDetailString, acknowledgementToStatus);
			}
			final String acknowledgementString = notification.Compliance_Review_Part__c + ':' + notification.Compliance_Review_Part__r.Standard_Document_Part__r.Name__c;
			acknowledgementToStatus.put(acknowledgementString, notification.Notification_status__c);
		}
		return JSON.serialize(userToAcknowledgementToStatus);
	}

	/**
	 * @description	Method for the dashboard to retrieve information regarding the status of the visible stations.
	 * @return		Map<String, String> <A map containing a string formatted as "id:name" for each station as key and the station's status as value>
	 */
	@AuraEnabled(cacheable=true)
	public static Map<String, String> statusPerStation() {
		// Get the viewable stations
		List<Id> stationIds = getViewableStations();
		// Prefill the result with unpublished statuses
		Map<IGOM_Account_Role_Detail__c, String> stationToStatus = new Map<IGOM_Account_Role_Detail__c, String>();
		Map<Id, IGOM_Account_Role_Detail__c> accountRoleIdToAccountRole = new Map<Id, IGOM_Account_Role_Detail__c>();
		List<Id> accountRoleIds = new List<Id>();
		for (IGOM_Account_Role_Detail__c station : [SELECT Id, Account_Role__r.Account__r.Name, Account_Role__c FROM IGOM_Account_Role_Detail__c WHERE Id IN :stationIds]) {
			stationToStatus.put(station, 'Non-existing');
			accountRoleIdToAccountRole.put(station.Account_Role__c, station);
			accountRoleIds.add(station.Account_Role__c);
		}
		// Count the status values of each station
		for (AggregateResult aggr : 
			[SELECT Count(Id)num, Is_Reviewed__c, Compliance_Review__r.Station__c stationId
			 FROM Compliance_Review_Part__c 
			 WHERE Compliance_Review__r.Station__c IN :accountRoleIds
			 	   AND Compliance_Review__r.Document__r.Is_Active__c = true
				   AND Compliance_Review__r.Publish_Status__c != :IGOMConstants.COMPLIANCE_REVIEW.STATUS.TEMPLATE 
			 GROUP BY Is_Reviewed__c, Compliance_Review__r.Station__c]) 
		{
			Id stationId = (Id)(aggr.get('stationId'));
			String statusValue = (Boolean)(aggr.get('Is_Reviewed__c')) ? 'Reviewed' : 'Pending review';
			if (String.isNotBlank(stationId)) {
				Integer statusValueCount = (Integer)(aggr.get('num'));
				IGOM_Account_Role_Detail__c station = accountRoleIdToAccountRole.get(stationId);
				String previousStatus = stationToStatus.get(station);
				// Save the status, but 1 pending review is enough to not be reviewed
				if (statusValue == 'Pending review') {
					stationToStatus.put(station, 'Pending review');
				} else if (statusValue == 'Reviewed' && previousStatus != 'Pending review') {
					stationToStatus.put(station, 'Reviewed');
				}
			}
		}
		// Format key string
		Map<String, String> result = new Map<String, String>();
		for (IGOM_Account_Role_Detail__c station : stationToStatus.keySet()) {
			result.put(station.Id + ':' + station.Account_Role__r.Account__r.Name, stationToStatus.get(station));
		}
		return result;
	}

	/**
	 * @description	Method for the dashboard to retrieve information regarding the variation statuses in each chapter for a GAP Analysis.
	 * @param		gapAnalysisId <Id of the GAP Analysis>
	 * @return		Map<String, Map<String, Integer>> <A map with the igom chapters as key and both the variation status (of the GAP Analysis Items) and its appearances in a map as the value>
	 */    
	@AuraEnabled(cacheable=true)
	public static Map<String, Map<Object, Integer>> variationStatusPerChapter(Id gapAnalysisId) {
		return getFieldCountPerChapter(gapAnalysisId, 'Status__c');
	}

	/**
	 * @description	Method for the dashboard to retrieve information regarding the validity in each chapter for a GAP Analysis.
	 * @param		gapAnalysisId <Id of the GAP Analysis>
	 * @return		Map<String, Map<String, Integer>> <A map with the igom chapters as key and both the validity (of the GAP Analysis Items) and its appearances in a map as the value>
	 */    
	@AuraEnabled(cacheable=true)
	public static Map<String, Map<Object, Integer>> itemStatusPerChapter(Id gapAnalysisId) {
		return getFieldCountPerChapter(gapAnalysisId, 'Is_Reviewed__c');
	}

	/**
	 * @description	Auxiliar method to count the values of a field in a GAP Analysis' items, grouped by chapter.
	 * @param		gapAnalysisId <Id of the GAP Analysis>
	 * @param		fieldName <Name of the field to count>
	 * @return		Map<String, Map<String, Integer>> <A map with the igom chapters as key and both the field value and the count of it in a map as the value>
	 */ 
	public static Map<String, Map<Object, Integer>> getFieldCountPerChapter(Id gapAnalysisId, String fieldName) {
		// Permission check
		checkDashboardPermissionOnComplianceReview(gapAnalysisId);
		// Escape inputs
		fieldName = String.escapeSingleQuotes(fieldName);
		gapAnalysisId = (Id)(String.escapeSingleQuotes(gapAnalysisId));
		// Get the used manual id
		Id manualId = [SELECT Document__c FROM Compliance_Review__c WHERE Id = :gapAnalysisId LIMIT 1].Document__c;
		// Calculate procedure to chapter
		ProcedureToChapterResult prToChap = procedureToChapter(manualId);
		// Query the information for the report
		Map<Id, Map<Object, Integer>> chapterIdToFieldCount = new Map<Id, Map<Object, Integer>>();
		for (SObject queriedObject : 
			 Database.query('SELECT ' + fieldName + ', Standard_Document_Part__c FROM Compliance_Review_Part__c WHERE Compliance_Review__c = :gapAnalysisId')) 
		{
			Compliance_Review_Part__c procComp = (Compliance_Review_Part__c)queriedObject;
			Id chapterId = prToChap.procedureIdToChapterId.get(procComp.Standard_Document_Part__c);
			Map<Object, Integer> fieldCount = chapterIdToFieldCount.get(chapterId);
			if (fieldCount == null) {
				fieldCount = new Map<Object, Integer>();
				chapterIdToFieldCount.put(chapterId, fieldCount);
			}
			Integer precount = fieldCount.get(queriedObject.get(fieldName));
			fieldCount.put(
				queriedObject.get(fieldName), 
				precount == null ? 1 : precount+1
			);
		}
		// Change the chapter Id for the names
		Map<String, Map<Object, Integer>> chapterToVarionStatusCount = new Map<String, Map<Object, Integer>>();
		for (Id chapterId : chapterIdToFieldCount.keySet()) {
			chapterToVarionStatusCount.put(
				prToChap.chapterIdToName.containsKey(chapterId) ? prToChap.chapterIdToName.get(chapterId) : chapterId, 
				chapterIdToFieldCount.get(chapterId)
			);
		}
		return chapterToVarionStatusCount;
	}

	/**
	 * @description	Auxiliar method to get the user's visible station ids in the dashboard.
	 * @return		List<Id> <A map with the igom chapters as key and both the field value and the count of it in a map as the value>
	 */ 
	private static List<Id> getViewableStations() {
		List<Id> stationIds;
		if (IGOMPermissions.hasPermission(IGOMConstants.PERMISSIONS.VIEW_ALL_DASHBOARD)) {
			stationIds = new List<Id>();
			for (IGOM_Account_Role_Detail__c station : [SELECT Id FROM IGOM_Account_Role_Detail__c]) {
				stationIds.add(station.Id);
			}
		} else if (IGOMPermissions.hasPermission(IGOMConstants.PERMISSIONS.VIEW_OWN_DASHBOARD)) {
			stationIds = IGOMPermissions.stationsWithPermission(IGOMConstants.PERMISSIONS.VIEW_OWN_DASHBOARD);
		} else {
			throw new AuraHandledException(String.format(IGOMConstants.ERRORS.REQUIRED_PERMISSIONS_MISSING_ERROR, new List<Object>{'use the Dashboard Data Service'}));
		}
		return stationIds;
	}

	/**
	 * @description	Auxiliar method that checks that a user has dashboard permission for a compliance review, throwing an exception if not.
	 * @param		complianceReviewId <Id of the GAP Analysis>
	 */ 
	private static void checkDashboardPermissionOnComplianceReview(Id complianceReviewId) {
		Compliance_Review__c complianceReview = [SELECT Station__c FROM Compliance_Review__c WHERE Id = :complianceReviewId];
		IGOM_Account_Role_Detail__c station = [SELECT Id FROM IGOM_Account_Role_Detail__c WHERE Account_Role__c = :complianceReview.Station__c];
		if (!IGOMPermissions.hasPermission(station.Id, IGOMConstants.PERMISSIONS.VIEW_OWN_VARIATIONS) &&
			!IGOMPermissions.hasPermission(IGOMConstants.PERMISSIONS.VIEW_ALL_VARIATIONS)) {
			throw new AuraHandledException(String.format(IGOMConstants.ERRORS.REQUIRED_PERMISSIONS_MISSING_ERROR, new List<Object>{'view variations for this station'}));
		}
	}
}