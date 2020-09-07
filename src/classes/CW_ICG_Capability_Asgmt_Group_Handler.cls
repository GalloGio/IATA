public without sharing class CW_ICG_Capability_Asgmt_Group_Handler {
	public static void handleAfterInsert(Map<Id, ICG_Capability_Assignment_Group__c> newMap) {
		updateCargoCommodities(newMap.values());
		deprecateOldAsgmtGroupWithoutChildren(newMap);
	}
	public static void handleAfterUpdate(Map<Id, ICG_Capability_Assignment_Group__c> newMap) {
		updateCargoCommodities(newMap.values());
	}

	public static void updateCargoCommodities(List<ICG_Capability_Assignment_Group__c> newList) {
		Set<Id> certificationIds = new Set<Id>();
		for (ICG_Capability_Assignment_Group__c accRoleDetailCert : newList) {
			if (accRoleDetailCert.ICG_Certification__c != null) {
				certificationIds.add(accRoleDetailCert.ICG_Certification__c);
			}
		}

		if (certificationIds.size() > 0) {
			Map<Id, ICG_Certification__c> mapIdAccCert = new Map<Id, ICG_Certification__c>([SELECT Id, Name FROM ICG_Certification__c WHERE Id IN :certificationIds]);
			Map<Id, ICG_Account_Role_Detail__c> mapAccRoleDetail = new Map<Id, ICG_Account_Role_Detail__c>();

			for (ICG_Capability_Assignment_Group__c accRoleDetailCert : newList) {
				if (accRoleDetailCert.ICG_Certification__c != null) {
					if (mapAccRoleDetail.get(accRoleDetailCert.ICG_Account_Role_Detail__c) == null) {
						mapAccRoleDetail.put(accRoleDetailCert.ICG_Account_Role_Detail__c, new ICG_Account_Role_Detail__c(Id = accRoleDetailCert.ICG_Account_Role_Detail__c));
					}
					ICG_Account_Role_Detail__c accRoleDetail = mapAccRoleDetail.get(accRoleDetailCert.ICG_Account_Role_Detail__c);
					String nameCert = mapIdAccCert.get(accRoleDetailCert.ICG_Certification__c).Name;

					if (nameCert.equals('CEIV Pharma')) {
						accRoleDetail.Pharmaceuticals__c = true;
					}

					if (nameCert.equals('CEIV Live Animals')) {
						accRoleDetail.Live_Animals__c = true;
					}

					if (nameCert.equals('CEIV Fresh')) {
						accRoleDetail.Perishables__c = true;
					}

					if (nameCert.equals('Smart Facility Operational Capacity')) {
						if (accRoleDetailCert.SFOC_Scope__c != null) {
							List<String> listScope = accRoleDetailCert.SFOC_Scope__c.split(';');
							for (String scope : listScope) {
								if (scope.equals('General Cargo')) {
									accRoleDetail.General_Cargo__c = true;
								}
								if (scope.equals('Dangerous Goods')) {
									accRoleDetail.Dangerous_Goods__c = true;
								}
								if (scope.equals('Live Animals')) {
									accRoleDetail.Live_Animals__c = true;
								}
								if (scope.equals('Pharmaceuticals')) {
									accRoleDetail.Pharmaceuticals__c = true;
								}
								if (scope.equals('Perishables')) {
									accRoleDetail.Perishables__c = true;
								}
								if (scope.equals('Airmail')) {
									accRoleDetail.Airmail__c = true;
								}
							}
						}
					}
				}
			}

			if (!mapAccRoleDetail.isEmpty()) {
				update mapAccRoleDetail.values();
			}
		}
	}

	public static void deprecateOldAsgmtGroupWithoutChildren(Map<Id, ICG_Capability_Assignment_Group__c> newMap) {
		Map<String, Id> newAsgmGroupWithoutChildren = new Map<String, Id>();
		Map<String, List<Id>> oldAsgmGroupWithoutChildren = new Map<String, List<Id>>();
		List<ICG_Capability_Assignment_Group__c> asgmGroupToUpdate = new List<ICG_Capability_Assignment_Group__c>();

		List<Id> accRoleDetailAffected = new List<Id>();
		for (Id currentId : newMap.keySet()) {
			if (!accRoleDetailAffected.contains(newMap.get(currentId).Id)) {
				accRoleDetailAffected.add(newMap.get(currentId).ICG_Account_Role_Detail__c);
			}
		}

		for (ICG_Capability_Assignment_Group__c currentRow : [
			SELECT Id, RecordType.DeveloperName, ICG_Account_Role_Detail__c, ICG_Certification__r.Name 
			FROM ICG_Capability_Assignment_Group__c 
			WHERE (ICG_Account_Role_Detail__c IN :accRoleDetailAffected AND Is_Expired__c = false AND Total_Children__c = 0 AND Is_Deprecated_Without_Children__c != true) OR Id IN :newMap.keySet() 
			ORDER BY CreatedDate DESC
		]) {
			String currentKey = currentRow.ICG_Account_Role_Detail__c + '#' + currentRow.RecordType.DeveloperName + '#' + (currentRow.ICG_Certification__r.Name != null ? currentRow.ICG_Certification__r.Name : '');
			if (newMap.containsKey(currentRow.Id)) {
				if (!newAsgmGroupWithoutChildren.containsKey(currentKey)) {
					newAsgmGroupWithoutChildren.put(currentKey, currentRow.Id);
				} else {
					asgmGroupToUpdate.add(new ICG_Capability_Assignment_Group__c(Id = currentRow.Id, Is_Deprecated_Without_Children__c = true));
				}
			} else {
				if (!oldAsgmGroupWithoutChildren.containsKey(currentKey)) {
					oldAsgmGroupWithoutChildren.put(currentKey, new List<Id>());
				}
				oldAsgmGroupWithoutChildren.get(currentKey).add(currentRow.Id);
			}
		}

		for (String currentKey : newAsgmGroupWithoutChildren.keySet()) {
			if (oldAsgmGroupWithoutChildren.containsKey(currentKey)) {
				for (Id currentAsgmGroupId : oldAsgmGroupWithoutChildren.get(currentKey)) {
					asgmGroupToUpdate.add(new ICG_Capability_Assignment_Group__c(Id = currentAsgmGroupId, Is_Deprecated_Without_Children__c = true));
				}
			}
		}

		if (!asgmGroupToUpdate.isEmpty()) {
			update asgmGroupToUpdate;
		}
	}
}