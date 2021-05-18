public  without sharing class LabRegistry_helper {
	public static final string labRegistryAccnRole = 'Lab Registry';

	@AuraEnabled(cacheable=true)
	public static list<Account> getAirlinesHQ(){
		list<Account> lsAirline = new list<Account>([select id, name, Airline_designator__c, AccountStatus__c, Site, IATA_ISO_Country__r.Name, IATA_ISO_Country__r.ISO_Code__c, Region__c, recordtypeId  from account where recordtype.developername = 'IATA_Airline' order by Name asc]);
		//return [select id, name, Airline_designator__c, AccountStatus__c, Site, IATA_ISO_Country__r.Name, IATA_ISO_Country__r.ISO_Code__c, Region__c, recordtypeId  from account where recordtype.developername = 'IATA_Airline' and ACLI_Status__c = 'Active Company' order by Name asc];
		return lsAirline;
	}

	@AuraEnabled
	public static boolean saveSurveyAnswers(LAB_Account_Role_Detail__c labRoleDetail
											, list<LAB_Account_Role_Detail__c> lsCountriesLab
											, list<LAB_Account_Role_Detail__c> lsAirlineAgreement){
		try {
			user currentUser = [select id, ContactId, Contact.AccountId from user where id =: UserInfo.getUserId()];
			
			//Create Account Role
			Account_Role__c accntRole = new Account_Role__c();
			accntRole.Account__c = currentUser.Contact.AccountId;
			accntRole.Functional_Role__c = LabRegistry_helper.labRegistryAccnRole;
			accntRole.recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Role__c', 'Master');
			insert accntRole;

			//Create Case
			Case theCase = new case();
			insert theCase;

			//Create Account Role Detail. Main answers
			labRoleDetail.onboarding_case__c = theCase.Id;
			switch on labRoleDetail.Lab_Type__c {
				when 'IT Integrator' {
				    labRoleDetail.recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('LAB_Account_Role_Detail__c', 'IT_Integrator');
				}	
				when 'Aggregator' {
					labRoleDetail.recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('LAB_Account_Role_Detail__c', 'Aggregator');
				}
				when 'Independent' {
					labRoleDetail.recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('LAB_Account_Role_Detail__c', 'Independent');
				}
				when 'Lab Network' {
					labRoleDetail.recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('LAB_Account_Role_Detail__c', 'Lab_Network');
				}
				when else {
					labRoleDetail.recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('LAB_Account_Role_Detail__c', 'Default');
				}
			}

			labRoleDetail.Account_Role__c = accntRole.Id;
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

			//Create Access Requested Portal Application Right
			Portal_Application_Right__c pac = new Portal_Application_Right__c();
			pac.recordtypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Portal_Application_Right__c', 'Application_rigth');
			pac.Contact__c = currentUser.ContactId;
			pac.Portal_Application__c = [select id from Portal_Applications__c where Functional_Role__c=:LabRegistry_helper.labRegistryAccnRole limit 1].Id;
			pac.Right__c = PortalServicesCtrl.PORTAL_ACCESS_REQUESTED;
			insert pac;

			return true;

			
		} catch (Exception e) {
			//return e.getMessage();
			return false;
		}
	}
}
