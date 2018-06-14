@isTest                       
private class SCIMDeleteUserPluginTest {
      
    // Tests
    @isTest static void testDelete() {
        // arrange
        System.Test.setMock(HttpCalloutMock.class, new HttpResponseGenerator());
        
        // act
        Process.PluginResult response = callPlugin();

        // assert
        System.assertEquals('Completed', response.outputParameters.get(UserProvisioningUtils.PARAM_STATUS));
    }
     
    @isTest static void test403HttpResponse() {
        // arrange
        System.Test.setMock(HttpCalloutMock.class, new HttpResponseGenerator(403));
        
        // act
        Process.PluginResult response = callPlugin();

        // assert
        System.assertEquals('Failed', response.outputParameters.get(UserProvisioningUtils.PARAM_STATUS));      
    }

    // Helper methods
    private static Process.PluginResult callPlugin() {
        // Create a UserProvisioningRequest for testing
        UserProvisioningRequest upr = UserProvisioningTestUtils.createUserProvisioningRequest('SCIM', 'Deactivate');
        
        // Build input params
        Map<String,Object> inputParams = new Map<String,Object>();
        inputParams.put(UserProvisioningUtils.PARAM_UPR_ID, upr.id);

        return UserProvisioningTestUtils.runPlugin(new SCIMDeleteUserPlugin(), inputParams);
    }
}