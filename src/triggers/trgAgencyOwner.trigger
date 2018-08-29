trigger trgAgencyOwner on Agency_Owner__c (before insert, before update) {

    if(!AMS_TriggerExecutionManager.checkExecution(Agency_Owner__c.getSObjectType(), 'trgAgencyOwner')) { return; }
    
	if (!IECConstants.GDPReplication_ProfileIDswithAccess.contains(UserInfo.getProfileId().substring(0, 15))){
	    for (Agency_Owner__c obj : trigger.new) {
	    	if (obj.AIMS_ID__c != null || obj.WebStar_ID__c != null)
	            obj.addError(Label.Cannot_Update_AIMS_values);
	    }
	}
}