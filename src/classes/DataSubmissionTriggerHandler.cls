/**
 * Created by ppop on 6/19/2019.
 */

public with sharing class DataSubmissionTriggerHandler {
	public static void notifyExternalUsers(Map<Id, Data_Submission__c> oldValues, List<Data_Submission__c> newValues) {
		List<Data_Submission__c> dataSubmitionsChanged = new List<Data_Submission__c>();
		List<Id> accounts = new List<Id>();
		for (Data_Submission__c dsNew : newValues) {
			Data_Submission__c dsOld = oldValues.get(dsNew.Id);
			if (dsOld != null) {
				if (statusChanged(dsOld, dsNew)) {
					dataSubmitionsChanged.add(dsNew);
					accounts.add(dsNew.Account__c);
				}
			}
		}

		Map<Id, Set<Id>> dsWithContacts = getAllDataSubmittersAndSuperUsers(accounts, dataSubmitionsChanged);

		Set<Id> allContacts = new Set<Id>();
		for(Set<Id> ids: dsWithContacts.values()){
			for (Id cId: ids){
				allContacts.add(cId);
			}
		}

		Map<Id, Contact> contactsMap = new Map<Id, Contact>([SELECT Id, Email FROM Contact WHERE Id =: allContacts AND IsEmailBounced = false AND (NOT Email LIKE '%.inactive')]);

		List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
		for(Id dataSubm: dsWithContacts.keySet()){
			for (Id cId: dsWithContacts.get(dataSubm)){
				if(contactsMap.containsKey(cId))
					allmsg.add(createNotification(dataSubm, contactsMap.get(cId)));
			}
		}

		try {
			Messaging.sendEmail(allmsg, false);
		} catch (Exception e) {
			system.debug(e);
		}
	}

	private static Messaging.SingleEmailMessage createNotification(Id dataSubmission, Contact user) {
		string emailTemplateName = 'Data_submission_status_change';
		EmailTemplate et = [SELECT Id, Name, Subject, Body FROM EmailTemplate WHERE DeveloperName = :emailTemplateName];
		Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(et.Id, user.Id, dataSubmission);
		mail.setToAddresses(new List<string>{
				user.Email
		});
		mail.setSaveAsActivity(false);
		mail.setUseSignature(false);
		mail.setTreatTargetObjectAsRecipient(false);
		string body = mail.getHtmlBody();
		return mail;
	}

	private static boolean statusChanged(Data_Submission__c oldValue, Data_Submission__c newValue) {
		if (newValue.Status__c == 'File processed' || newValue.Status__c == 'Rejected' || newValue.Status__c == 'Accepted for Processing') {
			return (oldValue.Status__c != newValue.Status__c);
		}
		return false;
	}

	public static Map<Id, Set<Id>> getAllDataSubmittersAndSuperUsers(List<Id> allAccounts, List<Data_Submission__c> dataSubmissions) {

		Id groupRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Group');

		Set<Id> dataSubmitters = new Set<Id>();
		for (Data_Submission__c dsNew : dataSubmissions) {
			dataSubmitters.add(dsNew.Submitter__c);
		}
		if(dataSubmitters.isEmpty()){return new Map<Id, Set<Id>>();}

		Map<Id, User> usersWithContacts = new Map<Id, User>([SELECT Id, ContactId FROM User WHERE Id = :dataSubmitters]);
		Set<Id> originalDataSubmittersContacts  = new Set<Id>();
		for(User u : usersWithContacts.values()){
			originalDataSubmittersContacts.add(u.ContactId);
		}

		List<Account_Contact_Role__c> grantedAccounts = [
				SELECT Id, Contact__c, Contact_Roles__c, Account_Role__r.Account__c
				FROM Account_Contact_Role__c WHERE Account_Role__r.Account__c IN: allAccounts AND RecordTypeId =: groupRecordTypeId
		];

		Set<Id> contactsForBUs = new Set<Id>();
		for (Account_Contact_Role__c acr : grantedAccounts) {
			contactsForBUs.add(acr.Contact__c);
		}

		system.debug(allAccounts + ' ' + groupRecordTypeId);
		List<Contact_Role_Service_Access__c> businessUnits = [
				SELECT Id, Contact_Role__r.Contact__c, Contact_Role__r.Contact_Roles__c, Contact_Role__r.Account_Role__r.Account__c
				FROM Contact_Role_Service_Access__c
				WHERE Contact_Role__r.Contact__c = :contactsForBUs
				AND Contact_Role__r.RecordTypeId = :groupRecordTypeId
				AND Service__r.Name = 'GADM'
				AND Contact_Role__r.Contact_Roles__r.Category__c = 'Business Unit'
				AND Status__c = 'Granted'
		];

		Map<Id, Set<Id>> contactToAccount = new Map<Id, Set<Id>>();
		for (Account_Contact_Role__c acr : grantedAccounts) {
			Set<Id> accounts = contactToAccount.get(acr.Contact__c);
			if (accounts == null) {
				contactToAccount.put(acr.Contact__c, new Set<Id>{
						acr.Account_Role__r.Account__c
				});
			} else {
				accounts.add(acr.Account_Role__r.Account__c);
			}
		}

		Map<Id, Set<Id>> contactsToBU = new Map<Id, Set<Id>>();
		for (Contact_Role_Service_Access__c acr : businessUnits) {
			Set<Id> bus = contactsToBU.get(acr.Contact_Role__r.Contact__c);
			if (bus == null) {
				contactsToBU.put(acr.Contact_Role__r.Contact__c, new Set<Id>{
						acr.Contact_Role__r.Contact_Roles__c
				});
			} else {
				bus.add(acr.Contact_Role__r.Contact_Roles__c);
			}
		}

		Set<Id> contactIds = new Set<Id>();
		for (Account_Contact_Role__c acr : grantedAccounts) {
			contactIds.Add(acr.Contact__c);
		}

		List<Contact_Role_Service_Access__c> usersAccess = [
				SELECT Account__c, Contact__c, Email_Address__c, Contact_Roles_Name__c, Status__c
				FROM Contact_Role_Service_Access__c
				WHERE Contact__c IN :contactIds AND Status__c = 'Granted' AND
				(Contact_Roles_Name__c = 'GADM Data Submitter' OR Contact_Roles_Name__c = 'Service Super User' OR Contact_Roles_Name__c = 'GADM User')  AND Service__r.Name = 'GADM'
		];

		Map<Id, Set<Id>> submittersAndSuperUsers = new Map<Id, Set<Id>>();

		Set<Id> grantedContacts = new Set<Id>();
		for(Contact_Role_Service_Access__c access: usersAccess){
			if(access.Contact_Roles_Name__c == 'GADM User' && access.Status__c == 'Granted') {
				grantedContacts.add(access.Contact__c);
			}
		}

		Set<Id> activeDataSubmitters = new Set<Id>();
		for(Contact_Role_Service_Access__c access: usersAccess){
			if(access.Contact_Roles_Name__c != 'GADM Data Submitter' || access.Status__c != 'Granted') {continue;}
			if(!originalDataSubmittersContacts.contains(access.Contact__c)) {continue;}
			if(!grantedContacts.contains(access.Contact__c)) {continue;}
			activeDataSubmitters.add(access.Contact__c);
		}

		for (Id submId : activeDataSubmitters) {
			submittersAndSuperUsers.put(submId, new Set<Id>());
		}

		for (Contact_Role_Service_Access__c access : usersAccess) {
			if (access.Contact_Roles_Name__c != 'Service Super User' || access.Status__c != 'Granted') { continue; }
			if(!grantedContacts.contains(access.Contact__c)) {continue;}
			Set<Id> suAccounts = contactToAccount.get(access.Contact__c);
			Set<Id> suBu = contactsToBU.get(access.Contact__c);

			for (Id submId : activeDataSubmitters) {
				if (submId == null) { continue; }
				Set<Id> dsAccounts = contactToAccount.get(submId);
				Set<Id> dsBus = contactsToBU.get(submId);
				if (dsBus == null) { continue; }
				boolean breakAccountLoop = false;
				for (Id dsAcc : dsAccounts) {
					if (breakAccountLoop) { break; }
					if (suAccounts.contains(dsAcc)) {
						if (suBu == null) { continue; }
						for (Id dsBu : dsBus) {
							if (suBu.contains(dsBu)) {
								Set<Id> superUsers = submittersAndSuperUsers.get(submId);
								superUsers.add(access.Contact__c);
								breakAccountLoop = true;
								break;
							}
						}
					}
				}
			}
		}

		Map<Id, Set<Id>> accountAccess = new Map<Id, Set<Id>>();
		for(Id accountId: allAccounts){
			if (!accountAccess.keySet().contains(accountId)){
				for(Contact_Role_Service_Access__c access: usersAccess) {
					if(access.Contact_Roles_Name__c != 'Service Super User' || access.Status__c != 'Granted') {continue;}
					if(!grantedContacts.contains(access.Contact__c)) {continue;}
					Set<Id> accounts = contactToAccount.get(access.Contact__c);
					if(accounts != null && accounts.contains(accountId)){
						Set<Id> accessFromMap = accountAccess.get(accountId);
						if(accessFromMap == null){
							accountAccess.put(accountId, new Set<Id>{access.Contact__c});
						} else {
							accessFromMap.add(access.Contact__c);
						}
					}
				}
			}
		}

		Map<Id, Set<Id>> submissionWithNotifiedUsers = new Map<Id, Set<Id>>();
		for(Data_Submission__c dataSubmission: dataSubmissions){
			User dataSubmitterContact = usersWithContacts.get(dataSubmission.Submitter__c);

			if(dataSubmitterContact.ContactId != null && !activeDataSubmitters.contains(dataSubmitterContact.ContactId)){
				if(dataSubmission.Account__c != null){
					Set<Id> suToBenotified = accountAccess.get(dataSubmission.Account__c);
					if(suToBenotified != null){
						submissionWithNotifiedUsers.put(dataSubmission.Id, suToBenotified);
					}
				}
			}
			else if(dataSubmitterContact.ContactId != null && activeDataSubmitters.contains(dataSubmitterContact.ContactId)){
				Set<Id> users = new Set<Id>{dataSubmitterContact.ContactId};
				Set<Id> sUsers = submittersAndSuperUsers.get(dataSubmitterContact.ContactId);
				if(sUsers != null){
					for(Id contactId: sUsers){
						users.add(contactId);
					}
				}

				submissionWithNotifiedUsers.put(dataSubmission.Id, users);
			}
		}

		return submissionWithNotifiedUsers;
	}
}
