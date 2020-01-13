public class ContactHandler{

	public static final set<String> PORTAL_STATUS = new set<String>{'Approved Admin','Approved User'};

	/**
		CODE BEFORE INSERT
	**/
	public static void beforeInsert( list<Contact> listNews) {
		populateNotificationTemplate(listNews, null);
		populateCanAllowPortalSelfReg(listNews);
		allowOnlyOneDistributionRiskLeaderForInsert(listNews);
	}

	/**
		CODE AFTER INSERT
	**/
	public static void afterInsert( list<Contact> listNews) {
		findParentAcountsToUpdate(listNews);
		ANG_ActivatePortalUsers.activate(listNews);
		grantAccessToPortalApps(listNews);
	}

	/**
		CODE BEFORE UPDATE
	**/
	public static void beforeUpdate( list<Contact> listNews, Map<Id,Contact> mapOlds) {
		populateNotificationTemplate(listNews, mapOlds);
		populateCanAllowPortalSelfReg(listNews);
		grantAccessToPortalAppsBefore(listNews,mapOlds);
		revokeAccessToPortalAppsBefore(listNews,mapOlds);
		allowOnlyOneDistributionRiskLeaderForUpdate(listNews,mapOlds);
	}

	/**
		CODE AFTER UPDATE
	**/
	public static void afterUpdate( list<Contact> listNews, list<Contact> listOlds) {
		findParentAcountsToUpdate(listNews, listOlds);
		ANG_ActivatePortalUsers.activate(listNews, listOlds);
		AccessToPortalAppsAfter(listNews);
	}

	/**
		CODE AFTER DELETE
	**/
	public static void afterDelete( list<Contact> listOlds) {
		findParentAcountsToUpdate(listOlds);
	}

	/**
		CODE AFTER UNDELETE
	**/
	public static void afterUndelete( list<Contact> listNews) {
		findParentAcountsToUpdate(listNews);
	}


	/**
		Get all related account Id and calls the method to update some dependent fields from child contacts
	**/
	public static void findParentAcountsToUpdate(list<Contact> listNews) {

		//if the iata code generation is running, the accounts were already updated
		if(ANG_OscarProcessHelper.isIATACodeGenerationRunning) return;

		list<Id> listAccountId = new list<Id>();
		for (Contact contact: listNews) {
			if (contact.AccountId != null && (contact.Financial_Assessment_Contact__c || contact.User_Portal_Status__c == 'Approved Admin')) {
				listAccountId.add(contact.AccountId);
			}
		}
		updateParentAccountFields(listAccountId);
	}

	/**
		Get some related account Ids, only when some fileds in current contact are being modified,
		and calls the method to update some dependent fields from child contacts
	**/
	public static void findParentAcountsToUpdate( list<Contact> listNews, list<Contact> listOlds) {

		//if the iata code generation is running, the accounts were already updated
		if(ANG_OscarProcessHelper.isIATACodeGenerationRunning) return;

		list<Id> listAccountId = new list<Id>();
		for (Integer i = 0; i<listNews.size(); i++) {
			Contact newContact = listNews[i];
			Contact oldContact = listOlds[i];
			if (newContact.AccountId != oldContact.AccountId) {
				if (newContact.AccountId!=null) {
					listAccountId.add(newContact.AccountId);
				}
				if (oldContact.AccountId!=null) {
					listAccountId.add(oldContact.AccountId);
				}
			} else if (newContact.AccountId!=null &&
					(  newContact.Financial_Assessment_Contact__c != oldContact.Financial_Assessment_Contact__c
					|| newContact.User_Portal_Status__c != oldContact.User_Portal_Status__c) ) {
				listAccountId.add(newContact.AccountId);
			}
		}
		updateParentAccountFields(listAccountId);
	}

	/**
		Update some account fields which value depends on child contacts
	**/
	public static void updateParentAccountFields(list<Id> listAccountId) {
		list<Account> listAccount = [
			SELECT Id, Has_a_Financial_Assessment_Contact__c, Has_an_Administrator_User_Portal__c,
			(Select Financial_Assessment_Contact__c, User_Portal_Status__c from Contacts)
			FROM Account
			WHERE id in :listAccountId];

		list<Account> listAccountToUpdate = new list<Account>();
		for (Account account: listAccount) {
			// variable to mark if the account has been modified
			Boolean accountModified = false;

			//update field Has_a_Financial_Assessment_Contact__c
			Boolean value1 = calculeHasAFinancialAssessmentValue(account.Contacts);
			if ( account.Has_a_Financial_Assessment_Contact__c != value1 ) {
				account.Has_a_Financial_Assessment_Contact__c = value1;
				accountModified = true;
			}

			//update field Has_an_Administrator_User_Portal__c
			Boolean value2 = calculeHasAnAdminPortalUserValue(account.Contacts);
			if ( account.Has_an_Administrator_User_Portal__c != value2 ) {
				account.Has_an_Administrator_User_Portal__c = value2;
				accountModified = true;
			}
			//if the account has been modified then add it to the update list
			if (accountModified) {
				listAccountToUpdate.add(account);
			}
		}

		//update list if is not empty
		if (!listAccountToUpdate.isEmpty()) {
			Database.update(listAccountToUpdate, false);
		}
	}

	/**
		Returns true if at least one of the input contacts is a Financial Assessment Contact
	**/
	public static Boolean calculeHasAFinancialAssessmentValue(list<Contact> listContact) {
		for (Contact contact: listContact) {
			if (contact.Financial_Assessment_Contact__c) {
				return true;
			}
		}
		return false;
	}

	/**
		Returns true if at least one of the input contacts is Admin Portal
	**/
	public static Boolean calculeHasAnAdminPortalUserValue(list<Contact> listContact) {
		for (Contact contact: listContact) {
			if (contact.User_Portal_Status__c == 'Approved Admin') {
				return true;
			}
		}
		return false;
	}

	private static void populateNotificationTemplate(List<Contact> listNewContacts, Map<Id,Contact> mapOldContacts) {

		for(Contact con : listNewContacts) {

			if((con.User_Portal_Status__c != 'Approved Admin'
				&& con.User_Portal_Status__c != 'Approved User'
				&& con.User_Portal_Status__c != 'Pending Approval')
				|| (mapOldContacts != null
				&& con.User_Portal_Status__c == mapOldContacts.get(con.Id).User_Portal_Status__c
				&& con.RecordTypeId == mapOldContacts.get(con.Id).RecordTypeId
				&& con.CNS_Contact__c == mapOldContacts.get(con.Id).CNS_Contact__c)
				|| con.RecordTypeId != RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact'))
				continue;

			con.Notification_Template__c = con.CNS_Contact__c ? 'NT-0021' : 'NT-0033';

		}

	}

	private static void populateCanAllowPortalSelfReg(List<Contact> listNewContacts) {

		for(Contact con : listNewContacts) {

			if(con.Financial_Assessment_Contact__c)
				con.CanAllowPortalSelfReg = true;
		}

	}

	/**
		Check the configuration in Portal_Application_Settings__mdt and if required
		grants the access to portal application services
		only used in insert
	**/
	private static void grantAccessToPortalApps(list<Contact> listNews) {
		System.debug('___grantAccessToPortalApps listNews ' + listNews);

		// create new app rights for each new role
		list<Portal_Application_Right__c> listAppRight = new list<Portal_Application_Right__c>();
		for (Contact contactNew: listNews) {
			try{
				list<String> listAddServices = PortalApplicationSettingHelper.getGrantAppNamesByContact(contactNew,null);

				for (String serviceName: listAddServices) {
					Portal_Applications__c app = getAppByName(serviceName);
					System.debug('___grantAccessToPortalApps app ' + app);
					if (app!=null) {
						Portal_Application_Right__c appRight =  new Portal_Application_Right__c(
							Contact__c = contactNew.Id,
							Portal_Application__c = app.Id,
							Right__c = 'Access Granted');
						listAppRight.add(appRight);
					}
				}
			} catch (Exception e) {
				contactNew.addError(e.getMessage());
			}
		}
		// insert app rights
		System.debug('___grantAccessToPortalApps listAppRight ' + listAppRight);
		if (listAppRight.isEmpty()) return;
		if (listNews.size()==1 || System.isQueueable()) {
			Database.SaveResult result = Database.insert(listAppRight[0], false);
			System.debug('___grantAccessToPortalApps listAppRight ' + result.isSuccess());
			for (Database.Error error: result.getErrors()) {
				if ( error.getStatusCode() == StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION) {
					listNews[0].addError(error.getMessage());
				}
			}

		} else {
			System.enqueueJob(new AsyncDML_Util(listAppRight, AsyncDML_Util.DML_INSERT, false));
		}
	}

	/**
		Check the configuration in Portal_Application_Settings__mdt and if required
		grants the access to portal application services
		only used in update
	**/
	private static list<Portal_Application_Right__c> LIST_GRANT_APPS = new list<Portal_Application_Right__c>();
	private static void grantAccessToPortalAppsBefore(list<Contact> listNews, Map<Id,Contact> mapOlds) {
		System.debug('___grantAccessToPortalAppsBefore listNews ' + listNews);
		System.debug('___grantAccessToPortalAppsBefore mapOlds ' + mapOlds);

		map<Id,list<Portal_Application_Right__c>> mapContactRights = new map<Id,list<Portal_Application_Right__c>>();
		// create new app rights for each new role
		for (Contact contactNew: listNews) {
			try{
				Contact contactOld = mapOlds.get(contactNew.Id);
				list<String> listAddServices = PortalApplicationSettingHelper.getGrantAppNamesByContact(contactNew,contactOld);

				list<Portal_Application_Right__c> listAppRight = new list<Portal_Application_Right__c>();
				for (String serviceName: listAddServices) {
					Portal_Applications__c app = getAppByName(serviceName);
					System.debug('___grantAccessToPortalAppsBefore app ' + app);
					if (app!=null) {
						Portal_Application_Right__c appRight =  new Portal_Application_Right__c(
							Contact__c = contactNew.Id,
							Portal_Application__c = app.Id,
							Right__c = 'Access Granted');
						listAppRight.add(appRight);
					}
				}
				if (!listAppRight.isEmpty()) {
					mapContactRights.put(contactNew.Id, listAppRight);
					LIST_GRANT_APPS.addAll(listAppRight);
				}
			} catch (Exception e) {
				contactNew.addError(e.getMessage());
			}
		}

		// find exisiting app rights with Access Denied before inserting new records
		for (Contact contact: [ SELECT Id,
									(SELECT Id, Portal_Application__c
									FROM Portal_Application_Rights__r
									WHERE Right__c = 'Access Denied')
								FROM Contact
								WHERE Id IN :mapContactRights.keyset()] ) {
			for ( Portal_Application_Right__c rightOld: contact.Portal_Application_Rights__r) {
				for ( Portal_Application_Right__c rightNew: mapContactRights.get(contact.Id)) {
					if (rightOld.Portal_Application__c == rightNew.Portal_Application__c) {
						rightNew.Id = rightOld.Id; // upsert this record
					}
				}
			}
		}
	}

	/**
		Check the configuration in Portal_Application_Settings__mdt and if required
		revokes the access to portal application services
	**/
	private static list<Portal_Application_Right__c> LIST_REVOKE_APPS  = new list<Portal_Application_Right__c>();
	private static void revokeAccessToPortalAppsBefore(list<Contact> listNews, Map<Id,Contact> mapOlds) {
		System.debug('___revokeAccessToPortalAppsBefore listNews ' + listNews);

		list<Contact> listPortalContacts = new list<Contact>();
		for (Contact contactNew: listNews) {
			listPortalContacts.add(contactNew);
		}
		if (listPortalContacts.isEmpty()) return;

		map<Id,Contact> mapContactsRights = new map<Id,Contact>([
			SELECT Id,
				(SELECT Id, Application_Name__c
				FROM Portal_Application_Rights__r
				WHERE Right__c = 'Access Granted'
				)
			FROM Contact
			WHERE Id IN :listPortalContacts
		]);

		for (Contact contactNew: listPortalContacts) {
			Contact contactOld = mapOlds==null? null: mapOlds.get(contactNew.Id);
			set<String> setRevokeServicesNames = new set<String>(PortalApplicationSettingHelper.getRevokeAppNamesByContact(contactNew,contactOld));

			Contact contactRight = mapContactsRights.get(contactNew.Id);
			for (Portal_Application_Right__c right: contactRight.Portal_Application_Rights__r) {
				if (setRevokeServicesNames.contains(right.Application_Name__c)) {
					right.Right__c = 'Access Denied';
					LIST_REVOKE_APPS.add(right);
				}
			}
		}
	}

	/**
		make the upsert for LIST_GRANT_APPS and LIST_REVOKE_APPS in the after trigger
	 */
	private static void accessToPortalAppsAfter(list<Contact> listNews) {
		list<Portal_Application_Right__c> listRights = new list<Portal_Application_Right__c>();
		listRights.addAll(LIST_GRANT_APPS);
		listRights.addAll(LIST_REVOKE_APPS);
		LIST_GRANT_APPS = new list<Portal_Application_Right__c>();
		LIST_REVOKE_APPS = new list<Portal_Application_Right__c>();
		System.debug('___accessToPortalAppsAfter listRights ' + listRights);
		if (listRights.isEmpty()) return;
		if (listNews.size()==1 || System.isQueueable()) {
			Database.UpsertResult result = Database.upsert(listRights[0], false);
			System.debug('___accessToPortalAppsAfter listAppRight ' + result);
			for (Database.Error error: result.getErrors()) {
				if ( error.getStatusCode() == StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION) {
					listNews[0].addError(error.getMessage());
				}
			}
		} else {
			System.enqueueJob(new AsyncDML_Util(listRights, AsyncDML_Util.DML_UPSERT, false));
		}
	}

	/**
		Find the Portal Application records by its name
	**/
	public static map<String,Portal_Applications__c> MAP_APPS;
	public static Portal_Applications__c getAppByName(String appname) {
		if (MAP_APPS==null) {
			MAP_APPS = new map<String,Portal_Applications__c>();
			for (Portal_Applications__c app: [SELECT Id, Name FROM Portal_Applications__c]) {
				MAP_APPS.put(app.Name, app);
			}
		}
		Portal_Applications__c app = MAP_APPS.get(appname);
		return app;
	}

	public static void allowOnlyOneDistributionRiskLeaderForInsert(list<Contact> listNews) {
		list<Contact> listContact = new list<Contact>();
		for(Contact contact: listNews) {
			if(contact.Airline_Credit_Risk_Manager__c) {
				listContact.add(contact);
			}
		}
		allowOnlyOneDistributionRiskLeader(listContact);
	}

	public static void allowOnlyOneDistributionRiskLeaderForUpdate(list<Contact> listNews, Map<Id,Contact> mapOlds) {
		list<Contact> listContact = new list<Contact>();
		for(Contact newContact: listNews) {
			Contact oldContact = mapOlds.get(newContact.Id);
			if(newContact.Airline_Credit_Risk_Manager__c && !oldContact.Airline_Credit_Risk_Manager__c) {
				listContact.add(newContact);
			}
		}
		allowOnlyOneDistributionRiskLeader(listContact);
	}

	public static void allowOnlyOneDistributionRiskLeader(list<Contact> listContact) {
		// order input contacts in a map by parent account
		map<Id,list<Contact>> mapAccountDRLs = new map<Id,list<Contact>>();
		for(Contact contact: listContact) {
			list<Contact> contacts = mapAccountDRLs.get(contact.AccountId);
			if (contacts == null) {
				contacts = new list<Contact>();
			}
			contacts.add(contact);
			mapAccountDRLs.put(contact.AccountId, contacts);
		}

		//if there are duplicates among the incoming contacts then throw an error
		for (Id accountId: mapAccountDRLs.keyset()) {
			list<Contact> listDRLs = mapAccountDRLs.get(accountId);
			if (listDRLs.size()>1) {
				for (Contact contact: listDRLs) {
					contact.addError('Only allowed one Distribution Risk Leader per Account');
				}
				mapAccountDRLs.remove(accountId);
			}
		}

		//if there are duplicates among the contacts in the database then throw an error
		for (Account account: [ SELECT Id,
								(SELECT Id FROM Contacts WHERE Airline_Credit_Risk_Manager__c = true)
								FROM Account
								WHERE Id IN :mapAccountDRLs.keyset()]) {
			if (account.contacts.size() > 0) {
				for (Contact contact: mapAccountDRLs.get(account.Id)) {
					contact.addError('Only allowed one Distribution Risk Leader per Account');
				}
			}
		}
	}

}
