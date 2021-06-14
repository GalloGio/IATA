@IsTest
public class TestDataFactory_FunctionalRoles_mdt {
	public static final String DEFAULTMASTERLABEL = 'Test Functional Role MDT';
	
	public static Functional_Role__mdt createDefaultFunctionalRole_mdt(){
		FunctionalRoles_mdt functionalRoles_mdt = new FunctionalRoles_mdt();
		return functionalRoles_mdt.createDefaultFunctionalRoleMDT();
	}
}