public without sharing class Invite_User_CTRL {
	public static final string OID_USER_APP_STATUS_STARTED='Started';
	@AuraEnabled
	public static user getCurrenthUserInfo() {
		User oUser = [select id, UserType FROM User Where id = :userInfo.getUserId()];
		return oUser;
	}
	@AuraEnabled
	public static List<Account> getGadmActors() {
		List<Account> gadmActors = new List<Account>();

		List<Account_Roles__c> gadmParticipant = [SELECT Id FROM Account_Roles__c WHERE Name = 'GADM Participant' LIMIT 1];
		if (!gadmParticipant.isEmpty()) {
			Date today = System.today();

			List<Account_Role__c> accountRoles = [SELECT Id, Account__c FROM Account_Role__c WHERE Status__c = 'Active' AND Effective_From_Date__c <= :today AND Effective_To_Date__c >= :today AND Account_Roles__c = :gadmParticipant];
			if (!accountRoles.isEmpty()) {
				Set<Id> actorIds = new Set<Id>();
				for (Account_Role__c accountRole : accountRoles) {
					actorIds.add(accountRole.Account__c);
				}
				if (!actorIds.isEmpty()) {
					List<Account> gadmList = [SELECT Id, Name FROM Account WHERE Id = :actorIds];
					if (!gadmList.isEmpty()) {
						gadmActors = gadmList;
					}
				}
			}
		}

		return gadmActors;
	}

	@AuraEnabled
	public static Map<Id, List<String>> getActorsAllowedDomains(String actors) {
		Map<Id, List<String>> actorIdToDomainsMap = new Map<Id, List<String>>();

		if (String.isNotBlank(actors)) {

			List<Account> actorsList = null;

			try {
				actorsList = (List<Account>) JSON.deserialize(actors, List<Account>.class);
			} catch (JSONException e) {
				//JSON error
			}

			if (actorsList != null && !actorsList.isEmpty()) {

				Set<Id> actorIds = new Set<Id>();
				for (Account actor : actorsList) {
					actorIds.add(actor.Id);
				}

				List<GADM_Account_Service_Detail__c> serviceDetailsList = [SELECT Id, Allowed_email_domain__c, Account_Role_Service__r.Account_Role__r.Account__c FROM GADM_Account_Service_Detail__c WHERE Account_Role_Service__r.Account_Role__r.Account__c = :actorIds];

				for (GADM_Account_Service_Detail__c detail : serviceDetailsList) {
					if (detail.Allowed_email_domain__c != null) {
						List<String> domainsList = new List<String>();
						if(detail.Allowed_email_domain__c.indexOf(';') > -1) {
							List<String> tempList = detail.Allowed_email_domain__c.split(';');
							for(String domain : tempList) {
								domainsList.add(domain.trim());
							}
						}else{
							domainsList.add(detail.Allowed_email_domain__c);
						}

						actorIdToDomainsMap.put(detail.Account_Role_Service__r.Account_Role__r.Account__c, domainsList);

					} else {//nothing in Allowed_email_domain__c field
						actorIdToDomainsMap.put(detail.Account_Role_Service__r.Account_Role__r.Account__c, new List<String>());
					}
				}
			}

		}

		return actorIdToDomainsMap;
	}

	@AuraEnabled
	public static string sendInvitation(string contactStr, string invitationStr,boolean existingRolePowerUser, Id existingUserSelectedAccount) {
		Invitation__c invitation = null;
		system.debug('in');
		system.debug(contactStr);
		system.debug(invitationStr);
		system.debug(existingRolePowerUser);
		system.debug(existingUserSelectedAccount);
		Contact contact = null;
		try {
			contact = (Contact) JSON.deserialize(contactStr, Contact.Class);
		} catch (Exception ex) {
		}
		try {
			invitation = (Invitation__c) JSON.deserialize(invitationStr, Invitation__c.Class);

		} catch (Exception ex) {
		}

		try {
			if (contact == null && invitation != null) {
				insert invitation;
				invitation = [SELECT Id, Salutation__c, AccountId__c, Email__c, Last_Name__c, First_Name__c FROM Invitation__c WHERE Id =: invitation.Id];
				return sendEmail(true, invitation, null);
			} else if (contact != null) {
				requestServiceViaInvitation('GADM', existingRolePowerUser ? 'Power User' : 'User', contact.Id, existingUserSelectedAccount);
				return sendEmail(false, contact, existingUserSelectedAccount);
			}
			return invitationStr;
		} catch (Exception e) {
			return 'err:' + e.getMessage();
		}
	}



	private static void requestServiceViaInvitation (String connectedapp, String role, Id contactId, Id accountId) {
		Savepoint sp = null;
		List<Id> permissionsetToAssign = new List<Id>();
		Set<String> permissionsetToAssignNames = new Set<String>();
		List<One_Id_User_Applications__c> userAppsIn = new List<One_Id_User_Applications__c>();
		Id indentityUser = File_Upload_CTRL.getUserFromContact(contactId);

		try {
			sp = Database.setSavepoint();

			List<One_Id_App_Config_Detail__c> apps = getApp(connectedapp);

			if(!apps.isEmpty()) {

				for(One_Id_App_Config_Detail__c app : apps){

					if(connectedapp == 'GADM') {
						permissionsetToAssignNames.add(app.PermissionSet_SSO__c);
					}
				}
			}



			if (!permissionsetToAssignNames.isEmpty()) {
				List<PermissionSet> listPerm = [SELECT id FROM PermissionSet WHERE name = :permissionsetToAssignNames];
				for(PermissionSet pSet : listPerm){
					permissionsetToAssign.add(pSet.id);
				}

				if(!permissionsetToAssign.isEmpty()){
					if(connectedapp == 'GADM') {
						LightningConnectedAppHelper.massAssignPermissionSets(new List<Id> {indentityUser}, permissionsetToAssign);


						Account acc = [SELECT Id FROM Account WHERE Id = :accountId];
						Contact con = [SELECT Id FROM Contact WHERE Id = :contactId];
						Boolean isPowerUser = (role == 'Power User');

						Account_Role__c accountRole = OneId_RegistrationHelper_GADM.getAccountRole(accountId);
						OneId_RegistrationHelper_GADM.createContactRole(con, accountRole, isPowerUser);

					}
				}
			}
		}
		catch (Exception e) {
			Database.rollback(sp);
			system.debug('@@@Error: ' + e.getMessage());
		}
	}
	public static List<One_Id_App_Config_Detail__c> getApp(string bundleName){
		List<One_Id_Service_Provider_Config__c> temp = new List<One_Id_Service_Provider_Config__c>();
		List<One_Id_App_Config_Detail__c> toReturn = new List<One_Id_App_Config_Detail__c>();
		Map<String, One_Id_App_Config_Detail__c> mapOfApps = new Map<String, One_Id_App_Config_Detail__c>();

		if (String.isNotBlank(bundleName)) {

			Id recTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('One_Id_Service_Provider_Config__c', 'Service_Bundle');

			temp = [select id, Service_Provider_Name__c, Description__c, App_Picture_Url__c, License_Upgrade_Required__c, Profile_Id__c,
					Service_Bundle__r.Service_Provider_Name__c,
					(select id, Connected_App_Provisioning_Name__c, PermissionSet_Provisioning__c, PermissionSet_SSO__c, One_Id_Service_Provider_Config__r.id, One_Id_Service_Provider_Config__r.Service_Provider_Name__c,
					 One_Id_Service_Provider_Config__r.Service_Bundle__r.id, One_Id_Service_Provider_Config__r.Service_Bundle__r.Service_Provider_Name__c from One_Id_App_Config_Details__r)
					from One_Id_Service_Provider_Config__c where Is_Active__c = true and Service_Bundle__r.Is_Active__c = true
							and Service_Bundle__r.RecordTypeid = :recTypeId and Service_Bundle__r.Service_Provider_Name__c = :bundleName limit 500];


			if (!temp.isEmpty()) {

				for (One_Id_Service_Provider_Config__c sp : temp) {
					System.debug('sp ' + sp);
					for (One_Id_App_Config_Detail__c app : sp.One_Id_App_Config_Details__r) {
						System.debug('app ' + app);
						mapOfApps.put(app.Connected_App_Provisioning_Name__c, app);
					}

				}

				if (!mapOfApps.isEmpty()) toReturn.addAll(mapOfApps.values());
			}
		}

		return toReturn;

	}
	private static string sendEmail(boolean newUser, SObject obj, id existingUserInvitationAccountId) {

		string linkSuffix = '';
		string emailTemplate = '';
		string emailAddress = '';
		String userName = '';
		Id whatId = null;
		Id accountId = null;

		if (newUser) {
			emailTemplate = 'Invite_user_new';
			linkSuffix = '/login/SelfRegister?serviceName=GADM&token=' + obj.get('Id');
			Invitation__c invitation = (Invitation__c) obj;
			emailAddress = String.isBlank(invitation.Email__c) || invitation.Email__c.endsWithIgnoreCase('.inactive') ? '' : invitation.Email__c;
			whatId = invitation.Id;
			accountId = invitation.AccountId__c;


			if ((invitation.Last_Name__c != null && invitation.Last_Name__c != '') && (invitation.First_Name__c != null && invitation.First_Name__c != '')) {
				userName = invitation.First_Name__c + ' ' + invitation.Last_Name__c;
			} else if ((invitation.Salutation__c != null && invitation.Salutation__c != '') && (invitation.Last_Name__c != null && invitation.Last_Name__c != '')) {
				userName = invitation.Salutation__c + invitation.Last_Name__c;
			} else if (invitation.First_Name__c != null && invitation.First_Name__c != '') {
				userName = invitation.First_Name__c;
			} else {
				userName = 'User';
			}

		} else {
			emailTemplate = 'Invite_user_already_exists';
			linkSuffix = '/login/';
			Contact con = (Contact) obj;
			emailAddress = String.isBlank(con.Email) || con.Email.endsWithIgnoreCase('.inactive') ? '' : con.Email;
			whatId = con.Id;
			accountId = existingUserInvitationAccountId;
		}

		string accountName = '';

		if (accountId != null){
			List<Account> accs = [SELECT Id, Name FROM Account WHERE Id = :accountId];
			if(accs != null && accs.size() > 0){
				accountName = accs[0].Name;
			}
		}

		Id iataNoReplyId = null;
		OrgWideEmailAddress[] iataNoReply = [select Id from OrgWideEmailAddress where Address = 'noreply@iata.org'];
		if(iataNoReply != null && iataNoReply.size() > 0){
			iataNoReplyId = iataNoReply.get(0).Id;
		}

		EmailTemplate et = [SELECT Id, Name, Subject, Body FROM EmailTemplate WHERE DeveloperName = :emailTemplate];
		Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(et.Id, UserInfo.getUserId(), whatId);
		string link = OneIdUtils.getSiteCompleteUrl(OneIdUtils.Mode.IDENTITY) + linkSuffix;
		if(String.isNotBlank(emailAddress)) {
			mail.setToAddresses(new List<string>{
					emailAddress
			});
		}
		mail.setSaveAsActivity(false);
		if(iataNoReplyId != null) {
			mail.setOrgWideEmailAddressId(iataNoReplyId);
		}
		mail.setUseSignature(false);
		mail.setTreatTargetObjectAsRecipient(false);
		string body = mail.getHtmlBody();

		if(newUser) {
			mail.setHtmlBody(body.replace('*link*', link).replace('*userName*', userName).replace('*account*', accountName));
			mail.setPlainTextBody(body.replace('*link*', link).replace('*userName*', userName).replace('*account*', accountName));

		}else{
			mail.setHtmlBody(body.replace('*link*', link).replace('*account*', accountName));
			mail.setPlainTextBody(body.replace('*link*', link).replace('*account*', accountName));
		}

		List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
		allmsg.add(mail);

		try {
			Messaging.sendEmail(allmsg, false);
			return 'sent';
		} catch (Exception e) {
			return e.getMessage();
		}
	}
	@AuraEnabled
	public static List<Account> getUserAccounts() {

		List<Account> accountsToReturn = new List<Account>();

		Id userId = UserInfo.getUserId();
		List<Account> userAccounts = Contact_Roles_Helper.getUserAccounts(userId);

		if (userAccounts != null && userAccounts.size() > 0) {

			Date today = System.today();

			List<Account_Role__c> accountRoles = [SELECT Id, Account__c, Status__c, Effective_From_Date__c, Effective_To_Date__c FROM Account_Role__c WHERE Status__c = 'Active' AND (Effective_From_Date__c <= :today AND Effective_To_Date__c >= :today) AND Account__c = :userAccounts];
			if (!accountRoles.isEmpty()) {
				Set<Id> accountIds = new Set<Id>();

				for (Account_Role__c accountRole : accountRoles) {
					accountIds.add(accountRole.Account__c);
				}

				if (!accountIds.isEmpty()) {
					for (Account acc : userAccounts) {
						if (accountIds.contains(acc.Id)) {
							accountsToReturn.add(acc);
						}
					}
				}

			}

		}

		return accountsToReturn;
	}
	@AuraEnabled
	public static List<OneId_RegistrationProcessController.PicklistEntry> getContactJobFunctionValues() {
		return OneId_RegistrationProcessController.getContactJobFunctionValues();
	}
	@AuraEnabled
	public static Map<String, String> getContactLabels() {
		return OneId_RegistrationProcessController.getContactLabels();
	}
	@AuraEnabled
	public static UserInformationWrapper getUserInformationFromEmail(String email, String serviceName) {
		List<Contact> existingContacts = OneId_RegistrationProcessController.returnExistingContact(email);

		boolean emailAddressAvailable = OneId_RegistrationProcessController.checkIsUsernameIsAvailableInGlobalSalesforce(email, existingContacts);
		boolean contactExists = existingContacts.size() > 0;
		boolean contactOrUserExists = !emailAddressAvailable || contactExists;

		UserInformationWrapper wrapper = new UserInformationWrapper(
				contactExists ? existingContacts[0] : null, new Invitation__c(Email__c = email)
		);

		wrapper.showNotifyButton = !(!emailAddressAvailable && !contactExists);
		wrapper.createNewInvitation = !contactOrUserExists;
		if (emailAddressAvailable && contactExists) {
			Contact con = existingContacts[0];
			Account acc = [SELECT Id, Top_Parent__c FROM Account WHERE Id = :con.AccountId][0];
			Invitation__c invitation = new Invitation__c();
			invitation.AccountId__c = acc.Top_Parent__c != null ? acc.Top_Parent__c : con.AccountId;
			invitation.Business_Fax__c = con.Fax;
			invitation.Business_Phone__c = con.Phone;
			invitation.Email__c = con.Email;
			invitation.First_Name__c = con.FirstName;
			invitation.Last_Name__c = con.LastName;

			invitation.Job_Title__c = con.Title;
			invitation.Mobile_Phone__c = con.MobilePhone;
			invitation.Salutation__c = con.Salutation;
			wrapper.invitation = invitation;
			wrapper.contact = null;
		}

		if (!emailAddressAvailable && !contactExists) {
			//internal user
			wrapper.invitation = null;
			wrapper.contact = null;
		}

		return wrapper;
	}

	@AuraEnabled
	public static String findLocation(){

		String ipAddress = '92.104.157.175';

		if(!Test.isRunningTest()) {
			Map<String,String> currentSessionAttributes = Auth.SessionManagement.getCurrentSession();
			ipAddress = currentSessionAttributes.get('SourceIp');
		}

		HttpRequest req = new HttpRequest();
		req.setEndpoint('https://ipinfo.io/' + ipAddress + '/json?token=' + ISSP_CS__c.getInstance('ipinfo_token').Value__c);
		req.setMethod('GET');
		req.setTimeout(2000);
		HttpResponse res;

		try{
			res = new Http().send(req);
			Map<String, String> response = (Map<String, String>)JSON.deserialize(res.getBody(), Map<String, String>.class);
			return response.get('country');

		}catch(Exception e){
			System.debug('Exception findLocation Invite_User_CTRL...' + e);
			return e.getMessage();
		}
	}


	public class UserInformationWrapper{
		@AuraEnabled
		public boolean contactIsAlreadyInvited {get;set;}
		@AuraEnabled
		public boolean createNewInvitation{get;set;}
		@AuraEnabled
		public boolean showNotifyButton{get;set;}
		@AuraEnabled
		public Invitation__c invitation {get;set;}
		@AuraEnabled
		public Contact contact {get;set;}
		public UserInformationWrapper(Contact contact, Invitation__c invitation){
			if (contact != null){
				this.contactIsAlreadyInvited = OneId_RegistrationHelper_GADM.contactIsAlreadyInvited(contact.Id);
			}
			this.contact = contact;
			this.invitation = invitation;
		}
	}
}
