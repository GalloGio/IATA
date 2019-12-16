trigger Training_Contact_Role_Details on Training_Contact_Role_Details__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
	//Trigger the platform events
	if(trigger.isAfter){
		//start
		PlatformEvents_Helper.publishEvents((trigger.isDelete?trigger.OldMap:Trigger.newMap), 'Training_Contact_Role_Detail__e', 'Training_Contact_Role_Details__c', trigger.isInsert, trigger.isUpdate, trigger.isDelete, trigger.isUndelete);
		//end
	}

}