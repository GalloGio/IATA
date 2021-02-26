@IsTest
private class PortalServiceAccessServiceTest {
	@TestSetup
	static void makeData(){
		Account account = TestDataFactory_Accounts.createStandardAccounts(1).get(0);
		insert account;
		Contact contact = TestDataFactory_Contacts.createDefaultContact(account.Id, 1).get(0);
		insert contact;
	}

	@IsTest static void testProcessPortalServiceAccessService(){
		PortalServiceAccessService.PortalServiceAccess portalServiceAccess = new PortalServiceAccessService.PortalServiceAccess();
		portalServiceAccess.functionalRoleName = AirportISService.FUNCTIONALROLE;
		portalServiceAccess.contact = ContactSelector.selectByEmails(new Set<String>{TestDataFactory_Contacts.DEFAULTEMAIL + '0'}).get(0);
		portalServiceAccess.accessStatus = PortalApplicationRights.ACCESSGRANTED;

		List<PortalServiceAccessService.PortalServiceAccess> portalServiceAccessList = new List<PortalServiceAccessService.PortalServiceAccess>{portalServiceAccess};
		try {
			PortalServiceAccessService.processPortalServiceAccessService(portalServiceAccessList);
			System.assert(true);
		} catch (Exception e) {
			System.assert(false, 'PortalServiceAccessService.processPortalServiceAccessService caused an error');
		}
	}
}