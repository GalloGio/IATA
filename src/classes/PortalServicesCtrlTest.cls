@isTest
public class PortalServicesCtrlTest {

	@testSetup
	static void setup() {

		Portal_Applications__c easyPay1 = new Portal_Applications__c (
			Name = ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_EDENRED,
			ANG_Restrict_by_Agency_Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
			ANG_Accredited_Agents_Only__c = false,
			Agency__c = true
		);

		Portal_Applications__c easyPay2 = new Portal_Applications__c (
			Name = ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_MSTS,
			ANG_Restrict_by_Agency_Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
			ANG_Accredited_Agents_Only__c = false,
			Agency__c = true
		);

		Portal_Applications__c easyPay3 = new Portal_Applications__c (
			Name = ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_WEX,
			ANG_Restrict_by_Agency_Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
			ANG_Accredited_Agents_Only__c = true,
			Agency__c = true
		);

		Portal_Applications__c serviceTest = new Portal_Applications__c (
			Name = 'serviceTest',
			ANG_Restrict_by_Agency_Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
			ANG_Accredited_Agents_Only__c = false,
			Agency__c = true
		);

		Portal_Applications__c serviceTest2 = new Portal_Applications__c (
			Name = 'serviceTest2',
			ANG_Restrict_by_Agency_Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
			ANG_Accredited_Agents_Only__c = false,
			Agency__c = true
		);

		Portal_Applications__c serviceTest3 = new Portal_Applications__c (
			Name = 'serviceTest3',
			requestable__c=true,
			Agency__c = true,
			Hide_on_Homepage__c=false
		);

		Portal_Applications__c serviceTest4 = new Portal_Applications__c (
			Name = 'serviceTest4',
			requestable__c=true,
			Agency__c = true
		);

		Portal_Applications__c serviceTest5 = new Portal_Applications__c (
			Name = 'Insurance Providers',
			requestable__c=false,
			Agency__c = true
		);
		Portal_Applications__c serviceTest6 = new Portal_Applications__c (
			Name = 'Financial Securities',
			Requestable__c = false
		);
	Portal_Applications__c serviceTest7 = new Portal_Applications__c (
		Name = 'Treasury Dashboard - Premium',
		Requestable__c = false
		);

	insert new List<Portal_Applications__c> {easyPay1,easyPay2,easyPay3,serviceTest,serviceTest2,serviceTest3,serviceTest4,serviceTest5,serviceTest6,serviceTest7};

	IATA_ISO_Country__c portugal = new IATA_ISO_Country__c (
		Name = 'Portugal_test',
		ISO_Code__c = 'PT',
		ANG_Portal_Service__c = easyPay1.id,
		ANG_Enable_NewGen__c = true
		);


	IATA_ISO_Country__c switzerland = new IATA_ISO_Country__c (
		Name = 'Switzerland_test',
		ISO_Code__c = 'CH',
		ANG_Portal_Service__c = easyPay2.id,
		ANG_Enable_NewGen__c = true
		);


	IATA_ISO_Country__c germany = new IATA_ISO_Country__c (
		Name = 'Germany_test',
		ISO_Code__c = 'DH',
		ANG_Portal_Service__c = easyPay3.id
		);

	IATA_ISO_Country__c spain = new IATA_ISO_Country__c (
		Name = 'Spain_test',
		ISO_Code__c = 'SP'
		);

	insert new List<IATA_ISO_Country__c> {portugal,switzerland,germany,spain};


		Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
		Account a = new Account (
			name = 'AccountTest',
			IATA_ISO_Country__c = portugal.id,
			Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
			ANG_IEP_Status__c = ANG_ISSP_PortalServiceHelper.STATUS_OPEN,
			Location_type__c = 'HE',
			OwnerId = UserInfo.getUserId(),
			Location_Class__c = 'P',
			recordtypeId=rtId
		);

		Account a2 = new Account (
			name = 'AccountTest2',
			IATA_ISO_Country__c = switzerland.id,
			Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
			ANG_IEP_Status__c = ANG_ISSP_PortalServiceHelper.STATUS_NO_IEP_ACCOUNT,
			Location_type__c = 'HE',
			OwnerId = UserInfo.getUserId(),
			Location_Class__c = 'P',
			recordtypeId=rtId
		);

		Account a3 = new Account (
			name = 'AccountTest3',
			IATA_ISO_Country__c = germany.id,
			Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
			ANG_IEP_Status__c = ANG_ISSP_PortalServiceHelper.STATUS_IN_PROGRESS,
			Location_type__c = 'AO',
			OwnerId = UserInfo.getUserId()
		);

		Account a4 = new Account (
			name = 'AccountTest4',
			IATA_ISO_Country__c = spain.id,
			Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
			ANG_IEP_Status__c = ANG_ISSP_PortalServiceHelper.STATUS_NO_IEP_ACCOUNT,
			Location_type__c = 'HO',
			OwnerId = UserInfo.getUserId()
		);

		insert new List<Account>{a,a2,a3,a4};

			Contact c = new Contact (
				LastName = 'ContactTest',
				FirstName = 'Name',
				accountID = a.id,
				email='ContactTest@portalservices.test',
				user_portal_status__c='Approved Admin'
			);

		Contact c2 = new Contact (
			LastName = 'ContactTest2',
			FirstName = 'Name',
			accountId = a2.id,
			email='ContactTest2@portalservices.test',
			user_portal_status__c='Approved Admin'
		);

		Contact c3 = new Contact (
			LastName = 'ContactTest3',
			FirstName = 'Name',
			accountId = a3.id,
			email='ContactTest3@portalservices.test',
			user_portal_status__c='Approved Admin'
		);

		Contact c4 = new Contact (
			LastName = 'ContactTest4',
			FirstName = 'Name',
			accountId = a4.id,
			email='ContactTest4@portalservices.test',
			user_portal_status__c='Approved Admin'
		);

		Contact c5 = new Contact (
			LastName = 'ContactTest5',
			FirstName = 'Name',
			accountId = a4.id,
			Birthdate = Date.today(),
			email='ContactTest4@portalservices.test',
			user_portal_status__c='Approved Admin'
		);

		Contact c21 = new Contact (
			LastName = 'ContactTest2.1',
			FirstName = 'Name',
			accountId = a2.id,
			email='ContactTest2.1@portalservices.test',
			user_portal_status__c='Approved Admin'
		);

		insert new List<Contact>{c,c2,c3,c4,c5,c21};

			Portal_Application_Right__c appRight = new Portal_Application_Right__c(
				Portal_Application__c = easyPay1.id,
				Right__c = 'Access Granted',
				Contact__c = c.Id
			);

		Portal_Application_Right__c appRight2 = new Portal_Application_Right__c(
			Portal_Application__c = easyPay2.id,
			Right__c = 'Access Granted',
			Contact__c = c2.Id
		);

		Portal_Application_Right__c appRight3 = new Portal_Application_Right__c(
			Portal_Application__c = easyPay3.id,
			Right__c = 'Access Requested',
			Contact__c = c3.Id
		);

	Portal_Application_Right__c appRight4 = new Portal_Application_Right__c(
		Portal_Application__c = serviceTest3.id,
		Right__c = 'Access Granted',
		Contact__c = c2.Id
		);

	Portal_Application_Right__c appRight5 = new Portal_Application_Right__c(
		Portal_Application__c = serviceTest4.id,
		Right__c = 'Access Requested',
		Contact__c = c4.Id
		);
	Portal_Application_Right__c appRight6 = new Portal_Application_Right__c(
		Portal_Application__c = serviceTest3.id,
		Right__c = 'Access Granted',
		Contact__c = c21.Id
		);
	Portal_Application_Right__c appRight7 = new Portal_Application_Right__c(
		Portal_Application__c = serviceTest7.id,
		Right__c = 'Access Granted',
		Contact__c = c4.Id
		);

	Portal_Application_Right__c appRight8 = new Portal_Application_Right__c(
		Portal_Application__c = serviceTest3.id,
		Right__c = 'Access Granted',
		Contact__c = c5.Id
		);

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

		User newUser = ISSP_ObjectFactory.createPortalUser(newCon);
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
	public static void PortalServicesCtrlTest_goToOldPortalService() {
		Test.StartTest();

		PortalServicesCtrl.goToOldPortalService('');

		Test.StopTest();

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

		Test.StartTest();
		Boolean isReq =PortalServicesCtrl.grantAccess(c.id, portalServicelist[0].id, 'Test');
		Test.StopTest();
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

		Test.StartTest();
		
		Account  acc =[select id from account where name='AccountTest'];

		Contact con = ISSP_ObjectFactory.createNewContact();
		con.FirstName = 'test';
		con.LastName = 'contact';
		con.AccountId= acc.Id;
		con.Email = 'test1@test.com';
		con.Preferred_Language__c = 'English';
		insert con;

		list<Portal_Applications__c> portalServicelist=[select id from Portal_Applications__c where Name ='serviceTest4'];


		portal_Application_Right__c appRight = new Portal_Application_Right__c(
				Portal_Application__c = portalServicelist[0].id,
				Right__c = 'Access Requested',
				Contact__c = con.Id
			);

		insert appRight;
		
		Boolean isReq =PortalServicesCtrl.grantAccess(con.id, portalServicelist[0].id, 'Test');
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
			String redirect  =PortalServicesCtrl.serviceWrapperRedirect(portalServicelist[0].id);
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

	String test = PortalServicesCtrl.CreateNewPortalAccess(contactIds, portalServicelist[0].id, PortalServiceRole);
}

@IsTest static void testPortalGlobalSearch() {

	User testUser = [SELECT Id FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];

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
			// Grant access to service
			Boolean isSuccessGrant =PortalServicesCtrl.massGrantAccess(new list<string>{c.id}, portalServicelist[0].id, 'Test');
			system.assertEquals(isSuccessGrant,true);
			system.assertEquals('Access Granted',[select Right__c from Portal_Application_Right__c where id=:appRight.id ].Right__c);

			boolean isSuccessDeny =PortalServicesCtrl.massDenyAccess(new list<string>{c.id}, portalServicelist[0].id, 'Test');
			system.assertEquals(isSuccessDeny,true);
			system.assertEquals('Access Denied',[select Right__c from Portal_Application_Right__c where id=:appRight.id ].Right__c);
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

			String id = PortalServicesCtrl.getPortalServiceId('serviceTest3');
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

			String id = PortalServicesCtrl.getPortalServiceId('serviceTest3');
			system.assert(portalServicelist.get(0).id == id);
			Test.StopTest();
		}
	}
	
}

