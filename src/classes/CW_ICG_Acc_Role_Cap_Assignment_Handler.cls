/**
 * @description Handler used by the trigger ICG_Account_Role_Capability_Assignment to execute the capabilities deprecation flow
 */
public with sharing class CW_ICG_Acc_Role_Cap_Assignment_Handler {
	private List<ICG_Account_Role_Capability_Assignment__c> newItems;

	// Data required for deprecation flow
	private static Map<Id, ICG_Capability_Assignment_Group__c> asgmtGroups;
	private static Map<Id, Account_Role_Detail_Capability__c> detailCapabilities;
	private static Map<Id, ICG_Account_Role_Capability_Assignment__c> asgmts;
	private static Map<Id, List<Id>> asgmtGroupsByStationPrev;
	private static Map<String, List<Id>> asgmtsByStationAndEquipmentPrev;
	private static List<String> multiRecordCapabilities;
	private static List<Id> affectedStations;

	private static Map<Id, ICG_Account_Role_Capability_Assignment__c> asgmtsToDeprecate;
	private static Map<Id, Account_Role_Detail_Capability__c> capabilitiesToUpdate;
	private static List<Id> capabilitiesInConflict;
	private static List<Id> capabilitiesToDelete;

	public CW_ICG_Acc_Role_Cap_Assignment_Handler() {
		this.newItems = (List<ICG_Account_Role_Capability_Assignment__c>) Trigger.new;
		execute();
	}

	// ## Execute the logic in right order
	private void execute() {
		if (Trigger.isBefore) {
			try {
				beforeBulk();
			} catch (Exception e) {
				addErrorGlobal('beforeBulk', e);
			}
			if (Trigger.isInsert) {
				for (ICG_Account_Role_Capability_Assignment__c currentItem : newItems) {
					beforeInsert(currentItem);
				}
			}
		}

		if (Trigger.isAfter) {
			try {
				afterFinally();
			} catch (Exception e) {
				addErrorGlobal('afterFinally', e);
			}
		}
	}

	// ## This method add errors to all records processed.
	private void addErrorGlobal(String key, Exception e) {
		for (ICG_Account_Role_Capability_Assignment__c currentItem : this.newItems) {
			currentItem.addError(key + ': ' + e.getMessage());
		}
	}

	private void beforeBulk() {
		// Initialize shared Objects
		asgmtGroups = new Map<Id, ICG_Capability_Assignment_Group__c>();
		detailCapabilities = new Map<Id, Account_Role_Detail_Capability__c>();
		asgmts = new Map<Id, ICG_Account_Role_Capability_Assignment__c>();
		asgmtGroupsByStationPrev = new Map<Id, List<Id>>();
		asgmtsByStationAndEquipmentPrev = new Map<String, List<Id>>();

		asgmtsToDeprecate = new Map<Id, ICG_Account_Role_Capability_Assignment__c>();
		capabilitiesToUpdate = new Map<Id, Account_Role_Detail_Capability__c>();
		capabilitiesInConflict = new List<Id>();
		capabilitiesToDelete = new List<Id>();

		// Get config data required
		multiRecordCapabilities = new List<String>();
		for (String currentCap : CW_FacilityCapabilitiesController.getMapConfig().get('Multi_Record_Capabilities')) {
			multiRecordCapabilities.add(currentCap.toLowerCase());
		}

		// Get all fields needed for the capabilities
		List<String> capabilityFields = new List<String>{ 'Photos__c' };
		for (List<String> fieldsGroup : CW_FacilityCapabilitiesController.getMapFieldsByRecordTypeAndCategory().values()) {
			for (String field : fieldsGroup) {
				if (!capabilityFields.contains(field)) {
					capabilityFields.add(field);
				}
			}
		}

		// Loop new ICG_Account_Role_Capability_Assignment__c to get Ids required for querys
		affectedStations = new List<Id>();
		Map<Id, Id> stationByAsgmtGroupsNew = new Map<Id, Id>();
		for (ICG_Account_Role_Capability_Assignment__c currentAssignment : newItems) {
			asgmtGroups.put(currentAssignment.ICG_Capability_Assignment_Group__c, null);
			detailCapabilities.put(currentAssignment.Account_Role_Detail_Capability__c, null);

			if (!affectedStations.contains(currentAssignment.ICG_Account_Role_Detail__c)) {
				affectedStations.add(currentAssignment.ICG_Account_Role_Detail__c);
			}

			if (!stationByAsgmtGroupsNew.containsKey(currentAssignment.ICG_Capability_Assignment_Group__c)) {
				stationByAsgmtGroupsNew.put(currentAssignment.ICG_Capability_Assignment_Group__c, currentAssignment.ICG_Account_Role_Detail__c);
			}
		}

		// Get the extra data linked to assignments or data to check
		//   PART 1: asgmtGroups(new), detailCapabilities - affectedEquipments
		asgmtGroups = new Map<Id, ICG_Capability_Assignment_Group__c>([SELECT Id, RecordType.DeveloperName, Expiration_Date__c, ICG_Certification__r.Certification_Type__c, ICG_Certification__r.Name FROM ICG_Capability_Assignment_Group__c WHERE Id IN :asgmtGroups.keySet()]);
		List<String> affectedEquipments = new List<String>();
		for (Account_Role_Detail_Capability__c currentCapability : (List<Account_Role_Detail_Capability__c>) Database.query(String.format('SELECT Id, {0} FROM Account_Role_Detail_Capability__c WHERE Id IN {1}', new List<String>{ String.join(capabilityFields, ','), '(\'' + String.join((List<String>) JSON.deserialize(JSON.serialize(detailCapabilities.keySet()), List<String>.class), '\',\'') + '\')' }))) {
			detailCapabilities.put(currentCapability.Id, currentCapability);
			if (!affectedEquipments.contains(currentCapability.Equipment__c.toLowerCase())) {
				affectedEquipments.add(currentCapability.Equipment__c.toLowerCase());
			}
		}

		//   PART 2: asgmtGroups(prev), detailCapabilities(prev), asgmts(prev) - asgmtGroupsByStationPrev, asgmtsByStationAndAsgmtGroupPrev, asgmtsByStationAndEquipmentPrev
		String dataToCheckQuery = String.format('SELECT Id, ICG_Account_Role_Detail__c, ICG_Capability_Assignment_Group__r.RecordType.DeveloperName, ICG_Capability_Assignment_Group__r.Expiration_Date__c, ICG_Capability_Assignment_Group__r.ICG_Certification__r.Certification_Type__c,ICG_Capability_Assignment_Group__r.ICG_Certification__r.Name, {0} FROM ICG_Account_Role_Capability_Assignment__c WHERE ICG_Account_Role_Detail__c IN {1} AND (Deprecated__c = false AND ICG_Capability_Assignment_Group__r.Expiration_Date__c > TODAY) ', new List<String>{ 'Account_Role_Detail_Capability__r.' + String.join(capabilityFields, ', Account_Role_Detail_Capability__r.'), '(\'' + String.join((List<String>) JSON.deserialize(JSON.serialize(affectedStations), List<String>.class), '\',\'') + '\')' });
		Map<String, List<Id>> asgmtsByStationAndAsgmtGroupPrev = new Map<String, List<Id>>();
		for (ICG_Account_Role_Capability_Assignment__c currentAssignment : (List<ICG_Account_Role_Capability_Assignment__c>) Database.query(dataToCheckQuery)) {
			asgmtGroups.put(currentAssignment.ICG_Capability_Assignment_Group__c, currentAssignment.ICG_Capability_Assignment_Group__r);
			detailCapabilities.put(currentAssignment.Account_Role_Detail_Capability__c, currentAssignment.Account_Role_Detail_Capability__r);
			asgmts.put(currentAssignment.Id, currentAssignment);

			// Get all previous assignment groups by station Id
			if (!stationByAsgmtGroupsNew.containsKey(currentAssignment.ICG_Capability_Assignment_Group__c)) {
				if (!asgmtGroupsByStationPrev.containsKey(currentAssignment.ICG_Account_Role_Detail__c)) {
					asgmtGroupsByStationPrev.put(currentAssignment.ICG_Account_Role_Detail__c, new List<Id>());
				}
				if (!asgmtGroupsByStationPrev.get(currentAssignment.ICG_Account_Role_Detail__c).contains(currentAssignment.ICG_Capability_Assignment_Group__c)) {
					asgmtGroupsByStationPrev.get(currentAssignment.ICG_Account_Role_Detail__c).add(currentAssignment.ICG_Capability_Assignment_Group__c);
				}
			}

			// Get all previous assignments by Station#AssignmentGroup for massive deprecate
			String stationAndAsgmtGroupKey = currentAssignment.ICG_Account_Role_Detail__c + '#' + currentAssignment.ICG_Capability_Assignment_Group__c;
			if (!asgmtsByStationAndAsgmtGroupPrev.containsKey(stationAndAsgmtGroupKey)) {
				asgmtsByStationAndAsgmtGroupPrev.put(stationAndAsgmtGroupKey, new List<Id>());
			}
			asgmtsByStationAndAsgmtGroupPrev.get(stationAndAsgmtGroupKey).add(currentAssignment.Id);

			// Get all previous assignments of same type that just created by Station#Equipment
			String stationAndEquipmentKey = currentAssignment.ICG_Account_Role_Detail__c + '#' + currentAssignment.Account_Role_Detail_Capability__r.Equipment__c.toLowerCase();
			if (affectedEquipments.contains(currentAssignment.Account_Role_Detail_Capability__r.Equipment__c.toLowerCase())) {
				if (!asgmtsByStationAndEquipmentPrev.containsKey(stationAndEquipmentKey)) {
					asgmtsByStationAndEquipmentPrev.put(stationAndEquipmentKey, new List<Id>());
				}
				asgmtsByStationAndEquipmentPrev.get(stationAndEquipmentKey).add(currentAssignment.Id);
			}
		}

		// DEPRECATE FLOW - STEP 1
		// Is there a previous certification(same type) / remote validation?
		for (Id asgmtGroupNewId : stationByAsgmtGroupsNew.keySet()) {
			ICG_Capability_Assignment_Group__c asgmtGroupNew = asgmtGroups.get(asgmtGroupNewId);
			Id stationId = stationByAsgmtGroupsNew.get(asgmtGroupNewId);
			if (asgmtGroupsByStationPrev.containsKey(stationId)) {
				for (Id asgmtGroupPrevId : asgmtGroupsByStationPrev.get(stationId)) {
					ICG_Capability_Assignment_Group__c asgmtGroupPrev = asgmtGroups.get(asgmtGroupPrevId);

					if (
						asgmtGroupPrev.RecordType == asgmtGroupNew.RecordType &&
						(asgmtGroupPrev.ICG_Certification__c == null || // Remote Validation
						asgmtGroupPrev.ICG_Certification__r.Name == asgmtGroupNew.ICG_Certification__r.Name) // Certification of same type
					) {
						// * Yes: Deprecate all ICG Account Role Capability Assignment linked to previous Certification / Remote Validation
						for (Id asgmtFoundToDeprecateId : asgmtsByStationAndAsgmtGroupPrev.get(stationId + '#' + asgmtGroupPrev.Id)) {
							asgmtsToDeprecate.put(asgmts.get(asgmtFoundToDeprecateId).Id, new ICG_Account_Role_Capability_Assignment__c(Id = asgmts.get(asgmtFoundToDeprecateId).Id, Deprecated__c = true));

							// Remove deprecated assignments from asgmtsByStationAndEquipmentPrev
							String stationAndEquipmentKey = stationId + '#' + detailCapabilities.get(asgmts.get(asgmtFoundToDeprecateId).Account_Role_Detail_Capability__c).Equipment__c.toLowerCase();
							if (asgmtsByStationAndEquipmentPrev.containsKey(stationAndEquipmentKey) && asgmtsByStationAndEquipmentPrev.get(stationAndEquipmentKey).contains(asgmts.get(asgmtFoundToDeprecateId).Id)) {
								asgmtsByStationAndEquipmentPrev.get(stationAndEquipmentKey).remove(asgmtsByStationAndEquipmentPrev.get(stationAndEquipmentKey).indexOf(asgmts.get(asgmtFoundToDeprecateId).Id));
							}
						}
					}
				}
			}
		}
	}
	private void beforeInsert(ICG_Account_Role_Capability_Assignment__c data) {
		if (detailCapabilities.get(data.Account_Role_Detail_Capability__c) == null) {
			return;
		}
		// First creation. No conflicts. Exit
		if (!asgmtGroupsByStationPrev.containsKey(data.ICG_Account_Role_Detail__c)) {
			return;
		}

		// DEPRECATE FLOW - STEP 2
		// Is there a previous Account Role Detail Capability with the same specific equipment for the same station and different Remote Validation or Certifications?
		//  * No: end process
		String stationAndEquipmentKey = data.ICG_Account_Role_Detail__c + '#' + detailCapabilities.get(data.Account_Role_Detail_Capability__c).Equipment__c.toLowerCase();
		if (!asgmtsByStationAndEquipmentPrev.containsKey(stationAndEquipmentKey) || asgmtsByStationAndEquipmentPrev.get(stationAndEquipmentKey).size() == 0) {
			return;
		}
		//  * Yes:
		Map<Id, Account_Role_Detail_Capability__c> prevCapabilities = new Map<Id, Account_Role_Detail_Capability__c>();
		for (Id currentAsgmtId : asgmtsByStationAndEquipmentPrev.get(stationAndEquipmentKey)) {
			Account_Role_Detail_Capability__c capabilityFound = detailCapabilities.get(asgmts.get(currentAsgmtId).Account_Role_Detail_Capability__c);
			if (!prevCapabilities.containsKey(capabilityFound.Id)) {
				prevCapabilities.put(capabilityFound.Id, capabilityFound);
			}
		}

		if (multiRecordCapabilities.contains(stationAndEquipmentKey.split('#')[1])) {
			List<String> idsInConflict = new List<String>();
			for (Account_Role_Detail_Capability__c prevCapabilityInConflict : prevCapabilities.values()) {
				if (!capabilitiesInConflict.contains(prevCapabilityInConflict.Id)) {
					capabilitiesInConflict.add(prevCapabilityInConflict.Id);
				}
				if (!idsInConflict.contains(prevCapabilityInConflict.Id)) {
					idsInConflict.add(prevCapabilityInConflict.Id);
				}
			}
			data.Is_In_Conflict__c = true;
			data.In_Conflict_With__c = JSON.serialize(idsInConflict);
		} else {
			// Set the new capability to be deleted
			capabilitiesToDelete.add(data.Account_Role_Detail_Capability__c);

			// Use the new capability to update the previous capability
			Account_Role_Detail_Capability__c updatedPrevCapability = detailCapabilities.get(data.Account_Role_Detail_Capability__c);
			updatedPrevCapability.Id = prevCapabilities.values()[0].Id;
			capabilitiesToUpdate.put(updatedPrevCapability.Id, updatedPrevCapability);

			// Re-parent to the previous capability
			data.Account_Role_Detail_Capability__c = prevCapabilities.values()[0].Id;
		}
	}
	private void afterFinally() {
		if (asgmtsToDeprecate.size() > 0) {
			Database.update(asgmtsToDeprecate.values());
		}
		if (capabilitiesToUpdate.size() > 0) {
			Database.update(capabilitiesToUpdate.values());
		}
		if (capabilitiesToDelete.size() > 0) {
			Database.delete(capabilitiesToDelete);
		}

		if(affectedStations.size() == 1){

			ICG_Account_Role_Detail__c station = [Select Id, Account_Role__r.Account__c from ICG_Account_Role_Detail__c where Id=:affectedStations[0]];

			List<ICG_Notification__c> notifications = new List<ICG_Notification__c>();

			List<String> contactIds = new List<String>();
			for(Contact c : CW_Utilities.getCompanyadminContactsFromAccountId(station.Account_Role__r.Account__c)){
				contactIds.add(c.Id);
			}
	
			String subject = 'Some capabilities are in conflict and needs to be handled manually';
			String body = subject;
			notifications.addAll(CW_NotificationsController.setNotificationCustom(subject, body, 'Requested', contactIds, station, CW_NotificationsController.RT_NOTIFICATION_PRIVATE_AREA, false));
				
			
			if(notifications.size() > 0){
				Database.insert(notifications);
			}
		}
	}
}