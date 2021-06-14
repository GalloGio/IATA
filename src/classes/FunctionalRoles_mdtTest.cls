@IsTest
private class FunctionalRoles_mdtTest {

	@IsTest
	static void testInitialisation(){
		FunctionalRoles_mdt functionalRoles_mdt = new FunctionalRoles_mdt();
		System.assertEquals(0, functionalRoles_mdt.records.size());

		functionalRoles_mdt = new FunctionalRoles_mdt(new List<Functional_Role__mdt>{new Functional_Role__mdt(MasterLabel = TestDataFactory_FunctionalRoles_mdt.DEFAULTMASTERLABEL)});
		System.assertEquals(1, functionalRoles_mdt.records.size());
	}

	@IsTest
	static void testCreateDefaultFunctionalRoleMDT(){
		FunctionalRoles_mdt functionalRoles_mdt = new FunctionalRoles_mdt();
		System.assert(functionalRoles_mdt.createDefaultFunctionalRoleMDT() != null);
	}
}