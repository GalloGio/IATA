/**
 * @description Handler used by the trigger ICG_Account_Role_Capability_Assignment to execute the capabilities deprecation flow
 */
public with sharing class CW_ICG_Acc_Role_Cap_Assignment_Handler {
	private List<ICG_Account_Role_Capability_Assignment__c> newItems;

	// Shared data required for deprecation flow
	private static Map<Id, ICG_Account_Role_Capability_Assignment__c> asgmtsData;
	private static Map<Id, ICG_Capability_Assignment_Group__c> asgmtGroupsData;
	private static Map<Id, Account_Role_Detail_Capability__c> capabilitiesData;

	private static List<Id> affectedStations;
	private static Map<String, List<Id>> previousAsgmtsByStationAndEquipment;
	private static List<String> multiRecordCapabilities;

	private static List<Id> affectedCapabilities;
	private static List<Id> capabilitiesToDelete;
	private static Map<Id, Account_Role_Detail_Capability__c> capabilitiesToUpdate;
	private static List<Id> capabilitiesInConflict;

	public CW_ICG_Acc_Role_Cap_Assignment_Handler() {
		this.newItems = (List<ICG_Account_Role_Capability_Assignment__c>) Trigger.new;
	}

	public void prepareBeforeInsert(){
		beforeInsertBulk();
		for (ICG_Account_Role_Capability_Assignment__c currentItem : newItems) {
			beforeInsert(currentItem);
		}
	}

	private void initializeSharedData(){
		asgmtsData = new Map<Id, ICG_Account_Role_Capability_Assignment__c>();
		asgmtGroupsData = new Map<Id, ICG_Capability_Assignment_Group__c>();
		capabilitiesData = new Map<Id, Account_Role_Detail_Capability__c>();

		affectedStations = new List<Id>();
		previousAsgmtsByStationAndEquipment = new Map<String, List<Id>>();
		multiRecordCapabilities = new List<String>();
		for (String currentCap : CW_FacilityCapabilitiesController.getMapConfig().get('Multi_Record_Capabilities')) {
			multiRecordCapabilities.add(currentCap.toLowerCase());
		}

		affectedCapabilities = new List<Id>();
		capabilitiesToDelete = new List<Id>();
		capabilitiesToUpdate = new Map<Id, Account_Role_Detail_Capability__c>();
		capabilitiesInConflict = new List<Id>();
	}

	private void mapIdsOfNewRecords(Map<Id, Id> stationByAsgmtGroupsNew){
		for (ICG_Account_Role_Capability_Assignment__c currentAssignment : newItems) {
			asgmtGroupsData.put(currentAssignment.ICG_Capability_Assignment_Group__c, null);
			capabilitiesData.put(currentAssignment.Account_Role_Detail_Capability__c, null);

			if (!affectedStations.contains(currentAssignment.ICG_Account_Role_Detail__c)) {
				affectedStations.add(currentAssignment.ICG_Account_Role_Detail__c);
			}

			if (!affectedCapabilities.contains(currentAssignment.Account_Role_Detail_Capability__c)) {
				affectedCapabilities.add(currentAssignment.Account_Role_Detail_Capability__c);
			}

			if (!stationByAsgmtGroupsNew.containsKey(currentAssignment.ICG_Capability_Assignment_Group__c)) {
				stationByAsgmtGroupsNew.put(currentAssignment.ICG_Capability_Assignment_Group__c, currentAssignment.ICG_Account_Role_Detail__c);
			}
		}
	}

	private void getPreviousAssignments(List<String> affectedEquipments, List<String> capabilityFields){
		String query = String.format(
			'SELECT Id, ICG_Account_Role_Detail__c, ICG_Capability_Assignment_Group__r.RecordType.DeveloperName, {0} FROM ICG_Account_Role_Capability_Assignment__c ' + 
			'WHERE ICG_Capability_Assignment_Group__r.Status__c IN {3} AND ICG_Account_Role_Detail__c IN {1} AND Account_Role_Detail_Capability__r.Equipment__c IN {2}', 
			new List<String>{
				'Account_Role_Detail_Capability__r.' + String.join(capabilityFields, ', Account_Role_Detail_Capability__r.'),
				'(\'' + String.join((List<String>) JSON.deserialize(JSON.serialize(affectedStations), List<String>.class), '\',\'') + '\')',
				'(\'' + String.join((List<String>) JSON.deserialize(JSON.serialize(affectedEquipments), List<String>.class), '\',\'') + '\')',
				'(\'' + String.join((List<String>) JSON.deserialize(JSON.serialize(new List<String>{'Active'}), List<String>.class), '\',\'') + '\')'});
		for (ICG_Account_Role_Capability_Assignment__c currentAssignment : (List<ICG_Account_Role_Capability_Assignment__c>) Database.query(query)) {
			asgmtsData.put(currentAssignment.Id, currentAssignment);
			asgmtGroupsData.put(currentAssignment.ICG_Capability_Assignment_Group__c, currentAssignment.ICG_Capability_Assignment_Group__r);
			capabilitiesData.put(currentAssignment.Account_Role_Detail_Capability__c, currentAssignment.Account_Role_Detail_Capability__r);

			if (!affectedCapabilities.contains(currentAssignment.Account_Role_Detail_Capability__c)) {
				String stationAndEquipmentKey = currentAssignment.ICG_Account_Role_Detail__c + '#' + currentAssignment.Account_Role_Detail_Capability__r.Equipment__c.toLowerCase();
				if (!previousAsgmtsByStationAndEquipment.containsKey(stationAndEquipmentKey)) {
					previousAsgmtsByStationAndEquipment.put(stationAndEquipmentKey, new List<Id>());
				}
				previousAsgmtsByStationAndEquipment.get(stationAndEquipmentKey).add(currentAssignment.Id);
			}
		}
	}

	private void getGroupAndCapabilityData(List<String> affectedEquipments, List<String> capabilityFields){
		asgmtGroupsData = new Map<Id, ICG_Capability_Assignment_Group__c>([SELECT Id, RecordType.DeveloperName FROM ICG_Capability_Assignment_Group__c WHERE Id IN :asgmtGroupsData.keySet()]);
		String query = String.format('SELECT Id, {0} FROM Account_Role_Detail_Capability__c WHERE Id IN {1}', new List<String>{ String.join(capabilityFields, ','), '(\'' + String.join((List<String>) JSON.deserialize(JSON.serialize(capabilitiesData.keySet()), List<String>.class), '\',\'') + '\')' });
		for (Account_Role_Detail_Capability__c currentCapability : (List<Account_Role_Detail_Capability__c>) Database.query(query)) {
			capabilitiesData.put(currentCapability.Id, currentCapability);
			if (!affectedEquipments.contains(currentCapability.Equipment__c.toLowerCase())) {
				affectedEquipments.add(currentCapability.Equipment__c.toLowerCase());
			}
		}
	}

	private void beforeInsertBulk() {
		initializeSharedData();
		
		Map<Id, Id> stationByAsgmtGroupsNew = new Map<Id, Id>();
		List<String> affectedEquipments = new List<String>();
		List<String> capabilityFields = getCapabilityFields();

		mapIdsOfNewRecords(stationByAsgmtGroupsNew);
		getGroupAndCapabilityData(affectedEquipments, capabilityFields);
		getPreviousAssignments(affectedEquipments, capabilityFields);
	}
	private void beforeInsert(ICG_Account_Role_Capability_Assignment__c data) {

		String stationAndEquipmentKey = capabilitiesData.get(data.Account_Role_Detail_Capability__c) != null ? data.ICG_Account_Role_Detail__c + '#' + capabilitiesData.get(data.Account_Role_Detail_Capability__c).Equipment__c.toLowerCase() : '';


		// Capability not defined. Exit
		if (capabilitiesData.get(data.Account_Role_Detail_Capability__c) == null || !previousAsgmtsByStationAndEquipment.containsKey(stationAndEquipmentKey) || previousAsgmtsByStationAndEquipment.get(stationAndEquipmentKey).size() == 0) {
			return;
		}

		// Is there one or more active capabilities with the same equipment for the same station? Continue
		Map<Id, Account_Role_Detail_Capability__c> prevCapabilities = new Map<Id, Account_Role_Detail_Capability__c>();
		for (Id currentAsgmtId : previousAsgmtsByStationAndEquipment.get(stationAndEquipmentKey)) {
			Account_Role_Detail_Capability__c capabilityFound = capabilitiesData.get(asgmtsData.get(currentAsgmtId).Account_Role_Detail_Capability__c);
			if (!prevCapabilities.containsKey(capabilityFound.Id)) {
				prevCapabilities.put(capabilityFound.Id, capabilityFound);
			}
		}

		if (!multiRecordCapabilities.contains(stationAndEquipmentKey.split('#')[1])) {
			// No multi-record
			// The new capability will be deleted
			capabilitiesToDelete.add(data.Account_Role_Detail_Capability__c);

			// Use the values of the new one to update the old one
			Account_Role_Detail_Capability__c updatedPrevCapability = capabilitiesData.get(data.Account_Role_Detail_Capability__c);
			updatedPrevCapability.Id = prevCapabilities.values()[0].Id;
			capabilitiesToUpdate.put(updatedPrevCapability.Id, updatedPrevCapability);

			// Re-parent the new assignment to the previous capability
			data.Account_Role_Detail_Capability__c = prevCapabilities.values()[0].Id;
		} else if (multiRecordCapabilities.contains(stationAndEquipmentKey.split('#')[1]) && asgmtGroupsData.get(data.ICG_Capability_Assignment_Group__c).RecordType.DeveloperName.toLowerCase() == 'remote_validation') {
			// It is multi-record && Remote Validation, generate conflicts
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
		}
	}

	public void afterInsertFinally() {
		if (!capabilitiesToUpdate.isEmpty()) {
			Database.update(capabilitiesToUpdate.values());
		}
		if (!capabilitiesToDelete.isEmpty()) {
			Database.delete(capabilitiesToDelete);
		}

		if (affectedStations.size() == 1) {
			ICG_Account_Role_Detail__c station = [SELECT Id, Account_Role__r.Account__c FROM ICG_Account_Role_Detail__c WHERE Id = :affectedStations[0]];

			List<ICG_Notification__c> notifications = new List<ICG_Notification__c>();

			List<String> contactIds = new List<String>();
			for (Contact c : CW_Utilities.getCompanyAdminContactsFromAccountId(station.Account_Role__r.Account__c)) {
				contactIds.add(c.Id);
			}

			if(!capabilitiesInConflict.isEmpty()){
				String subject = 'Some capabilities are in conflict and need to be handled manually';
				String body = subject;
				notifications.addAll(CW_NotificationsController.setNotificationCustom(subject, body, 'Requested', contactIds, station, CW_NotificationsController.RT_NOTIFICATION_PRIVATE_AREA, false));
	
				if (!notifications.isEmpty()) {
					Database.insert(notifications);
				}
			}
		}
	}

	private List<String> getCapabilityFields() {
		List<String> capabilityFields = new List<String>{ 'Photos__c' };
		for (List<String> fieldsGroup : CW_FacilityCapabilitiesController.getMapFieldsByRecordTypeAndCategory().values()) {
			for (String field : fieldsGroup) {
				if (!capabilityFields.contains(field)) {
					capabilityFields.add(field);
				}
			}
		}
		return capabilityFields;
	}
}