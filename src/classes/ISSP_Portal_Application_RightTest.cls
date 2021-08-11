@isTest
public class ISSP_Portal_Application_RightTest {

	@TestSetup
	private static void loadData() {
		ISSP_WS_SIS_Callout_Common_Test.load_ISSP_CS();
	}

	public static testMethod void myUnitTest_1bis() {
		Portal_Applications__c apptest = TestDataFactory_PortalApplications.createDefaultPortalApplication(1).get(0);
		apptest.Name = 'SIS';
		insert apptest;
	}

	public static testMethod void ISSP_Portal_Application_RightTest() {
		Id rtId = RecordTypeSelector.selectIdBySObjectAndDeveloperName('Portal_Application_Right__c', 'Biller_Direct');
		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		Contact contact;
		User newUser;

		System.runAs(thisUser) {
			Account acc = ISSP_ObjectFactory.createNewAccount();
			insert acc;

			SAP_Account__c sap = new SAP_Account__c();
			sap.SAP_Account_type__c = 'test';
			sap.Account__c = acc.Id;
			sap.SAP_Id__c = '1234';
			insert sap;

			contact = ISSP_ObjectFactory.createNewContact();
			contact.AccountId = acc.Id;
			insert contact;

			newUser = new User(alias = 'dsfsdfds',
												 email = contact.email,
												 emailencodingkey = 'UTF-8',
												 firstname = contact.firstName,
												 lastname = contact.lastname,
												 languagelocalekey = 'en_US',
												 localesidkey = 'en_US',
												 contactId = contact.Id,
												 timezonesidkey = 'Asia/Dubai',
												 username = contact.email + 'dfgdf',
												 PortalRole = 'Manager',
												 CommunityNickname = contact.email.substring(0, contact.email.indexOf('@')) + Datetime.now().formatLong().substring(10, 15),
												 ProfileId = ISSP_Constant.TEST_User_ProfileID,
												 IsActive = true);
			insert newUser;
		}

		Test.startTest();
		System.runAs(thisUser) {
			Portal_Applications__c app = TestDataFactory_PortalApplications.createDefaultPortalApplication(1).get(0);
			app.Name = 'Biller Direct';
			insert app;
			Portal_Application_Right__c par = TestDataFactory_PortalApplicationRights.createPortalApplicationRight(app.Id, contact.Id);
			par.Right__c = 'Access Granted';
			par.RecordTypeId = rtId;
			par.Invoice_Type__c = 'test';
			insert par;
		}
		Test.stopTest();
	}

	public static testMethod void IFGUnitTest() {
		////////////////////////////////
		// Configurations SET
		////////////////////////////////
		SCIM_Prov_Connector__c conf = new SCIM_Prov_Connector__c();
		conf.Name = 'Test';
		conf.FYI_Email__c = 'manuel.conde@rightitservices.com';
		conf.Processor_Email__c = 'manuel.conde@rightitservices.com';
		conf.SetupOwnerId = UserInfo.getOrganizationId();
		insert conf;

		Id recTypeId = RecordTypeSelector.selectIdBySObjectAndDeveloperName('One_Id_Service_Provider_Config__c', 'Service_Bundle');

		One_Id_Service_Provider_Config__c oi = new One_Id_Service_Provider_Config__c(
			Service_Provider_Name__c = SCIMServProvManager.PRE_PROD_SRV_PROV,
			License_Upgrade_Required__c= true,
			Profile_Id__c='a1',
			Description__c='qualquer',
			Is_Active__c = true,
			Portal_Visible__c = false,
			RecordTypeid = recTypeId,
			Customer_Type_Activation__c = 'Aircraft Operator;ICAO Member State',
			App_Picture_Url__c='oi');
		insert oi;

		One_Id_Service_Provider_Config__c rr =
		new One_Id_Service_Provider_Config__c (
			Service_Provider_Name__c = SCIMServProvManager.PRE_PROD_SRV_PROV,
			Is_Active__c = true,
			Portal_Visible__c = false,
			RecordTypeid = recTypeId,
			Customer_Type_Activation__c = 'Aircraft Operator;ICAO Member State',
			Service_Bundle__c=oi.id);
		insert rr;

		List<PermissionSet> psIds = [SELECT Id, name FROM PermissionSet LIMIT 5];

		One_Id_App_Config_Detail__c r =
			new One_Id_App_Config_Detail__c (
			One_Id_Service_Provider_Config__c = rr.id,
			PermissionSet_SSO__c = psIds[0].name,
			PermissionSet_Provisioning__c = psIds[01].name );
		insert r;

		/////////////////////////////////////////////////////////////

		Account newAccount = ISSP_ObjectFactory.CreateNewAccount();
		insert newAccount;

		Contact newContact = ISSP_ObjectFactory.CreateNewContact();
		newContact.AccountId = newAccount.id;
		insert newContact;

		User newPortalUser = TestDataFactory_Users.createPortalUsers(new List<Contact>{newContact}).get(0);
		insert newPortalUser;
		newContact.OwnerId = newPortalUser.Id;
		update newContact;

		Portal_Applications__c app = TestDataFactory_PortalApplications.createDefaultPortalApplication(1).get(0);
		app.Name = 'IFG Pre-Production';
		app.Provisioning_Type__c = 'SCIM';
		app.SCIM_App_Name__c = SCIMServProvManager.PRE_PROD_SRV_PROV;
		insert app;

		System.runAs(newPortalUser) {
			Portal_Application_Right__c par = TestDataFactory_PortalApplicationRights.createPortalApplicationRight(app.Id, newContact.Id);
			par.Right__c = TestDataFactory_PortalApplicationRights.GRANTED;
			par.Technical_Provisioning_Status__c = 'IATA Access Granted';
			insert par;
			par.Right__c = SCIMServProvManager.IATA_STS_ACCESS_DENIED;
			update par;
			par.Right__c = SCIMServProvManager.IATA_STS_ACCESS_GRANTED;
			update par;
		}
	}

	public static testMethod void ebulletinAccessDeniedTest() {
		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		System.runAs(thisUser) {
			Id rtParId = RecordTypeSelector.selectIdBySObjectAndDeveloperName('Portal_Application_Right__c', 'Application_rigth');
			Id rtWeeklyId = RecordTypeSelector.selectIdBySObjectAndDeveloperName('AMS_eBulletin_Profile__c', 'Weekly');
			Id rtDailyId = RecordTypeSelector.selectIdBySObjectAndDeveloperName('AMS_eBulletin_Profile__c', 'Daily');

			Account acc = TestDataFactory_Accounts.createDefaultAccounts(1).get(0);
			insert acc;

			Contact contact = TestDataFactory_Contacts.createDefaultContact(acc.id,1).get(0);
			insert contact;

			User newUser = TestDataFactory_Users.createPortalUsers(new List<Contact>{contact}).get(0);
			newUser.PortalRole = 'Manager';
			newUser.CommunityNickname = contact.email.substring(0, contact.email.indexOf('@')) + Datetime.now().formatLong().substring(10, 15);
			newUser.ProfileId = ISSP_Constant.TEST_User_ProfileID;
			newUser.IsActive = true;
			insert newUser;

			Portal_Applications__c app = TestDataFactory_PortalApplications.createDefaultPortalApplication(1).get(0);
			app.Name = 'E-Bulletin';
			insert app;

			Portal_Application_Right__c par = TestDataFactory_PortalApplicationRights.createPortalApplicationRight(app.Id, contact.Id);
			par.Right__c = TestDataFactory_PortalApplicationRights.GRANTED;
			par.RecordTypeId = rtParId;
			insert par;

			AMS_eBulletin_Profile__c profDaily = new AMS_eBulletin_Profile__c(
				Area_2__c = true,
				CountriesList__c = 'GB',
				Opt_in__c = true,
				Opt_out_Bulletin__c = false,
				Program_Passage__c = true,
				User__c = newUser.Id,
				RecordTypeId = rtDailyId,
				Agency_Info_Irregularities__c = true);
			insert profDaily;

			AMS_eBulletin_Profile__c profWeekly = new AMS_eBulletin_Profile__c(
				Area_2__c = true,
				CountriesList__c = 'GB',
				Opt_in__c = true,
				Opt_out_Bulletin__c = false,
				Program_Passage__c = true,
				User__c = newUser.Id,
				RecordTypeId = rtWeeklyId,
				Agency_Info_Irregularities__c = true);
			insert profWeekly;

			List<AMS_eBulletin_Profile__c> profiles = [SELECT Id, Opt_in__c, Opt_out_Bulletin__c FROM AMS_eBulletin_Profile__c WHERE User__c = : newUser.Id];

			System.assertEquals(true, profiles.get(0).Opt_in__c);
			System.assertEquals(true, profiles.get(1).Opt_in__c);
			System.assertEquals(false, profiles.get(0).Opt_out_Bulletin__c);
			System.assertEquals(false, profiles.get(1).Opt_out_Bulletin__c);

			par.Right__c = TestDataFactory_PortalApplicationRights.DENIED;
			update par;

			profiles = [SELECT Id, Opt_in__c, Opt_out_Bulletin__c FROM AMS_eBulletin_Profile__c WHERE User__c = : newUser.Id];

			System.assertEquals(false, profiles.get(0).Opt_in__c);
			System.assertEquals(false, profiles.get(1).Opt_in__c);
			System.assertEquals(true, profiles.get(0).Opt_out_Bulletin__c);
			System.assertEquals(true, profiles.get(1).Opt_out_Bulletin__c);
		}
	}

	private static void checkLogs(Boolean isSuccess, String method) {
		list<ISSP_Web_Service_Log__c> listLogs = [SELECT Id, Success__c, Web_Service__c, Method__c, System__c, Error_Message__c FROM ISSP_Web_Service_Log__c];
		//System.assert(listLogs.size() == 1, '' + listLogs);
		//System.assertEquals(isSuccess, listLogs[0].Success__c, '' + listLogs[0].Error_Message__c);
		//System.assertEquals('ISSP_WS_SIS_Callout', listLogs[0].Web_Service__c);
		//System.assertEquals(method, listLogs[0].Method__c);
		//System.assertEquals('SIS', listLogs[0].System__c);
	}

	static testMethod void testSIS_GrantAccess_Error() {
		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		ISSP_WS_SIS_Callout_Common_Test.load_ISSP_CS();
		Id recordtypeAgency = RecordTypeSelector.selectIdBySObjectAndDeveloperName('Account', 'IATA_Agency');
		Portal_Applications__c sisApp = TestDataFactory_PortalApplications.createDefaultPortalApplication(1).get(0);
		sisApp.Name = 'SIS';
		insert sisApp;
		ISSP_ObjectFactory.fiilIncludedFields();

		Account acc = TestDataFactory_Accounts.createDefaultAccounts(1).get(0);
		acc.RecordTypeId = recordtypeAgency;
		acc.SIS_ID__c = '123456';
		insert acc;

		Contact contact = TestDataFactory_Contacts.createDefaultContact(acc.id,1).get(0);
		insert contact;

		system.runAs(thisUser) {
			User newUser = TestDataFactory_Users.createPortalUsers(new List<Contact>{contact}).get(0);
			newUSer.ProfileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Agency User (Partner)'].Id;
			insert newUser;
		}

		ISSP_WS_SIS_Callout_CreateUser.TEST_RESPONSE = '<Response><IsSuccess>false</IsSuccess></Response>';

		delete [SELECT Id FROM ISSP_Web_Service_Log__c];

		Test.startTest();
		system.runAs(thisUser) {
			ISSP_UserTriggerHandler.preventTrigger = true;
			Portal_Application_Right__c appRight = new Portal_Application_Right__c();
			appRight.Portal_Application__c = sisApp.Id;
			appRight.Right__c = 'Access Granted';
			appRight.Contact__c = contact.Id;
			insert appRight;
		}
		Test.stopTest();

		checkLogs(false, 'CreateUser');
	}

	static testMethod void testSIS_GrantAccess_CreatingUser_OK() {
		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		ISSP_WS_SIS_Callout_Common_Test.load_ISSP_CS();
		Id recordtypeAgency = RecordTypeSelector.selectIdBySObjectAndDeveloperName('Account', 'IATA_Agency');
		List<Portal_Applications__c> lApp = TestDataFactory_PortalApplications.createDefaultPortalApplication(4);
		lApp.get(0).Name = 'Baggage Proration';
		lApp.get(0).Name = 'Standards Setting Workspace';
		lApp.get(0).Name = 'IATA Accreditation';
		lApp.get(0).Name = 'SIS';
		insert lApp;
		ISSP_ObjectFactory.fiilIncludedFields();

		Account acc = TestDataFactory_Accounts.createDefaultAccounts(1).get(0);
		acc.RecordTypeId = recordtypeAgency;
		acc.SIS_ID__c = '123456';
		insert acc;

		Contact contact = TestDataFactory_Contacts.createDefaultContact(acc.id,1).get(0);
		insert contact;
		
		System.runAs(thisUser){
			User newUser = TestDataFactory_Users.createPortalUsers(new List<Contact>{contact}).get(0);
			newUSer.ProfileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Agency User (Partner)'].Id;
			insert newUser;
		}

		ISSP_WS_SIS_Callout_CreateUser.TEST_RESPONSE = '<Response><IsSuccess>true</IsSuccess></Response>';

		delete [SELECT Id FROM ISSP_Web_Service_Log__c];

		Test.startTest();
		system.runAs(thisUser) {
			ISSP_UserTriggerHandler.preventTrigger = true;
			List<Portal_Application_Right__c> appRight = new list<Portal_Application_Right__c>();
			appRight.add(new Portal_Application_Right__c(Portal_Application__c = lApp[0].Id,
			Right__c = 'Access Granted',
			Contact__c = contact.Id));
			/*appRight.add(new Portal_Application_Right__c(Portal_Application__c = lApp[1].Id,
			Right__c = 'Access Granted',
			Contact__c = contact.Id));*/
			appRight.add(new Portal_Application_Right__c(Portal_Application__c = lApp[2].Id,
			Right__c = 'Access Granted',
			Contact__c = contact.Id));
			appRight.add(new Portal_Application_Right__c(Portal_Application__c = lApp[3].Id,
			Right__c = 'Access Granted',
			Contact__c = contact.Id));
			insert appRight;

			 appRight[0].Right__c = 'Access Denied';
			 appRight[1].Right__c = 'Access Denied';
			 update appRight;
		}
		Test.stopTest();

		checkLogs(true, 'CreateUser');
	}

	static testMethod void testSIS_GrantAccess_ExistingUser_OK() {
		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		ISSP_WS_SIS_Callout_Common_Test.load_ISSP_CS();
		Id recordtypeAgency = RecordTypeSelector.selectIdBySObjectAndDeveloperName('Account', 'IATA_Agency') ;
		Portal_Applications__c sisApp = TestDataFactory_PortalApplications.createDefaultPortalApplication(1).get(0);
		sisApp.Name = 'SIS';
		insert sisApp;
		ISSP_ObjectFactory.fiilIncludedFields();

		Account acc = TestDataFactory_Accounts.createDefaultAccounts(1).get(0);
		acc.RecordTypeId = recordtypeAgency;
		acc.SIS_ID__c = '123456';
		insert acc;

		Contact contact = TestDataFactory_Contacts.createDefaultContact(acc.id,1).get(0);
		insert contact;
		
		system.runAs(thisUser) {
			User newUser = TestDataFactory_Users.createPortalUsers(new List<Contact>{contact}).get(0);
			newUSer.ProfileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Agency User (Partner)'].Id;
			insert newUser;
		}

		ISSP_WS_SIS_Callout_CreateUser.TEST_RESPONSE = '<Response>'
				+ '<IsSuccess>false</IsSuccess>'
				+ '<ErrorCode>' + ISSP_WS_SIS_Callout_CreateUser.ERROR_FEDERATIONID_DUPLICATE + '</ErrorCode>'
				+ '</Response>';
		ISSP_WS_SIS_Callout_ActivateUser.TEST_RESPONSE = '<Response>'
				+ '<IsSuccess>true</IsSuccess>'
				+ '</Response>';

		delete [SELECT Id FROM ISSP_Web_Service_Log__c];

		Test.startTest();
		system.runAs(thisUser) {
			ISSP_UserTriggerHandler.preventTrigger = true;
			Portal_Application_Right__c appRight = TestDataFactory_PortalApplicationRights.createPortalApplicationRight(sisApp.Id, contact.Id);
			appRight.Right__c = TestDataFactory_PortalApplicationRights.GRANTED;
			insert appRight;
		}
		Test.stopTest();

		list<ISSP_Web_Service_Log__c> listLogs = [SELECT Id, Success__c, Web_Service__c, Method__c, System__c, Error_Message__c FROM ISSP_Web_Service_Log__c];
	}

	static testMethod void testSIS_RevokeAccess_ERROR() {
		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		ISSP_WS_SIS_Callout_Common_Test.load_ISSP_CS();
		Id recordtypeAgency = RecordTypeSelector.selectIdBySObjectAndDeveloperName('Account', 'IATA_Agency') ;
		Portal_Applications__c sisApp = TestDataFactory_PortalApplications.createDefaultPortalApplication(1).get(0);
		sisApp.Name = 'SIS';
		insert sisApp;
		ISSP_ObjectFactory.fiilIncludedFields();

		Account acc = TestDataFactory_Accounts.createDefaultAccounts(1).get(0);
		acc.RecordTypeId = recordtypeAgency;
		acc.SIS_ID__c = '123456';
		insert acc;

		Contact contact = TestDataFactory_Contacts.createDefaultContact(acc.id,1).get(0);
		insert contact;

		system.runAs(thisUser) {
			User newUser = TestDataFactory_Users.createPortalUsers(new List<Contact>{contact}).get(0);
			insert newUser;
		}

		Portal_Application_Right__c appRight = TestDataFactory_PortalApplicationRights.createPortalApplicationRight(sisApp.Id, contact.Id);
		system.runAs(thisUser) {
			appRight.Right__c = TestDataFactory_PortalApplicationRights.GRANTED;
			ISSP_UserTriggerHandler.preventTrigger = true;
			ISSP_UserTriggerHandler.preventSISIntegration = true;
			insert appRight;
			ISSP_UserTriggerHandler.preventTrigger = false;
			ISSP_UserTriggerHandler.preventSISIntegration = false;
		}

		ISSP_WS_SIS_Callout_ActivateUser.TEST_RESPONSE = '<Response><IsSuccess>false</IsSuccess></Response>';

		delete [SELECT Id FROM ISSP_Web_Service_Log__c];

		Test.startTest();
		system.runAs(thisUser) {
			appRight.Right__c = 'Access Denied';
			update appRight;
		}
		Test.stopTest();

		checkLogs(false, 'DeactivateUser');
	}

	static testMethod void testSIS_RevokeAccess_OK() {
		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		ISSP_WS_SIS_Callout_Common_Test.load_ISSP_CS();
		Id recordtypeAgency = RecordTypeSelector.selectIdBySObjectAndDeveloperName('Account', 'IATA_Agency') ;
		Portal_Applications__c sisApp = TestDataFactory_PortalApplications.createDefaultPortalApplication(1).get(0);
		sisApp.Name = 'SIS';
		insert sisApp;
		ISSP_ObjectFactory.fiilIncludedFields();

		Account acc = TestDataFactory_Accounts.createDefaultAccounts(1).get(0);
		acc.RecordTypeId = recordtypeAgency;
		acc.SIS_ID__c = '123456';
		insert acc;

		Contact contact = TestDataFactory_Contacts.createDefaultContact(acc.id,1).get(0);
		insert contact;
		
		system.runAs(thisUser) {
			User newUser = TestDataFactory_Users.createPortalUsers(new List<Contact>{contact}).get(0);
			newUSer.ProfileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Agency User (Partner)'].Id;
			insert newUser;
		}

		Portal_Application_Right__c appRight = TestDataFactory_PortalApplicationRights.createPortalApplicationRight(sisApp.Id, contact.Id);
		system.runAs(thisUser) {
			appRight.Right__c = TestDataFactory_PortalApplicationRights.GRANTED;
			ISSP_UserTriggerHandler.preventTrigger = true;
			ISSP_UserTriggerHandler.preventSISIntegration = true;
			insert appRight;
			ISSP_UserTriggerHandler.preventTrigger = false;
			ISSP_UserTriggerHandler.preventSISIntegration = false;
		}

		ISSP_WS_SIS_Callout_ActivateUser.TEST_RESPONSE = '<Response><IsSuccess>true</IsSuccess></Response>';

		delete [SELECT Id FROM ISSP_Web_Service_Log__c];

		Test.startTest();
		system.runAs(thisUser) {
			appRight.Right__c = 'Access Denied';
			update appRight;
		}
		Test.stopTest();

		checkLogs(true, 'DeactivateUser');
	}

	static testMethod void testParentContactInsertService() {
		Portal_Applications__c sisApp = TestDataFactory_PortalApplications.createDefaultPortalApplication(1).get(0);
		sisApp.Name = 'SIS';
		insert sisApp;

		Id recordtypeAgency = RecordTypeSelector.selectIdBySObjectAndDeveloperName('Account','IATA_Agency');
		Account acc = TestDataFactory_Accounts.createDefaultAccounts(1).get(0);
		acc.RecordTypeId = recordtypeAgency;
		insert acc;

		Contact contact = TestDataFactory_Contacts.createDefaultContact(acc.id,1).get(0);
		insert contact;

		contact = [SELECT Available_Services__c FROM Contact WHERE Id = :contact.Id];
		System.assert(String.isBlank(contact.Available_Services__c));

		Test.startTest();
		Portal_Application_Right__c appRight = TestDataFactory_PortalApplicationRights.createPortalApplicationRight(sisApp.Id, contact.Id);
		appRight.Right__c = TestDataFactory_PortalApplicationRights.GRANTED;
		insert appRight;
		Test.stopTest();

		contact = [SELECT Available_Services__c FROM Contact WHERE Id = :contact.Id];
		System.assertEquals(contact.Available_Services__c,sisApp.Name);
	}

	static testMethod void testParentContactUpdateService() {
		Portal_Applications__c sisApp = TestDataFactory_PortalApplications.createDefaultPortalApplication(1).get(0);
		sisApp.Name = 'SIS';
		insert sisApp;

		Id recordtypeAgency = RecordTypeSelector.selectIdBySObjectAndDeveloperName('Account','IATA_Agency');
		Account acc = ISSP_ObjectFactory.createNewAccount();
		acc.RecordTypeId = recordtypeAgency;
		insert acc;

		Contact contact = TestDataFactory_Contacts.createDefaultContact(acc.id,1).get(0);
		insert contact;

		contact = [SELECT Available_Services__c FROM Contact WHERE Id = :contact.Id];
		System.assert(String.isBlank(contact.Available_Services__c));

		Portal_Application_Right__c appRight = TestDataFactory_PortalApplicationRights.createPortalApplicationRight(sisApp.Id, contact.Id);
		appRight.Right__c = TestDataFactory_PortalApplicationRights.DENIED;
		insert appRight;

		contact = [SELECT Available_Services__c FROM Contact WHERE Id = :contact.Id];
		System.assert(String.isBlank(contact.Available_Services__c));

		Test.startTest();
		appRight.Right__c = TestDataFactory_PortalApplicationRights.GRANTED;
		update appRight;
		Test.stopTest();

		contact = [SELECT Available_Services__c FROM Contact WHERE Id = :contact.Id];
		System.assertEquals(contact.Available_Services__c,sisApp.Name);
	}

	@isTest
	static void testParentContactDeleteService_part1() {
		Portal_Applications__c sisApp = TestDataFactory_PortalApplications.createDefaultPortalApplication(1).get(0);
		sisApp.Name = 'SIS';
		insert sisApp;

		Id recordtypeAgency = RecordTypeSelector.selectIdBySObjectAndDeveloperName('Account','IATA_Agency');
		Account acc = ISSP_ObjectFactory.createNewAccount();
		acc.RecordTypeId = recordtypeAgency;
		insert acc;

		Contact contact = TestDataFactory_Contacts.createDefaultContact(acc.id,1).get(0);
		contact.ID_Card_Holder__c = true;
		insert contact;
		
		contact = [SELECT Available_Services__c FROM Contact WHERE Id = :contact.Id];
		System.assertEquals(IdCardUtil.IDCARD_SERVICE_NAME,contact.Available_Services__c);

		Portal_Application_Right__c appRight = TestDataFactory_PortalApplicationRights.createPortalApplicationRight(sisApp.Id, contact.Id);
		appRight.Right__c = TestDataFactory_PortalApplicationRights.GRANTED;
		Test.startTest();
		insert appRight;
		Test.stopTest();

		contact = [SELECT Available_Services__c FROM Contact WHERE Id = :contact.Id];
		System.assertEquals(sisApp.Name + ';' + IdCardUtil.IDCARD_SERVICE_NAME, contact.Available_Services__c);
	}

	@isTest
	static void testParentContactDeleteService_part2() {
		Portal_Applications__c sisApp = TestDataFactory_PortalApplications.createDefaultPortalApplication(1).get(0);
		sisApp.Name = 'SIS';
		insert sisApp;

		Id recordtypeAgency = RecordTypeSelector.selectIdBySObjectAndDeveloperName('Account','IATA_Agency');
		Account acc = ISSP_ObjectFactory.createNewAccount();
		acc.RecordTypeId = recordtypeAgency;
		insert acc;

		Contact contact = TestDataFactory_Contacts.createDefaultContact(acc.id,1).get(0);
		contact.ID_Card_Holder__c = true;
		insert contact;

		contact = [SELECT Available_Services__c FROM Contact WHERE Id = :contact.Id];
		System.assertEquals(IdCardUtil.IDCARD_SERVICE_NAME,contact.Available_Services__c);

		Portal_Application_Right__c appRight = TestDataFactory_PortalApplicationRights.createPortalApplicationRight(sisApp.Id, contact.Id);
		appRight.Right__c = TestDataFactory_PortalApplicationRights.GRANTED;
		insert appRight;

		//the result of this first code is on testParentContactDeleteService_part1
		//we had to separate the asserts in 2 methods due to the update of the field being done on a queueable job

		Test.startTest();
		delete appRight;
		Test.stopTest();

		contact = [SELECT Available_Services__c FROM Contact WHERE Id = :contact.Id];
		System.assertEquals(IdCardUtil.IDCARD_SERVICE_NAME,contact.Available_Services__c);
	}
}