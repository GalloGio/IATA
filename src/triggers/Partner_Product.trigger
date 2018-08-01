trigger Partner_Product on Partner_products__c (after delete, after insert, after undelete,
    after update, before delete, before insert, before update){
	if (Trigger.isAfter) {
        //Publish the platform events
    	PlatformEvents_Helper.publishEvents((trigger.isDelete?trigger.OldMap:Trigger.newMap), 'PartnerProduct__e', 'Partner_products__c', trigger.isInsert, trigger.isUpdate, trigger.isDelete, trigger.isUndelete);
    }
    
    if(trigger.isBefore){
    	if(trigger.isInsert){
    		TIP_Utils.SyncAccountRoleOnProduct(trigger.new, null);
    	}
    	
    	if(trigger.isUpdate){
    		TIP_Utils.SyncAccountRoleOnProduct(trigger.new, trigger.oldMap);
    	}
    }
}