trigger Contacts on Contact (after delete, after insert, after update, before delete, before insert, before update) {
    
    if (Trigger.isAfter) {
    	EF_ContactHandler.handleAfterUpdate();    	
    }    
    if (Utility.getNumericSetting('Stop Trigger:Contact') == 1) return;
    Contact_Dom.triggerHandler();

    
}