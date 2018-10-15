@isTest
private class OperationalCalendarHandlerTest {

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
    
    @isTest
    private static void testBeforeInsertForBSP() {
        AMS_Settlement_System__c issOperation = new AMS_Settlement_System__c(Name = 'BSP-AD');
        insert issOperation;
        
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(
            Name='Spain',
            ISO_Code__c = 'SP',
            AMS_Settlement_System__c = issOperation.Id
        );
        insert country;
        
        Test.StartTest();
        Operational_Calendar__c operation = new Operational_Calendar__c(
            Visible_on_the_portal__c = true,
            Operation_Code__c= 'SP_BSP_Y_EUR_D',
            Period_Code__c= '20180202M'
        );
        insert operation;
        Test.stopTest();
        
        operation = [
            SELECT Id, Operation_Code__c, Period_Code__c, Operation_Currency__c, Operation_Period_code__c,
                Frequency_code__c, Operation_Type__c, ISS_operation__c,Recordtype.DeveloperName
            FROM Operational_Calendar__c
            WHERE Id = :operation.Id];
        System.assertEquals('EUR',operation.Operation_Currency__c);
        System.assertEquals('M',operation.Frequency_code__c);
        System.assertEquals('BSP Domestic',operation.Operation_Type__c);
        System.assertEquals(issOperation.Id,operation.ISS_operation__c);
        System.assertEquals(operation.Operation_Code__c + '__RM_' + operation.Period_Code__c ,operation.Operation_Period_code__c);
        System.assertEquals('ISS_Calendar',operation.Recordtype.DeveloperName);
    }
    
    @isTest
    private static void testBeforeInsertForCASS() {
        AMS_Settlement_System__c issOperation = new AMS_Settlement_System__c(Name = 'CASS-AD');
        insert issOperation;
        
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(
            Name='Spain',
            ISO_Code__c = 'SP',
            AMS_Settlement_System_CASS__c = issOperation.Id
        );
        insert country;
        
        Test.StartTest();
        Operational_Calendar__c operation = new Operational_Calendar__c(
            Visible_on_the_portal__c = true,
            Operation_Code__c= 'SP_CAS_E_EUR_X',
            Period_Code__c= '20180202M'
        );
        insert operation;
        Test.stopTest();
        
        operation = [
            SELECT Id, Operation_Code__c, Period_Code__c, Operation_Currency__c, Operation_Period_code__c,
                Frequency_code__c, Operation_Type__c, ISS_operation__c,Recordtype.DeveloperName
            FROM Operational_Calendar__c
            WHERE Id = :operation.Id];
        System.assertEquals('EUR',operation.Operation_Currency__c);
        System.assertEquals('M',operation.Frequency_code__c);
        System.assertEquals('CASS Export',operation.Operation_Type__c);
        System.assertEquals(issOperation.Id,operation.ISS_operation__c);
        System.assertEquals(operation.Operation_Code__c + '__RM_' + operation.Period_Code__c ,operation.Operation_Period_code__c);
        System.assertEquals('ISS_Calendar',operation.Recordtype.DeveloperName);
    }
    
    @isTest
    private static void testCreateNotificationtToAgencyCASSUser() {
        insert new Notification_template__c(Subject__c = 'Remittance change in Operational Calendar');
        
        AMS_Settlement_System__c issOperation = new AMS_Settlement_System__c(Name = 'CASS-AN');
        insert issOperation;
        
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(
            Name='Spain',
            ISO_Code__c = 'SP',
            AMS_Settlement_System_CASS__c = issOperation.Id
        );
        insert country;
        
        // use a CASS location class
        String locationClass = 'C'; //CASS Export
        // use a random frequency 
        String frequency = 'D';
        
        Operational_Calendar__c operation = new Operational_Calendar__c(
            Visible_on_the_portal__c = true,
            Operation_Code__c= 'SP_CAS_E_EUR_X',
            Period_Code__c= '20180202M',
            frequency_code__c = frequency,
            Operation_Type__c = ISSP_OperationalCalendarController.MAP_OPERATION_TYPES.get(locationClass)
        );
        insert operation;
        
        Account account = new Account(
            Name = 'Test Account',
            IATA_ISO_Country__c = country.Id,
            Remittance_frequency__c = frequency,
            Location_Class__c = locationClass
        );
        insert account;
        
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= account.Id;
        con.Email = 'Test_' + Math.random() + '@test.com';
        con.User_Portal_Status__c='Administrator';
        con.Status__c = 'Active';
        insert con;

        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        
        User thisuser = [Select Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisuser) {
            newUser.ProfileId = OperationalCalendarHandler.AGENT_PROFILES.get(0);
            update newUser;
            con.OwnerId = newUser.Id;
            update con;
        }
        
        // this query is necessary because the query in OperationalCalendarHandler
        // has a condition using 5 level deep, and that is not working in test classes
        OperationalCalendarHandler.TEST_LIST_AGENCY_USER = queryListUsersWorkaround(new list<Id>{newUser.Id});
            
        Test.StartTest();
        operation.Remittance_Day__c = Date.today();
        update operation;
        Test.stopTest();
        
        list<Notification__c> listNotification = [SELECT Id FROM Notification__c WHERE Contact__c = :con.Id];
        System.assertEquals(1,listNotification.size());
    }
    
    @isTest
    private static void testCreateNotificationtToAirlineBSPUser() {
        Notification_template__c settlementTemplate = new Notification_template__c(Subject__c = 'Settlement change in Operational Calendar');
        Notification_template__c remittanceTemplate = new Notification_template__c(Subject__c = 'Remittance change in Operational Calendar');
        insert new list<Notification_template__c>{settlementTemplate,remittanceTemplate};
        
        AMS_Settlement_System__c issOperation = new AMS_Settlement_System__c(Name = 'BSP-SP');
        insert issOperation;
        
        Operational_Calendar__c operation = new Operational_Calendar__c(
            Visible_on_the_portal__c = true,
            Operation_Code__c= 'SP_CAS_E_EUR_X',
            Period_Code__c= '20180202M'
        );
        insert operation;
        
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(
            Name='Spain',
            ISO_Code__c = 'SP',
            AMS_Settlement_System__c = issOperation.Id
        );
        insert country;
        
        Account account = new Account(
            Name = 'Test Account',
            IATA_ISO_Country__c = country.Id
        );
        insert account;
        
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= account.Id;
        con.Email = 'Test_' + Math.random() + '@test.com';
        con.User_Portal_Status__c='Administrator';
        con.Status__c = 'Active';
        insert con;

        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        
        User thisuser = [Select Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisuser) {
            newUser.ProfileId = OperationalCalendarHandler.AIRLINE_PROFILES.get(0);
            update newUser;
            con.OwnerId = newUser.Id;
            update con;
        }
        
        // this query is necessary because the query in OperationalCalendarHandler
        // has a condition using 5 level deep, and that is not working in test classes
        OperationalCalendarHandler.TEST_LIST_AIRLINE_USER = queryListUsersWorkaround(new list<Id>{newUser.Id});
            
        Test.StartTest();
        operation.Settlement_Day__c = Date.today();
        operation.Remittance_Day__c = Date.today();
        update operation;
        Test.stopTest();
        
        list<Notification__c> listNotification = [SELECT Id FROM Notification__c WHERE Contact__c = :con.Id];
        System.assertEquals(2,listNotification.size());
    }
    
    private static list<User> queryListUsersWorkaround(list<id> listUserId) {
         return [SELECT Id, Contact.Name, Contact.Email,
                Contact.Account.IATA_ISO_Country__c,
                Contact.Account.Remittance_frequency__c,
                Contact.Account.Location_Class__c,
                Contact.Account.IATA_ISO_Country__r.AMS_Settlement_System__c,
                Contact.Account.IATA_ISO_Country__r.AMS_Settlement_System_CASS__c
            FROM User
            WHERE Id IN :listUserId];
    }
}