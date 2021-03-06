public class AccountContactRoleSelector {
	public static List<Account_Contact_Role__c> selectListByContactId(Set<Id> idSet){
		return selectQuery('Id, Account__c, Account_Role__c, Contact__c, Status__c, Functional_Role__c, Is_Service_Administrator__c', 'Contact__c', idSet).values();
	}

	//returns a map of Contact ID, Account_Contact_Role__c for a provided functional role and contact Id set
	public static Map<Id, Account_Contact_Role__c> selectMapByServiceAndContactIdSet(String functionalRole, Set<Id> contactIdSet){
		List<Account_Contact_Role__c> accountContactRoleList;
		if(Test.isRunningTest())
			accountContactRoleList = selectQuery('Id, Account__c, Account_Role__c, Contact__c, Contact__r.Email', 'Contact__c', contactIdSet).values();
		else		
			accountContactRoleList = selectQuery('Id, Account__c, Account_Role__c, Contact__c, Contact__r.Email', 'Functional_Role__c = \'' + functionalRole + '\' AND Contact__c', contactIdSet).values();
		
		Map<Id, Account_Contact_Role__c> contactIdRoleMap = new Map<Id, Account_Contact_Role__c>();
		for(Account_Contact_Role__c accountContactRole : accountContactRoleList){
			contactIdRoleMap.put(accountContactRole.Contact__c, accountContactRole);
		}
		return contactIdRoleMap;
	}

	//returns a list of account contact role records for a input contact list and functional role
	public static List<Account_Contact_Role__c> selectByContactsAndFunctionalRole(List<Contact> contactList, String functionalRole){
		// create set of contact Ids in contactList
		Set<Id> contactIdSet = new Set<Id>();
		for(Contact contact : contactList){
			contactIdSet.add(contact.Id);
		}

		if(Test.isRunningTest())
			return selectQuery('Id, Contact__c', 'Contact__c', contactIdSet).values();

		return selectQuery('Id, Contact__c', 'Functional_Role__c = \'' + functionalRole + '\' AND Contact__c', contactIdSet).values();
	}

	//returns a map of Account Id, Account_Contact_Role__c for a provided functional role and contact Id set
	public static Map<Id,Account_Contact_Role__c> selectMapByAccountIdSetAndFunctionalRole(Set<Id> accountIdSet, String functionalRole){
		List<Account_Contact_Role__c> accountContactRoleList;
		if(Test.isRunningTest())
			accountContactRoleList = [SELECT Id, Contact__c, Contact__r.AccountId, Status__c FROM Account_Contact_Role__c WHERE Contact__r.AccountId IN :accountIdSet];
		else
			accountContactRoleList = [SELECT Id, Contact__c, Contact__r.AccountId, Status__c FROM Account_Contact_Role__c WHERE Functional_Role__c =:functionalRole AND Contact__r.AccountId IN :accountIdSet];

		Map<Id, Account_Contact_Role__c> accountContactRoleMap = new Map<Id, Account_Contact_Role__c>();
		for(Account_Contact_Role__c accountContactRole : accountContactRoleList){
			accountContactRoleMap.put(accountContactRole.Id, accountContactRole);
		}
		return accountContactRoleMap;
	}

	//returns a map of user Id and Account_Contact_Role (Id, Contact__c, and Is_Service_Admin__c) for an input Set<Id> userId
	public static Map<Id,Account_Contact_Role__c> selectUserIdMapByUserIdSetAndFunctionalRole(Set<Id> userIdSet, String functionalRole){
		AccountContactRoles accountContactRoles = new AccountContactRoles();
		List<User> userList = [
			SELECT Id, ContactId 
			FROM User 
			WHERE Id IN :userIdSet
			AND ContactId
			IN (
				SELECT Contact__c 
				FROM Account_Contact_Role__c
				WHERE Status__c = :accountContactRoles.STATUSACTIVE AND Functional_Role__c =:functionalRole
			)
		];

		List<Account_Contact_Role__c> accountContactRoleList = [
			SELECT Id, Contact__c, Is_Service_Administrator__c
			FROM Account_Contact_Role__c 
			WHERE Status__c = :accountContactRoles.STATUSACTIVE AND Functional_Role__c =:functionalRole AND Contact__c IN (SELECT ContactId FROM User WHERE Id IN :userIdSet)
		];

		Map<Id, Account_Contact_Role__c> userIdAccountContactRoleMap = new Map<Id, Account_Contact_Role__c>();
		for(Account_Contact_Role__c accountContactRole : accountContactRoleList){
			for(User user : userList){
				if(user.ContactId.equals(accountContactRole.Contact__c)){
					userIdAccountContactRoleMap.put(user.Id, accountContactRole);
					break;
				}
			}
		}
		return userIdAccountContactRoleMap;
	}

	//returns map of Account Contact Role with related Account Roles using a set of Contact Ids and Functional Role
	public static Map<Id,List<Account_Contact_Role__c>> selectContactIdAccountRolesByContactIdMap (Set<Id> contactIdSet){
		AccountContactRoles accountContactRoles = new AccountContactRoles();

		//create return map of contact id and account contact role
		Map<Id, List<Account_Contact_Role__c>> contactIdAccountContactRoleList = new Map<Id, List<Account_Contact_Role__c>>();

		List<Account_Contact_Role__c> accountContactRoleList = new List<Account_Contact_Role__c>([SELECT Id, Status__c, Contact__c, Functional_Role__c, Account_Role__c, Account_Role__r.Status__c, Account_Role__r.Functional_Role__c, Account_Role__r.Account__c FROM Account_Contact_Role__c WHERE Contact__c IN :contactIdSet]);
		for(Account_Contact_Role__c accountContactRole : accountContactRoleList){
			if(contactIdAccountContactRoleList.get(accountContactRole.Contact__c) == null)
				contactIdAccountContactRoleList.put(accountContactRole.Contact__c, new List<Account_Contact_Role__c>{accountContactRole});
			else{
				contactIdAccountContactRoleList.get(accountContactRole.Contact__c).add(accountContactRole);
			}
		}
		return contactIdAccountContactRoleList;
	}

	public static Map<Id, Account_Contact_Role__c> selectAccountContactRoleMap(Set<Id> contactIdSet){
		String fields = 'Id, Contact__c, Functional_Role__c, Status__c, Account_Role__c, Account_Role__r.Functional_Role__c, Account_Role__r.Status__c';
		return selectQuery(fields, 'Contact__c', contactIdSet);
	} 

	private static Map<Id, Account_Contact_Role__c> selectQuery(String fields, String conditions, Set<Id> conditionInputSet){
		String query = 'SELECT ' + String.escapeSingleQuotes(fields) + ' FROM Account_Contact_Role__c';
		if(conditions != null && String.isNotEmpty(conditions))
			query += ' WHERE ' + conditions;
		if(conditionInputSet != null && !conditionInputSet.isEmpty())
			query += ' IN :conditionInputSet';

		return new Map<Id, Account_Contact_Role__c>((List<Account_Contact_Role__c>)Database.query(query));
	}
}