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
	static void testSelectAutoGrantAccountRoleByName(){
		Portal_Applications__c portalApplication = PortalApplicationSelector.selectAutoGrantAccountRoleByName(new Set<String>{TestDataFactory_PortalApplications.DEFAULTSERVICENAME}).get(0);
		System.assertNotEquals(true, portalApplication.Auto_grant_Account_Role__c);
		portalApplication.Auto_grant_Account_Role__c = true;
		update portalApplication;
		portalApplication = PortalApplicationSelector.selectAutoGrantAccountRoleByName(new Set<String>{TestDataFactory_PortalApplications.DEFAULTSERVICENAME}).get(0);
		System.assertEquals(true, portalApplication.Auto_grant_Account_Role__c);
	}
}