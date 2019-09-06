/**
    Test Class for ISSP_OperationalCalendarController.cls 
**/
@isTest
public class ISSP_OperationalCalendarControllerTest {

    public static final map<String,String> MAP_OPERATION_TYPES = new map<String,String>{
        'P' => 'BSP International',
        'D' => 'BSP Domestic',
        'C' => 'CASS Export',
        'R' => 'CASS Export',
        'I' => 'CASS Import'
    };
    public static String AIRLINE_PROFILES = 'ISS OperationalCalendar Airline Profil';
    public static String AGENT_PROFILES = 'ISS OperationalCalendar Agency Profile';

    @TestSetup
    public static void setup() {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(
            Name='Spain',
            ISO_Code__c='SP'
        );
        IATA_ISO_Country__c world = new IATA_ISO_Country__c(
            Name='World',
            ISO_Code__c='WW'
        );
        insert new list<IATA_ISO_Country__c>{country,world};
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
        listCs.add(new ISSP_CS__c(Name=AIRLINE_PROFILES,Value__c=String.join(listAirlineId,',')));
        listCs.add(new ISSP_CS__c(Name=AGENT_PROFILES,Value__c=String.join(listAgencyId,',')));
        insert listCs;
    }

    public static User createUser(Profile profile, String operationType, IATA_ISO_Country__c country) {
        Boolean isCASS = MAP_OPERATION_TYPES.get(operationType).contains('CASS');
        Boolean isBSP = MAP_OPERATION_TYPES.get(operationType).contains('BSP');
        
        AMS_Settlement_System__c operation = new AMS_Settlement_System__c();
        insert operation;

        if (isBSP) {
            country.AMS_Settlement_System__c = operation.Id;
        }
        if (isCASS) {
            country.AMS_Settlement_System_CASS__c = operation.Id;
        }
        update country;
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
        account.Membership_status__c = 'Non-IATA member';
        insert account;
        account.IATA_ISO_Country__r = country;
        
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = account.Id;
        contact.LastName = 'test';
        contact.Email = 'test@email.com' + (Math.random()*1000000000);
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
            WHERE Id IN :ISSP_CS__c.getValues(AIRLINE_PROFILES).Value__c.split(',')
            LIMIT 1];
        IATA_ISO_Country__c country = [SELECT Id FROM IATA_ISO_Country__c LIMIT 1];
        return createUser(airlineProfile,'P', country);
    }
    
    public static User createAirlineUserCASS() {
        Profile airlineProfile = [SELECT Id FROM Profile 
            WHERE Id IN :ISSP_CS__c.getValues(AIRLINE_PROFILES).Value__c.split(',')
            LIMIT 1];
        IATA_ISO_Country__c country = [SELECT Id FROM IATA_ISO_Country__c LIMIT 1];
        return createUser(airlineProfile, 'C', country);
    }
    
    public static User createAgentUserBSP() {
        Profile agentProfile = [SELECT Id FROM Profile 
            WHERE Id IN :ISSP_CS__c.getValues(AGENT_PROFILES).Value__c.split(',')
            LIMIT 1];
        IATA_ISO_Country__c country = [SELECT Id FROM IATA_ISO_Country__c LIMIT 1];
        return createUser(agentProfile,'P', country);
    }
    
    public static User createAgentUserCASS() {
        Profile agentProfile = [SELECT Id FROM Profile 
            WHERE Id IN :ISSP_CS__c.getValues(AGENT_PROFILES).Value__c.split(',')
            LIMIT 1];
        IATA_ISO_Country__c country = [SELECT Id FROM IATA_ISO_Country__c LIMIT 1];
        return createUser(agentProfile,'C', country);
    }
    
    @isTest
    public static void testStaticMethods() {
        delete [SELECT Name FROM ISSP_CS__c];
        Test.StartTest();
        System.assertEquals('present-row',ISSP_OperationalCalendarController.getDateClassName(Date.today(),Date.today().addDays(2)));
        System.assertEquals('past-row',ISSP_OperationalCalendarController.getDateClassName(Date.today().addDays(-1),Date.today().addDays(2)));
        System.assertEquals('future-row',ISSP_OperationalCalendarController.getDateClassName(Date.today().addDays(1),Date.today().addDays(2)));
        System.assertEquals('first-nonpast-row',ISSP_OperationalCalendarController.getDateClassName(Date.today().addDays(1),Date.today().addDays(1)));
        System.assert(ISSP_OperationalCalendarController.AIRLINE_PROFILES.isEmpty());
        System.assert(ISSP_OperationalCalendarController.AGENT_PROFILES.isEmpty());
        Test.StopTest();
    }
    
    @isTest
    public static void testController_AgentUserWithoutOperations() {
        User user = createAgentUserBSP();
        
        Test.StartTest();
        System.runAs(user) {
            ISSP_OperationalCalendarController.IS_AIRLINE = false;
            ISSP_OperationalCalendarController.IS_AGENT = false;
            ISSP_OperationalCalendarController.isAllowedAccess();
            ISSP_OperationalCalendarController controller = new ISSP_OperationalCalendarController();
            controller.getListFiltersJson();
            controller.getListOperations();
            controller.getIsAirline();
            controller.getListEventsJSON();
            controller.getListEventsJSONGrouped();
            controller.getMapFrequenciesJSON();
            controller.getMapCountriesJSON();
            controller.getSisOptionsJSON();
            controller.getDescription();
            controller.getUserLanguage();
            List<SelectOption> listOptions = controller.selectedOperations;
            controller.selectedOperations = listOptions;
            listOptions = controller.selectedFrenquencies;
            controller.selectedFrenquencies = listOptions;
            listOptions = controller.selectedCountries;
            controller.selectedCountries = listOptions;
            try {
                ISSP_OperationalCalendarController.loadEventsRemote('','','','','');
                System.assert(false, 'Exception expected');
            } catch (Exception e) {
                System.assert(true);
            }
            try {
                ISSP_OperationalCalendarController.loadDetailsRemote('','','','','','');
                System.assert(false, 'Exception expected');
            } catch (Exception e) {
                System.assert(true);
            }
        }
        Test.StopTest();
    }
    
    @isTest
    public static void testController_AirlineUserWithoutOperations() {
        User user = createAirlineUserBSP();
        
        Test.StartTest();
        System.runAs(user) {
            ISSP_OperationalCalendarController.IS_AIRLINE = true;
            ISSP_OperationalCalendarController.IS_AGENT = false;
            ISSP_OperationalCalendarController controller = new ISSP_OperationalCalendarController();
            controller.getListFiltersJson();
            controller.getListOperations();
            controller.getIsAirline();
            controller.getListEventsJSON();
            controller.getListEventsJSONGrouped();
            controller.getDescription();
            try {
                ISSP_OperationalCalendarController.loadEventsRemote('','','','','');
                System.assert(false, 'Exception expected');
            } catch(Exception e) {
                System.assert(true);
            }
            try {
                ISSP_OperationalCalendarController.loadDetailsRemote('','','','','','');
                System.assert(false, 'Exception expected');
            } catch(Exception e) {
                System.assert(true);
            }
        }
        Test.StopTest();
    }
        
    @isTest
    public static void testController_AirlineUserWithBSPCASSOperations() {
        User user = createAirlineUserBSP();
        String operationType = ISSP_OperationalCalendarController.MAP_OPERATION_TYPES.get(user.contact.account.Location_Class__c);
        list<Operational_Calendar__c> listOpCalendar = new list<Operational_Calendar__c>();
        listOpCalendar.add(new Operational_Calendar__c(
            RecordTypeId = ISSP_OperationalCalendarController.RT_ISS_CALENDAR.getRecordTypeId(),
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
            ISSP_OperationalCalendarController.IS_AIRLINE = true;
            ISSP_OperationalCalendarController.IS_AGENT = false;
            ISSP_OperationalCalendarController controller = new ISSP_OperationalCalendarController();
            String country = user.contact.account.IATA_ISO_Country__c;
            String cycle = '';
            String frequency = '';
            String currencyCode = 'EUR';
            String billingPeriod = String.valueOf(Date.today().year());
            ISSP_OperationalCalendarController.loadEventsRemote(operationType, cycle, country, frequency, currencyCode);
            ISSP_OperationalCalendarController.loadDetailsRemote(operationType, cycle, country, frequency, currencyCode, billingPeriod);
            ISSP_OperationalCalendarController.loadDetailsRemote(operationType, cycle, country, frequency, currencyCode, '1');
            controller.getListEventsJSON();
            controller.getListEventsJSONGrouped();
        }
        Test.StopTest();
    }

    @isTest
    public static void testController_AirlineUserWithSISOperations() {
        User user = createAirlineUserBSP();
        String operationType = 'SIS';
        list<Operational_Calendar__c> listOpCalendar = new list<Operational_Calendar__c>();
        listOpCalendar.add(new Operational_Calendar__c(
            RecordTypeId = ISSP_OperationalCalendarController.RT_SIS_CALENDAR.getRecordTypeId(),
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
            ISS_operation__c = null,
            Country__c = user.contact.account.IATA_ISO_Country__c,
            Operation_Type__c = operationType,
            frequency_code__c = user.contact.account.Remittance_frequency__c
        ));
        insert listOpCalendar;
        
        Test.StartTest();
        System.runAs(user) {
            ISSP_OperationalCalendarController.IS_AIRLINE = true;
            ISSP_OperationalCalendarController.IS_AGENT = false;
            ISSP_OperationalCalendarController controller = new ISSP_OperationalCalendarController();
            String country = user.contact.account.IATA_ISO_Country__c;
            String cycle = '';
            String frequency = '';
            String currencyCode = 'EUR';
            String billingPeriod = String.valueOf(Date.today().year());
            ISSP_OperationalCalendarController.loadEventsRemote(operationType, cycle, country, frequency, currencyCode);
            ISSP_OperationalCalendarController.loadDetailsRemote(operationType, cycle, country, frequency, currencyCode, billingPeriod);
            ISSP_OperationalCalendarController.loadDetailsRemote(operationType, cycle, country, frequency, currencyCode, '1');
            controller.getListEventsJSON();
            controller.getListEventsJSONGrouped();
        }
        Test.StopTest();
    }

    @isTest
    public static void testController_AirlineUserWithICCSOperations() {
        User user = createAirlineUserBSP();
        String operationType = 'ICCS';
        list<Operational_Calendar__c> listOpCalendar = new list<Operational_Calendar__c>();
        listOpCalendar.add(new Operational_Calendar__c(
            RecordTypeId = ISSP_OperationalCalendarController.RT_ICCS_CALENDAR.getRecordTypeId(),
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
            ISS_operation__c = null,
            Country__c = user.contact.account.IATA_ISO_Country__c,
            Operation_Type__c = 'BSP',
            frequency_code__c = user.contact.account.Remittance_frequency__c
        ));
        insert listOpCalendar;
        
        Test.StartTest();
        System.runAs(user) {
            ISSP_OperationalCalendarController.IS_AIRLINE = true;
            ISSP_OperationalCalendarController.IS_AGENT = false;
            ISSP_OperationalCalendarController controller = new ISSP_OperationalCalendarController();
            String country = user.contact.account.IATA_ISO_Country__c;
            String cycle = '';
            String frequency = '';
            String currencyCode = 'EUR';
            String billingPeriod = String.valueOf(Date.today().year());
            ISSP_OperationalCalendarController.loadEventsRemote(operationType, cycle, country, frequency, currencyCode);
            ISSP_OperationalCalendarController.loadDetailsRemote(operationType, cycle, country, frequency, currencyCode, billingPeriod);
            ISSP_OperationalCalendarController.loadDetailsRemote(operationType, cycle, country, frequency, currencyCode, '1');
            controller.getListEventsJSON();
            controller.getListEventsJSONGrouped();
        }
        Test.StopTest();
    }

    @isTest
    public static void testController_AirlineUserWithOperations_CASS() {
        User user = createAirlineUserCASS();
        String operationType = ISSP_OperationalCalendarController.MAP_OPERATION_TYPES.get(user.contact.account.Location_Class__c);
        list<Operational_Calendar__c> listOpCalendar = new list<Operational_Calendar__c>();
        listOpCalendar.add(new Operational_Calendar__c(
            RecordTypeId = ISSP_OperationalCalendarController.RT_ISS_CALENDAR.getRecordTypeId(),
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
            ISSP_OperationalCalendarController.IS_AIRLINE = true;
            ISSP_OperationalCalendarController.IS_AGENT = false;
            ISSP_OperationalCalendarController controller = new ISSP_OperationalCalendarController();
            String country = user.contact.account.IATA_ISO_Country__c;
            String cycle = '';
            String frequency = '';
            String currencyCode = '';
            String billingPeriod = String.valueOf(Date.today().year());
            ISSP_OperationalCalendarController.loadEventsRemote(operationType, cycle, country, frequency, currencyCode);
            ISSP_OperationalCalendarController.loadDetailsRemote(operationType, cycle, country, frequency, currencyCode, billingPeriod);
            ISSP_OperationalCalendarController.loadDetailsRemote(operationType, cycle, country, frequency, currencyCode, '1');
            controller.getListEventsJSON();
            controller.getListEventsJSONGrouped();
        }
        Test.StopTest();
    }
    
    @isTest
    public static void testController_AgentUserWithOperationsBSP() {
        User user = createAgentUserBSP();
        
        String operationType = ISSP_OperationalCalendarController.MAP_OPERATION_TYPES.get(user.contact.account.Location_Class__c);
        list<Operational_Calendar__c> listOpCalendar = new list<Operational_Calendar__c>();
        listOpCalendar.add(new Operational_Calendar__c(
            RecordTypeId = ISSP_OperationalCalendarController.RT_ISS_CALENDAR.getRecordTypeId(),
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
            ISSP_OperationalCalendarController.IS_AIRLINE = false;
            ISSP_OperationalCalendarController.IS_AGENT = true;
            ISSP_OperationalCalendarController controller = new ISSP_OperationalCalendarController();
            String country = user.contact.account.IATA_ISO_Country__c;
            String cycle = '';
            String frequency = '';
            String currencyCode = '';
            String billingPeriod = String.valueOf(Date.today().year());
            ISSP_OperationalCalendarController.loadEventsRemote(operationType, cycle, country, frequency, currencyCode);
            ISSP_OperationalCalendarController.loadDetailsRemote(operationType, cycle, country, frequency, currencyCode, billingPeriod);
            controller.getListEventsJSON();
            controller.getListEventsJSONGrouped();
        }
        Test.StopTest();
    }
    
    @isTest
    public static void testController_AgentUserWithOperationsCASS() {
        User user = createAgentUserCASS();
        
        String operationType = ISSP_OperationalCalendarController.MAP_OPERATION_TYPES.get(user.contact.account.Location_Class__c);
        list<Operational_Calendar__c> listOpCalendar = new list<Operational_Calendar__c>();
        listOpCalendar.add(new Operational_Calendar__c(
            RecordTypeId = ISSP_OperationalCalendarController.RT_ISS_CALENDAR.getRecordTypeId(),
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
            ISSP_OperationalCalendarController.IS_AIRLINE = false;
            ISSP_OperationalCalendarController.IS_AGENT = true;
            ISSP_OperationalCalendarController controller = new ISSP_OperationalCalendarController();
            String country = user.contact.account.IATA_ISO_Country__c;
            String cycle = '';
            String frequency = '';
            String currencyCode = '';
            String billingPeriod = String.valueOf(Date.today().year());
            ISSP_OperationalCalendarController.loadEventsRemote(operationType, cycle, country, frequency, currencyCode);
            ISSP_OperationalCalendarController.loadDetailsRemote(operationType, cycle, country, frequency, currencyCode, billingPeriod);
            controller.getListEventsJSON();
            controller.getListEventsJSONGrouped();
        }
        Test.StopTest();
    }

    @isTest
    public static void testController_Disclaimerlabel() {
        User user = createAgentUserBSP();
        
        IATA_ISO_Country__c country = [SELECT Id, ISO_Code__c FROM IATA_ISO_Country__c LIMIT 1];
        
        insert new ISSP_Operational_Calendar_Disclaimer__c(
            Name = '1',
            Country__c = country.ISO_Code__c,
            Operation_Type__c = 'BSP International',
            Label__c = 'label'
        );

        Test.StartTest();
        System.runAs(user) {
            ISSP_OperationalCalendarController controller = new ISSP_OperationalCalendarController();
            controller.selectedCountry = country.Id;
            controller.selectedType = 'CASS';
            controller.findDisclaimerLabel();
            System.assertEquals(null,controller.disclaimerLabelName);

            controller.selectedCountry = country.Id;
            controller.selectedType = 'BSP International';
            controller.findDisclaimerLabel();
            System.assertEquals('label', controller.disclaimerLabelName);
        }
        Test.StopTest();
    }

    @isTest
    public static void testMassExportBSP() {
        User user = createAirlineUserBSP();

        AMS_Settlement_System__c issOperation = [SELECT Id FROM AMS_Settlement_System__c LIMIT 1];
        IATA_ISO_Country__c country = [SELECT Id FROM IATA_ISO_Country__c LIMIT 1];

        String operationType = ISSP_OperationalCalendarController.MAP_OPERATION_TYPES.get(user.contact.account.Location_Class__c);
        list<Operational_Calendar__c> listOpCalendar = new list<Operational_Calendar__c>();
        listOpCalendar.add(new Operational_Calendar__c(
            RecordTypeId = ISSP_OperationalCalendarController.RT_ISS_CALENDAR.getRecordTypeId(),
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
            ISS_operation__c = issOperation.Id,
            Operation_Type__c = operationType,
            frequency_code__c = user.contact.account.Remittance_frequency__c
        ));
        insert listOpCalendar;

        Account account = new Account(
            Id= user.contact.accountId,
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IATA_Airline').getRecordTypeId()
        );
        User adminuser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator - automated processes' AND isActive = true LIMIT 1];
        System.runAs(adminuser) {
            update account;
        }
        insert new Services_Rendered__c(Services_Rendered_to_Airline__c = user.contact.accountId);

        Test.StartTest();
        System.runAs(user) {
            ISSP_OperationalCalendarController.IS_AIRLINE = true;
            ISSP_OperationalCalendarController.IS_AGENT = false;
            ISSP_OperationalCalendarController controller = new ISSP_OperationalCalendarController();
            List<String> operations = new List<String> {operationType};
            List<String> remittance = new List<String>{user.contact.account.Remittance_frequency__c};
            List<Id> countries = new list<Id>{country.Id};
            ISSP_OperationalCalendarController.createZipFile('allservices', operations, remittance, countries, user.contact.accountId);
            ISSP_OperationalCalendarController.createZipFile('custom', operations, remittance, countries, user.contact.accountId);
            ISSP_OperationalCalendarController.createZipFile('all', operations, remittance, countries, user.contact.accountId);
        }
        Test.StopTest();
    }

    @isTest
    public static void testMassExportCASS() {
        User user = createAirlineUserCASS();

        AMS_Settlement_System__c issOperation = [SELECT Id FROM AMS_Settlement_System__c LIMIT 1];
        IATA_ISO_Country__c country = [SELECT Id FROM IATA_ISO_Country__c LIMIT 1];

        String operationType = ISSP_OperationalCalendarController.MAP_OPERATION_TYPES.get(user.contact.account.Location_Class__c);
        list<Operational_Calendar__c> listOpCalendar = new list<Operational_Calendar__c>();
        listOpCalendar.add(new Operational_Calendar__c(
            RecordTypeId = ISSP_OperationalCalendarController.RT_ISS_CALENDAR.getRecordTypeId(),
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
            ISS_operation__c = issOperation.Id,
            Operation_Type__c = operationType,
            frequency_code__c = user.contact.account.Remittance_frequency__c
        ));
        insert listOpCalendar;

        Account account = new Account(
            Id= user.contact.accountId,
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IATA_Airline').getRecordTypeId()
        );
        User adminuser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator - automated processes' AND isActive = true LIMIT 1];
        System.runAs(adminuser) {
            update account;
        }

        insert new Services_Rendered__c(Services_Rendered_to_Airline__c = user.contact.accountId);

        Test.StartTest();
        System.runAs(user) {
            ISSP_OperationalCalendarController.IS_AIRLINE = true;
            ISSP_OperationalCalendarController.IS_AGENT = false;
            ISSP_OperationalCalendarController controller = new ISSP_OperationalCalendarController();
            List<String> operations = new List<String> {operationType};
            List<String> remittance = new List<String>{user.contact.account.Remittance_frequency__c};
            List<Id> countries = new list<Id>{country.Id};
            ISSP_OperationalCalendarController.createZipFile('allservices', operations, remittance, countries, user.contact.accountId);
            ISSP_OperationalCalendarController.createZipFile('custom', operations, remittance, countries, user.contact.accountId);
            ISSP_OperationalCalendarController.createZipFile('all', operations, remittance, countries, user.contact.accountId);
        }
        Test.StopTest();
    }

    @isTest
    public static void testMassExportOthers() {
        User user = createAirlineUserCASS();

        IATA_ISO_Country__c country = [SELECT Id FROM IATA_ISO_Country__c WHERE ISO_Code__c = 'SP' LIMIT 1];
        IATA_ISO_Country__c world = [SELECT Id FROM IATA_ISO_Country__c WHERE ISO_Code__c = 'WW' LIMIT 1];

        list<Operational_Calendar__c> listOpCalendar = new list<Operational_Calendar__c>();
        listOpCalendar.add(new Operational_Calendar__c(
            RecordTypeId = ISSP_OperationalCalendarController.RT_SIS_CALENDAR.getRecordTypeId(),
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
            Operation_Type__c = 'SIS',
            frequency_code__c = user.contact.account.Remittance_frequency__c,
            Country__c = world.Id
        ));
        listOpCalendar.add(new Operational_Calendar__c(
            RecordTypeId = ISSP_OperationalCalendarController.RT_ICCS_CALENDAR.getRecordTypeId(),
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
            Operation_Type__c = 'CASS',
            frequency_code__c = user.contact.account.Remittance_frequency__c,
            Country__c = country.Id,
            Cycle__c = '052'
        ));
        insert listOpCalendar;

        Account account = new Account(
            Id= user.contact.accountId,
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IATA_Airline').getRecordTypeId()
        );
        User adminuser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator - automated processes' AND isActive = true LIMIT 1];
        System.runAs(adminuser) {
            update account;
        }

        insert new Services_Rendered__c(Services_Rendered_to_Airline__c = user.contact.accountId);

        Test.StartTest();
        System.runAs(user) {
            ISSP_OperationalCalendarController.IS_AIRLINE = true;
            ISSP_OperationalCalendarController.IS_AGENT = false;
            ISSP_OperationalCalendarController controller = new ISSP_OperationalCalendarController();
            List<String> operations = new List<String> {'SIS','CASS'};
            List<String> remittance = new List<String>{user.contact.account.Remittance_frequency__c};
            List<Id> countries = new list<Id>{country.Id};
            ISSP_OperationalCalendarController.createZipFile('allservices', operations, remittance, countries, user.contact.accountId);
            ISSP_OperationalCalendarController.createZipFile('custom', operations, remittance, countries, user.contact.accountId);
            ISSP_OperationalCalendarController.createZipFile('all', operations, remittance, countries, user.contact.accountId);
        }
        Test.StopTest();
    }
}