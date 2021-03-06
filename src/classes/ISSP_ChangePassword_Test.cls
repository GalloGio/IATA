@isTest
private class ISSP_ChangePassword_Test {

	@testSetup static void setup() {

		IATA_ISO_Country__c ISO_Country = new IATA_ISO_Country__c(ISO_Code__c='TT',Name='test');
		insert ISO_Country;

		Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
		Account acc = ISSP_ObjectFactory.createNewAccount();
		acc.IATACode__c = '100';
		acc.IATA_ISO_Country__c = ISO_Country.Id;
		acc.RecordTypeId = recordTypeId;
		acc.Airline_designator__c = 'TT';
		insert acc;

		Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
		Contact con = ISSP_ObjectFactory.createNewContact();
		con.AccountId = acc.Id;
		con.LastName = 'test';
		con.Email = 'test.issp.registration@testisspregistration.com';
		con.RecordTypeId = rtId;
		insert con;

		User newUser = new User(alias = 'dsfsdfds',
								email = con.email,
								emailencodingkey = 'UTF-8',
								firstname = con.firstName,
								lastname = con.lastname,
								languagelocalekey = 'en_US',
								localesidkey = 'en_US',
								contactId = con.Id,
								timezonesidkey = 'Asia/Dubai',
								Username = 'test.issp.registration.testisspregistration.com@partner.iata.org',
								PortalRole = 'Manager',
								CommunityNickname = con.email.substring(0, con.email.indexOf('@'))+Datetime.now().formatLong().substring(10,15),
								ProfileId = ISSP_Constant.TEST_User_ProfileID,
								IsActive = true);
		insert newUser;

		ISSP_CS__c issp_cs = new ISSP_CS__c(Name = 'PasswordResetPeriod', Value__c = '90');
		ISSP_CS__c issp_cs2 = new ISSP_CS__c(Name = 'Fred_System', Value__c = 'test');
		insert new List<ISSP_CS__c>{issp_cs, issp_cs2};

	}

	@isTest	
	static void myUnitTest_2() {
		ISSP_CS__c issc = new ISSP_CS__c(name = 'PasswordResetPeriod', value__c = '90');
		insert issc;
		Test.startTest();
		PageReference pgRef = Page.ISSP_ChangePassword;
		Test.setCurrentPage(pgRef);
		
		ISSP_ChangePassword pgCont = new ISSP_ChangePassword();
		pgCont.currentPassword = '';
		pgCont.newPassword = '';
		pgCont.confirmNewPassword = '';
		pgCont.changePassword();

		User usr = IECTestUtil.createSampleGuestUserAndLogin();
		System.runAs(usr) {
			
			
			// Test 001: Leave all fields blank
			pgCont.currentPassword = '';
			pgCont.newPassword = '';
			pgCont.confirmNewPassword = '';
			pgCont.changePassword();
			
			// Test 002: Different passwords
			pgCont.currentPassword = 'a';
			pgCont.newPassword = 'b';
			pgCont.confirmNewPassword = 'c';
			pgCont.changePassword();
			
			// Test 003: Correct
			pgCont.currentPassword = 'a';
			pgCont.newPassword = 'b1234567';
			pgCont.confirmNewPassword = 'b1234567';
			pgCont.changePassword();
		}
		Test.stopTest();
	}
	
	@isTest
	static void myUnitTest_3() {
		ISSP_CS__c issc = new ISSP_CS__c(name = 'PasswordResetPeriod', value__c = '90');
		insert issc;
		Test.startTest();
		PageReference pgRef = Page.ISSP_ChangePassword;
		Test.setCurrentPage(pgRef);
		
		List<Network> networks = [SELECT Id
									FROM Network
									WHERE (Name = 'IATA Portal' OR Name = 'CS Portal')];

		if(!networks.isEmpty()){
			ApexPages.currentPage().getParameters().put('retUrl','networkId='+networks[0].Id);
		}
		
		// insert account
		Account newAccount = new Account();
		newAccount.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
		newAccount.Name = 'Company';
		insert newAccount;
 
		// create Bill To contact info
		Contact newContact = new Contact();
		newContact.RecordTypeId = IECUserManager.getContactRecordTypeForIEC();
		newContact.AccountId = newAccount.Id;
		newContact.FirstName = 'Test';
		newContact.LastName = 'User';
		newContact.Title = 'TestTitle';
		newContact.Email = 'testIECGuest@test.iata.org';
		newContact.Phone = '514123345';
		newContact.User_IECPortal_Status__c = IECConstants.APPROVED_CONTACT_STATUS;
		insert newContact;

		User u = new User(
			Username = ISSP_Utilities.buildPortalUserName('testIECGuest@test.iata.org')
			, Email = 'testIECGuest@test.iata.org'
			, emailencodingkey = 'UTF-8'
			, Alias = IECUserManager.createAliasFromName(newContact.LastName)
			, FirstName = newContact.FirstName
			, LastName = newContact.LastName
			, LocaleSidKey = 'en_US'
			, CommunityNickname = 'testIECGuest@iata.org'
			, ProfileId = IECUserManager.getProfileIdForIECUser()
			, LanguageLocaleKey = 'en_US'
			, timezonesidkey = 'America/New_York'
			, ContactId = newContact.Id
			, IsActive = true
			, ReceivesAdminInfoEmails = false
			, ReceivesInfoEmails = false
			, UID__c = '1234'
		);
		insert u;

		String userId = Site.createPortalUser(u, newAccount.Id, 'testpassword');
		IECUserManager.login(u.Username, 'testpassword', null);
		
		System.runAs(u) {
			ISSP_ChangePassword pgCont = new ISSP_ChangePassword();
			// Test 001: Leave all fields blank
			pgCont.currentPassword = '';
			pgCont.newPassword = '';
			pgCont.confirmNewPassword = '';
			pgCont.changePassword();
			
			// Test 002: Different passwords
			pgCont.currentPassword = 'a';
			pgCont.newPassword = 'b';
			pgCont.confirmNewPassword = 'c';
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Test'));
			pgCont.changePassword();
			
			// Test 003: Correct
			pgCont.currentPassword = 'a';
			pgCont.newPassword = 'b1234567';
			pgCont.confirmNewPassword = 'b1234567';
			pgCont.serviceName = 'serviceName';
			pgCont.serviceNameParam = 'serviceNameParam';
			pgCont.changePassword();

		}
		Test.stopTest();
	}

	@isTest
	static void myUnitTest_4() {
		ISSP_CS__c issc = new ISSP_CS__c(name = 'PasswordResetPeriod', value__c = '90');
		insert issc;
		Test.startTest();
		PageReference pgRef = Page.ISSP_ChangePassword;
		Test.setCurrentPage(pgRef);

		List<Network> networks = [SELECT Id
									FROM Network
									WHERE (Name = 'IATA Portal' OR Name = 'CS Portal')];

		if(!networks.isEmpty()){
			ApexPages.currentPage().getParameters().put('retUrl','networkId='+networks[0].Id);
		}

		// insert account
		Account newAccount = new Account();
		newAccount.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Others');
		newAccount.Name = 'Company';
		newAccount.Sector__c = 'Airline Supplier';
		newAccount.Category__c = 'Fuel Supplier';
		insert newAccount;

		//Create Portal Application
		Portal_Applications__c portalApp = TestDataFactory_PortalApplications.createDefaultPortalApplication(1).get(0);
		portalApp.Name = 'IFTP';

		//Create Accounts Roles
		List<Account_Roles__c> accRolesList = new List<Account_Roles__c>();
		Account_Roles__c accRolesITP = new Account_Roles__c(Name = 'ITP');
		Account_Roles__c accRolesAirline = new Account_Roles__c(Name = 'Airline');
		accRolesList.add(accRolesITP);
		accRolesList.add(accRolesAirline);
		insert accRolesList;

		//Create Accounts Services'
		List<Account_Role_Services__c> accRoleServicesList = new List<Account_Role_Services__c>();
		Account_Role_Services__c accRoleServicesITP = new Account_Role_Services__c(Name = 'IFTP-ITP', Account_Roles__c = accRolesITP.Id, Portal_Service__c = portalApp.Id);
		Account_Role_Services__c accRoleServicesAirline = new Account_Role_Services__c(Name = 'IFTP - Airline', Account_Roles__c = accRolesAirline.Id, Portal_Service__c = portalApp.Id);
		accRoleServicesList.add(accRoleServicesITP);
		accRoleServicesList.add(accRoleServicesAirline);
		insert accRoleServicesList;

		//Create Accounts Role
		Id accRoleITP_RT = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Role__c', 'IFTP');

		List<Account_Role__c> accRoleList = new List<Account_Role__c>();
		Account_Role__c accRoleITP = new Account_Role__c(Account__c = newAccount.Id, Account_Roles__c = accRolesITP.Id, RecordTypeId = accRoleITP_RT);
			accRoleList.add(accRoleITP);
		insert accRoleList;
		System.debug('accRoleList - ' + accRoleList);


		//Create Accounts Service
		List<Account_Role_Service__c> accRoleServiceList = new List<Account_Role_Service__c>();
		Account_Role_Service__c accRoleServiceITP = new Account_Role_Service__c(Account_Role__c = accRoleITP.Id, Account_Role_Services__c = accRoleServicesITP.Id);
		accRoleServiceList.add(accRoleServiceITP);
		insert accRoleServiceList;

		//Create Contact Roles
		List<Contact_Roles__c> contactRolesList = new List<Contact_Roles__c>();
		Contact_Roles__c contactRolesITPAdmin = new Contact_Roles__c(Name = 'ITP Administrator', Service__c = portalApp.Id);
		Contact_Roles__c contactRolesITPCoord = new Contact_Roles__c(Name = 'ITP Training Coordinator', Service__c = portalApp.Id);
		Contact_Roles__c contactRolesITPMaster = new Contact_Roles__c(Name = 'ITP Master', Service__c = portalApp.Id);
		contactRolesList.add(contactRolesITPAdmin);
		contactRolesList.add(contactRolesITPCoord);
		contactRolesList.add(contactRolesITPMaster);
		insert contactRolesList;

		// create Bill To contact info
		Contact newContact = new Contact();
		newContact.RecordTypeId = IECUserManager.getContactRecordTypeForIEC();
		newContact.AccountId = newAccount.Id;
		newContact.FirstName = 'Test';
		newContact.LastName = 'User';
		newContact.Title = 'TestTitle';
		newContact.Email = 'testIECGuest@test.iata.org';
		newContact.Phone = '514123345';
		newContact.User_IECPortal_Status__c = IECConstants.APPROVED_CONTACT_STATUS;
		insert newContact;

		User u = new User(
			Username = ISSP_Utilities.buildPortalUserName('testIECGuest@test.iata.org')
			, Email = 'testIECGuest@test.iata.org'
			, emailencodingkey = 'UTF-8'
			, Alias = IECUserManager.createAliasFromName(newContact.LastName)
			, FirstName = newContact.FirstName
			, LastName = newContact.LastName
			, LocaleSidKey = 'en_US'
			, CommunityNickname = 'testIECGuest@iata.org'
			, ProfileId = IECUserManager.getProfileIdForIECUser()
			, LanguageLocaleKey = 'en_US'
			, timezonesidkey = 'America/New_York'
			, ContactId = newContact.Id
			, IsActive = true
			, ReceivesAdminInfoEmails = false
			, ReceivesInfoEmails = false
			, UID__c = '1234'
		);
		insert u;

		String userId = Site.createPortalUser(u, newAccount.Id, 'testpassword');
		IECUserManager.login(u.Username, 'testpassword', null);

		System.runAs(u) {
			ISSP_ChangePassword pgCont = new ISSP_ChangePassword();
			// Test 001: Leave all fields blank
			pgCont.currentPassword = '';
			pgCont.newPassword = '';
			pgCont.confirmNewPassword = '';
			pgCont.changePassword();

			// Test 002: Different passwords
			pgCont.currentPassword = 'a';
			pgCont.newPassword = 'b';
			pgCont.confirmNewPassword = 'c';
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Test'));
			pgCont.changePassword();

			// Test 003: Correct
			pgCont.currentPassword = 'a';
			pgCont.newPassword = 'b1234567';
			pgCont.confirmNewPassword = 'b1234567';
			pgCont.serviceName = 'serviceName';
			pgCont.serviceNameParam = 'serviceNameParam';
			pgCont.changePassword();

		}
		Test.stopTest();
	}

	@isTest
	static void loginPage_ISSP() {

		ISSP_CS__c cs = new ISSP_CS__c();
		cs.Name = 'ipinfo_token';
		cs.Value__c = 'test';
		insert cs;

		String UID =  Comm_User_Helper.NewGuid();
		User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
		thisUser.UID__c = UID;
		update thisUser;
		
		System.runAs(thisUser) {
			PageReference pageRef = Page.ISSP_First_Login;
			Test.setCurrentPage(pageRef);

			String myUsername = Userinfo.getUsername();
			string parameters =myUsername+Comm_User_Helper.SEPARATOR+'testpassword'+Comm_User_Helper.SEPARATOR+ UID;
			ApexPages.currentPage().getParameters().put('c',Comm_User_Helper.EncryptString(parameters));

			ISSP_First_Login ctrl = new ISSP_First_Login();
			Pagereference pr = Page.ISSP_Login;
			
			system.assertEquals('/apex/issp_changepassword',ctrl.DoNext().getUrl());

		}
	}

	@isTest
	static void loginPage_ISSP_2() {

		ISSP_CS__c cs = new ISSP_CS__c();
		cs.Name = 'ipinfo_token';
		cs.Value__c = 'test';
		insert cs;

		PageReference pageRef = Page.ISSP_First_Login;
		Test.setCurrentPage(pageRef);

		String UID =  Comm_User_Helper.NewGuid();
		String myUsername = Userinfo.getUsername();
		string parameters =myUsername+Comm_User_Helper.SEPARATOR+'testpassword'+Comm_User_Helper.SEPARATOR+ UID;
		ApexPages.currentPage().getParameters().put('c',Comm_User_Helper.EncryptString(parameters));

		ISSP_First_Login ctrl = new ISSP_First_Login();
		Pagereference pr = Page.ISSP_Login;

	}

	@isTest
	static void loginPage_ISSP_3() {
		ISSP_CS__c cs = new ISSP_CS__c();
		cs.Name = 'ipinfo_token';
		cs.Value__c = 'test';
		insert cs;
		ISSP_First_Login ctrl = new ISSP_First_Login();
		ctrl.changePassword();
		ISSP_First_Login.updateUsers(UserInfo.getUserId());
	}

	@isTest
	static void fredTests() {
		ISSP_CS__c issc = new ISSP_CS__c(name = 'PasswordResetPeriod', value__c = '90');
		insert issc;
		Test.startTest();
		PageReference pgRef = Page.ISSP_ChangePassword;
		pgRef.getParameters().put('serviceName','FRED');

		Test.setCurrentPageReference(pgRef); // use setCurrentPageReference,
		
		ISSP_ChangePassword pgCont = new ISSP_ChangePassword();
		pgCont.termsAndConditionChecked = false;
		
		String serviceNameParam = pgCont.serviceNameParam;
		
		User usr = IECTestUtil.createSampleGuestUserAndLogin();
		System.runAs(usr) {

			pgCont.currentPassword = 'a';
			pgCont.newPassword = 'b1234567';
			pgCont.confirmNewPassword = 'b1234567';

			pgCont.changePassword();

			pgCont.showTCpopup();
			pgCont.closePopup();

			pgCont.termsAndConditionChecked = true;

			pgCont.changePassword();
		}
		Test.stopTest();
	}

	@isTest
	static void CheckProvisioningTestIF(){

		User newUser = [SELECT Id, Email FROM User WHERE Username = 'test.issp.registration.testisspregistration.com@partner.iata.org' LIMIT 1];

		UserProvisioningRequest userProvisining = new UserProvisioningRequest(State = 'Completed',
													Operation = 'Activate',
													ApprovalStatus = 'Required',
													SalesforceUserId = newUser.Id);
		insert userProvisining;

		Invitation__c invitations = new Invitation__c(Role__c = 'Primary', AccountId__c = 'test', Email__c = newUser.email);
		insert invitations;

		PageReference pagereference;

		System.runAs(newUser){
			Test.startTest();
			ISSP_ChangePassword pageCP = new ISSP_ChangePassword();
			pagereference = pageCP.getCheckProvisioning();
			Test.stopTest();
		}

		ISSP_CS__c issp = [SELECT Name, Value__c FROM ISSP_CS__c WHERE Name = 'Fred_System'];

		System.assertEquals(new PageReference(issp.Value__c).getUrl(), pagereference.getUrl());

	}

	@isTest
	static void ChangePasswordServiceNameTest(){
			
		Test.startTest();
		PageReference pgRef = Page.ISSP_ChangePassword;
		pgRef.getParameters().put('serviceName','testServiceName');
		pgRef.getParameters().put('OneId','testOneId');
		Test.setCurrentPageReference(pgRef); 

		ISSP_ChangePassword pageCP = new ISSP_ChangePassword();
		PageReference result = pageCP.changePassword();
		Test.stopTest();

		System.assertEquals(new PageReference(OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.IDENTITY,'/s/?&serviceName=testServiceName')).getUrl(), result.getUrl());
		
	}

	@isTest
	static void checkProvisioningTestElse(){	

		User newUser = [SELECT Id FROM User WHERE Username = 'test.issp.registration.testisspregistration.com@partner.iata.org' LIMIT 1];

		UserProvisioningRequest userProvisining = new UserProvisioningRequest(State = 'Completed',
												Operation = 'Activate', 
												ApprovalStatus = 'Required',
												SalesforceUserId = newUser.Id);

		insert userProvisining;

		System.runAs(newUser){
			Test.startTest();
			ISSP_ChangePassword pageCP = new ISSP_ChangePassword();
			pageCP.getCheckProvisioning();
			Test.stopTest();

		}
		
		List<PermissionSetAssignment> permissionSetAssignments = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :newUser.Id AND PermissionSetId IN (SELECT Id FROM PermissionSet WHERE Name='FRED_Primary_User') LIMIT 1];
		System.assert(!permissionSetAssignments.isEmpty());

	}

	@isTest	
	static void CheckProvisioningTestElseIf(){

		User newUser = [SELECT Id FROM User WHERE Username = 'test.issp.registration.testisspregistration.com@partner.iata.org' LIMIT 1];

		UserProvisioningRequest userProvisining = new UserProvisioningRequest(State = 'Failed',
												Operation = 'Activate', 
												ApprovalStatus = 'Required',
												SalesforceUserId = newUser.Id);

		insert userProvisining;

		System.runAs(newUser){
			Test.startTest();
			ISSP_ChangePassword pageCP = new ISSP_ChangePassword();
			pageCP.getCheckProvisioning();
			Test.stopTest();

		}
	
		List<Apexpages.Message> msgs = ApexPages.getMessages();
		boolean b = false;

		for(Apexpages.Message msg:msgs){
			if (msg.getDetail().contains('provisioning error contact admin')) b = true;
		}

		System.assert(b);	
	
	}

}
