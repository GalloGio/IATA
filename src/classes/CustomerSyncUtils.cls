/**
 * Created by LBERB on 17/10/2019.
 */

/**
 * Handle Customer (Account, Account Relationship, Address, Address Role, Address Role Business Context) synchronization logic to SAP/DMS
 */
public with sharing class CustomerSyncUtils extends SObjectSyncUtils {

	public class CustomerSyncException extends Exception {
	}

	@TestVisible
	private final static Id ACCOUNT_RECORDTYPEID_AIRPORT = Schema.Account.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Airport').getRecordTypeId();
	@TestVisible
	private final static String ACCOUNT_HIERARCHY_LEVEL_BRANCH = 'Branch';
	@TestVisible
	private final static String ACCOUNT_ACTIVATION_CONTEXT_STATUS_OK = 'Completed';
	@TestVisible
	private final static String ADDRESS_ROLE_ROLE_TYPE_BUSINESS = 'Business';

	public enum Context {
		Standard,
		Airport,
		Branch
	}

	private static Map<String, List<String>> FIELDS_TO_CHECK_ON_UPDATE = new Map<String, List<String>>{
			'Account' => new List<String>{
					'EF_SIS_Designator__c',
					'EF_SIS_Code__c',
					'Category__c',
					'Sector__c',
					'Legal_name__c',
					'Name',
					'VAT_Number_2__c',
					'VAT_Number__c',
					'Email__c',
					'Phone'
			},
			'Account_Relationship__c' => new List<String>{
					'Child_Account__c',
					'Parent_Account__c'
			},
			'Address__c' => new List<String>{
					'Street__c',
					'Po_Box__c',
					'Postal_Code__c',
					'City_Name__c',
					'Country__c',
					'Geo_Coordinates__Latitude__s',
					'Geo_Coordinates__Longitude__s',
					'State_Name__c',
					'Account__c'
			},
			'Address_Role__c' => new List<String>{
					'SIS_Location_ID__c',
					'Role_Type__c',
					'Address__c'
			},
			'Address_Role_Business_Context__c' => new List<String>{
					'Account_Activation_Context_Status__c',
					'Address_Role__c',
					'Business_Context__c'
			}
	};

	public CustomerSyncUtils() {
		this.fieldsToCheckOnUpdate.putAll(FIELDS_TO_CHECK_ON_UPDATE);

		this.accounts = new Map<Id, Account>();
		this.synchronizedAccountIds = new Set<Id>();
		this.airportAuthIdByAiportId = new Map<Id, Id>();
		this.hasSynchronizedBusinessAddressAccountIds = new Set<Id>();
	}

	/**
	 * Contains processed Account which are synchronized with SAP/DMS
	 */
	private Map<Id, Account> accounts;
	/**
	 * Contains processed Account which are synchronized with SAP/DMS
	 */
	private Set<Id> synchronizedAccountIds;
	/**
	 * Contains main Account Id by child AccountId (airport scenario)
	 */
	private Map<Id, Id> airportAuthIdByAiportId;
	/**
	 * Contains processed Account which have a business address (airport scenario)
	 */
	private Set<Id> hasSynchronizedBusinessAddressAccountIds;

	/**
	 * Handle synchronize logic between Salesforce and SAP/DMS
	 *
	 * @param contexts (Standard, Airport, Branch)
	 * @param sobjIdsByAccountIds
	 * @param eventType (Insert, Update, Delete, Undelete)
	 */
	public void doSynchronisation(List<Context> contexts, List<SObject> sObjects, String eventType) {
		System.debug('CustomerSyncUtils.doSynchronisation() - ' + eventType);

		System.debug('sObjects.size() : ' + sObjects.size());
		System.debug('sObjects : ' + sObjects);
		if (sObjects.size() == 0) {
			return;
		}

		Map<Id, List<SObject>> ARBCIdsByAccountId = getARBCByAccountIdsFromSObjects(sObjects);

		getAccountInformation(contexts, ARBCIdsByAccountId.keySet());

		PlatformEventUtils.clear();

		System.debug('Processing data');
		Account account;
		for (Id accountId : ARBCIdsByAccountId.keySet()) {
			if (!accounts.containsKey(accountId)) {
				System.debug('Account not allowed : ' + accountId);
				continue;
			}
			account = accounts.get(accountId);
			System.debug('accountId : ' + accountId);
			System.debug('account : ' + account);

			if (!isAccountSynchronized(account)) {
				System.debug('Account is synchronized : ' + accountId);
				continue;
			}

			for (SObject sobj : ARBCIdsByAccountId.get(accountId)) {
				System.debug('Address Role Business Context which will be synchronized : ' + sobj.Id);

				PlatformEventUtils.add(new AddressRoleBusinessContext__e(
						EventType__c = eventType,
						RecordType__c = sobj.get('RecordTypeId') != null ? (String) sobj.getSObject('RecordType').get('DeveloperName') : '',
						RecordId__c = sobj.Id
				));
			}

		}

		Boolean isFullSuccess = PlatformEventUtils.send();
	}

	/**
	 * Get Address Role Business Context by Account Ids from the given @sObjects (Account, Account Relationship, Address, Address Role, Address Role Business Context)
	 *
	 * @param sObjects
	 *
	 * @return Address Role Business Context by Account Ids
	 */
	private Map<Id, List<SObject>> getARBCByAccountIdsFromSObjects(List<SObject> sObjects) {
		System.debug('getARBCByAccountIdsFromSObjects()');

		Map<Id, List<SObject>> ARBCIdsByAccountId = new Map<Id, List<SObject>>();

		// Query Address Role Business Context from @sObjects
		Id prevAddressRoleId, addressRoleId, accountId;
		Set<Id> accountIds = new Set<Id>();
		for (Address_Role_Business_Context__c addressRoleBusinessContext : getARBCFromSObjects(sObjects)) {
			accountId = addressRoleBusinessContext.Address_Role__r.Address__r.Account__c;
			addressRoleId = addressRoleBusinessContext.Address_Role__c;

			// Store Address Role Business Context Ids that must be sent to SAP/MDS by Account Id
			if (!ARBCIdsByAccountId.containsKey(accountId)) {
				ARBCIdsByAccountId.put(accountId, new List<SObject>());
			}

			// Store only one Address Role Business Context by Address Role
			if (prevAddressRoleId == null || prevAddressRoleId != addressRoleId) {
				ARBCIdsByAccountId.get(accountId).add(addressRoleBusinessContext);
			}

			prevAddressRoleId = addressRoleId;
		}

		System.debug('ARBCIdsByAccountId : ' + ARBCIdsByAccountId);
		return ARBCIdsByAccountId;
	}

	private List<Address_Role_Business_Context__c> getARBCFromSObjects(List<SObject> sObjects) {
		System.debug('getARBCFromSObjects()');

		Set<Id> ids = new Set<Id>();

		String query = 'SELECT Id, RecordType.DeveloperName, Address_Role__c, Address_Role__r.Address__r.Account__c';
		query += ' FROM Address_Role_Business_Context__c';
		query += ' WHERE ';

		// Context is observed by the current where clause
		switch on sObjects.get(0) {
			when Account account {
				System.debug('from Account');
				query += 'Address_Role__r.Address__r.Account__c';

				for (SObject sobj : sObjects) {
					ids.add(sobj.Id);
				}
			}
			when Account_Relationship__c accountRelationship {
				System.debug('from Account Relationship');
				query += 'Address_Role__r.Address__r.Account__c';

				for (SObject sobj : sObjects) {
					ids.add((Id) sobj.get('Child_Account__c'));
				}
			}
			when Address__c address {
				System.debug('from Address');
				query += 'Address_Role__r.Address__c';

				for (SObject sobj : sObjects) {
					ids.add(sobj.Id);
				}
			}
			when Address_Role__c addressRole {
				System.debug('from Address Role');
				query += 'Address_Role__c';

				for (SObject sobj : sObjects) {
					ids.add(sobj.Id);
				}
			}
			when Address_Role_Business_Context__c addressRoleBusinessContext {
				System.debug('from Address Role Business Context');
				for (SObject sobj : sObjects) {
					ids.add(sobj.Id);
				}

				for(Address_Role_Business_Context__c addressRoleBusinessContext2 : [
						SELECT Address_Role__r.Address__r.Account__c FROM Address_Role_Business_Context__c
						WHERE Id IN :ids
				]){
					ids.add(addressRoleBusinessContext2.Address_Role__r.Address__r.Account__c);
				}

				for(Account_Relationship__c accountRelationship : [
						SELECT Child_Account__c FROM Account_Relationship__c
						WHERE Parent_Account__c IN :ids
				]){
					ids.add(accountRelationship.Child_Account__c);
				}

				query += 'Address_Role__r.Address__r.Account__c IN :ids AND Id';
			}
			when else {
				// TODO throw exception with Custom Label
				throw new CustomerSyncException(String.format('This process does not support the SObject {0}', new List<String>{
						sObjects.get(0).getSObjectType().getDescribe().getName()
				}));
			}
		}

		query += ' IN :ids';

		query += ' ORDER BY Address_Role__r.Address__r.Account__c DESC, Address_Role__r.Address__c DESC, Address_Role__c DESC, Id DESC';
		System.debug('query : ' + query);
		System.debug('ids : ' + ids);

		// Apply filter : only one platform event per Address Role
		List<Address_Role_Business_Context__c> addressRoleBusinessContexts = new List<Address_Role_Business_Context__c>();

		Set<String> doneKeys = new Set<String>();
		String key;
		for (Address_Role_Business_Context__c addressRoleBusinessContext : Database.query(query)) {
			key = addressRoleBusinessContext.Address_Role__c;
			if (!doneKeys.contains(key)) {
				doneKeys.add(key);

				addressRoleBusinessContexts.add(addressRoleBusinessContext);
			}
		}

		return addressRoleBusinessContexts;
	}

	/**
	 * Get information from account (is synchronized, has a business address synchronized, airport authority information, ...)
	 *
	 * @param contexts (Standard, Airport, Branch)
	 * @param ids Account Ids
	 *
	 * @return True is if the current account is authorized for synchronization, false otherwise
	 */
	private void getAccountInformation(List<Context> contexts, Set<Id> ids) {
		System.debug('getAccountInformation()');
		Id accountId;
		Set<Id> accountIds = new Set<Id>();

		Boolean isStandardContext = contexts.contains(Context.Standard);
		Boolean isAirportContext = contexts.contains(Context.Airport);
		Boolean isBranchContext = contexts.contains(Context.Branch);
		System.debug('isStandardContext : ' + isStandardContext);
		System.debug('isAirportContext : ' + isAirportContext);
		System.debug('isBranchContext : ' + isBranchContext);

		// Given ids are not enough to handle every scenario => need to query account in order to select all needed Account
		for (Account account : [
				SELECT Id, RecordTypeId, Hierarchy_Level__c, ParentId
				FROM Account
				WHERE Id IN :ids
		]) {
			accountId = account.Id;

			// For airport : airport authority is the main account
			if (ACCOUNT_RECORDTYPEID_AIRPORT == account.RecordTypeId) {
				if (isAirportContext) {
					accountIds.add(accountId);
				}
			}
			// For branch : Holding Parent contains the main account
			else if (ACCOUNT_HIERARCHY_LEVEL_BRANCH == account.Hierarchy_Level__c) {
				if (isBranchContext) {
					accountIds.add(accountId);
					accountIds.add(account.ParentId);
				}
			} else {
				if (isStandardContext) {
					accountIds.add(accountId);
				}
			}
		}

		System.debug('accountIds.size() : ' + accountIds.size());
		System.debug('accountIds : ' + accountIds);

		// Get parent Account from Account Relationship (airport process)
		if (isAirportContext && accountIds.size() > 0) {
			for (Account_Relationship__c accountRelationship : [
					SELECT Parent_Account__c, Child_Account__c
					FROM Account_Relationship__c
					WHERE Child_Account__c IN :accountIds
					AND Child_Account__r.RecordTypeId = :ACCOUNT_RECORDTYPEID_AIRPORT
			]) {
				accountIds.add(accountRelationship.Parent_Account__c);
				airportAuthIdByAiportId.put(accountRelationship.Child_Account__c, accountRelationship.Parent_Account__c);
			}
			System.debug('airportAuthIdByAiportId : ' + airportAuthIdByAiportId);
			System.debug('accountIds.size() : ' + accountIds.size());
		}

		// Get whole context for each selected Customer (Account, Address, AddressRole, AddressRoleBusinessContext)
		for (Address_Role_Business_Context__c addressRoleBusinessContext : [
				SELECT Id, Account_Activation_Context_Status__c,
						Address_Role__r.AccountHierarchyLevel__c, Address_Role__r.Role_Type__c,
						Address_Role__r.Address__c,
						Address_Role__r.Address__r.Account__c, Address_Role__r.Address__r.Account__r.RecordTypeId, Address_Role__r.Address__r.Account__r.ParentId, Address_Role__r.Address__r.Account__r.Hierarchy_Level__c
				FROM Address_Role_Business_Context__c
				WHERE Address_Role__r.Address__r.Account__c IN :accountIds
				ORDER BY Address_Role__r.Address__r.Account__r.ParentId ASC,
						Address_Role__r.Address__r.Account__c ASC,
						Address_Role__r.Address__c ASC,
						Address_Role__c ASC,
						Id ASC
		]) {
			accountId = addressRoleBusinessContext.Address_Role__r.Address__r.Account__c;

			// If the Account is synchronized
			if (ACCOUNT_ACTIVATION_CONTEXT_STATUS_OK == addressRoleBusinessContext.Account_Activation_Context_Status__c) {
				//synchronizedAccountIds.add(accountId);

				// And if this is a business address
				if (ADDRESS_ROLE_ROLE_TYPE_BUSINESS == addressRoleBusinessContext.Address_Role__r.Role_Type__c) {
					hasSynchronizedBusinessAddressAccountIds.add(accountId);
				}
			}

			// Store Accounts to process them later
			if (!accounts.containsKey(accountId)) {
				accounts.put(accountId, addressRoleBusinessContext.Address_Role__r.Address__r.Account__r);
			}
		}

		//System.debug('synchronizedAccountIds.size() : ' + synchronizedAccountIds.size());
		//System.debug('synchronizedAccountIds : ' + synchronizedAccountIds);

		System.debug('hasSynchronizedBusinessAddressAccountIds.size() : ' + hasSynchronizedBusinessAddressAccountIds.size());
		System.debug('hasSynchronizedBusinessAddressAccountIds : ' + hasSynchronizedBusinessAddressAccountIds);

		System.debug('accounts.size() : ' + accounts.size());
	}

	/**
	 * Check if the current account is authorized for synchronization
	 *
	 * @param account
	 *
	 * @return True is if the current account is authorized for synchronization, false otherwise
	 */
	private Boolean isAccountSynchronized(Account account) {
		System.debug('isAccountSynchronized()');

		// For airport : airport authority must be synchronized
		if (ACCOUNT_RECORDTYPEID_AIRPORT == account.RecordTypeId) {
			System.debug('Airport');
			if (airportAuthIdByAiportId.containsKey(account.Id)) {
				return hasSynchronizedBusinessAddressAccountIds.contains(airportAuthIdByAiportId.get(account.Id));
			} else {
				return false;
			}
		}
		// For branch : need to have their master account synchronized
		else if (ACCOUNT_HIERARCHY_LEVEL_BRANCH == account.Hierarchy_Level__c) {
			System.debug('Branch');
			return hasSynchronizedBusinessAddressAccountIds.contains(account.ParentId);
		}
		// For other account : need to be synchronized
		else {
			System.debug('Standard');
			return hasSynchronizedBusinessAddressAccountIds.contains(account.Id);
		}
	}
}