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

	}

	static testMethod void myUnitTest_2() {
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
	
	static testMethod void myUnitTest_3() {
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
	
	static testMethod void loginPage_ISSP() {

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
	
	static testMethod void loginPage_ISSP_2() {

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

	static testMethod void loginPage_ISSP_3() {
		ISSP_CS__c cs = new ISSP_CS__c();
		cs.Name = 'ipinfo_token';
		cs.Value__c = 'test';
		insert cs;
		ISSP_First_Login ctrl = new ISSP_First_Login();
		ctrl.changePassword();
		ISSP_First_Login.updateUsers(UserInfo.getUserId());
	}

	static testMethod void fredTests() {
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

	static testMethod void CheckProvisioningTestIF(){

		User newUser = [SELECT Id, Email FROM User WHERE Username = 'test.issp.registration.testisspregistration.com@partner.iata.org' LIMIT 1];

		ISSP_CS__c issp_cs = new ISSP_CS__c(Name = 'PasswordResetPeriod', Value__c = '90');
		ISSP_CS__c issp_cs2 = new ISSP_CS__c(Name = 'Fred_System', Value__c = 'test');		
		insert new List<ISSP_CS__c>{issp_cs, issp_cs2};

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

		System.assertEquals(new PageReference(issp_cs2.Value__c).getUrl(), pagereference.getUrl());

	}

			static testMethod void ChangePasswordServiceName(){
			
			Test.startTest();
			PageReference pgRef = Page.ISSP_ChangePassword;
			pgRef.getParameters().put('serviceName','testServiceName');
			pgRef.getParameters().put('OneId','testOneId');
			Test.setCurrentPageReference(pgRef); 

			ISSP_CS__c issp_cs = new ISSP_CS__c(Name = 'PasswordResetPeriod', Value__c = '90');
			ISSP_CS__c issp_cs2 = new ISSP_CS__c(Name = 'Fred_System', Value__c = 'test');
			insert new List<ISSP_CS__c>{issp_cs, issp_cs2};

			ISSP_ChangePassword pageCP = new ISSP_ChangePassword();
			pageCP.changePassword();
			Test.stopTest();

		}

		static testMethod void checkProvisioningTestElse(){	

			User newUser = [SELECT Id FROM User WHERE Username = 'test.issp.registration.testisspregistration.com@partner.iata.org' LIMIT 1];

			ISSP_CS__c issp_cs = new ISSP_CS__c(Name = 'PasswordResetPeriod', Value__c = '90');
			ISSP_CS__c issp_cs2 = new ISSP_CS__c(Name = 'Fred_System', Value__c = 'test');		
			insert new List<ISSP_CS__c>{issp_cs, issp_cs2};

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

			Id  permissionSetId = [SELECT Id FROM PermissionSet WHERE Name='FRED_Primary_User' LIMIT 1].Id;
		 
			List<PermissionSetAssignment> permissionSetAssignments = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :newUser.Id AND PermissionSetId =  :permissionSetId];
			System.assert(!permissionSetAssignments.isEmpty());

		}

		static testMethod void CheckProvisioningTestElseIf(){

			User newUser = [SELECT Id FROM User WHERE Username = 'test.issp.registration.testisspregistration.com@partner.iata.org' LIMIT 1];

			ISSP_CS__c issp_cs = new ISSP_CS__c(Name = 'PasswordResetPeriod', Value__c = '90');
			ISSP_CS__c issp_cs2 = new ISSP_CS__c(Name = 'Fred_System', Value__c = 'test');		
			insert new List<ISSP_CS__c>{issp_cs, issp_cs2};

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