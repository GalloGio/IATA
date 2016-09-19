trigger EF_LocationCurrencyTrigger on EF_Location_Currency__c (
	before insert, 
	before update, 
	before delete, 
	after insert, 
	after update, 
	after delete, 
	after undelete) {

		if (Trigger.isBefore && Trigger.isInsert) {
			 
			// checks if location chosen has been set in Contract Location Currency.
	    	EF_LocationCurrencyHandler.manageNewLocationCurrency(Trigger.new, 'insert');
	    
        } else if(Trigger.isBefore && Trigger.isUpdate){ 
            EF_LocationCurrencyHandler.manageNewLocationCurrency(Trigger.new, 'update');
        }
        if (Trigger.isBefore) {    
	    	//Delete billing currency from contract
            EF_LocationCurrencyHandler.validateLocationCurrencyRemoval(Trigger.new, Trigger.oldMap);
            //EF_LocationCurrencyHandler.manageDeleteLocationCurrency(Trigger.old);
	     
		}



}