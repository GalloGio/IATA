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
		
		for (Integer i=0;i<con.size();i++){
			String community = owners.get(usercontacts.get(con[i].id));
			system.debug('@@@community: ' + community);
			con[i].User_Portal_Status__c = ISSP_Constant.NEW_CONTACT_STATUS;
			if (community == 'ISSP') {
				con[i].community__c = 'ISS Customer Portal';
				system.debug('@@@con[i].community__c: ' + con[i].community__c); 
				//selectedCustomerType == GeneralPublic || isNotIATA || newAirline
				//isnotIATA not used anymore, newAirline means that it is new account-> in a mass update it means that it had not been enabled as partner
				system.debug('@@@con[i].ID_Cards__r.isEmpty: ' + con[i].ID_Cards__r.isEmpty());
				system.debug('@@@con[i].account.Sector__c: ' + con[i].account.Sector__c);
				system.debug('@@@con[i].account.ispartner: ' + con[i].account.ispartner);
				if (!con[i].ID_Cards__r.isEmpty() || con[i].account.Sector__c == 'General Public' || con[i].account.ispartner!=true) {   
	                con[i].User_Portal_Status__c = ISSP_Constant.APPROVED_CONTACT_STATUS;
	            }
	            system.debug('@@@con[i].User_Portal_Status__c: ' + con[i].account.ispartner);
			}
			
			else if (community == 'IEC') 
				con[i].community__c = 'E-Commerce';
				
			system.debug('@@@con[i].community__c: ' + con[i].community__c);
			
			
		}
		try {
			database.update(con);
		}
		catch (Exception e) {}
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}

    
}