public class AMS_UpdateCertificateCampaign implements Database.Batchable<sObject> {

	Set<Id> accountIds;

	public AMS_UpdateCertificateCampaign(Set<Id> accountIds) {
		this.accountIds = accountIds;
	}

	public Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator('SELECT Id, Certificate_Generated_Current_Year__c FROM Account WHERE Id IN :accountIds AND Certificate_Generated_Current_Year__c = false');
	}

	 	public void execute(Database.BatchableContext BC, List<Account> scope) {
		for(Account acc : scope) acc.Certificate_Generated_Current_Year__c = true;

		update scope;
	}

	public void finish(Database.BatchableContext BC) {

	}

}
