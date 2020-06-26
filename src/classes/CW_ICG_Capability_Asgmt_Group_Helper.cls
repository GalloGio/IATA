public without sharing class CW_ICG_Capability_Asgmt_Group_Helper {
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
}