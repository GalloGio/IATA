public with sharing class RelatedContactUtil {

	/*
	 * Updates the list of ids of accounts that related contacts are linked to (Related_to_Accounts__c field on the Contact object)
	 */
	public static void UpdateRelatedContacts (map<Id, Related_Contact__c> triggerMap) {
		// a set of the related contact ids
		set<Id> setRelatedContactIds = new set<Id>();

		for (Related_Contact__c rc : triggerMap.values()) {
			setRelatedContactIds.add(rc.Contact__c);
		}

		map<Id, Contact> mapContactsPerId = new map<Id, Contact>([SELECT Id, Related_to_Accounts__c FROM Contact WHERE Id IN :setRelatedContactIds]);
		// reset the Related_to_Accounts__c fields
		for (Contact c : mapContactsPerId.values()) {
			c.Related_to_Accounts__c = '';
		}

		List<Related_Contact__c> lstActiveRelatedContacts = [SELECT Id, Contact__c, Account__c FROM Related_Contact__c WHERE Contact__c IN :setRelatedContactIds AND Status__c = 'Active'];

		for (Related_Contact__c rc : lstActiveRelatedContacts) {
			mapContactsPerId.get(rc.Contact__c).Related_to_Accounts__c += (mapContactsPerId.get(rc.Contact__c).Related_to_Accounts__c == '' ? '' : ',') + rc.Account__c;
		}

		update mapContactsPerId.values();
	}
}
