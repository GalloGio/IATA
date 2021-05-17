public  without sharing class LabRegistry_helper {

	@AuraEnabled(cacheable=true)
	public static list<Account> getAirlinesHQ(){
		list<Account> lsAirline = new list<Account>([select id, name, Airline_designator__c, AccountStatus__c, Site, IATA_ISO_Country__r.Name, IATA_ISO_Country__r.ISO_Code__c, Region__c, recordtypeId  from account where recordtype.developername = 'IATA_Airline' order by Name asc]);
		//return [select id, name, Airline_designator__c, AccountStatus__c, Site, IATA_ISO_Country__r.Name, IATA_ISO_Country__r.ISO_Code__c, Region__c, recordtypeId  from account where recordtype.developername = 'IATA_Airline' and ACLI_Status__c = 'Active Company' order by Name asc];
		return lsAirline;
	}

	@AuraEnabled
	public static string saveSurveyAnswers(LAB_Account_Role_Detail__c labRoleDetail
											, list<LAB_Account_Role_Detail__c> lsCountriesLab
											, list<LAB_Account_Role_Detail__c> lsAirlineAgreement){
		try {

			Account_Role__c accntRole = new Account_Role__c();
			id AccntId = [Select contact.AccountId from User where id = :UserInfo.getUserId()].contact.AccountId;
			//Create Account Role
			accntRole.Account__c = AccntId;
			accntRole.recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Role__c', 'Master');
			insert accntRole;

			//Create Case
			Case theCase = new case();
			insert theCase;

			//Create Account Role Detail. Main answers
			labRoleDetail.recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('LAB_Account_Role_Detail__c', 'Default');
			insert labRoleDetail;

			//Create Account Role details. How many labs per country
			for(LAB_Account_Role_Detail__c countryLabs:lsCountriesLab){
				countryLabs.recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('LAB_Account_Role_Detail__c', 'Operating_Country');
				countryLabs.Parent_Detail_For_Country__c = labRoleDetail.Id;
			}

			insert lsCountriesLab;

			//Create Account Role details. Airline partnership
			for(LAB_Account_Role_Detail__c airlineAgreements:lsAirlineAgreement){
				airlineAgreements.recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('LAB_Account_Role_Detail__c', 'Airline_agreement');
				airlineAgreements.Parent_Detail_For_Airline__c = labRoleDetail.Id;
			}

			insert lsAirlineAgreement;

			return 'success';

			
		} catch (Exception e) {
			return e.getMessage();
		}
	}
}
