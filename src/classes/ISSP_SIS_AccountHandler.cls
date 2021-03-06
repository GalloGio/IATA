/**
	Account Trigger for SIS Integration
	Selects the accounts relevant for SIS and calls the external web services
	to create or update accounts
**/
public with sharing class ISSP_SIS_AccountHandler {

	public static final ID RT_AGENCY = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency') ;
	public static set<ID> ALLOWED_COUNTRIES = null;
	public static set<String> ALLOWED_LOCATIONS = null;
	public static set<String> ALLOWED_STATUS = ISSP_SIS_Account_Allowed_Status__c.getAll().keyset();

	public static Boolean BLOCK_EXECUTION = false;

	public static map<String,ISSP_SIS_Account_Status__c> MAP_SIS_ACCOUNT_STATUS = null;
	/**
		Get the map with the custom setting 'ISSP_SIS_Account_Status__c' or creates it if not initialized
	**/
	public static map<String,ISSP_SIS_Account_Status__c> getMapSISAccountStatus() {
		//initialize map only once
		if (MAP_SIS_ACCOUNT_STATUS == null) {
			MAP_SIS_ACCOUNT_STATUS = new map<String,ISSP_SIS_Account_Status__c>();
			for (ISSP_SIS_Account_Status__c setting: ISSP_SIS_Account_Status__c.getAll().values()) {
				list<String> listISOCode = setting.Country_ISO_Codes__c==null? new list<String>(): setting.Country_ISO_Codes__c.split(',');
				list<String> listLocations = setting.Location_Class__c==null? new list<String>(): setting.Location_Class__c.split(',');
				for (String countryISOCode: listISOCode) {
					for (String location: listLocations) {
						String key = RecordTypeSingleton.getInstance().getRecordTypeId('Account', setting.Recordtype__c) + ' ' + setting.Status__c + ' ' + location + ' ' + countryISOCode;
						MAP_SIS_ACCOUNT_STATUS.put(key, setting);
					}
				}
			}
		}
		return MAP_SIS_ACCOUNT_STATUS;
	}

	/**
		Get the set of all valid combinations of location class an location Type
		defined in the CS 'ISSP_SIS_Account_Allowed_Location__c'
	**/
	public static set<String> getAllowedLocations() {
		// initialize  the location set if it is the first time
		if (ALLOWED_LOCATIONS==null) {
			ALLOWED_LOCATIONS = new set<String>();
			for (ISSP_SIS_Account_Allowed_Location__c setting: ISSP_SIS_Account_Allowed_Location__c.getAll().values()) {
				for (String locationClass: setting.Location_Classes__c.split(',')) {
					for (String locationType: setting.Location_Types__c.split(',')) {
						ALLOWED_LOCATIONS.add(locationClass.trim() + ',' + locationType.trim());
					}
				}
			}
		}
		return ALLOWED_LOCATIONS;
	}

	/**
		BEFORE INSERT
	**/
	public static void beforeInsert(list<Account> listAccount) {
		if (BLOCK_EXECUTION) return;
		updateSISStatusFields(listAccount);
	}

	/**
		AFTER INSERT
	**/
	public static void afterInsert(list<Account> listAccount) {
		if (BLOCK_EXECUTION) return;
		if (!ISSP_WS_SIS_Callout_Common.SIS_CALLOUTS_ENABLED) return;
		list<Id> listInsertAccountId = new list<Id>();
		list<Id> listUpdateAccountId = new list<Id>();
		for (Account account: listAccount) {
			if (validSISAccount(account)
				&& ALLOWED_STATUS.contains(account.Status__c)) {
				if (String.isBlank(account.SIS_ID__c)) {
					listInsertAccountId.add(account.Id);
				} else {
					listUpdateAccountId.add(account.Id);
				}
			}
		}
		if (!listInsertAccountId.isEmpty()) {
			if(Test.isRunningTest()){
				ISSP_WS_Utilities.invokeCreateAccount(listInsertAccountId);
			}
			else{
				System.schedule('ScheduledJob ' + String.valueOf(Math.random()), ISSP_SIS_Schedulable.getNextFireTime(), new ISSP_SIS_Schedulable(listInsertAccountId, 'invokeCreateAccount'));
			}
			BLOCK_EXECUTION = true;
		}
		if (!listUpdateAccountId.isEmpty()) {
			if(Test.isRunningTest()){
				ISSP_WS_Utilities.invokeUpdateAccount(listUpdateAccountId);
			}
			else{
				System.schedule('ScheduledJob ' + String.valueOf(Math.random()), ISSP_SIS_Schedulable.getNextFireTime(), new ISSP_SIS_Schedulable(listUpdateAccountId, 'invokeUpdateAccount'));
			}
			BLOCK_EXECUTION = true;
		}
	}

	/**
		BEFORE UPDATE
	**/
	public static void beforeUpdate(map<Id,Account> mapNews, map<Id,Account> mapOlds) {
		if (BLOCK_EXECUTION) return;
		validateFieldAvailableSISManagement(mapNews, mapOlds);
		updateSISStatusFields(mapNews, mapOlds);

		if (!ISSP_WS_SIS_Callout_Common.SIS_CALLOUTS_ENABLED) return;
		list<Id> listInsertAccountId = new list<Id>();
		list<Id> listUpdateAccountId = new list<Id>();
		for (Account accountNew: mapNews.values()) {
			Account accountOld = mapOlds.get(accountNew.Id);
			if ( validSISAccount(accountNew) && isAccountModified(accountNew, accountOld)) {
				if (String.isBlank(accountNew.SIS_ID__c)) {
					listInsertAccountId.add(accountNew.Id);
				} else {
					listUpdateAccountId.add(accountNew.Id);
				}
				if (accountnew.Status__c == 'Terminated') {
					accountnew.SIS_Status__c = 'TERMINATED';
				}
				if (accountnew.Status__c == 'Approved') {
					accountnew.SIS_Status__c = 'Active';
				}
			}
		}
		if (!listInsertAccountId.isEmpty()) {
			if(Test.isRunningTest()){
				ISSP_WS_Utilities.invokeCreateAccount(listInsertAccountId);
			}
			else{
				System.schedule('ScheduledJob ' + String.valueOf(Math.random()), ISSP_SIS_Schedulable.getNextFireTime(), new ISSP_SIS_Schedulable(listInsertAccountId, 'invokeCreateAccount'));
			}
			BLOCK_EXECUTION = true;
		}
		if (!listUpdateAccountId.isEmpty()) {
			if(Test.isRunningTest()){
				ISSP_WS_Utilities.invokeUpdateAccount(listUpdateAccountId);
			}
			else{
				System.schedule('ScheduledJob ' + String.valueOf(Math.random()), ISSP_SIS_Schedulable.getNextFireTime(), new ISSP_SIS_Schedulable(listUpdateAccountId, 'invokeUpdateAccount'));
			}
			BLOCK_EXECUTION = true;
		}
	}

	/**
		Returns true only if the account is valid to be updated with SIS, Must be:
			- An AGENCY
			- Not terminated
			- to be a Validated Account
			- its country must be in the Custom setting 'ISSP SIS Account Allowed Countries'
	**/
	public static Boolean validSISAccount(Account account) {
		try {
			// if is null initialize list of allowed countries using the CS
			if (ALLOWED_COUNTRIES==null) {
				ALLOWED_COUNTRIES = new map<Id,IATA_ISO_Country__c>(IATAIsoCountryDAO.getIsoCountryByIsoCodes(ISSP_SIS_Account_Allowed_Countries__c.getAll().keyset())).keyset();
			}
			return account.RecordtypeId==RT_AGENCY &&
				(account.Quality__c.contains('YES') || account.Quality__c.contains('015w0000001yCfW')) &&
				ALLOWED_COUNTRIES.contains(account.IATA_ISO_Country__c) &&
				checkAccountLocation(account);

		} catch (Exception e) {
			System.debug('ERROR in validSISAccount for account ' + account + ' ' + e.getMessage());
			return false;
		}
	}

	private static Boolean isAccountModified(Account accountNew, Account accountOld) {
		//special case, status is terminated
		if (accountnew.Status__c == 'Terminated') {
			if (accountOld.Status__c == 'Terminated') {
				return false; // if the status was Terminated and is not changing, ignore the update
			} else {
				return true; // if the status changing to Terminated then update it
			}
		}

		if (accountnew.Status__c == 'Approved') {
			if (accountOld.Status__c != 'Approved') {
				return true;
			}
		}

		if(ALLOWED_STATUS.contains(accountnew.Status__c)) {
			for (String fieldName: ISSP_WS_SIS_Callout_CreateAccount.LIST_FIELD_NAMES) {
				if (fieldName!='BillingAddress')
				if (accountNew.get(fieldName) != accountOld.get(fieldName)) {
					return true;
				}
			}
		}
		return false;
	}

	/**
		Populate SIS status and substatus fields bases in the custom setting 'ISSP_SIS_Account_Status__c'
	**/
	//for update select only when change Recordtype, status__c or Country
	private static void updateSISStatusFields(map<Id,Account> mapNews, map<Id,Account> mapOlds) {
		list<Account> listAccount = new list<Account>();
		for (Account accountNew: mapNews.values()) {
			Account accountOld = mapOlds.get(accountNew.Id);
			if (accountNew.RecordTypeId!=accountOld.RecordtypeId ||
				accountNew.Status__c!=accountOld.Status__c ||
				accountNew.IATA_ISO_Country__c!=accountOld.IATA_ISO_Country__c ||
				accountNew.Location_Class__c!=accountOld.Location_Class__c
			) {
				listAccount.add(accountNew);
			}
		}
		updateSISStatusFields(listAccount);
	}

	// for insert
	private static void updateSISStatusFields(list<Account> listAccount) {
		for (Account account: listAccount) {
			// include country objetct in the account
			account.IATA_ISO_Country__r = AMS_utils.mapCountries.get(account.IATA_ISO_Country__c);

			if (String.isBlank(account.SIS_Status__c) || String.isBlank(account.SIS_Sub_Status__c) ) {
				ISSP_SIS_Account_Status__c setting = findCustomSettingSISStatus(account);
				if (setting!=null) {
					account.SIS_Status__c = setting.SIS_Status__c;
					account.SIS_Sub_Status__c = setting.SIS_Substatus__c;
				}
			}
		}
	}

	/**
		Search in the map setting the one that matches the recordtype, status and country
	**/
	private static ISSP_SIS_Account_Status__c findCustomSettingSISStatus(Account account) {
		//find  custom setting
		map<String,ISSP_SIS_Account_Status__c> mapSettings = getMapSISAccountStatus();
		// first find the setting for all exact values
		String key = account.RecordtypeId + ' ' + account.Status__c + ' ' + account.Location_Class__c + ' ' + account.IATA_ISO_Country__r.ISO_Code__c;
		ISSP_SIS_Account_Status__c setting = mapSettings.get(key);
		if (setting!=null) return setting;

		// second only when the country has a wildcard
		key = account.RecordtypeId + ' ' + account.Status__c + ' ' + account.Location_Class__c + ' All';
		setting = mapSettings.get(key);
		if (setting!=null) return setting;

		// third when the location class has the wildcard
		key = account.RecordtypeId + ' ' + account.Status__c + ' All ' + account.IATA_ISO_Country__r.ISO_Code__c;
		setting = mapSettings.get(key);
		if (setting!=null) return setting;

		// finally when the location class and the country have wildcards
		key = account.RecordtypeId + ' ' + account.Status__c + ' All All';
		setting = mapSettings.get(key);
		return setting;
	}

	/**
		check if account location fields are valid according to the CS ISSP_SIS_Account_Allowed_Location__c
	**/
	public static Boolean checkAccountLocation(Account account) {
		String locationClass = account.Location_Class__c==null? '': account.Location_Class__c.trim();
		String locationType = account.Location_Type__c==null? '': account.Location_Type__c.trim();
		String key = locationClass + ',' + locationType;
		return getAllowedLocations().contains(key);
	}

	/**
		Give_SIS_Membership__c can only be changed from empty to some value
		if there is at least one portal contact having access to SIS joining application
	**/
	private static void validateFieldAvailableSISManagement(map<Id,Account> mapNews, map<Id,Account> mapOlds) {
		list<Id> listAccountId = new list<Id>();
		for (Account accountNew: mapNews.values()) {
			Account accountOld = mapOlds.get(accountNew.Id);
			if (accountOld.Give_SIS_Membership__c==null && accountNew.Give_SIS_Membership__c!=null) {
				listAccountId.add(accountNew.Id);
			}
		}
		if (listAccountId.isEmpty()) return;
		list<Account> listQueryAccount = [
			SELECT Id, (SELECT id, Available_Services__c FROM Contacts WHERE Available_Services__c INCLUDES (:ISSP_SISMembershipApplication_Ctrl.APP_NAME))
			FROM Account
			WHERE id IN :listAccountId];
		for (Account account: listQueryAccount) {
			if (account.Contacts.isEmpty()) {
				mapNews.get(account.Id).Give_SIS_Membership__c.addError('Required at least one contact with "' + ISSP_SISMembershipApplication_Ctrl.APP_NAME + '"');
			}
		}
	}

}
