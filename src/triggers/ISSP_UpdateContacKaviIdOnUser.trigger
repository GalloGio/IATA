trigger ISSP_UpdateContacKaviIdOnUser on Contact (after insert, after update) {

    //if(ISSP_ContactTriggerHandler.preventTrigger)
      //  return;
        
    if(trigger.isAfter && trigger.isInsert) 
       
    	for (Contact oneContact: Trigger.new){

    		//if Kaviuser Field has been modified launch the process of updating ContactKaviId field on User related record.
    			
				ISSP_ContactTriggerHandler.updateKaviIdOnUser(trigger.new);

    	}

    	if (trigger.isAfter && trigger.isUpdate)
       
    	for (Contact oneContact: Trigger.new){

    		//if Kaviuser Field has been modified launch the process of updating ContactKaviId field on User related record.
    		if (!((Trigger.oldMap.get(oneContact.id).Kavi_User__c) == (Trigger.newMap.get(oneContact.id).Kavi_User__c))){
				
				ISSP_ContactTriggerHandler.updateKaviIdOnUser(trigger.new);

				}
    	}
}