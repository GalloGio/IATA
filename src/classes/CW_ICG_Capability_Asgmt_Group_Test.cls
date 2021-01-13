@IsTest
private class CW_ICG_Capability_Asgmt_Group_Test {
	@isTest
	public static void testCreateGroups() {
		IATA_ISO_Country__c isoCode = CW_TestDataFactory.newISOCountry();
		insert isoCode;

		Account acc = CW_TestDataFactory.TestAccount(isoCode.Id);
		insert acc;

		Airport_Detail__c airport = CW_TestDataFactory.newAirport(isoCode.Id, acc.Id);
		insert airport;

		Contact con1 = CW_TestDataFactory.testContact(acc.id);
		insert con1;

		Account_Role__c accRole = CW_TestDataFactory.testAccountRole(acc.Id, 'Test');
		insert accRole;

		ICG_Account_Role_Detail__c accRoleDetail = CW_TestDataFactory.testICGAccountRoleDetail(accRole.Id, airport);
		insert accRoleDetail;

		ICG_Certification__c cert = CW_TestDataFactory.newCertification();
		insert cert;

		Map<String, ICG_Capability_Assignment_Group__c> asgmGroupsMap = new Map<String, ICG_Capability_Assignment_Group__c>();
		asgmGroupsMap.put('not_active_0', new ICG_Capability_Assignment_Group__c(ICG_Certification__c = cert.id, ICG_Account_Role_Detail__c = accRoleDetail.Id, Issue_Date__c = date.today().addDays(-10), Expiration_Date__c = date.today().addDays(10)));
		asgmGroupsMap.put('not_active_1', new ICG_Capability_Assignment_Group__c(ICG_Certification__c = cert.id, ICG_Account_Role_Detail__c = accRoleDetail.Id, Issue_Date__c = date.today().addDays(-10), Expiration_Date__c = date.today().addDays(9)));
		asgmGroupsMap.put('active_0', new ICG_Capability_Assignment_Group__c(ICG_Certification__c = cert.id, ICG_Account_Role_Detail__c = accRoleDetail.Id, Issue_Date__c = date.today().addDays(-8), Expiration_Date__c = date.today().addDays(8)));
		asgmGroupsMap.put('future_0', new ICG_Capability_Assignment_Group__c(ICG_Certification__c = cert.id, ICG_Account_Role_Detail__c = accRoleDetail.Id, Issue_Date__c = date.today().addDays(3), Expiration_Date__c = date.today().addDays(10)));
		asgmGroupsMap.put('expired_0', new ICG_Capability_Assignment_Group__c(ICG_Certification__c = cert.id, ICG_Account_Role_Detail__c = accRoleDetail.Id, Issue_Date__c = date.today().addDays(-10), Expiration_Date__c = date.today().addDays(-1)));
		insert asgmGroupsMap.values();

		List<Id> ids = new List<Id>();
		ids.add(asgmGroupsMap.get('not_active_0').Id);
		ids.add(asgmGroupsMap.get('not_active_1').Id);
		ids.add(asgmGroupsMap.get('active_0').Id);
		ids.add(asgmGroupsMap.get('future_0').Id);
		ids.add(asgmGroupsMap.get('expired_0').Id);

		for (ICG_Capability_Assignment_Group__c currentGroup : [SELECT Id, Is_Active__c, Is_Expired__c FROM ICG_Capability_Assignment_Group__c WHERE id IN :ids]) {
			for (String currentKey : asgmGroupsMap.keySet()) {
				if (asgmGroupsMap.get(currentKey).Id == currentGroup.Id) {
					asgmGroupsMap.put(currentKey, currentGroup);
				}
			}
		}

		System.assertEquals(false, asgmGroupsMap.get('not_active_0').Is_Active__c, 'Deprecation flow failed: not_active_0');
		System.assertEquals(false, asgmGroupsMap.get('not_active_1').Is_Active__c, 'Deprecation flow failed: not_active_1');
		System.assertEquals(true, asgmGroupsMap.get('active_0').Is_Active__c, 'Deprecation flow failed: active_0');
		System.assertEquals(false, asgmGroupsMap.get('future_0').Is_Active__c, 'Deprecation flow failed: future_0');
		System.assertEquals(false, asgmGroupsMap.get('expired_0').Is_Active__c, 'Deprecation flow failed: expired_0');
		System.assertEquals(true, asgmGroupsMap.get('expired_0').Is_Expired__c, 'Deprecation flow failed: expired_0');
	}
}