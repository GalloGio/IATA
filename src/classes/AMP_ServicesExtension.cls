public with sharing class AMP_ServicesExtension {
	public AMP_ServicesExtension() {

	}

	@AuraEnabled
	public Static List<Account_Service__c> getAccountServices(Id accountId) {
		return [SELECT Id, Service__r.Name, Active__c FROM Account_Service__c WHERE Account__c = :accountId];
	}
}