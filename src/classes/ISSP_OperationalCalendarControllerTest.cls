/**
    Test Class for ISSP_OperationalCalendarController.cls 
**/
@isTest
public class ISSP_OperationalCalendarControllerTest {

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
        Boolean isCASS = ISSP_OperationalCalendarController.MAP_OPERATION_TYPES.get(operationType).contains('CASS');
        Boolean isBSP = ISSP_OperationalCalendarController.MAP_OPERATION_TYPES.get(operationType).contains('BSP');
        
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
    public static void testStaticMethods() {
        Test.StartTest();
        System.assertEquals('present-row',ISSP_OperationalCalendarController.getDateComparedToToday(Date.today()));
        System.assertEquals('past-row',ISSP_OperationalCalendarController.getDateComparedToToday(Date.today().addDays(-1)));
        System.assertEquals('future-row',ISSP_OperationalCalendarController.getDateComparedToToday(Date.today().addDays(1)));
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
            try {
                ISSP_OperationalCalendarController.loadEventsRemote('','','','');
                System.assert(false, 'Exception expected');
            } catch (Exception e) {
                System.assert(true);
            }
            try {
                ISSP_OperationalCalendarController.loadDetailsRemote('','','','','');
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
            try {
                ISSP_OperationalCalendarController.loadEventsRemote('','','','');
                System.assert(false, 'Exception expected');
            } catch(Exception e) {
                System.assert(true);
            }
            try {
                ISSP_OperationalCalendarController.loadDetailsRemote('','','','','');
                System.assert(false, 'Exception expected');
            } catch(Exception e) {
                System.assert(true);
            }
        }
        Test.StopTest();
    }
        
    @isTest
    public static void testController_AirlineUserWithOperations() {
        User user = createAirlineUserBSP();
        String operationType = ISSP_OperationalCalendarController.MAP_OPERATION_TYPES.get(user.contact.account.Location_Class__c);
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
            ISSP_OperationalCalendarController.IS_AIRLINE = true;
            ISSP_OperationalCalendarController.IS_AGENT = false;
            ISSP_OperationalCalendarController controller = new ISSP_OperationalCalendarController();
            String country = user.contact.account.IATA_ISO_Country__c;
            String frequency = '';
            String currencyCode = 'EUR';
            String billingPeriod = String.valueOf(Date.today().year());
            ISSP_OperationalCalendarController.loadEventsRemote(country, frequency, operationType, currencyCode);
            ISSP_OperationalCalendarController.loadDetailsRemote(country, frequency, operationType, currencyCode, billingPeriod);
            ISSP_OperationalCalendarController.loadDetailsRemote(country, frequency, operationType, currencyCode, '1');
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
            String frequency = '';
            String currencyCode = '';
            String billingPeriod = String.valueOf(Date.today().year());
            ISSP_OperationalCalendarController.loadEventsRemote(country, frequency, operationType, currencyCode);
            ISSP_OperationalCalendarController.loadDetailsRemote(country, frequency, operationType, currencyCode, billingPeriod);
            ISSP_OperationalCalendarController.loadDetailsRemote(country, frequency, operationType, currencyCode, '1');
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
            String frequency = '';
            String currencyCode = '';
            String billingPeriod = String.valueOf(Date.today().year());
            ISSP_OperationalCalendarController.loadEventsRemote(country, frequency, operationType, currencyCode);
            ISSP_OperationalCalendarController.loadDetailsRemote(country, frequency, operationType, currencyCode, billingPeriod);
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
            String frequency = '';
            String currencyCode = '';
            String billingPeriod = String.valueOf(Date.today().year());
            ISSP_OperationalCalendarController.loadEventsRemote(country, frequency, operationType, currencyCode);
            ISSP_OperationalCalendarController.loadDetailsRemote(country, frequency, operationType, currencyCode, billingPeriod);
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
}