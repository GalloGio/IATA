public with sharing class AWW_AccountHeaderCtrl {

	@AuraEnabled
	public static Account getAccountHeader(Id accountId){
		return [SELECT Id, RecordTypeId, RecordType.Name, Name, Quality__c, Agency_Business_Model__c,
							IATA_ISO_Country__c, IATA_ISO_Country__r.Name, Top_Parent__c,
							Sector__c, Category__c, Account_Type__c, Logo_File_ID__c,
							Company_Logo__c, Legal_Name__c, AccountNumber, Region_formula__c,
							AM_Account_Manager__c, AM_Account_Manager__r.Name, AM_Account_Manager__r.PPD_Tittle__c,
							AM_Account_Manager__r.PPD_Office__c, AM_Account_Manager__r.Email, AM_Account_Manager__r.Phone,
							AM_Account_Manager__r.MobilePhone, BillingStreet, BillingCity, BillingState, BillingPostalCode,
							BillingCountry, Sub_Region__c, Website
					   FROM Account
					   WHERE Id = :accountId];
	}
}
