public  without sharing class LabRegistry_helper {

	@AuraEnabled(cacheable=true)
	public static list<Account> getAirlinesHQ(){
		list<Account> lsAirline = new list<Account>([select id, name, Airline_designator__c, AccountStatus__c, Site, IATA_ISO_Country__r.Name, IATA_ISO_Country__r.ISO_Code__c, Region__c, recordtypeId  from account where recordtype.developername = 'IATA_Airline' order by Name asc]);
		//return [select id, name, Airline_designator__c, AccountStatus__c, Site, IATA_ISO_Country__r.Name, IATA_ISO_Country__r.ISO_Code__c, Region__c, recordtypeId  from account where recordtype.developername = 'IATA_Airline' and ACLI_Status__c = 'Active Company' order by Name asc];
		return lsAirline;
	}

	@AuraEnabled
	public static string saveSurveyAnswers(){
		try {
			
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
		return null;
	}
}
