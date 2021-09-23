@IsTest
private class ContactRoleDetails_mdtTest {
    @IsTest
	static void testInitialisation(){
		ContactRoleDetails_mdt contactRoleDetails_mdt = new ContactRoleDetails_mdt();
		System.assertEquals(0, contactRoleDetails_mdt.records.size());

		contactRoleDetails_mdt = new ContactRoleDetails_mdt(new List<Contact_Role_Detail__mdt>{new Contact_Role_Detail__mdt(MasterLabel = TestDataFactory_ContactRoleDetails_mdt.DEFAULTMASTERLABEL)});
		System.assertEquals(1, contactRoleDetails_mdt.records.size());
	}

	@IsTest
	static void testCreateDefaultContactRoleDetailMDT(){
		ContactRoleDetails_mdt contactRoleDetails_mdt = new ContactRoleDetails_mdt();
		System.assertEquals(2, contactRoleDetails_mdt.createDefaultContactRoleDetailMDT(2).size());
	}
}