@isTest
public class OneId_NDCMatchmakerController_Test {

	public static String generateUniqueUserEmail() {
		return (System.now().getTime() + '@test' + UserInfo.getOrganizationId() + '.org').toLowerCase();
	}

	public static User createUserWithRole() {
		UserRole r = new UserRole(name = 'TEST ROLE');
		Database.insert(r);

		String userEmail = generateUniqueUserEmail();

		Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		User userWithRole = new User(alias = 'hasrole', email = userEmail, userroleid = r.id,
									 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
									 localesidkey='en_US', profileid = pf.Id,
									 timezonesidkey='America/Los_Angeles', username = userEmail, License_Cost_Center__c = 'ISF005CH01');

		insert userWithRole;
		return userWithRole;
	}

	public static User createUserWithAccount() {

		Id p = [select id from profile where name='ISS Portal (Partner)'].id;

		System.runAs(createUserWithRole()){
			String roleRecordTypeId = Schema.SObjectType.Account_Role__c.getRecordTypeInfosByDeveloperName().get('Default').getRecordTypeId();
			String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Airline Headquarters').getRecordTypeId();
			String sProviderRecordTypeId = Schema.SObjectType.One_Id_Service_Provider_Config__c.getRecordTypeInfosByDeveloperName().get('Service_Provider').getRecordTypeId();

			Account ac = new Account(RecordTypeId = recordTypeId, Name ='Acc', Sector__c = 'Airline', Category__c = 'Passenger only');
			insert ac;

			Account_Roles__c ars = new Account_Roles__c(Name = 'Airline - Passenger only', Sector__c = 'Airline', Category__c = 'Passenger only');
			insert ars;

			Portal_Applications__c pa = new Portal_Applications__c(Name = 'NDCMM');
			insert pa;

			One_Id_Service_Provider_Config__c oneIdService = new One_Id_Service_Provider_Config__c(Portal_Service__c = pa.Id, Service_Provider_Name__c = 'NDCMM', RecordTypeId = sProviderRecordTypeId);
			insert oneIdService;

			Contact con = new Contact(LastName ='Con',AccountId = ac.Id, Email='testuser@example.com');
			insert con;

			Account_Role__c rol = new Account_Role__c (Account__c = ac.Id, RecordTypeId = roleRecordTypeId, Account_Roles__c = ars.Id);
			insert rol;

			Account_Role_Services__c arserv = new Account_Role_Services__c(Account_Roles__c = ars.Id, Portal_Service__c = oneIdService.Portal_Service__c);
			insert arserv;

		}
		Contact cont = [SELECT Id FROM Contact WHERE LastName = 'Con'];
		User user = new User(Alias = 'testuser', Email='testuser@example.com',
							 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
							 LocalesIdKey='en_US', ProfileId = p, Country='United States', IsActive =true,
							 ContactId = cont.Id,
							 TimeZonesIdKey='America/Los_Angeles', Username='testuser@example.com', License_Cost_Center__c = 'ISF005CH01');

		insert user;
		return user;
	}

	@isTest
	public static void testInitializeGuest() {

		UserRole r = new UserRole(name = 'TEST ROLE');
		Database.insert(r);

		Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

		User userWithRole = new User(alias = 'Guest', email = 'identity@example.com', userroleid = r.id,
									 emailencodingkey='UTF-8', lastname='identity Site Guest User', languagelocalekey='en_US',
									 localesidkey='en_US', profileid = pf.Id,
									 timezonesidkey='America/Los_Angeles', username = 'identity@example.com', License_Cost_Center__c = 'ISF005CH01');

		insert userWithRole;

		OneId_NDCMatchmakerController.UserInformation u = new OneId_NDCMatchmakerController.UserInformation();

		Test.startTest();
		System.runAs(userWithRole) {
			u = OneId_NDCMatchmakerController.initialize();
		}
		Test.stopTest();

		System.assertEquals(null, u.usr);
	}

	@isTest
	public static void testGetUserInfoGuest() {

		UserRole r = new UserRole(name = 'TEST ROLE');
		Database.insert(r);

		Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

		User userWithRole = new User(alias = 'Guest', email = 'identity@example.com', userroleid = r.id,
									 emailencodingkey='UTF-8', lastname='identity Site Guest User', languagelocalekey='en_US',
									 localesidkey='en_US', profileid = pf.Id,
									 timezonesidkey='America/Los_Angeles', username = 'identity@example.com', License_Cost_Center__c = 'ISF005CH01');

		insert userWithRole;

		OneId_NDCMatchmakerController.UserInformation u = new OneId_NDCMatchmakerController.UserInformation();

		Test.startTest();
		System.runAs(userWithRole) {
			u = OneId_NDCMatchmakerController.getUserInfo();
		}
		Test.stopTest();

		System.assertEquals(null, u.usr);
	}

	@isTest
	public static void testGetUserInfoNoTC() {

		User usr = CreateUserWithAccount();
		User usrQuery = [SELECT Id, AccountId, ContactId FROM User WHERE Id =: usr.Id];

		String sProviderConfigRecordTypeId = Schema.SObjectType.One_Id_Service_Provider_Config__c.getRecordTypeInfosByDeveloperName().get('Service_Provider').getRecordTypeId();

		System.runAs(createUserWithRole()){
			Portal_Applications__c pa = [SELECT Id
											FROM Portal_Applications__c
											WHERE Name = 'NDCMM'
											LIMIT 1];

			Portal_Application_Right__c pr = new Portal_Application_Right__c(Right__c = 'Access Granted', Portal_Application__c = pa.Id, Contact__c = usrQuery.ContactId);
			insert pr;
		}

		OneId_NDCMatchmakerController.UserInformation u = new OneId_NDCMatchmakerController.UserInformation();

		Test.startTest();
		System.runAs(usr) {
			u = OneId_NDCMatchmakerController.getUserInfo();
		}
		Test.stopTest();

		System.assertEquals('Access Granted', u.accessStatus);

	}

	@isTest
	public static void testInitializeNoTcAcceptances() {

		User usr = CreateUserWithAccount();
		User usrQuery = [SELECT Id, AccountId, ContactId
						 FROM User
						 WHERE Id =: usr.Id];

		String sProviderConfigRecordTypeId = Schema.SObjectType.One_Id_Service_Provider_Config__c.getRecordTypeInfosByDeveloperName().get('Service_Provider').getRecordTypeId();

		System.runAs(createUserWithRole()){
			Portal_Applications__c pa = [SELECT Id
											FROM Portal_Applications__c
											WHERE Name = 'NDCMM'
											LIMIT 1];

			Portal_Application_Right__c pr = new Portal_Application_Right__c(Right__c = 'Access Granted', Portal_Application__c = pa.Id, Contact__c = usrQuery.ContactId);
			insert pr;

			Term_And_Condition__c tc = new Term_And_Condition__c(Is_Latest__c = TRUE, T_C_Id__c = 'docId', NewGenApp_PortalService__c = pa.Id, Effective_Start_Date__c = Date.today());
			insert tc;
		}

		OneId_NDCMatchmakerController.UserInformation u = new OneId_NDCMatchmakerController.UserInformation();

		Test.startTest();
		System.runAs(usr) {
			u = OneId_NDCMatchmakerController.getUserInfo();
		}
		Test.stopTest();

		System.assertEquals('Access Granted', u.accessStatus);

	}

	@isTest
	public static void testInitializeNoLatestTc() {

		User usr = CreateUserWithAccount();
		User usrQuery = [SELECT Id, AccountId, ContactId
						 FROM User
						 WHERE Id =: usr.Id];

		String sProviderConfigRecordTypeId = Schema.SObjectType.One_Id_Service_Provider_Config__c.getRecordTypeInfosByDeveloperName().get('Service_Provider').getRecordTypeId();

		System.runAs(createUserWithRole()){
			Portal_Applications__c pa = [SELECT Id
											FROM Portal_Applications__c
											WHERE Name = 'NDCMM'
											LIMIT 1];

			Portal_Application_Right__c pr = new Portal_Application_Right__c(Right__c = 'Access Granted', Portal_Application__c = pa.Id, Contact__c = usrQuery.ContactId);
			insert pr;

			Term_And_Condition__c tc = new Term_And_Condition__c(Is_Latest__c = FALSE, T_C_Id__c = 'docId', NewGenApp_PortalService__c = pa.Id, Effective_Start_Date__c = Date.today());
			insert tc;
		}

		OneId_NDCMatchmakerController.UserInformation u = new OneId_NDCMatchmakerController.UserInformation();

		Test.startTest();
		System.runAs(usr) {
			u = OneId_NDCMatchmakerController.getUserInfo();
		}
		Test.stopTest();

		System.assertEquals('Access Granted', u.accessStatus);

	}

	@isTest
	public static void testInitializeMultipleLatestTc() {

		User usr = CreateUserWithAccount();
		User usrQuery = [SELECT Id, AccountId, ContactId
						 FROM User
						 WHERE Id =: usr.Id];

		String sProviderConfigRecordTypeId = Schema.SObjectType.One_Id_Service_Provider_Config__c.getRecordTypeInfosByDeveloperName().get('Service_Provider').getRecordTypeId();

		System.runAs(createUserWithRole()){
			Portal_Applications__c pa = [SELECT Id
											FROM Portal_Applications__c
											WHERE Name = 'NDCMM'
											LIMIT 1];

			Portal_Application_Right__c pr = new Portal_Application_Right__c(Right__c = 'Access Granted', Portal_Application__c = pa.Id, Contact__c = usrQuery.ContactId);
			insert pr;

			Term_And_Condition__c tc = new Term_And_Condition__c(Is_Latest__c = TRUE, T_C_Id__c = 'docId', NewGenApp_PortalService__c = pa.Id, Effective_Start_Date__c = Date.today());
			insert tc;

			Term_And_Condition__c tc2 = new Term_And_Condition__c(Is_Latest__c = TRUE, T_C_Id__c = 'docId2', NewGenApp_PortalService__c = pa.Id, Effective_Start_Date__c = Date.today());
			insert tc2;
		}

		OneId_NDCMatchmakerController.UserInformation u = new OneId_NDCMatchmakerController.UserInformation();

		Test.startTest();
		System.runAs(usr) {
			u = OneId_NDCMatchmakerController.getUserInfo();
		}
		Test.stopTest();

		System.assertEquals('Access Granted', u.accessStatus);

	}

	@isTest
	public static void testGetUser() {

		User usr = CreateUserWithAccount();

		User userTest;

		Test.startTest();
		System.runAs(usr) {
			userTest = OneId_NDCMatchmakerController.getUser();
		}
		Test.stopTest();

		System.assertEquals('Acc', userTest.Account.Name);
	}

	@isTest
	public static void testGetNDCCapabilitiesNoRole() {

		Id p = [SELECT Id
				FROM profile
				WHERE name='ISS Portal (Partner)'].id;

		System.runAs(createUserWithRole()){
			String roleRecordTypeId = Schema.SObjectType.Account_Role__c.getRecordTypeInfosByDeveloperName().get('Default').getRecordTypeId();
			String sProviderRecordTypeId = Schema.SObjectType.One_Id_Service_Provider_Config__c.getRecordTypeInfosByDeveloperName().get('Service_Provider').getRecordTypeId();
			String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Airline Headquarters').getRecordTypeId();
			Account ac = new Account(RecordTypeId = recordTypeId, Name ='Acc', Sector__c = 'Airline', Category__c = 'Passenger only');
			insert ac;

			Account_Roles__c ars = new Account_Roles__c(Name = 'Airline - Passenger only', Sector__c = 'Airline', Category__c = 'Passenger only');
			insert ars;

			Contact con = new Contact(LastName ='Con',AccountId = ac.Id, Email='testuser@example.com');
			insert con;

			Portal_Applications__c pa = new Portal_Applications__c(Name = 'One Id NDC Matchmaker');
			insert pa;

			Account_Role_Services__c arss = new Account_Role_Services__c(Account_Roles__c = ars.Id, Portal_Service__c = pa.Id);
			insert arss;

			One_Id_Service_Provider_Config__c oneIdService = new One_Id_Service_Provider_Config__c(Portal_Service__c = pa.Id, Service_Provider_Name__c = 'NDCMM', RecordTypeId = sProviderRecordTypeId);
			insert oneIdService;
		}
		Contact cont = [SELECT Id FROM Contact WHERE LastName = 'Con'];
		User user = new User(Alias = 'testuser', Email='testuser@example.com',
							 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
							 LocalesIdKey='en_US', ProfileId = p, Country='United States', IsActive =true,
							 ContactId = cont.Id,
							 TimeZonesIdKey='America/Los_Angeles', Username='testuser@example.com', License_Cost_Center__c = 'ISF005CH01');

		insert user;

		User usrQuery = [SELECT Id, AccountId, ContactId FROM User WHERE Id =: user.Id];

		NDC_Account_Service_Detail__c ard;

		Test.startTest();
		System.runAs(usrQuery) {
			ard = OneId_NDCMatchmakerController.getNDCCapabilities(usrQuery);
		}
		Test.stopTest();

		system.debug(ard);

		System.assertNotEquals(Null, ard);
	}

	@isTest
	public static void testGetNDCCapabilitiesNoDetail() {

		Id p = [SELECT Id
				FROM profile
				WHERE name='ISS Portal (Partner)'].id;

		System.runAs(createUserWithRole()){
			String roleRecordTypeId = Schema.SObjectType.Account_Role__c.getRecordTypeInfosByDeveloperName().get('Default').getRecordTypeId();
			String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Airline Headquarters').getRecordTypeId();
			String sProviderRecordTypeId = Schema.SObjectType.One_Id_Service_Provider_Config__c.getRecordTypeInfosByDeveloperName().get('Service_Provider').getRecordTypeId();

			Account ac = new Account(RecordTypeId = recordTypeId, Name ='Acc', Sector__c = 'Airline', Category__c = 'Passenger only');
			insert ac;

			Account_Roles__c ars = new Account_Roles__c(Name = 'Airline - Passenger only', Sector__c = 'Airline', Category__c = 'Passenger only');
			insert ars;

			Contact con = new Contact(LastName ='Con',AccountId = ac.Id, Email='testuser@example.com');
			insert con;

			Account_Role__c rol = new Account_Role__c (Account__c = ac.Id, RecordTypeId = roleRecordTypeId, Account_Roles__c = ars.Id);
			insert rol;

			Portal_Applications__c pa = new Portal_Applications__c(Name = 'One Id NDC Matchmaker');
			insert pa;

			Account_Role_Services__c arss = new Account_Role_Services__c(Account_Roles__c = ars.Id, Portal_Service__c = pa.Id);
			insert arss;

			One_Id_Service_Provider_Config__c oneIdService = new One_Id_Service_Provider_Config__c(Portal_Service__c = pa.Id, Service_Provider_Name__c = 'NDCMM', RecordTypeId = sProviderRecordTypeId);
			insert oneIdService;

		}
		Contact cont = [SELECT Id
						FROM Contact
						WHERE LastName = 'Con'];

		User user = new User(Alias = 'testuser', Email='testuser@example.com',
							 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
							 LocalesIdKey='en_US', ProfileId = p, Country='United States', IsActive =true,
							 ContactId = cont.Id,
							 TimeZonesIdKey='America/Los_Angeles', Username='testuser@example.com', License_Cost_Center__c = 'ISF005CH01');

		insert user;

		User usrQuery = [SELECT Id, AccountId, ContactId
						 FROM User
						 WHERE Id =: user.Id];

		NDC_Account_Service_Detail__c ard;

		Test.startTest();
		System.runAs(usrQuery) {
			ard = OneId_NDCMatchmakerController.getNDCCapabilities(usrQuery);
		}
		Test.stopTest();
		system.debug(ard);

		System.assertNotEquals(Null, ard);
	}

	@isTest
	public static void testAcceptTermsAndConditions() {

		Term_And_Condition_Acceptance__c tca = new Term_And_Condition_Acceptance__c();
		insert tca;

		Term_And_Condition_Acceptance__c tcAcceptance;

		Test.startTest();
		tcAcceptance = OneId_NDCMatchmakerController.acceptTermsAndConditions(tca);
		Test.stopTest();

		System.assertEquals(TRUE, tcAcceptance.Is_Accepted__c);
	}

	@isTest
	public static void testSubmitCaseForApproval() {

		Id p = [SELECT Id
				FROM profile
				WHERE name='ISS Portal (Partner)'].id;

		System.runAs(createUserWithRole()){
			String roleRecordTypeId = Schema.SObjectType.Account_Role__c.getRecordTypeInfosByDeveloperName().get('Default').getRecordTypeId();
			String sProviderRecordTypeId = Schema.SObjectType.One_Id_Service_Provider_Config__c.getRecordTypeInfosByDeveloperName().get('Service_Provider').getRecordTypeId();
			String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Airline Headquarters').getRecordTypeId();
			Account ac = new Account(RecordTypeId = recordTypeId, Name ='Acc', Sector__c = 'Airline', Category__c = 'Passenger only');
			insert ac;

			Account_Roles__c ars = new Account_Roles__c(Name = 'Airline - Passenger only', Sector__c = 'Airline', Category__c = 'Passenger only');
			insert ars;

			Contact con = new Contact(LastName ='Con',AccountId = ac.Id, Email='testuser@example.com');
			insert con;

			Portal_Applications__c pa = new Portal_Applications__c(Name = 'One Id NDC Matchmaker');
			insert pa;

			Account_Role_Services__c arss = new Account_Role_Services__c(Account_Roles__c = ars.Id, Portal_Service__c = pa.Id);
			insert arss;

			One_Id_Service_Provider_Config__c oneIdService = new One_Id_Service_Provider_Config__c(Portal_Service__c = pa.Id, Service_Provider_Name__c = 'NDCMM', RecordTypeId = sProviderRecordTypeId);
			insert oneIdService;
		}
		Contact cont = [SELECT Id FROM Contact WHERE LastName = 'Con'];
		User user = new User(Alias = 'testuser', Email='testuser@example.com',
							 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
							 LocalesIdKey='en_US', ProfileId = p, Country='United States', IsActive =true,
							 ContactId = cont.Id,
							 TimeZonesIdKey='America/Los_Angeles', Username='testuser@example.com', License_Cost_Center__c = 'ISF005CH01');

		insert user;

		User usrQuery = [SELECT Id, AccountId, ContactId FROM User WHERE Id =: user.Id];

		NDC_Account_Service_Detail__c ard;

		Test.startTest();

		System.runAs(usrQuery) {
			ard = OneId_NDCMatchmakerController.getNDCCapabilities(usrQuery);
			ard.NDC_Forms_of_Payment_Accepted__c = 'Vouchers';
			ard.NDC_Airline_Profile__c = 'Yes';
			ard.Contact_Email__c = 'test@test.com';
			ard.Contact_Person__c = 'Test User';
			ard.NDC_Content_Differentiation__c = 'Yes';
			ard.Content_Differentiation_Products_and_Se__c = 'Yes';
			ard.NDC_Forms_of_Payment_Accepted__c = 'Invoice';
			ard.NDC_Forms_of_Remittance_and_Settlement__c = 'ARC';
			ard.NDC_Types_of_Fares__c = 'Private fares';
			ard.NDC_Personalisation__c = 'Yes';
			ard.NDC_Public_Incentive_Schemes_for_Sellers__c = 'Yes';
			ard.NDC_Rich_Content__c = 'No';
			ard.NDC_Schema_Version__c = '1.1.3';
			ard.NDC_Servicing__c = 'Voluntary';
			update ard;
			OneId_NDCMatchmakerController.submitCaseForApproval();

		}

		Test.stopTest();
		List<Case> cse = [SELECT Subject
						  FROM Case
						  WHERE Subject = 'NDC Matchmaker - Validate NDC Capability'];

		System.assertEquals(1, cse.size());
	}

}
