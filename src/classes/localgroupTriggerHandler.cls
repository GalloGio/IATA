public class localgroupTriggerHandler
{
	public List<LocalGovernance__c> getAllChildren(Id parentId, List<LocalGovernance__c> allGroups) {
		List<LocalGovernance__c> lsChildren = new List<LocalGovernance__c>();
		for(LocalGovernance__c l : allGroups) {
			if(l.Reporting_to__c == parentId) {
				lsChildren.add(l);
				lsChildren.addAll(getChildren(l.Id, allGroups));
			}
		}
		return lsChildren;
	}

	public List<LocalGovernance__c> getChildren(Id parentId, List<LocalGovernance__c> allGroups) {
		List<LocalGovernance__c> lsChildren = new List<LocalGovernance__c>();
		for(LocalGovernance__c l : allGroups) {
			if(l.Reporting_to__c == parentId) {
				lsChildren.add(l);
			}
		}
		return lsChildren;
	}

	public Boolean hasActiveGroups(List<LocalGovernance__c> lsGroups) {
		Boolean hasActive = false;
		for(LocalGovernance__c l : lsGroups) {
			if(l.Active__c) {
				hasActive = true;
				break;
			}
		}
		return hasActive;
	}

	public static void beforeUpdate(map<Id,LocalGovernance__c> mapNews, map<Id,LocalGovernance__c> mapOlds) {
		findChangedLocalGroups(mapNews,mapOlds);
	}

	public static void afterUpdate(map<Id,LocalGovernance__c> mapNews, map<Id,LocalGovernance__c> mapOlds) {
		findContactsToUpdate(LIST_LOCALGROUPS_CHANGED);
	}


	/*
	 * Find LocalGovernance__c having a change in the Abbreviation__c field 
	 */
	private static list<LocalGovernance__c> LIST_LOCALGROUPS_CHANGED;
	public static void findChangedLocalGroups(map<Id,LocalGovernance__c> mapNews, map<Id,LocalGovernance__c> mapOlds) {
		LIST_LOCALGROUPS_CHANGED = new list<LocalGovernance__c>();
		for ( LocalGovernance__c newValue: mapNews.values()) {
			LocalGovernance__c oldValue = mapOlds.get(newValue.Id);
			if (newValue.Abbreviation__c != oldValue.Abbreviation__c) {
				LIST_LOCALGROUPS_CHANGED.add(newValue);
			}
		}
	}

	/*
	 * Find all contacts that belong to the input groups
	 */
	public static void findContactsToUpdate(list<LocalGovernance__c> listGroups) {
		// find all Contacts related to the input groups
		list<Id> listContactId = new list<Id>();
		for (Participant__c participant:
				[SELECT Contact__c
				FROM Participant__c
				WHERE Local_Governance__c IN :listGroups]) {
			listContactId.add(participant.Contact__c);
		}
		// for each contact update theid checboxes related to Industry groups
		updateParentContacts(listContactId);
	}

	/**
	 * Update fields related to Industry groups in Contacts
	 */
	public static void updateParentContacts(list<Id> listContactId) {
		//find all Participations for the input Contacts
		list<Contact> listContact = [
			SELECT Id, PaConf_Representative__c, PAPGCJ_Participant__c, PSG_Member__c,
				(SELECT Id, Local_Governance__r.Abbreviation__c FROM APJC_Participants__r)
			FROM Contact
			WHERE Id IN :listContactId
		];
		// for each contact update theid checboxes related to Industry groups
		list<Contact> listContactToUpdate = new list<Contact>();
		for (Contact contact: listContact) {
			Boolean isPAC = false;
			Boolean isPSG = false;
			Boolean isPAPGJC = false;
			for (Participant__c participant: contact.APJC_Participants__r) {
				isPAC |= (participant.Local_Governance__r.Abbreviation__c == 'PAC');
				isPSG |= (participant.Local_Governance__r.Abbreviation__c == 'PSG');
				isPAPGJC |= (participant.Local_Governance__r.Abbreviation__c == 'PAPGJC');
			}
			if (isPAC != contact.PaConf_Representative__c) {
				contact.PaConf_Representative__c = isPAC;
				listContactToUpdate.add(contact);
			}
			if (isPSG != contact.PSG_Member__c) {
				contact.PSG_Member__c = isPSG;
				listContactToUpdate.add(contact);
			}
			if (isPAPGJC != contact.PAPGCJ_Participant__c) {
				contact.PAPGCJ_Participant__c = isPAPGJC;
				listContactToUpdate.add(contact);
			}
		}
		// if there is any change in the contacts run the update batch
		if (!listContactToUpdate.isEmpty()) {
			System.enqueueJob(new AsyncDML_Util(listContactToUpdate, AsyncDML_Util.DML_UPDATE, false));
		}
	}
}
