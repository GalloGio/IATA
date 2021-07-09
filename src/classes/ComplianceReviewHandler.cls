public with sharing class ComplianceReviewHandler {
	/**
	 * @description Do all the actions for the Compliance Review records in the After update trigger.
	 */
	public void afterUpdate(Map<Id, SObject> sobjectsOldMap, List<SObject> sobjectsNew){
		Map<Id, Compliance_Review__c> complianceReview_OldMap = (Map<Id, Compliance_Review__c>)sobjectsOldMap;
		Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Compliance_Review__c', IGOMConstants.COMPLIANCE_REVIEW.RECORD_TYPE.IGOM);
		// Generate a map of one Compliance Review record per station Id to set as latest published for the IGOM RT related records
		Map<Id, Compliance_Review__c> complianceReviewsToSetAsPublishedPerStationId = new Map<Id, Compliance_Review__c>();
		for (Compliance_Review__c complianceReview : (List<Compliance_Review__c>)sobjectsNew) {
			if(complianceReview.RecordTypeId == recordTypeId && complianceReview.Is_Latest_Published__c &&
			!((Compliance_Review__c)complianceReview_OldMap.get(complianceReview.Id)).Is_Latest_Published__c &&
			complianceReviewsToSetAsPublishedPerStationId.get(complianceReview.Station__c) == null){
				//Add compliance review only when the map does not contain a compliance review for the station
				complianceReviewsToSetAsPublishedPerStationId.put(complianceReview.Station__c, complianceReview);
			}
		}
		complianceReviewsToSetAsLatestPublished(complianceReviewsToSetAsPublishedPerStationId);
	}

	/**
	 * @description Update all the compliance reviews that were Latest Published but are not in the complianceReviewsPerStation map
	 *              for the active IGOM
	 *              Notes:
	 *                  - On GAP analysis publish the partial Gap analysis publishes will be inserts and the full gap analyses will be
	 *                    updates, that is why they will only be set to !Is_Latest_Published__c on the update.
	 *                  - On partial GAP analysis publishes, multiple gaps can have the Is_Latest_Published__c active.
	 * @param		complianceReviewsPerStation <Map containing all the latest publised compliance review for each station>
	 */
	public void complianceReviewsToSetAsLatestPublished(Map<Id, Compliance_Review__c> complianceReviewsPerStation){
		Set<Id> stationsInvolved = complianceReviewsPerStation.keySet();
		Set<Id> latestPublishedComplRev = new Set<Id>();
		for(Compliance_Review__c complianceReview : complianceReviewsPerStation.values()){
			latestPublishedComplRev.add(complianceReview.Id);
		}

		List<Compliance_Review__c> complianceReviewsNotLatestPublished = new List<Compliance_Review__c>();
		for(Compliance_Review__c complianceReview :[SELECT Id FROM Compliance_Review__c WHERE Document__r.Is_Active__c = true AND
													Is_Latest_Published__c = true AND Station__c IN :stationsInvolved AND
													Id NOT IN :latestPublishedComplRev]){
			complianceReview.Is_Latest_Published__c = false;
			complianceReviewsNotLatestPublished.add(complianceReview);
		}
		update complianceReviewsNotLatestPublished;
	}
}
