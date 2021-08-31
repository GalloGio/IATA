@isTest
public class PortalServicesCtrlTest {

	@testSetup
	static void setup() {
		List<Portal_Applications__c> portalApplicationList = TestDataFactory_PortalApplications.createDefaultPortalApplication(11);

		Portal_Applications__c easyPay1 = portalApplicationList.get(0);
		easyPay1.Name = ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_EDENRED;
		easyPay1.ANG_Restrict_by_Agency_Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT;
		easyPay1.ANG_Accredited_Agents_Only__c = false;
		easyPay1.Agency__c = true;

		Portal_Applications__c easyPay2 =  portalApplicationList.get(1);
		easyPay2.Name = ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_MSTS;
		easyPay2.ANG_Restrict_by_Agency_Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT;
		easyPay2.ANG_Accredited_Agents_Only__c = false;
		easyPay2.Agency__c = true;

		Portal_Applications__c easyPay3 = portalApplicationList.get(2); 
		easyPay3.Name = ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_WEX;
		easyPay3.ANG_Restrict_by_Agency_Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT;
		easyPay3.ANG_Accredited_Agents_Only__c = true;
		easyPay3.Agency__c = true;

		Portal_Applications__c serviceTest = portalApplicationList.get(3);
		serviceTest.Name = 'serviceTest';
		serviceTest.ANG_Restrict_by_Agency_Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT;
		serviceTest.ANG_Accredited_Agents_Only__c = false;
		serviceTest.Agency__c = true;

		Portal_Applications__c serviceTest2 = portalApplicationList.get(4);
		serviceTest2.Name = 'serviceTest2';
		serviceTest2.ANG_Restrict_by_Agency_Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT;
		serviceTest2.ANG_Accredited_Agents_Only__c = false;
		serviceTest2.Agency__c = true;

		Portal_Applications__c serviceTest3 = portalApplicationList.get(5);
		serviceTest3.Name = 'serviceTest3';
		serviceTest3.requestable__c = true;
		serviceTest3.Agency__c = true;
		serviceTest3.Hide_on_Homepage__c = false;

		Portal_Applications__c serviceTest4 = portalApplicationList.get(6);
		serviceTest4.Name = 'serviceTest4';
		serviceTest4.requestable__c = true;
		serviceTest4.Agency__c = true;

		Portal_Applications__c serviceTest5 = portalApplicationList.get(7);
		serviceTest5.Name = 'Insurance Providers';
		serviceTest5.requestable__c = false;
		serviceTest5.Agency__c = true;


		Portal_Applications__c serviceTest6 = portalApplicationList.get(8);
		serviceTest6.Name = 'Financial Securities';
		serviceTest6.Requestable__c = false;

		Portal_Applications__c serviceTest7 = portalApplicationList.get(9);
		serviceTest7.Name = 'Treasury Dashboard - Premium';
		serviceTest7.Requestable__c = false;

		Portal_Applications__c serviceTest8 = portalApplicationList.get(10);
		serviceTest8.Name = 'E&F APPS';
		serviceTest8.Requestable__c = true;

		insert portalApplicationList;

		List<IATA_ISO_Country__c> iataISOCountryList = TestDataFactory_IATAISOCountries.createDefaultIATAISOCountries(4);
		
		IATA_ISO_Country__c portugal = iataISOCountryList.get(0);
		portugal.Name = 'Portugal_test';
		portugal.ISO_Code__c = 'PT';
		portugal.ANG_Portal_Service__c = easyPay1.id;
		portugal.ANG_Enable_NewGen__c = true;

		IATA_ISO_Country__c switzerland = iataISOCountryList.get(1);
		switzerland.Name = 'Switzerland_test';
		switzerland.ISO_Code__c = 'CH';
		switzerland.ANG_Portal_Service__c = easyPay2.id;
		switzerland.ANG_Enable_NewGen__c = true;

		IATA_ISO_Country__c germany = iataISOCountryList.get(2);
		germany.Name = 'Germany_test';
		germany.ISO_Code__c = 'DH';
		germany.ANG_Portal_Service__c = easyPay3.id;

		IATA_ISO_Country__c spain = iataISOCountryList.get(3);
		spain.Name = 'Spain_test';
		spain.ISO_Code__c = 'SP';

		insert iataISOCountryList;

		Id rtId = RecordTypeSelector.selectIdBySObjectAndDeveloperName('Account', 'IATA_Agency');

		List<Account> accountList = TestDataFactory_Accounts.createStandardAccounts(4);
		String reasonForCreation = Account.Reason_for_creation__c.getDescribe().getPickListValues().get(0).getLabel();

		Account a = accountList.get(0);
		a.name = 'AccountTest';
		a.IATA_ISO_Country__c = portugal.id;
		a.Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT;
		a.ANG_IEP_Status__c = ANG_ISSP_PortalServiceHelper.STATUS_OPEN;
		a.Location_type__c = 'HE';
		a.OwnerId = UserInfo.getUserId();
		a.Location_Class__c = 'P';
		a.RecordTypeId = rtId;
		a.Reason_for_creation__c = reasonForCreation;

		Account a2 = accountList.get(1);
		a2.name = 'AccountTest2';
		a2.IATA_ISO_Country__c = switzerland.id;
		a2.Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT;
		a2.ANG_IEP_Status__c = ANG_ISSP_PortalServiceHelper.STATUS_NO_IEP_ACCOUNT;
		a2.Location_type__c = 'HE';
		a2.OwnerId = UserInfo.getUserId();
		a2.Location_Class__c = 'P';
		a2.RecordTypeId=rtId;
		a2.Reason_for_creation__c = reasonForCreation;

		Account a3 = accountList.get(2);
		a3.name = 'AccountTest3';
		a3.IATA_ISO_Country__c = germany.id;
		a3.Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT;
		a3.ANG_IEP_Status__c = ANG_ISSP_PortalServiceHelper.STATUS_IN_PROGRESS;
		a3.Location_type__c = 'AO';
		a3.OwnerId = UserInfo.getUserId();
		a3.Reason_for_creation__c = reasonForCreation;

		Account a4 = accountList.get(3);
		a4.name = 'AccountTest4';
		a4.IATA_ISO_Country__c = spain.id;
		a4.Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT;
		a4.ANG_IEP_Status__c = ANG_ISSP_PortalServiceHelper.STATUS_NO_IEP_ACCOUNT;
		a4.Location_type__c = 'HO';
		a4.OwnerId = UserInfo.getUserId();
		a4.Reason_for_creation__c = reasonForCreation;

		insert accountList;

		List<Contact> contactList = TestDataFactory_Contacts.createDefaultContact(accountList.get(0).Id, 6);

		Contact c = contactList.get(0);
		c.LastName = 'ContactTest';
		c.FirstName = 'Name';
		c.accountID = a.id;
		c.email='ContactTest@portalservices.test';
		c.user_portal_status__c='Approved Admin';

		Contact c2 = contactList.get(1);
		c2.LastName = 'ContactTest2';
		c2.FirstName = 'Name';
		c2.accountId = a2.id;
		c2.email='ContactTest2@portalservices.test';
		c2.user_portal_status__c='Approved Admin';

		Contact c3 = contactList.get(2);
		c3.LastName = 'ContactTest3';
		c3.FirstName = 'Name';
		c3.accountId = a3.id;
		c3.email='ContactTest3@portalservices.test';
		c3.user_portal_status__c='Approved Admin';

		Contact c4 = contactList.get(3);
		c4.LastName = 'ContactTest4';
		c4.FirstName = 'Name';
		c4.accountId = a4.id;
		c4.email='ContactTest4@portalservices.test';
		c4.user_portal_status__c='Approved Admin';

		Contact c5 = contactList.get(4);
		c5.LastName = 'ContactTest5';
		c5.FirstName = 'Name';
		c5.accountId = a4.id;
		c5.Birthdate = Date.today();
		c5.email='ContactTest4@portalservices.test';
		c5.user_portal_status__c='Approved Admin';

		Contact c21 = contactList.get(5);
		c21.LastName = 'ContactTest2.1';
		c21.FirstName = 'Name';
		c21.accountId = a2.id;
		c21.email='ContactTest2.1@portalservices.test';
		c21.user_portal_status__c='Approved Admin';

		insert contactList;

		PortalApplicationRights portalApplicationRights = new PortalApplicationRights();
		Portal_Application_Right__c appRight = TestDataFactory_PortalApplicationRights.createPortalApplicationRight(easyPay1.id, c.Id);
		appRight.Right__c = PortalApplicationRights.ACCESSGRANTED;	

		Portal_Application_Right__c appRight2 = TestDataFactory_PortalApplicationRights.createPortalApplicationRight(easyPay2.id, c2.Id);
		appRight2.Right__c = PortalApplicationRights.ACCESSGRANTED;

		Portal_Application_Right__c appRight3 = TestDataFactory_PortalApplicationRights.createPortalApplicationRight(easyPay3.id, c3.Id);
		appRight3.Right__c = PortalApplicationRights.ACCESSREQUESTED;

		Portal_Application_Right__c appRight4 = TestDataFactory_PortalApplicationRights.createPortalApplicationRight(serviceTest3.id, c2.Id);
		appRight4.Right__c = PortalApplicationRights.ACCESSGRANTED;

		Portal_Application_Right__c appRight5 = TestDataFactory_PortalApplicationRights.createPortalApplicationRight(serviceTest4.id, c4.Id);
		appRight5.Right__c = PortalApplicationRights.ACCESSREQUESTED;
		
		Portal_Application_Right__c appRight6 = TestDataFactory_PortalApplicationRights.createPortalApplicationRight(serviceTest3.id, c21.Id);
		appRight6.Right__c = PortalApplicationRights.ACCESSGRANTED;

		Portal_Application_Right__c appRight7 = TestDataFactory_PortalApplicationRights.createPortalApplicationRight(serviceTest7.id, c4.Id);
		appRight7.Right__c = PortalApplicationRights.ACCESSGRANTED;

		Portal_Application_Right__c appRight8 = TestDataFactory_PortalApplicationRights.createPortalApplicationRight(serviceTest8.id, c4.Id);
		appRight8.Right__c = PortalApplicationRights.ACCESSGRANTED;

		insert new List<Portal_Application_Right__c> {appRight,appRight2,appRight3,appRight4,appRight5,appRight6,appRight7};

		ISSP_CS__c cs= new ISSP_CS__c(
			name='ISS_Portal_Agency_Delegated_Admin',
			Value__c=ISSP_Constant.TEST_User_ProfileID
			);
		insert cs;

		map<string,ID> profileMap = new map<string,id>();
		for(profile pr : [SELECT Id, Name FROM Profile WHERE Name in ('ISS Portal Agency User','ISS Portal Agency Delegated Admin User')]){
			profileMap.put(pr.name,pr.id);
		}

		List<ISSP_CS__c> cSettings = new List<ISSP_CS__c>();

		ISSP_CS__c cSetting = new ISSP_CS__c();
		cSetting.Name = 'ISS_Portal_Agency_User';
		cSetting.Value__c = String.valueOf(profileMap.get('ISS Portal Agency User')).substring(0, 15);
		cSettings.add(cSetting);

		ISSP_CS__c cSetting2 = new ISSP_CS__c();
		cSetting2.Name = 'Host';
		cSetting2.Value__c = 'portal.iata.org';
		cSettings.add(cSetting2);

		insert cSettings;

		Id rtHQ =  RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');

		Account MyAirline = new Account(
		RecordTypeId = rtHQ,
		Name='MyAirline',
		ACLI_Status__c = 'Active Company',
		MITA_Member__c = true,
		BIETA_Member__c = true,
		Airline_designator__c = 'AA',
		IATACode__c = '123',
		Airline_Prefix__c = '456');
		insert MyAirline;

		Contact newCon = ISSP_ObjectFactory.createNewContact();
		newCon.AccountId = MyAirline.Id;
		newCon.Email='testemail1@csp.testclass';
		newCon.User_Portal_Status__c = 'Approved Admin';
		insert newCon;
	}

	@isTest
	public static void PortalServicesCtrlTest_getAccessGrantedServices() {
		Contact c = [select id,email,firstname,lastname,name from contact where lastName = 'ContactTest2'];
		User portalUser = ISSP_ObjectFactory.createPortalUser(c);

		ISSPServiceListView__c cslv = new ISSPServiceListView__c();
		cslv.Name = 'Available services';
		cslv.Profiles_Id__c = String.valueOf(portalUser.profileId).substring(0,15);
		cslv.Field_Set_API_Name__c = 'ISSP_Available_services';
		cslv.SOQL_Filter__c = 'WHERE Name != \'12345\' ';
		insert cslv;

		System.runAs(portalUser) {
			Test.StartTest();
			List<PortalServicesCtrl.ServiceWrapper> lstResults = PortalServicesCtrl.getUserAccessGrantedServices();
			System.assertEquals(lstResults.size() > 0, true);
			Test.StopTest();
		}
	}

	@isTest
	public static void PortalServicesCtrlTest_getAccessRequestedServices() {
		Contact c = [select id,email,firstname,lastname,name from contact where lastName = 'ContactTest3'];
		User portalUser = ISSP_ObjectFactory.createPortalUser(c);
		System.runAs(portalUser) {
			Test.StartTest();
			List<PortalServicesCtrl.ServiceWrapper> lstResults = PortalServicesCtrl.getUserAccessRequestedServices();
			System.assertEquals(lstResults.size() > 0, true);
			Test.StopTest();
		}
	}

	@isTest
	public static void PortalServicesCtrlTest_getUserServicesList() {
		Contact c = [select id,email,firstname,lastname,name from contact where lastName = 'ContactTest'];
		User portalUser = ISSP_ObjectFactory.createPortalUser(c);
		System.runAs(portalUser) {
			Test.StartTest();
			PortalSearchFilterWrapper psfwrapper= new PortalSearchFilterWrapper();
			psfwrapper.searchText = '' + ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_MSTS;
			CSP_Utils.PagedResult results = PortalServicesCtrl.getUserFilteredServices(JSON.serialize(psfwrapper), '0');
			System.assertEquals(results.totalItemCount == 1, true);
			Test.StopTest();
		}
	}

	@isTest
	public static void PortalServicesCtrlTest_getFavoriteServicesList() {
		Contact c = [select id,email,firstname,lastname,name from contact where lastName = 'ContactTest'];
		User portalUser = ISSP_ObjectFactory.createPortalUser(c);
		System.runAs(portalUser) {
			Test.StartTest();
			List<Portal_Application_Right__c> lstResults = PortalServicesCtrl.getFavoriteServicesList();
			System.assertEquals(lstResults.size() > 0, true);
			Test.StopTest();
		}
	}

	@isTest
	public static void PortalServicesCtrlTest_getFavoriteServicesList_noRightsGiven() {
		Contact c = [select id,email,firstname,lastname,name from contact where lastName = 'ContactTest3'];
		User portalUser = ISSP_ObjectFactory.createPortalUser(c);
		System.runAs(portalUser) {
			Test.StartTest();
			List<Portal_Application_Right__c> lstResults = PortalServicesCtrl.getFavoriteServicesList();
			System.assertEquals(lstResults.size() >= 0, true);
			Test.StopTest();
		}
	}

	@isTest
	public static void PortalServicesCtrlTest_getServiceInformation() {
		Contact c = [select id,email,firstname,lastname,name from contact where lastName = 'ContactTest2'];
		User portalUser = ISSP_ObjectFactory.createPortalUser(c);
		System.runAs(portalUser) {
			Test.StartTest();
			list<Portal_Applications__c> portalServicelist=[select id from Portal_Applications__c where name ='serviceTest3'];
			PortalServicesCtrl.ServiceWrapper result = PortalServicesCtrl.getServiceDetails(portalServicelist.get(0).id);
			System.assertEquals(result.accessGranted, true);
			Test.StopTest();
		}
	}

	@isTest
	public static void PortalServicesCtrlTest_getServiceInfoForAdminWithoutAccess() {
		account acc=[select id from account where name='AccountTest2'];
		Contact c = new Contact (
			LastName = 'ContactTest34',
			FirstName = 'Name',
			accountId = acc.id,
			user_portal_status__c='Approved Admin',
			email='ContactTest444@portalservices.test'
		);
		insert c;
		User portalUser = ISSP_ObjectFactory.createPortalUser(c);
		System.runAs(portalUser) {
			Test.StartTest();
			list<Portal_Applications__c> portalServicelist=[select id from Portal_Applications__c where name ='serviceTest3'];
			PortalServicesCtrl.ServiceWrapper result = PortalServicesCtrl.getServiceDetails(portalServicelist.get(0).id);
			List<PortalServicesCtrl.ContactWrapper>  resultList = PortalServicesCtrl.getContactsAndStatusRelatedToServiceList(portalServicelist.get(0).id,0);
			Test.StopTest();
		}
	}

	@isTest
	public static void PortalServicesCtrlTest_getAccessGrantedServicesForContacts() {
		List<Contact> contacts = [SELECT Id,email,firstname,lastname from Contact WHERE LastName LIKE 'ContactTest%' LIMIT 3];
		List<Id> contactIds = new List<Id>();
		List<User> users = new List<User>();
		Map<Id, Contact> contactIdtoContact = new Map<Id, Contact>();
		Map<Id, List<PortalServicesCtrl.ServiceWrapper>> contactToServices = new Map<Id, List<PortalServicesCtrl.ServiceWrapper>>();

		if (!contacts.isEmpty()) {
			for (Contact c : contacts) {
				User portalUser = ISSP_ObjectFactory.createPortalUser(c);
				contactIds.add(c.Id);
				contactIdtoContact.put(c.Id, c);
			}
			users = DAL_ISSP.getUsersByContactId(contactIds);
			Map<Id, Id> contactToUser = new Map<Id, Id>();
			for (User u : users) {
				contactToUser.put(u.ContactId, u.Id);
			}
			contactToServices = PortalServicesCtrl.getContactsAccessGrantedServices(contactToUser, true);
			System.assert(!contactToServices.keySet().isEmpty());
		}
	}

	@isTest
	public static void PortalServicesCtrlTest_grantAccess() {
		Contact c = [select id from contact where lastName = 'ContactTest4'];
		list<Portal_Applications__c> portalServicelist=[select id from Portal_Applications__c where Name ='serviceTest4'];
		
		User adminUser = TestDataFactory_Users.createInternalSystemAdminUsers(1).get(0);
		insert adminUser;

		System.runAs(adminUser){
			Test.StartTest();
			Boolean isReq = PortalServicesCtrl.grantAccess(c.id, portalServicelist[0].id, 'Test');
			Test.StopTest();
		}
	}

	@isTest
	public static void PortalServicesCtrlTest_grantAccessToContactPendingApproval() {
		account  acc =[select id from account where name='AccountTest'];
		Contact newCon2 = new Contact(
			AccountId = acc.Id,
			FirstName = 'CSP',
			LastName = 'Tester',
			Email = System.today().dayOfYear() + 'testemail2@csp.testclass',
			User_Portal_Status__c = 'Pending Approval',
			Community__c='ISSP portal');
		insert newCon2;

		list<Portal_Applications__c> portalServicelist=[select id from Portal_Applications__c where Name ='serviceTest4'];

		Test.StartTest();
		portal_Application_Right__c appRight = new Portal_Application_Right__c(
			Portal_Application__c = portalServicelist[0].id,
			Right__c = 'Access Requested',
			Contact__c = newCon2.Id
		);
		insert appRight;
		Boolean isReq =PortalServicesCtrl.grantAccess(newCon2.id, portalServicelist[0].id, 'Test');
		Test.StopTest();
	}

	@isTest
	public static void PortalServicesCtrlTest_grantAccessToContactWithoutUser() {
		Account  acc =[select id from account where name='AccountTest'];
		Contact con = ISSP_ObjectFactory.createNewContact();
		con.FirstName = 'test';
		con.LastName = 'contact';
		con.AccountId= acc.Id;
		con.Email = 'test1@test.com';
		con.Preferred_Language__c = 'English';
		insert con;

		list<Portal_Applications__c> portalServicelist=[select id from Portal_Applications__c where Name ='serviceTest4'];

		User adminUser = TestDataFactory_Users.createInternalSystemAdminUsers(1).get(0);
		insert adminUser;

		Test.StartTest();
		System.runAs(adminUser){
			portal_Application_Right__c appRight = new Portal_Application_Right__c(
				Portal_Application__c = portalServicelist[0].id,
				Right__c = 'Access Requested',
				Contact__c = con.Id
			);
			insert appRight;
			PortalServicesCtrl.grantAccess(con.id, portalServicelist[0].id, 'Test');
		}
		Test.StopTest();
	}

	@isTest
	public static void PortalServicesCtrlTest_denyAccess() {
		Contact c = [select id from contact where lastName = 'ContactTest4'];
		c.Status__c='Active';
		update c;

		list<Portal_Applications__c> portalServicelist=[select id from Portal_Applications__c where Name ='serviceTest4'];

		Test.StartTest();
		Boolean isReq =PortalServicesCtrl.denyAccess(c.id, portalServicelist[0].id, 'Test',true);
		System.assertEquals(isReq,true);
		isReq =PortalServicesCtrl.denyAccess(c.id, portalServicelist[0].id, 'Test',false);
		System.assertEquals(isReq,true);
		Test.StopTest();
	}

	@isTest
	public static void PortalServicesCtrlTest_serviceWrapperRedirect() {
		Contact c = [select id,email,firstname,lastname,name from contact where lastName = 'ContactTest4'];
		User portalUser = ISSP_ObjectFactory.createPortalUser(c);
		list<Portal_Applications__c> portalServicelist=[select id from Portal_Applications__c where Name ='serviceTest4'];

		System.runAs(portalUser) {
			Test.StartTest();
			String redirect = PortalServicesCtrl.serviceWrapperRedirect(portalServicelist[0].id);
			Test.StopTest();
		}
	}

	@isTest
	public static void PortalServicesCtrlTest_getContactsAndStatusRelatedToServiceList() {
		Contact c = [select id,email,firstname,lastname,name from contact where lastName = 'ContactTest4'];
		User portalUser = ISSP_ObjectFactory.createPortalUser(c);
		list<Portal_Applications__c> portalServicelist=[select id from Portal_Applications__c where Name ='serviceTest4'];
		System.runAs(portalUser) {
			Test.StartTest();
			List<PortalServicesCtrl.ContactWrapper> cw = PortalServicesCtrl.getContactsAndStatusRelatedToServiceList(portalServicelist[0].id,3);
			List<PortalServicesCtrl.ContactWrapper> cw2 = PortalServicesCtrl.searchContactsInService(portalServicelist[0].id,'serv','','','');
			List<PortalServicesCtrl.ContactWrapper> cw3 = PortalServicesCtrl.searchContactsInService(portalServicelist[0].id,'serv','test','test','test');
			List<PortalServicesCtrl.ContactWrapper> cw4 = PortalServicesCtrl.searchContactsInService(portalServicelist[0].id,'serv','test','','');
			List<PortalServicesCtrl.ServiceWrapper> sw3 = PortalServicesCtrl.getUserAvailableServices();
			Test.StopTest();
		}
	}

	@isTest
	public static void PortalServicesCtrlTest_paymentLinkRedirect() {
		Contact c = [select id,email,firstname,lastname,name from contact where lastName = 'ContactTest4'];
		User portalUser = ISSP_ObjectFactory.createPortalUser(c);
		list<Portal_Applications__c> portalServicelist=[select id from Portal_Applications__c where Name ='serviceTest4'];

		Test.StartTest();
			PortalServicesCtrl.updateLastModifiedService(portalServicelist.get(0).id);
			Map<String,String> userOptions = new Map<String,String>();
			System.runAs(portalUser) {

				String paymentLink = PortalServicesCtrl.paymentLinkRedirect();
				Integer userProvisioningRequests = PortalServicesCtrl.userProvisioningRequests();
				userOptions = PortalServicesCtrl.getUserOptions(portalUser.id);
				List<Connected_App_Roles__c> cap = PortalServicesCtrl.availableIEPPortalServiceRoles(portalUser.id);
				List<Connected_App_Roles__c> cap2 = PortalServicesCtrl.availableICCSPortalServiceRoles();

			}
		Test.StopTest();
	}

	@isTest
	public static void PortalServicesCtrlTest_requestAccess() {
		Contact c = [select id,email,firstname,lastname,name from contact where lastName = 'ContactTest4'];
		User portalUser = ISSP_ObjectFactory.createPortalUser(c);
		List<String> lstString = new List<String>();
		lstString.add(c.id);
		List<Contact> contList = new List<Contact>();
		List<PortalServicesCtrl.ServiceWrapper> paList = new List<PortalServicesCtrl.ServiceWrapper>();
		Test.StartTest();
			list<Portal_Applications__c> portalServicelist=[select id from Portal_Applications__c where Name in ('serviceTest3','serviceTest2','Insurance Providers')];

			//requestAccessToICCS
			PortalServicesCtrl.newAppsRequestICCS(portalServicelist.get(1).id, '', c.id);

			PortalServicesCtrl.newAppsRequest2(portalServicelist.get(2).id, '', c.id, '', false);
		Test.StopTest();
	}

	@isTest
	public static void PortalServicesCtrlTest_getTotalNrContacts() {
		Contact c = [select id,email,firstname,lastname,name from contact where lastName = 'ContactTest4'];
		User portalUser = ISSP_ObjectFactory.createPortalUser(c);

		PortalApplicationRight_Sel pars = new PortalApplicationRight_Sel();
		System.runAs(portalUser) {
			Test.StartTest();
			list<Portal_Applications__c> portalServicelist=[select id from Portal_Applications__c where Name ='serviceTest3'];
			Integer paList = pars.getTotalNrContacts(portalServicelist.get(0).id);
			Test.StopTest();
		}
	}

	@isTest
	public static void PortalServicesCtrlTest_grantAccessToContacts() {
		Contact c = [select id,email,firstname,lastname,name from contact where lastName = 'ContactTest4'];
		List<String> lstString = new List<String>();
		lstString.add(c.id);
		Test.StartTest();
		list<Portal_Applications__c> portalServicelist=[select id from Portal_Applications__c where Name ='serviceTest3'];
		PortalServicesCtrl.grantAccessToContacts(lstString, portalServicelist.get(0).id);
		Test.StopTest();
	}

	@isTest
	public static void PortalServicesCtrlTest_getContactsForServiceAssignment() {
		Contact c = [select id,email,firstname,lastname,name from contact where lastName = 'ContactTest4'];
		User portalUser = ISSP_ObjectFactory.createPortalUser(c);
		list<PortalLookupSearchResult> plsr = new List<PortalLookupSearchResult>();
		System.runAs(portalUser) {
			Test.StartTest();
			list<Portal_Applications__c> portalServicelist=[select id from Portal_Applications__c where Name ='serviceTest4'];
			PortalServicesCtrl.newUserRequestableWithoutApproval(ISSP_Constant.adminIdSet.contains(UserInfo.getProfileId()),portalServicelist.get(0).id);
			plsr = PortalServicesCtrl.getContactsForServiceAssignment(portalServicelist.get(0).id, '');
			Test.StopTest();
		}
	}

	@isTest
	public static void PortalServicesCtrlTest_getContactsForServiceAssignment2() {
		Contact c = [select id,email,firstname,lastname,name from contact where lastName = 'ContactTest4'];
		User portalUser = ISSP_ObjectFactory.createPortalUser(c);
		list<PortalLookupSearchResult> plsr = new List<PortalLookupSearchResult>();
		System.runAs(portalUser) {
			Test.StartTest();
			list<Portal_Applications__c> portalServicelist=[select id from Portal_Applications__c where Name ='serviceTest4'];
			PortalServicesCtrl.newUserRequestableWithoutApproval(ISSP_Constant.adminIdSet.contains(UserInfo.getProfileId()),portalServicelist.get(0).id);
			plsr = PortalServicesCtrl.getContactsForServiceAssignment(portalServicelist.get(0).id, c.lastName);
			Test.StopTest();
		}
	}

	@isTest
	public static void PortalServicesCtrlTest_testCanAddUsers(){
		Contact c = [select id,email,firstname,lastname,name from contact where lastName = 'ContactTest4'];
		User portalUser = ISSP_ObjectFactory.createPortalUser(c);

		System.runAs(portalUser) {
			list<Portal_Applications__c> portalServicelist=[select id from Portal_Applications__c where Name ='serviceTest3'];
			PortalServicesCtrl.newUserRequestableWithoutApproval(ISSP_Constant.adminIdSet.contains(UserInfo.getProfileId()),portalServicelist.get(0).id);
		}
	}

	@isTest
	public static void PortalServicesCtrlTest_ActivateIEPUsers(){
		Contact c = [select id,email,firstname,lastname,name from contact where lastName = 'ContactTest3'];

		List<String> contactIds = new List<String>();
		contactIds.add(c.id);
		User portalUser = ISSP_ObjectFactory.createPortalUser(c);

		System.runAs(portalUser) {
			PortalServicesCtrl.ActivateIEPUsers(contactIds);
		}
	}

	@isTest
	public static void PortalServicesCtrlTest_ActivateIEPUsers2(){
		Account acc =[select id from account where name='AccountTest'];
		Contact newCon2 = new Contact(
			AccountId = acc.Id,
			FirstName = 'CSP',
			LastName = 'Tester',
			Email = System.today().dayOfYear() + 'testemail2@csp.testclass',
			User_Portal_Status__c = 'Pending Approval',
			Community__c='ISSP portal');
		insert newCon2;

		List<String> contactIds = new List<String>();
		contactIds.add(newCon2.id);

		PortalServicesCtrl.ActivateIEPUsers(contactIds);
	}

	@isTest
	public static void PortalServicesCtrlTest_CreateNewPortalAccess(){
		Contact c = [select id,email,firstname,lastname,name from contact where lastName = 'ContactTest4'];
		list<Portal_Applications__c> portalServicelist=[select id from Portal_Applications__c where Name ='serviceTest3'];
		String PortalServiceRole = '';
		List<String> contactIds = new List<String>();
		contactIds.add(c.id);
		User portalUser = ISSP_ObjectFactory.createPortalUser(c);
		Test.startTest();
			PortalServicesCtrl.CreateNewPortalAccess(contactIds, portalServicelist[0].id, PortalServiceRole);
		Test.stopTest();
	}

	@IsTest static void testPortalGlobalSearch() {
		Contact contact = [SELECT Id, Email, LastName FROM Contact WHERE Email = 'ContactTest@portalservices.test' LIMIT 1];
		User testUser = TestDataFactory_Users.createPortalUsers(new List<Contact>{contact}).get(0);
		insert testUser;

		Test.startTest();
		System.runAs(testUser) {
			CSP_Utils.PagedResult test = new CSP_Utils.PagedResult();
			PortalSearchFilterWrapper.servicesComponent servCmp = new PortalSearchFilterWrapper.servicesComponent();
			servCmp.show = true;
			PortalSearchFilterWrapper filtersWrapper = new PortalSearchFilterWrapper();
			filtersWrapper.searchText = 'Test';
			filtersWrapper.servicesComponent = servCmp;
			test = PortalGlobalSearchCtrl.portalGlobalSearch(JSON.serialize(filtersWrapper), 'Services');
		}
		Test.stopTest();
	}

	@isTest
	public static void PortalServicesCtrlTest_getAvailableServicesForNewContact(){
		Contact c = [select id,email,firstname,lastname,name from contact where lastName = 'ContactTest'];
		User portalUser = ISSP_ObjectFactory.createPortalUser(c);
		List<Portal_Applications__c> services = new List<Portal_Applications__c>();
		System.runAs(portalUser) {
			Test.StartTest();
			services =  PortalServicesCtrl.getAvailableServicesForNewContact();
			Test.StopTest();
		}

		for(Portal_Applications__c service : services){
			if(service.Cannot_be_managed_by_portal_admin__c){
				System.assert(false);
			}
		}
		System.assert(true);
	}

	@isTest
	public static void PortalServicesCtrlTest_MassActions() {
		Contact c = [select id from contact where lastName = 'ContactTest4'];
		list<Portal_Applications__c> portalServicelist=[select id from Portal_Applications__c where Name ='serviceTest3'];

		Portal_Application_Right__c appRight = new Portal_Application_Right__c(
			Portal_Application__c = portalServicelist.get(0).id,
			Right__c = 'Access Requested',
			Contact__c = c.Id
			);

		insert appRight;

		Test.StartTest();
		c.User_Portal_Status__c = 'Pending Approval';
		c.Community__c = 'ISS Portal';
		update c;

		// Grant access to service
		Boolean isSuccessGrant =PortalServicesCtrl.massGrantAccess(new list<string>{c.id}, portalServicelist[0].id, 'Test');
		system.assertEquals(isSuccessGrant,true);
		system.assertEquals('Access Granted',[select Right__c from Portal_Application_Right__c where id=:appRight.id ].Right__c);

		boolean isSuccessDeny =PortalServicesCtrl.massDenyAccess(new list<string>{c.id}, portalServicelist[0].id, 'Test');
		system.assertEquals(isSuccessDeny,true);
		system.assertEquals('Access Denied',[select Right__c from Portal_Application_Right__c where id=:appRight.id ].Right__c);
	
		Boolean isSuccessGrantAgain =PortalServicesCtrl.massGrantAccess(new list<string>{c.id}, portalServicelist[0].id, 'Test');
		system.assertEquals(isSuccessGrantAgain,true);
		system.assertEquals('Access Granted',[select Right__c from Portal_Application_Right__c where id=:appRight.id ].Right__c);
		Test.StopTest();
	}

	//WMO-736 - ACAMBAS: Begin
	@isTest
	public static void getPortalServiceDetailsTest() {
		Contact c = [select id,email,firstname,lastname,name from contact where lastName = 'ContactTest2'];
		User portalUser = ISSP_ObjectFactory.createPortalUser(c);

		System.runAs(portalUser) {
			PortalServicesCtrl.getPortalServiceDetails('serviceTest');
		}
	}
	//WMO-736 - ACAMBAS: End

	@isTest
	public static void PortalServicesCtrlTest_verifyL3DataNegative() {
		Contact c = [select id,email,firstname,lastname,name from contact where lastName = 'ContactTest4'];
		User portalUser = ISSP_ObjectFactory.createPortalUser(c);
		List<Portal_Applications__c> portalServicelist=[select id from Portal_Applications__c where Name ='serviceTest3'];
		Term_and_Condition__c tos = new Term_and_Condition__c(NewGenApp_PortalService__c = portalServicelist.get(0).id, Is_Latest__c = true, Status__c = 'Final', Effective_Start_Date__c = Date.today());
		insert tos;
		Term_and_Condition_Acceptance__c tosAccept = new Term_and_Condition_Acceptance__c(Is_Accepted__c = true, Term_Condition__c = tos.Id, Contact__c = c.Id);
		insert tosAccept;

		System.runAs(portalUser) {
			Test.StartTest();
			String result = PortalServicesCtrl.verifyCompleteL3Data(portalServicelist.get(0).id);
			String id = ServiceTermsAndConditionsUtils.getPortalServiceId('serviceTest3');
			system.assert(portalServicelist.get(0).id == id);
			Test.StopTest();
		}
	}
	@isTest
	public static void PortalServicesCtrlTest_verifyL3DataPositive() {
		Contact c = [select id,email,firstname,lastname,name, accountId from contact where lastName = 'ContactTest5'];
		Account_Role__c accRole = new Account_Role__c(Account__c = c.accountId);
		insert accRole;

		Id accContactRole_RT = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Master');
		Account_Contact_Role__c acr = new Account_Contact_Role__c(Account_Role__c = accRole.Id, Contact__c = c.Id, Service_Rendered__c = 'Other', RecordTypeId = accContactRole_RT);
		insert acr;

		String RECTYPE_Trainee_YASContDet = RecordTypeSingleton.getInstance().getRecordTypeId('Training_Contact_Role_Details__c', 'Yardstick_Trainee');
		Training_Contact_Role_Details__c tcrd = new Training_Contact_Role_Details__c(Account_Contact_Role__c = acr.Id, RecordTypeId = RECTYPE_Trainee_YASContDet);
		insert tcrd;

		User portalUser = ISSP_ObjectFactory.createPortalUser(c);

		List<Portal_Applications__c> portalServicelist=[select id from Portal_Applications__c where Name ='serviceTest3'];
		Term_and_Condition__c tos = new Term_and_Condition__c(NewGenApp_PortalService__c = portalServicelist.get(0).id, Is_Latest__c = true, Status__c = 'Final', Effective_Start_Date__c = Date.today());
		insert tos;
		Term_and_Condition_Acceptance__c tosAccept = new Term_and_Condition_Acceptance__c(Is_Accepted__c = true, Term_Condition__c = tos.Id, Contact__c = c.Id);
		insert tosAccept;

		System.runAs(portalUser) {
			Test.StartTest();
			String result = PortalServicesCtrl.verifyCompleteL3Data(portalServicelist.get(0).id);
			String id = ServiceTermsAndConditionsUtils.getPortalServiceId('serviceTest3');
			system.assert(portalServicelist.get(0).id == id);
			Test.StopTest();
		}
	}

	@isTest
	public static void getPortalServiceDetailsEFTest() {
		Contact c = [select id,email,firstname,lastname,name from contact where lastName = 'ContactTest4'];
		User portalUser = ISSP_ObjectFactory.createPortalUser(c);

		System.runAs(portalUser) {
			PortalServicesCtrl.getPortalServiceDetails('E&F APPS');
		}
	}
}