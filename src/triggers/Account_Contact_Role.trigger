trigger Account_Contact_Role on Account_Contact_Role__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    if(trigger.isBefore){
    	if(trigger.isInsert || trigger.isUpdate){
	    	for(Account_Contact_Role__c acr:trigger.new)
	    		acr.UniqueKey__c = TIP_Utils.AccountContactRoleGenerateUniquekey(acr);
    	}
    }
    
    //Trigger the platform events
    if(trigger.isAfter)
    	PlatformEvents_Helper.publishEvents((trigger.isDelete?trigger.OldMap:Trigger.newMap), 'AccountContactRole__e', 'Account_Contact_Role__c', trigger.isInsert, trigger.isUpdate, trigger.isDelete, trigger.isUndelete);
}