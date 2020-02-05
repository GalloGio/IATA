@isTest
public class OneId_NDCProductsController_Test {
	public static String generateUniqueUserEmail() {
		return (System.now().getTime() + '@test' + UserInfo.getOrganizationId() + '.org').toLowerCase();
	}

	public static User createUserWithRole() {
		UserRole r = new UserRole(name = 'TEST ROLE');
		Database.insert(r);

		String userEmail = generateUniqueUserEmail();

		Profile pf = [SELECT Id
					  FROM Profile
					  WHERE Name = 'System Administrator'];
		User userWithRole = new User(alias = 'hasrole', email = userEmail, userroleid = r.id,
									 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
									 localesidkey='en_US', profileid = pf.Id,
									 timezonesidkey='America/Los_Angeles', username = userEmail, License_Cost_Center__c = 'ISF005CH01');

		insert userWithRole;
		return userWithRole;
	}

	public static User createUserWithAccount() {

		Id p = [SELECT id
				FROM profile
				WHERE name='Partner Community User'].id;

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

			Account_Role_Service__c arservice = new Account_Role_Service__c(Account_Role__c = rol.Id, Account_Role_Services__c = arserv.Id);
			insert arservice;

			Account_Role_Service_Capability__c arsc = new Account_Role_Service_Capability__c(name = 'Test', Account_Role_Services__c = arserv.Id);
			insert arsc;
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
	public static void testGetAddedProducts() {

		User usr = CreateUserWithAccount();
		User usrQuery = [SELECT Id, AccountId
						 FROM User
						 WHERE Id =: usr.Id];

		Account_Role__c role = [SELECT Id
								FROM Account_Role__c
								WHERE Account__c =: usrQuery.AccountId
								AND RecordType.DeveloperName = 'Default'];

		System.runAs(createUserWithRole()){
			Account_Role_Service__c ars = [SELECT Id
											FROM Account_Role_Service__c
											LIMIT 1];

			Account_Role_Service_Capability__c arsc = [SELECT Id
														FROM Account_Role_Service_Capability__c
														LIMIT 1];

			Account_Role_Capability_Assignment__c cas = new Account_Role_Capability_Assignment__c(Account_Role_Service__c = ars.Id, Account_Role_Service_Capability__c = arsc.Id);
			insert cas;
		}

		List<OneId_NDCProductsAndServicesController.ProdWrapper> prodList = new List<OneId_NDCProductsAndServicesController.ProdWrapper>();

		Test.startTest();
		System.runAs(usr) {
			prodList = OneId_NDCProductsAndServicesController.getAddedProducts();
		}
		Test.stopTest();
		System.assertEquals(1, prodList.size());
	}

	@isTest
	public static void testGetUnaddedProducts() {

		User usr = CreateUserWithAccount();

		List<OneId_NDCProductsAndServicesController.ProdWrapper> prodList = new List<OneId_NDCProductsAndServicesController.ProdWrapper>();

		Test.startTest();
		System.runAs(usr) {
			prodList = OneId_NDCProductsAndServicesController.getUnaddedProducts();
		}
		Test.stopTest();
		System.assertEquals(1, prodList.size());
	}

	@isTest
	public static void testDeleteProducts() {

		User usr = CreateUserWithAccount();

		System.runAs(createUserWithRole()){
			Account_Role_Service__c ars = [SELECT Id
											FROM Account_Role_Service__c
											LIMIT 1];

			Account_Role_Service_Capability__c arsc = [SELECT Id
														FROM Account_Role_Service_Capability__c
														LIMIT 1];

			Account_Role_Capability_Assignment__c cas = new Account_Role_Capability_Assignment__c(Account_Role_Service__c = ars.Id, Account_Role_Service_Capability__c = arsc.Id);
			insert cas;
		}

		Account_Role_Capability_Assignment__c cas = [SELECT Id, Account_Role_Service_Capability__r.Name
													 FROM Account_Role_Capability_Assignment__c LIMIT 1];

		List<OneId_NDCProductsAndServicesController.ProdWrapper> prodList = new List<OneId_NDCProductsAndServicesController.ProdWrapper>();
		OneId_NDCProductsAndServicesController.ProdWrapper wrapper = new OneId_NDCProductsAndServicesController.ProdWrapper();

		wrapper.ProdId = cas.Id;
		wrapper.ProdName = cas.Account_Role_Service_Capability__r.Name;
		prodList.Add(wrapper);

		String prodListSerialized = JSON.serialize(prodList);

		Test.startTest();
		System.runAs(usr) {
			OneId_NDCProductsAndServicesController.deleteProducts(prodListSerialized);
		}
		Test.stopTest();

		List<Account_Role_Capability_Assignment__c> casList = [SELECT Id
															   FROM Account_Role_Capability_Assignment__c];

		System.assertEquals(0, casList.size());
	}

	@isTest
	public static void testCreateProducts() {

		User usr = CreateUserWithAccount();

		Account_Role_Service_Capability__c arsc = [SELECT Id, Name
													FROM Account_Role_Service_Capability__c];

		List<OneId_NDCProductsAndServicesController.ProdWrapper> prodList = new List<OneId_NDCProductsAndServicesController.ProdWrapper>();
		OneId_NDCProductsAndServicesController.ProdWrapper wrapper = new OneId_NDCProductsAndServicesController.ProdWrapper();

		wrapper.ProdId = arsc.Id;
		wrapper.ProdName = arsc.Name;
		prodList.Add(wrapper);

		String prodListSerialized = JSON.serialize(prodList);

		Test.startTest();
		System.runAs(usr) {
			OneId_NDCProductsAndServicesController.createProducts(prodListSerialized);
		}
		Test.stopTest();

		List<Account_Role_Capability_Assignment__c> casList = [SELECT Id
															   FROM Account_Role_Capability_Assignment__c];

		System.assertEquals(1, casList.size());
	}
}
