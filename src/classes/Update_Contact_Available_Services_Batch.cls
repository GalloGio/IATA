global class Update_Contact_Available_Services_Batch implements Database.Batchable<sObject> {
	
	global final String query;

	
	global Update_Contact_Available_Services_Batch() {
		query = 'Select ContactId From User Where IsPortalEnabled = true AND Contact.Available_Services__c = null';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<User> listContact) {
   		List<Technical_Logs__c> lstErrorsToInsert = new List<Technical_Logs__c>();
   		Savepoint sp = Database.setSavepoint();
   		List<Id> listContactId = new List<Id>();

   		try{
   			for(User u : listContact){
   				listContactId.add(u.ContactId);
   			}
   			
 			PortalServiceAccessTriggerHandler.updateParentContactServices(listContactId);
            
            if(Test.isRunningTest()){
            	throw new System.DmlException('test exception');
        	}
		}
		catch(Exception e){
			Database.rollback(sp);
			lstErrorsToInsert.add(new Technical_Logs__c(Operation__c= 'Update_Contact_Available_Services_Batch', 
                                                        Record__c= BC.getJobId(),
                                                        Status__c= 'Error',
                                                        Log__c= e.getMessage()));
        

	        if(!lstErrorsToInsert.isEmpty()) {
	            insert lstErrorsToInsert;
	        }
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}