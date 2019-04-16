/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class FREDSCIMUserTest {

    static testMethod void myUnitTest() {
        

    	String json = '{\"schemas\":[\"urn:scim:schemas:core:1.0\",\"urn:scim:schemas:extension:enterprise:1.0\",\"urn:salesforce:schemas:extension:00D30000001bZxaEAE\"],\"id\":\"00530000008xIlOAAU\",\"userName\":\"demoadmin@identity.org\",\"externalId\":\"adminqa@qaresponder.info\",\"name\":{\"formatted\":\"Demo Admin\",\"familyName\":\"Admin\",\"givenName\":\"Demo\"},\"displayName\":\"Demo Admin\",\"nickName\":\"demoadmin\",\"emails\":[{\"type\":\"work\",\"primary\":true,\"value\":\"adminqa@qaresponder.info\"}],\"phoneNumbers\":[{\"type\":\"work\",\"value\":\"1234567\"}],\"photos\":[{\"type\":\"photo\",\"value\":\"https://customer--c.na1.content.force.com/profilephoto/72930000000UxTS/F\"},{\"type\":\"thumbnail\",\"value\":\"https://customer--c.na1.content.force.com/profilephoto/72930000000UxTS/T\"}],\"userType\":\"Standard\",\"preferredLanguage\":\"en_US\",\"locale\":\"en_US\",\"active\":true,\"entitlements\":[{\"value\":\"00e30000001y7a7AAA\",\"display\":\"Identity Admin\",\"primary\":true},{\"value\":\"0PS30000000PVEPGA4\",\"display\":\"IdentityConnect\",\"primary\":false},{\"value\":\"0PS30000000PVZOGA4\",\"display\":\"StoreAdmin\",\"primary\":false},{\"value\":\"0PS30000000PVZPGA4\",\"display\":\"StoreUser\",\"primary\":false},{\"value\":\"0PS30000000PhouGAC\",\"display\":\"OpenID_App_Access\",\"primary\":false},{\"value\":\"0PS30000000PigwGAC\",\"display\":\"Matrix_Admin\",\"primary\":false},{\"value\":\"0PS30000000PitMGAS\",\"display\":\"LDS_Demo_Access\",\"primary\":false},{\"value\":\"0PS30000000PjT0GAK\",\"display\":\"FooTracker_Developer\",\"primary\":false}],\"groups\":[],\"roles\":[{\"value\":\"00E30000001RuAaEAK\",\"display\":\"Admin\"}],\"urn:scim:schemas:extension:enterprise:1.0\":{\"organization\":\"00D30000001bZxaEAE\"},\"urn:salesforce:schemas:extension:00D30000001bZxaEAE\":{\"GoogleID__c\":\"111632884813494120524\",\"AD_Guid__c\":\"%3CGUID%3Dc4422f5d3d3b0b4aa774fc1bdfe2a398%3E\",\"Has_Registered_2FA__c\":false,\"isSelfRegistered__c\":false,\"randomUsername__c\":\"user1@wave-demo.org\"},\"meta\":{\"created\":\"2013-09-25T10:50:42Z\",\"lastModified\":\"2015-07-01T09:21:35Z\",\"version\":\"eb4043f3ff6066c98c9286832f6d818250d7801b\"}}';
        FREDSCIMMessageEnhancer instance = new FREDSCIMMessageEnhancer();
        new FREDSCIMMessageEnhancer('FRED');

        Map<String, Object> inputParams = new Map<String, Object>();
        inputParams.put(UserProvisioningUtils.PARAM_USERPAYLOAD, json);
        inputParams.put(SCIMUserAttributeGenerator.PARAM_USERNAME, 'dummy@iata.org');
        inputParams.put(SCIMUserAttributeGenerator.PARAM_FIRSTNAME, 'dummy');
        inputParams.put(SCIMUserAttributeGenerator.PARAM_LASTNAME, 'dummy');
        inputParams.put(SCIMUserAttributeGenerator.PARAM_EXTERNALID, '3213213');
        inputParams.put(SCIMUserAttributeGenerator.PARAM_EMAIL, 'dummy@iata.org');

        Process.PluginRequest request = new Process.PluginRequest(inputParams);
		instance.enhanceMessage(request);
		
        SCIMUser obj = SCIMUser.parse(json);        
        FREDSCIMUser test = new FREDSCIMUser(obj.username, obj.name.familyName,obj.name.givenName, obj.externalid, UserInfo.getUserEmail());
    }
   
    @isTest
	static void UserProvisioningRequestUpdateTrigger(){	 
                  
        Test.startTest();
        
	        UserProvisioningRequest u = new UserProvisioningRequest();
	        u.SalesforceUserId = UserInfo.getUserId();
	        u.ConnectedAppId = [SELECT id FROM ConnectedApplication WHERE name = 'FRED_Provisioning' LIMIT 1].id;
	        u.State = 'New';
	        u.Operation = 'Create';
	        u.ApprovalStatus = 'Required';
	
	        database.insert(u);
	        u.state = 'Completed';
	        database.update(u);

        Test.stopTest();
	}
}