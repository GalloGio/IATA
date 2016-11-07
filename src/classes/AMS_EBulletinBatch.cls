global class AMS_EBulletinBatch implements Database.Batchable<sObject> {
	
	String query;
	
	global AMS_EBulletinBatch() {
	
		this.query = 'select id,Name from AMS_eBulletin_Profile__c';
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<AMS_eBulletin_Profile__c> scope) {
	
		for(AMS_eBulletin_Profile__c eBprof : scope){
		//run the eBulletinReport
		AMS_EBulletinReportWebservice.generateEBulletinReport( eBprof );
		
		}

	}
	
	global void finish(Database.BatchableContext BC) {
		
		//send notific
	}
	
}