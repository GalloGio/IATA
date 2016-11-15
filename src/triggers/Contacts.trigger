trigger Contacts on Contact (after delete, after insert, after update, before delete, before insert, before update) {
    
    if (Trigger.isAfter) {
    	EF_ContactHandler.handleAfterUpdate();    	
    	if(Trigger.isUpdate){
    		//manage critical field notifications on after update
    		EF_ContactHandler.manageCriticalFieldChanges(trigger.new, trigger.oldMap);
    	}   	
    }    
    if (Utility.getNumericSetting('Stop Trigger:Contact') == 1) return;
    Contact_Dom.triggerHandler();

    
}