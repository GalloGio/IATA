public class ANG_ContactHandler {

	public List<Contact> triggerNew = (List<Contact>) Trigger.new;
	public List<Contact> triggerOld = (List<Contact>) Trigger.old;

	public Map<Id, Contact> newMap = (Map<Id,Contact>) Trigger.newMap;
	public Map<Id, Contact> oldMap = (Map<Id,Contact>) Trigger.oldMap;

	public void ANG_ContactHandler(){}

	public void handleBeforeUpdate() {
		checkAccountHierarchy();
	}

	private void checkAccountHierarchy() {
		//
		// Check if the contact will be moved to another account outside the hierarchy.
		// If true gives an error
		//
		// This rule in only applied if the contact has an EasyPay Service subscrived.
		//
		Set<Id> contactsIdsSet = new Set<Id>();
		Set<Id> accountsIdsSet = new Set<Id>();

		for (Contact old : triggerOld) {			
			if (old.accountId != null && old.accountId != newMap.get(old.id).accountId) {
				contactsIdsSet.add(old.id);
				accountsIdsSet.add(old.accountId);
			}
		}

		if (contactsIdsSet.size() != 0) {
			List<Portal_Application_Right__c> parList = [Select contact__c 
														   From Portal_Application_Right__c 
														  Where Contact__c in : contactsIdsSet 
														    AND portal_application__r.ANG_Cannot_move_contact_between_Agencies__c = true
														    And Right__c in ('Access Requested', 'Access Granted')];

			if (parList.size() != 0) {														    

				Map<Id, List<AMS_Agencies_relationhip__c>> hier = AMS_HierarchyHelper.getAccountsHierarchies(accountsIdsSet);

				Set<id> easyPayContacts = new Set<Id>();
				for (Portal_Application_Right__c p : parList) {
					easyPayContacts.add(p.contact__c);
				}

				for (Contact old : triggerOld) {
					if (old.accountId != newMap.get(old.id).accountId && easyPayContacts.contains(old.id)) {
						List<AMS_Agencies_relationhip__c> amsl = hier.get(old.accountId);

						boolean error = true;
						for (AMS_Agencies_relationhip__c ams : amsl) {
							if (ams.Child_Account__c == newMap.get(old.id).accountId || ams.Parent_Account__c == newMap.get(old.id).accountId) {
								error = false;
								break;
							}
						}
						if (error) {
							newMap.get(old.id).addError(Label.ANG_ISSP_ChangeContactHierarchyError);
						}
					}
				}
			}
		}
	}
}