@isTest
public class CW_UtilitiesTest {
	@testSetup
	public static void setupTestData() {
		Profile pf = [SELECT Id FROM profile WHERE Name LIKE '%IATA Customer Community User%' LIMIT 1];
		Profile pf2 = [Select Id from profile where Name = 'System Administrator' limit 1]; 
		String orgId = UserInfo.getOrganizationId();
		String dateString = String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
		Integer RandomId = Integer.valueOf(Math.rint(Math.random() * 1000000));
		String uniqueName = orgId + dateString + RandomId;

		User sysAdminUser = [SELECT Id, UserRoleId FROM User Where IsActive = TRUE AND Profile.Name='System Administrator' Limit 1];
		UserRole userRole = [SELECT Id, DeveloperName FROM UserRole Where DeveloperName = 'DirectorGeneral' Limit 1];
		sysAdminUser.UserRoleId = userRole.Id;
		update sysAdminUser;

		Contact con1;
		Account_Role__c accRole;
		Account_Role__c accRole2;
		Account acc;
		System.runAs(sysAdminUser) {

			IATA_ISO_Country__c country = CW_TestDataFactory.newISOCountry();
			insert country;
	
			IATA_ISO_State__c state = new IATA_ISO_State__c(IEC_Valid_SAP__c = true, IATA_ISO_Country__c = country.Id, Name = 'Ontario', ISO_Code__c = 'CA-ON');
			insert state;
	
			IATA_ISO_City__c city = new IATA_ISO_City__c(Name = 'Madrid', IATA_ISO_State__c = state.id, Status__c = 'Verified', GeonameName__c = 'Madrid');
			insert city;

			acc = CW_TestDataFactory.TestAccount(country.Id);
			acc.Business_City__c = city.Id;
			Account ac2 = new Account(Name = 'Account02', IATA_ISO_Country__c = country.Id, Business_City_Name__c = 'Madrid');
			insert new List<Account>{acc, ac2};

			Airport_Detail__c airport = CW_TestDataFactory.newAirport(country.Id, acc.Id);
			insert airport;

			con1 = CW_TestDataFactory.testContact(acc.id);
			insert con1;

			accRole = CW_TestDataFactory.testAccountRole(acc.Id, 'Test');
			accRole2 = CW_TestDataFactory.testAccountRole(ac2.Id, 'Test2');
			insert new List<Account_Role__c>{accRole, accRole2};

			ICG_Account_Role_Detail__c stationOne = CW_TestDataFactory.testICGAccountRoleDetail(accRole.Id, airport);
			stationOne.Name = 'Test 1';
			ICG_Account_Role_Detail__c stationTwo = CW_TestDataFactory.testICGAccountRoleDetail(accRole2.Id, airport);
			stationTwo.Name = 'Test 2';
			ICG_Account_Role_Detail__c stationThree = CW_TestDataFactory.testICGAccountRoleDetailPendingForApproval(accRole2.Id, airport);
			stationThree.Name = 'Test 3';
			insert new List<ICG_Account_Role_Detail__c>{stationOne, stationTwo, stationThree};
		
			User uu = CW_TestDataFactory.testUser('IATAICGACB', 'IATAICGXYZ', uniqueName, orgId, pf.Id, con1.id);
			User uu2 = new User(firstname = 'IATATESTQUEUE', 
							lastName = 'IATAQUEUETEST', 
							email = uniqueName + '2@test' + orgId + '.org', 
							Username = uniqueName + '2@test' + orgId + '.org', 
							EmailEncodingKey = 'ISO-8859-1', 
							Alias = uniqueName.substring(18, 23), 
							TimeZoneSidKey = 'America/Los_Angeles', 
							LocaleSidKey = 'en_US', 
							LanguageLocaleKey = 'en_US', 
							ProfileId = pf2.Id,
							License_Cost_Center__c = 'XSMW01JO01'
							);
			insert new List<User>{uu, uu2};

			List<Group> groupLst = new List<Group>();
			Group testQueue = new Group(Name = 'Fresh_Test_Queue', Type = 'Queue');
			Group testPublicGroup = new Group(Name = 'Fresh_Test_PublicGroup', Type = 'Regular');
			groupLst.add(testQueue);
			groupLst.add(testPublicGroup);
			insert groupLst;

			List<GroupMember> groupMembership = new List<GroupMember>();
			groupMembership.add(new GroupMember(UserOrGroupId = uu2.Id, GroupId = testPublicGroup.Id));			
			groupMembership.add(new GroupMember(UserOrGroupId = uu2.Id, GroupId = testQueue.Id));
			groupMembership.add(new GroupMember(UserOrGroupId = testPublicGroup.Id, GroupId = testQueue.Id));
			groupMembership.add(new GroupMember(UserOrGroupId = testPublicGroup.Id, GroupId = testQueue.Id));
			insert groupMembership;

			Account_Contact_Role__c acr = CW_TestDataFactory.testAccountContactRole(accRole.Id, acc.Id, con1.Id);
			insert acr;

			ISSP_CS__c icgUralBase = new ISSP_CS__c(Name = 'ICG_URL_Base', Value__c = 'https://theurl.com/s/');
			ISSP_CS__c hotIEC = new ISSP_CS__c(Name = 'HostIEC', Value__c = 'customer-portal-iata.force.com');
			insert new List<ISSP_CS__c>{icgUralBase, hotIEC};

			IEC_Settings__c iecSettings = new IEC_Settings__c(Name = 'Test', Account_Owner_Id__c = '', CAC_Web_Service_API_Gateway__c = '0000000',
															CAC_Web_Service_Usage_Url__c = 'https://test.saelsforce.com', Cart_cookie_session_timeout__c = -1,
															Contact_Owner_Id__c = '', Customer_Permission_Set_Id__c = '00000000',
															EBC_ExactTarget_Password__c = '', EBC_ExactTarget_Username__c = '',
															EBC_Send_From_Email__c = '', eBroadcast_Counter_AWS_API_KEY__c = '',
															eBroadcast_Counter_AWS_URL__c = '', eBroadcast_Counter_Switch__c = false,
															Encryption_Algorythm__c = 'AES128', Encryption_Key__c = 'Kg0m2vAj4VmBBviGAUehrw',
															Error_Log_Keep_Duration__c = 2, IEC_Contact_Us_Email__c = 'settingstext@test.com',
															IEC_Contact_Us_Subject__c = '', IEC_User_Portal_URL__c = 'https://iec-customer-portal-iata.cs17.force.com/iec',
															IEC_Web_Service_Endpoint__c = 'https://test.salesforce.com/services/Soap/u/30.0', 
															IEC_Web_Service_Password__c = 'blahblahgOTfA5SIlgvzVsjEKmfPoEPSW',
															IEC_Web_Service_Username__c = 'systemintegrations@iata.org.ecom', 
															InvoiceTemplate_Bank_Transfer_Zuora_ID__c = '',
															InvoiceTemplate_Check_Zuora_ID__c = '00000000', InvoiceTemplate_Credit_Card_Zuora_ID__c = '00000000',
															InvoiceTemplate_Other_Zuora_ID__c = '', PaymentMethod_Bank_Transfer_Zuora_ID__c = '00000000',
															PaymentMethod_Check_Zuora_ID__c = '', PaymentMethod_ICH_Zuora_ID__c = '4028e6992e836e4a012e914e1dd85e22',
															PaymentMethod_Other_Zuora_ID__c = '00000000', Prod_CACPro__c = '',
															Prod_CACWeb__c = '', Prod_EBro__c = '', Prod_GAD__c = '', Prod_GSS__c = '',
															Prod_MDP__c = '', Quote_Template_ID_New_Subscription__c = '00000000',
															Quote_Template_Zuora_ID_New_Subscription__c = '000000', SchdlCACWSUsageUpdate_Class_ID__c = '0000000',
															SchdlIECCompileUsage_Class_ID__c = '000000', Server_API_URL__c = 'https://iata--ecom.cs18.my.salesforce.com/services/Soap/u/10.0/00D110000005PWM',
															SF_Partner_Web_Service_endpoint__c = '', Zuora_Generate_Quote_PDF_URL__c = '');
			insert iecSettings;

			Account_Role_Relationship__c arr = new Account_Role_Relationship__c(From__c = accRole.Id, To__c = accRole2.Id, Ops_Hierarchy_Group__c = 'Test');
			Account_Role_Relationship__c arr2 = new Account_Role_Relationship__c(From__c = accRole2.Id, Relationship_Name__c = 'TestNameRelationship', To__c = accRole2.Id, Ops_Hierarchy_Group__c = 'Test');
			insert new List<Account_Role_Relationship__c>{arr, arr2};
		}
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

		System.assert(!result.contains('Thank you for your request'), 'Not succesfull Submition request');
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

	
	@isTest
	static void getOpsHierarchyGroupFromAccountId() {
		List<Account> acct = [SELECT Id FROM Account WHERE Name = 'Account01'];

		test.startTest();
		String result = CW_Utilities.getOpsHierarchyGroupFromAccountId(acct[0].Id);
		String resultName = CW_Utilities.getOpsHierarchyGroupNameFromAccountId(acct[0].Id);
		test.stopTest();
		System.assertEquals(result, 'Test');
		System.assertEquals(resultName, 'Test');

	}
	/**@description Validates the "submitted == true " section of the BecomeCompanyAdmin Method
	 */
	@isTest
	static void testBecomeCompanyAdminOK() {
		List<Account_Role_Relationship__c> lstARR = [SELECT Id, Relationship_Name__c FROM Account_Role_Relationship__c];
		List<Account> acct = [SELECT Id, Name FROM Account WHERE Name = 'Account01'];
		List<Contact> cont = [SELECT Id FROM Contact WHERE FirstName = 'Test'];

		List<User> urs = [SELECT id, accountid, contactid FROM user WHERE firstname = 'IATAICGACB' AND lastname = 'IATAICGXYZ'];
		List<ICG_Account_Role_Detail__c> ard = [SELECT id FROM ICG_Account_Role_Detail__c];
		List<Account_Contact_Role__c> acr = [SELECT Id FROM Account_Contact_Role__c];
		List<Account_Role__c> arc = [SELECT Id FROM Account_Role__c LIMIT 1];
		
		ICG_Contact_Role_Detail__c crd = CW_TestDataFactory.testICGContactRoleDetail(acr[0].id, ard[0].id);
		crd.ICG_Role__c = 'Company Admin';
		crd.Status__c = 'Approved';
		crd.Account_Role__c = arc[0].Id;
		insert crd;

		test.startTest();
		
		CW_Utilities.becomeCompanyAdmin('Account02', acct[0].Id, cont[0].Id);
		CW_Utilities.becomeCompanyAdmin('test1', acct[0].Id, cont[0].Id);

		String result = CW_Utilities.becomeCompanyAdmin(lstARR[1].Relationship_Name__c, acct[0].Id, cont[0].Id);

		System.assert(result.contains('Thank you for your request'), 'Not succesfull Submition request');


		test.stopTest();
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
			if (pv.api.Contains('Cargo')) {
				pickListApiFound = true;
			}
		}

		System.assertEquals(true, pickListApiFound, 'Cargo_Handling was not found');
	}

	@isTest
	static void testApproveRejectStationAutomaticProcess() {
		User usr;
		for (User currentItem : [SELECT Id, AccountId, ContactId FROM User WHERE Firstname = 'IATAICGACB' AND Lastname = 'IATAICGXYZ']) {
			usr = currentItem;
		}
		
		Map<String, ICG_Account_Role_Detail__c> mapStationByName = new Map<String, ICG_Account_Role_Detail__c>();
		for (ICG_Account_Role_Detail__c currentItem : [SELECT id, Name, Status__c, Account_Role__c FROM ICG_Account_Role_Detail__c ORDER BY Name]) {
			mapStationByName.put(currentItem.Name, currentItem);
		}

		Account_Contact_Role__c accContactRole;
		for (Account_Contact_Role__c currentItem : [SELECT Id FROM Account_Contact_Role__c WHERE Contact__c = :usr.ContactId]) {
			accContactRole = currentItem;
		}

		ICG_Account_Role_Detail__c stationOne = mapStationByName.get('Test 1');
		ICG_Account_Role_Detail__c stationImCompanyAdmin = mapStationByName.get('Test 3');

		ICG_Contact_Role_Detail__c crd = CW_TestDataFactory.testICGContactRoleDetail(accContactRole.id, stationImCompanyAdmin.id);
		crd.ICG_Role__c = CW_Utilities.COMPANY_ADMIN;
		crd.Account_Role__c = stationImCompanyAdmin.Account_Role__c;
		insert crd;

		System.runAs(usr) {
			test.startTest();
			System.assertEquals(false, CW_Utilities.approveStationAutomaticProcess(stationOne.Id), 'The process run correctly');
			System.assertEquals(false, CW_Utilities.rejectStationAutomaticProcess(stationOne.Id, 'the reason'), 'The process run correctly');
			System.assertEquals(false, CW_Utilities.approveStationAutomaticProcess('notId'), 'The process run correctly');
			System.assertEquals(false, CW_Utilities.rejectStationAutomaticProcess('notId', 'the reason'), 'The process run correctly');
			System.assertEquals(true, CW_Utilities.rejectStationAutomaticProcess(stationImCompanyAdmin.Id, 'the reason'), 'The process run correctly');
			test.stopTest();
		}
	}

	@isTest
	static void testGetOpsHierarchy() {
		//List<Account_Role_Relationship__c> lstARR = [SELECT Id FROM Account_Role_Relationship__c];

		List<User> urs = [SELECT id, accountid, contactid FROM user WHERE firstname = 'IATAICGACB' AND lastname = 'IATAICGXYZ'];
		List<ICG_Account_Role_Detail__c> ard = [SELECT id FROM ICG_Account_Role_Detail__c];
		test.startTest();
		String hFromUser = CW_Utilities.getOpsHierarchyNameFromUserId(urs[0].Id);
		String hFromStation = CW_Utilities.getOpsHierarchyNameFromStationId(ard[0].Id);
		test.stopTest();
		System.assertEquals('Test', hFromUser, 'Hierarchy Fails 1');
		System.assertEquals('Test', hFromStation, 'Hierarchy Fails 2');
	}

	@isTest
	static void testGetCompanyAdminContacts() {
		List<Account_Role_Relationship__c> lstARR = [SELECT Id, Relationship_Name__c FROM Account_Role_Relationship__c];
		List<Account_Role__c> listAR = [SELECT Id, Account_Role_Name__c FROM Account_Role__c WHERE Account_Role_Name__c = 'Test'];
		List<Contact> auxContact = new List<Contact>();
		String aux = '';
		test.startTest();
		auxContact = CW_Utilities.getCompanyAdminContactsFromGroupName(new List<String>{lstARR[0].Relationship_Name__c});
		aux = CW_Utilities.getOpsHierarchyNameFromAccountId(listAR[0].Account_Role_Name__c);
		test.stopTest();
		System.assertEquals(0, auxContact.size(), 'Contact list size > 0');
		System.assertEquals(null, aux, 'Hierarchy Fails');
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
			String resultApprovedJSON = CW_Utilities.handleContactRoleDetailRemovalProcess(crd.Id, true);
			CW_Utilities.HandledContactRole resultApproved = (CW_Utilities.HandledContactRole) JSON.deserialize(resultApprovedJSON, CW_Utilities.HandledContactRole.class);
			System.assertEquals('MissingRights', resultApproved.message, 'User were allowed to edit even without being a company admin');
			String resultRejectedJSON = CW_Utilities.handleContactRoleDetailRemovalProcess(crd.Id, false);
			CW_Utilities.HandledContactRole resultRejected = (CW_Utilities.HandledContactRole) JSON.deserialize(resultRejectedJSON, CW_Utilities.HandledContactRole.class);
			System.assertEquals('MissingRights', resultRejected.message, 'User were allowed to edit even without being a company admin');
			test.stopTest();
		}

	}

	@IsTest
	public static void handleContactRoleDetailRemovalProcessStationManagerWrong() {
		List<User> urs = [SELECT id, accountid, contactid FROM user WHERE firstname = 'IATAICGACB' AND lastname = 'IATAICGXYZ'];
		
		System.runAs(urs[0]) {
			test.startTest();
				String resultApprovedJSON = CW_Utilities.handleContactRoleDetailRemovalProcess('', true);						
			test.stopTest();
			CW_Utilities.HandledContactRole resultApproved = (CW_Utilities.HandledContactRole) JSON.deserialize(resultApprovedJSON, CW_Utilities.HandledContactRole.class);
			System.assertEquals('No matching contact found', resultApproved.message, 'No matching contact found');	
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
		
		test.startTest();
		ICG_Contact_Role_Detail__c res = CW_Utilities.rejectContactRoleDetailAutomaticProcess(crd.Id, 'test reject reason');
		system.assertEquals(res, null, 'rejected');

		crd.Status__c = 'Pending for Approval';
		update crd;
		res = CW_Utilities.rejectContactRoleDetailAutomaticProcess(crd.Id, 'test reject reason');
		system.assertEquals(res, null, 'rejected');

		crd.ICG_Role__c = 'Company Admin';
		update crd;
		res = CW_Utilities.rejectContactRoleDetailAutomaticProcess(crd.Id, 'test reject reason');
		system.assertEquals(res, null, 'rejected');

		test.stopTest();
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
			
			Set<Id> listResult = CW_Utilities.getRelatedAccountsByStation(crd.Id);
			System.assertNotEquals(listResult.size(), 0, 'list empty');
			
			test.stopTest();
		}
	}

	@IsTest
	public static void getFacilityManagerContactRolesFromStationListByUserTest() {
		List<User> urs = [SELECT id, accountid, contactid FROM user WHERE firstname = 'IATAICGACB' AND lastname = 'IATAICGXYZ'];
		List<ICG_Account_Role_Detail__c> ard = [SELECT id FROM ICG_Account_Role_Detail__c];
		List<Account_Contact_Role__c> acr = [SELECT Id FROM Account_Contact_Role__c];
		List<Account_Role__c> arc = [SELECT Id FROM Account_Role__c LIMIT 1];
		System.runAs(urs[0]) {

			//For some reason I cannot yet see, this object cannot be created in the SETUP method
			ICG_Contact_Role_Detail__c crd = CW_TestDataFactory.testICGContactRoleDetail(acr[0].id, ard[0].id);
			crd.ICG_Role__c = 'Facility Manager';
			crd.Account_Role__c = arc[0].Id;
			insert crd;
			
			test.startTest();
			List<ICG_Contact_Role_Detail__c> res = CW_Utilities.getFacilityManagerContactRolesFromStationListByUser(urs[0].Id);
			system.assertNotEquals(res.size(), 0, 'list empty');
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
		insert crd;
		
		ICG_Contact_Role_Detail__c crd1 = CW_TestDataFactory.testICGContactRoleDetail(acr[0].id, ard[0].id);
		crd1.ICG_Role__c = 'Facility Manager';
		crd1.Status__c = 'Rejected';
		crd1.Account_Role__c = arc[0].Id;
		insert crd1;
		
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
		   
			List<ICG_Notification__c> notifications = [SELECT Id FROM ICG_Notification__c];
			
			system.assertNotEquals(notifications.size(), 0, 'list empty');
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
		crd.Account_Role__c = arc[0].Id;
		insert crd;
		System.runAs(urs[0]) {
			test.startTest();
			ICG_Contact_Role_Detail__c res = CW_Utilities.approveContactRoleDetailAutomaticProcess(crd.Id);
			system.assertEquals(res, null, 'approved');

			crd.Status__c = 'Pending for Approval';
			res = CW_Utilities.approveContactRoleDetailAutomaticProcess(crd.Id);
			system.assertEquals(res, null, 'approved Pending for Approval');

			test.stopTest();
		}
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
		insert crd;

		ICG_Contact_Role_Detail__c crd1 = CW_TestDataFactory.testICGContactRoleDetail(acr[0].id, ard[0].id);
		crd1.ICG_Role__c = 'Facility Manager';
		crd1.Status__c = 'Rejected';
		crd1.Account_Role__c = arc[0].Id;
		insert crd1;

		test.startTest();

		CW_Utilities.updateAllStationManagementRecords(ard[0].CreatedBy.ContactId, ard[0].Id, 'Rejected');
		List<ICG_Contact_Role_Detail__c> crds = [Select id from ICG_Contact_Role_Detail__c where ICG_Account_Role_Detail__c =:ard[0].Id AND Status__c =: 'Rejected'];
		system.assertNotEquals(crds.size(), 0, 'list empty');

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
		crd.ICG_Role__c = 'Company Admin';
		crd.Status__c = 'Pending for Approval';
		crd.Account_Role__c = arc[0].Id;
		insert crd;
		System.runAs(urs[0]) {
			test.startTest();
			String groupName = CW_Utilities.getOpsHierarchyNameFromStationId(crd.Id);
			List<ICG_Contact_Role_Detail__c> listResult = CW_Utilities.getPendingCompanyAdminContactRolesFromGroupName(groupName);
			System.assertNotEquals(listResult.size(), 0, 'list empty');
			test.stopTest();
		}
	}

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
			
			CW_Utilities.approveContactRoleDetailAutomaticProcess(crd.Id);
			
			String userRoleAdmin = CW_Utilities.getUserRole(ard[0].id);
			System.assertEquals('Company Admin', userRoleAdmin, 'not a company admin' + userRoleAdmin);

			CW_Utilities.approveStationAutomaticProcess(ard[0].Id);
			String crdRemovalProcessJSON = CW_Utilities.handleContactRoleDetailRemovalProcess(crd.Id, true);
			CW_Utilities.HandledContactRole crdRemovalProcess = (CW_Utilities.HandledContactRole) JSON.deserialize(crdRemovalProcessJSON, CW_Utilities.HandledContactRole.class);
			
			System.assertEquals('Successful', crdRemovalProcess.message, 'removal error');
			
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
			CW_Utilities.sendApproveOrRejectMails(ard[1], ard[0]);
		} catch (Exception ex) {
		}

		try {
			CW_Utilities.rejectStationAutomaticProcess(ard[0].Id, 'the reason');
		} catch (Exception ex) {
			Boolean res = ex.getMessage().contains('Aura handled exception');
			system.assertEquals(res, true, 'reject dennied');
		}

		test.stopTest();
	}
	
	@isTest
	static void testGetPermissionToEdit() {
		List<User> urs = [SELECT id, accountid, contactid FROM user WHERE firstname = 'IATAICGACB' AND lastname = 'IATAICGXYZ'];

		System.runAs(urs[0]) {
			test.startTest();

			Boolean result = CW_Utilities.getPermissionToEdit();
			system.assertEquals(result, false, 'has permisson');

			test.stopTest();
		}
	}
	
	
	@isTest
	static void testGetContactRoleDetailsToInsert() {
		List<Account> acct = [SELECT Id FROM Account WHERE Name = 'Account02'];
		List<ICG_Account_Role_Detail__c> accRoleDetail = [SELECT Id FROM ICG_Account_Role_Detail__c WHERE Nearest_Airport__r.Code__c = 'MAD' AND IATA_ISO_Country__r.Name = 'Spain' AND City_FOR__c = 'Madrid'];
		List<Contact> cont = [SELECT Id FROM Contact WHERE FirstName = 'Test'];

		test.startTest();
		
		List<ICG_Contact_Role_Detail__c> result = CW_Utilities.getContactRoleDetailsToInsert(acct[0].Id, accRoleDetail[0].Id, cont[0].Id, 'Pending for Approval');
	   
		system.assertNotEquals(result.size(), 0, 'empty list');
		
		test.stopTest();
	}

	/*********************************************************************************************************
	 * @name			getArdTypesBySectorAndCategoryTest
	 * @author			Bea <beatriz.menendez@next-link.ch>
	 * @created			07 / 10 / 2020
	 * @description		Description of your code
	 * @param			-
	 * @return			-
	**********************************************************************************************************/
	@isTest
	static void getArdTypesBySectorAndCategoryTest(){
		Test.startTest();
			String ardTypes = CW_Utilities.getArdTypesBySectorAndCategory();
		Test.stopTest();

		System.assert(String.isNotEmpty(ardTypes), 'ERROR: getArdTypesBySectorAndCategory should not be null');
	}

	/*********************************************************************************************************
	 * @name			getAllGroupsMembersTest
	 * @author			Beatriz <beatriz.menendez@next-link.ch>
	 * @created			10 / 12 / 2020
	 * @description		Test generic method that pbtains a map with all group members.
	 * @param			-
	 * @return			-
	**********************************************************************************************************/
	@isTest
	static void getAllGroupsMembersTest(){
		User testUser = [SELECT Id FROM User WHERE firstname = 'IATATESTQUEUE' AND lastName = 'IATAQUEUETEST' LIMIT 1];
		System.runAs(testUser){
			Group testQueue = [SELECT Id FROM Group WHERE Name = 'Fresh_Test_Queue' AND Type = 'Queue'];

			Test.startTest();
				Set<Id> queuesSet = new Set<Id>();
				queuesSet.add(testQueue.Id);
				Map<Id, Set<Id>> queueUsersMap = CW_Utilities.getUserIdsFromGroup(queuesSet);
			Test.stopTest();

			System.assertEquals(1, queueUsersMap.get(testQueue.Id).size(), 'ERROR: just one user added to the queue list');
		}
	}

	/*********************************************************************************************************
	 * @name			getEcommerceUrlBaseTest
	 * @author			Beatriz <beatriz.menendez@next-link.ch>
	 * @created			10 / 12 / 2020
	 * @description		Description of your code
	 * @param			String param : Explanation
	 * @return			Explanation of the return value
	**********************************************************************************************************/
	@isTest
	static void getEcommerceUrlBaseTest(){
		Test.startTest();
			String url = CW_Utilities.getEcommerceUrlBase();
		Test.stopTest();

		System.assert(String.isNotEmpty(url), 'ERROR: getEcommerceUrlBase should not be null');
	}

	/*********************************************************************************************************
	 * @name			getIECSettingVariablesTest
	 * @author			Beatriz <beatriz.menendez@next-link.ch>
	 * @created			10 / 12 / 2020
	 * @description		Description of your code
	 * @param			String param : Explanation
	 * @return			Explanation of the return value
	**********************************************************************************************************/
	@isTest
	static void getIECSettingVariablesTest(){
		Test.startTest();
			IEC_Settings__c settings = CW_Utilities.getIECSettingVariables();
		Test.stopTest();

		System.assert(settings != null, 'ERROR: getEcommerceUrlBase should not be null');
	}

	/*********************************************************************************************************
	 * @name			getFacilityManagerApprovedOrRemovedByUserTest
	 * @author			Beatriz <beatriz.menendez@next-link.ch>
	 * @created			10 / 12 / 2020
	 * @description		Description of your code
	 * @param			String param : Explanation
	 * @return			Explanation of the return value
	**********************************************************************************************************/
	@isTest
	static void getFacilityManagerApprovedOrRemovedByUserTest(){
		User testUser = [SELECT Id FROM User WHERE firstname = 'IATATESTQUEUE' AND lastName = 'IATAQUEUETEST' LIMIT 1];
		Test.startTest();
			List<ICG_Contact_Role_Detail__c> settings = CW_Utilities.getFacilityManagerApprovedOrRemovedByUser(testUser.Id);
		Test.stopTest();

		System.assert(settings != null, 'ERROR: getEcommerceUrlBase should Not be null');
	}

	/*********************************************************************************************************
	 * @name			becomeCompanyAdminFromStationTest
	 * @author			Beatriz <beatriz.menendez@next-link.ch>
	 * @created			10 / 12 / 2020
	 * @description		Description of your code
	 * @param			String param : Explanation
	 * @return			Explanation of the return value
	**********************************************************************************************************/
	@isTest
	static void becomeCompanyAdminFromStationTest(){
		List<ICG_Account_Role_Detail__c> ard = [SELECT id FROM ICG_Account_Role_Detail__c];
		ICG_Account_Role_Detail__c station = [SELECT id FROM ICG_Account_Role_Detail__c].get(0);
		Account company = [SELECT Id, Name FROM Account WHERE Name = 'Account01'].get(0);
		Contact contact = [SELECT Id FROM Contact WHERE FirstName = 'Test'].get(0);
		Test.startTest();
			String settings = CW_Utilities.becomeCompanyAdminFromStation(String.ValueOf(station.Id), String.valueOf(company.Id), String.ValueOf(contact.Id));
		Test.stopTest();

		System.assert(String.isNotEmpty(settings), 'ERROR: getEcommerceUrlBase should be null');
	}

	/*********************************************************************************************************
	 * @name			getFacilityHistoryByUserTest
	 * @author			Beatriz <beatriz.menendez@next-link.ch>
	 * @created			18 / 12 / 2020
	 * @description		Test method for getFacilityHistoryByUser CW_Utilities method
	 * @param			-
	 * @return			-
	**********************************************************************************************************/
	@isTest
	static void getFacilityHistoryByUserTest(){
		User testUser 		= [SELECT id FROM User WHERE firstname = 'IATATESTQUEUE' AND lastName = 'IATAQUEUETEST' LIMIT 1];
		System.runAs(testUser){
			Test.startTest();
			Account acc 				= [SELECT Id FROM Account WHERE Name = 'Account01' LIMIT 1];
			Airport_Detail__c airport 	= [SELECT Id, IATA_ISO_Country__c FROM Airport_Detail__c LIMIT 1];
			Account_Role__c accRole 	= CW_TestDataFactory.testAccountRole(acc.Id, 'Test');
			insert accRole;

			ICG_Account_Role_Detail__c station = CW_TestDataFactory.testICGAccountRoleDetail(accRole.Id, airport);
			station.Status__c = 'Pending for Approval';
			insert station;
			
			station.Status__c = 'Approved';
			update station;

			List<CW_Utilities.HistoryDTO> historyLst = CW_Utilities.getFacilityHistoryByUser(String.ValueOf(testUser.Id));
			Test.stopTest();

			System.assert(!historyLst.isEmpty(), 'ERROR: historyLst should not be null');
		}
	}

	@isTest
	static void getAllServicesAvailableTest(){
		List<CW_Utilities.PicklistVal> historyLst = CW_Utilities.getAllServicesAvailable();
		System.assertEquals(false, historyLst.isEmpty(), 'ERROR: List of services available for ramp handler are empty');
	}
	
	/*********************************************************************************************************
	 * @name			getFacilityHistoryByUserTest
	 * @author			Daniel Mendoza <daniel.mendoza@nextlinksolutions.ch>
	 * @created			24 / 02 / 2021
	 * @description		Test method for getOpsHierarchyNameFromContactId method
	 * @param			-
	 * @return			-
	**********************************************************************************************************/
	@isTest
	static void getOpsHierarchyNameFromContactIdTest(){
		User usr;
		for (User currentItem : [SELECT Id, AccountId, ContactId FROM User WHERE Firstname = 'IATAICGACB' AND Lastname = 'IATAICGXYZ']) {
			usr = currentItem;
		}
		
		Map<String, ICG_Account_Role_Detail__c> mapStationByName = new Map<String, ICG_Account_Role_Detail__c>();
		for (ICG_Account_Role_Detail__c currentItem : [SELECT id, Name, Status__c, Account_Role__c FROM ICG_Account_Role_Detail__c ORDER BY Name]) {
			mapStationByName.put(currentItem.Name, currentItem);
		}

		Account_Contact_Role__c accContactRole;
		for (Account_Contact_Role__c currentItem : [SELECT Id FROM Account_Contact_Role__c WHERE Contact__c = :usr.ContactId]) {
			accContactRole = currentItem;
		}

		ICG_Account_Role_Detail__c stationImCompanyAdmin = mapStationByName.get('Test 3');

		ICG_Contact_Role_Detail__c crd = CW_TestDataFactory.testICGContactRoleDetail(accContactRole.id, stationImCompanyAdmin.id);
		crd.ICG_Role__c = CW_Utilities.COMPANY_ADMIN;
		crd.Account_Role__c = stationImCompanyAdmin.Account_Role__c;
		insert crd;
		
		List<CW_Utilities.HistoryDTO> history = CW_Utilities.getFacilityHistoryByUser(usr.Id);

		List<Contact> contacts = CW_Utilities.getCompanyAdminContactsFromContactId(usr.ContactId);
		System.runAs(usr) {
			test.startTest();
			System.assert(!contacts.isEmpty(), 'ERROR: contacts should not be empty');
			System.assertEquals('Test', contacts[0].FirstName, 'ERROR: contact FirstName  should be Test');
			System.assert(!history.isEmpty(), 'ERROR: history should not be empty');
			test.stopTest();
		}
	}


	/*********************************************************************************************************
	 * @name			getAccountContactRoleTest
	 * @author			Daniel Mendoza <daniel.mendoza@nextlinksolutions.ch>
	 * @created			24 / 02 / 2021
	 * @description		Test method for getAccountContactRole method
	 * @param			-
	 * @return			-
	**********************************************************************************************************/
	@isTest
	static void getAccountContactRoleTest(){
		Account_Role__c accRole = [SELECT Id, Account__c FROM Account_Role__c WHERE Account_Role_Name__c = 'Test' LIMIT 1];
		accRole.Functional_Role__c = '';
		update accRole;
		ICG_Account_Role_Detail__c station = [SELECT id FROM ICG_Account_Role_Detail__c WHERE Name = 'Test 1' LIMIT 1];
		User usr = [SELECT Id, AccountId, ContactId FROM User WHERE Firstname = 'IATAICGACB' AND Lastname = 'IATAICGXYZ' LIMIT 1];
		
		test.startTest();
		List<ICG_Contact_Role_Detail__c> crds = CW_Utilities.getContactRoleDetailsToInsert(accRole.Account__c, station.Id, usr.ContactId, 'Approved');
		test.stopTest();
		System.assert(!crds.isEmpty(), 'ERROR: crds should not be empty');
	}


	/*********************************************************************************************************
	 * @name			getAllHandlingServicesAvailableJsonTest
	 * @description		Test method for getAllServicesAvailableJson method
	 * @param			-
	 * @return			-
	**********************************************************************************************************/
	@isTest
	static void getAllHandlingServicesAvailableJsonTest(){
		String services = CW_Utilities.getAllServicesAvailableJson();
		System.assert(string.isNotBlank(services), 'ERROR: services not be empty');
	}

	@isTest
	public static void isCurrentUserSystemAdministratorTest() {
		Test.startTest();
		
		Boolean result = CW_Utilities.isCurrentUserSystemAdministrator();
		system.assertEquals(true, result);
		
		Test.stopTest();
	}

	@isTest
	public static void getCurrentUserPermissionSetsTest() {
		Test.startTest();
		
		List<String> result = CW_Utilities.getCurrentUserPermissionSets();
		system.assertNotEquals(null, result);
		
		Test.stopTest();
	}

	@isTest
	public static void hasSpecialPermissionsToEditTest() {
		Test.startTest();
		
		Boolean result = CW_Utilities.hasSpecialPermissionsToEdit();
		system.assertEquals(true, result);
		
		Test.stopTest();
	}
}