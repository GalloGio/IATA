@isTest
private  class LightningConnectedAppHelper_Test {

	@TestSetup
	private static void setup() {

		List<PermissionSet> permissionSets = [SELECT Id, Name FROM PermissionSet WHERE Name = 'GADM'];

		if(permissionSets.isEmpty()) {
			PermissionSet ps = new PermissionSet(Label = 'GADM', Name = 'GADM');
			insert ps;
		}

	}

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

		SCIM_Prov_Connector__c conf = new SCIM_Prov_Connector__c();
		conf.Name = 'Test';
		conf.FYI_Email__c = 'manuel.conde@rightitservices.com';
		conf.Processor_Email__c = 'manuel.conde@rightitservices.com';
		conf.SetupOwnerId=UserInfo.getOrganizationId();
		insert conf;

		Profile p = [SELECT Id FROM Profile WHERE Name='Developer'];
		USER user = new USER (Alias = 'newUser',Email = 'ze@ze.pt', LastName = 'ze',  ProfileId = p.Id, UserName='ze@testorg.com',TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US',EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US');
		Id recTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('One_Id_Service_Provider_Config__c', 'Service_Bundle');

		One_Id_Service_Provider_Config__c oi = new One_Id_Service_Provider_Config__c(Service_Provider_Name__c = 'Bundle',
																					 License_Upgrade_Required__c= true,
																					 Profile_Id__c='a1',
																					 Description__c='qualquer',
																					 Is_Active__c = true, Portal_Visible__c = true,
																					 RecordTypeid = recTypeId, App_Picture_Url__c='oi',
																					 Customer_Type_Activation__c = 'Airline');
		insert oi;

		List<id> userlist = New List<id>();
		userlist.add(user.id);

		List<PermissionSet> psIds = [SELECT Id,name FROM PermissionSet LIMIT 5];

		List<id> idd = New List<id>();
		idd.add(psIds[0].id);

		List<String> userlistst = New List<String>();
		userlistst.add(user.id);

		List<String> idds = New List<String>();
		idds.add(psIds[0].id);


		One_Id_Service_Provider_Config__c rr = new One_Id_Service_Provider_Config__c (Service_Provider_Name__c = 'App 1', Is_Active__c = true, Portal_Visible__c = true, Service_Bundle__c=oi.id,Customer_Type_Activation__c = 'Airline');
		insert rr;
		One_Id_App_Config_Detail__c r = new One_Id_App_Config_Detail__c (One_Id_Service_Provider_Config__c=rr.id, PermissionSet_SSO__c = psIds[0].name, PermissionSet_Provisioning__c = psIds[1].name );
		insert r;
		One_Id_App_Role_Config__c role = new One_Id_App_Role_Config__c (Role_Name__c = 'Admin', One_Id_App_Config_Detail__c = r.id, Role_Description__c = 'desc');
		insert role;

		System.debug('««««««««««««««««««««««««««««««««««««««' + rr);
		System.debug(LoggingLevel.INFO,role);

		try {
			LightningConnectedAppHelper.getPic('vm');

		}
		catch (Exception e) {

		}

		try {
			LightningConnectedAppHelper.getAppDescription('App 1');
			LightningConnectedAppHelper.getAppDescription('empty');
		}
		catch (Exception e) {

		}



		LightningConnectedAppHelper_Test.createData();
		Test.startTest();

		LightningConnectedAppHelper.ConnectedAppsList();

		LightningConnectedAppHelper.getroles('Bundle');
		LightningConnectedAppHelper.getAppTerms('Bundle');
		LightningConnectedAppHelper.submit('Bundle', 'Admin');
		LightningConnectedAppHelper.massAssignPermissionSets(userlist,idd);
		LightningConnectedAppHelper.massassignpermissionset(userlistst,idds);

		Test.stopTest();


	}

	static testMethod void TestResetSCIMProvisioning(){

		List<PermissionSet> psIds = [SELECT Id,name FROM PermissionSet LIMIT 5];
		Id recTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('One_Id_Service_Provider_Config__c', 'Service_Bundle');
		One_Id_Service_Provider_Config__c oi = new One_Id_Service_Provider_Config__c(Service_Provider_Name__c = 'Bundle',
				License_Upgrade_Required__c= true,
				Profile_Id__c='a1',
				Description__c='qualquer',
				Is_Active__c = true, Portal_Visible__c = true,
				RecordTypeid = recTypeId, App_Picture_Url__c='oi',
				Customer_Type_Activation__c = 'Airline');
		insert oi;

		One_Id_Service_Provider_Config__c rr = new One_Id_Service_Provider_Config__c (Service_Provider_Name__c = 'App 1', Is_Active__c = true, Portal_Visible__c = true, Service_Bundle__c=oi.id, Customer_Type_Activation__c = 'Airline');
		insert rr;

		One_Id_App_Config_Detail__c r = new One_Id_App_Config_Detail__c (One_Id_Service_Provider_Config__c=rr.id, PermissionSet_SSO__c = psIds[0].name, PermissionSet_Provisioning__c = psIds[1].name );
		insert r;

		One_Id_App_Role_Config__c role = new One_Id_App_Role_Config__c (Role_Name__c = 'Admin', One_Id_App_Config_Detail__c = r.id, Role_Description__c = 'desc');
		insert role;



		One_Id_User_Applications__c anUserApp = new One_Id_User_Applications__c();
		anUserApp.Application__c = r.id;
		anUserApp.One_Id_Service_Provider_Config__c = rr.id;
		anUserApp.One_Id_App_Bundle__c = oi.id;
		anUserApp.Identity_User__c = UserInfo.getUserId();
		anUserApp.Provisioning_Status__c = 'Started';
		//anUserApp.User_Provisioning_Request__c = uprov.id;
		anUserApp.action__c = 'Add';
		anUserApp.App_Key__c = LightningConnectedAppHelper.OneIdBuildUserAppKey(anUserApp);
		insert anUserApp;

		One_Id_Service_Provider_Config__c oi1 = new One_Id_Service_Provider_Config__c(Service_Provider_Name__c = 'Bundle',
				License_Upgrade_Required__c= true,
				Profile_Id__c='a1',
				Description__c='qualquer',
				Is_Active__c = true, Portal_Visible__c = true,
				RecordTypeid = recTypeId, App_Picture_Url__c='oi',
				Customer_Type_Activation__c = 'Airline');
		insert oi1;

		One_Id_Service_Provider_Config__c rr1 = new One_Id_Service_Provider_Config__c (Service_Provider_Name__c = 'App 1', Is_Active__c = true, Portal_Visible__c = true, Service_Bundle__c=oi1.id,Customer_Type_Activation__c = 'Airline');
		insert rr1;

		One_Id_App_Config_Detail__c r1 = new One_Id_App_Config_Detail__c (One_Id_Service_Provider_Config__c=rr1.id, PermissionSet_SSO__c = psIds[0].name, PermissionSet_Provisioning__c = psIds[1].name );
		insert r1;

		One_Id_App_Role_Config__c role1 = new One_Id_App_Role_Config__c (Role_Name__c = 'Admin', One_Id_App_Config_Detail__c = r1.id, Role_Description__c = 'desc');
		insert role1;

		One_Id_User_Applications__c anUserApp1 = new One_Id_User_Applications__c();
		anUserApp1.Application__c = r1.id;
		anUserApp1.One_Id_Service_Provider_Config__c = rr1.id;
		anUserApp1.One_Id_App_Bundle__c = oi1.id;
		anUserApp1.Identity_User__c = UserInfo.getUserId();
		anUserApp1.Provisioning_Status__c = 'Started';
		anUserApp1.action__c = 'Remove';
		//anUserApp.User_Provisioning_Request__c = uprov.id;
		anUserApp1.App_Key__c = LightningConnectedAppHelper.OneIdBuildUserAppKey(anUserApp1);
		insert anUserApp1;

		List<One_Id_User_Applications__c> processList = new List<One_Id_User_Applications__c>();
		processList.add(anUserApp);
		processList.add(anUserApp1);
		String serialized = JSON.serialize(processList);
		LightningConnectedAppHelper.syncUserApps(serialized);

		Set<Id> setId1 = new Set<id>();
		setId1.add(anUserApp1.id);
		LightningConnectedAppHelper.resetSCIMProvisioning(setId1);

		One_Id_User_Applications__c anUserApp2 = new One_Id_User_Applications__c();
		anUserApp2.Application__c = r1.id;
		anUserApp2.One_Id_Service_Provider_Config__c = rr1.id;
		anUserApp2.One_Id_App_Bundle__c = oi1.id;
		anUserApp2.Identity_User__c = UserInfo.getUserId();
		anUserApp2.Provisioning_Status__c = 'Started';
		anUserApp2.action__c = 'Remove';
		//anUserApp.User_Provisio+ning_Request__c = uprov.id;
		anUserApp1.App_Key__c = LightningConnectedAppHelper.OneIdBuildUserAppKey(anUserApp1);
		insert anUserApp2;

		Set<Id> setId2 = new Set<id>();
		setId2.add(anUserApp2.id);

		LightningConnectedAppHelper.deleteSObjects(setId2);


	}

	static void createData(){


		IATA_ISO_Country__c ISO_Country = new IATA_ISO_Country__c(ISO_Code__c='TT',Name='test');
		insert ISO_Country;

		Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
		Account acc = ISSP_ObjectFactory.createNewAccount();
		acc.IATACode__c = '100';
		acc.IATA_ISO_Country__c = ISO_Country.Id;
		acc.RecordTypeId = recordTypeId;
		acc.Airline_designator__c = 'TT';
		acc.Name = 'TestAccount';
		insert acc;

		 Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
		Contact con = ISSP_ObjectFactory.createNewContact();
		con.AccountId = acc.Id;
		con.LastName = 'test';
		con.Email = 'test.issp.registration@testisspregistration.com';
		con.RecordTypeId = rtId;
		insert con;

		System.assert(con.id !=null,'Contact must be created');
		User newUser = new User(alias = 'dsfsdfds',
				email = con.email,
				emailencodingkey = 'UTF-8',
				firstname = con.firstName,
				lastname = con.lastname,
				languagelocalekey = 'en_US',
				localesidkey = 'en_US',
				contactId = con.Id,
				timezonesidkey = 'Asia/Dubai',
				Username = ISSP_Utilities.buildPortalUserName(con.email),
				PortalRole = 'Manager',
				CommunityNickname = con.email.substring(0, con.email.indexOf('@'))+Datetime.now().formatLong().substring(10,15),
				ProfileId = ISSP_Constant.TEST_User_ProfileID,
				IsActive = true);
		insert newUser;




   }
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
		//System.assertEquals('jane.doe@scimuserprov.test', response.outputParameters.get(UserProvisioningUtils.PARAM_EXTERNAL_USERNAME));
		//System.assertEquals('daisypop89@gmail.com', response.outputParameters.get(UserProvisioningUtils.PARAM_EXTERNAL_EMAIL));
		System.assertEquals('Daisy', response.outputParameters.get(UserProvisioningUtils.PARAM_EXTERNAL_FIRSTNAME));
		System.assertEquals('Jensen', response.outputParameters.get(UserProvisioningUtils.PARAM_EXTERNAL_LASTNAME));
	}
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

	static testMethod void testProvisioning()
	{


		System.Test.setMock(HttpCalloutMock.class, new HttpResponseGenerator());

		UserProvisioningRequest up = UserProvisioningTestUtils.userProvisioningRequestVM('ISAGO Provisioning', 'Create', 'New');

		Map<String,Object> inputParams = new Map<String,Object>();
		if (true) {
			inputParams.put(UserProvisioningUtils.PARAM_UPR_ID, up.id);
			inputParams.put(UserProvisioningUtils.PARAM_USERPAYLOAD, '{\n  "name" : {\n    "familyName" : "Jensen",\n    "givenName" : "Daisy"\n  },\n  "emails" : [ {\n    "value" : "daisypop89@gmail.com"\n  } ],\n  "schemas" : [ "urn:scim:schemas:core:1.0" ]\n}');
		}

		Process.PluginResult tes = UserProvisioningTestUtils.runPlugin(new SCIMCreateUserPlugin(), inputParams);





	}

	@IsTest
	private static void gadmSubmitTest() {

		createData();

		List<PermissionSet> psIds = [SELECT Id,name FROM PermissionSet LIMIT 5];
		Id recTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('One_Id_Service_Provider_Config__c', 'Service_Bundle');
		One_Id_Service_Provider_Config__c bundleConfig = new One_Id_Service_Provider_Config__c(Service_Provider_Name__c = 'GADM',
				License_Upgrade_Required__c= true,
				Profile_Id__c='a1',
				Description__c='some description',
				Is_Active__c = true, Portal_Visible__c = true,
				RecordTypeid = recTypeId, App_Picture_Url__c='oi',
				Customer_Type_Activation__c = 'Airline');
		insert bundleConfig;

		One_Id_Service_Provider_Config__c serviceProviderConfig = new One_Id_Service_Provider_Config__c (Service_Provider_Name__c = 'GADM', Is_Active__c = true, Portal_Visible__c = true, Service_Bundle__c= bundleConfig.id, Customer_Type_Activation__c = 'Airline');
		insert serviceProviderConfig;

		One_Id_App_Config_Detail__c appConfigDetail = new One_Id_App_Config_Detail__c (One_Id_Service_Provider_Config__c= serviceProviderConfig.id, PermissionSet_SSO__c = psIds[0].name, PermissionSet_Provisioning__c = psIds[1].name );
		insert appConfigDetail;

		One_Id_App_Role_Config__c role = new One_Id_App_Role_Config__c (Role_Name__c = 'Power User', One_Id_App_Config_Detail__c = appConfigDetail.id, Role_Description__c = 'role description');
		insert role;

		One_Id_App_Role_Config__c role2 = new One_Id_App_Role_Config__c (Role_Name__c = 'GADM User', One_Id_App_Config_Detail__c = appConfigDetail.id, Role_Description__c = 'role2 description');
		insert role2;

		Account_Roles__c accountRoles = new Account_Roles__c();
		accountRoles.Name = 'GADM Participant';
		insert accountRoles;

		Id externalRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact_Roles__c', 'External');

		Contact_Roles__c contactRoles = new Contact_Roles__c();
		contactRoles.Name = 'GADM User';
		contactRoles.RecordTypeId = externalRecordTypeId;
		insert contactRoles;

		Contact_Roles__c contactRoles2 = new Contact_Roles__c();
		contactRoles2.Name = 'Service Power User';
		contactRoles2.RecordTypeId = externalRecordTypeId;
		insert contactRoles2;

		Portal_Applications__c portalApplications = TestDataFactory_PortalApplications.createDefaultPortalApplication(1).get(0);
		portalApplications.Name = 'GADM';
		insert portalApplications;

		Contact_Role_Service__c gadmUserRoleService = new Contact_Role_Service__c();
		gadmUserRoleService.Service__c = portalApplications.Id;
		gadmUserRoleService.Contact_Role__c = contactRoles.Id;
		insert gadmUserRoleService;

		Contact_Role_Service__c powerUserRoleService = new Contact_Role_Service__c();
		powerUserRoleService.Service__c = portalApplications.Id;
		powerUserRoleService.Contact_Role__c = contactRoles2.Id;
		insert powerUserRoleService;

		Account_Role_Services__c accountRoleServices = new Account_Role_Services__c();
		accountRoleServices.Portal_Service__c = portalApplications.Id;
		accountRoleServices.Account_Roles__c = accountRoles.Id;
		insert accountRoleServices;

		User testUser = [SELECT Id FROM User WHERE Email = 'test.issp.registration@testisspregistration.com'];

		Test.startTest();

		System.runAs(testUser) {
			LightningConnectedAppHelper.submit('GADM', 'Power User');
		}

		Test.stopTest();

		List<Account_Contact_Role__c> accountContactRoles = [SELECT Id, Contact_Roles__r.Name FROM Account_Contact_Role__c];
		//functional: power user, gadm user; group gadm user with parent account
		System.assertEquals(3, accountContactRoles.size(), 'Not all Account_Contact_Role__c objects were created!');

		Set<Id> roleIds = new Set<Id>();
		Set<String> roleNames =new Set<String>();
		for(Account_Contact_Role__c accountContactRole : accountContactRoles) {
			roleNames.add(accountContactRole.Contact_Roles__r.Name);
			roleIds.add(accountContactRole.Id);
		}

		System.assertEquals(true, roleNames.contains('Service Power User'), 'Account_Contact_Role__c for Power User was not created!');
		System.assertEquals(true, roleNames.contains('GADM User'), 'Account_Contact_Role__c for GADM User was not created!');

		List<Contact_Role_Service_Access__c> serviceAccesses = [SELECT Id, Status__c FROM Contact_Role_Service_Access__c WHERE Contact_Role__c IN :roleIds];
		for(Contact_Role_Service_Access__c serviceAccess : serviceAccesses) {
			System.assertEquals('Pending', serviceAccess.Status__c, 'Contact_Role_Service_Access__c.Status__c should be Pending!');
		}

	}


	@IsTest
	private static void gadmConnectedAppsListTest() {

		createData();

		User testUser = [SELECT Id FROM User WHERE Email = 'test.issp.registration@testisspregistration.com'];

		PermissionSet permissionSet = [SELECT Id, Name FROM PermissionSet WHERE Name = 'GADM'];

		Id recTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('One_Id_Service_Provider_Config__c', 'Service_Bundle');
		One_Id_Service_Provider_Config__c bundleConfig = new One_Id_Service_Provider_Config__c(Service_Provider_Name__c = 'GADM',
				License_Upgrade_Required__c= true,
				Profile_Id__c='a1',
				Description__c='some description',
				Is_Active__c = true, Portal_Visible__c = true,
				RecordTypeid = recTypeId, App_Picture_Url__c='oi',
				Customer_Type_Activation__c = 'Airline');
		insert bundleConfig;

		One_Id_Service_Provider_Config__c serviceProviderConfig = new One_Id_Service_Provider_Config__c (Service_Provider_Name__c = 'GADM', Is_Active__c = true, Portal_Visible__c = true, Service_Bundle__c= bundleConfig.id, Customer_Type_Activation__c = 'Airline');
		insert serviceProviderConfig;

		One_Id_App_Config_Detail__c appConfigDetail = new One_Id_App_Config_Detail__c (One_Id_Service_Provider_Config__c= serviceProviderConfig.id, PermissionSet_SSO__c = permissionSet.Name);
		insert appConfigDetail;

		Test.startTest();

		List<String> userApps;

		System.runAs(testUser) {

			PermissionSetAssignment psa = new PermissionSetAssignment();
			psa.AssigneeId = testUser.Id;
			psa.PermissionSetId = permissionSet.Id;
			insert psa;

			userApps = LightningConnectedAppHelper.ConnectedAppsList();
		}

		Test.stopTest();

		System.assertEquals(false, userApps.contains('GADM'), 'GADM app should not be displayed if user has already access to it!');

	}

}
