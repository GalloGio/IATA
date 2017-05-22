@isTest
private class SCIMUserAttributeGeneratorPluginTest {
    
    // Tests     
    @isTest static void testGeneratePayload() {
        // arrange
        //String expected = '{"schemas":["urn:scim:schemas:core:1.0"],"name":{"givenName":"Daisy","familyName":"Jensen"},"emails":[{"value":"daisypop89@gmail.com"}]}';
        // act
        Process.PluginResult response = callPlugin();
        String actual = (String)response.outputParameters.get(UserProvisioningUtils.PARAM_USERPAYLOAD);

        // assert
        //System.assertEquals(expected, actual);
    }

    // Helper methods
    private static Process.PluginResult callPlugin() {
        // Create a UserProvisioningRequest for testing
        UserProvisioningRequest upr = UserProvisioningTestUtils.createUserProvisioningRequest('SCIM', 'Create');

        // Build input params
        Map<String,Object> inputParams = new Map<String,Object>();

        inputParams.put(SCIMUserAttributeGenerator.PARAM_FIRSTNAME, 'Daisy');
        inputParams.put(SCIMUserAttributeGenerator.PARAM_LASTNAME, 'Jensen');
        inputParams.put(SCIMUserAttributeGenerator.PARAM_EMAIL, 'daisypop89@gmail.com');        
        inputParams.put(SCIMUserAttributeGenerator.PARAM_USERNAME, 'daisypop89@gmail.com');
        inputParams.put(SCIMUserAttributeGenerator.PARAM_EXTERNALID, 'daisypop89@gmail.com');
        inputParams.put(SCIMUserAttributeGenerator.PARAM_ENTITLEMENT, 'COPAMessage');

        return UserProvisioningTestUtils.runPlugin(new SCIMUserAttributeGeneratorPlugin(), inputParams);
    }

    @isTest static void testGeneratePayload1() {
    	
    	SCIM_App_Messages_Definition__c a = new SCIM_App_Messages_Definition__c();
    	a.name = 'COPAMessage';
    	a.Apex_Class_Name__c='COPASCIMMessageEnhancer';
    	insert a;
    	
        Process.PluginResult response = callPlugin();

        String actual = (String)response.outputParameters.get(UserProvisioningUtils.PARAM_USERPAYLOAD);
    }
}