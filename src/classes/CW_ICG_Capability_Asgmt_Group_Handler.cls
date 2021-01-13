public without sharing class CW_ICG_Capability_Asgmt_Group_Handler {
	// Data required for deprecation flow
	private static Map<Id, ICG_Account_Role_Detail__c> accRoleDetailAffectedMap;
	private static Map<Id, ICG_Certification__c> certificationsAffectedMap;
	private static List<Id> asgmtGroupWithCertification;

	private static List<String> keysToDeactivate;

	public static void handleBulkBefore(List<ICG_Capability_Assignment_Group__c> newItems) {
		// Initialize shared data
		accRoleDetailAffectedMap = new Map<Id, ICG_Account_Role_Detail__c>();
		asgmtGroupWithCertification = new List<Id>();
		certificationsAffectedMap = new Map<Id, ICG_Certification__c>();
		keysToDeactivate = new List<String>();

		for (ICG_Capability_Assignment_Group__c item : newItems) {
			accRoleDetailAffectedMap.put(item.ICG_Account_Role_Detail__c, null);
			if (item.ICG_Certification__c != null) {
				if (!asgmtGroupWithCertification.contains(item.Id)) {
					asgmtGroupWithCertification.add(item.Id);
				}
				certificationsAffectedMap.put(item.ICG_Certification__c, null);
			}
		}
		if (!accRoleDetailAffectedMap.isEmpty()) {
			accRoleDetailAffectedMap = new Map<Id, ICG_Account_Role_Detail__c>([SELECT Id, Airmail__c, Dangerous_Goods__c, General_Cargo__c, Live_Animals__c, Perishables__c, Pharmaceuticals__c FROM ICG_Account_Role_Detail__c WHERE Id IN :accRoleDetailAffectedMap.keySet()]);
		}
		if (!certificationsAffectedMap.isEmpty()) {
			certificationsAffectedMap = new Map<Id, ICG_Certification__c>([SELECT Id, Name FROM ICG_Certification__c WHERE Id IN :certificationsAffectedMap.keySet()]);
		}
	}
	public static void handleBeforeInsert(List<ICG_Capability_Assignment_Group__c> newItems) {
		setCalculatedFieldsInAsgmtGroup(null, newItems);
	}
	public static void handleAfterInsert(Map<Id, ICG_Capability_Assignment_Group__c> newMap) {
		updateCargoCommodities(newMap);
		// deprecateOldAsgmtGroupWithoutChildren(newMap);
		deactivateAsgmtGroupRecords(newMap.keySet());
	}

	public static void handleBeforeUpdate(Map<Id, ICG_Capability_Assignment_Group__c> oldMap, List<ICG_Capability_Assignment_Group__c> newItems) {
		setCalculatedFieldsInAsgmtGroup(oldMap, newItems);
	}
	public static void handleAfterUpdate(Map<Id, ICG_Capability_Assignment_Group__c> oldMap, Map<Id, ICG_Capability_Assignment_Group__c> newMap) {
		updateCargoCommodities(newMap);
		deactivateAsgmtGroupRecords(newMap.keySet());
	}

	public static void updateCargoCommodities(Map<Id, ICG_Capability_Assignment_Group__c> newMap) {
		Map<Id, ICG_Account_Role_Detail__c> accsRoleDetailToUpdate = new Map<Id, ICG_Account_Role_Detail__c>();
		for (Id asgmGroupId : asgmtGroupWithCertification) {
			if (newMap.containsKey(asgmGroupId)) {
				ICG_Capability_Assignment_Group__c currentAsgmtGroup = newMap.get(asgmGroupId);
				Id currentArdId = newMap.get(asgmGroupId).ICG_Account_Role_Detail__c;

				switch on certificationsAffectedMap.get(newMap.get(asgmGroupId).ICG_Certification__c).Name {
					when 'ceiv_pharma' {
						if (accRoleDetailAffectedMap.get(currentArdId).Pharmaceuticals__c != true) {
							accRoleDetailAffectedMap.get(currentArdId).Pharmaceuticals__c = true;
							accsRoleDetailToUpdate.put(accRoleDetailAffectedMap.get(currentArdId).Id, accRoleDetailAffectedMap.get(currentArdId));
						}
					}
					when 'ceiv_live_animals' {
						if (accRoleDetailAffectedMap.get(currentArdId).Live_Animals__c != true) {
							accRoleDetailAffectedMap.get(currentArdId).Live_Animals__c = true;
							accsRoleDetailToUpdate.put(accRoleDetailAffectedMap.get(currentArdId).Id, accRoleDetailAffectedMap.get(currentArdId));
						}
					}
					when 'ceiv_fresh' {
						if (accRoleDetailAffectedMap.get(currentArdId).Perishables__c != true) {
							accRoleDetailAffectedMap.get(currentArdId).Perishables__c = true;
							accsRoleDetailToUpdate.put(accRoleDetailAffectedMap.get(currentArdId).Id, accRoleDetailAffectedMap.get(currentArdId));
						}
					}
					when 'smart_facility_operational_capacity' {
						if (String.isNotBlank(currentAsgmtGroup.SFOC_Scope__c)) {
							for (String currentScope : currentAsgmtGroup.SFOC_Scope__c.split(';')) {
								switch on currentScope {
									when 'General Cargo' {
										if (accRoleDetailAffectedMap.get(currentArdId).General_Cargo__c != true) {
											accRoleDetailAffectedMap.get(currentArdId).General_Cargo__c = true;
											accsRoleDetailToUpdate.put(accRoleDetailAffectedMap.get(currentArdId).Id, accRoleDetailAffectedMap.get(currentArdId));
										}
									}
									when 'Dangerous Goods' {
										if (accRoleDetailAffectedMap.get(currentArdId).Dangerous_Goods__c != true) {
											accRoleDetailAffectedMap.get(currentArdId).Dangerous_Goods__c = true;
											accsRoleDetailToUpdate.put(accRoleDetailAffectedMap.get(currentArdId).Id, accRoleDetailAffectedMap.get(currentArdId));
										}
									}
									when 'Live Animals' {
										if (accRoleDetailAffectedMap.get(currentArdId).Live_Animals__c != true) {
											accRoleDetailAffectedMap.get(currentArdId).Live_Animals__c = true;
											accsRoleDetailToUpdate.put(accRoleDetailAffectedMap.get(currentArdId).Id, accRoleDetailAffectedMap.get(currentArdId));
										}
									}
									when 'Pharmaceuticals' {
										if (accRoleDetailAffectedMap.get(currentArdId).Pharmaceuticals__c != true) {
											accRoleDetailAffectedMap.get(currentArdId).Pharmaceuticals__c = true;
											accsRoleDetailToUpdate.put(accRoleDetailAffectedMap.get(currentArdId).Id, accRoleDetailAffectedMap.get(currentArdId));
										}
									}
									when 'Perishables' {
										if (accRoleDetailAffectedMap.get(currentArdId).Perishables__c != true) {
											accRoleDetailAffectedMap.get(currentArdId).Perishables__c = true;
											accsRoleDetailToUpdate.put(accRoleDetailAffectedMap.get(currentArdId).Id, accRoleDetailAffectedMap.get(currentArdId));
										}
									}
									when 'Airmail' {
										if (accRoleDetailAffectedMap.get(currentArdId).Airmail__c != true) {
											accRoleDetailAffectedMap.get(currentArdId).Airmail__c = true;
											accsRoleDetailToUpdate.put(accRoleDetailAffectedMap.get(currentArdId).Id, accRoleDetailAffectedMap.get(currentArdId));
										}
									}
								}
							}
						}
					}
				}
			}
		}
		if (!accsRoleDetailToUpdate.isEmpty()) {
			update accsRoleDetailToUpdate.values();
		}
	}

	public static void setCalculatedFieldsInAsgmtGroup(Map<Id, ICG_Capability_Assignment_Group__c> oldMap, List<ICG_Capability_Assignment_Group__c> newItems) {
		Map<String, List<ICG_Capability_Assignment_Group__c>> asgmtGroupProcessed = new Map<String, List<ICG_Capability_Assignment_Group__c>>();

		for (ICG_Capability_Assignment_Group__c item : newItems) {
			String currentKey = item.ICG_Account_Role_Detail__c + '#' + item.RecordTypeId + '#' + item.ICG_Certification__c;

			// Check if the group is active (Today between issue date and expiration date)
			if (oldMap == null || oldMap.get(item.Id).Issue_Date__c != item.Issue_Date__c || oldMap.get(item.Id).Expiration_Date__c != item.Expiration_Date__c) {
				if (!asgmtGroupProcessed.containsKey(currentKey)) {
					asgmtGroupProcessed.put(currentKey, new List<ICG_Capability_Assignment_Group__c>());
				}

				if (Date.today() >= item.Issue_Date__c && Date.today() <= item.Expiration_Date__c) {
					item.Is_Active__c = true;

					if (!asgmtGroupProcessed.get(currentKey).isEmpty()) {
						asgmtGroupProcessed.get(currentKey)[asgmtGroupProcessed.get(currentKey).size() - 1].Is_Active__c = false;
					}
					asgmtGroupProcessed.get(currentKey).add(item);
				} else {
					item.Is_Active__c = false;
					if (asgmtGroupProcessed.get(currentKey).isEmpty()) {
						asgmtGroupProcessed.get(currentKey).add(item);
					} else {
						asgmtGroupProcessed.get(currentKey).add(0, item);
					}
				}
			}

			// Check if the group is expired (Today > expiration date)
			if (oldMap == null || oldMap.get(item.Id).Expiration_Date__c != item.Expiration_Date__c) {
				item.Is_Expired__c = (Date.today() > item.Expiration_Date__c);
			}

			// Force not active if expired
			if (item.Is_Expired__c == true) {
				item.Is_Active__c = false;
			}

			// If Is_Active__c has been changed to true, deactivate others active of same type.
			if ((oldMap == null || oldMap.get(item.Id).Is_Active__c != item.Is_Active__c) && item.Is_Active__c == true && !keysToDeactivate.contains(currentKey)) {
				keysToDeactivate.add(currentKey);
			}
		}
	}

	public static void deactivateAsgmtGroupRecords(Set<Id> idsToAvoid) {
		if (keysToDeactivate != null && !keysToDeactivate.isEmpty()) {
			List<ICG_Capability_Assignment_Group__c> asgmtGroupToDeactivate = new List<ICG_Capability_Assignment_Group__c>();
			for (ICG_Capability_Assignment_Group__c item : [SELECT Id, RecordTypeId, ICG_Account_Role_Detail__c, ICG_Certification__c FROM ICG_Capability_Assignment_Group__c WHERE ICG_Account_Role_Detail__c IN :accRoleDetailAffectedMap.keySet() AND id NOT IN :idsToAvoid AND Is_Active__c = true]) {
				if (keysToDeactivate.contains(item.ICG_Account_Role_Detail__c + '#' + item.RecordTypeId + '#' + item.ICG_Certification__c)) {
					asgmtGroupToDeactivate.add(new ICG_Capability_Assignment_Group__c(Id = item.Id, Is_Active__c = false));
				}
			}

			if (!asgmtGroupToDeactivate.isEmpty()) {
				update asgmtGroupToDeactivate;
			}
		}
	}
}