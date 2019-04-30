/*
	Class Name: Part_Online_App_ReqTrigger
	Related Classes: Part_Online_App_ReqTriggerHandler

	Copyright @Right IT Services

	Purpose: This trigger control before delete events on Participant_Online_App_Requirement__c object

	VERSION  	AUTHOR				DATE    		DETAIL/CHANGE REFERENCE
 	1.0		  	Joao Ferreira		2019-01-14  	INITIAL DEVELOPMENT
*/
trigger Part_Online_App_ReqTrigger on Participant_Online_App_Requirement__c (
	before delete, 
	after delete) {

	if (Trigger.isBefore) {
    	if (Trigger.isDelete) {
    		Part_Online_App_ReqTriggerHandler.handleBeforeDelete(Trigger.old);
    	}	    
	} 
	if (Trigger.isAfter) {
    	if (Trigger.isDelete) {
    		Part_Online_App_ReqTriggerHandler.handleAfterDelete(Trigger.old);
    	}	    
	} 
}