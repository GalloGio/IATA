trigger Account_Contact_Role on Account_Contact_Role__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
	if(trigger.isBefore){
		if(trigger.isInsert || trigger.isUpdate){

			Id tipRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Payment_Provider_Contact');
			for(Account_Contact_Role__c acr:trigger.new){
				if(acr.RecordTypeId == tipRT){
					acr.UniqueKey__c = TIP_Utils.AccountContactRoleGenerateUniquekey(acr);
				}
			}

			Account_Contact_Role_Helper.generateGadmUniqueKey(Trigger.new);
			Account_Contact_Role_Helper.checkForGadmUserRole(Trigger.new);
		}
	}
	
	//Trigger the platform events    
	if(trigger.isAfter){
		ShareObjectsToExternalUsers.shareObjectsByRoleOnAccountContactRoleChange(Trigger.new ,Trigger.oldMap);
		if((Limits.getLimitQueueableJobs() - Limits.getQueueableJobs()) > 0 && !System.isFuture() && !System.isBatch()) {
			System.enqueueJob(new PlatformEvents_Helper((trigger.isDelete?trigger.OldMap:Trigger.newMap), 'AccountContactRole__e', 'Account_Contact_Role__c', trigger.isInsert, trigger.isUpdate, trigger.isDelete, trigger.isUndelete));
		} else {
			PlatformEvents_Helper.publishEvents((trigger.isDelete?trigger.OldMap:Trigger.newMap), 'AccountContactRole__e', 'Account_Contact_Role__c', trigger.isInsert, trigger.isUpdate, trigger.isDelete, trigger.isUndelete);
		}
	}

	AccountContactRoleTriggerHandler handler = new AccountContactRoleTriggerHandler();
	if (Trigger.isInsert && Trigger.isAfter) {
		handler.OnAfterInsert(Trigger.new);
	}
	else if (Trigger.isUpdate && Trigger.isAfter) {
		handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap);
	}
	else if (Trigger.isDelete && Trigger.isBefore) {
		handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
	}
}