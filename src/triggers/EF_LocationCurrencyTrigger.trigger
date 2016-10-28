trigger EF_LocationCurrencyTrigger on EF_Location_Currency__c (
	before insert, 
	before update, 
	before delete, 
	after insert, 
	after update, 
	after delete, 
	after undelete) {
        
        if (Trigger.isBefore)
        {
	    	if (Trigger.isInsert)
	    	{
				EF_LocationCurrencyHandler.handleWithApprovalInserts(Trigger.new);
				// checks if location chosen has been set in Contract Location Currency.
		    	EF_LocationCurrencyHandler.manageNewLocationCurrency(Trigger.new, 'insert');
        	}

	    	if(Trigger.isUpdate)
	    	{
	    		//Delete billing currency from contract
		    	EF_LocationCurrencyHandler.validateLocationCurrencyRemoval(Trigger.newMap, Trigger.oldMap);
	    		EF_LocationCurrencyHandler.handleWithApprovalUpdates(Trigger.newMap, Trigger.oldMap);
	            EF_LocationCurrencyHandler.handleApprovedAndRejectedApprovals(Trigger.new, Trigger.oldMap);
	    	}
		}

        
        else if(Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert))
        {
            if(Trigger.isUpdate)
	            EF_LocationCurrencyHandler.manageUpdateLocationCurrency();

            if(EF_LocationCurrencyHandler.runOnce() && EF_ContractHandler.isUserCsSpecialist())
	        {
				EF_LocationCurrencyHandler.startApprovalProcesses(Trigger.new);
	        }
        }
}