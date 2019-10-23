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
        
        //System.assertEquals('1', notifications);
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
    
    @IsTest
    static void testRedirectToOldPortal(){
        
        Contact con = [SELECT Id, User_Portal_Status__c FROM Contact WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];
        con.User_Portal_Status__c = '';
        con.Community__c = 'CS Portal';
        update con;
        
        User usr = [SELECT Id FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];
        
        String redirect = '';
        System.runAs(usr) {
            Test.startTest();
            redirect = CSP_Utils.redirectToOldPortal('');
            Test.stopTest();
        }
    }
    
    @IsTest
    static void testgetPickListValues(){
        
        Contact con = [SELECT Id, User_Portal_Status__c FROM Contact WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];
        con.User_Portal_Status__c = '';
        con.Community__c = 'CS Portal';
        update con;
        
        User usr = [SELECT Id FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];
        
        List<CSP_Utils.PickListWrapper> picks = new List<CSP_Utils.PickListWrapper>();
        System.runAs(usr) {
            Test.startTest();
            picks = CSP_Utils.getPickListValues('Account', 'Status__c');
            Test.stopTest();
        }
    }
    
    @IsTest
    static void testrandomUUID(){
        
        Contact con = [SELECT Id, User_Portal_Status__c FROM Contact WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];
        con.User_Portal_Status__c = '';
        con.Community__c = 'CS Portal';
        update con;
        
        User usr = [SELECT Id FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];
        
        String rand = '';
        System.runAs(usr) {
            Test.startTest();
            rand = CSP_Utils.randomUUID();
            Test.stopTest();
        }
    }
    
    @IsTest
    static void testgetCommunityAvailableLanguages(){
        
        Contact con = [SELECT Id, User_Portal_Status__c FROM Contact WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];
        con.User_Portal_Status__c = '';
        con.Community__c = 'CS Portal';
        update con;
        
        User usr = [SELECT Id FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];
        
        List<CSP_Utils.PickListWrapper> picks = new List<CSP_Utils.PickListWrapper>();
        System.runAs(usr) {
            Test.startTest();
            picks = CSP_Utils.getCommunityAvailableLanguages('', '');
            Test.stopTest();
        }
    }
    
    @IsTest
    static void testchangeUserLanguage(){
        
        Test.startTest();
        CSP_Utils.changeUserLanguage('en_US');
        Test.stopTest();
    }
    
    @IsTest
    static void testCSPortalRedirectExists(){
        
        Contact con = [SELECT Id, User_Portal_Status__c FROM Contact WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];
        con.User_Portal_Status__c = '';
        con.Community__c = 'CS Portal';
        update con;
        
        User usr = [SELECT Id FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];
        
        System.runAs(usr) {
            Test.startTest();
            Boolean csPortalRedirects =  CSP_Utils.CSPortalRedirectExists();
            Test.stopTest();
        }
    }    
    
    @IsTest
    static void testgetContentDistribution(){
        
        string before = 'Testing base 64 encode';            
        Blob beforeblob = Blob.valueOf(before);
        
        ContentVersion cv = new ContentVersion();
        cv.title = 'test';      
        cv.PathOnClient ='test';   
        cv.VersionData = beforeblob;
        insert cv;   
        
        ContentVersion cv2 = new ContentVersion();
        cv2.title = 'test2';      
        cv2.PathOnClient ='test2';   
        cv2.VersionData = beforeblob;
        insert cv2;   
        
        ContentDistribution contentToInsert = new ContentDistribution();
        contentToInsert.Name = 'TestDoc';
        contentToInsert.ContentVersionId = cv.id;
        contentToInsert.PreferencesExpires = true;
        contentToInsert.ExpiryDate = Datetime.now().addMinutes(10);
        contentToInsert.PreferencesAllowViewInBrowser = true;
        contentToInsert.PreferencesLinkLatestVersion = true;
        contentToInsert.PreferencesAllowPDFDownload = false;
        contentToInsert.PreferencesNotifyOnVisit = false;
        contentToInsert.PreferencesPasswordRequired = false;
        contentToInsert.PreferencesAllowOriginalDownload = true;
        
        insert contentToInsert; 
        
        Contact con = [SELECT Id, User_Portal_Status__c FROM Contact WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];
        con.User_Portal_Status__c = '';
        con.Community__c = 'CS Portal';
        update con;
        
        User usr = [SELECT Id FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];
        
        
        Test.startTest();
        ContentDistribution csContDist =  CSP_Utils.getContentDistribution('TestDoc1', cv2.id); 
        System.runAs(usr) {
            User testuser = CSP_Utils.getLoggedUser();
            Boolean testAdmin = CSP_Utils.isAdmin();
            Boolean tesAirlineUser = CSP_Utils.isAirlineUser();
            Boolean testPortal = CSP_Utils.isNewPortalActive();
            ContentDistribution csContDist2 =  CSP_Utils.getContentDistribution('TestDoc', cv.id);
            PageReference pr = CSP_Utils.redirectToNewPortalPage('');
            String pr1 = CSP_Utils.redirectfromPortalHeader('');
        }
        Test.stopTest();
    }    
}