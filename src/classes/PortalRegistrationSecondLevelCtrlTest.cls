@IsTest
public class PortalRegistrationSecondLevelCtrlTest {

	@TestSetup
	static void createData(){

		ISSP_CS__c setting = new ISSP_CS__c();
		setting.Name = 'DefaultNewAccountOwnerId';
		setting.Value__c = UserInfo.getUserId();
		insert setting;

		/** COUNTRIES */
		IATA_ISO_Country__c switzerland = new IATA_ISO_Country__c(
			Name='Switzerland',
			ISO_Code__c='CH',
			Region__c='Europe',
			Region_Province_and_Cities_Enabled__c = true,
			ISS_Office_Location__c='Switzerland'
		);
		insert switzerland;

		/** STATES */
		IATA_ISO_State__c vaud = new IATA_ISO_State__c(
			Name='Vaud',
			IATA_ISO_Country__c = switzerland.Id,
			Valid_for_Address__c = true,
			ISO_Code__c=' CH-VD'
		);
		insert vaud;

		/** CITIES */
		IATA_ISO_City__c lausanne = new IATA_ISO_City__c(
			Name = 'Lausanne',
			IATA_ISO_State__c = vaud.Id
		);
		insert lausanne;

		/** ACCOUNTS */
		List<Account> accs = new List<Account>();

		Account gp = new Account(
			Name = 'TEST GENERAL PUBLIC',
			Category__c='Passenger only',
			Sector__c='Airline',
			IATA_ISO_Country__c = switzerland.Id,
			Is_General_Public_Account__c = true,
			ACLI_Status__c = 'Inactive Company',
			Reason_for_creation__c = 'Created by customer',
			recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account','Standard_Account')
		);
		accs.add(gp);

		Account swiss = new Account(
			Name = 'TEST AIRLINE',
			Sector__c='Airline',
			Category__c='Passenger only',
			IATACode__c = '057',
			IATA_ISO_Country__c = switzerland.Id,
			Reason_for_creation__c = 'Created by customer',
			recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline')
		);
		accs.add(swiss);

		Account itp = new Account(
			Name = 'TEST ITP',
			Sector__c = 'Airline Supplier',
			Category__c = 'Fuel Supplier',
			IATA_ISO_Country__c = switzerland.Id,
			Reason_for_creation__c = 'Created by customer',
			recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Others')
		);
		accs.add(itp);

		insert accs;

		swiss.IsPartner = true;
		update swiss;

		/** CONTACT */
		Contact con = new Contact(
			FirstName = 'Test',
			LastName = 'L1 Contact',
			Email = 'test' + DateTime.now().getTime() + '@test.test',
			Community__c = 'ISS Customer Portal',
			AccountId = gp.Id
		);
		insert con;

		/** USER */
		User portalUser = ISSP_ObjectFactory.createPortalUser(con);
	}

	@IsTest
	static void testGetAccountInfo(){
		Account swiss = [SELECT Id FROM Account WHERE Name = 'TEST AIRLINE' LIMIT 1];

		Account swissInfo = PortalRegistrationSecondLevelCtrl.getAccountInfo(swiss.Id);
	}

	@IsTest
	static void testGetCustomerType(){
		Account acc = [SELECT Sector__c, Category__c FROM Account WHERE Name = 'TEST AIRLINE'];

		String customerType = PortalRegistrationFirstLevelCtrl.getCustomerTypeFromSectorAndCategory(acc.Sector__c, acc.Category__c);

		GCS_Customer_Type_For_Registration__mdt customerTypeMetadata = PortalRegistrationSecondLevelCtrl.getMetadataCustomerTypeForL2(customerType);

		List<GCS_AccountCreation.CustomerTypePicklist> picklists = PortalRegistrationSecondLevelCtrl.getCustomerTypePicklistsForL2(customerType);
	}

	@IsTest
	static void testGetContactInfo(){
		User usr = [SELECT Id FROM User WHERE LastName = 'L1 Contact' LIMIT 1];

		System.runAs(usr) {
			Contact con = PortalRegistrationSecondLevelCtrl.getContactInfo();
		}
	}

	@IsTest
	static void testSaveContactInfo(){
		Contact con = [SELECT Id FROM Contact WHERE LastName = 'L1 Contact'];
		PortalRegistrationSecondLevelCtrl.saveContactInfo(con);
	}

	@IsTest
	static void testGetL2Topics(){
		List<PortalKnowledge__c> topics = PortalRegistrationSecondLevelCtrl.getL2Topics();
	}

	@IsTest
	static void testRegistrationWithNewAccount(){
		Contact con = [SELECT Id FROM Contact WHERE LastName = 'L1 Contact'];

		IATA_ISO_Country__c country = [SELECT Id, Name from IATA_ISO_Country__c WHERE Name = 'Switzerland'];

		IATA_ISO_State__c state = [SELECT Id, Name FROM IATA_ISO_State__c WHERE Name = 'Vaud'];

		String cityName = 'Geneva';
		String cityId = PortalRegistrationSecondLevelCtrl.createIsoCity(cityName, state.Id, false);

		Account acc = new Account(
			Name = 'New Account',
			Sector__c = 'Airline',
			Category__c = 'Passenger and Cargo',

			Business_Street__c = 'Street',
			BillingStreet = 'Street',
			ShippingStreet = 'Street',

			Business_Postal_Code__c = '1234',
			BillingPostalCode = '1234',
			ShippingPostalCode = '1234',

			BillingCountry = country.Name,
			ShippingCountry = country.Name,

			IATA_ISO_Country__c = country.Id,
			IATA_ISO_Shipping_Country__c = country.Id,

			Business_City__c = cityId,
			Business_City_Name__c = cityName,

			Geoname_Billing_City__c = cityId,
			BillingCity = cityName,

			Geoname_Shipping_City__c = cityId,
			ShippingCity = cityName,

			Iso_State__c = state.Id,
			Business_State_Name__c = state.Name,

			IATA_ISO_Billing_State__c = state.Id,
			BillingState = state.Name,

			IATA_ISO_Shipping_State__c = state.Id,
			ShippingState = state.Name
		);

		PortalRegistrationSecondLevelCtrl.registrationWithNewAccount(acc, con);
	}

	@IsTest
	static void testRegistrationWithExistingAccount(){
		Contact con = [SELECT Id FROM Contact WHERE LastName = 'L1 Contact'];
		Account acc = [SELECT Id FROM Account WHERE Name = 'TEST AIRLINE'];

		Boolean success = PortalRegistrationSecondLevelCtrl.registrationWithExistingAccount(acc, con);

		System.assert(success);
	}

	@IsTest
	static void testEmailNotification(){
		Contact con = [SELECT Id FROM Contact WHERE LastName = 'L1 Contact'];

		IATA_ISO_Country__c country = [SELECT Id, Name from IATA_ISO_Country__c WHERE Name = 'Switzerland'];

		IATA_ISO_State__c state = [SELECT Id, Name FROM IATA_ISO_State__c WHERE Name = 'Vaud'];

		String cityName = 'Geneva';
		String cityId = PortalRegistrationSecondLevelCtrl.createIsoCity(cityName, state.Id, false);

		Account acc = new Account(
			Name = 'New Account',
			Sector__c = 'Accommodation',
			Category__c = 'Category for Email Notification  ',

			Business_Street__c = 'Street',
			BillingStreet = 'Street',
			ShippingStreet = 'Street',

			Business_Postal_Code__c = '1234',
			BillingPostalCode = '1234',
			ShippingPostalCode = '1234',

			BillingCountry = country.Name,
			ShippingCountry = country.Name,

			IATA_ISO_Country__c = country.Id,
			IATA_ISO_Shipping_Country__c = country.Id,

			Business_City__c = cityId,
			Business_City_Name__c = cityName,

			Geoname_Billing_City__c = cityId,
			BillingCity = cityName,

			Geoname_Shipping_City__c = cityId,
			ShippingCity = cityName,

			Iso_State__c = state.Id,
			Business_State_Name__c = state.Name,

			IATA_ISO_Billing_State__c = state.Id,
			BillingState = state.Name,

			IATA_ISO_Shipping_State__c = state.Id,
			ShippingState = state.Name
		);

		PortalRegistrationSecondLevelCtrl.registrationWithNewAccount(acc, con);
	}

	@IsTest
	static void testIFTPRegistrationWithNewAccount(){
		Contact con = [SELECT Id FROM Contact WHERE LastName = 'L1 Contact'];

		IATA_ISO_Country__c country = [SELECT Id, Name from IATA_ISO_Country__c WHERE Name = 'Switzerland'];

		IATA_ISO_State__c state = [SELECT Id, Name FROM IATA_ISO_State__c WHERE Name = 'Vaud'];

		String cityName = 'Geneva';
		String cityId = PortalRegistrationSecondLevelCtrl.createIsoCity(cityName, state.Id, false);

		Account acc = new Account(
			Name = 'New Account',
			Sector__c = 'Airline Supplier',
			Category__c = 'Fuel Supplier',

			Business_Street__c = 'Street',
			BillingStreet = 'Street',
			ShippingStreet = 'Street',

			Business_Postal_Code__c = '1234',
			BillingPostalCode = '1234',
			ShippingPostalCode = '1234',

			BillingCountry = country.Name,
			ShippingCountry = country.Name,

			IATA_ISO_Country__c = country.Id,
			IATA_ISO_Shipping_Country__c = country.Id,

			Business_City__c = cityId,

			Geoname_Billing_City__c = cityId,
			BillingCity = cityName,

			Geoname_Shipping_City__c = cityId,
			ShippingCity = cityName,

			Iso_State__c = state.Id,

			IATA_ISO_Billing_State__c = state.Id,
			BillingState = state.Name,

			IATA_ISO_Shipping_State__c = state.Id,
			ShippingState = state.Name
		);

		Portal_Applications__c portalApp = new Portal_Applications__c(Name = 'IFTP');
		insert portalApp;

		//Create Accounts Roles
		List<Account_Roles__c> accRolesList = new List<Account_Roles__c>();
		Account_Roles__c accRolesITP = new Account_Roles__c(Name = 'ITP');
		Account_Roles__c accRolesAirline = new Account_Roles__c(Name = 'Airline');
		Account_Roles__c accRolesAirlineSup = new Account_Roles__c(Name = 'Airline Supplier - ITP');
		accRolesList.add(accRolesITP);
		accRolesList.add(accRolesAirline);
		accRolesList.add(accRolesAirlineSup);
		insert accRolesList;

		//Create Accounts Services'
		List<Account_Role_Services__c> accRoleServicesList = new List<Account_Role_Services__c>();
		Account_Role_Services__c accRoleServicesITP = new Account_Role_Services__c(Name = 'IFTP - ITP', Account_Roles__c = accRolesITP.Id, Portal_Service__c = portalApp.Id);
		Account_Role_Services__c accRoleServicesAirline = new Account_Role_Services__c(Name = 'IFTP - Airline', Account_Roles__c = accRolesAirline.Id, Portal_Service__c = portalApp.Id);
		accRoleServicesList.add(accRoleServicesITP);
		accRoleServicesList.add(accRoleServicesAirline);
		insert accRoleServicesList;


		Test.startTest();
		PortalRegistrationSecondLevelCtrl.registrationWithNewAccount(acc, con);
		Test.stopTest();
	}

	@IsTest
	static void testIFTPRegistrationWithExistingAccount(){
		Contact con = [SELECT Id FROM Contact WHERE LastName = 'L1 Contact'];
		Account acc = [SELECT Id FROM Account WHERE Name = 'TEST ITP'];

		Portal_Applications__c portalApp = new Portal_Applications__c(Name = 'IFTP');
		insert portalApp;

		//Create Accounts Roles
		List<Account_Roles__c> accRolesList = new List<Account_Roles__c>();
		Account_Roles__c accRolesITP = new Account_Roles__c(Name = 'ITP');
		Account_Roles__c accRolesAirline = new Account_Roles__c(Name = 'Airline');
		Account_Roles__c accRolesAirlineSup = new Account_Roles__c(Name = 'Airline Supplier - ITP');
		accRolesList.add(accRolesITP);
		accRolesList.add(accRolesAirline);
		accRolesList.add(accRolesAirlineSup);
		insert accRolesList;

		//Create Accounts Services'
		List<Account_Role_Services__c> accRoleServicesList = new List<Account_Role_Services__c>();
		Account_Role_Services__c accRoleServicesITP = new Account_Role_Services__c(Name = 'IFTP - ITP', Account_Roles__c = accRolesITP.Id, Portal_Service__c = portalApp.Id);
		Account_Role_Services__c accRoleServicesAirline = new Account_Role_Services__c(Name = 'IFTP - Airline', Account_Roles__c = accRolesAirline.Id, Portal_Service__c = portalApp.Id);
		accRoleServicesList.add(accRoleServicesITP);
		accRoleServicesList.add(accRoleServicesAirline);
		insert accRoleServicesList;

		String RECTYPE_ITP_AccRole = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Role__c', 'IFTP');
		Account_Role__c accRole = new Account_Role__c(account__c = acc.id, recordtypeid = RECTYPE_ITP_AccRole);
		insert accRole;

		Test.startTest();
		Boolean success = PortalRegistrationSecondLevelCtrl.registrationWithExistingAccount(acc, con);
		Test.stopTest();

	}

}
