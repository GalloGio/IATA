public with sharing class KeyCustomerAlertCtrl {


	@AuraEnabled
	public static KeyCustomerAlertInfo getKeyCustomerAlertInfo(Id caseId) {
		Case CaseDetail =  [SELECT id, Account.Identify_as_Key_Customer__c, RecordType.DeveloperName
							FROM Case 
							WHERE id = :caseId];      

		return new KeyCustomerAlertInfo(CaseDetail, Case_RTs_for_Key_Customer_alert__c.getall().values());
	}


	public class KeyCustomerAlertInfo {
		@AuraEnabled public Case CaseDetail {get;set;}
		@AuraEnabled public List<Case_RTs_for_Key_Customer_alert__c> developerNames {get;set;}

		public KeyCustomerAlertInfo(Case cc, List<Case_RTs_for_Key_Customer_alert__c> devNames) {
			this.CaseDetail = cc;
			this.developerNames = devNames;
		}
	}
}