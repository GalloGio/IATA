/*
*WARNING: This batch is only to run once, to clean the fake State data on addresses
*delete this batch after the process finished
*/

global class AMS_UpdateAccountState implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        /*return [select id, Primary_Address__r.State__c, Primary_Address__r.State__r.Name, Primary_Address__r.State__r.ISO_Code__c, Primary_Address__r.Country__r.AIMS_Area_Name__c,
        		Primary_Address__r.Country__r.ISO_Code__c, Account__c, Account__r.Id, Account__r.BillingState from AMS_Agency__c where Primary_Address__c <> null and Primary_Address__r.State__c <> null];*/
        return Database.getQueryLocator('select id, Primary_Address__r.State__c, Primary_Address__r.State__r.Name, Primary_Address__r.State__r.ISO_Code__c, Primary_Address__r.Country__r.AIMS_Area_Name__c, Primary_Address__r.Country__r.ISO_Code__c, Account__c, Account__r.Id, Account__r.BillingState from AMS_Agency__c where Primary_Address__c <> null and Primary_Address__r.State__c <> null and Primary_Address__r.Country__c <> null and Account__r.BillingState <> null');
    }

    global void execute(Database.BatchableContext BC, list<sObject> scope) {
    	AMS_Agency__c ag = null;
    	List<Account> listToUpdate = new List<Account>();
    	for(sObject s:scope){
    		ag = (AMS_Agency__c)s;
    		if(ag.Primary_Address__r.State__r.Name == ag.Primary_Address__r.Country__r.AIMS_Area_Name__c || ag.Primary_Address__r.State__r.Name == ag.Primary_Address__r.State__r.ISO_Code__c || ag.Primary_Address__r.State__r.Name == ag.Primary_Address__r.Country__r.ISO_Code__c){
    			ag.Account__r.BillingState = '';
    			listToUpdate.add(ag.Account__r);
    		}
    	}

    	if(listToUpdate.size() > 0)
    		update listToUpdate;
    }

    global void finish(Database.BatchableContext BC) {

    }
}