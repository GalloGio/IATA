@isTest
public class ISSP_AvailableServices_Test {

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

        insert new List<Portal_Application_Right__c>{appRight,appRight2};
        /*
        Connected_App_Roles__c car = new Connected_App_Roles__c(
            Name = 'ANG Test2',
            Connected_App__c = 'IATA EasyPay (EDENRED)',
            Permission_set_SSO__c = 'IEP_EdenRed',
            Role__c = 'IEP Admin',
            Default_User_Role__c = true,
            Min_Users_With_Role__c = 2
        );
        insert car;
        */

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
            ISSP_AvailableServices cttr = new ISSP_AvailableServices();
            ISSPServiceListView__c cs = new ISSPServiceListView__c();
            cs.Name = 'Test';
            cs.Profiles_Id__c = Userinfo.getProfileId().substring(0,15);
            cs.Field_Set_API_Name__c = 'ISSP_Available_services';
            cs.SOQL_Filter__c = 'WHERE Name != \'12345\' ';
            cs.Permission_set__c = '0PS200000004CryGAE';
            insert cs;
            
            Portal_Applications__c app = new Portal_Applications__c(Name = '--Management Information Report'); 
            insert app;

            Portal_Applications__c app2 = new Portal_Applications__c(Name = '--Treasury Dashboard - Premium'); 
            insert app2;

            Portal_Application_Right__c appRight = new Portal_Application_Right__c(
                Portal_Application__c = app.id,
                Right__c = 'Access Granted',
                Contact__c = [select Id,ContactId from User where Id =:Userinfo.getUserId()].ContactId
            );
            //insert appRight;

            Portal_Application_Right__c appRight2 = new Portal_Application_Right__c(
                Portal_Application__c = app.id,
                Right__c = 'Access Granted',
                Contact__c = [select Id,ContactId from User where Id =:Userinfo.getUserId()].ContactId
            );
            //insert appRight2;
            
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
            cttr.submitRequest();
            
            cttr.setSortDirection('DESC');
            system.assertEquals('DESC', cttr.getSortDirection());
            cttr.sortExpression = 'ASC';
            
            System.assertEquals(serviceList.size(), 7);

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

            System.assertEquals(serviceList.size(), 6);

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
            system.debug('aqui serviceList ' + serviceList);
            System.assertEquals(serviceList.size(), 6);

            System.assertEquals(serviceList.get(0).recordService.name, 'IATA EasyPay (EDENRED)');

        }        
    }


    

    public static testMethod void testEasyPay5() {
        
        Contact c = [select id from contact where lastName = 'ContactTest'];

        Profile p = [SELECT Id FROM Profile WHERE Name='ISS Portal Agency User (Partner)']; 

        //User testeUser1 = new User (
        //        Alias = 'newUser', 
        //        Email='newuser@testorg.com', 
        //        EmailEncodingKey='UTF-8', 
        //        LastName='Testing1', 
        //        LanguageLocaleKey='en_US', 
        //        ContactId = c.id,            
        //        LocaleSidKey='en_US',
        //        ProfileId = p.Id, 
        //        TimeZoneSidKey='America/Los_Angeles', 
        //        UserName='newuser@testorg.com'
        //    );
        
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
        
           
        
    }

    public static testMethod void testEasyPay6() {
        
        Contact c = [select id from contact where lastName = 'ContactTest'];

        Account a = [Select Id from Account Where name = 'AccountTest4'];

        c.accountId = a.id;

        update c;

        Profile p = [SELECT Id FROM Profile WHERE Name='ISS Portal Agency User (Partner)']; 
        
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
        
           
        
    }

    public static testMethod void testEasyPay7() {
        
        Contact c = [select id from contact where lastName = 'ContactTest3'];

        Account a = [Select Id from Account Where name = 'AccountTest3'];

        c.accountId = a.id;

        update c;

        Profile p = [SELECT Id FROM Profile WHERE Name='ISS Portal Agency User (Partner)']; 
        
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
        
    }


    public static testMethod void testnewAppsRequest2() {
        
        Test.startTest();

        Account acc = ISSP_ObjectFactory.createNewAccount();
        insert acc;
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = acc.id;
        insert con;

        Portal_Applications__c app = new Portal_Applications__c(Name = 'Standards Setting Workspace',
                ANG_Restrict_by_Agency_Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
                ANG_Accredited_Agents_Only__c = false,
                Agency__c = true); 
        insert app;

        Portal_Applications__c easyPay1 = new Portal_Applications__c (
                Name = ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_EDENRED,
                //ANG_Restrict_by_Agency_Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
                ANG_Accredited_Agents_Only__c = false                
            );
        

        Portal_Applications__c easyPay2 = new Portal_Applications__c (
                Name = ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_MSTS,
                //ANG_Restrict_by_Agency_Sector__c = ANG_ISSP_PortalServiceHelper.CARGO_AGENT,
                ANG_Accredited_Agents_Only__c = false                
            );


        insert new List<Portal_Applications__c>{easyPay1, easyPay2};
        
        ISSP_AvailableServices cttr = new ISSP_AvailableServices();

        ISSP_AvailableServices.newAppsRequest2 (easyPay1.Id, easyPay1.Name, con.Id, 'portalServiceRole', false, 'defaultPortalUserRole');

        ISSP_AvailableServices.newAppsRequest2 (easyPay2.Id, easyPay2.Name, con.Id, 'portalServiceRole', true, 'defaultPortalUserRole');

        ISSP_AvailableServices.newAppsRequest2 (app.Id, app.Name, con.Id, 'portalServiceRole', false, 'defaultPortalUserRole');

        Test.stopTest();

    }

    public static testMethod void testPoolerMethods() {


        Contact c3 = [select id from contact where lastName = 'ContactTest3'];

        Profile p = [SELECT Id FROM Profile WHERE Name='ISS Portal Agency User (Partner)']; 

        Portal_Applications__c easyPayServ = [Select id, name From Portal_Applications__c where name =: ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_EDENRED Limit 1];

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
            Test.startTest();

            PermissionSet pSet = new PermissionSet(Name = 'IEP_EdenRed_test', Label='IEP_EdenRed_test');
            insert pSet;
            
            PermissionSet ps = [Select id From PermissionSet Where name = 'IEP_EdenRed_test' Limit 1];

            PermissionSetAssignment psa = new PermissionSetAssignment(
                AssigneeId = UserInfo.getUserId(),
                PermissionSetId = ps.id
            );

            insert psa;

            ISSP_AvailableServices cttr = new ISSP_AvailableServices();

            ISSP_AvailableServices.ServiceWrapper sr = new ISSP_AvailableServices.ServiceWrapper(easyPayServ, 'Open', true, true);

            cttr.Serv = sr;

            PageReference page = cttr.setPollerOff();
            page = cttr.iepPermissionSetPoller();

            Test.stopTest();
        }
    }   


    public static testMethod void testnewAppsRequest3() {
            
        Account acc = ISSP_ObjectFactory.createNewAccount();        
        acc.Location_Type__c = 'HO';

        insert acc;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.lastName = 'IATA';
        con.AccountId = acc.id;
        con.Authorized_Signatory__c = true;

        insert con;

        Test.startTest();

        Profile p = [SELECT Id FROM Profile WHERE Name='ISS Portal Agency Delegated Admin User']; 

        User testeUser3 = new User (
                Alias = 'newUser2', 
                Email='newuser@testorg.com', 
                EmailEncodingKey='UTF-8', 
                LastName='Testing3', 
                LanguageLocaleKey='en_US', 
                ContactId = con.id,            
                LocaleSidKey='en_US',
                ProfileId = p.Id, 
                TimeZoneSidKey='America/Los_Angeles', 
                UserName='newuser2@testorg.com',
                License_Cost_Center__c = 'XSMW01JO01'
            );

        System.runAs(testeUser3) {

            Account acc2 = ISSP_ObjectFactory.createNewAccount();        
            acc2.Location_Type__c = 'HO';
            acc2.ANG_IEP_Status__c = 'In Progress';

            insert acc2;    

            //Account.Location_Type__c,
            //Account.Top_Parent__r.Location_Type__c, 
            
            //Account.Is_Branch_Abroad__c = true;
            //Account.Status__c

            Contact con2 = ISSP_ObjectFactory.createNewContact();
            con2.AccountId = acc2.id;
            con2.Authorized_Signatory__c = true;
            //con2.User_Portal_Status__c =

            insert con2;
            
            ISSP_AvailableServices cttr = new ISSP_AvailableServices();

            cttr.initialization();
        }
        Test.stopTest();
    }     

    public static testMethod void testnewAppsRequest4() {
            
        Account acc = ISSP_ObjectFactory.createNewAccount();        

        insert acc;


        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = acc.id;

        insert con;

        Test.startTest();

        Profile p = [SELECT Id FROM Profile WHERE Name='ISS Portal Agency Delegated Admin User']; 

        User testeUser3 = new User (
                Alias = 'newUser2', 
                Email='newuser@testorg.com', 
                EmailEncodingKey='UTF-8', 
                LastName='Testing3', 
                LanguageLocaleKey='en_US', 
                ContactId = con.id,            
                LocaleSidKey='en_US',
                ProfileId = p.Id, 
                TimeZoneSidKey='America/Los_Angeles', 
                UserName='newuser2@testorg.com',
                License_Cost_Center__c = 'XSMW01JO01'
            );

        System.runAs(testeUser3) {

            Account acc2 = ISSP_ObjectFactory.createNewAccount();        
            acc2.Location_Type__c = 'HO';

            insert acc2;

            Contact con2 = ISSP_ObjectFactory.createNewContact();
            con2.lastName = 'IATA';
            con2.AccountId = acc2.id;
            con2.Authorized_Signatory__c = false;

            insert con2;
            
            ISSP_AvailableServices cttr = new ISSP_AvailableServices();

            cttr.initialization();
        }
        Test.stopTest();
    }    

    public static testMethod void testnewAppsRequest5() {
            
        Account acc = ISSP_ObjectFactory.createNewAccount();        

        insert acc;


        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = acc.id;

        insert con;

        Test.startTest();

        Profile p = [SELECT Id FROM Profile WHERE Name='ISS Portal Agency Delegated Admin User']; 

        User testeUser3 = new User (
                Alias = 'newUser2', 
                Email='newuser@testorg.com', 
                EmailEncodingKey='UTF-8', 
                LastName='Testing3', 
                LanguageLocaleKey='en_US', 
                ContactId = con.id,            
                LocaleSidKey='en_US',
                ProfileId = p.Id, 
                TimeZoneSidKey='America/Los_Angeles', 
                UserName='newuser2@testorg.com',
                License_Cost_Center__c = 'XSMW01JO01'
            );

        System.runAs(testeUser3) {
            
            IATA_ISO_Country__c portugal = [Select Id from IATA_ISO_Country__c where Name = 'Portugal_test'];

            Account acc2 = ISSP_ObjectFactory.createNewAccount();        
            acc2.ANG_IEP_Status__c = 'Open';
            acc2.Location_Type__c = 'HE';
            acc2.Location_Class__c = 'P';
            acc2.IATA_ISO_Country__c = portugal.Id;

            insert acc2;

            Contact con2 = ISSP_ObjectFactory.createNewContact();
            con2.lastName = 'IATA';
            con2.AccountId = acc2.id;
            con2.Authorized_Signatory__c = false;

            insert con2;
            
            ISSP_AvailableServices cttr = new ISSP_AvailableServices();

            cttr.initialization();
        }
        Test.stopTest();
    }    


    public static testMethod void testnewAppsRequest6() {
            
        Account acc = ISSP_ObjectFactory.createNewAccount();        

        insert acc;


        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = acc.id;

        insert con;

        Test.startTest();

        Profile p = [SELECT Id FROM Profile WHERE Name='ISS Portal Agency Delegated Admin User']; 

        User testeUser3 = new User (
                Alias = 'newUser2', 
                Email='newuser@testorg.com', 
                EmailEncodingKey='UTF-8', 
                LastName='Testing3', 
                LanguageLocaleKey='en_US', 
                ContactId = con.id,            
                LocaleSidKey='en_US',
                ProfileId = p.Id, 
                TimeZoneSidKey='America/Los_Angeles', 
                UserName='newuser2@testorg.com',
                License_Cost_Center__c = 'XSMW01JO01'
            );

        System.runAs(testeUser3) {

            Account acc2 = ISSP_ObjectFactory.createNewAccount();        
            acc2.ANG_IEP_Status__c = 'Open';
            acc2.Location_Type__c = 'AO';

            insert acc2;

            Contact con2 = ISSP_ObjectFactory.createNewContact();
            con2.lastName = 'IATA';
            con2.AccountId = acc2.id;
            con2.Authorized_Signatory__c = false;

            insert con2;

            Connected_App_Roles__c car = new Connected_App_Roles__c(
                Name = 'ANG Test2',
                Connected_App__c = 'IATA EasyPay (EDENRED)',
                Permission_set_SSO__c = 'IEP_EdenRed',
                Role__c = 'IEP Admin',
                Default_User_Role__c = true,
                Min_Users_With_Role__c = 2
            );
            insert car;

            Portal_Applications__c easyPay1 = new Portal_Applications__c (
                    Name = ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_EDENRED,
                    ANG_Restrict_by_Agency_Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
                    ANG_Accredited_Agents_Only__c = false,
                    Agency__c = true
                );

            insert easyPay1;
            
            ISSP_AvailableServices cttr = new ISSP_AvailableServices();

            cttr.Serv = new ISSP_AvailableServices.ServiceWrapper(easyPay1, 'Open', true, true);

            cttr.initialization();

            List<ISSP_AvailableServices.SelectOption2> l = cttr.availablePortalServiceRoles;
        }
        Test.stopTest();
    }

    public static testMethod void testnewAppsRequest7() {
            
        Account acc = ISSP_ObjectFactory.createNewAccount();        

        insert acc;


        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = acc.id;

        insert con;

        Test.startTest();

        Profile p = [SELECT Id FROM Profile WHERE Name='ISS Portal Agency Delegated Admin User']; 

        User testeUser3 = new User (
                Alias = 'newUser2', 
                Email='newuser@testorg.com', 
                EmailEncodingKey='UTF-8', 
                LastName='Testing3', 
                LanguageLocaleKey='en_US', 
                ContactId = con.id,            
                LocaleSidKey='en_US',
                ProfileId = p.Id, 
                TimeZoneSidKey='America/Los_Angeles', 
                UserName='newuser2@testorg.com',
                License_Cost_Center__c = 'XSMW01JO01'
            );

        System.runAs(testeUser3) {

            Account acc2 = ISSP_ObjectFactory.createNewAccount();        
            acc2.ANG_IEP_Status__c = ANG_ISSP_PortalServiceHelper.STATUS_NO_IEP_ACCOUNT;
            acc2.Location_Type__c = 'AO';

            insert acc2;

            Contact con2 = ISSP_ObjectFactory.createNewContact();
            con2.lastName = 'IATA';
            con2.AccountId = acc2.id;
            con2.Authorized_Signatory__c = false;

            insert con2;

            Connected_App_Roles__c car = new Connected_App_Roles__c(
                Name = 'ANG Test2',
                Connected_App__c = 'IATA EasyPay (EDENRED)',
                Permission_set_SSO__c = 'IEP_EdenRed',
                Role__c = 'IEP Admin',
                Default_User_Role__c = true,
                Min_Users_With_Role__c = 2
            );
            insert car;

            Portal_Applications__c easyPay1 = new Portal_Applications__c (
                    Name = ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_EDENRED,
                    ANG_Restrict_by_Agency_Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
                    ANG_Accredited_Agents_Only__c = false,
                    Agency__c = true
                );

            insert easyPay1;
            
            ISSP_AvailableServices cttr = new ISSP_AvailableServices();

            cttr.Serv = new ISSP_AvailableServices.ServiceWrapper(easyPay1, ANG_ISSP_PortalServiceHelper.STATUS_NO_IEP_ACCOUNT, true, true);

            String x = cttr.Serv.portalServiceRole;

            cttr.initialization();

            List<ISSP_AvailableServices.SelectOption2> l = cttr.availablePortalServiceRoles;
        }
        Test.stopTest();
    }    
    
}