trigger trgAgencyOwner on Agency_Owner__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {

	if ( Trigger.isAfter ) {
		 if (Trigger.isInsert) {
            AgencyOwnerHandler.afterInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            AgencyOwnerHandler.afterUpdate(Trigger.new, Trigger.old);
        }
        if (Trigger.isDelete) {
            AgencyOwnerHandler.afterDelete(Trigger.old);
        }
        if (Trigger.isUndelete) {
            AgencyOwnerHandler.afterUndelete(Trigger.new);
        }
	}

	if(Trigger.isBefore){
		if(Trigger.isInsert || Trigger.isUpdate){
			if(!AMS_TriggerExecutionManager.checkExecution(Agency_Owner__c.getSObjectType(), 'trgAgencyOwner')) { return; }

			if (!IECConstants.GDPReplication_ProfileIDswithAccess.contains(UserInfo.getProfileId().substring(0, 15))){
				for (Agency_Owner__c obj : trigger.new) {
					if (obj.AIMS_ID__c != null || obj.WebStar_ID__c != null)
					obj.addError(Label.Cannot_Update_AIMS_values);
				}
			}
		}
	}


}