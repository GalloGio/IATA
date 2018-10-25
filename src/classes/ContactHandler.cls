public class ContactHandler{

	/**
		CODE AFTER INSERT
	**/
	public static void afterInsert( list<Contact> listNews) {
		findParentAcountsToUpdate(listNews);
		ANG_ActivatePortalUsers.activate(listNews);
	}

	/**
		CODE AFTER UPDATE
	**/
	public static void afterUpdate( list<Contact> listNews, list<Contact> listOlds) {
		findParentAcountsToUpdate(listNews, listOlds);
		ANG_ActivatePortalUsers.activate(listNews, listOlds);
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
		list<Id> listAccountId = new list<Id>();
		for (Contact contact: listNews) {
			if (contact.AccountId!= null) {
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

}
