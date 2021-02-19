@IsTest
private class PortalApplicationSelectorTest {
	@TestSetup
	static void makeData(){
		insert TestDataFactory_PortalApplications.createDefaultPortalApplication(1);
	}

	@IsTest
	static void testSelectIdByName(){
		List<Portal_Applications__c> portalApplicationList = PortalApplicationSelector.selectIdByName(new Set<String>{TestDataFactory_PortalApplications.DEFAULTSERVICENAME});
		System.assertEquals(1, portalApplicationList.size(), 'Expected 1 Portal_Applications__c record but got ' + portalApplicationList.size());
	}

	@IsTest
	static void testSelectFunctionalRoleMapByServiceNameSet(){
		Map<Id, Portal_Applications__c> portalApplicationIdMap = PortalApplicationSelector.selectFunctionalRoleMapByServiceNameSet(new Set<String>{TestDataFactory_PortalApplications.DEFAULTSERVICENAME});		 
		System.assertEquals(1, portalApplicationIdMap.size());
	}
}