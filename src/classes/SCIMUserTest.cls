@isTest
public class SCIMUserTest {

	@isTest static void testParse() {
		// arrange
		String json = '{\"schemas\":[\"urn:scim:schemas:core:1.0\",\"urn:scim:schemas:extension:enterprise:1.0\",\"urn:salesforce:schemas:extension:00D30000001bZxaEAE\"],\"id\":\"00530000008xIlOAAU\",\"userName\":\"demoadmin@identity.org\",\"externalId\":\"adminqa@qaresponder.info\",\"name\":{\"formatted\":\"Demo Admin\",\"familyName\":\"Admin\",\"givenName\":\"Demo\"},\"displayName\":\"Demo Admin\",\"nickName\":\"demoadmin\",\"emails\":[{\"type\":\"work\",\"primary\":true,\"value\":\"adminqa@qaresponder.info\"}],\"phoneNumbers\":[{\"type\":\"work\",\"value\":\"1234567\"}],\"photos\":[{\"type\":\"photo\",\"value\":\"https://customer--c.na1.content.force.com/profilephoto/72930000000UxTS/F\"},{\"type\":\"thumbnail\",\"value\":\"https://customer--c.na1.content.force.com/profilephoto/72930000000UxTS/T\"}],\"userType\":\"Standard\",\"preferredLanguage\":\"en_US\",\"locale\":\"en_US\",\"active\":true,\"entitlements\":[{\"value\":\"00e30000001y7a7AAA\",\"display\":\"Identity Admin\",\"primary\":true},{\"value\":\"0PS30000000PVEPGA4\",\"display\":\"IdentityConnect\",\"primary\":false},{\"value\":\"0PS30000000PVZOGA4\",\"display\":\"StoreAdmin\",\"primary\":false},{\"value\":\"0PS30000000PVZPGA4\",\"display\":\"StoreUser\",\"primary\":false},{\"value\":\"0PS30000000PhouGAC\",\"display\":\"OpenID_App_Access\",\"primary\":false},{\"value\":\"0PS30000000PigwGAC\",\"display\":\"Matrix_Admin\",\"primary\":false},{\"value\":\"0PS30000000PitMGAS\",\"display\":\"LDS_Demo_Access\",\"primary\":false},{\"value\":\"0PS30000000PjT0GAK\",\"display\":\"FooTracker_Developer\",\"primary\":false}],\"groups\":[],\"roles\":[{\"value\":\"00E30000001RuAaEAK\",\"display\":\"Admin\"}],\"urn:scim:schemas:extension:enterprise:1.0\":{\"organization\":\"00D30000001bZxaEAE\"},\"urn:salesforce:schemas:extension:00D30000001bZxaEAE\":{\"GoogleID__c\":\"111632884813494120524\",\"AD_Guid__c\":\"%3CGUID%3Dc4422f5d3d3b0b4aa774fc1bdfe2a398%3E\",\"Has_Registered_2FA__c\":false,\"isSelfRegistered__c\":false,\"randomUsername__c\":\"user1@wave-demo.org\"},\"meta\":{\"created\":\"2013-09-25T10:50:42Z\",\"lastModified\":\"2015-07-01T09:21:35Z\",\"version\":\"eb4043f3ff6066c98c9286832f6d818250d7801b\"}}';
		System.debug('json ' + json);
		// act
		SCIMUser obj = SCIMUser.parse(json);
		System.debug('obj ' + obj);
		// assert
		System.assert(obj != null);
		System.assertEquals('demoadmin@identity.org', obj.userName);
	}
	@isTest static void testUnParse() {
		// Create a test user - changes will be reverted automatically by Salesforce
		Profile p = [SELECT Id FROM profile WHERE name='Standard User'];
		User user = new User(
				userName = DateTime.now().getTime() +'john.doe@example.org',
				email = 'john.doe@example.org',
				firstName = 'John',
				lastName = 'Doe',
				profileId = p.id,
				alias = 'johndoe',
				TimeZoneSidKey = 'GMT',
				LocaleSidKey = 'en_US',
				EmailEncodingKey = 'ISO-8859-1',
				LanguageLocaleKey = 'en_US',
				License_Cost_Center__c = 'ISF005CH01'
		);
		insert user;

		SCIMUser anUser = new SCIMUser(user.userName, user.lastName, user.firstname, user.email, user.email);
		SCIMUserAttributeGenerator attG = new SCIMUserAttributeGenerator();
		String payload = attG.getSerializedAttributes(anUser);

		System.debug(payload);
	}
}
