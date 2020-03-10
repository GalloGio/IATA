trigger Training_Contact_Role_Details on Training_Contact_Role_Details__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    //Trigger the platform events
    if(trigger.isAfter){
		
		// User userMuleIntg = [SELECT Id FROM USER WHERE Name = 'Mulesoft Integration' LIMIT 1];
        string userFirstName = UserInfo.getFirstName();
		string userLastName = UserInfo.getLastName();
		Boolean isMulesoft = (userFirstName == 'Mulesoft' && userLastName == 'Integration') ? true : false;
        
        for (Training_Contact_Role_Details__c tcrd : trigger.new) {
            // if((trigger.isInsert && tcrd.CreatedById != userMuleIntg.Id) || (trigger.isUpdate && tcrd.LastModifiedById != userMuleIntg.Id) ){
			if((trigger.isInsert && !isMulesoft) || (trigger.isUpdate && !isMulesoft) ){
                PlatformEvents_Helper.publishEvents((trigger.isDelete?trigger.OldMap:Trigger.newMap), 'Training_Contact_Role_Detail__e', 'Training_Contact_Role_Details__c', trigger.isInsert, trigger.isUpdate, trigger.isDelete, trigger.isUndelete);
            }       
        }
    }
}