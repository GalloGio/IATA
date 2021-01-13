global class BtchEBCFixIdCardAgencyLink implements Database.Batchable<sObject> {
	public String query = 'Select Id, Agency_IATA_Code__c From ID_Card__c';

	global Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<ID_Card__c> scope){
		for(ID_Card__c ic : scope) {
			if (String.isBlank(ic.Agency_IATA_Code__c)) continue;

			ic.GDP_Products_Account_View__r = new GDP_Products_Account_View__c(IATA_Code__c = ic.Agency_IATA_Code__c);
		}

		update scope;
	}

	global void finish(Database.BatchableContext BC){
	}
}
