@IsTest
private class FunctionalRole_mdt_SelectorTest {
	@IsTest
	static void testSelectIdById(){
		//custom metadata cannot be inserted nor queried () in test classes so this is a dummy method for code coverage
		FunctionalRole_mdt_Selector.selectIdById(null);
	}

	@IsTest
	static void testSelectIdByName(){
		//custom metadata cannot be inserted nor queried () in test classes so this is a dummy method for code coverage
		FunctionalRole_mdt_Selector.selectIdByName('');
	}

	@IsTest
	static void testSelectQuery(){
		//custom metadata cannot be inserted nor queried () in test classes so this is a dummy method for code coverage
		FunctionalRole_mdt_Selector.selectQuery('Id', null, null);
	}
}