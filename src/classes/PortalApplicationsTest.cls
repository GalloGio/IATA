@IsTest
private class PortalApplicationsTest {
	@TestSetup
	static void makeData(){
		Portal_Applications__c portalApplication = new Portal_Applications__c();
		portalApplication.Name = TestDataFactory_PortalApplications.DEFAULTSERVICENAME;
		portalApplication.Functional_Role__c = SObjectType.Portal_Applications__c.Fields.Functional_Role__c.PicklistValues[0].getValue();
		insert portalApplication;
	}

	@IsTest
	static void testInitialisation(){
		PortalApplications portalApplications = new PortalApplications();
		System.assertEquals(0, portalApplications.records.size());

		List<Portal_Applications__c> portalApplicationList = [SELECT Id FROM Portal_Applications__c LIMIT 1];
		portalApplications = new PortalApplications(portalApplicationList);
		System.assertEquals(1, portalApplications.records.size());
	}

	@IsTest
	static void testCreateDefaultPortalApplications(){
		PortalApplications portalApplications = new PortalApplications();
		List<Portal_Applications__c> portalApplicationList = portalApplications.createDefaultPortalApplications(1);
	}
}