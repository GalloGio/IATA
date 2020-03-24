trigger ContentVersionTrigger on ContentVersion (after insert, before insert) {

	/* After Insert */
	if(trigger.isInsert && trigger.isAfter) {
		ContentVersionTriggerHandler.afterInsertContentVersionTriggerHandler();
	}

	if(trigger.isInsert && trigger.isBefore) {
		// Salesforce is facing the issue with not populated default RT for Content Version object
		// this fix is to populate the GADM RT if no RT is assigned to newly added Content version record
		// RT is assigned only to users in GADM Internal Users Group
		// https://success.salesforce.com/issues_view?id=a1p3A0000008gIQQAY
		// Can be removed once issue is fixed
		List<ContentVersion> contentVersionWithNoRecordTypeAssigned = new List<ContentVersion>();
		for (ContentVersion cv: trigger.New){
			if(cv.RecordTypeId == null){
				contentVersionWithNoRecordTypeAssigned.add(cv);
			}
		}
		if (contentVersionWithNoRecordTypeAssigned.size() > 0) {
			GADM_FileSharing.assignGadmRecordType(contentVersionWithNoRecordTypeAssigned);
		}
	}
}
