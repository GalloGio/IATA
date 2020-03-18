public without sharing class GADM_ActorMembershipNotifier {

	private static final String GADM_NOTIFICATION_GROUP =  'GADM Internal Users Notification Group';

	public static String notifyUsers() {

		List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();

		List<NotifierWrapper> wrappers = getUsersToNotify();

		if(wrappers != null && wrappers.size() > 0) {

			EmailTemplate upcomingEmailTemplate = [SELECT Id, Name, Subject, Body FROM EmailTemplate WHERE DeveloperName =: 'Actor_Membership_Termination'];

			Id iataNoReplyId = null;
			OrgWideEmailAddress[] iataNoReply = [select Id from OrgWideEmailAddress where Address = 'noreply@iata.org'];
			if(iataNoReply != null && iataNoReply.size() > 0){
				iataNoReplyId = iataNoReply.get(0).Id;
			}

			String email = 'gadm@iata.org';
			List<GADM_Settings__mdt> settings = [SELECT IATA_Email_Contact__c FROM GADM_Settings__mdt WHERE DeveloperName = 'GADM'];
			if(settings != null && settings.size() > 0){
				email = settings[0].IATA_Email_Contact__c;
			}

			for(NotifierWrapper wrapper : wrappers) {
				Integer noOfDays = wrapper.priorDaysToNotify;
				Date effectiveFrom = wrapper.effectiveFrom;
				Date effectiveTo = wrapper.effectiveTo;
				String accountName= wrapper.accountName;
				List<Contact> contacts = wrapper.contacts;
				List<User> users = wrapper.users;

				if(contacts != null && contacts.size() > 0) {

					for(Contact con : contacts) {
						Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(upcomingEmailTemplate.Id, con.Id, null);
						String bodyHtml = mail.getHtmlBody();
						String replacedHtmlBody = bodyHtml.replace('*userName*', String.valueOf(con.FirstName + ' ' +con.LastName )).replace('*email*', email).replace('*actorName*', accountName).replace('*noOfdays*', String.valueOf(noOfDays));
						if(effectiveFrom != null) {
							replacedHtmlBody = replacedHtmlBody.replace('*effectiveFrom*', String.valueOf(effectiveFrom));
						}
						if(effectiveTo != null) {
							replacedHtmlBody = replacedHtmlBody.replace('*effectiveTo*', String.valueOf(effectiveTo));
						}
						mail.setHtmlBody(replacedHtmlBody);

						String bodyText = mail.getPlainTextBody();
						String replacedTextBody = bodyText.replace('*userName*', String.valueOf(con.FirstName + ' ' +con.LastName )).replace('*email*', email).replace('*actorName*', accountName).replace('*noOfdays*', String.valueOf(noOfDays));
						if(effectiveFrom != null) {
							replacedTextBody = replacedTextBody.replace('*effectiveFrom*', String.valueOf(effectiveFrom));
						}
						if(effectiveTo != null) {
							replacedTextBody = replacedTextBody.replace('*effectiveTo*', String.valueOf(effectiveTo));
						}
						mail.setPlainTextBody(replacedTextBody);
						mail.setToAddresses(new List<string>{
								con.Email
						});
						if(iataNoReplyId != null) {
							mail.setOrgWideEmailAddressId(iataNoReplyId);
						}
						mail.setSaveAsActivity(false);
						mail.setUseSignature(false);
						mail.setTreatTargetObjectAsRecipient(false);
						emailMessages.add(mail);

					}

				}

				if(users != null && users.size() > 0) {
					for(User u : users) {
						Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(upcomingEmailTemplate.Id, u.Id, null);
						String bodyHtml = mail.getHtmlBody();
						String replacedHtmlBody = bodyHtml.replace('*userName*', String.valueOf(u.FirstName + ' ' +u.LastName )).replace('*email*', email).replace('*actorName*', accountName).replace('*noOfdays*', String.valueOf(noOfDays));
						if(effectiveFrom != null) {
							replacedHtmlBody = replacedHtmlBody.replace('*effectiveFrom*', String.valueOf(effectiveFrom));
						}
						if(effectiveTo != null) {
							replacedHtmlBody = replacedHtmlBody.replace('*effectiveTo*', String.valueOf(effectiveTo));
						}
						mail.setHtmlBody(replacedHtmlBody);

						String bodyText = mail.getPlainTextBody();
						String replacedTextBody = bodyText.replace('*userName*', String.valueOf(u.FirstName + ' ' +u.LastName )).replace('*email*', email).replace('*actorName*', accountName).replace('*noOfdays*', String.valueOf(noOfDays));
						if(effectiveFrom != null) {
							replacedTextBody = replacedTextBody.replace('*effectiveFrom*', String.valueOf(effectiveFrom));
						}
						if(effectiveTo != null) {
							replacedTextBody = replacedTextBody.replace('*effectiveTo*', String.valueOf(effectiveTo));
						}
						mail.setPlainTextBody(replacedTextBody);
						mail.setToAddresses(new List<string>{
								u.Email
						});
						if(iataNoReplyId != null) {
							mail.setOrgWideEmailAddressId(iataNoReplyId);
						}
						mail.setSaveAsActivity(false);
						mail.setUseSignature(false);
						mail.setTreatTargetObjectAsRecipient(false);
						emailMessages.add(mail);
					}
				}


			}

		}

		try {

			Messaging.sendEmail(emailMessages, false);

			return 'sent';

		} catch (Exception e) {

			return e.getMessage();

		}

	}


	@TestVisible
	private static List<NotifierWrapper> getUsersToNotify() {

		List<NotifierWrapper> notificationWrappers = new List<NotifierWrapper>();

		List<GADM_Settings__mdt> gadmSettings = [SELECT Id, Actor_Membership_Termination__c FROM GADM_Settings__mdt WHERE DeveloperName = 'GADM' LIMIT 1];

		if (! gadmSettings.isEmpty()) {

			Integer priorDaysToNotify = 0;
			if (gadmSettings[0].Actor_Membership_Termination__c != null) {
				priorDaysToNotify = (Integer) gadmSettings[0].Actor_Membership_Termination__c;
			}

			Date today = Date.today();
			Date targetDate = today.addDays(priorDaysToNotify);

			//accounts that will be terminated
			List<Account_Role__c> accountRoles = [SELECT Id, Account__c, Account__r.Name, Effective_From_Date__c, Effective_To_Date__c FROM Account_Role__c WHERE Account_Roles__r.Name = 'GADM Participant' AND Status__c = 'Active' AND Effective_To_Date__c = :targetDate];
			if(! accountRoles.isEmpty()) {
				Map<Id, Account_Role__c> accountToGadmAccountRoleMap = new Map<Id, Account_Role__c>();
				for (Account_Role__c role : accountRoles) {
					accountToGadmAccountRoleMap.put(role.Account__c, role);
				}


				Id functionalRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Functional');

				List<Contact_Role_Service_Access__c> powerUserAccess = [
						SELECT Id, Contact_Role__r.Account_Role__r.Account__c, Contact__c
						FROM Contact_Role_Service_Access__c
						WHERE Status__c = 'Granted'
						AND Contact_Role__r.RecordTypeId = :functionalRecordTypeId
						AND Contact_Roles_Name__c = 'Service Power User'
						AND Service__r.Name = 'GADM'];

				Map<Id, List<Id>> accountToPowerUsersMap = new Map<Id, List<Id>>();
				for(Contact_Role_Service_Access__c access : powerUserAccess) {
					if(accountToPowerUsersMap.get(access.Contact_Role__r.Account_Role__r.Account__c) == null) {
						accountToPowerUsersMap.put(access.Contact_Role__r.Account_Role__r.Account__c, new List<String>{access.Contact__c});
					}else{
						accountToPowerUsersMap.get(access.Contact_Role__r.Account_Role__r.Account__c).add(access.Contact__c);
					}
				}


				List<Contact_Role_Service_Access__c> gadmUserAccess = [
						SELECT Id, Contact_Role__r.Account_Role__r.Account__c, Contact__c
						FROM Contact_Role_Service_Access__c
						WHERE Status__c = 'Granted'
						AND Contact_Role__r.RecordTypeId = :functionalRecordTypeId
						AND Contact_Roles_Name__c = 'GADM User'
						AND Service__r.Name = 'GADM'];

				Map<Id, List<Id>> accountToGadmUsersMap = new Map<Id, List<Id>>();
				for(Contact_Role_Service_Access__c access : gadmUserAccess) {
					if(accountToGadmUsersMap.get(access.Contact_Role__r.Account_Role__r.Account__c) == null) {
						accountToGadmUsersMap.put(access.Contact_Role__r.Account_Role__r.Account__c, new List<String>{access.Contact__c});
					}else{
						accountToGadmUsersMap.get(access.Contact_Role__r.Account_Role__r.Account__c).add(access.Contact__c);
					}
				}


				//active gadm users with active power user role
				Set<Id> gadmAndPowerUsers = new Set<Id>();
				for(Id accountId : accountToGadmUsersMap.keySet()) {
					if(accountToGadmUsersMap.get(accountId) == null) {continue;}
					if(accountToPowerUsersMap.get(accountId) == null) {continue;}
					List<Id> powerUsers = accountToPowerUsersMap.get(accountId);
					List<Id> gadmUser = accountToGadmUsersMap.get(accountId);
					for(Id powerUserId : powerUsers) {
						if(gadmUser.contains(powerUserId)) {
							gadmAndPowerUsers.add(powerUserId);
						}
					}
				}


				Map<Id, Contact> contactsMap = new Map<Id, Contact>([SELECT Id, FirstName, LastName, Email FROM Contact WHERE Id = :gadmAndPowerUsers]);

				Id groupRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Group');

				List<Account_Contact_Role__c> accountContactRoles = [SELECT Id, Contact__c, Account_Role__r.Account__c FROM Account_Contact_Role__c WHERE Contact__c = :gadmAndPowerUsers AND RecordTypeId = :groupRecordTypeId AND Contact_Roles__r.Name = 'GADM User' AND Service_Rendered__c =  'GADM' AND Account_Role__c = :accountRoles];

				Map<Id, List<Id>> visibleAccountToContactsMap = new Map<Id, List<Id>>();
				for(Account_Contact_Role__c contactRole : accountContactRoles) {
					if(visibleAccountToContactsMap.get(contactRole.Account_Role__r.Account__c) == null) {
						visibleAccountToContactsMap.put(contactRole.Account_Role__r.Account__c, new List<Id>{contactRole.Contact__c});
					}else{
						visibleAccountToContactsMap.get(contactRole.Account_Role__r.Account__c).add(contactRole.Contact__c);
					}
				}


				//create wrappers for contacts
				for(Id accountId : visibleAccountToContactsMap.keySet()) {
					if(accountToGadmAccountRoleMap.get(accountId) == null) {continue;}

					NotifierWrapper wrapper = new NotifierWrapper();
					wrapper.priorDaysToNotify = priorDaysToNotify;
					wrapper.effectiveFrom = accountToGadmAccountRoleMap.get(accountId).Effective_From_Date__c;
					wrapper.effectiveTo = accountToGadmAccountRoleMap.get(accountId).Effective_To_Date__c;
					wrapper.accountName = accountToGadmAccountRoleMap.get(accountId).Account__r.Name;
					wrapper.contacts = new List<Contact>();
					wrapper.users = new List<User>();

					List<Id> contactList = visibleAccountToContactsMap.get(accountId);
					for(Id contactId : contactList) {
						if(contactsMap.get(contactId) == null) {continue;}
						wrapper.contacts.add(contactsMap.get(contactId));
					}

					notificationWrappers.add(wrapper);
				}

				List<User> usersFromGroup = GADM_InternalUsersHandler.getUsersFromGroup(GADM_NOTIFICATION_GROUP);
				Map<Id, User> usersMap = new Map<Id, User>([SELECT Id, FirstName, LastName, Email FROM User WHERE Id = :usersFromGroup AND IsActive = true AND Contact.IsEmailBounced = false]);

				//create wrappers for users from public group
				for(Account_Role__c accountRole : accountRoles) {
					if(accountToGadmAccountRoleMap.get(accountRole.Account__c) == null) {continue;}

					NotifierWrapper wrapper = new NotifierWrapper();
					wrapper.priorDaysToNotify = priorDaysToNotify;
					wrapper.effectiveFrom = accountToGadmAccountRoleMap.get(accountRole.Account__c).Effective_From_Date__c;
					wrapper.effectiveTo = accountToGadmAccountRoleMap.get(accountRole.Account__c).Effective_To_Date__c;
					wrapper.accountName = accountToGadmAccountRoleMap.get(accountRole.Account__c).Account__r.Name;
					wrapper.contacts = new List<Contact>();
					wrapper.users = new List<User>();

					for(Id userId : usersMap.keySet()) {
						if(usersMap.get(userId) == null) {continue;}
						wrapper.users.add(usersMap.get(userId));
					}

					notificationWrappers.add(wrapper);
				}

			}


		}


		return notificationWrappers;
	}


	public class NotifierWrapper {
		public Integer priorDaysToNotify {get; set;}
		public Date effectiveFrom {get; set;}
		public Date effectiveTo {get; set;}
		public String accountName {get; set;}
		public List<Contact> contacts {get; set;}
		public List<User> users {get; set;}
	}





}
