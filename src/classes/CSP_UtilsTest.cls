@isTest
private class CSP_UtilsTest {

    @TestSetup
    static void testSetup(){
        Account newAcc = new Account(Name='Account Test CSP Utils');
        insert newAcc;

        Contact newCon1 = new Contact(AccountId = newAcc.Id, FirstName = 'John', LastName = 'Doe', Email = System.today().dayOfYear() + 'testemail1@csp.testclass', User_Portal_Status__c = 'Approved Admin');
        Contact newCon2 = new Contact(AccountId = newAcc.Id, FirstName = 'CSP', LastName = 'Tester', Email = System.today().dayOfYear() + 'testemail2@csp.testclass', User_Portal_Status__c = 'Pending Approval');
        insert new List<Contact>{newCon1, newCon2};

        User newUser = ISSP_ObjectFactory.createPortalUser(newCon1);
        
        Portal_Applications__c pa1 = new Portal_Applications__c(Name = 'Portal Service 1', Cannot_be_managed_by_portal_admin__c = false);
        Portal_Applications__c pa2 = new Portal_Applications__c(Name = 'Portal Service 2', Cannot_be_managed_by_portal_admin__c = true);
        insert new List<Portal_Applications__c>{pa1, pa2};

        Portal_Application_Right__c par1 = new Portal_Application_Right__c(Contact__c = newCon2.Id, Portal_Application__c = pa1.Id, Right__c = 'Access Requested');
        Portal_Application_Right__c par2 = new Portal_Application_Right__c(Contact__c = newCon2.Id, Portal_Application__c = pa2.Id, Right__c = 'Access Requested');
        insert new List<Portal_Application_Right__c>{par1, par2};

        Notification__c not1 = new Notification__c(Archive__c = false, Contact__c = newCon1.Id, Message__c = 'Test Notification - Archive False', Number_of_views__c = 0);
        Notification__c not2 = new Notification__c(Archive__c = true, Contact__c = newCon1.Id, Message__c = 'Test Notification - Archive True', Number_of_views__c = 0);
        Notification__c not3 = new Notification__c(Archive__c = true, Contact__c = newCon1.Id, Message__c = 'Test Notification - More views', Number_of_views__c = 3);
        insert new List<Notification__c>{not1,not2,not3};

    }

    @IsTest
    static void testGetSelectedColumns(){

        Test.startTest();
        Map<String, String> result = CSP_Utils.getSelectedColumns('Case', new List<String>{'CaseNumber', 'CurrencyIsoCode', 'Origin'});
        Test.stopTest();

        System.assertEquals('Case Number', result.get('CaseNumber'));
        System.assertEquals('Case Currency', result.get('CurrencyIsoCode'));
        System.assertEquals('Case Origin', result.get('Origin'));
    }

    @IsTest
    static void testGetNotificationsCountAdmin(){

        User usr = [SELECT Id FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];
        String notifications = '';
        System.runAs(usr) {
            Test.startTest();
            notifications = CSP_Utils.getNotificationsCount();
            Test.stopTest();
        }

        System.assertEquals('3', notifications);
    }

    @IsTest
    static void testGetNotificationsCountNotAdmin(){

        Contact con = [SELECT Id, User_Portal_Status__c FROM Contact WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];
        con.User_Portal_Status__c = '';
        con.Community__c = 'CS Portal';
        update con;

        User usr = [SELECT Id FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];

        String notifications = '';
        System.runAs(usr) {
            Test.startTest();
            notifications = CSP_Utils.getNotificationsCount();
            Test.stopTest();
        }

        System.assertEquals('1', notifications);
    }
}
