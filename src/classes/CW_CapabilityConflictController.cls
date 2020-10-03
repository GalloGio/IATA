/**
 * @description		Controller for retreiving relevant capability data for handling capability conflicts
 *
 * Edit Log:
 * @history			2020/06/02  |  sf-680  |  Creation.
 */
public without sharing class CW_CapabilityConflictController {
	public enum ConflictAction {
		NONE,
		STATUS_ADD,
		STATUS_REMOVE,
		STATUS_REPLACE,
		STATUS_MAINTAIN,
		STATUS_TO_BE_REPLACED_BY
	}

	private static ConflictAction extractEnumValueByString(String rType) {
		ConflictAction reportTypeMatch = ConflictAction.NONE;

		for (ConflictAction rt : ConflictAction.values()) {
			if (rt.name() == rType) {
				reportTypeMatch = rt;
				break;
			}
		}

		return reportTypeMatch;
	}

	/**
	 * @description		Parsing handled capabilities and solving conflicts. Updating objects in db
	 * @param			handledCapabilitiesJSON <List of handled capabilities>
	 * @return			Response containing success indicator and result message
	 */
	@AuraEnabled
	public static string solveCapabilityConflicts(String handledCapabilitiesJSON) {
		Savepoint sp;
		CW_Utilities.ResponseBody res = new CW_Utilities.ResponseBody();

		List<ICG_Account_Role_Capability_Assignment__c> assignmentsToUpsert = new List<ICG_Account_Role_Capability_Assignment__c>();
		List<ICG_Account_Role_Capability_Assignment__c> assignmentsToDelete = new List<ICG_Account_Role_Capability_Assignment__c>();
		

		List<HandledCapability> handledCapabilities = (List<HandledCapability>) JSON.deserialize(handledCapabilitiesJSON, List<HandledCapability>.class);

		Set<Id> capabilitiesAdd = new Set<Id>();
		Set<Id> capabilitiesRemove = new Set<Id>();
		Map<Id, Id> capabilitiesReplacementMap = new Map<Id, Id>();

		try {
			for (HandledCapability handledCapability : handledCapabilities) {
				ConflictAction action = extractEnumValueByString(handledCapability.action);

				if (action == ConflictAction.STATUS_ADD) {
					capabilitiesAdd.add(handledCapability.id);
				} else if (action == ConflictAction.STATUS_REPLACE) {
					capabilitiesReplacementMap.put(handledCapability.id, handledCapability.target);
				} else if (action == ConflictAction.STATUS_REMOVE) {
					capabilitiesRemove.add(handledCapability.id);
				}
			}

			Set<Id> combinedCapabilities = new Set<Id>();
			combinedCapabilities.addAll(capabilitiesAdd);
			combinedCapabilities.addAll(capabilitiesReplacementMap.keySet());
			combinedCapabilities.addAll(capabilitiesRemove);
			combinedCapabilities.addAll(capabilitiesReplacementMap.values());

			for (ICG_Account_Role_Capability_Assignment__c assignment : [SELECT Id, In_Conflict_With__c, Account_Role_Detail_Capability__c, Is_In_Conflict__c FROM ICG_Account_Role_Capability_Assignment__c WHERE Account_Role_Detail_Capability__c IN :combinedCapabilities]) {
				Id capabilityId = assignment.Account_Role_Detail_Capability__c;
				if (combinedCapabilities.contains(capabilityId)) {
					if (capabilitiesAdd.contains(capabilityId)) {
						assignment.In_Conflict_With__c = '';
						assignment.Is_In_Conflict__c = false;
						assignmentsToUpsert.add(assignment);
					} else if (capabilitiesReplacementMap.containsKey(capabilityId)) {
						assignment.Account_Role_Detail_Capability__c = capabilitiesReplacementMap.get(capabilityId);
						assignment.In_Conflict_With__c = '';
						assignment.Is_In_Conflict__c = false;
						assignmentsToUpsert.add(assignment);
					}
					else if(capabilitiesRemove.contains(capabilityId) ){
						assignmentsToDelete.add(assignment);
					}
				}
			}

			Set<Id> combinedCapabilityIdsToHandle = new Set<Id>();
			combinedCapabilityIdsToHandle.addAll(capabilitiesReplacementMap.keySet());
			combinedCapabilityIdsToHandle.addAll(capabilitiesReplacementMap.values());

			Map<Id, Account_Role_Detail_Capability__c> capabilitiesToHandle = generateCapabiltiesToHandleMap(combinedCapabilityIdsToHandle);
			List<Account_Role_Detail_Capability__c> capabilitiesToUpsert = replaceCapabilities(capabilitiesToHandle, capabilitiesReplacementMap);
			List<Account_Role_Detail_Capability__c> capabilitiesToDelete = generateCapabilitiesToDelete(capabilitiesToHandle, capabilitiesReplacementMap.keySet());


			sp = CW_DBTransactionHandler.setSavepoint();
			if (!assignmentsToUpsert.isEmpty()) {
				upsert assignmentsToUpsert;
			}

			if (!capabilitiesToUpsert.isEmpty()) {
				upsert capabilitiesToUpsert;
			}

			if (!assignmentsToDelete.isEmpty()) {
				Database.delete(assignmentsToDelete, false);
			}

			if (!capabilitiesToDelete.isEmpty()) {
				Database.delete(capabilitiesToDelete, false);
			}

			

			res.success = true;
			res.message = 'Conflicting capabilities have been handled';
			return JSON.serialize(res);
		} catch (Exception exc) {
			CW_DBTransactionHandler.doRollback(sp);
			throw new AuraHandledException('exception: ' + exc);
		}
	}

	/**
	 * @description		Returns all valid assignments belonging to a certain station and is in conflict
	 * @param			stationId <The id of the station>
	 * @return			List of assignments
	 */
	@AuraEnabled
	public static List<ICG_Account_Role_Capability_Assignment__c> getConflictCapabilities(String stationId) {
		if (stationId == null || stationId == '') {
			return new List<ICG_Account_Role_Capability_Assignment__c>();
		}

		return [SELECT Id, In_Conflict_With__c, Account_Role_Detail_Capability__c FROM ICG_Account_Role_Capability_Assignment__c WHERE ICG_Capability_Assignment_Group__r.Is_Active__c = true AND Is_In_Conflict__c = true AND ICG_Account_Role_Detail__c = :stationId];
	}

	private static List<Account_Role_Detail_Capability__c> generateCapabilitiesToDelete(Map<Id, Account_Role_Detail_Capability__c> capabilitiesToHandle, Set<Id> capabilityIdsToDelete) {
		List<Account_Role_Detail_Capability__c> capabilitiesToDelete = new List<Account_Role_Detail_Capability__c>();

		for (Id capabilityId : capabilityIdsToDelete) {
			Account_Role_Detail_Capability__c capabilityToDelete = new Account_Role_Detail_Capability__c();
			capabilityToDelete.Id = capabilityId;
			capabilitiesToDelete.add(capabilityToDelete);
		}

		return capabilitiesToDelete;
	}

	private static Map<Id, Account_Role_Detail_Capability__c> generateCapabiltiesToHandleMap(Set<Id> combinedCapabilityIdsToHandle) {
		Map<Id, Account_Role_Detail_Capability__c> capabilitiesToHandle = new Map<Id, Account_Role_Detail_Capability__c>();
		Map<String, Schema.SObjectField> fieldMap = Account_Role_Detail_Capability__c.sObjectType.getDescribe().fields.getMap();
		Set<String> fieldNames = fieldMap.keySet();
		List<Account_Role_Detail_Capability__c> capabilities = Database.query('select ' + String.join(new List<String>(fieldNames), ', ') + ' from Account_Role_Detail_Capability__c where Id in: combinedCapabilityIdsToHandle');
		for (Account_Role_Detail_Capability__c capability : capabilities) {
			capabilitiesToHandle.put(capability.Id, capability);
		}
		return capabilitiesToHandle;
	}

	private static List<Account_Role_Detail_Capability__c> replaceCapabilities(Map<Id, Account_Role_Detail_Capability__c> capabilitiesToHandle, Map<Id, Id> capabilitiesReplacementMap) {
		List<Account_Role_Detail_Capability__c> capabilitiesToUpsert = new List<Account_Role_Detail_Capability__c>();

		for (Id capabilityId : capabilitiesReplacementMap.keySet()) {
			Id capabilityToBeReplacedId = capabilitiesReplacementMap.get(capabilityId);
			Account_Role_Detail_Capability__c originalCapability = capabilitiesToHandle.get(capabilityId);
			if(originalCapability != null) {
				originalCapability.Id = capabilityToBeReplacedId;
				capabilitiesToUpsert.add(originalCapability);
			}
		}

		return capabilitiesToUpsert;
	}

	public class HandledCapability {
		@AuraEnabled
		public Id id { get; set; }
		@AuraEnabled
		public String action { get; set; }
		@AuraEnabled
		public Id target { get; set; }

		public HandledCapability(Id id, String action, Id target) {
			this.id = id;
			this.action = action;
			this.target = target;
		}
	}
}