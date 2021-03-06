@isTest
public class PASSSCIMMessageEnhancer_Test {

	@testSetup static void methodTest(){
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='France',ISO_Code__c='FR', Region__c = 'Europe')  ;
		insert ctry ;

		ID rtAgency = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
		IATA_ISO_Country__c italy = new IATA_ISO_Country__c(Name='Italy', ISO_Code__c='IT', Region__c='Europe', ISS_Office_Location__c='Italy');
		insert italy;

		String SECTORPAX = 'Travel Agent';
		String CATEGORYPAX = 'IATA Passenger Sales Agent';
		String LOCCLASSPAX = 'P';
		Account acc = new Account(RecordTypeId = rtAgency, Name = 'My Travels', IATAcode__c = '1111110', IATA_ISO_Country__c = italy.id,
						 Sector__c = SECTORPAX, Category__c = CATEGORYPAX, Location_Class__c = LOCCLASSPAX, Location_Type__c = 'HO',
						 Status__c = AMS_Utils.ACC_S9_APPROVED);
		insert acc;
		Contact contact = ISSP_ObjectFactory.createNewContact();
		contact.AccountId = acc.Id;
		contact.Email='email@email.com';
		insert contact;
		User testUser = ISSP_ObjectFactory.createPortalUser(contact);
	}
	
	static testMethod void passTest() {


		String json = '{\"schemas\":[\"urn:scim:schemas:core:1.0\",\"urn:scim:schemas:extension:enterprise:1.0\",\"urn:salesforce:schemas:extension:00D30000001bZxaEAE\"],\"id\":\"00530000008xIlOAAU\",\"userName\":\"demoadmin@identity.org\",\"externalId\":\"adminqa@qaresponder.info\",\"name\":{\"formatted\":\"Demo Admin\",\"familyName\":\"Admin\",\"givenName\":\"Demo\"},\"displayName\":\"Demo Admin\",\"nickName\":\"demoadmin\",\"emails\":[{\"type\":\"work\",\"primary\":true,\"value\":\"adminqa@qaresponder.info\"}],\"phoneNumbers\":[{\"type\":\"work\",\"value\":\"1234567\"}],\"photos\":[{\"type\":\"photo\",\"value\":\"https://customer--c.na1.content.force.com/profilephoto/72930000000UxTS/F\"},{\"type\":\"thumbnail\",\"value\":\"https://customer--c.na1.content.force.com/profilephoto/72930000000UxTS/T\"}],\"userType\":\"Standard\",\"preferredLanguage\":\"en_US\",\"locale\":\"en_US\",\"active\":true,\"entitlements\":[{\"value\":\"00e30000001y7a7AAA\",\"display\":\"Identity Admin\",\"primary\":true},{\"value\":\"0PS30000000PVEPGA4\",\"display\":\"IdentityConnect\",\"primary\":false},{\"value\":\"0PS30000000PVZOGA4\",\"display\":\"StoreAdmin\",\"primary\":false},{\"value\":\"0PS30000000PVZPGA4\",\"display\":\"StoreUser\",\"primary\":false},{\"value\":\"0PS30000000PhouGAC\",\"display\":\"OpenID_App_Access\",\"primary\":false},{\"value\":\"0PS30000000PigwGAC\",\"display\":\"Matrix_Admin\",\"primary\":false},{\"value\":\"0PS30000000PitMGAS\",\"display\":\"LDS_Demo_Access\",\"primary\":false},{\"value\":\"0PS30000000PjT0GAK\",\"display\":\"FooTracker_Developer\",\"primary\":false}],\"groups\":[],\"roles\":[{\"value\":\"00E30000001RuAaEAK\",\"display\":\"Admin\"}],\"urn:scim:schemas:extension:enterprise:1.0\":{\"organization\":\"00D30000001bZxaEAE\"},\"urn:salesforce:schemas:extension:00D30000001bZxaEAE\":{\"GoogleID__c\":\"111632884813494120524\",\"AD_Guid__c\":\"%3CGUID%3Dc4422f5d3d3b0b4aa774fc1bdfe2a398%3E\",\"Has_Registered_2FA__c\":false,\"isSelfRegistered__c\":false,\"randomUsername__c\":\"user1@wave-demo.org\"},\"meta\":{\"created\":\"2013-09-25T10:50:42Z\",\"lastModified\":\"2015-07-01T09:21:35Z\",\"version\":\"eb4043f3ff6066c98c9286832f6d818250d7801b\"}}';
		PASSMessageEnhancer instance = new PASSMessageEnhancer();
		new PASSMessageEnhancer('PASS');

		Map<String, Object> inputParams = new Map<String, Object>();
		inputParams.put(UserProvisioningUtils.PARAM_USERPAYLOAD, json);
		inputParams.put(SCIMUserAttributeGenerator.PARAM_USERNAME, 'dummy@iata.org');
		inputParams.put(SCIMUserAttributeGenerator.PARAM_FIRSTNAME, 'dummy');
		inputParams.put(SCIMUserAttributeGenerator.PARAM_LASTNAME, 'dummy');
		inputParams.put(SCIMUserAttributeGenerator.PARAM_EXTERNALID, '3213213');
		inputParams.put(SCIMUserAttributeGenerator.PARAM_EMAIL, 'email@email.com');

		Process.PluginRequest request = new Process.PluginRequest(inputParams);
		instance.enhanceMessage(request);
		SCIMUser passUser = instance.enhanceMessage(request); // Creates a SCIMUser used on PASS flow
		System.assertEquals('dummy@iata.org', passUser.username);
	}

	@isTest
	static void UserProvisioningRequestUpdateTrigger(){
		User testUser = new User(alias = 'dsfsdfds',
								email = 'con.email12312313132PASSTEST@email.com',
								emailencodingkey = 'UTF-8',
								firstname = 'TestUser',
								lastname = 'UserLastName',
								languagelocalekey = 'en_US',
								localesidkey = 'en_US',
								timezonesidkey = 'Asia/Dubai',
								Username = 'Username123123131313132@email.com',
								ProfileId = [select Id from Profile where Name='System Administrator' limit 1].Id,
								License_Cost_Center__c = 'ITO005CH01',
								IsActive = true);
		insert testUser;
		List<PermissionSetAssignment> oldpermissionList = [SELECT Id,PermissionSet.Name from PermissionSetAssignment WHERE AssigneeId=:testUser.Id];
		Test.startTest();
			UserProvisioningRequest u = new UserProvisioningRequest();
			u.SalesforceUserId = testUser.Id;
			u.ConnectedAppId = [SELECT id FROM ConnectedApplication WHERE name = 'Pass User Prov' LIMIT 1].id;
			u.State = 'New';
			u.Operation = 'Create';
			u.ApprovalStatus = 'Required';
			database.insert(u);
			u.state = 'Completed';
			database.update(u);
			Test.stopTest();
			//Upon insert of the UserProvisioningRequest, it will run the PASS flow and assign the Permisison Set to the User
			List<PermissionSetAssignment> permissionList = [SELECT Id,PermissionSet.Name from PermissionSetAssignment WHERE AssigneeId=:testUser.Id AND PermissionSet.Name LIKE 'PASS%'];
			System.assertEquals(1,permissionList.size());
	}
}
