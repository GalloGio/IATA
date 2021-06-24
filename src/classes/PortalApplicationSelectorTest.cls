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

	@IsTest
	static void testSelectFunctionalRoleMapByServiceIdSet(){
		Map<Id, Portal_Applications__c> portalApplicationIdMap = PortalApplicationSelector.selectFunctionalRoleMapByServiceNameSet(new Set<String>{TestDataFactory_PortalApplications.DEFAULTSERVICENAME});		 
		System.assertEquals(1, portalApplicationIdMap.size());
	}

	@IsTest
	static void testSelectInvitationFieldsMapByName(){
		Portal_Applications__c portalApplication = [SELECT Id, Functional_Role__c FROM Portal_Applications__c LIMIT 1];
		System.assert(PortalApplicationSelector.selectInvitationFieldsMapByName(new Set<String>{portalApplication.Functional_Role__c}) != null);
	}

	@IsTest
	static void testSelectIsServiceEnabledMapByServiceIdSet(){
		Portal_Applications__c portalApplication = [SELECT Id, Is_Invitation_Enabled__c FROM Portal_Applications__c WHERE Name = :TestDataFactory_PortalApplications.DEFAULTSERVICENAME LIMIT 1];
		portalApplication.Is_Invitation_Enabled__c = true;
		update portalApplication;

		Map<Id, Portal_Applications__c> portalApplicationIdMap = PortalApplicationSelector.selectIsServiceEnabledMapByServiceIdSet(new Set<Id>{portalApplication.Id});		 
		System.assert(portalApplicationIdMap.get(portalApplication.Id).Is_Invitation_Enabled__c);
	}
}