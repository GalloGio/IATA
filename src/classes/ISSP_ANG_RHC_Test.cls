@isTest
public class ISSP_ANG_RHC_Test {

	@testSetup
	static void setup() {
		insert new ISSP_CS__c(
			Name = ANG_ISSP_AfpWrapper.AVAILABLE_SERVICES_OLD_PATH_CS_NAME, 
			value__c = '/ISSP_AvailableServices?MainNav=Services&subNav=Access&mid=M3S1',
			defaultValue__c = '/ISSP_AvailableServices?MainNav=Services&subNav=Access&mid=M3S1'
		);
	}

	public static testMethod void test1() {
		List<Portal_Applications__c> portalApplicationsList = TestDataFactory_PortalApplications.createDefaultPortalApplication(2);
		Portal_Applications__c s1 = portalApplicationsList.get(0);
		s1.Name = ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_EDENRED;
		s1.ANG_Restrict_by_Agency_Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT;
		s1.ANG_Accredited_Agents_Only__c = false;
		s1.Agency__c = true;

		Portal_Applications__c s2 = portalApplicationsList.get(1);
		s2.Name = ISSP_ANG_RHC.ICE_SERVICE;
		s2.ANG_Restrict_by_Agency_Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT;
		s2.ANG_Accredited_Agents_Only__c = false;
		s2.Agency__c = true;

		insert portalApplicationsList;

		IATA_ISO_Country__c portugal = new IATA_ISO_Country__c (
				Name = 'Portugal_test',
				ISO_Code__c = 'PT',
				ANG_Portal_Service__c = s1.id,
				ANG_Enable_NewGen__c = true
			);

		insert new List<IATA_ISO_Country__c>{portugal};

		Account a = new Account (
				name = 'AccountTest',
				IATA_ISO_Country__c = portugal.id,
				Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
				ANG_IEP_Status__c = ANG_ISSP_PortalServiceHelper.STATUS_OPEN,
				Location_type__c = 'HE',
				IATACode__c = '1234567890',
				ANG_Accreditation_Model__c = 'Cash',
				Status__c = 'Approved',
				OwnerId = UserInfo.getUserId(),
				Location_Class__c = 'P'
			);

		insert new List<Account>{a};

		Contact c = new Contact (
				firstName = 'firstname',
				LastName = 'ContactTest',
				accountID = a.id
			);

		insert new List<Contact>{c};

		Portal_Application_Right__c appRight = new Portal_Application_Right__c(
				Portal_Application__c = s1.id,
				Right__c = 'Access Granted',
				Contact__c = c.Id
			);

		Portal_Application_Right__c appRight2 = new Portal_Application_Right__c(
				Portal_Application__c = s2.id,
				Right__c = 'Access Granted',
				Contact__c = c.Id
			);

		insert new List<Portal_Application_Right__c>{appRight,appRight2};

		Agency_Authorization__c aa = new Agency_Authorization__c (
				ANG_FormOfPayment_ID__c = 'CC',
				Account__c = a.id,
				Status__c = 'Active'
			);

		ANG_Risk_Event_Type__c t = new ANG_Risk_Event_Type__c(
			ANG_Description__c = 'Active event 2',
			ANG_Expiration__c = 1233,
			ANG_Risk_ID__c = '4234381'
			);

		insert t;

		ANG_Agency_Risk_Event__c e = new ANG_Agency_Risk_Event__c(
			ANG_Risk_Type__c = t.id,
			ANG_HE_AccountId__c = a.id,
			ANG_Issued_Date__c = Date.today(),
			ANG_Event_Status__c = 'Active',
			ANG_AccountId__c = a.id,
			ANG_Expired__c = false,
			ANG_Created_from__c = 'bla bla'
		);

		insert e;

		insert new List<Agency_Authorization__c>{aa};

		Profile p = [SELECT Id FROM Profile WHERE Name='ISS Portal'];

		User testeUser1 = new User (
				Alias = 'newUser',
				Email='newuser@testorg.com',
				EmailEncodingKey='UTF-8',
				LastName='Testing1',
				LanguageLocaleKey='en_US',
				ContactId = c.id,
				LocaleSidKey='en_US',
				ProfileId = p.Id,
				TimeZoneSidKey='America/Los_Angeles',
				UserName='newuser@testorg.com',
				Mgmt_Report_Team__c = true
			);

		System.runAs(testeUser1) {
			ISSP_ANG_RHC cont = new ISSP_ANG_RHC();

			cont.getRiskEventList();

			Boolean b = cont.hasRightAccessIceService;

			cont.refreshRiskEventsTable();

			cont.riskStatusFilter = 'Expired';

			cont.getRiskEventList();

			cont.riskStatusFilter = 'Inactive';

			cont.getRiskEventList();

			cont.riskStatusFilter = 'All';

			cont.getRiskEventList();
		}
	}

	public static testMethod void test2() {
		List<Portal_Applications__c> portalApplicationsList = TestDataFactory_PortalApplications.createDefaultPortalApplication(2);
		Portal_Applications__c s1 = portalApplicationsList.get(0);
		s1.Name = ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_EDENRED;
		s1.ANG_Restrict_by_Agency_Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT;
		s1.ANG_Accredited_Agents_Only__c = false;
		s1.Agency__c = true;

		Portal_Applications__c s2 = portalApplicationsList.get(1);
		s2.Name = ISSP_ANG_RHC.ICE_SERVICE;
		s2.ANG_Restrict_by_Agency_Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT;
		s2.ANG_Accredited_Agents_Only__c = false;
		s2.Agency__c = true;

		insert portalApplicationsList;

		IATA_ISO_Country__c portugal = new IATA_ISO_Country__c (
				Name = 'Portugal_test',
				ISO_Code__c = 'PT',
				ANG_Portal_Service__c = s1.id,
				ANG_Enable_NewGen__c = true
			);

		insert new List<IATA_ISO_Country__c>{portugal};

		Account a = new Account (
				name = 'AccountTest',
				IATA_ISO_Country__c = portugal.id,
				Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
				ANG_IEP_Status__c = ANG_ISSP_PortalServiceHelper.STATUS_NO_IEP_ACCOUNT,
				Location_type__c = 'HE',
				IATACode__c = '1234567890',
				ANG_Accreditation_Model__c = 'Cash',
				Status__c = 'Approved',
				OwnerId = UserInfo.getUserId(),
				Location_Class__c = 'P'
			);

		insert new List<Account>{a};


		System.debug('ANG_IEP_Status_FF__c--->' + a.ANG_IEP_Status_FF__c);

		Contact c = new Contact (
				firstName = 'firstname',
				LastName = 'ContactTest',
				accountID = a.id
			);

		insert new List<Contact>{c};

		Portal_Application_Right__c appRight = new Portal_Application_Right__c(
				Portal_Application__c = s1.id,
				Right__c = 'Access Granted',
				Contact__c = c.Id
			);

		Portal_Application_Right__c appRight2 = new Portal_Application_Right__c(
				Portal_Application__c = s2.id,
				Right__c = 'Access Granted',
				Contact__c = c.Id
			);

		insert new List<Portal_Application_Right__c>{appRight,appRight2};

		Agency_Authorization__c aa = new Agency_Authorization__c (
				ANG_FormOfPayment_ID__c = 'CA',
				Account__c = a.id,
				Status__c = 'Active'
			);

		ANG_Risk_Event_Type__c t = new ANG_Risk_Event_Type__c(
			ANG_Description__c = 'Active event 2',
			ANG_Expiration__c = 1233,
			ANG_Risk_ID__c = '4234381'
			);

		insert t;

		ANG_Agency_Risk_Event__c e = new ANG_Agency_Risk_Event__c(
			ANG_Risk_Type__c = t.id,
			ANG_HE_AccountId__c = a.id,
			ANG_Issued_Date__c = Date.today(),
			ANG_Event_Status__c = 'Active',
			ANG_AccountId__c = a.id,
			ANG_Expired__c = true,
			ANG_Created_from__c = 'bla bla'
		);

		insert e;

		insert new List<Agency_Authorization__c>{aa};

		Profile p = [SELECT Id FROM Profile WHERE Name='ISS Portal'];

		User testeUser1 = new User (
				Alias = 'newUser',
				Email='newuser@testorg.com',
				EmailEncodingKey='UTF-8',
				LastName='Testing1',
				LanguageLocaleKey='en_US',
				ContactId = c.id,
				LocaleSidKey='en_US',
				ProfileId = p.Id,
				TimeZoneSidKey='America/Los_Angeles',
				UserName='newuser@testorg.com',
				Mgmt_Report_Team__c = true
			);

		System.runAs(testeUser1) {
			ISSP_ANG_RHC cont = new ISSP_ANG_RHC();

			cont.getRiskEventList();

			Boolean b = cont.hasRightAccessIceService;

			cont.refreshRiskEventsTable();

			cont.riskStatusFilter = 'Expired';

			cont.getRiskEventList();

			cont.riskStatusFilter = 'Inactive';

			cont.getRiskEventList();

			cont.riskStatusFilter = 'All';

			cont.getRiskEventList();

			System.assertEquals(true, cont.afpWrapper.displayIcons);
			System.assertEquals(false, cont.afpWrapper.isBOPFlag);
			System.assertEquals(false, cont.afpWrapper.isInternational);
			System.assertEquals(false, cont.afpWrapper.isDomestic);
		}
	}

	public static testMethod void test3() {
		List<Portal_Applications__c> portalApplicationList = TestDataFactory_PortalApplications.createDefaultPortalApplication(2);
		Portal_Applications__c s1 = portalApplicationList.get(0);
		s1.Name = ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_EDENRED;
		s1.ANG_Restrict_by_Agency_Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT;
		s1.ANG_Accredited_Agents_Only__c = false;
		s1.Agency__c = true;

		Portal_Applications__c s2 = portalApplicationList.get(1);
		s2.Name = ISSP_ANG_RHC.ICE_SERVICE;
		s2.ANG_Restrict_by_Agency_Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT;
		s2.ANG_Accredited_Agents_Only__c = false;
		s2.Agency__c = true;

		insert portalApplicationList;

		IATA_ISO_Country__c indonesia = new IATA_ISO_Country__c (
				Name = 'Indonesia',
				ISO_Code__c = 'ID',
				ANG_Portal_Service__c = s1.id,
				ANG_Enable_NewGen__c = true
			);

		insert new List<IATA_ISO_Country__c>{indonesia};

		Account a = new Account (
				name = 'AccountTest',
				IATA_ISO_Country__c = indonesia.id,
				Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
				ANG_IEP_Status__c = ANG_ISSP_PortalServiceHelper.STATUS_OPEN,
				Location_type__c = 'HE',
				IATACode__c = '1234567890',
				ANG_Accreditation_Model__c = 'Cashless',
				Status__c = 'Approved',
				OwnerId = UserInfo.getUserId(),
				Financial_Review_Result__c = 'Unsatisfactory',
				Location_Class__c = 'P',
				Category__c = AMS_Utils.CATEGORY_PASSENGER_SALES_AGENT
			);

		insert new List<Account>{a};

		Contact c = new Contact (
				firstName = 'firstname',
				LastName = 'ContactTest',
				accountID = a.id,
				Authorized_Signatory__c = true
			);

		insert new List<Contact>{c};

		Portal_Application_Right__c appRight = new Portal_Application_Right__c(
				Portal_Application__c = s1.id,
				Right__c = 'Access Requested',
				Contact__c = c.Id
			);

		Portal_Application_Right__c appRight2 = new Portal_Application_Right__c(
				Portal_Application__c = s2.id,
				Right__c = 'Access Requested',
				Contact__c = c.Id
			);

		insert new List<Portal_Application_Right__c>{appRight,appRight2};

		Agency_Authorization__c aa = new Agency_Authorization__c (
				ANG_FormOfPayment_ID__c = 'CC',
				Account__c = a.id,
				Status__c = 'Active'
			);

		insert new List<Agency_Authorization__c>{aa};

		Case ca = new Case(

		);
		insert ca;

		ANG_Risk_Event_Type__c t = new ANG_Risk_Event_Type__c(
			ANG_Description__c = 'Active event 2',
			ANG_Expiration__c = 1233,
			ANG_Risk_ID__c = '4234381'
			);

		insert t;

		ANG_Agency_Risk_Event__c e = new ANG_Agency_Risk_Event__c(
			ANG_Risk_Type__c = t.id,
			ANG_HE_AccountId__c = a.id,
			ANG_Issued_Date__c = Date.today(),
			ANG_Event_Status__c = 'Inactive_Withdrawn',
			ANG_AccountId__c = a.id,
			ANG_Expired__c = false,
			ANG_Created_from__c = 'bla bla',
			ANG_CaseId__c = ca.id
		);

		insert e;

		Profile p = [SELECT Id FROM Profile WHERE Name='ISS Portal'];

		User testeUser1 = new User (
				Alias = 'newUser',
				Email='newuser@testorg.com',
				EmailEncodingKey='UTF-8',
				LastName='Testing1',
				LanguageLocaleKey='en_US',
				ContactId = c.id,
				LocaleSidKey='en_US',
				ProfileId = p.Id,
				TimeZoneSidKey='America/Los_Angeles',
				UserName='newuser@testorg.com',
				Mgmt_Report_Team__c = true
			);

		System.runAs(testeUser1) {
			ISSP_ANG_RHC cont = new ISSP_ANG_RHC();

			cont.getRiskEventList();

			Boolean b = cont.hasRightAccessIceService;

			cont.refreshRiskEventsTable();

			cont.riskStatusFilter = 'Expired';

			cont.getRiskEventList();

			cont.riskStatusFilter = 'Inactive';

			cont.getRiskEventList();

			cont.riskStatusFilter = 'All';

			cont.getRiskEventList();
		}
	}

	public static testMethod void test4() {
		List<Portal_Applications__c> portalApplicationList = TestDataFactory_PortalApplications.createDefaultPortalApplication(2);
		Portal_Applications__c s1 = portalApplicationList.get(0);
		s1.Name = ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_EDENRED;
		s1.ANG_Restrict_by_Agency_Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT;
		s1.ANG_Accredited_Agents_Only__c = false;
		s1.Agency__c = true;

		Portal_Applications__c s2 = portalApplicationList.get(1);
		s2.Name = ISSP_ANG_RHC.ICE_SERVICE;
		s2.ANG_Restrict_by_Agency_Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT;
		s2.ANG_Accredited_Agents_Only__c = false;
		s2.Agency__c = true;

		insert new List<Portal_Applications__c>{s1,s2};

		IATA_ISO_Country__c korea = new IATA_ISO_Country__c (
				Name = 'South_Korea_test',
				ISO_Code__c = 'KR',
				ANG_Portal_Service__c = s1.id,
				ANG_IEP_Model__c = 'Banking Model'
			);

		insert new List<IATA_ISO_Country__c>{korea};

		Account a = new Account (
				name = 'AccountTest',
				IATA_ISO_Country__c = korea.id,
				Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
				ANG_IEP_Status__c = ANG_ISSP_PortalServiceHelper.STATUS_NO_IEP_ACCOUNT,
				Location_type__c = 'HO',
				IATACode__c = '1234567890',
				ANG_Accreditation_Model__c = 'Cash',
				Status__c = 'Approved',
				OwnerId = UserInfo.getUserId()
			);

		insert new List<Account>{a};

		Contact c = new Contact (
				firstName = 'firstname',
				LastName = 'ContactTest',
				accountID = a.id
			);

		insert new List<Contact>{c};

		Portal_Application_Right__c appRight = new Portal_Application_Right__c(
				Portal_Application__c = s1.id,
				Right__c = 'Access Granted',
				Contact__c = c.Id
			);

		Portal_Application_Right__c appRight2 = new Portal_Application_Right__c(
				Portal_Application__c = s2.id,
				Right__c = 'Access Granted',
				Contact__c = c.Id
			);

		insert new List<Portal_Application_Right__c>{appRight,appRight2};

		Agency_Authorization__c aa = new Agency_Authorization__c (
				ANG_FormOfPayment_ID__c = 'CC',
				Account__c = a.id,
				Status__c = 'Active'
			);

		ANG_Risk_Event_Type__c t = new ANG_Risk_Event_Type__c(
			ANG_Description__c = 'Active event 2',
			ANG_Expiration__c = 1233,
			ANG_Risk_ID__c = '4234381'
			);

		insert t;

		ANG_Agency_Risk_Event__c e = new ANG_Agency_Risk_Event__c(
			ANG_Risk_Type__c = t.id,
			ANG_HE_AccountId__c = a.id,
			ANG_Issued_Date__c = Date.today(),
			ANG_Event_Status__c = 'Active',
			ANG_AccountId__c = a.id,
			ANG_Expired__c = false,
			ANG_Created_from__c = 'bla bla'
		);

		insert e;

		insert new List<Agency_Authorization__c>{aa};

		Profile p = [SELECT Id FROM Profile WHERE Name='ISS Portal'];

		User testeUser1 = new User (
				Alias = 'newUser',
				Email='newuser@testorg.com',
				EmailEncodingKey='UTF-8',
				LastName='Testing1',
				LanguageLocaleKey='en_US',
				ContactId = c.id,
				LocaleSidKey='en_US',
				ProfileId = p.Id,
				TimeZoneSidKey='America/Los_Angeles',
				UserName='newuser@testorg.com',
				Mgmt_Report_Team__c = true
			);

		System.runAs(testeUser1) {
			ISSP_ANG_RHC cont = new ISSP_ANG_RHC();

			//cont.initFormsOfPayment();

		}
	}

	public static testMethod void test5() {
		List<Portal_Applications__c> portalApplicationsList = TestDataFactory_PortalApplications.createDefaultPortalApplication(2);
		Portal_Applications__c s1 = portalApplicationsList.get(0);
		s1.Name = ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_EDENRED;
		s1.ANG_Restrict_by_Agency_Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT;
		s1.ANG_Accredited_Agents_Only__c = false;
		s1.Agency__c = true;

		Portal_Applications__c s2 = portalApplicationsList.get(1);
		s2.Name = ISSP_ANG_RHC.ICE_SERVICE;
		s2.ANG_Restrict_by_Agency_Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT;
		s2.ANG_Accredited_Agents_Only__c = false;
		s2.Agency__c = true;

		insert portalApplicationsList;

		IATA_ISO_Country__c china = new IATA_ISO_Country__c (
				Name = 'China_test',
				ISO_Code__c = 'CN',
				ANG_Portal_Service__c = s1.id
			);

		insert new List<IATA_ISO_Country__c>{china};

		Account a = new Account (
				name = 'AccountTest',
				IATA_ISO_Country__c = china.id,
				Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
				ANG_IEP_Status__c = ANG_ISSP_PortalServiceHelper.STATUS_NO_IEP_ACCOUNT,
				Location_type__c = 'AO',
				IATACode__c = '1234567890',
				ANG_Accreditation_Model__c = 'Cash',
				Status__c = 'Approved',
				OwnerId = UserInfo.getUserId()
			);

		insert new List<Account>{a};

		Contact c = new Contact (
				firstName = 'firstname',
				LastName = 'ContactTest',
				accountID = a.id
			);

		insert new List<Contact>{c};

		Portal_Application_Right__c appRight = new Portal_Application_Right__c(
				Portal_Application__c = s1.id,
				Right__c = 'Access Granted',
				Contact__c = c.Id
			);

		Portal_Application_Right__c appRight2 = new Portal_Application_Right__c(
				Portal_Application__c = s2.id,
				Right__c = 'Access Granted',
				Contact__c = c.Id
			);

		insert new List<Portal_Application_Right__c>{appRight,appRight2};

		Agency_Authorization__c aa = new Agency_Authorization__c (
				ANG_FormOfPayment_ID__c = 'CC',
				Account__c = a.id,
				Status__c = 'Active'
			);

		ANG_Risk_Event_Type__c t = new ANG_Risk_Event_Type__c(
			ANG_Description__c = 'Active event 2',
			ANG_Expiration__c = 1233,
			ANG_Risk_ID__c = '4234381'
			);

		insert t;

		ANG_Agency_Risk_Event__c e = new ANG_Agency_Risk_Event__c(
			ANG_Risk_Type__c = t.id,
			ANG_HE_AccountId__c = a.id,
			ANG_Issued_Date__c = Date.today(),
			ANG_Event_Status__c = 'Active',
			ANG_AccountId__c = a.id,
			ANG_Expired__c = false,
			ANG_Created_from__c = 'bla bla'
		);

		insert e;

		insert new List<Agency_Authorization__c>{aa};

		Profile p = [SELECT Id FROM Profile WHERE Name='ISS Portal'];

		User testeUser1 = new User (
				Alias = 'newUser',
				Email='newuser@testorg.com',
				EmailEncodingKey='UTF-8',
				LastName='Testing1',
				LanguageLocaleKey='en_US',
				ContactId = c.id,
				LocaleSidKey='en_US',
				ProfileId = p.Id,
				TimeZoneSidKey='America/Los_Angeles',
				UserName='newuser@testorg.com',
				Mgmt_Report_Team__c = true
			);

		System.runAs(testeUser1) {
			ISSP_ANG_RHC cont = new ISSP_ANG_RHC();

			//cont.initFormsOfPayment();

		}
	}
}
