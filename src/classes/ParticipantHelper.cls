public with sharing class ParticipantHelper {
	/*
	 * Flags the contact using the LCAG_Member__c and APJC_Participant__c checkboxes if the parent Local Group / Governance has the respective type 
	 */
	public static void FlagParticipatingContacts(list<Participant__c> lstTriggerNew) {
		// get all the parent Local Groups / Governances Ids in a list
		list<Id> lstLocalGovernanceIds = new list<Id>();
		for (Participant__c p : lstTriggerNew) {
			lstLocalGovernanceIds.add(p.Local_Governance__c);
		}
		
		// get all Local Governances with their type in a map
		map<Id, LocalGovernance__c> lstLocalGovernancesPerId = new map<Id, LocalGovernance__c>([SELECT Id, Local_Governance_type__c FROM LocalGovernance__c WHERE Id IN :lstLocalGovernanceIds AND RecordType.DeveloperName = 'Local_Groups']);
		
		// create a map of the contacts to be flagged, per their Ids
		map<Id,Contact> mapContactsToUpdatePerId = new map<Id, Contact>();
		for(Participant__c p : lstTriggerNew) {
			if (lstLocalGovernancesPerId.get(p.Local_Governance__c) != null) {
				// flag for APJC
				if (lstLocalGovernancesPerId.get(p.Local_Governance__c).Local_Governance_type__c == 'APJC' ) {
					// put the Contact in the map if it's not already in there
					if (mapContactsToUpdatePerId.get(p.Contact__c) == null) {
						mapContactsToUpdatePerId.put(p.Contact__c, new Contact(Id = p.Contact__c));
					}
					
					// flag it as APJC Participant
					Contact flagged_contact = mapContactsToUpdatePerId.get(p.Contact__c);
					flagged_contact.APJC_Participant__c = true;
					
					// put it back in the map
					mapContactsToUpdatePerId.put(p.Contact__c, flagged_contact);
				}
				
				// flag for LCAG
				if (lstLocalGovernancesPerId.get(p.Local_Governance__c).Local_Governance_type__c == 'LCAG-C' || 
					lstLocalGovernancesPerId.get(p.Local_Governance__c).Local_Governance_type__c == 'LCAG-P' ) {
					
					// put the Contact in the map if it's not already in there
					if (mapContactsToUpdatePerId.get(p.Contact__c) == null) {
						mapContactsToUpdatePerId.put(p.Contact__c, new Contact(Id = p.Contact__c));
					}
					
					// flag it as APJC Participant
					Contact flagged_contact = mapContactsToUpdatePerId.get(p.Contact__c);
					flagged_contact.LCAG_Member__c = true;
					
					// put it back in the map
					mapContactsToUpdatePerId.put(p.Contact__c, flagged_contact);
				}
			}
		}
		
		// if there are flagged contacts, update them in the DB
		if (!mapContactsToUpdatePerId.values().isEmpty()) {
			update mapContactsToUpdatePerId.values();
		}
	}
	
	
	
	/*
	 * Un-flags the contact when a Participant record is deleted, if it is no longer participating in Local Groups / Governances of the respective type 
	 */
	public static void UnflagParticipatingContacts(list<Participant__c> lstTriggerOld) {
		// get all the related contacts in a map per contact Id, and reset their flags
		map<Id, Contact> mapRelatedContactPerIds = new map<Id, Contact>();
		for (Participant__c p : lstTriggerOld) {
			mapRelatedContactPerIds.put(p.Contact__c, new Contact(Id = p.Contact__c, LCAG_Member__c = false, APJC_Participant__c = false));
		}
		
		// get all the participations of the related contacts in a map per contact Id
		map<Id, list<Participant__c>> mapParticipantsPerContactIds = new map<Id, list<Participant__c>>();
		for (Participant__c p : [SELECT Id, Contact__c, Local_Governance__r.Local_Governance_type__c FROM Participant__c WHERE Contact__c IN :mapRelatedContactPerIds.keyset() AND Local_Governance__r.RecordType.DeveloperName = 'Local_Groups']) {
			if (mapParticipantsPerContactIds.get(p.Contact__c) == null) {
				mapParticipantsPerContactIds.put(p.Contact__c, new list<Participant__c>());
			}
			
			mapParticipantsPerContactIds.get(p.Contact__c).add(p);
		}
		
		// for all the deleted participations, check if the contact has another participation of the same type - then flag it back
		for(Participant__c deletedParticipant : lstTriggerOld) {
			if (mapParticipantsPerContactIds.get(deletedParticipant.Contact__c) != null) {
				for (Participant__c otherPartipant : mapParticipantsPerContactIds.get(deletedParticipant.Contact__c)) {
					Contact contactToUpdate = mapRelatedContactPerIds.get(deletedParticipant.Contact__c);
					
					if (otherPartipant.Local_Governance__r.Local_Governance_type__c == 'APJC') {
						contactToUpdate.APJC_Participant__c = true;
					}
					
					if (otherPartipant.Local_Governance__r.Local_Governance_type__c == 'LCAG-C' || otherPartipant.Local_Governance__r.Local_Governance_type__c == 'LCAG-P' ) {
						contactToUpdate.LCAG_Member__c = true;
					}
					
					mapRelatedContactPerIds.put(deletedParticipant.Contact__c, contactToUpdate);
				}
			}
		}
		
		
		update mapRelatedContactPerIds.values();
				
	}

	/*
	 * Blocks deletion of members to inactive groups
	 */
	public static void blockDeletingFromInactiveGroups(list<Participant__c> lstTriggerOld) {
		// get all the parent Local Groups / Governances Ids in a list
		list<Id> lstLocalGovernanceIds = new list<Id>();
		for (Participant__c p : lstTriggerOld) {
			lstLocalGovernanceIds.add(p.Local_Governance__c);
		}
		// get all Local Governances with their type in a map
		map<Id, LocalGovernance__c> lstLocalGovernancesPerId = new map<Id, LocalGovernance__c>([SELECT Id, Active__c FROM LocalGovernance__c WHERE Id IN :lstLocalGovernanceIds ]);

		for(Participant__c p : lstTriggerOld) {
			if (lstLocalGovernancesPerId.get(p.Local_Governance__c).Active__c == false) {
				p.addError('Cannot delete members from inactive groups');
			}
		}
	}


}