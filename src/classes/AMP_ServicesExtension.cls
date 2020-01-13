public with sharing class AMP_ServicesExtension {
	public AMP_ServicesExtension() {

	}

	@AuraEnabled
	public static Boolean canViewSalesfigures() {
		Boolean canRead = false;
		if(Schema.SObjectType.Account.fields.SAP_BW_report_with_sales_figures__c.isAccessible()) canRead = true;
		return canRead;
	}

	@AuraEnabled
	public Static List<Account_Service__c> getAccountServices(Id accountId) {
		return [SELECT Id, Service__r.Name, Active__c
		FROM Account_Service__c WHERE Account__c = :accountId
		ORDER BY Service__r.Order__c];
	}
}
