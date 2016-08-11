trigger EF_RelationshipTrigger on EF_Relationship__c (
	before insert, 
	before update, 
	before delete, 
	after insert, 
	after update, 
	after delete, 
	after undelete) {

		if (Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)) {
			// checks if location chosen has been set in Contract Location Currency.
	    	EF_RelationshipHandler.checkLocationCurrency(Trigger.new);
	    	EF_RelationshipHandler.checkCurrencyFromContract(Trigger.new, Trigger.oldMap);
	    
		} else if (Trigger.isAfter) {     
	    	//call handler.after method
	    
		}
}