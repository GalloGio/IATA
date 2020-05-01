@isTest 
private class PermissionSetsTest {
    private static PermissionSets permissionSets = new PermissionSets();

    @TestSetup
    static void setup(){
        insert new PermissionSet(label = 'Test Permission Set', name = 'Test_Permission_Set');
    }

    @IsTest static void testConstructors(){
        System.assert(permissionSets.records != null, 'PermissionSets domain class not initalised correctly with empty records.');

        List<PermissionSet> permissionSetList = [SELECT Id, Label FROM PermissionSet WHERE Label = 'Test Permission Set'];
        permissionSets = new PermissionSets(permissionSetList);
        System.assert(permissionSets.records.size() > 0, 'PermissionSets domain class not initalised correctly with input Permission Set list.');
    }

    @IsTest static void testGetPermissionSetsByName(){
        List<PermissionSet> permissionSetList = permissionSets.getPermissionSetsByName(new List<String>{'Test_Permission_Set'});
        System.assertEquals(1, permissionSetList.size(), 'Permission Set not found');
    }

    @IsTest static void testInsertRecords(){
        permissionSets.records.add(new PermissionSet(label = 'Test Permission Set2', name = 'Test_Permission_Set2'));
        permissionSets.insertRecords();
        List<PermissionSet> permissionSetList = [SELECT Id FROM PermissionSet WHERE Name = 'Test_Permission_Set2'];
        System.assertEquals(1, permissionSetList.size(), 'Permission Set not inserted.');
    }
}