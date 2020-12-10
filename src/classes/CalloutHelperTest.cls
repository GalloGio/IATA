@isTest
private class CalloutHelperTest{

	@isTest
	private static void testGetFullConfig() {
		CalloutHelper cHelp = new CalloutHelper();
		system.assertEquals(null, cHelp.getFullConfig('nothingFound'));
		system.assertNotEquals(null, cHelp.getFullConfig('UserProvisioning_Create'));
	}

	@isTest
	private static void testgetResourceFromConfig() {
		CalloutHelper cHelp = new CalloutHelper();
		system.assertEquals(null, cHelp.getResourceFromConfig('nothingFound'));
		system.assertNotEquals('', cHelp.getResourceFromConfig('UserProvisioning_Create'));
	}
}