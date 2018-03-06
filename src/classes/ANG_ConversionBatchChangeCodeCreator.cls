global class ANG_ConversionBatchChangeCodeCreator implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
	
	String query;

	global Set<Id> accountIds;
	
	global ANG_ConversionBatchChangeCodeCreator(Set<Id> accountIdsIn) {

		accountIds = accountIdsIn;

		this.query = 'Select Id, (select Id, Name, Account__c,ANG_Account_Portal_Service__c,Agency__c,Agency_Applied_Change_code__c,RelationShip__c,Change_Code__c,ConfigurationID__c,Country_ISO_Code__c,IATACode__c,IATA_Regional_Office__c,Integration_System__c,Location_Type_Ordered__c,Sector__c,Status__c,Update_Type__c from AMS_Agency_Updates__r where Integration_System__c = \'Mulesoft\' ) from Agency_Applied_Change_code__c where Account__c in:accountIds and Active__c = true and Change_Code__c = \'COR\'';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		
		ANG_ConversionHelper.isMigrationTool=true;

		//Set<Account> accountsToAdd = new Set<Account>((List<Account>)scope);

		//ANG_ConversionHelper.createCorrectionChangeCodes(accountsToAdd);

		List<AMS_Agency_Updates__c> agencyUpdates = new List<AMS_Agency_Updates__c>();

		For(Agency_Applied_Change_code__c cc: (List<Agency_Applied_Change_code__c>) scope){
			if(!cc.AMS_Agency_Updates__r.isEmpty()){
				agencyUpdates.add(cc.AMS_Agency_Updates__r.get(0));
			}
		}

		if(!agencyUpdates.isEmpty())
			ANG_IEP_CalloutHelper.invokeCustomImpl(agencyUpdates);

	}
	
	global void finish(Database.BatchableContext BC) {
			
	}
	
}