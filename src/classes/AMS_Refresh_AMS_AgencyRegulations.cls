global class AMS_Refresh_AMS_AgencyRegulations implements Database.Batchable<sObject> {

	String query = 'SELECT Id FROM AMS_Agency_Regulation__c WHERE Expired__c = FALSE AND Expiry_Date__c < TODAY';

	global AMS_Refresh_AMS_AgencyRegulations() {

	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		try {
			update scope;
		} catch(Exception e) {
			System.debug(e);
		}
	}

	global void finish(Database.BatchableContext BC) {

	}

}
