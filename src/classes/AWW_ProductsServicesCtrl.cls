public with sharing class AWW_ProductsServicesCtrl {

	@AuraEnabled
	public static Response getProductsAndServices(Id accountId){
		Account acc = [SELECT Id, SAP_BW_report_with_sales_figures__c FROM Account WHERE Id = :accountId];
		Response result = new Response(acc);
		return result;
	}

	public class Response {
		@AuraEnabled public Boolean hasAccessToSAPFigures {get;set;}
		@AuraEnabled public String linkToSAPFigures {get;set;}
		@AuraEnabled public ServiceWrapper nonServices {get;set;}
		@AuraEnabled public ServiceWrapper services {get;set;}

		public Response(Account acc) {
			this.hasAccessToSAPFigures = Schema.SObjectType.Account.fields.SAP_BW_report_with_sales_figures__c.isAccessible() && String.isNotBlank(acc.SAP_BW_report_with_sales_figures__c);
			if(this.hasAccessToSAPFigures) {
				this.linkToSAPFigures = acc.SAP_BW_report_with_sales_figures__c;
			}
			initServices(acc.Id);
		}

		private void initServices(Id accountId) {
			List<Account_Service__c> publications = [
				SELECT Id,  Service__c, Service__r.Name, Service__r.Service_Publication__c, Active__c
				FROM Account_Service__c
				WHERE Account__c = :accountId AND Service__r.Service_Publication__c <> 'Services'
				ORDER BY Service__r.Service_Publication__c DESC, Service__r.Order__c ASC
			];
			this.nonServices = new ServiceWrapper('Publications', publications);

			List<Account_Service__c> services = [
				SELECT Id,  Service__c, Service__r.Name, Service__r.Service_Publication__c, Active__c
				FROM Account_Service__c
				WHERE Account__c = :accountId AND Service__r.Service_Publication__c = 'Services'
				ORDER BY Service__r.Order__c ASC
			];
			this.services = new ServiceWrapper('', services);
		}
	}

	public class ServiceWrapper {
		@AuraEnabled public String name {get;set;}
		@AuraEnabled public List<Account_Service__c> services {get;set;}

		public ServiceWrapper(String name, List<Account_Service__c> services) {
			this.name = name;
			this.services = services;
		}
	}

}
