public with sharing class PortalInvitationController {
	@AuraEnabled(cacheable=true)
	public static Map<String, String> getAccountRoles() {
		Map<String, String> accountToRoles = new Map<String, String>();
		User user = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
		RecordTypeInfo operatorRecInfo = Schema.E_and_F_Account_Role_Detail__c.getSObjectType().getDescribe().getRecordTypeInfosByName().get('Operator');
		List<Account_Role__c> accountRoles = [SELECT Id, Account_Name__c FROM Account_Role__c WHERE Id IN (
												SELECT Account_Role__c FROM E_and_F_Account_Role_Detail__c
												 WHERE E_and_F_Client_Services_Specialist__c =: user.ContactId AND RecordTypeId =: operatorRecInfo.getRecordTypeId()
											)];
		for(Account_Role__c role : accountRoles) {
			accountToRoles.put(role.Account_Name__c, role.Id);
		}
		return accountToRoles;
	}
}