@IsTest(SeeAllData = false)
public with sharing class SCIMProvisioningRequestUpdateTest {

    private static final String PERM_SET_PROV='IFG_Provisioning_Prod';
	private static final String PERM_SET_SSO='IFG_SSO_Production';
	private static final String CON_APP_PROV='IFG Provisioning PreProd Conn App';

	@testSetup static void testObjsInit() {
		System.debug('basto1p - TEST IMITIALISING... testStandardObjsInit');

		////////////////////////////////
		// Configurations SET
		////////////////////////////////
		SCIM_Prov_Connector__c conf = new SCIM_Prov_Connector__c();
		conf.Name = 'Test';
		conf.FYI_Email__c = 'manuel.conde@rightitservices.com';
		conf.Processor_Email__c = 'manuel.conde@rightitservices.com';
		conf.SetupOwnerId = UserInfo.getOrganizationId();
		insert conf;

		System.debug('basto1p - testConfigObjsInit SCIM_Prov_Connector__c conf=' + conf);

		Id recTypeId = OneIdProvisioningDAO.AppRecordTypesConfig.get('One_Id_Service_Provider_Config__c').get(
				'Service_Bundle');

		One_Id_Service_Provider_Config__c oi = new One_Id_Service_Provider_Config__c(
				Service_Provider_Name__c = SCIMServProvManager.PRE_PROD_SRV_PROV,
				License_Upgrade_Required__c = true,
				Profile_Id__c = 'a1',
				Description__c = 'qualquer',
				Is_Active__c = true,
				Portal_Visible__c = false,
				RecordTypeid = recTypeId,
				App_Picture_Url__c = 'oi',
				Customer_Type_Activation__c='Airline');
		insert oi;

		System.debug('basto1p - testConfigObjsInit One_Id_Service_Provider_Config__c oi=' + oi);

		One_Id_Service_Provider_Config__c rr =
				new One_Id_Service_Provider_Config__c (
						Service_Provider_Name__c = SCIMServProvManager.PRE_PROD_SRV_PROV,
						Is_Active__c = true,
						Portal_Visible__c = false,
						RecordTypeid = recTypeId,
						Service_Bundle__c = oi.id,
						Customer_Type_Activation__c='Airline');
		insert rr;

		System.debug('basto1p - testConfigObjsInit One_Id_Service_Provider_Config__c rr=' + rr);


		List<PermissionSet> psIds = [SELECT Id,name FROM PermissionSet LIMIT 5];
		One_Id_App_Config_Detail__c r =
				new One_Id_App_Config_Detail__c (
						One_Id_Service_Provider_Config__c = rr.id,
						PermissionSet_SSO__c = PERM_SET_SSO,
						PermissionSet_Provisioning__c = PERM_SET_PROV,
						Connected_App_Provisioning_Name__c = CON_APP_PROV
				);
		insert r;

		/*
		List<PermissionSet> psIds = [SELECT Id,name FROM PermissionSet LIMIT 5];
		One_Id_App_Config_Detail__c r =
				new One_Id_App_Config_Detail__c (
						One_Id_Service_Provider_Config__c=rr.id,
						PermissionSet_SSO__c = psIds[0].name,
						PermissionSet_Provisioning__c = psIds[1].name );
		insert r;
		*/

		/*
		// Creating the permission set
		PermissionSet psProv = new PermissionSet(Label='IFG_Provisioning_ProdTest',Name='IFG_Provisioning_ProdTest');
		insert psProv;

		PermissionSet psSSO = new PermissionSet(Label='IFG_SSO_ProductionTest',Name='IFG_SSO_ProductionTest');
		insert psSSO;
		*/

		////////////////////////////////////////
		// Accounts SET
		///////////////////////////////////////
		Account parent = ISSP_ObjectFactory.createNewAccount();
		parent.BillingCity = 'test';
		parent.Name = 'test';
		insert parent;
		System.debug('basto1p - parent Id: ' + parent.Id);

		Account childAccount = ISSP_ObjectFactory.createNewAccount();
		childAccount.BillingCity = 'test2';
		childAccount.Name = 'test2';
		childAccount.Site = 'headSite';
		childAccount.sector__c = 'Airline';
		childAccount.Top_Parent__c = parent.Id;
		insert childAccount;
		System.debug('basto1p - child Id: ' + childAccount.Id);


		////////////////////////////////////////
		// Contacts/Users SET
		///////////////////////////////////////

		//create contact3 with same email as contact 1
		Contact con3 = new Contact();
		con3.FirstName = 'test3';
		con3.LastName = 'test3';
		con3.AccountId= childAccount.Id;
		con3.Email = 'Test@test33.com';
		insert con3;
		System.debug('basto1p - con3 Id: ' + con3.Id);

		User newUser3 = ISSP_ObjectFactory.createPortalUser(con3);
		System.debug('basto1p - newUser3=' + newUser3);
		con3.OwnerId = newUser3.Id;
		update con3;
/*
		newUser3=[SELECT Id, FederationIdentifier FROM User WHERE ContactId=:con3.Id];
		newUser3.FederationIdentifier='';//to be able to test fill federation ids
		update newUser3;
*/
		//////////////////////////////
		// Create SCIM application to handle access
		/////////////////////////////
		Portal_Applications__c portApp = new Portal_Applications__c(
				Name = 'My Test App',
				Provisioning_Type__c =SCIMServProvManager.PROV_TYP_SCIM,
				SCIM_App_Name__c = SCIMServProvManager.PRE_PROD_SRV_PROV
		);
		insert portApp;
		system.debug('basto1p portApp='+portApp);
	}


	@IsTest
	static void testSCIMProvisioningRequestUpdateFailures1() {
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = OneIdUtils.getCommunityUrlName()+'/services/apexrest/SCIMProvisioningRequestUpdate';  //Request URL
		req.httpMethod = 'POST';//HTTP Request Type

		system.debug('basto1p - req.requestURI='+req.requestURI);

		RestContext.request = req;
		RestContext.response= res;

		Contact con3=[SELECT Id FROM CONTACT WHERE FirstName = 'test3' AND Email = 'Test@test33.com'];
		Portal_Applications__c portApp=
			[SELECT Id FROM Portal_Applications__c
			WHERE
			Name = 'My Test App' AND
			Provisioning_Type__c =:SCIMServProvManager.PROV_TYP_SCIM AND
			SCIM_App_Name__c =:SCIMServProvManager.PRE_PROD_SRV_PROV];

		//User/Contact does not exist
		try {
			//Call REST Service
			SCIMProvisioningRequestUpdate.doPost('paubasError@hotmail.com', true, SCIMServProvManager.PRE_PROD_SRV_PROV);
			System.debug('OSCIMProvisioningRequestUpdateTest After Call SCIMProvisioningRequestUpdate.doPost responseBody='+res);
		}
		catch(SCIMServProvManager.SCIMException ex)
		{
			System.AssertEquals(ex.getExcepCode(), SCIMServProvManager.ERR_SCIM_REST_INVALID_ROW_RESULT_EX_1);
		}

		/*
		//Test invalid row result because more than one contact exists for the given email
		try {
			SCIMProvisioningRequestUpdate.doPost('Test@test11.com', true, SCIMServProvManager.PRE_PROD_SRV_PROV);
		}
		catch(SCIMServProvManager.SCIMException ex)
		{
			System.AssertEquals(ex.getExcepCode(), SCIMServProvManager.ERR_SCIM_REST_INVALID_ROW_RESULT_EX_1);
		}
		*/

		//Test invalid row result because contact exists but no permission access row exists for it
		try {
			SCIMProvisioningRequestUpdate.doPost('Test@test33.com', true, SCIMServProvManager.PRE_PROD_SRV_PROV);
		}
		catch(SCIMServProvManager.SCIMException ex)
		{
			System.AssertEquals(ex.getExcepCode(), SCIMServProvManager.ERR_SCIM_REST_INVALID_ROW_RESULT_EX_1);
		}


		//INSERT access row in portal apllciation rights for contact 3
		Portal_Application_Right__c PortAccessRigthItem3= new Portal_Application_Right__c();
		PortAccessRigthItem3.Contact__c=con3.Id;
		PortAccessRigthItem3.Portal_Application__c=portApp.Id;
		//PortAccessRigthItem3.Right__c=SCIMServProvManager.IATA_STS_ACCESS_DENIED;
		//PortAccessRigthItem3.Technical_Provisioning_Status__c=SCIMServProvManager.TECH_STS_IATA_ACCESS_DENIED;
		PortAccessRigthItem3.Right__c=SCIMServProvManager.IATA_STS_REQUESTED;
		PortAccessRigthItem3.Technical_Provisioning_Status__c=SCIMServProvManager.TECH_STS_REQUESTED;
		insert PortAccessRigthItem3;
		system.debug('basto1p PortAccessRigthItem3='+PortAccessRigthItem3);

		//TEst invalid context because not ready for this scenario yet
		try {
			SCIMProvisioningRequestUpdate.doPost('Test@test33.com', true, SCIMServProvManager.PRE_PROD_SRV_PROV);
		}
		catch(SCIMServProvManager.SCIMException ex)
		{
			System.AssertEquals(ex.getExcepCode(), SCIMServProvManager.ERR_SCIM_REST_INVALID_CONTEXT);
		}

		try {
			//Call REST Service
			SCIMProvisioningRequestUpdate.doPost('Test@test33.com', false, SCIMServProvManager.PRE_PROD_SRV_PROV);
			System.debug('OSCIMProvisioningRequestUpdateTest After Call SCIMProvisioningRequestUpdate.doPost responseBody='+res);
		}
		catch(SCIMServProvManager.SCIMException ex)
		{
			System.AssertEquals(ex.getExcepCode(), SCIMServProvManager.ERR_SCIM_REST_INVALID_CONTEXT);
		}
	}


	@IsTest
	static void testSCIMProvisioningRequestUpdateFailures2() {
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = OneIdUtils.getCommunityUrlName()+'/services/apexrest/SCIMProvisioningRequestUpdate';  //Request URL
		req.httpMethod = 'POST';//HTTP Request Type

		system.debug('basto1p - req.requestURI='+req.requestURI);

		RestContext.request = req;
		RestContext.response= res;

		Contact con3=[SELECT Id FROM CONTACT WHERE FirstName = 'test3' AND Email = 'Test@test33.com'];

		Portal_Applications__c portApp=
		[SELECT Id FROM Portal_Applications__c
				WHERE
				Name = 'My Test App' AND
				Provisioning_Type__c =:SCIMServProvManager.PROV_TYP_SCIM AND
				SCIM_App_Name__c =:SCIMServProvManager.PRE_PROD_SRV_PROV];

		//Xreate app with same SCIM key name but is a diferent app in Portal_Applications__c
		Portal_Applications__c portApp2 = new Portal_Applications__c(
				Name = 'My Test App2',
				Provisioning_Type__c =SCIMServProvManager.PROV_TYP_SCIM,
				SCIM_App_Name__c = SCIMServProvManager.PRE_PROD_SRV_PROV
		);
		insert portApp2;
		system.debug('basto1p portApp='+portApp2);

		//INSERT row in portal apllciation rights contact 1
		Portal_Application_Right__c PortAccessRigthItem= new Portal_Application_Right__c();
		PortAccessRigthItem.Contact__c=con3.Id;
		PortAccessRigthItem.Portal_Application__c=portApp.Id;
		PortAccessRigthItem.Right__c=SCIMServProvManager.IATA_STS_REQUESTED;
		PortAccessRigthItem.Technical_Provisioning_Status__c=SCIMServProvManager.TECH_STS_REQUESTED;
		insert PortAccessRigthItem;
		system.debug('basto1p PortAccessRigthItem='+PortAccessRigthItem);

		//INSERT row in portal apllciation rights app 2 with same SCIM Provision App Key for same contact
		Portal_Application_Right__c PortAccessRigthItem2= new Portal_Application_Right__c();
		PortAccessRigthItem2.Contact__c=con3.Id;
		PortAccessRigthItem2.Portal_Application__c=portApp2.Id;
		PortAccessRigthItem2.Right__c=SCIMServProvManager.IATA_STS_REQUESTED;
		PortAccessRigthItem2.Technical_Provisioning_Status__c=SCIMServProvManager.TECH_STS_REQUESTED;
		insert PortAccessRigthItem2;
		system.debug('basto1p - PortAccessRigthItem2='+PortAccessRigthItem2);

		//User exists duplicated (2 different user same email) in Access Rights
		try{
			//Call REST Service
			SCIMProvisioningRequestUpdate.doPost('Test@test33.com', true, SCIMServProvManager.PRE_PROD_SRV_PROV);
			System.debug('OSCIMProvisioningRequestUpdateTest After Call SCIMProvisioningRequestUpdate.doPost responseBody='+res);
		}
		catch(SCIMServProvManager.SCIMException ex)
		{
			System.AssertEquals(ex.getExcepCode(), SCIMServProvManager.ERR_SCIM_REST_INVALID_ROW_RESULT_EX_1);
		}
	}

	@IsTest
	static void testSCIMProvisioningRequestUpdateSucess1() {
		testSuccessCases(true);

		Contact con3=[SELECT Id FROM CONTACT WHERE FirstName = 'test3' AND Email = 'Test@test33.com'];

		Portal_Application_Right__c PortAccRightRow=
		[SELECT Technical_Provisioning_Status__c FROM Portal_Application_Right__c
		WHERE Contact__r.Id = :con3.Id
		and Portal_Application__r.Provisioning_Type__c = :SCIMServProvManager.PROV_TYP_SCIM
		and Portal_Application__r.SCIM_App_Name__c=:SCIMServProvManager.PRE_PROD_SRV_PROV];

		System.AssertEquals(PortAccRightRow.Technical_Provisioning_Status__c, SCIMServProvManager.TECH_STS_EXT_ACCESS_GRANTED);
		/*
		/////////////////////////////////////////////////////////
		// SET IATA DENIED
		/////////////////////////////////////////////////////////
		PortAccRightRow.Right__c = SCIMServProvManager.IATA_STS_ACCESS_DENIED;
		update PortAccRightRow;

		PortAccRightRow=
		[SELECT Technical_Provisioning_Status__c FROM Portal_Application_Right__c
				WHERE Contact__r.Id = :con3.Id
		and Portal_Application__r.Provisioning_Type__c = :SCIMServProvManager.PROV_TYP_SCIM
		and Portal_Application__r.SCIM_App_Name__c=:SCIMServProvManager.PRE_PROD_SRV_PROV];

		System.AssertEquals(PortAccRightRow.Technical_Provisioning_Status__c, SCIMServProvManager.TECH_STS_IATA_ACCESS_DENIED);
		*/
	}

	@IsTest
	static void testSCIMProvisioningRequestUpdateSucess2() {
		testSuccessCases(false);

		Contact con3=[SELECT Id FROM CONTACT WHERE FirstName = 'test3' AND Email = 'Test@test33.com'];

		Portal_Application_Right__c PortAccRightRow=
		[SELECT Technical_Provisioning_Status__c FROM Portal_Application_Right__c
				WHERE Contact__r.Id = :con3.Id
		and Portal_Application__r.Provisioning_Type__c = :SCIMServProvManager.PROV_TYP_SCIM
		and Portal_Application__r.SCIM_App_Name__c=:SCIMServProvManager.PRE_PROD_SRV_PROV];

		System.AssertEquals(PortAccRightRow.Technical_Provisioning_Status__c, SCIMServProvManager.TECH_STS_EXT_ACCESS_DENIED);
	}

	@IsTest
	static void testSCIMProvisioningRequestUpdateSucess3() {
		Portal_Application_Right__c PortAccRightRow;

		//Test exception not debug mode
		SCIMServProvManager.EXCEP_RSP_DEBUG_MODE_ACTIVE=false;

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = OneIdUtils.getCommunityUrlName()+'/services/apexrest/SCIMProvisioningRequestUpdate';  //Request URL
		req.httpMethod = 'POST';//HTTP Request Type

		system.debug('basto1p - req.requestURI='+req.requestURI);

		RestContext.request = req;
		RestContext.response= res;

		Contact con3=[SELECT Id, Record_Sharing_Criteria__c FROM CONTACT WHERE FirstName = 'test3' AND Email = 'Test@test33.com'];

		User portalUser=[SELECT alias, email,emailencodingkey,firstname,lastname,
				languagelocalekey,localesidkey,contactId,FederationIdentifier,timezonesidkey,
				Username,PortalRole,CommunityNickname,ProfileId,IsActive
				FROM User WHERE contactId=:con3.Id];

		//Test also dorce fill dederation ID
		portalUser.FederationIdentifier='';
		update portalUser;

		Portal_Applications__c portApp=
		[SELECT Id FROM Portal_Applications__c
				WHERE
				Name = 'My Test App' AND
				Provisioning_Type__c =:SCIMServProvManager.PROV_TYP_SCIM AND
				SCIM_App_Name__c =:SCIMServProvManager.PRE_PROD_SRV_PROV];

		Test.StartTest();
		system.runAs(portalUser)
		{
			//INSERT access row in portal apllciation rights for contact 3
			Portal_Application_Right__c PortAccessRigthItem4 = new Portal_Application_Right__c();
			PortAccessRigthItem4.Contact__c = con3.Id;
			PortAccessRigthItem4.Portal_Application__c = portApp.Id;
			PortAccessRigthItem4.Right__c = SCIMServProvManager.IATA_STS_REQUESTED;
			PortAccessRigthItem4.Technical_Provisioning_Status__c = SCIMServProvManager.TECH_STS_REQUESTED;
			insert PortAccessRigthItem4;

			/////////////////////////////////////////////////////////
			// SET IATA DENIED
			/////////////////////////////////////////////////////////
			PortAccessRigthItem4.Right__c = SCIMServProvManager.IATA_STS_ACCESS_DENIED;
			update PortAccessRigthItem4;

			PortAccRightRow=
			[SELECT Technical_Provisioning_Status__c FROM Portal_Application_Right__c
					WHERE Contact__r.Id = :con3.Id
			and Portal_Application__r.Provisioning_Type__c = :SCIMServProvManager.PROV_TYP_SCIM
			and Portal_Application__r.SCIM_App_Name__c=:SCIMServProvManager.PRE_PROD_SRV_PROV];

			System.AssertEquals(PortAccRightRow.Technical_Provisioning_Status__c, SCIMServProvManager.TECH_STS_IATA_ACCESS_DENIED);


			/////////////////////////////////////////////////////////
			// SET IATA GRANTED
			/////////////////////////////////////////////////////////
			PortAccessRigthItem4.Right__c = SCIMServProvManager.IATA_STS_ACCESS_GRANTED;
			update PortAccessRigthItem4;

			PortAccRightRow=
			[SELECT Technical_Provisioning_Status__c FROM Portal_Application_Right__c
					WHERE Contact__r.Id = :con3.Id
			and Portal_Application__r.Provisioning_Type__c = :SCIMServProvManager.PROV_TYP_SCIM
			and Portal_Application__r.SCIM_App_Name__c=:SCIMServProvManager.PRE_PROD_SRV_PROV];
			System.AssertEquals(PortAccRightRow.Technical_Provisioning_Status__c, SCIMServProvManager.TECH_STS_IATA_ACCESS_GRANTED);

			system.debug('basto1p PortAccessRigthItem4=' + PortAccessRigthItem4);

			/////////////////////////////////////////////////////////
			// Call REST Service to externaly approve service
			/////////////////////////////////////////////////////////
			SCIMProvisioningRequestUpdate.doPost('Test@test33.com', true, SCIMServProvManager.PRE_PROD_SRV_PROV);

			PortAccRightRow=
			[SELECT Technical_Provisioning_Status__c FROM Portal_Application_Right__c
					WHERE Contact__r.Id = :con3.Id
			and Portal_Application__r.Provisioning_Type__c = :SCIMServProvManager.PROV_TYP_SCIM
			and Portal_Application__r.SCIM_App_Name__c=:SCIMServProvManager.PRE_PROD_SRV_PROV];
			System.AssertEquals(PortAccRightRow.Technical_Provisioning_Status__c, SCIMServProvManager.TECH_STS_EXT_ACCESS_GRANTED);
		}
		Test.StopTest();
	}

	@IsTest
	static void testUserProvisionRequestRelatedFunctions(){
		Contact con3=[SELECT Id FROM CONTACT WHERE FirstName = 'test3' AND Email = 'Test@test33.com'];

		User portalUser=[SELECT alias, email,emailencodingkey,firstname,lastname,
				languagelocalekey,localesidkey,contactId,FederationIdentifier,timezonesidkey,
				Username,PortalRole,CommunityNickname,ProfileId,IsActive
				FROM User WHERE contactId=:con3.Id];

		Portal_Applications__c portApp=
		[SELECT Id FROM Portal_Applications__c
				WHERE
				Name = 'My Test App' AND
				Provisioning_Type__c =:SCIMServProvManager.PROV_TYP_SCIM AND
				SCIM_App_Name__c =:SCIMServProvManager.PRE_PROD_SRV_PROV];

		system.runAs(portalUser)
		{
			//ConnectedApplication capp = UserProvisioning.ConnectorTestUtil.createConnectedApp(CON_APP_PROV);

			//INSERT access row in portal apllciation rights for contact 3
			Portal_Application_Right__c PortAccessRigthItem4 = new Portal_Application_Right__c();
			PortAccessRigthItem4.Contact__c = con3.Id;
			PortAccessRigthItem4.Portal_Application__c = portApp.Id;
			PortAccessRigthItem4.Right__c = SCIMServProvManager.IATA_STS_ACCESS_GRANTED;
			PortAccessRigthItem4.Technical_Provisioning_Status__c =
					SCIMServProvManager.TECH_STS_IATA_ACCESS_GRANTED;
			insert PortAccessRigthItem4;
		}

		SCIMServProvManager.setPortalAccessRightProvTechStatus(
		portalUser.Id,
		SCIMServProvManager.PRE_PROD_SRV_PROV,
		SCIMServProvManager.TECH_STS_PROV_FAIL);

		SCIMServProvManager.setPortalAccessRightProvTechStatus(
				portalUser.Id,
				SCIMServProvManager.PRE_PROD_SRV_PROV,
				SCIMServProvManager.TECH_STS_IATA_ACCESS_GRANTED);



		//deleteProvRelatedPermissionSets
	}
	/*
	@IsTest
	static void testUserProvisioningRequestScenarios(){

		//UserProvisioningTestUtils.createUserProvisioningRequest(CON_APP_PROV,'Create');
		Contact con3=[SELECT Id FROM CONTACT WHERE FirstName = 'test3' AND Email = 'Test@test33.com'];

		User portalUser=[SELECT alias, email,emailencodingkey,firstname,lastname,
				languagelocalekey,localesidkey,contactId,FederationIdentifier,timezonesidkey,
				Username,PortalRole,CommunityNickname,ProfileId,IsActive
				FROM User WHERE contactId=:con3.Id];

		Portal_Applications__c portApp=
		[SELECT Id FROM Portal_Applications__c
				WHERE
				Name = 'My Test App' AND
				Provisioning_Type__c =:SCIMServProvManager.PROV_TYP_SCIM AND
				SCIM_App_Name__c =:SCIMServProvManager.PRE_PROD_SRV_PROV];

		system.runAs(portalUser)
		{
			//ConnectedApplication capp = UserProvisioning.ConnectorTestUtil.createConnectedApp(CON_APP_PROV);

			//INSERT access row in portal apllciation rights for contact 3
			Portal_Application_Right__c PortAccessRigthItem4 = new Portal_Application_Right__c();
			PortAccessRigthItem4.Contact__c = con3.Id;
			PortAccessRigthItem4.Portal_Application__c = portApp.Id;
			PortAccessRigthItem4.Right__c = SCIMServProvManager.IATA_STS_ACCESS_GRANTED;
			PortAccessRigthItem4.Technical_Provisioning_Status__c = SCIMServProvManager.TECH_STS_IATA_ACCESS_GRANTED;
			insert PortAccessRigthItem4;


			// Build user provisioning account linked to the test user
			UserProvAccount upa = new UserProvAccount(
					salesforceUserId = portalUser.id,
					//connectedAppId = capp.Id,
					externalUserId = 'xxx-xxx-slb',
					externalUserName = 'external@example.org',
					externalFirstName = 'test',
					externalLastName = '33',
					linkState = 'Linked',
					status = 'Active'
			);
			insert upa;

			UserProvisioningRequest uprov = new UserProvisioningRequest();
			uprov.AppName=CON_APP_PROV;//SCIMServProvManager.PRE_PROD_SRV_PROV;
			//uprov.connectedAppId= capp.Id;
			uprov.State='New';
			uprov.Operation='Create';
			uprov.ApprovalStatus='NotRequired';
			uprov.SalesforceUserId=portalUser.Id;
			insert uprov;

			uprov.State='Failed';
			//uprov.State='Completed';
			update uprov;



			/////////////////////////////////////////////////////////
			// SET IATA DENIED
			/////////////////////////////////////////////////////////
			PortAccessRigthItem4.Right__c = SCIMServProvManager.IATA_STS_ACCESS_DENIED;
			update PortAccessRigthItem4;

			Portal_Application_Right__c PortAccRightRow=
			[SELECT Technical_Provisioning_Status__c FROM Portal_Application_Right__c
					WHERE Contact__r.Id = :con3.Id
			and Portal_Application__r.Provisioning_Type__c = :SCIMServProvManager.PROV_TYP_SCIM
			and Portal_Application__r.SCIM_App_Name__c=:SCIMServProvManager.PRE_PROD_SRV_PROV];

			System.AssertEquals(PortAccRightRow.Technical_Provisioning_Status__c, SCIMServProvManager.TECH_STS_IATA_ACCESS_DENIED);

		}

	}
*/
	static void testSuccessCases(Boolean rspActiveFlag){
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = OneIdUtils.getCommunityUrlName()+'/services/apexrest/SCIMProvisioningRequestUpdate';  //Request URL
		req.httpMethod = 'POST';//HTTP Request Type

		system.debug('basto1p - req.requestURI='+req.requestURI);

		RestContext.request = req;
		RestContext.response= res;

		Contact con3=[SELECT Id FROM CONTACT WHERE FirstName = 'test3' AND Email = 'Test@test33.com'];
		//Add already a value to pick list in order to test case of pick list with already some value in it
		con3.Record_Sharing_Criteria__c='None;';
		update con3;

		User portalUser=[SELECT alias, email,emailencodingkey,firstname,lastname,
				languagelocalekey,localesidkey,contactId,FederationIdentifier,timezonesidkey,
				Username,PortalRole,CommunityNickname,ProfileId,IsActive
				FROM User WHERE contactId=:con3.Id];

		Portal_Applications__c portApp=
		[SELECT Id FROM Portal_Applications__c
				WHERE
				Name = 'My Test App' AND
				Provisioning_Type__c =:SCIMServProvManager.PROV_TYP_SCIM AND
				SCIM_App_Name__c =:SCIMServProvManager.PRE_PROD_SRV_PROV];

		system.runAs(portalUser)
		{
			//INSERT access row in portal apllciation rights for contact 3
			Portal_Application_Right__c PortAccessRigthItem4 = new Portal_Application_Right__c();
			PortAccessRigthItem4.Contact__c = con3.Id;
			PortAccessRigthItem4.Portal_Application__c = portApp.Id;
			PortAccessRigthItem4.Right__c = SCIMServProvManager.IATA_STS_ACCESS_GRANTED;
			PortAccessRigthItem4.Technical_Provisioning_Status__c = SCIMServProvManager.TECH_STS_IATA_ACCESS_GRANTED;
			insert PortAccessRigthItem4;

			system.debug('basto1p PortAccessRigthItem4=' + PortAccessRigthItem4);

			//Call REST Service for a valid and not duplicated contact and access granted
			SCIMProvisioningRequestUpdate.doPost('Test@test33.com', rspActiveFlag, SCIMServProvManager.PRE_PROD_SRV_PROV);
		}
	}

}