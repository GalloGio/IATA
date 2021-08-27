@IsTest
private class PortalApplicationRightsTest {
	@TestSetup
	static void makeData(){
		Portal_Applications__c portalApplication = TestDataFactory_PortalApplications.createDefaultPortalApplication(1).get(0);
		insert portalApplication;
		Account account = TestDataFactory_Accounts.createDefaultAccounts(1).get(0);
		insert account;
		Contact contact = TestDataFactory_Contacts.createDefaultContact(account.Id, 1).get(0);
		insert contact;
		Portal_Application_Right__c portalApplicationRight = TestDataFactory_PortalApplicationRights.createPortalApplicationRight(portalApplication.Id, contact.Id);
		insert portalApplicationRight;
	}

	@IsTest
	static void testContructors(){
		PortalApplicationRights portalApplicationRights = new PortalApplicationRights();
		System.assert(portalApplicationRights.records.isEmpty(), 'Expected PortalApplicationRights domain class to be created with empty records list');

		Id contactId = ContactSelector.selectByEmails(new Set<String>{TestDataFactory_Contacts.DEFAULTEMAIL + '0'}).get(0).Id;
		Id portalApplicationId = PortalApplicationSelector.selectIdByName(new Set<String>{TestDataFactory_PortalApplications.DEFAULTSERVICENAME}).get(0).Id;
		Portal_Application_Right__c portalApplicationRight = PortalApplicationRightSelector.selectByContactIdAndServiceId(contactId, portalApplicationId);
		portalApplicationRights = new PortalApplicationRights(new List<Portal_Application_Right__c>{portalApplicationRight});
		System.assertEquals(1, portalApplicationRights.records.size(), 'Expected PortalApplicationRights domain class to be created with 1 record but got ' + portalApplicationRights.records.size());
	}

	@IsTest
	static void testCreateDefaultPortalApplicationRight(){
		PortalApplicationRights portalApplicationRights = new PortalApplicationRights();
		List<Portal_Application_Right__c> portalApplicationRightsList = portalApplicationRights.createDefaultPortalApplicationRight(10);
		System.assertEquals(10, portalApplicationRightsList.size());
	}
}