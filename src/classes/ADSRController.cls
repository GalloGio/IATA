public without sharing class ADSRController {
	
	@AuraEnabled(cacheable=true)
	public static List<PicklistWrapper> getRegions() {
		List<PicklistWrapper> result = new List<PicklistWrapper>();
		
		User currentUser = [SELECT Contact.Account.Region_formula__c
							FROM User
							WHERE Id = :UserInfo.getUserId()
							LIMIT 1];
		
		for (Schema.PicklistEntry region : Utility.getPicklistEntries('IATA_ISO_Country__c', 'Region__c')) {
			PicklistWrapper item = new PicklistWrapper();
			item.value = region.getValue();
			item.label = region.getLabel();
			item.selected = region.getValue() == currentUser.Contact.Account.Region_formula__c;
			result.add(item);
		}
		
		return result;
	}
	
	@AuraEnabled(cacheable=true)
	public static List<PicklistWrapper> getMarkets(String region) {
		List<PicklistWrapper> result = new List<PicklistWrapper>();
		
		String query = 'SELECT Id, Name, Region__c, BSP__c, CASS_Export__c, CASS_Import__c FROM IATA_ISO_Country__c';
		query += ' WHERE (BSP__c = \'Yes\' OR CASS_Export__c = \'Yes\' OR CASS_Import__c = \'Yes\')';
		if (!String.isBlank(region)) {
			query += ' AND Region__c = :region';
		}
		query += ' ORDER BY Name ASC';
		
		for (IATA_ISO_Country__c market : (List<IATA_ISO_Country__c>) Database.query(query)) {
			PicklistWrapper item = new PicklistWrapper();
			item.value = market.Name;
			item.label = market.Name;
			
			String keyBSP = 'BSP_' + market.Region__c;
			String keyCASS = 'CASS_' + market.Region__c;
			
			if (market.BSP__c == 'Yes') {
				item.masterValue.add(keyBSP);
			}
			
			if (market.CASS_Import__c == 'Yes' || market.CASS_Import__c == 'Yes') {
				item.masterValue.add(keyCASS);
			}
			
			item.masterValue.add(market.Region__c);
			
			result.add(item);
		}
		
		return result;
	}
	
	@AuraEnabled(cacheable=false)
	public static ADSRService.SummaryReport getReport(String region, String service, String markets, String agent) {
		User u = [SELECT Id, Name, Contact.Account.Id, Contact.Account.Name, Contact.Account.IATACode__c, Contact.Account.Airline_Prefix__c
				  FROM User
				  WHERE Id = :UserInfo.getUserId()];
		
		ADSRService.SummaryReport report;
		try {
			ADSRService aDSRService = new ADSRService(u.Contact.Account, region, null, null, agent);
			report = aDSRService.getSummaryReport();
		} catch (ADSRExternalAPI.IRISException e) {
			String message;
			if (e.type == ADSRExternalAPI.IRIS_MISSING_PARAMETER) {
				message = 'You didn\'t select a region or you are not assotiated to a valid Airline account.';
			} else if (e.type == ADSRExternalAPI.IRIS_INVALID_OPERATION) {
				message = 'The region, the airline you are assotiated or the agent code provided could not be found or is invalid, or the operation is inactive.';
			} else {
				message = 'IRIS Internal Error: <br/>' + e.title + '<br/>Please try again later.';
			}
			throw new AuraHandledException(message);
		}
		
		return report;
	}
	
	public class PicklistWrapper {
		@AuraEnabled
		public String value;
		@AuraEnabled
		public String label;
		@AuraEnabled
		public Boolean selected;
		@AuraEnabled
		public List<String> masterValue;
		
		public PicklistWrapper() {
			this.masterValue = new List<String>();
		}
	}
	
}