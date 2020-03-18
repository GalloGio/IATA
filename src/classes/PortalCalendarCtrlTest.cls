/**
	Test Class for ISSP_OperationalCalendarController.cls
**/
@isTest
public  class PortalCalendarCtrlTest {

	@TestSetup
	public static void setup() {
		list<String> listAirlineId = new list<String>();
		for (Profile profile: [SELECT Id FROM Profile WHERE Name LIKE 'ISS Portal Airline%']) {
			listAirlineId.add(profile.Id);
		}
		System.assert(!listAirlineId.isEmpty(), 'No airline profiles found');
		list<String> listAgencyId = new list<String>();
		for (Profile profile: [SELECT Id FROM Profile WHERE Name LIKE 'ISS Portal Agency%']) {
			listAgencyId.add(profile.Id);
		}
		System.assert(!listAgencyId.isEmpty(), 'No agency profiles found');
		list<ISSP_CS__c> listCs = new list<ISSP_CS__c>();
		listCs.add(new ISSP_CS__c(Name='ISS OperationalCalendar Airline Profil',Value__c=String.join(listAirlineId,',')));
		listCs.add(new ISSP_CS__c(Name='ISS OperationalCalendar Agency Profile',Value__c=String.join(listAgencyId,',')));
		insert listCs;
	}

	public static User createUser(Profile profile, String operationType) {
		Boolean isCASS = PortalCalendarCtrl.MAP_OPERATION_TYPES.get(operationType).contains('CASS');
		Boolean isBSP = PortalCalendarCtrl.MAP_OPERATION_TYPES.get(operationType).contains('BSP');

		AMS_Settlement_System__c operation = new AMS_Settlement_System__c();
		insert operation;

		IATA_ISO_Country__c country = new IATA_ISO_Country__c(
			Name='Spain',
			ISO_Code__c='SP'
		);
		if (isBSP) {
			country.AMS_Settlement_System__c = operation.Id;
		}
		if (isCASS) {
			country.AMS_Settlement_System_CASS__c = operation.Id;
		}
		insert country;

		if (isBSP) {
			country.AMS_Settlement_System__r = operation;
		}
		if (isCASS) {
			country.AMS_Settlement_System_CASS__r = operation;
		}

		Account account = ISSP_ObjectFactory.createNewAccount();
		account.IATACode__c = '100';
		account.IATA_ISO_Country__c = country.Id;
		account.Remittance_frequency__c = 'M';
		account.Location_Class__c = operationType;
		insert account;
		account.IATA_ISO_Country__r = country;

		Contact contact = ISSP_ObjectFactory.createNewContact();
		contact.AccountId = account.Id;
		contact.LastName = 'test';
		contact.Email = System.now().millisecond() + 'test@email.com';
		insert contact;
		contact.Account = account;

		User user = ISSP_ObjectFactory.createPortalUser(contact);
		user.Contact = contact;
		user.profileId = profile.Id;
		User thisuser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		System.runAs(thisuser) {
			update user;
		}
		return user;
	}

	public static User createAirlineUserBSP() {
		Profile airlineProfile = [SELECT Id FROM Profile
			WHERE Id IN :ISSP_OperationalCalendarController.AIRLINE_PROFILES
			LIMIT 1];
		return createUser(airlineProfile,'P');
	}

	public static User createAirlineUserCASS() {
		Profile airlineProfile = [SELECT Id FROM Profile
			WHERE Id IN :ISSP_OperationalCalendarController.AIRLINE_PROFILES
			LIMIT 1];
		return createUser(airlineProfile, 'C');
	}

	public static User createAgentUserBSP() {
		Profile agentProfile = [SELECT Id FROM Profile
			WHERE Id IN :ISSP_OperationalCalendarController.AGENT_PROFILES
			LIMIT 1];
		return createUser(agentProfile,'P');
	}

	public static User createAgentUserCASS() {
		Profile agentProfile = [SELECT Id FROM Profile
			WHERE Id IN :ISSP_OperationalCalendarController.AGENT_PROFILES
			LIMIT 1];
		return createUser(agentProfile,'C');
	}

	@isTest
	public static void testController_AgentUserWithoutOperations() {
		User user = createAgentUserBSP();

		Test.StartTest();
		System.runAs(user) {
			List<PortalCalendarCtrl.EventWrapper> lstEvents = PortalCalendarCtrl.getOperationalCalendarEventsBetweenDates();
			System.assertEquals(0,lstEvents.size());
		}
		Test.StopTest();
	}

	@isTest
	public static void testController_AirlineUserWithoutOperations() {
		User user = createAirlineUserBSP();

		Test.StartTest();
		PortalCalendarCtrl.IS_AIRLINE = true;
		PortalCalendarCtrl.IS_AGENT = false;
		System.runAs(user) {
			List<PortalCalendarCtrl.EventWrapper> lstEvents = PortalCalendarCtrl.getOperationalCalendarEventsBetweenDates();
			System.assertEquals(0,lstEvents.size());
		}
		Test.StopTest();
	}

	@isTest
	public static void testController_AirlineUserWithOperations() {
		User user = createAirlineUserBSP();
		String operationType = PortalCalendarCtrl.MAP_OPERATION_TYPES.get(user.contact.account.Location_Class__c);
		list<Operational_Calendar__c> listOpCalendar = new list<Operational_Calendar__c>();
		listOpCalendar.add(new Operational_Calendar__c(
			Visible_on_the_portal__c = true,
			Operation_Currency__c = 'EUR',
			Settlement_Day__c = Date.today(),
			Airline_Input_Upload_Cut_Off__c = Date.today(),
			Airline_Correction_Response_Cut_Off__c = Date.today(),
			Remittance_Day__c = Date.today(),
			Billing_Availability__c = Date.today(),
			Agent_Correction_Cut_Off__c = Date.today(),
			HAR_Day__c = Date.today(),
			First_Day__c = Date.today(),
			ISS_operation__c = user.contact.account.IATA_ISO_Country__r.AMS_Settlement_System__c,
			Operation_Type__c = operationType,
			frequency_code__c = user.contact.account.Remittance_frequency__c
		));
		insert listOpCalendar;

		Test.StartTest();
		System.runAs(user) {
			PortalCalendarCtrl.IS_AIRLINE = true;
			PortalCalendarCtrl.IS_AGENT = false;
			List<PortalCalendarCtrl.EventWrapper> lstEvents = PortalCalendarCtrl.getOperationalCalendarEventsBetweenDates();
			System.assertEquals(true,lstEvents.size()>0);
		}
		Test.StopTest();
	}

	@isTest
	public static void testController_AirlineUserWithOperations_CASS() {
		User user = createAirlineUserCASS();
		String operationType = PortalCalendarCtrl.MAP_OPERATION_TYPES.get(user.contact.account.Location_Class__c);
		list<Operational_Calendar__c> listOpCalendar = new list<Operational_Calendar__c>();
		listOpCalendar.add(new Operational_Calendar__c(
			Visible_on_the_portal__c = true,
			Operation_Currency__c = 'EUR',
			Settlement_Day__c = Date.today(),
			Airline_Input_Upload_Cut_Off__c = Date.today(),
			Airline_Correction_Response_Cut_Off__c = Date.today(),
			Remittance_Day__c = Date.today(),
			Billing_Availability__c = Date.today(),
			Agent_Correction_Cut_Off__c = Date.today(),
			HAR_Day__c = Date.today(),
			First_Day__c = Date.today(),
			ISS_operation__c = user.contact.account.IATA_ISO_Country__r.AMS_Settlement_System_CASS__c,
			Operation_Type__c = operationType,
			frequency_code__c = user.contact.account.Remittance_frequency__c
		));
		insert listOpCalendar;

		Test.StartTest();
		System.runAs(user) {
			PortalCalendarCtrl.IS_AIRLINE = true;
			PortalCalendarCtrl.IS_AGENT = false;
			List<PortalCalendarCtrl.EventWrapper> lstEvents = PortalCalendarCtrl.getOperationalCalendarEventsBetweenDates();
			System.assertEquals(true,lstEvents.size()>0);
		}
		Test.StopTest();
	}

	@isTest
	public static void testController_AgentUserWithOperationsBSP() {
		User user = createAgentUserBSP();

		String operationType = PortalCalendarCtrl.MAP_OPERATION_TYPES.get(user.contact.account.Location_Class__c);
		list<Operational_Calendar__c> listOpCalendar = new list<Operational_Calendar__c>();
		listOpCalendar.add(new Operational_Calendar__c(
			Visible_on_the_portal__c = true,
			Settlement_Day__c = Date.today(),
			Airline_Input_Upload_Cut_Off__c = Date.today(),
			Airline_Correction_Response_Cut_Off__c = Date.today(),
			Remittance_Day__c = Date.today(),
			Billing_Availability__c = Date.today(),
			Agent_Correction_Cut_Off__c = Date.today(),
			HAR_Day__c = Date.today(),
			First_Day__c = Date.today(),
			ISS_operation__c = user.contact.account.IATA_ISO_Country__r.AMS_Settlement_System__c,
			Operation_Type__c = operationType,
			frequency_code__c = user.contact.account.Remittance_frequency__c
		));
		insert listOpCalendar;

		Test.StartTest();
		System.runAs(user) {
			PortalCalendarCtrl.IS_AIRLINE = false;
			PortalCalendarCtrl.IS_AGENT = true;
			List<PortalCalendarCtrl.EventWrapper> lstEvents = PortalCalendarCtrl.getOperationalCalendarEventsBetweenDates();
			System.assertEquals(true,lstEvents.size()>0);
		}
		Test.StopTest();
	}

	@isTest
	public static void testController_AgentUserWithOperationsCASS() {
		User user = createAgentUserCASS();

		String operationType = PortalCalendarCtrl.MAP_OPERATION_TYPES.get(user.contact.account.Location_Class__c);
		list<Operational_Calendar__c> listOpCalendar = new list<Operational_Calendar__c>();
		listOpCalendar.add(new Operational_Calendar__c(
			Visible_on_the_portal__c = true,
			Settlement_Day__c = Date.today(),
			Airline_Input_Upload_Cut_Off__c = Date.today(),
			Airline_Correction_Response_Cut_Off__c = Date.today(),
			Remittance_Day__c = Date.today(),
			Billing_Availability__c = Date.today(),
			Agent_Correction_Cut_Off__c = Date.today(),
			HAR_Day__c = Date.today(),
			First_Day__c = Date.today(),
			ISS_operation__c = user.contact.account.IATA_ISO_Country__r.AMS_Settlement_System_CASS__c,
			Operation_Type__c = operationType,
			frequency_code__c = user.contact.account.Remittance_frequency__c
		));
		insert listOpCalendar;

		Test.StartTest();
		System.runAs(user) {
			PortalCalendarCtrl.IS_AIRLINE = false;
			PortalCalendarCtrl.IS_AGENT = true;
			List<PortalCalendarCtrl.EventWrapper> lstEvents = PortalCalendarCtrl.getOperationalCalendarEventsBetweenDates();
			System.assertEquals(true,lstEvents.size()>0);
		}
		Test.StopTest();
	}

	@isTest
	public static void testController_getMonthsForHomeCalendar() {
		User user = createAgentUserCASS();

		String operationType = PortalCalendarCtrl.MAP_OPERATION_TYPES.get(user.contact.account.Location_Class__c);
		list<Operational_Calendar__c> listOpCalendar = new list<Operational_Calendar__c>();
		listOpCalendar.add(new Operational_Calendar__c(
			Visible_on_the_portal__c = true,
			Settlement_Day__c = Date.today(),
			Airline_Input_Upload_Cut_Off__c = Date.today(),
			Airline_Correction_Response_Cut_Off__c = Date.today(),
			Remittance_Day__c = Date.today(),
			Billing_Availability__c = Date.today(),
			Agent_Correction_Cut_Off__c = Date.today(),
			HAR_Day__c = Date.today(),
			First_Day__c = Date.today(),
			ISS_operation__c = user.contact.account.IATA_ISO_Country__r.AMS_Settlement_System_CASS__c,
			Operation_Type__c = operationType,
			frequency_code__c = user.contact.account.Remittance_frequency__c
		));
		listOpCalendar.add(new Operational_Calendar__c(
			Visible_on_the_portal__c = true,
			Settlement_Day__c = Date.today().addMonths(1),
			Airline_Input_Upload_Cut_Off__c = Date.today().addMonths(1),
			Airline_Correction_Response_Cut_Off__c = Date.today().addMonths(1),
			Remittance_Day__c = Date.today().addMonths(1),
			Billing_Availability__c = Date.today().addMonths(1),
			Agent_Correction_Cut_Off__c = Date.today().addMonths(1),
			HAR_Day__c = Date.today().addMonths(1),
			First_Day__c = Date.today().addMonths(1),
			ISS_operation__c = user.contact.account.IATA_ISO_Country__r.AMS_Settlement_System_CASS__c,
			Operation_Type__c = operationType,
			frequency_code__c = user.contact.account.Remittance_frequency__c
		));
		listOpCalendar.add(new Operational_Calendar__c(
			Visible_on_the_portal__c = true,
			Settlement_Day__c = Date.today().addMonths(-1),
			Airline_Input_Upload_Cut_Off__c = Date.today().addMonths(-1),
			Airline_Correction_Response_Cut_Off__c = Date.today().addMonths(-1),
			Remittance_Day__c = Date.today().addMonths(-1),
			Billing_Availability__c = Date.today().addMonths(-1),
			Agent_Correction_Cut_Off__c = Date.today().addMonths(-1),
			HAR_Day__c = Date.today().addMonths(-1),
			First_Day__c = Date.today().addMonths(-1),
			ISS_operation__c = user.contact.account.IATA_ISO_Country__r.AMS_Settlement_System_CASS__c,
			Operation_Type__c = operationType,
			frequency_code__c = user.contact.account.Remittance_frequency__c
		));
		insert listOpCalendar;

		String todayDate = Date.today().year() + '-' + Date.today().month() + '-' + Date.today().day();

		Test.StartTest();
		System.runAs(user) {
			PortalCalendarCtrl.IS_AIRLINE = false;
			PortalCalendarCtrl.IS_AGENT = true;

			PortalCalendarCtrl.MonthWrapper month = PortalCalendarCtrl.getInitialMonthPage(todayDate, todayDate);
			PortalCalendarCtrl.MonthWrapper previousMonth = PortalCalendarCtrl.getPreviousMonth(todayDate, Date.today().month(), Date.today().year());
			PortalCalendarCtrl.MonthWrapper nextMonth = PortalCalendarCtrl.getNextMonth(todayDate, Date.today().month(), Date.today().year());
		}
		Test.StopTest();
	}

	@isTest
	public static void testController_testgetNumberEmptyDays() {
		Integer i = 0;
		for(i = 0; i < 7; i++){
			PortalCalendarCtrl.getNumberEmptyDays(Datetime.now().addDays(i));
		}
	}

	@isTest
	public static void testController_isAirlineOrAgencyUser() {

			PortalCalendarCtrl.isAirlineOrAgencyUser();

	}

}
