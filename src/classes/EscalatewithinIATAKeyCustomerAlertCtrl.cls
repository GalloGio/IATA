public with sharing class EscalatewithinIATAKeyCustomerAlertCtrl {

	@AuraEnabled
	public static Case getCaseInfo(Id caseId) {
		Case CaseDetail =  [SELECT id, Contact.Id, ContactId, Subject, BSPCountry__c, Region__c, Type_of_customer__c, 
									AccountId, CaseNumber, CaseArea__c, Reason1__c, Priority, Owner.Name
							FROM Case 
							WHERE id = :caseId];

		return CaseDetail;
	}
}