public with sharing class AccountDashboardCTIHeaderCtrl {

	@AuraEnabled
	public static Account getAccountHeader(Id accountId){
		return [SELECT Id, RecordTypeId, RecordType.Name, Name, IATACode__c, Location_Type__c, 
							IATA_ISO_Country__c, IATA_ISO_Country__r.Name, Top_Parent__c,
							Sector__c, Category__c, Account_Type__c, Logo_File_ID__c, Status__c,
							Company_Logo__c, Legal_Name__c, AccountNumber, Region_formula__c,
							Service_Model__c, Segmentation__c, Quality__c, Customer_Type__c
					   FROM Account
					   WHERE Id = :accountId];
	}
}
