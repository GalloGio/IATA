//EM: Fill in User portal status and community at contact level if users are mass-inserted
global class HandleContactPortalFields implements Database.Batchable<sObject> {
	map <Id,String> owners = new map <Id,String>(); 
	map <Id,Id> usercontacts = new map <Id,Id>();
	
	//Constructor initialization
	global HandleContactPortalFields(Map<Id, String> us, Map <Id,Id> cid) {
		owners = us;
		usercontacts = cid;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) { 
		//EM: If single insertion (registration process) this query returns 0 results since contact portal status is already filled in
		return DataBase.getQueryLocator([SELECT Account.Sector__c, Account.isPartner, Community__c, User_IECPortal_Status__c, User_Portal_Status__c, (SELECT Id, Valid_To_Date__c FROM ID_Cards__r WHERE Is_Active_Card__c = true) FROM Contact WHERE Id IN : usercontacts.keySet() AND (User_Portal_Status__c = null OR Community__c = null)]);
	}	
	
	global void execute(Database.BatchableContext BC,List<Contact> con) {
		HandleContactPortalFields_Helper h = new HandleContactPortalFields_Helper();
		h.fillportalfields(con,owners,usercontacts);
				
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}

    
}