@isTest
public class ISSP_AvailableServices_Test {

    @testSetup
    static void setup() {
        Portal_Applications__c easyPay1 = new Portal_Applications__c (
                Name = ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_EDENRED,
                ANG_Restrict_by_Agency_Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
                ANG_Accredited_Agents_Only__c = false
            );

        Portal_Applications__c easyPay2 = new Portal_Applications__c (
                Name = ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_MSTS,
                ANG_Restrict_by_Agency_Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
                ANG_Accredited_Agents_Only__c = false
            );

        Portal_Applications__c easyPay3 = new Portal_Applications__c (
                Name = ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_WEX,
                ANG_Restrict_by_Agency_Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
                ANG_Accredited_Agents_Only__c = true
            );

        Portal_Applications__c serviceTest = new Portal_Applications__c (
                Name = 'serviceTest',
                ANG_Restrict_by_Agency_Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
                ANG_Accredited_Agents_Only__c = false
            );

        Portal_Applications__c serviceTest2 = new Portal_Applications__c (
                Name = 'serviceTest2',
                ANG_Restrict_by_Agency_Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
                ANG_Accredited_Agents_Only__c = false
            );


        insert new List<Portal_Applications__c>{easyPay1,easyPay2,easyPay3,serviceTest,serviceTest2};

        IATA_ISO_Country__c portugal = new IATA_ISO_Country__c (
                Name = 'Portugal_test',
                ISO_Code__c = 'PT',
                ANG_Portal_Service__c = easyPay1.id
            );


        IATA_ISO_Country__c switzerland = new IATA_ISO_Country__c (
                Name = 'Switzerland_test',
                ISO_Code__c = 'CH',
                ANG_Portal_Service__c = easyPay2.id
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
                ANG_IEP_Status__c = ANG_ISSP_PortalServiceHelper.STATUS_OPEN
            );

        Account a2 = new Account (
                name = 'AccountTest',
                IATA_ISO_Country__c = switzerland.id,
                Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
                ANG_IEP_Status__c = ANG_ISSP_PortalServiceHelper.STATUS_NO_IEP_ACCOUNT
            );

        Account a3 = new Account (
                name = 'AccountTest',
                IATA_ISO_Country__c = germany.id,
                Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
                ANG_IEP_Status__c = ANG_ISSP_PortalServiceHelper.STATUS_IN_PROGRESS
            );

        Account a4 = new Account (
                name = 'AccountTest4',
                IATA_ISO_Country__c = spain.id,
                Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
                ANG_IEP_Status__c = ANG_ISSP_PortalServiceHelper.STATUS_OPEN
            );

        insert new List<Account>{a,a2,a3,a4};

        Contact c = new Contact (
                LastName = 'ContactTest',
                accountID = a.id
            );

        Contact c2 = new Contact (
                LastName = 'ContactTest2',
                accountId = a2.id
            );

        Contact c3 = new Contact (
                LastName = 'ContactTest3',
                accountId = a3.id
            );


        Contact c4 = new Contact (
                LastName = 'ContactTest4',
                accountId = a4.id
            );

        insert new List<Contact>{c,c2,c3,c4};

    }

	public static testMethod void testServices_1() {
        ISSP_AvailableServices cttr = new ISSP_AvailableServices();
        ISSPServiceListView__c cs = new ISSPServiceListView__c();
        cs.Name = 'Test';
        cs.Profiles_Id__c = Userinfo.getProfileId().substring(0,15);
        cs.Field_Set_API_Name__c = 'ISSP_Available_services';
        cs.SOQL_Filter__c = 'WHERE Name != \'12345\' ';
        cs.Permission_set__c = '0PS200000004CryGAE';
        insert cs;
        
        Portal_Applications__c app = new Portal_Applications__c(Name = 'Management Information Report'); 
        insert app;
        
        cttr.initialization();
        
        cttr.getServiceList();
        
        cttr.getServices();
        cttr.refresh();
        
        cttr.sortExpression = 'Name';
        cttr.getServices();
        cttr.refresh();
        cttr.sortExpression = 'Case_creation_record_type__c';
        cttr.getServices();
        cttr.refresh();
        
        cttr.setSortDirection('DESC');
        system.assertEquals('DESC', cttr.getSortDirection());
        cttr.sortExpression = 'ASC';        
    }
    
    public static testMethod void testServices_2() {
    	
        ISSP_AvailableServices cttr = new ISSP_AvailableServices();

        cttr.initialization();
        
    }
    
    public static testMethod void testServices_3() {
    	
    	Account acc = ISSP_ObjectFactory.createNewAccount();
		insert acc;
		Contact con = ISSP_ObjectFactory.createNewContact();
		insert con;
		Portal_Applications__c app = new Portal_Applications__c(Name = 'Management Information Report'); 
        insert app;
        
        ISSP_AvailableServices cttr = new ISSP_AvailableServices();
        Apexpages.currentPage().getParameters().put('ServId', app.Id);
		
    	cttr.doRequest();
    	ISSP_AvailableServices.newAppsRequest(app.Id, app.Name, con.Id);
    }


    public static testMethod void testEasyPay1() {
        
        Contact c = [select id from contact where lastName = 'ContactTest'];

        Profile p = [SELECT Id FROM Profile WHERE Name='ISS Portal Agency User (Partner)']; 

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
                UserName='newuser@testorg.com'
            );
        
        System.runAs(testeUser1) {
            ISSP_AvailableServices cttr = new ISSP_AvailableServices();
            ISSPServiceListView__c cs = new ISSPServiceListView__c();
            cs.Name = 'Test';
            cs.Profiles_Id__c = Userinfo.getProfileId().substring(0,15);
            cs.Field_Set_API_Name__c = 'ISSP_Available_services';
            cs.SOQL_Filter__c = 'WHERE Name != \'12345\' ';
            cs.Permission_set__c = '0PS200000004CryGAE';
            insert cs;
            
            Portal_Applications__c app = new Portal_Applications__c(Name = 'Management Information Report'); 
            insert app;
            
            cttr.initialization();
            
            List<ISSP_AvailableServices.ServiceWrapper> serviceList = cttr.getServiceList();
            
            cttr.getServices();
            cttr.refresh();
            
            cttr.sortExpression = 'Name';
            cttr.getServices();
            cttr.refresh();
            cttr.sortExpression = 'Case_creation_record_type__c';
            cttr.getServices();
            cttr.refresh();
            
            cttr.setSortDirection('DESC');
            system.assertEquals('DESC', cttr.getSortDirection());
            cttr.sortExpression = 'ASC';
            
            System.assertEquals(serviceList.size(), 3);

            Integer n = 0;
            for (ISSP_AvailableServices.ServiceWrapper line : serviceList) {
                if (line.recordService.name == 'serviceTest' || line.recordService.name == ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_EDENRED) {
                    n++;
                }
            }

            System.assertEquals(n,2);
        }
        
    }


    public static testMethod void testEasyPay2() {

        Contact c2 = [select id from contact where lastName = 'ContactTest2'];

        Profile p = [SELECT Id FROM Profile WHERE Name='ISS Portal Agency User (Partner)']; 

        User testeUser2 = new User (
                Alias = 'newUser2',
                Email='newuser@testorg.com', 
                EmailEncodingKey='UTF-8', 
                LastName='Testing2', 
                LanguageLocaleKey='en_US', 
                ContactId = c2.id,            
                LocaleSidKey='en_US',
                ProfileId = p.Id, 
                TimeZoneSidKey='America/Los_Angeles', 
                UserName='newuser2@testorg.com'
            );

        System.runAs(testeUser2) {
            ISSP_AvailableServices cttr = new ISSP_AvailableServices();
            ISSPServiceListView__c cs = new ISSPServiceListView__c();
            cs.Name = 'Test';
            cs.Profiles_Id__c = Userinfo.getProfileId().substring(0,15);
            cs.Field_Set_API_Name__c = 'ISSP_Available_services';
            cs.SOQL_Filter__c = 'WHERE Name != \'12345\' ';
            cs.Permission_set__c = '0PS200000004CryGAE';
            insert cs;
            
            Portal_Applications__c app = new Portal_Applications__c(Name = 'Management Information Report'); 
            insert app;
            
            cttr.initialization();
            
            List<ISSP_AvailableServices.ServiceWrapper> serviceList = cttr.getServiceList();
            
            cttr.getServices();
            cttr.refresh();
            
            cttr.sortExpression = 'Name';
            cttr.getServices();
            cttr.refresh();
            cttr.sortExpression = 'Case_creation_record_type__c';
            cttr.getServices();
            cttr.refresh();
            
            cttr.setSortDirection('DESC');
            system.assertEquals('DESC', cttr.getSortDirection());
            cttr.sortExpression = 'ASC';

            System.assertEquals(serviceList.size(), 3);

            Integer n = 0;
            for (ISSP_AvailableServices.ServiceWrapper line : serviceList) {
                if (line.recordService.name == 'serviceTest' || line.recordService.name == ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_MSTS) {
                    n++;
                }
            }

            System.assertEquals(n,2);
        }        
    }

    public static testMethod void testEasyPay3() {

        Contact c3 = [select id from contact where lastName = 'ContactTest3'];

        Profile p = [SELECT Id FROM Profile WHERE Name='ISS Portal Agency User (Partner)']; 

        User testeUser3 = new User (
                Alias = 'newUser2', 
                Email='newuser@testorg.com', 
                EmailEncodingKey='UTF-8', 
                LastName='Testing3', 
                LanguageLocaleKey='en_US', 
                ContactId = c3.id,            
                LocaleSidKey='en_US',
                ProfileId = p.Id, 
                TimeZoneSidKey='America/Los_Angeles', 
                UserName='newuser2@testorg.com'
            );

        System.runAs(testeUser3) {
            ISSP_AvailableServices cttr = new ISSP_AvailableServices();
            ISSPServiceListView__c cs = new ISSPServiceListView__c();
            cs.Name = 'Test';
            cs.Profiles_Id__c = Userinfo.getProfileId().substring(0,15);
            cs.Field_Set_API_Name__c = 'ISSP_Available_services';
            cs.SOQL_Filter__c = 'WHERE Name != \'12345\' ';
            cs.Permission_set__c = '0PS200000004CryGAE';
            insert cs;
            
            Portal_Applications__c app = new Portal_Applications__c(Name = 'Management Information Report'); 
            insert app;
            
            cttr.initialization();
            
            List<ISSP_AvailableServices.ServiceWrapper> serviceList = cttr.getServiceList();
            
            cttr.getServices();
            cttr.refresh();
            
            cttr.sortExpression = 'Name';
            cttr.getServices();
            cttr.refresh();
            cttr.sortExpression = 'Case_creation_record_type__c';
            cttr.getServices();
            cttr.refresh();
            
            cttr.setSortDirection('DESC');
            system.assertEquals('DESC', cttr.getSortDirection());
            cttr.sortExpression = 'ASC';

            System.assertEquals(serviceList.size(), 2);

            System.assertEquals(serviceList.get(0).recordService.name, 'serviceTest');

        }        
    }

/*
    public static testMethod void testServices_4() {

        Contact c4 = [select id from contact where lastName = 'ContactTest4'];

        Portal_Applications__c serviceTest2 = [select id from Portal_Applications__c where name = 'serviceTest2'];

        system.debug(LoggingLevel.ERROR, '--CON ID 2 : ' + c4.id);

        Profile p = [SELECT Id FROM Profile WHERE Name='ISS Portal Agency Delegated Admin User']; 

        User testeUser4 = new User (
                Alias = 'newUser',
                Email='newuser@testorg.com', 
                EmailEncodingKey='UTF-8', 
                LastName='Testing',
                LanguageLocaleKey='en_US', 
                ContactId = c4.id,            
                LocaleSidKey='en_US',
                ProfileId = p.Id, 
                TimeZoneSidKey='America/Los_Angeles', 
                UserName='newuser2@testorg.com'
            );
        
        System.runAs(testeUser4) {
            ISSPServiceListView__c cs = new ISSPServiceListView__c();
            cs.Name = 'Test';
            cs.Profiles_Id__c = Userinfo.getProfileId().substring(0,15);
            cs.Field_Set_API_Name__c = 'ISSP_Available_services';
            cs.SOQL_Filter__c = 'WHERE Name != \'12345\' ';
            cs.Permission_set__c = '0PS200000004CryGAE';
            insert cs;
            
            Portal_Applications__c app = new Portal_Applications__c(Name = 'Management Information Report'); 
            insert app;

            Portal_Application_Right__c rightApp = new Portal_Application_Right__c (
                    Right__c = 'Access Granted',
                    Contact__c = c4.id,
                    Portal_Application__c = serviceTest2.id
                );

            insert rightApp;            

            ISSP_AvailableServices cttr = new ISSP_AvailableServices();

            cttr.initialization();
            
            List<ISSP_AvailableServices.ServiceWrapper> serviceList = cttr.getServiceList();

            cttr.getServices();
            cttr.refresh();
            
            cttr.sortExpression = 'Name';
            cttr.getServices();
            cttr.refresh();
            cttr.sortExpression = 'Case_creation_record_type__c';
            cttr.getServices();
            cttr.refresh();
            
            cttr.setSortDirection('DESC');
            system.assertEquals('DESC', cttr.getSortDirection());
            cttr.sortExpression = 'ASC';

        }                      
    }
    */
}