trigger ISSP_ContactStatusTrigger on Contact (after update) {

	if(ISSP_ContactList.avoidContactStatusTrigger)
		return;
		
	Set<Id> contactIds = new Set<Id>();
	Map<String, List<Id>> inactivationReasonMap = new Map<String, List<Id>> ();
	for(Contact newCon : trigger.new){
		Contact oldCon = trigger.oldMap.get(newCon.Id);
		if (newCon.Status__c != oldCon.Status__c){
			if (newCon.Status__c != 'Active'){
				contactIds.add(newCon.Id);
				system.debug('Inactivating contact');
				if (!inactivationReasonMap.containsKey(newCon.Status__c)){
					inactivationReasonMap.put(newCon.Status__c, new List<Id>{newCon.Id});
				}
				else{
					inactivationReasonMap.get(newCon.Status__c).add(newCon.Id);
				}
			}
		}
	}
	
	if (!contactIds.isEmpty()){
		List <Contact> contactList = [SELECT Id,
									(SELECT Id, Valid_To_Date__c FROM ID_Cards__r WHERE NOT card_status__c like 'Cancelled%'),
        							(SELECT Id FROM IEC_Subscriptions_History__r)
        							from Contact where Id IN :contactIds];
		for (Contact thisContact : contactList){
			if (!thisContact.ID_Cards__r.isEmpty()){
				for(Contact newCon : trigger.new){
					if (newCon.Id == thisContact.Id){
						newCon.addError('This contact is an ID Card holder. Please cancel the ID Card before inactivating the user.');
					}
				}
			}
			else if (!thisContact.IEC_Subscriptions_History__r.isEmpty()){
				for(Contact newCon : trigger.new){
					if (newCon.Id == thisContact.Id){
						newCon.addError('This contact has an active product subscription. It\'s not possible to inactivate contacts with active subscriptions.');
					}
				}
			}
		}
		for (String thisReason : inactivationReasonMap.keySet()){
			system.debug('thisReason: ' + thisReason);
			Set <Id> contactIdSet = new Set <Id>();
			List <Id> contactIdList = inactivationReasonMap.get(thisReason);
			if (thisReason == 'Left Company / Relocated'){
				thisReason = 'LeftCompany';
			}
			else if (thisReason == 'Retired'){
				thisReason = 'Retired';
			}
			else if (thisReason == 'Inactive'){
				thisReason = 'UnknownContact';
			}
			for (Id thisId : contactIdList){
				system.debug('contactIds: ' + thisId);
				contactIdSet.add(thisId);
			}
			ISSP_ContactList ctrl = new ISSP_ContactList();
			ctrl.processMultiplePortalUserStatusChange(contactIdSet, 'Deactivated', thisReason);
		}
	}
	
}