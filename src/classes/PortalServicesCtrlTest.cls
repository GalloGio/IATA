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

        insert new List<Portal_Applications__c>{easyPay1,easyPay2,easyPay3,serviceTest,serviceTest2};

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

        insert new List<IATA_ISO_Country__c>{portugal,switzerland,germany,spain};

        Account a = new Account (
                name = 'AccountTest',
                IATA_ISO_Country__c = portugal.id,
                Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
                ANG_IEP_Status__c = ANG_ISSP_PortalServiceHelper.STATUS_OPEN,
                Location_type__c = 'HE',
                OwnerId = UserInfo.getUserId(),
                Location_Class__c = 'P'
            );

        Account a2 = new Account (
                name = 'AccountTest',
                IATA_ISO_Country__c = switzerland.id,
                Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
                ANG_IEP_Status__c = ANG_ISSP_PortalServiceHelper.STATUS_NO_IEP_ACCOUNT,
                Location_type__c = 'HE',
                OwnerId = UserInfo.getUserId(),
                Location_Class__c = 'P'
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
                accountID = a.id
            );

        Contact c2 = new Contact (
                LastName = 'ContactTest2',
                FirstName = 'Name',
                accountId = a2.id
            );

        Contact c3 = new Contact (
                LastName = 'ContactTest3',
                FirstName = 'Name',
                accountId = a3.id
            );

        Contact c4 = new Contact (
                LastName = 'ContactTest4',
                FirstName = 'Name',
                accountId = a4.id
            );

        insert new List<Contact>{c,c2,c3,c4};

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

        insert new List<Portal_Application_Right__c>{appRight,appRight2,appRight3};

    }


    @isTest
    public static void PortalServicesCtrlTest_getAccessGrantedServices() {

        Contact c = [select id from contact where lastName = 'ContactTest2'];

        //Profile p = [SELECT Id FROM Profile WHERE Name='ISS Portal Agency User (Partner)']; 
        Profile p = [SELECT Id FROM Profile WHERE Name='ISS Portal Agency Delegated Admin User']; 


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
            Test.StartTest();

            List<Portal_Application_Right__c> lstResults = PortalServicesCtrl.getAccessGrantedServices();
            System.assertEquals(lstResults.size() > 0, true);

            Test.StopTest();
        }
    }

    @isTest
    public static void PortalServicesCtrlTest_getAccessRequestedServices() {
        Contact c = [select id from contact where lastName = 'ContactTest3'];

        //Profile p = [SELECT Id FROM Profile WHERE Name='ISS Portal Agency User (Partner)']; 
        Profile p = [SELECT Id FROM Profile WHERE Name='ISS Portal Agency Delegated Admin User']; 


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
            Test.StartTest();

            List<Portal_Application_Right__c> lstResults = PortalServicesCtrl.getAccessRequestedServices();
            System.assertEquals(lstResults.size() > 0, true);

            Test.StopTest();
        }
    }

    @isTest
    public static void PortalServicesCtrlTest_getUserServicesList() {
        Contact c = [select id from contact where lastName = 'ContactTest'];

        //Profile p = [SELECT Id FROM Profile WHERE Name='ISS Portal Agency User (Partner)']; 
        Profile p = [SELECT Id FROM Profile WHERE Name='ISS Portal Agency Delegated Admin User']; 


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
            Test.StartTest();

            PortalServicesCtrl.FilteringObject filteringObjectAux = new PortalServicesCtrl.FilteringObject();
            filteringObjectAux.searchText = '' + ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_MSTS;

            String filteringObjectAuxStr = JSON.serialize(filteringObjectAux);


            List<Portal_Application_Right__c> lstResults = PortalServicesCtrl.getUserServicesList(filteringObjectAuxStr);
            System.assertEquals(lstResults.size() == 0, true);

            Test.StopTest();
        }
    }

    @isTest
    public static void PortalServicesCtrlTest_getFavoriteServicesList() {

        Contact c = [select id from contact where lastName = 'ContactTest'];

        //Profile p = [SELECT Id FROM Profile WHERE Name='ISS Portal Agency User (Partner)']; 
        Profile p = [SELECT Id FROM Profile WHERE Name='ISS Portal Agency Delegated Admin User']; 


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
            Test.StartTest();

            List<Portal_Application_Right__c> lstResults = PortalServicesCtrl.getFavoriteServicesList();
            System.assertEquals(lstResults.size() > 0, true);

            Test.StopTest();
        }
    }

    @isTest
    public static void PortalServicesCtrlTest_getFavoriteServicesList_noRightsGiven() {

        Contact c = [select id from contact where lastName = 'ContactTest3'];

        //Profile p = [SELECT Id FROM Profile WHERE Name='ISS Portal Agency User (Partner)']; 
        Profile p = [SELECT Id FROM Profile WHERE Name='ISS Portal Agency Delegated Admin User']; 


        List<Portal_Applications__c> lstApps = [SELECT Id from Portal_Applications__c];
        Database.delete(lstApps);

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
            Test.StartTest();

            List<Portal_Application_Right__c> lstResults = PortalServicesCtrl.getFavoriteServicesList();
            System.assertEquals(lstResults.size() == 0, true);

            Test.StopTest();
        }
    }

    @isTest
    public static void PortalServicesCtrlTest_goToOldPortalService() {
        Test.StartTest();

        PortalServicesCtrl.goToOldPortalService('');

        Test.StopTest();
        
    }


}
