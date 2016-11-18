public with sharing class AMP_ProductsController {
	public AMP_ProductsController() {

	}

	@AuraEnabled
	public static Boolean canViewSalesfigures() {
		Boolean canRead = false;
		if(Schema.SObjectType.Account.fields.SAP_BW_report_with_sales_figures__c.isAccessible()) canRead = true;
		return canRead;
	}
}
