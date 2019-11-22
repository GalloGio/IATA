/**
 * Handle Contact (Contact, Account Contact Role, Address Role Business Context) synchronization logic to SAP/DMS
 */
public with sharing class ContactSyncUtils extends SObjectSyncUtils {

	public class ContactSyncException extends Exception {}

	public ContactSyncUtils() {
		this.getFieldsToCheckOnUpdate(SObjectSyncUtils.Context.Contact);
	}

	/**
	 * Handle synchronize logic between Salesforce and SAP/DMS
	 *
	 * @param sobjIdsByAccountIds
	 * @param isInsert
	 * @param isUpdate
	 * @param isDelete
	 * @param isUndelete
	 */
	public void doSynchronisation(List<SObject> sObjects, Boolean isInsert, Boolean isUpdate, Boolean isDelete, Boolean isUndelete) {
		if (sObjects.size() == 0) {
			return;
		}

		Map<Id, SObject> mapToSend = new Map<Id, SObject>();

		Set<String> doneKeys = new Set<String>();
		String key;
		for (Account_Contact_Role__c accountContactRole : getACRFromSObjects(sObjects)) {
			// Only one platform event per Contact in a same Account
			key = accountContactRole.Contact__c + '|' + accountContactRole.Account_Role__r.Account__c;
			if(!doneKeys.contains(key)) {
				doneKeys.add(key);

				mapToSend.put(accountContactRole.Id, accountContactRole);
			}
		}

		if((Limits.getLimitQueueableJobs() - Limits.getQueueableJobs()) > 0 && !System.isFuture() && !System.isBatch()) {
			System.enqueueJob(new PlatformEvents_Helper(mapToSend, 'AccountContactRole__e', 'Account_Contact_Role__c', trigger.isInsert, trigger.isUpdate, trigger.isDelete, trigger.isUndelete));
		} else {
			PlatformEvents_Helper.publishEvents(mapToSend, 'AccountContactRole__e', 'Account_Contact_Role__c', trigger.isInsert, trigger.isUpdate, trigger.isDelete, trigger.isUndelete);
		}
	}


	/**
	 * Get a list of Account Contact Role from the given @sObjects (Contact, Account Contact Role, Address Role Business Context)
	 *
	 * @param sObjects
	 *
	 * @return List of Account Contact Role
	 */
	private List<Account_Contact_Role__c> getACRFromSObjects(List<SObject> sObjects){
		Set<Id> ids = new Set<Id>();

		String query = 'SELECT Id, RecordType.DeveloperName, Contact__c, Account_Role__r.Account__c FROM Account_Contact_Role__c WHERE ';

		// Context is observed by the current where clause
		switch on sObjects.get(0){
			when Contact contact {
				query += 'Contact__c';

				for (SObject sobj : sObjects) {
					ids.add(sobj.Id);
				}
			}
			when Account_Contact_Role__c  accountContactRole {
				query += 'Id';

				for (SObject sobj : sObjects) {
					ids.add(sobj.Id);
				}
			}
			when Address_Role_Business_Context__c addressRoleBusinessContext {
				query += 'Account_Role__r.Account__c';

				for(Address_Role_Business_Context__c addressRoleBusinessContext : [
						SELECT Address_Role__r.Address__r.Account__c
						FROM Address_Role_Business_Context__c
						WHERE Id IN :sObjects
				]){
					ids.add(addressRoleBusinessContext.Address_Role__r.Address__r.Account__c);
				}
			}
			when else {
				throw new ContactSyncException(String.format('This process does not support the SObject {0}', new List<String>{sObjects.get(0).getSObjectType().getDescribe().getName()}));
			}
		}

		query += ' IN :ids ORDER BY Account_Role__r.Account__c DESC, Contact__c DESC, Id DESC';

		// Apply filter : only one platform event per Contact in a same Account
		List<Account_Contact_Role__c> accountContactRoles = new List<Account_Contact_Role__c>();

		Set<String> doneKeys = new Set<String>();
		String key;
		for (Account_Contact_Role__c accountContactRole : Database.query(query)) {
			key = accountContactRole.Contact__c + '|' + accountContactRole.Account_Role__r.Account__c;
			if(!doneKeys.contains(key)) {
				doneKeys.add(key);

				accountContactRoles.add(accountContactRole);
			}
		}

		return accountContactRoles;
	}
}