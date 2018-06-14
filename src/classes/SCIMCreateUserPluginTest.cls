@isTest                       
private class SCIMCreateUserPluginTest {
      
    // Tests
    @isTest static void testCreate() {
        // arrange
        HttpResponseGenerator generator = new HttpResponseGenerator();
        generator.nextBody = '{"schemas":["urn:scim:schemas:core:1.0","urn:scim:schemas:extension:enterprise:1.0"],"id":"005B0000001SFMhIAO","userName":"jane.doe@scimuserprov.test","name":{"formatted":"Jane Doe","familyName":"Doe","givenName":"Jane"},"displayName":"Jane Doe","nickName":"jane.doe","emails":[{"type":"work","primary":true,"value":"jane.doe@testemail.com"}],"photos":[{"type":"photo","value":"https://c.gus.content.force.com/profilephoto/005/F"},{"type":"thumbnail","value":"https://c.gus.content.force.com/profilephoto/005/T"}],"userType":"Standard","preferredLanguage":"en_US","locale":"en_US","active":true,"entitlements":[{"value":"00eB0000000MZj0IAG","display":"Identity User","primary":true}],"groups":[],"urn:scim:schemas:extension:enterprise:1.0":{"organization":"00DB000000016v5MAA"},"meta":{"created":"2015-06-24T11:57:02Z","lastModified":"2015-06-24T11:57:02Z","version":"0b86f5170f7ee5b9a7b3120670a2621127b853b9"}}';
        System.Test.setMock(HttpCalloutMock.class, generator);

        // act
        Process.PluginResult response = callPlugin(true);

        // assert
        System.assertEquals('Completed', response.outputParameters.get(UserProvisioningUtils.PARAM_STATUS));
        System.assertEquals('005B0000001SFMhIAO', response.outputParameters.get(UserProvisioningUtils.PARAM_EXTERNAL_USERID));
        System.assertEquals('jane.doe@scimuserprov.test', response.outputParameters.get(UserProvisioningUtils.PARAM_EXTERNAL_USERNAME));
        System.assertEquals('daisypop89@gmail.com', response.outputParameters.get(UserProvisioningUtils.PARAM_EXTERNAL_EMAIL));
        System.assertEquals('Daisy', response.outputParameters.get(UserProvisioningUtils.PARAM_EXTERNAL_FIRSTNAME));
        System.assertEquals('Jensen', response.outputParameters.get(UserProvisioningUtils.PARAM_EXTERNAL_LASTNAME));                        
    }
    
    @isTest static void testIncompleteInputParams() {
        // arrange
        System.Test.setMock(HttpCalloutMock.class, new HttpResponseGenerator());

        // act
        Process.PluginResult response = callPlugin(false);

        // assert
        System.assertEquals('Failed', response.outputParameters.get(UserProvisioningUtils.PARAM_STATUS));
    }
 
    @isTest static void test403HttpResponse() {
        // arrange
        System.Test.setMock(HttpCalloutMock.class, new HttpResponseGenerator(403));

        // act
        Process.PluginResult response = callPlugin(true);


        // assert
        System.assertEquals('Failed', response.outputParameters.get(UserProvisioningUtils.PARAM_STATUS));     
    }
    
    @isTest static void testExceptionWithInvalidJSONResponse() {
        // arrange
        HttpResponseGenerator generator = new HttpResponseGenerator();
        generator.nextBody = '{],"id":"005B0000001SFMhIAO","userName":"jane.doe@scimuserprov.test",';
        System.Test.setMock(HttpCalloutMock.class, generator);

        // act
        Process.PluginResult response = callPlugin(true);

        // assert
        System.assertEquals('Failed', response.outputParameters.get(UserProvisioningUtils.PARAM_STATUS));
    }

    // Helper methods
    private static Process.PluginResult callPlugin() {
        return callPlugin(true);
    }

    private static Process.PluginResult callPlugin(Boolean validInput) {
        // Create a UserProvisioningRequest for testing
        UserProvisioningRequest upr = UserProvisioningTestUtils.createUserProvisioningRequest('SCIM', 'Create');
        
        // Build input params
        Map<String,Object> inputParams = new Map<String,Object>();
        if (validInput) {
            inputParams.put(UserProvisioningUtils.PARAM_UPR_ID, upr.id);
            inputParams.put(UserProvisioningUtils.PARAM_USERPAYLOAD, '{\n  "name" : {\n    "familyName" : "Jensen",\n    "givenName" : "Daisy"\n  },\n  "emails" : [ {\n    "value" : "daisypop89@gmail.com"\n  } ],\n  "schemas" : [ "urn:scim:schemas:core:1.0" ]\n}');
        }

        return UserProvisioningTestUtils.runPlugin(new SCIMCreateUserPlugin(), inputParams);
    }
}