@IsTest
private class PortalApplicationRightSelectorTest {
	@TestSetup
	static void makeData(){
		Account account = TestDataFactory_Accounts.createDefaultAccounts(1).get(0);
		insert account;
		Contact contact = TestDataFactory_Contacts.createDefaultContact(1).get(0);
		contact.AccountId = account.Id;
		insert contact;
		Portal_Applications__c portalApplication = TestDataFactory_PortalApplications.createDefaultPortalApplication(1).get(0);
		insert portalApplication;
		Portal_Application_Right__c portalApplicationRight = TestDataFactory_PortalApplicationRights.createPortalApplicationRight(portalApplication.Id, contact.Id);
		insert portalApplicationRight;
	}

	@IsTest
	static void test(){
		Test.startTest();
		Contact contact = ContactSelector.selectByEmails(new Set<String>{TestDataFactory_Contacts.DEFAULTEMAIL + '0'}).get(0);
		Portal_Applications__c portalApplication = PortalApplicationSelector.selectIdByName(new Set<String>{TestDataFactory_PortalApplications.DEFAULTSERVICENAME}).get(0);
		Test.stopTest();
		
		Id portalApplicationRightId = PortalApplicationRightSelector.selectIdByContactIdAndServiceId(contact.Id, portalApplication.Id);
		Portal_Application_Right__c portalApplicationRight = [SELECT Id FROM Portal_Application_Right__c WHERE Contact__c = :contact.Id AND Portal_Application__c = :portalApplication.Id].get(0);
		System.assertEquals(portalApplicationRight.Id, portalApplicationRightId, 'Expected Portal_Application_Right__c.Id not returned');
	
		portalApplicationRight = PortalApplicationRightSelector.selectByContactIdAndServiceId(contact.Id, portalApplication.Id);
		System.assert(portalApplicationRight.Id != null, 'Expected Portal_Application_Right__c not returned');
	}
}