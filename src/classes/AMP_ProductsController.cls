public with sharing class AMP_ProductsController {
	public Account acc {get; set;}
	public List<ServiceWrapper> lsServiceWrappers {get;set;}
	public List<ServiceWrapper> lsIndustryActivitiesWrappers {get;set;}

	public Boolean showNotApplicableMsg {get; set;}

	public AMP_ProductsController(ApexPages.StandardController stdController) {
		acc = (Account)stdController.getRecord();
		acc = [SELECT Id, Membership_status__c, SAP_BW_report_with_sales_figures__c, RecordType.DeveloperName, Sector__c FROM Account WHERE Id = :acc.Id];

		showNotApplicableMsg = (acc.RecordType.DeveloperName == 'IATA_Airline' && acc.Sector__c == 'Airline' && acc.Membership_status__c != 'IATA member');

		// Fill Non-SAP Products and Services List
		List<Account_Service__c> lsServices = getAccountServices(acc.Id);
		lsServiceWrappers = new List<ServiceWrapper>();
		Integer index = 0;
		for(Account_Service__c a : lsServices) {
			ServiceWrapper sw = new ServiceWrapper();
			sw.service = a;

			Integer rowspan = 1;
			for(Account_Service__c b : lsServices) {
				if(a.Id != b.Id) {
					if(a.Service__r.Service_Publication__c == b.Service__r.Service_Publication__c) {
						rowspan++;
					}
				}
			}
			if(index>0 && lsServices[index].Service__r.Service_Publication__c == lsServices[index-1].Service__r.Service_Publication__c) {
				rowspan = 0;
			}
			sw.rowspan = rowspan;
			lsServiceWrappers.add(sw);
			index++;
		}

		// Fill Industry Activities list
		List<Account_Service__c> lsIndustryActivities = getIndustryActivities(acc.Id);
		lsIndustryActivitiesWrappers = new List<ServiceWrapper>();
		index = 0;
		for(Account_Service__c a : lsIndustryActivities) {
			ServiceWrapper sw = new ServiceWrapper();
			sw.service = a;

			Integer rowspan = 1;
			for(Account_Service__c b : lsIndustryActivities) {
				if(a.Id != b.Id) {
					if(a.Service__r.Service_Publication__c == b.Service__r.Service_Publication__c) {
						rowspan++;
					}
				}
			}
			if(index>0 && lsIndustryActivities[index].Service__r.Service_Publication__c == lsIndustryActivities[index-1].Service__r.Service_Publication__c) {
				rowspan = 0;
			}
			sw.rowspan = rowspan;
			lsIndustryActivitiesWrappers.add(sw);
			index++;
		}
	}

	public class ServiceWrapper {
		public Account_Service__c service {get;set;}
		public Integer rowspan {get;set;}
	}

	@AuraEnabled
	public static Boolean canViewSalesfigures() {
		Boolean canRead = false;
		if(Schema.SObjectType.Account.fields.SAP_BW_report_with_sales_figures__c.isAccessible()) canRead = true;
		return canRead;
	}

	@AuraEnabled
	public Static List<Account_Service__c> getAccountServices(Id accountId) {
		return [SELECT Id,  Service__c, Service__r.Name, Service__r.Service_Publication__c, Active__c
		FROM Account_Service__c WHERE Account__c = :accountId and Service__r.Service_Publication__c <> 'Services'
		ORDER BY Service__r.Service_Publication__c DESC, Service__r.Order__c ASC];
	}

	@AuraEnabled
	public Static List<Account_Service__c> getIndustryActivities(Id accountId) {
		return [SELECT Id,  Service__c, Service__r.Name, Service__r.Service_Publication__c, Active__c
		FROM Account_Service__c WHERE Account__c = :accountId and Service__r.Service_Publication__c = 'Services'
		ORDER BY Service__r.Order__c ASC];
	}

	@AuraEnabled
	public static Boolean isIATAMember(Id accountId) {
		Account acc = [select Membership_status__c, RecordType.DeveloperName, Sector__c from Account where Id =: accountId];
		return (acc.RecordType.DeveloperName == 'IATA_Airline' && acc.Sector__c == 'Airline' && acc.Membership_status__c == 'IATA member');
	}

}
