@IsTest
private class PortalApplicationSelectorTest {
	@TestSetup
	static void makeData(){
		insert TestDataFactory_PortalApplications.createDefaultPortalApplication(1);
	}

	@IsTest
	static void testSelectAutoGrantAccountRoleByFunctionalRole(){
		List<Portal_Applications__c> portalApplicationList = PortalApplicationSelector.selectAutoGrantAccountRoleByFunctionalRole(new Set<String>{'FAKE'});
		System.assert(!portalApplicationList.isEmpty());
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

	@IsTest
	static void testSelectNewGenFieldsMapByName(){
		Test.startTest();
		Portal_Applications__c portalApplication = PortalApplicationSelector.selectIdByName(new Set<String>{TestDataFactory_PortalApplications.DEFAULTSERVICENAME}).get(0);
		portalApplication.ANG_Restrict_by_Agency_Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT;
		portalApplication.ANG_Accredited_Agents_Only__c = false;
		portalApplication.Agency__c = true;
		update portalApplication;
		Test.stopTest();

		portalApplication = PortalApplicationSelector.selectNewGenFieldsMapByName(new Set<String>{TestDataFactory_PortalApplications.DEFAULTSERVICENAME}).values().get(0);
		System.assertEquals(ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT, portalApplication.ANG_Restrict_by_Agency_Sector__c, 'Expected ' + ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT + ' but returned ' + portalApplication.ANG_Restrict_by_Agency_Sector__c);
		System.assert(!portalApplication.ANG_Accredited_Agents_Only__c, 'Expected false but returned ' + !portalApplication.ANG_Accredited_Agents_Only__c);
		System.assert(portalApplication.Agency__c, 'Expected true but returned ' + portalApplication.Agency__c);
	}
}