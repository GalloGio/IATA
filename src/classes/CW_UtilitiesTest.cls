@isTest
public class CW_UtilitiesTest {
	@testSetup
	public static void setupTestData() {
		Profile pf = [SELECT Id FROM profile WHERE Name LIKE '%IATA Customer Community User%' LIMIT 1];
		String orgId = UserInfo.getOrganizationId();
		String dateString = String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
		Integer RandomId = Integer.valueOf(Math.rint(Math.random() * 1000000));
		String uniqueName = orgId + dateString + RandomId;

		IATA_ISO_Country__c country = CW_TestDataFactory.newISOCountry();
		insert country;

		IATA_ISO_State__c state = new IATA_ISO_State__c(IEC_Valid_SAP__c = true, IATA_ISO_Country__c = country.Id, Name = 'Ontario', ISO_Code__c = 'CA-ON');
		insert state;

		IATA_ISO_City__c city = new IATA_ISO_City__c(Name = 'Madrid', IATA_ISO_State__c = state.id, Status__c = 'Verified', GeonameName__c = 'Madrid');
		insert city;

		Account acc = CW_TestDataFactory.TestAccount(country.Id);
		acc.Business_City__c = city.Id;
		insert acc;

		Airport_Detail__c airport = CW_TestDataFactory.newAirport(country.Id, acc.Id);
		insert airport;

		Contact con1 = CW_TestDataFactory.testContact(acc.id);
		insert con1;

		Account_Role__c accRole = CW_TestDataFactory.testAccountRole(acc.Id, 'Test');
		insert accRole;

		Account_Role__c accRole2 = CW_TestDataFactory.testAccountRole(acc.Id, 'Test2');
		insert accRole2;

		ICG_Account_Role_Detail__c accRoleDetail = CW_TestDataFactory.testICGAccountRoleDetail(accRole.Id, airport);
		insert accRoleDetail;

		ICG_Account_Role_Detail__c accRoleDetail2 = CW_TestDataFactory.testICGAccountRoleDetail(accRole2.Id, airport);
		insert accRoleDetail2;

		User uu = CW_TestDataFactory.testUser('IATAICGACB', 'IATAICGXYZ', uniqueName, orgId, pf.Id, con1.id);
		insert uu;

		Account_Contact_Role__c acr = CW_TestDataFactory.testAccountContactRole(accRole.Id, acc.Id, con1.Id);
		insert acr;
		System.debug(LoggingLevel.FINE, 'AB:: SETUP Account_Contact_Role__c = >' + acr.Id);

		ISSP_CS__c icgUralBase = new ISSP_CS__c(Name = 'ICG_URL_Base', Value__c = 'https://theurl.com/s/');
		insert icgUralBase;

		List<Account_Role_Relationship__c> lstARR = new List<Account_Role_Relationship__c>();
		Account_Role_Relationship__c arr = new Account_Role_Relationship__c(From__c = accRole.Id, To__c = accRole2.Id, Ops_Hierarchy_Group__c = 'Test');
		lstARR.add(arr);
		Account_Role_Relationship__c arr2 = new Account_Role_Relationship__c(From__c = accRole2.Id, Relationship_Name__c = 'TestNameRelationship', To__c = accRole2.Id, Ops_Hierarchy_Group__c = 'Test');
		lstARR.add(arr2);
		insert lstARR;
	}
	/*
	 * @author
	 * Description: Get infamation of he metadata for the footer
	 */
	@istest
	static void testGetMetadataInfo() {
		test.startTest();
		ICG_Portal_URL__mdt mtdResult = CW_Utilities.getMetadataInfo('Twitter');
		test.stopTest();

		System.assertEquals(mtdResult.MasterLabel, 'Twitter');
		System.assertEquals(mtdResult.DeveloperName, 'Twitter');
	}
	/*
	 * @author
	 * Description: Get url from custom metadata
	 */
	@istest
	static void testGetURL() {
		test.startTest();
		String url = CW_Utilities.getURLPage('URL_ICG_ResultPage');
		test.stopTest();

		System.assert(url.containsIgnoreCase('search-results'));
	}
	/*
	 * @author
	 * Description: Get url from custom metadata
	 */
	@istest
	static void testGetEnvironmentVariables() {
		ICG_Environment_Variables__c env = new ICG_Environment_Variables__c();
		env.EXPIRING_VALIDATION_DAYS__c = 60;
		insert env;
		test.startTest();
		ICG_Environment_Variables__c envVars = CW_Utilities.getEnvironmentVariables();
		test.stopTest();

		System.assertEquals(60, envVars.EXPIRING_VALIDATION_DAYS__c);
	}
	/*
	 * @author
	 * Description: Get url from custom metadata
	 */
	@istest
	static void testUserRole() {
		List<User> urs = [SELECT id, accountid, contactid FROM user WHERE firstname = 'IATAICGACB' AND lastname = 'IATAICGXYZ'];
		List<ICG_Account_Role_Detail__c> ard = [SELECT id FROM ICG_Account_Role_Detail__c];
		List<Account_Contact_Role__c> acr = [SELECT Id FROM Account_Contact_Role__c];

		//For some reason I cannot yet see, this object cannot be created in the SETUP method
		ICG_Contact_Role_Detail__c crd = CW_TestDataFactory.testICGContactRoleDetail(acr[0].id, ard[0].id);
		insert crd;

		System.runAs(urs[0]) {
			test.startTest();
			String userRole = CW_Utilities.getUserRole(ard[0].id);
			test.stopTest();

			System.assertEquals('Facility Manager', userRole);
		}

	}
	/**@description Since there code to be tested depends on he existance of the ICG_Account_Role_Detail__c custom object
	 *              an invoke to the method and validation of non-empty result string is proposed.
	 */
	@isTest
	static void testGetCompanyTypes() {
		test.startTest();
		String result = CW_Utilities.getCompanyTypes();
		test.stopTest();

		System.assert(string.isNotBlank(result), 'Mere execution test:: If Result is blank, then no RecordTypes are registered for the ICG_Account_Role_Detail__c object.');
	}

	/**@description Validates the GetIATACountries method
	 */
	@isTest
	static void testGetIATACountries() {
		List<IATA_ISO_Country__c> countries = new List<IATA_ISO_Country__c>();
		countries.add(new IATA_ISO_Country__c(name = 'Guyana', ISO_Code__c = 'GY', ISO_Code_Numeric__c = 328));
		countries.add(new IATA_ISO_Country__c(name = 'Saint Lucia', ISO_Code__c = 'LC', ISO_Code_Numeric__c = 662));
		countries.add(new IATA_ISO_Country__c(name = 'South Africa', ISO_Code__c = 'ZA', ISO_Code_Numeric__c = 710));
		countries.add(new IATA_ISO_Country__c(name = 'New Zealand', ISO_Code__c = 'NZ', ISO_Code_Numeric__c = 554));

		insert countries;

		test.startTest();
		String result = CW_Utilities.getIATACountries();
		test.stopTest();

		System.assert(result.contains('NZ'), 'Validate existance of ítem');
	}

	/**@description Validates an empty result for the getResourceURL method
	 */
	@isTest
	static void testEMPTYgetResourceURL() {
		test.startTest();
		String result = CW_Utilities.getResourceURL('Invalid Reource Name');
		test.stopTest();

		System.assert(result == '', 'Validates an empty resultset');
	}

	/**@description Validates the "No Account Contact Role" section of the BecomeFacilityAdmin Method
	 */
	@isTest
	static void testBecomeFacilityAdminNoAccountContactRole() {
		List<ICG_Account_Role_Detail__c> accRoleDetail = [SELECT Id FROM ICG_Account_Role_Detail__c WHERE Nearest_Airport__r.Code__c = 'MAD' AND IATA_ISO_Country__r.Name = 'Spain' AND City_FOR__c = 'Madrid'];

		List<Contact> cont = [SELECT Id FROM Contact WHERE FirstName = 'Test'];

		test.startTest();
		String result = CW_Utilities.becomeFacilityAdmin('88', accRoleDetail[0].Id, cont[0].Id, false);
		test.stopTest();

		System.assert(result.contains('No Account Contact Role'), 'No Account Contact Role response validation');
	}

	/**@description Validates the "Submitted == true" section of the BecomeFacilityAdmin Method
	 */
	@isTest
	static void testBecomeFacilityAdminSubmittedOK() {
		List<Account> acct = [SELECT Id FROM Account WHERE Name = 'Account01'];
		List<ICG_Account_Role_Detail__c> accRoleDetail = [SELECT Id FROM ICG_Account_Role_Detail__c WHERE Nearest_Airport__r.Code__c = 'MAD' AND IATA_ISO_Country__r.Name = 'Spain' AND City_FOR__c = 'Madrid'];
		List<Contact> cont = [SELECT Id FROM Contact WHERE FirstName = 'Test'];

		test.startTest();
		String result = CW_Utilities.becomeFacilityAdmin(acct[0].Id, accRoleDetail[0].Id, cont[0].Id, false);
		test.stopTest();

		System.assert(result.contains('Thank you for your request'), 'Not succesfull Submition request');
	}

	/**@description Validates the "No Facility" section of the BecomeFacilityAdmin Method
	 */
	@isTest
	static void testBecomeFacilityAdminSubmittedNoFacility() {
		List<Account> acct = [SELECT Id FROM Account WHERE Name = 'Account01'];
		List<Contact> cont = [SELECT Id FROM Contact WHERE FirstName = 'Test'];

		test.startTest();
		String result = CW_Utilities.becomeFacilityAdmin(acct[0].Id, null, cont[0].Id, null);
		test.stopTest();

		System.assert(result.contains('Please, select at least one facility'), 'Null Facility validation');
	}

	/**@description Validates the "submitted == true " section of the BecomeCompanyAdmin Method
	 */
	@isTest
	static void testBecomeCompanyAdminOK() {
		List<Account> acct = [SELECT Id, Name FROM Account WHERE Name = 'Account01'];
		List<Contact> cont = [SELECT Id FROM Contact WHERE FirstName = 'Test'];

		test.startTest();
		String result = CW_Utilities.becomeCompanyAdmin(acct[0].Name, acct[0].Id, cont[0].Id);
		test.stopTest();

		System.debug(LoggingLevel.FINE, 'AB:: result => ' + result);

		System.assert(result.contains('Thank you for your request'), 'Not succesfull Submition request');
	}

	/**@description Validates the "No Account Contact Role" section of the BecomeCompanyAdmin Method
	 */
	@isTest
	static void testBecomeCompanyAdminNoAccountContactRole() {
		List<Contact> cont = [SELECT Id FROM Contact WHERE FirstName = 'Test'];

		test.startTest();
		String result = CW_Utilities.becomeCompanyAdmin(null, '88', cont[0].Id);
		test.stopTest();

		System.debug(LoggingLevel.FINE, 'AB:: result => ' + result);

		System.assert(result.contains('No Account Contact Role'), 'No Account Contact Role response validation');
	}

	/**@description Validates the getFacilityLanguages method
	 */
	@isTest
	static void testGetFacilityLanguages() {
		test.startTest();
		String result = CW_Utilities.getFacilityLanguages();
		test.stopTest();

		Boolean languageFound = false;
		List<CW_Utilities.PicklistValue> picklistValues = (List<CW_Utilities.PicklistValue>) JSON.deserialize(result, List<CW_Utilities.PicklistValue>.class);
		for (CW_Utilities.PicklistValue pv : picklistValues) {
			if (pv.value == 'Spanish') {
				languageFound = true;
			}
		}

		System.assertEquals(true, languageFound, 'Spanish language does not exist');
	}

	/**@description Validates the getPicklistFieldDependencies method
	 */
	@isTest
	static void testGetPicklistFieldDependencies() {
		test.startTest();
		Map<String, List<Map<String, Object>>> result = CW_Utilities.getPicklistFieldDependencies('Account_Role_Detail_Capability__c', 'Category__c', 'Equipment__c', true);
		test.stopTest();

		System.assertEquals(true, result.containsKey('15_to_25_c'), 'Field dependency does not exist');
	}

	/**@description Validates the getPicklistValues method
	 */
	@isTest
	static void testGetPicklistValues() {
		test.startTest();
		List<CW_Utilities.picklistVal> result = (List<CW_Utilities.picklistVal>) JSON.deserialize(CW_Utilities.getPicklistValues('ICG_Capability_Assignment_Group__c', 'CEIV_Scope_List__c'), List<CW_Utilities.picklistVal>.class);
		test.stopTest();

		Boolean pickListApiFound = false;

		for (CW_Utilities.picklistVal pv : result) {
			if (pv.api == 'Cargo_Handling') {
				pickListApiFound = true;
			}
		}

		System.assertEquals(true, pickListApiFound, 'Cargo_Handling was not found');
	}

	@isTest
	static void testApproveRejectStationAutomaticProcess() {
		List<User> urs = [SELECT id, accountid, contactid FROM user WHERE firstname = 'IATAICGACB' AND lastname = 'IATAICGXYZ'];
		List<ICG_Account_Role_Detail__c> ard = [SELECT id FROM ICG_Account_Role_Detail__c];
		List<Account_Contact_Role__c> acr = [SELECT Id FROM Account_Contact_Role__c];
		List<Account_Role__c> arc = [SELECT Id FROM Account_Role__c LIMIT 1];

		//For some reason I cannot yet see, this object cannot be created in the SETUP method
		ICG_Contact_Role_Detail__c crd = CW_TestDataFactory.testICGContactRoleDetail(acr[0].id, ard[0].id);
		crd.ICG_Role__c = 'Company Admin';
		crd.Status__c = 'Approved';
		crd.Account_Role__c = arc[0].Id;

		insert crd;
		Boolean aux = false;
		System.runAs(urs[0]) {
			test.startTest();
			aux = CW_Utilities.approveStationAutomaticProcess(ard[0].Id);
			System.assertEquals(false, aux, 'The process run correctly');
			aux = CW_Utilities.approveStationAutomaticProcess('notId');
			System.assertEquals(false, aux, 'The process run correctly');
			aux = CW_Utilities.rejectStationAutomaticProcess(ard[0].Id, 'the reason');
			System.assertEquals(false, aux, 'The process run correctly');
			aux = CW_Utilities.rejectStationAutomaticProcess('notId', 'the reason');
			System.assertEquals(false, aux, 'The process run correctly');
			test.stopTest();
		}
	}

	@isTest
	static void testGetOpsHierarchy() {
		//List<Account_Role_Relationship__c> lstARR = [SELECT Id FROM Account_Role_Relationship__c];

		List<User> urs = [SELECT id, accountid, contactid FROM user WHERE firstname = 'IATAICGACB' AND lastname = 'IATAICGXYZ'];
		List<ICG_Account_Role_Detail__c> ard = [SELECT id FROM ICG_Account_Role_Detail__c];
		System.debug(LoggingLevel.FINE, '@FIX->usr: ' + urs);
		System.debug(LoggingLevel.FINE, '@FIX->ard: ' + ard);
		test.startTest();
		String hFromUser = CW_Utilities.getOpsHierarchyNameFromUserId(urs[0].Id);
		String hFromStation = CW_Utilities.getOpsHierarchyNameFromStationId(ard[0].Id);
		test.stopTest();
		System.assertEquals('TestNameRelationship', hFromUser, 'Hierarchy Fails');
		System.assertEquals('TestNameRelationship', hFromStation, 'Hierarchy Fails');
	}

	@isTest
	static void testGetCompanyAdminContacts() {
		List<Account_Role_Relationship__c> lstARR = [SELECT Id, Relationship_Name__c FROM Account_Role_Relationship__c];
		List<Account_Role__c> listAR = [SELECT Id, Account_Role_Name__c FROM Account_Role__c WHERE Account_Role_Name__c = 'Test'];
		List<Contact> auxContact = new List<Contact>();
		String aux = '';
		test.startTest();
		auxContact = CW_Utilities.getCompanyAdminContactsFromGroupName(lstARR[0].Relationship_Name__c);
		aux = CW_Utilities.getOpsHierarchyNameFromAccountId(listAR[0].Account_Role_Name__c);
		test.stopTest();
		System.assertEquals(0, auxContact.size(), 'Contact list size > 0');
		System.assertEquals(null, aux, 'Hierarchy Fails');
	}

	@isTest
	static void testSendEmailTemplate() {
		List<Account> acc = [SELECT Id FROM Account];
		List<Contact> cnt = [SELECT Id FROM Contact];
		List<EmailTemplate> eTemplate = [SELECT Id, DeveloperName FROM EmailTemplate WHERE isActive = true LIMIT 1];
		Boolean aux = false;
		test.startTest();
		aux = CW_Utilities.sendEmailTemplate(eTemplate[0].DeveloperName, acc[0].Id, cnt[0].Id, new List<String>{ 'intent@gmail.com', 'intent2@gmail.com' });
		test.stopTest();
		System.assertEquals(true, aux, 'Email sender Fails');
	}

	@IsTest
	public static void handleContactRoleDetailRemovalProcessStationManager() {
		List<User> urs = [SELECT id, accountid, contactid FROM user WHERE firstname = 'IATAICGACB' AND lastname = 'IATAICGXYZ'];
		List<ICG_Account_Role_Detail__c> ard = [SELECT id FROM ICG_Account_Role_Detail__c];
		List<Account_Contact_Role__c> acr = [SELECT Id FROM Account_Contact_Role__c];
		List<Account_Role__c> arc = [SELECT Id FROM Account_Role__c LIMIT 1];

		//For some reason I cannot yet see, this object cannot be created in the SETUP method
		ICG_Contact_Role_Detail__c crd = CW_TestDataFactory.testICGContactRoleDetail(acr[0].id, ard[0].id);
		crd.ICG_Role__c = 'Facility Manager';
		crd.Status__c = 'Pending for Removal';
		crd.Account_Role__c = arc[0].Id;
		insert crd;
		System.runAs(urs[0]) {
			test.startTest();
			String resultApproved = CW_Utilities.handleContactRoleDetailRemovalProcess(crd.Id, true);
			System.assertEquals('MissingRights', resultApproved, 'User were allowed to edit even without being a company admin');
			String resultRejected = CW_Utilities.handleContactRoleDetailRemovalProcess(crd.Id, false);
			System.assertEquals('MissingRights', resultRejected, 'User were allowed to edit even without being a company admin');
			test.stopTest();
		}

	}

	@IsTest
	public static void rejectContactRoleDetailAutomaticProcessTest() {
		List<User> urs = [SELECT id, accountid, contactid FROM user WHERE firstname = 'IATAICGACB' AND lastname = 'IATAICGXYZ'];
		List<ICG_Account_Role_Detail__c> ard = [SELECT id FROM ICG_Account_Role_Detail__c];
		List<Account_Contact_Role__c> acr = [SELECT Id FROM Account_Contact_Role__c];
		List<Account_Role__c> arc = [SELECT Id, Account__c FROM Account_Role__c LIMIT 1];
		List<Account> acc = [SELECT Id FROM Account LIMIT 1];

		//For some reason I cannot yet see, this object cannot be created in the SETUP method
		ICG_Contact_Role_Detail__c crd = CW_TestDataFactory.testICGContactRoleDetail(acr[0].id, ard[0].id);
		crd.ICG_Role__c = 'Facility Manager';
		crd.Account_Role__c = arc[0].Id;

		insert crd;
		System.runAs(urs[0]) {
			test.startTest();
			CW_Utilities.rejectContactRoleDetailAutomaticProcess(crd.Id, 'test reject reason');

			crd.Status__c = 'Pending for Approval';
			CW_Utilities.rejectContactRoleDetailAutomaticProcess(crd.Id, 'test reject reason');

			crd.ICG_Role__c = 'test';
			CW_Utilities.rejectContactRoleDetailAutomaticProcess(crd.Id, 'test reject reason');

			test.stopTest();
		}
	}

	@IsTest
	public static void getRelatedAccountsByStationTest() {
		List<User> urs = [SELECT id, accountid, contactid FROM user WHERE firstname = 'IATAICGACB' AND lastname = 'IATAICGXYZ'];
		List<ICG_Account_Role_Detail__c> ard = [SELECT id FROM ICG_Account_Role_Detail__c];
		List<Account_Contact_Role__c> acr = [SELECT Id FROM Account_Contact_Role__c];
		List<Account_Role__c> arc = [SELECT Id FROM Account_Role__c LIMIT 1];

		//For some reason I cannot yet see, this object cannot be created in the SETUP method
		ICG_Contact_Role_Detail__c crd = CW_TestDataFactory.testICGContactRoleDetail(acr[0].id, ard[0].id);
		crd.ICG_Role__c = 'Facility Manager';
		crd.Account_Role__c = arc[0].Id;
		insert crd;
		System.runAs(urs[0]) {
			test.startTest();
			CW_Utilities.getRelatedAccountsByStation(crd.Id);
			test.stopTest();
		}
	}

	@IsTest
	public static void getFacilityManagerContactRolesFromStationListByUserTest() {
		List<User> urs = [SELECT id, accountid, contactid FROM user WHERE firstname = 'IATAICGACB' AND lastname = 'IATAICGXYZ'];
		List<ICG_Account_Role_Detail__c> ard = [SELECT id FROM ICG_Account_Role_Detail__c];
		List<Account_Contact_Role__c> acr = [SELECT Id FROM Account_Contact_Role__c];
		List<Account_Role__c> arc = [SELECT Id FROM Account_Role__c LIMIT 1];

		//For some reason I cannot yet see, this object cannot be created in the SETUP method
		ICG_Contact_Role_Detail__c crd = CW_TestDataFactory.testICGContactRoleDetail(acr[0].id, ard[0].id);
		crd.ICG_Role__c = 'Facility Manager';
		crd.Account_Role__c = arc[0].Id;
		insert crd;
		System.runAs(urs[0]) {
			test.startTest();
			CW_Utilities.getFacilityManagerContactRolesFromStationListByUser(urs[0].Id);
			test.stopTest();
		}
	}

	@IsTest
	public static void sendApproveOrRejectMailsContactRoleTest() {
		List<User> urs = [SELECT id, accountid, contactid FROM user WHERE firstname = 'IATAICGACB' AND lastname = 'IATAICGXYZ'];
		List<ICG_Account_Role_Detail__c> ard = [SELECT id FROM ICG_Account_Role_Detail__c];
		List<Account_Contact_Role__c> acr = [SELECT Id FROM Account_Contact_Role__c];
		List<Account_Role__c> arc = [SELECT Id FROM Account_Role__c LIMIT 1];

		//For some reason I cannot yet see, this object cannot be created in the SETUP method
		ICG_Contact_Role_Detail__c crd = CW_TestDataFactory.testICGContactRoleDetail(acr[0].id, ard[0].id);
		crd.ICG_Role__c = 'Facility Manager';
		crd.Status__c = 'Approved';
		crd.Account_Role__c = arc[0].Id;

		ICG_Contact_Role_Detail__c crd1 = CW_TestDataFactory.testICGContactRoleDetail(acr[0].id, ard[0].id);
		crd1.ICG_Role__c = 'Facility Manager';
		crd1.Status__c = 'Rejected';
		crd1.Account_Role__c = arc[0].Id;
		insert crd;
		System.runAs(urs[0]) {
			test.startTest();
			CW_Utilities.sendApproveOrRejectMailsContactRole(crd, crd1);

			crd.ICG_Role__c = 'Company Admin';
			CW_Utilities.sendApproveOrRejectMailsContactRole(crd, crd1);

			crd.Status__c = 'Rejected';
			crd.ICG_Role__c = 'Facility Manager';
			crd1.Status__c = 'Approved';
			CW_Utilities.sendApproveOrRejectMailsContactRole(crd, crd1);

			crd.Status__c = 'Rejected';
			crd.ICG_Role__c = 'Company Admin';
			crd1.Status__c = 'Approved';
			CW_Utilities.sendApproveOrRejectMailsContactRole(crd, crd1);

			crd.Status__c = 'Removed';
			CW_Utilities.sendApproveOrRejectMailsContactRole(crd, crd1);
			test.stopTest();
		}
	}

	@IsTest
	public static void approveContactRoleDetailAutomaticProcessTest() {
		List<User> urs = [SELECT id, accountid, contactid FROM user WHERE firstname = 'IATAICGACB' AND lastname = 'IATAICGXYZ'];
		List<ICG_Account_Role_Detail__c> ard = [SELECT id FROM ICG_Account_Role_Detail__c];
		List<Account_Contact_Role__c> acr = [SELECT Id FROM Account_Contact_Role__c];
		List<Account_Role__c> arc = [SELECT Id FROM Account_Role__c LIMIT 1];

		//For some reason I cannot yet see, this object cannot be created in the SETUP method
		ICG_Contact_Role_Detail__c crd = CW_TestDataFactory.testICGContactRoleDetail(acr[0].id, ard[0].id);
		crd.ICG_Role__c = 'Facility Manager';
		crd.Account_Role__c = arc[0].Id;
		insert crd;
		System.runAs(urs[0]) {
			test.startTest();
			CW_Utilities.approveContactRoleDetailAutomaticProcess(crd.Id);

			crd.Status__c = 'Pending for Approval';
			CW_Utilities.approveContactRoleDetailAutomaticProcess(crd.Id);

			test.stopTest();
		}
	}

	@IsTest
	public static void sendApproveOrRejectMailsTest() {
		List<User> urs = [SELECT id, accountid, contactid FROM user WHERE firstname = 'IATAICGACB' AND lastname = 'IATAICGXYZ'];
		List<ICG_Account_Role_Detail__c> ard = [SELECT id, Account_Role__r.Account__r.RecordType.DeveloperName FROM ICG_Account_Role_Detail__c];
		List<Account_Contact_Role__c> acr = [SELECT Id FROM Account_Contact_Role__c];
		List<Account_Role__c> arc = [SELECT Id FROM Account_Role__c LIMIT 1];
		String contactId = [SELECT Id FROM Contact LIMIT 1].Id;

		//For some reason I cannot yet see, this object cannot be created in the SETUP method
		ICG_Contact_Role_Detail__c crd = CW_TestDataFactory.testICGContactRoleDetail(acr[0].id, ard[0].id);
		crd.ICG_Role__c = 'Facility Manager';
		crd.Status__c = 'Approved';
		crd.Account_Role__c = arc[0].Id;

		ICG_Contact_Role_Detail__c crd1 = CW_TestDataFactory.testICGContactRoleDetail(acr[0].id, ard[0].id);
		crd1.ICG_Role__c = 'Facility Manager';
		crd1.Status__c = 'Rejected';
		crd1.Account_Role__c = arc[0].Id;
		insert crd;

		test.startTest();

		ard[0].Status__c = 'Approved';
		ard[1].Status__c = 'Rejected';
		CW_Utilities.sendApproveOrRejectMails(ard[0], ard[1]);

		test.stopTest();
	}

	@IsTest
	public static void updateAllStationManagementRecordsTest() {
		List<User> urs = [SELECT id, accountid, contactid FROM user WHERE firstname = 'IATAICGACB' AND lastname = 'IATAICGXYZ'];
		List<ICG_Account_Role_Detail__c> ard = [SELECT id, Account_Role__r.Account__r.RecordType.DeveloperName, CreatedBy.ContactId FROM ICG_Account_Role_Detail__c];
		List<Account_Contact_Role__c> acr = [SELECT Id FROM Account_Contact_Role__c];
		List<Account_Role__c> arc = [SELECT Id FROM Account_Role__c LIMIT 1];
		String contactId = [SELECT Id FROM Contact LIMIT 1].Id;

		//For some reason I cannot yet see, this object cannot be created in the SETUP method
		ICG_Contact_Role_Detail__c crd = CW_TestDataFactory.testICGContactRoleDetail(acr[0].id, ard[0].id);
		crd.ICG_Role__c = 'Facility Manager';
		crd.Status__c = 'Approved';
		crd.Account_Role__c = arc[0].Id;

		ICG_Contact_Role_Detail__c crd1 = CW_TestDataFactory.testICGContactRoleDetail(acr[0].id, ard[0].id);
		crd1.ICG_Role__c = 'Facility Manager';
		crd1.Status__c = 'Rejected';
		crd1.Account_Role__c = arc[0].Id;
		insert crd;

		test.startTest();

		CW_Utilities.updateAllStationManagementRecords(ard[0].CreatedBy.ContactId, ard[0].Id, 'Rejected');

		test.stopTest();
	}

	@IsTest
	public static void getPendingCompanyAdminContactRolesFromGroupNameTest() {
		List<User> urs = [SELECT id, accountid, contactid FROM user WHERE firstname = 'IATAICGACB' AND lastname = 'IATAICGXYZ'];
		List<ICG_Account_Role_Detail__c> ard = [SELECT id FROM ICG_Account_Role_Detail__c];
		List<Account_Contact_Role__c> acr = [SELECT Id FROM Account_Contact_Role__c];
		List<Account_Role__c> arc = [SELECT Id FROM Account_Role__c LIMIT 1];

		//For some reason I cannot yet see, this object cannot be created in the SETUP method
		ICG_Contact_Role_Detail__c crd = CW_TestDataFactory.testICGContactRoleDetail(acr[0].id, ard[0].id);
		crd.ICG_Role__c = 'Facility Manager';
		crd.Status__c = 'Pending for Approval';
		crd.Account_Role__c = arc[0].Id;
		insert crd;
		System.runAs(urs[0]) {
			test.startTest();
			String groupName = CW_Utilities.getOpsHierarchyNameFromStationId(crd.Id);
			CW_Utilities.getPendingCompanyAdminContactRolesFromGroupName(groupName);
			test.stopTest();
		}
	}

	// @istest
	// static void testUserRoleAdmin() {
	// 	List<User> urs = [SELECT id, accountid, contactid FROM user WHERE firstname = 'IATAICGACB' AND lastname = 'IATAICGXYZ'];
	// 	List<ICG_Account_Role_Detail__c> ard = [Select id, Account_Role__r.Account__r.Name from ICG_Account_Role_Detail__c];
	// 	List<Account_Contact_Role__c> acr = [SELECT Id FROM Account_Contact_Role__c];
	//     List<Account_Role__c> arc = [SELECT Id, Account__r.Name FROM Account_Role__c LIMIT 1];

	// 	//For some reason I cannot yet see, this object cannot be created in the SETUP method
	// 	ICG_Contact_Role_Detail__c crd = CW_TestDataFactory.testICGContactRoleDetail(acr[0].id, ard[0].id);
	// 	crd.ICG_Role__c = 'Company Admin';
	//     crd.Status__c = 'Approved';
	//     crd.Account_Role__c = arc[0].Id;
	//     insert crd;

	//     List<Account_Role_Relationship__c> arr = [SELECT Id FROM Account_Role_Relationship__c];
	//     arr[0].Relationship_Name__c = 'Account01';
	//     arr[1].Relationship_Name__c = 'Account01';
	//     update arr;

	//     ard[0].Account_Role__r.Account__r.Name = 'Account01';
	//     update ard[0];

	//     List<Account_Role__c> arc1 = [Select Id, Account__r.Name from Account_Role__c];
	//     arc1[0].Account__r.Name = ard[0].Account_Role__r.Account__r.Name;
	//     arc1[1].Account__r.Name = ard[0].Account_Role__r.Account__r.Name;
	//     update arc1;

	// 	System.runAs(urs[0]) {
	// 		test.startTest();
	// 		String userRoleAdmin = CW_Utilities.getUserRole(ard[0].id);
	//         System.assertEquals('Company Admin', userRoleAdmin, 'not a company admin' + userRoleAdmin);
	// 		test.stopTest();
	// 	}
	// }

	@istest
	static void testUserAdminActions() {
		List<User> urs = [SELECT id, accountid, contactid FROM user WHERE firstname = 'IATAICGACB' AND lastname = 'IATAICGXYZ'];
		List<ICG_Account_Role_Detail__c> ard = [SELECT id, Account_Role__r.Account__r.Name FROM ICG_Account_Role_Detail__c];
		List<Account_Contact_Role__c> acr = [SELECT Id FROM Account_Contact_Role__c];
		List<Account_Role__c> arc = [SELECT Id, Account__r.Name FROM Account_Role__c LIMIT 1];

		//For some reason I cannot yet see, this object cannot be created in the SETUP method
		ICG_Contact_Role_Detail__c crd = CW_TestDataFactory.testICGContactRoleDetail(acr[0].id, ard[0].id);
		crd.ICG_Role__c = 'Company Admin';
		crd.Status__c = 'Approved';
		crd.Account_Role__c = arc[0].Id;
		insert crd;

		List<Account_Role_Relationship__c> arr = [SELECT Id FROM Account_Role_Relationship__c];
		arr[0].Relationship_Name__c = 'Account01';
		arr[1].Relationship_Name__c = 'Account01';
		update arr;

		ard[0].Account_Role__r.Account__r.Name = 'Account01';
		ard[0].Status__c = 'Pending for Approval';
		ard[1].Status__c = 'Pending for Approval';
		update ard;

		List<Account_Role__c> arc1 = [SELECT Id, Account__r.Name FROM Account_Role__c];
		arc1[0].Account__r.Name = ard[0].Account_Role__r.Account__r.Name;
		arc1[1].Account__r.Name = ard[0].Account_Role__r.Account__r.Name;
		update arc1;

		System.runAs(urs[0]) {
			test.startTest();
			String userRoleAdmin = CW_Utilities.getUserRole(ard[0].id);
			System.assertEquals('Company Admin', userRoleAdmin, 'not a company admin' + userRoleAdmin);

			CW_Utilities.approveStationAutomaticProcess(ard[0].Id);
			CW_Utilities.handleContactRoleDetailRemovalProcess(crd.Id, true);
			CW_Utilities.approveContactRoleDetailAutomaticProcess(crd.Id);
			test.stopTest();
		}
	}

	@istest
	static void testCatches() {
		List<User> urs = [SELECT id, accountid, contactid FROM user WHERE firstname = 'IATAICGACB' AND lastname = 'IATAICGXYZ'];
		List<ICG_Account_Role_Detail__c> ard = [SELECT id, Account_Role__r.Account__r.RecordType.DeveloperName FROM ICG_Account_Role_Detail__c];
		List<Account_Contact_Role__c> acr = [SELECT Id FROM Account_Contact_Role__c];
		List<Account_Role__c> arc = [SELECT Id FROM Account_Role__c LIMIT 1];
		String contactId = [SELECT Id FROM Contact LIMIT 1].Id;

		//For some reason I cannot yet see, this object cannot be created in the SETUP method
		ICG_Contact_Role_Detail__c crd = CW_TestDataFactory.testICGContactRoleDetail(acr[0].id, ard[0].id);
		crd.ICG_Role__c = 'Facility Manager';
		crd.Status__c = 'Approved';
		crd.Account_Role__c = arc[0].Id;

		ICG_Contact_Role_Detail__c crd1 = CW_TestDataFactory.testICGContactRoleDetail(acr[0].id, ard[0].id);
		crd1.ICG_Role__c = 'Facility Manager';
		crd1.Status__c = 'Rejected';
		crd1.Account_Role__c = arc[0].Id;
		insert crd;

		test.startTest();

		try {
			ard[0].Status__c = 'Rejected';
			ard[1].Status__c = 'Approved';
			CW_Utilities.sendApproveOrRejectMails(ard[0], ard[1]);
		} catch (Exception ex) {
		}

		try {
			CW_Utilities.rejectStationAutomaticProcess(ard[0].Id, 'the reason');
		} catch (Exception ex) {
		}

		test.stopTest();
	}
}