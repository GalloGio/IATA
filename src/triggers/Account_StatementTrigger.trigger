trigger Account_StatementTrigger on Account_Statement__c (after update) {

    NewGenApp_AccountStatementTriggerHandler handler = new NewGenApp_AccountStatementTriggerHandler();
   	NewGenApp_Custom_Settings__c newgenCS = NewGenApp_Custom_Settings__c.getOrgDefaults();
    /* After Update */
    if(Trigger.isUpdate && Trigger.isAfter){
		if(newgenCS.Push_Notifications_State__c){
        	handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap);
    	}
    }

}