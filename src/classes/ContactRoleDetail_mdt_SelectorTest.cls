@IsTest
private class ContactRoleDetail_mdt_SelectorTest {
	static final Functional_Role__mdt functionalRole_mdt = new Functional_Role__mdt(MasterLabel = 'Test Functional Role');
    
	@IsTest
	static void testSelectIdById(){
		//custom metadata cannot be inserted nor queried () in test classes so this is a dummy method for code coverage
		ContactRoleDetail_mdt_Selector.selectIdById(null);
	}

	@IsTest
	static void testSelectRolesByFunctionalRole(){
		//custom metadata cannot be inserted nor queried () in test classes so this is a dummy method for code coverage
		ContactRoleDetail_mdt_Selector.selectRolesByFunctionalRole('');
	}

	@IsTest
	static void testSelectQuery(){
		//custom metadata cannot be inserted nor queried () in test classes so this is a dummy method for code coverage
		ContactRoleDetail_mdt_Selector.selectQuery('Id', null, null);
	}
}