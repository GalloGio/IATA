@isTest
private class PortalCasesCtrlTest {

	@TestSetup
	static void testSetup(){
		Id accountAgencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
		Id caseRT_IATA_Financial_Review = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');
		Id caseRT_FDS_ICCS_Email_to_Case = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'FDS_ICCS_Email_to_Case');

		Account newAcc = new Account(Name='Account Test Headquarter', Site = 'Site Test', Sector__c = 'Airline',
									 IATACode__c = '123', Field_Head_Office__c = 'Headquarter',
									 RecordTypeId = accountAgencyRT);
		insert newAcc;

		Contact newCon1 = new Contact(AccountId = newAcc.Id, FirstName = 'John', LastName = 'Doe', Email = System.today().dayOfYear() + 'testemail1@csp.testclass', User_Portal_Status__c = 'Approved Admin', Status__c = 'Active');
		Contact newCon2 = new Contact(AccountId = newAcc.Id, FirstName = 'John 1', LastName = 'Doe 1', Email = 'testemailNEW@csp.testclass', User_Portal_Status__c = 'Approved User', Status__c = 'Active');
		Contact newCon3 = new Contact(AccountId = newAcc.Id, FirstName = 'Jane', LastName = 'Doe 1', Email = 'janedoetest@csp.testclass', User_Portal_Status__c = 'Approved User', Status__c = 'Active');
		insert new List<Contact>{newCon1, newCon2,newCon3};

		Case newCase = new Case(Subject = 'Case Test', Region__c = 'Africa & Middle East',
								Origin = 'Portal', CaseArea__c = 'Accreditation');
		Case newCase1 = new Case(Subject = 'Case Test 1', Region__c = 'Africa & Middle East',
								 Origin = 'Portal', CaseArea__c = 'Accreditation',
								 E2CP__AdditionalCC__c = 'testqa.tcosta@yopmail.com.inactive.inactive');
		Case newCase3 = new Case(Subject = 'Bla', Region__c = 'Africa & Middle East',
							Origin = 'Portal', CaseArea__c = 'Accreditation',
							E2CP__AdditionalCC__c = 'testqa.tcosta@yopmail.com.inactive.inactive',
							RecordTypeId = caseRT_FDS_ICCS_Email_to_Case,
							Visible_on_ISS_Portal__c = true, ContactId = newCon1.Id);
		insert new List<Case>{newCase, newCase1, newCase3};

		CaseComment caseComment = new CaseComment(ParentId = newCase.Id);
		insert caseComment;

		User newUser = ISSP_ObjectFactory.createPortalUser(newCon1);

		List<Portal_Applications__c> portalApplicationList = TestDataFactory_PortalApplications.createDefaultPortalApplication(4);

		Portal_Applications__c pa = portalApplicationList.get(0);
		pa.Name = TIP_Utils.PORTAL_SERVICE_NAME_TIP;
		Portal_Applications__c pa1 = portalApplicationList.get(1);
		pa1.Name = 'Airline Joinings Test';
		Portal_Applications__c pa2 = portalApplicationList.get(2);
		pa2.Name = 'Agency Service Test';
		Portal_Applications__c pa3 = portalApplicationList.get(3);
		pa3.Name = 'IATA Airlines and Location Codes';
		insert portalApplicationList;

		ISSP_Portal_Service_Ids__c psi = new ISSP_Portal_Service_Ids__c(
			TIP_Portal_Service_Id__c = pa.Id,
			AirlineParticipation__c = String.valueOf(pa1.Id).substring(0, 15),
			AgencyAccreditation__c = String.valueOf(pa2.Id).substring(0, 15),
			ACLI_IATA_Airlines_and_Location_Codes_Na__c = pa3.Name,
			ACLI_IATA_Airlines_and_Location_Codes__c = String.valueOf(pa3.Id).substring(0, 15)
		);
		insert psi;

		Portal_Application_Right__c right1 = new Portal_Application_Right__c(Contact__c = newCon1.Id, Right__c = 'Access Granted', Portal_Application__c = pa.Id);
		Portal_Application_Right__c right2 = new Portal_Application_Right__c(Contact__c = newCon1.Id, Right__c = 'Access Granted', Portal_Application__c = pa1.Id);
		Portal_Application_Right__c right3 = new Portal_Application_Right__c(Contact__c = newCon1.Id, Right__c = 'Access Granted', Portal_Application__c = pa2.Id);
		Portal_Application_Right__c right4 = new Portal_Application_Right__c(Contact__c = newCon1.Id, Right__c = 'Access Granted', Portal_Application__c = pa3.Id);
		insert new List<Portal_Application_Right__c>{right1, right2, right3, right4};

		ISSPCaseListView__c customSet = new ISSPCaseListView__c();
		customSet.Name = 'ISSP_MyRecentCases';
		customSet.Field_Set_API_Name__c = 'ISSP_MyRecentCases';
		customSet.isAdmin__c = false;
		customSet.isMyAccount__c = false;
		customSet.isOwnedByMe__c = false;
		customSet.Label_API_name__c = 'ISSP_MyRecentCases';
		customSet.Permission_set__c = '';
		customSet.Profiles_Id__c = '00ew0000001QRzH;00ew0000001QRzE;00ew0000001QRzC;00ew0000001QRzG';
		customSet.SOQL_Filter__c = 'where CreatedDate > 2014-01-13T00:00:00Z and Visible_on_ISS_Portal__c = true';
		customSet.SOQL_Order__c = 'CreatedDate DESC';

		ISSPCaseListView__c customSet1 = new ISSPCaseListView__c();
		customSet1.Name = 'ISSP_MyCompanyOpenCases';
		customSet1.Field_Set_API_Name__c = 'ISSP_MyCompanyOpenCases';
		customSet1.isAdmin__c = true;
		customSet1.isMyAccount__c = true;
		customSet1.isOwnedByMe__c = false;
		customSet1.Label_API_name__c = 'ISSP_Homepage_My_Company_open_cases';
		customSet1.Permission_set__c = '';
		customSet1.Profiles_Id__c = '00ew0000001QRzB;00ew0000001QRzH;00ew0000001QRzE;00ew0000001QRzC;00ew0000001QRzF;00ew0000001QRzD;00ew0000001QRzI;00ew0000001QoD2;00ew0000001QoBu;00ew0000001QoBp;00ew0000001QoC9;00ew0000001QRzG';
		customSet1.SOQL_Filter__c = 'where CreatedDate > 2014-01-13T00:00:00Z and Visible_on_ISS_Portal__c = true and IsClosed = false';
		customSet1.SOQL_Order__c = '';
		insert new List<ISSPCaseListView__c>{customSet, customSet1};

		ISSP_CS__c customSettingProfile = new ISSP_CS__c();
		customSettingProfile.Name = 'ISS_Portal_Airline_Delegated_Admin';
		customSettingProfile.Value__c = ISSP_Constant.TEST_User_ProfileID;
		insert customSettingProfile;
	}

	@IsTest
	static void testHandleResult(){
		User usr = [SELECT Id, ContactId FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];
		Contact cont = [SELECT Id FROM Contact WHERE FirstName = 'John' LIMIT 1];
		Account newAcc = [SELECT Id FROM Account LIMIT 1];
		Case newCase = [SELECT Id FROM Case WHERE Subject = 'Case Test' LIMIT 1];
		Case newCase1 = [SELECT Id FROM Case WHERE Subject = 'Case Test 1' LIMIT 1];
		Case newCase3 = [SELECT Id, is_Portal_user_equal_case_contact__c FROM Case WHERE Subject = 'Bla' LIMIT 1];

		Id caseRT_FDS_ICCS_Email_to_Case = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'FDS_ICCS_Email_to_Case');
		Test.startTest();
		System.runAs(usr) {
			Case newCase4 = new Case(Subject = 'Bla', Region__c = 'Africa & Middle East',
									Origin = 'Portal', CaseArea__c = 'Accreditation',
									E2CP__AdditionalCC__c = 'testqa.tcosta@yopmail.com.inactive.inactive',
									RecordTypeId = caseRT_FDS_ICCS_Email_to_Case,
									Visible_on_ISS_Portal__c = true, ContactId = usr.ContactId);
			insert newCase4;

			Case getCaseTest = PortalCasesCtrl.getCaseById(newCase4.Id);

			List<CSP_Utils.PickListWrapper> caseTypeOptions = PortalCasesCtrl.typeOfCasePortalCustomPicklist();

			PortalSearchFilterWrapper.casesComponent casesCmp = new PortalSearchFilterWrapper.casesComponent();
			casesCmp.caseTypeFilter = caseTypeOptions[0].value;
			casesCmp.caseCountryFilter = 'Portugal';
			PortalSearchFilterWrapper portFilterWrapper = new PortalSearchFilterWrapper();
			portFilterWrapper.searchText = 'Bla';
			portFilterWrapper.casesComponent = casesCmp;

			CSP_Utils.PagedResult pag1 = PortalCasesCtrl.getFilteredCasesResultsPage(JSON.serialize(portFilterWrapper), '0', CSP_Utils.isAdmin());

			CSP_Utils.PagedResult pag = PortalCasesCtrl.getRecentCases(false, false, false);

			PortalCasesCtrl.ReturnWrapper addNewRecipientTest = PortalCasesCtrl.addNewRecipient(newCase1.Id, '');

			DAL_WithoutSharing.ReturnWrapper submitNewMessageTest = DAL_WithoutSharing.submitNewMessage(newCase.Id, 'Test Message');
		}
		PortalCasesCtrl.ReturnWrapper addNewRecipientTest1 = PortalCasesCtrl.addNewRecipient(newCase.Id, 'testeW@csp.testclass');
		PortalCasesCtrl.ReturnWrapper addNewRecipientTest2 = PortalCasesCtrl.addNewRecipient(newCase.Id, 'testemailNEW@csp.testclass');
		List<PortalCasesCtrl.MessageWrapper> lstCases = PortalCasesCtrl.getCaseMessages(newCase.Id);
		PortalCasesCtrl.ReturnWrapper removeRecipientTest = PortalCasesCtrl.removeRecipient(newCase1.Id, 'tes@test.com');
		Test.stopTest();
	}

	@IsTest
	static void testHandleResult1(){
		User usr = [SELECT Id, ContactId FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];
		Contact cont = [SELECT Id FROM Contact WHERE FirstName = 'John' LIMIT 1];
		Account newAcc = [SELECT Id FROM Account LIMIT 1];
		Case newCase = [SELECT Id FROM Case WHERE Subject = 'Case Test' LIMIT 1];
		Case newCase1 = [SELECT Id FROM Case WHERE Subject = 'Case Test 1' LIMIT 1];
		Case newCase3 = [SELECT Id, is_Portal_user_equal_case_contact__c FROM Case WHERE Subject = 'Bla' LIMIT 1];

		Case getCaseTest = PortalCasesCtrl.getCaseById(newCase.Id);
		Id caseRT_FDS_ICCS_Email_to_Case = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'FDS_ICCS_Email_to_Case');
		Test.startTest();
		Boolean isAdmin = PortalCasesCtrl.isAirlineAdmin();
		System.runAs(usr) {

			Case newCase4 = new Case(Subject = 'Bla', Region__c = 'Africa & Middle East',
									Origin = 'Portal', CaseArea__c = 'Accreditation', CNSCase__c = true,
									E2CP__AdditionalCC__c = 'testqa.tcosta@yopmail.com.inactive.inactive',
									RecordTypeId = caseRT_FDS_ICCS_Email_to_Case,
									Visible_on_ISS_Portal__c = true, ContactId = usr.ContactId);
			insert newCase4;

			CSP_Utils.PagedResult pag = PortalCasesCtrl.getRecentCases(true, true, true);

			PortalCasesCtrl.ReturnWrapper addNewRecipientTest = PortalCasesCtrl.addNewRecipient(newCase1.Id, '');

			DAL_WithoutSharing.ReturnWrapper submitNewMessageTest = DAL_WithoutSharing.submitNewMessage(newCase.Id, 'Test Message');
		}
		PortalCasesCtrl.ReturnWrapper addNewRecipientTest1 = PortalCasesCtrl.addNewRecipient(newCase.Id, 'testeW@csp.testclass');
		PortalCasesCtrl.ReturnWrapper addNewRecipientTest2 = PortalCasesCtrl.addNewRecipient(newCase.Id, 'testemailNEW@csp.testclass');
		List<PortalCasesCtrl.MessageWrapper> lstCases = PortalCasesCtrl.getCaseMessages(newCase.Id);
		PortalCasesCtrl.ReturnWrapper removeRecipientTest = PortalCasesCtrl.removeRecipient(newCase1.Id, 'tes@test.com');
		Test.stopTest();
	}

	@IsTest
	static void testHandleResult2(){
		User usr = [SELECT Id, ContactId FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];

		Case newCase = [SELECT Id FROM Case WHERE Subject = 'Case Test' LIMIT 1];
		Case newCase1 = [SELECT Id FROM Case WHERE Subject = 'Case Test 1' LIMIT 1];

		Case getCaseTest = PortalCasesCtrl.getCaseById(newCase.Id);
		Test.startTest();
		System.runAs(usr) {
			createOscar(TIP_Utils.CASE_REASON_PAYMENT_PROVIDER_MANAGMENT,TIP_Utils.CASE_AREA_TRANSPARENCY_IN_PAYMENTS,TIP_Utils.CASE_STATUS_DRAFT,usr.ContactId,'OSCAR_Communication');
			PortalSearchFilterWrapper portFilterWrapper = new PortalSearchFilterWrapper();
			portFilterWrapper.searchText = 'Bla';

			CSP_Utils.PagedResult pag1 = PortalCasesCtrl.getFilteredCasesResultsPage(JSON.serialize(portFilterWrapper), '0', CSP_Utils.isAdmin());
			PortalCasesCtrl.ReturnWrapper addNewRecipientTest = PortalCasesCtrl.addNewRecipient(newCase1.Id, '');
			DAL_WithoutSharing.ReturnWrapper submitNewMessageTest = DAL_WithoutSharing.submitNewMessage(newCase.Id, 'Test Message');
			PortalCasesCtrl.MessageWrapper mw = new PortalCasesCtrl.MessageWrapper();
		}
		PortalCasesCtrl.ReturnWrapper addNewRecipientTest1 = PortalCasesCtrl.addNewRecipient(newCase.Id, 'testeW@csp.testclass');
		PortalCasesCtrl.ReturnWrapper addNewRecipientTest2 = PortalCasesCtrl.addNewRecipient(newCase.Id, 'testemailNEW@csp.testclass');
		List<PortalCasesCtrl.MessageWrapper> lstCases = PortalCasesCtrl.getCaseMessages(newCase.Id);
		PortalCasesCtrl.ReturnWrapper removeRecipientTest = PortalCasesCtrl.removeRecipient(newCase1.Id, 'tes@test.com');
		Test.stopTest();
	}

	@IsTest
	static void testHandleResult3(){
		Contact cont = [SELECT Id,lastname,firstname,email FROM Contact WHERE FirstName = 'Jane' LIMIT 1];

		user u = ISSP_ObjectFactory.createPortalUser(cont);
		u.profileId=[select id from profile where name like 'ISS Portal DPC Admin%' limit 1].id;
		update u;

		Id caseRT_FDS_ICCS_Email_to_Case = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

		Test.startTest();
		System.runAs(u) {
			contact contt2= new contact(
				lastname='Dane',
				email='janedanetest@test.test',
				status__c='Active',
				user_portal_status__c='Approved Admin'
			);
			insert contt2;
			Case cs = new Case(	Subject = 'Bla', Region__c = 'Africa & Middle East',
								Origin = 'Portal', CaseArea__c = 'Accreditation',
								E2CP__AdditionalCC__c = 'testqa.tcosta@yopmail.com.inactive.inactive',
								RecordTypeId = caseRT_FDS_ICCS_Email_to_Case,
								Visible_on_ISS_Portal__c = true, ContactId = u.ContactId);
			insert cs;

			PortalCasesCtrl.ReturnWrapper addNewRecipientTest = PortalCasesCtrl.addNewRecipient(cs.Id, 'janedanetest@test.test');
		}

		Test.stopTest();
	}

	@IsTest
	static void testHandleResult4(){
		User usr = [SELECT Id, ContactId FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];

		Test.startTest();
		System.runAs(usr) {
			createOscar('CHG – Data Maintenance','Test','Draft',usr.ContactId,'OSCAR_Communication');
			PortalSearchFilterWrapper portFilterWrapper = new PortalSearchFilterWrapper();
			portFilterWrapper.searchText = 'Bla';

			CSP_Utils.PagedResult pag1 = PortalCasesCtrl.getFilteredCasesResultsPage(JSON.serialize(portFilterWrapper), '0', CSP_Utils.isAdmin());
			List<CSP_Utils.PickListWrapper> contactPickOptions = PortalCasesCtrl.companyCasesContactsPicklist();
			System.assertNotEquals(0, contactPickOptions.size());
		}
		Test.stopTest();
	}

	@IsTest
	static void testHandleResult5(){
		User usr = [SELECT Id, ContactId FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];

		Test.startTest();
		System.runAs(usr) {
			createOscar(AMS_Utils.CASE_REASON_FOR_MANAGEMENT,'Test','Draft',usr.ContactId,'OSCAR_Communication');
			PortalSearchFilterWrapper portFilterWrapper = new PortalSearchFilterWrapper();
			portFilterWrapper.searchText = 'Bla';

			CSP_Utils.PagedResult pag1 = PortalCasesCtrl.getFilteredCasesResultsPage(JSON.serialize(portFilterWrapper), '0', CSP_Utils.isAdmin());
		}
		Test.stopTest();
	}
	@IsTest
	static void testHandleResult6(){
		User usr = [SELECT Id, ContactId FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];

		Test.startTest();
		System.runAs(usr) {
			createOscar('New','Test','Draft',usr.ContactId,'OSCAR_Communication');
			PortalSearchFilterWrapper portFilterWrapper = new PortalSearchFilterWrapper();
			portFilterWrapper.searchText = 'Bla';

			CSP_Utils.PagedResult pag1 = PortalCasesCtrl.getFilteredCasesResultsPage(JSON.serialize(portFilterWrapper), '0', CSP_Utils.isAdmin());
		}
		Test.stopTest();
	}

	@IsTest
	static void testHandleResult_MC(){
		User usr = [SELECT Id, ContactId FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];

		Test.startTest();
		System.runAs(usr) {
			createOscar(AMS_Utils.CASE_REASON_HE_MULTICOUNTRY,'Test','Draft',usr.ContactId,'OSCAR_Communication');
			PortalSearchFilterWrapper portFilterWrapper = new PortalSearchFilterWrapper();
			portFilterWrapper.searchText = 'Bla';

			CSP_Utils.PagedResult pag1 = PortalCasesCtrl.getFilteredCasesResultsPage(JSON.serialize(portFilterWrapper), '0', CSP_Utils.isAdmin());
		}
		Test.stopTest();
	}

	@IsTest
	static void testHandleResult7(){
		User usr = [SELECT Id, ContactId FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];

		Test.startTest();
		System.runAs(usr) {

			createOscar('CLO – Closure','Test','Draft',usr.ContactId,'OSCAR_Communication');
			PortalSearchFilterWrapper portFilterWrapper = new PortalSearchFilterWrapper();
			portFilterWrapper.searchText = 'Bla';

			CSP_Utils.PagedResult pag1 = PortalCasesCtrl.getFilteredCasesResultsPage(JSON.serialize(portFilterWrapper), '0', CSP_Utils.isAdmin());
		}
		Test.stopTest();
	}
	@IsTest
	static void testHandleResult8(){
		User usr = [SELECT Id, ContactId FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];

		Test.startTest();
		System.runAs(usr) {

			createOscar('Bank Detail Update','Test','Draft',usr.ContactId,'OSCAR_Communication');
			PortalSearchFilterWrapper portFilterWrapper = new PortalSearchFilterWrapper();
			portFilterWrapper.searchText = 'Bla';

			CSP_Utils.PagedResult pag1 = PortalCasesCtrl.getFilteredCasesResultsPage(JSON.serialize(portFilterWrapper), '0', CSP_Utils.isAdmin());
		}
		Test.stopTest();
	}
	@IsTest
	static void testHandleResult9(){
		User usr = [SELECT Id, ContactId FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];

		Test.startTest();
		System.runAs(usr) {

			createOscar('Annual revalidation','Test','Open',usr.ContactId,'OSCAR_Communication');
			PortalSearchFilterWrapper portFilterWrapper = new PortalSearchFilterWrapper();
			portFilterWrapper.searchText = 'Bla';

			CSP_Utils.PagedResult pag1 = PortalCasesCtrl.getFilteredCasesResultsPage(JSON.serialize(portFilterWrapper), '0', CSP_Utils.isAdmin());
		}
		Test.stopTest();
	}
	@IsTest
	static void testHandleResult10(){
		User usr = [SELECT Id, ContactId FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];

		Test.startTest();
		System.runAs(usr) {
			createOscar(TIP_Utils.CASE_REASON_PRODUCT_MANAGEMENT,TIP_Utils.CASE_AREA_TRANSPARENCY_IN_PAYMENTS,TIP_Utils.CASE_STATUS_DRAFT,usr.ContactId,'OSCAR_Communication');

			PortalSearchFilterWrapper portFilterWrapper = new PortalSearchFilterWrapper();
			portFilterWrapper.searchText = 'Bla';

			CSP_Utils.PagedResult pag1 = PortalCasesCtrl.getFilteredCasesResultsPage(JSON.serialize(portFilterWrapper), '0', CSP_Utils.isAdmin());
		}
		Test.stopTest();
	}

	@IsTest
	static void testHandleResult11(){
		User usr = [SELECT Id, ContactId FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];

		Test.startTest();
		System.runAs(usr) {
			createOscar('Test','','Draft',usr.ContactId,'IDFS_Airline_Participation_Process');

			PortalSearchFilterWrapper portFilterWrapper = new PortalSearchFilterWrapper();
			portFilterWrapper.searchText = 'Bla';

			CSP_Utils.PagedResult pag1 = PortalCasesCtrl.getFilteredCasesResultsPage(JSON.serialize(portFilterWrapper), '0', CSP_Utils.isAdmin());
		}
		Test.stopTest();
	}

	@isTest
	static void testHandleResult12(){	
		User usr = [SELECT Id, ContactId FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];
		Id caseRT_airlineCodingApplication = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Airline_Coding_Application');

		Test.startTest();
		System.runAs(usr) {
			Case newCase4 = new Case(Subject = 'Bla', Region__c = 'Europe', Status='Draft',
									Origin = 'Portal', CaseArea__c = 'Airline Coding Application', Reason1__c='Location ID Form',
									RecordTypeId = caseRT_airlineCodingApplication,
									Visible_on_ISS_Portal__c = true, ContactId = usr.ContactId);
			insert newCase4;
			
				
			Participation_Online_Application__c participation = new Participation_Online_Application__c();
			participation.Case__c = newCase4.Id;
			insert participation;

			Case getCaseTest = PortalCasesCtrl.getCaseById(newCase4.Id);

			List<CSP_Utils.PickListWrapper> caseTypeOptions = PortalCasesCtrl.typeOfCasePortalCustomPicklist();
			
			CSP_Utils.PagedResult pag = PortalCasesCtrl.getRecentCases(false, false, false);
		}
		Test.stopTest();
	}

	@isTest
	static void testHandleResult13(){	
		User usr = [SELECT Id, ContactId FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];
		Id caseRT_airlineCodingApplication = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Airline_Coding_Application');

		Test.startTest();
		System.runAs(usr) {
			Case newCase4 = new Case(Subject = 'Bla', Region__c = 'Europe', Status='Draft',
									Origin = 'Portal', CaseArea__c = 'Airline Coding Application', Reason1__c='Designator Form',
									RecordTypeId = caseRT_airlineCodingApplication,
									Visible_on_ISS_Portal__c = true, ContactId = usr.ContactId);
			insert newCase4;
			
				
			Participation_Online_Application__c participation = new Participation_Online_Application__c();
			participation.Case__c = newCase4.Id;
			insert participation;

			Case getCaseTest = PortalCasesCtrl.getCaseById(newCase4.Id);

			List<CSP_Utils.PickListWrapper> caseTypeOptions = PortalCasesCtrl.typeOfCasePortalCustomPicklist();
			
			CSP_Utils.PagedResult pag = PortalCasesCtrl.getRecentCases(false, false, false);
		}
		Test.stopTest();
	}

	@isTest
	static void testHandleResult14(){	
		User usr = [SELECT Id, ContactId FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];
		Id caseRT_airlineCodingApplication = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Airline_Coding_Application');

		Test.startTest();
		System.runAs(usr) {
			Case newCase4 = new Case(Subject = 'Bla', Region__c = 'Europe', Status='Draft',
									Origin = 'Portal', CaseArea__c = 'Airline Coding Application', Reason1__c='Baggage Tag Identifier Codes',
									RecordTypeId = caseRT_airlineCodingApplication,
									Visible_on_ISS_Portal__c = true, ContactId = usr.ContactId);
			insert newCase4;

			Participation_Online_Application__c participation = new Participation_Online_Application__c();
			participation.Case__c = newCase4.Id;
			insert participation;

			Case getCaseTest = PortalCasesCtrl.getCaseById(newCase4.Id);
			List<CSP_Utils.PickListWrapper> caseTypeOptions = PortalCasesCtrl.typeOfCasePortalCustomPicklist();
			CSP_Utils.PagedResult pag = PortalCasesCtrl.getRecentCases(false, false, false);
		}
		Test.stopTest();
	}

	@isTest
	static void testHandleResult15(){	
		User usr = [SELECT Id, ContactId FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];
		Id caseRT_airlineCodingApplication = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Airline_Coding_Application');

		Test.startTest();
		System.runAs(usr) {
			Case newCase4 = new Case(Subject = 'Bla', Region__c = 'Europe', Status='Draft',
									Origin = 'Portal', CaseArea__c = 'Airline Coding Application', Reason1__c='3 Digit Form',
									RecordTypeId = caseRT_airlineCodingApplication,
									Visible_on_ISS_Portal__c = true, ContactId = usr.ContactId);
			insert newCase4;

			Participation_Online_Application__c participation = new Participation_Online_Application__c();
			participation.Case__c = newCase4.Id;
			insert participation;

			Case getCaseTest = PortalCasesCtrl.getCaseById(newCase4.Id);

			List<CSP_Utils.PickListWrapper> caseTypeOptions = PortalCasesCtrl.typeOfCasePortalCustomPicklist();

			CSP_Utils.PagedResult pag = PortalCasesCtrl.getRecentCases(false, false, false);	
		}
		Test.stopTest();
	}

	private static void createOscar(string caseReason,string caseArea,string caseStatus,Id contactId,string devName){
		Id oscarRTId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', devName);
		Case newCase4 = new Case(
					subject = 'Bla',
					Region__c = 'Africa & Middle East',
					Origin = 'Portal',
					CaseArea__c = caseArea,
					CNSCase__c = false,
					Status = caseStatus,
					E2CP__AdditionalCC__c = 'testqa.tcosta@yopmail.com.inactive.inactive',
					Reason1__c = caseReason,
					RecordTypeId = oscarRTId,
					Visible_on_ISS_Portal__c = true,
					ContactId = contactId);
		insert newCase4;

		AMS_Pax_Accreditation_Form__c ams = new AMS_Pax_Accreditation_Form__c();
		ams.SAAM_Case__c = newCase4.id;
		ams.Operation_Type__c = 'Travel_Agent';
		ams.Notify_Change_Location__c = true;
		insert ams;

		AP_Process_Form__c apForm = new AP_Process_Form__c(Case__c = newCase4.Id);
		insert apForm;

		PortalCasesCtrl.OptionWrapper opBuilder = PortalCasesCtrl.optionBuilder(newCase4);
	}

	@IsTest
	static void testGetSurveyLink(){
		CaseClosedStatus__c ccs= new CaseClosedStatus__c(name='Closed');
		insert ccs;

		Case newCase = [SELECT Id,RecordType.Name FROM Case WHERE Subject = 'Case Test' LIMIT 1];
		newCase.Status = 'Closed';
		update newCase;

		ClosedSurvey__c closedSurvey = new ClosedSurvey__c(RolesAvailable__c='All',Name=newCase.RecordType.Name);
		insert closedSurvey;

		String link = PortalCasesCtrl.getSurveyLink(newCase.Id);
		System.assert(link != null);
	}

	@IsTest static void testPortalGlobalSearch() {
		User testUser = [SELECT Id FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];

		Test.startTest();
		System.runAs(testUser) {
			CSP_Utils.PagedResult test = new CSP_Utils.PagedResult();
			List<CSP_Utils.PickListWrapper> caseTypeOptions = PortalCasesCtrl.typeOfCasePortalCustomPicklist();

			PortalSearchFilterWrapper.casesComponent casesCmp = new PortalSearchFilterWrapper.casesComponent();
			casesCmp.caseTypeFilter = caseTypeOptions[0].value;
			casesCmp.caseCountryFilter = 'Portugal';
			casesCmp.show = true;
			PortalSearchFilterWrapper filtersWrapper = new PortalSearchFilterWrapper();
			filtersWrapper.searchText = 'Bla';
			filtersWrapper.casesComponent = casesCmp;

			test = PortalGlobalSearchCtrl.portalGlobalSearch(JSON.serialize(filtersWrapper), 'Cases');
		}
		Test.stopTest();
	}

	@IsTest
	static void testGetHideForClosedCases(){
		User usr = [SELECT Id, ContactId FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];
		Contact cont = [SELECT Id FROM Contact WHERE FirstName = 'John' LIMIT 1];
		Account newAcc = [SELECT Id FROM Account LIMIT 1];
		Case newCase = [SELECT Id FROM Case WHERE Subject = 'Case Test' LIMIT 1];
		Case newCase1 = [SELECT Id FROM Case WHERE Subject = 'Case Test 1' LIMIT 1];
		Case newCase3 = [SELECT Id, is_Portal_user_equal_case_contact__c FROM Case WHERE Subject = 'Bla' LIMIT 1];

		Id caseRT_FDS_ICCS_Email_to_Case = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'FDS_ICCS_Email_to_Case');
	
			Test.startTest();
			System.runAs(usr) {
				Case newCase4 = new Case(Subject = 'Bla', Region__c = 'Africa & Middle East',
										Origin = 'Portal', CaseArea__c = 'Accreditation',
										E2CP__AdditionalCC__c = 'testqa.tcosta@yopmail.com.inactive.inactive',
										RecordTypeId = caseRT_FDS_ICCS_Email_to_Case,
										Visible_on_ISS_Portal__c = true, ContactId = usr.ContactId);
				insert newCase4;
				
				Case getCaseTest = PortalCasesCtrl.getCaseById(newCase4.Id);

				boolean expired = PortalCasesCtrl.getHideForClosedCases(newCase4.Id);
				
				System.assertEquals(expired,false);
				Test.stopTest();
		
			}
	}
	
	@IsTest
	static void testGetHideAddNewDocumentsDGR(){
		User usr = [SELECT Id, ContactId FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];
		IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(name = 'suisse',ISO_Code__c ='SS' );
		insert isoCountry;
		Id agencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
		Account newAcc = new Account(RecordTypeId=agencyRT, Status__c = 'Approved', Reason_for_creation__c = 'Headquarter is missing', 
									Name='Test1 Account', Location_Type__c = 'HO', Type='CASS Associate', Sector__c = 'Travel Agent', 
									IATA_ISO_Country__c = isoCountry.id, IATAcode__c = '12345678', AIMS_ID__c = '12345678', Source_System__c = 'AIMS2');
		insert newAcc;
		ID rtChange = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'CERTIFICATION');
		AMS_OSCAR__c theOscar = new AMS_OSCAR__c(RecordTypeId = rtChange, Account__c = newAcc.Id, Type_of_change__c = AMS_Utils.COR,Change_effective_as_of__c  = Date.today());
		insert theOscar;

		ID rtCommCase = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');
		Case newCase4 = new Case(Subject = 'Bla', Region__c = 'Africa & Middle East',
								Origin = 'Portal', CaseArea__c = 'Accreditation',
								E2CP__AdditionalCC__c = 'testqa.tcosta@yopmail.com.inactive.inactive',
								RecordTypeId = rtCommCase,
								Visible_on_ISS_Portal__c = true, ContactId = usr.ContactId, OSCAR__c = theOscar.Id);
		insert newCase4;
		Test.startTest();
		System.runAs(usr) {
			boolean expired = PortalCasesCtrl.getHideAddNewDocumentsDGR(newCase4.Id);
			System.assertEquals(expired,false);
			Test.stopTest();
	
		}
	}
	
	@IsTest
	static void testSidraCase(){
		User usr = [SELECT Id, ContactId FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];
		Contact cont = [SELECT Id FROM Contact WHERE FirstName = 'John' LIMIT 1];
		Account newAcc = [SELECT Id FROM Account LIMIT 1];

		Id caseRT_FDS_ICCS_Email_to_Case = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');

		Case newCase4 = new Case(Subject = 'Sidra test case', Region__c = 'Africa & Middle East',
									Origin = 'Portal', CaseArea__c = 'Accreditation', BSP_CASS__c = 'BSP',
									E2CP__AdditionalCC__c = 'testqa.tcosta@yopmail.com.inactive.inactive',
									IATAcode__c = '98789344',
									RecordTypeId = caseRT_FDS_ICCS_Email_to_Case,
									Visible_on_ISS_Portal__c = true, ContactId = usr.ContactId);
		insert newCase4;

		Test.startTest();
		System.runAs(usr) {
			PortalCasesCtrl.PortalCasesCtrl_WithoutSharing CasesNoSharing = new PortalCasesCtrl.PortalCasesCtrl_WithoutSharing();
            CasesNoSharing.getCaseComments(newCase4.Id);

			Case getCaseTest = PortalCasesCtrl.getCaseById(newCase4.Id);
			System.assertNotEquals(getCaseTest, null);
		}
		PortalCasesCtrl.ReturnWrapper returnWrapperTest = new PortalCasesCtrl.ReturnWrapper(true, 'test', 'test');
		Test.stopTest();
	}
}