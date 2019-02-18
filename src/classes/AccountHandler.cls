public class AccountHandler{

	/**
		CODE BEFORE INSERT
	
	**/
	public static void beforeInsert( list<Account> listNews){
		setIataMembershipStatus(listNews);
	}
	
	/**
		CODE AFTER INSERT
	**/
	public static void afterInsert( list<Account> listNews) {
		findParentAcountsToUpdate(listNews);
	}

	/**
		CODE AFTER UPDATE
	**/
	public static void afterUpdate( list<Account> listNews, list<Account> listOlds) {
		findParentAcountsToUpdate(listNews, listOlds);
		terminateMSOAppointments(listNews, (Map<Id, Account>) Trigger.oldMap);
	}

	/**
		CODE AFTER DELETE
	**/
	public static void afterDelete( list<Account> listOlds) {
		findParentAcountsToUpdate(listOlds);
	}

	/**
		CODE AFTER UNDELETE
	**/
	public static void afterUndelete( list<Account> listNews) {
		findParentAcountsToUpdate(listNews);
	}


	/**
		Get all related account Id and calls the method to update some dependent fields from accounts below the hirarchy
	**/
	public static void findParentAcountsToUpdate(list<Account> listNews) {
		list<Id> listAccountId = new list<Id>();
		for (Account account: listNews) {
			if (account.parentId!= null) {
				listAccountId.add(account.parentId);
			}
		}
		updateParentAccountFields(listAccountId);
	}

	/**
		Get some related account Ids, only when some fileds in current account are being modified,
		and calls the method to update some dependent fields from accounts below hirarchy
	**/
	public static void findParentAcountsToUpdate( list<Account> listNews, list<Account> listOlds) {
		list<Id> listAccountId = new list<Id>();
		for (Integer i = 0; i<listNews.size(); i++) {
			Account newAccount = listNews[i];
			Account oldAccount = listOlds[i];
			if (newAccount.parentId != oldAccount.parentId) {
				if (newAccount.parentId!=null) {
					listAccountId.add(newAccount.parentId);
				}
				if (oldAccount.parentId!=null) {
					listAccountId.add(oldAccount.parentId);
				}
			} else if (newAccount.ParentId != null &&
                    (  newAccount.Has_a_Financial_Assessment_Contact__c != oldAccount.Has_a_Financial_Assessment_Contact__c
					|| newAccount.Has_a_Financial_Assessment_Contact_Sum__c != oldAccount.Has_a_Financial_Assessment_Contact_Sum__c
					|| newAccount.Has_an_Administrator_User_Portal__c != oldAccount.Has_an_Administrator_User_Portal__c
					|| newAccount.Has_an_Administrator_User_Portal_Sum__c != oldAccount.Has_an_Administrator_User_Portal_Sum__c ) ) {
				listAccountId.add(newAccount.parentId);
			}
		}
		updateParentAccountFields(listAccountId);
	}

	/**
		Update some account fields which value depends on child contacts
	**/
	public static void updateParentAccountFields(list<Id> listAccountId) {
		if (listAccountId.isEmpty()) return;
		list<Account> listAccount = [
			SELECT Id, Has_a_Financial_Assessment_Contact_Sum__c, Has_an_Administrator_User_Portal_Sum__c,
			(Select Has_a_Financial_Assessment_Contact_Formu__c, Has_an_Administrator_User_Portal_Formula__c from childAccounts)
			FROM Account
			WHERE id in :listAccountId];

		list<Account> listAccountToUpdate = new list<Account>();
		for (Account account: listAccount) {
			// variable to mark if the account has been modified
			Boolean accountModified = false;

			//update field Has_a_Financial_Assessment_Contact_Sum__c
			Boolean value1 = calculeHasAFinancialAssessmentValue(account.childAccounts);
			if ( account.Has_a_Financial_Assessment_Contact_Sum__c != value1 ) {
				account.Has_a_Financial_Assessment_Contact_Sum__c = value1;
				accountModified = true;
			}
			//update field Has_an_Administrator_User_Portal_Sum__c
			Boolean value2 = calculeHasAnAdminPortalUserValue(account.childAccounts);
			if ( account.Has_an_Administrator_User_Portal_Sum__c != value2 ) {
				account.Has_an_Administrator_User_Portal_Sum__c = value2;
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
		Returns true if at least one of the input accounts has a Financial Assessment Contact
	**/
	private static Boolean calculeHasAFinancialAssessmentValue(list<Account> listAccount) {
		for (Account account: listAccount) {
			if (account.Has_a_Financial_Assessment_Contact_Formu__c) {
				return true;
			}
		}
		return false;
	}

	/**
		Returns true if at least one of the input accounts has an Admin Portal
	**/
	private static Boolean calculeHasAnAdminPortalUserValue(list<Account> listAccount) {
		for (Account account: listAccount) {
			if (account.Has_an_Administrator_User_Portal_Formula__c) {
				return true;
			}
		}
		return false;
	}
	
	/*** AMSU-128 Start ***/
	public static void terminateMSOAppointments(List<Account> listAccount, Map<Id, Account> oldMap) {


		Id airlineHQRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
		Id agencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
		
		if(airlineHQRT == null || agencyRT == null) {
			return;
		}
		List<Account> accountsToCheck = new List<Account>();
		for(Account acc : listAccount) {
			Account oldAcc = oldMap.get(acc.Id);
			if(!String.isBlank(oldAcc.Airline_designator__c) && String.isBlank(acc.Airline_designator__c) && acc.RecordTypeId == airlineHQRT) {
				accountsToCheck.add(acc);
			}
		}

		if(accountsToCheck.isEmpty()) {
			return;
		}

		List<AMS_Inspection__c> appointments = [SELECT Account__c, Airline__c, Accreditation_Endorsement_Status_code__c
												FROM AMS_Inspection__c
												WHERE Account__r.RecordTypeId = :agencyRT AND Account__r.Location_Class__c = 'M' AND Airline__c IN :accountsToCheck];

		//Set<Account> agenciesToUpdate = new Set<Account>();

		for(AMS_Inspection__c appointment : appointments) {
			appointment.Accreditation_Endorsement_Status_code__c = '0';
			//agenciesToUpdate.add(new Account(Id= appointment.Account__c, Status__c= 'Terminated', Reason__c= '0-Terminated'));
		}

		update appointments;

		//update new List<Account>(agenciesToUpdate);

	}
	/*** AMSU-128 End ***/
	
	
	public static void setIataMembershipStatus(list<Account> listAccount){
		if(!Test.isRunningTest()){
			for(Account acc : listAccount){
				acc.Membership_Status__c = 'Non-IATA Member';
			}
		}
	}
}
