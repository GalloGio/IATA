@isTest
private class LightningConnectedAppHelper_Test {

    static testMethod void testAuramethods() {
        LightningConnectedAppHelper.ConnectedAppsList();
        LightningConnectedAppHelper.getroles('testconnectedapp');
        UserProvisioningRequest u = new UserProvisioningRequest();
        u.SalesforceUserId = UserInfo.getUserId();
        u.ConnectedAppId = [SELECT id FROM ConnectedApplication LIMIT 1].id;
        u.State = 'New';
        u.Operation = 'Create';
        u.ApprovalStatus = 'Required';
        database.insert(u);
        u.state = 'Completed';
        database.update(u);
        
        try {
        	LightningConnectedAppHelper.getPic(null);
        }
        catch (Exception e) {
        	
        }
        
        try {
        	LightningConnectedAppHelper.getAppDescription(null);
        }
        catch (Exception e) {
        	
        }
        
        try {
        	LightningConnectedAppHelper.assignpermissionset(null,null);
        }
        catch (Exception e) {
        	
        }
        
    }
}