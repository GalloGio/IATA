public with sharing class PortalInvitationController {
	@AuraEnabled(cacheable=true)
	public static Map<String, String> getAccountRoles() {
		Map<String, String> accountToRoles = new Map<String, String>();
		User user = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
		// RecordTypeSingleton.getInstance().getRecordTypeByName('E_and_F_Account_Role_Detail__c', 'ServiceAdmin');
		// RecordTypeInfo operatorRecInfo = Schema.E_and_F_Account_Role_Detail__c.getSObjectType().getDescribe().getRecordTypeInfosByName().get('Operator');
		/* List<Account_Role__c> accountRoles = [SELECT Id, Account_Name__c FROM Account_Role__c WHERE Id IN (
												SELECT Account_Role__c FROM E_and_F_Account_Role_Detail__c
												 WHERE E_and_F_Client_Services_Specialist__c =: user.ContactId AND RecordTypeId =: operatorRecInfo.getRecordTypeId()
											)]; */
		List<E_and_F_Account_Role_Detail__c> accountRoles = [
			SELECT Account_Role__c, Account_Role__r.Account_Name__c, Account_Role__r.Account__c FROM E_and_F_Account_Role_Detail__c WHERE ID IN(
				SELECT E_F_Account_Role_Detail__c FROM E_and_F_Contact_Role_Detail__c
				 WHERE RecordType.DeveloperName =: 'Service_Admin'/*  AND Contact_Role__r.Contact__c =: user.ContactId */
			)
		];
		for(E_and_F_Account_Role_Detail__c role : accountRoles) {
			accountToRoles.put(role.Account_Role__r.Account_Name__c, role.Account_Role__c+':'+role.Account_Role__r.Account__c);
		}
		return accountToRoles;
	}
	
	@AuraEnabled
	public static void sendEmail(String emailAddress) {
		EmailTemplate email = [SELECT Id FROM EmailTemplate WHERE DeveloperName = ''];
		User user = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
		
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setTemplateId(email.Id);
		mail.setToAddresses(new List<String>{emailAddress});
		mail.setSubject('Invitation');
		mail.setTargetObjectId(user.Id);
		mail.setWhatId(user.ContactId);
		mail.setSaveAsActivity(false);
		mail.setUseSignature(false);
		
		List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
		messages.add(mail);
		
			Messaging.sendEmail(messages, false);
	}
}