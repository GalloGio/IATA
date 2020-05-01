@IsTest
private class PermissionSetSelectorTest {
	private static String permissionSetName = 'Test_Permission_Set_1';

	@TestSetup
	static void setup(){
		insert new PermissionSet(name = permissionSetName, label = 'Test Permission Set 1');
	}

	@IsTest static void testInsertPermissionSets(){
		System.assertEquals(1, [SELECT Id FROM PermissionSet WHERE Name = :permissionSetName].size(), 'Did not find 1 PermissionSet.');
	}

	@IsTest static void testSelectByConditionSet(){
		List<PermissionSet> permissionSetList = PermissionSetSelector.selectByConditionSet('Id', 'Name', new Set<String>{permissionSetName});
		System.assertEquals(1, permissionSetList.size(), 'Permission Set List size not equal to 1');
	}

}
