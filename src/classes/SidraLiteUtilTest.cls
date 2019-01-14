@isTest
public class SidraLiteUtilTest {

    @isTest
    public static void testgetDefaultRegion1() {
        UserRole role = new USerRole(Name='Africa & ME');
        insert role;
        
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User testUser = New User(
            Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = testProfile.Id, UserRoleId = role.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test.username@test.com',
            License_Cost_Center__c = 'ISF005CH01'
        );
        insert testUser;
        string result;
        Test.startTest();
        System.RunAs(testUser){
            result = SidraLiteUtil.getDefaultRegion();
        }
        Test.stopTest();
           
        System.assertEquals('Africa & Middle East', result);
        
    }
    
    @isTest
    public static void testgetDefaultRegion2() {
        UserRole role = new USerRole(Name='Americas');
        insert role;
        
       Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User testUser = New User(
            Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = testProfile.Id, UserRoleId = role.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test.username@test.com',
            License_Cost_Center__c = 'ISF005CH01'
        );
        insert testUser;
        
        string result;
        Test.startTest();
        System.RunAs(testUser){
            result = SidraLiteUtil.getDefaultRegion();
        }
        Test.stopTest();
        
        System.assertEquals('Americas', result);
        
    }
    
    @isTest
    public static void testgetDefaultRegion3() {
        UserRole role = new USerRole(Name='A&P');
        insert role;
        
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User testUser = New User(
            Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = testProfile.Id, UserRoleId = role.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test.username@test.com',
            License_Cost_Center__c = 'ISF005CH01'
        );
        insert testUser;
        
        string result;
        Test.startTest();
        System.RunAs(testUser){
            result = SidraLiteUtil.getDefaultRegion();
        }
        Test.stopTest();
        
        System.assertEquals('Asia & Pacific', result);
        
        
    }
    
    @isTest
    public static void testgetDefaultRegion4() {
        UserRole role = new USerRole(Name='China');
        insert role;
        
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User testUser = New User(
            Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = testProfile.Id, UserRoleId = role.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test.username@test.com',
            License_Cost_Center__c = 'ISF005CH01'
        );
        insert testUser;
        
        string result;
        Test.startTest();
        System.RunAs(testUser){
            result = SidraLiteUtil.getDefaultRegion();
        }
        Test.stopTest();
        
        System.assertEquals('China & North Asia', result);
        
    }
    
    @isTest
    public static void testgetDefaultRegion5() {
        UserRole role = new USerRole(Name='MAD');
        insert role;
        
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User testUser = New User(
            Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = testProfile.Id, UserRoleId = role.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test.username@test.com',
            License_Cost_Center__c = 'ISF005CH01'
        );
        insert testUser;
        
        string result;
        Test.startTest();
        System.RunAs(testUser){
            result = SidraLiteUtil.getDefaultRegion();
        }
        Test.stopTest();
        System.assertEquals('Europe', result);
        
    }

    @isTest
    public static void testgetDefaultRegion_ERROR() {
        Test.startTest();
        String result = SidraLiteUtil.getDefaultRegion();
        Test.stopTest();
        
        System.assertEquals('', result);
    }
    
    @isTest
    public static void testisPassenger_ERROR() {
        Test.startTest();
        try {
            Boolean result = SidraLiteUtil.isPassenger(null);
            System.assert(false, 'Exception expected');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testisPassenger_OK() {
        Account account = new Account(Name='test', Type='IATA Passenger Sales Agent');
        Test.startTest();
        Boolean result = SidraLiteUtil.isPassenger(account);
        System.assertEquals(true, result);
        Test.stopTest();
    }
    
    @isTest
    public static void testisCargoCASS_ERROR() {
        Test.startTest();
        try {
            Boolean result = SidraLiteUtil.isCargoCASS(null);
            System.assert(false, 'Exception expected');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testisCargoCASS_OK() {
        Account account = new Account(Name='test', Type='IATA Cargo Agent');
        Test.startTest();
        Boolean result = SidraLiteUtil.isCargoCASS(account);
        System.assertEquals(true, result);
        Test.stopTest();
    }
    
    @isTest
    public static void testisAgent_ERROR() {
        Test.startTest();
        try {
            Boolean result = SidraLiteUtil.isAgent(null);
            System.assert(false, 'Exception expected');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testisAgent_OK() {
        Account account = new Account(Name='test', Type='TIDS Agent');
        Test.startTest();
        Boolean result = SidraLiteUtil.isAgent(account);
        System.assertEquals(true, result);
        Test.stopTest();
    }
    
    @isTest
    public static void testgetBSPCASS_ERROR() {
        Test.startTest();
        try {
            String result = SidraLiteUtil.getBSPCASS(null);
            System.assert(false, 'Exception expected');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testgetBSPCASS_IsBSP() {
        Account account = new Account(Name='test', Type='TIDS Agent');
        Test.startTest();
        String result = SidraLiteUtil.getBSPCASS(account);
        System.assertEquals('BSP', result);
        Test.stopTest();
    }
    
    @isTest
    public static void testgetBSPCASS_IsCASS() {
        Account account = new Account(Name='test', Type='IATA Cargo Agent');
        Test.startTest();
        String result = SidraLiteUtil.getBSPCASS(account);
        System.assertEquals('CASS', result);
        Test.stopTest();
    }
    
    @isTest
    public static void testgetBSPCASS_Else() {
        Account account = new Account(Name='test', Type='dummy value');
        Test.startTest();
        String result = SidraLiteUtil.getBSPCASS(account);
        System.assertEquals('', result);
        Test.stopTest();
    }

    @isTest
    public static void testisAccountActive_ERROR() {
        Test.startTest();
        try {
            Boolean result = SidraLiteUtil.isAccountActive(null);
            System.assert(false, 'Exception expected');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testisAccountActive_OK() {
        Account account = new Account(Name='test', Status__c='Cash basis/no commission');
        Test.startTest();
        Boolean result = SidraLiteUtil.isAccountActive(account);
        System.assertEquals(false, result);
        Test.stopTest();
    }
    
    @isTest
    public static void testlastMonthDay() {
        Test.startTest();
        System.assertEquals(Date.newInstance(2017,02,28), SidraLiteUtil.lastMonthDay(Date.newInstance(2017,02,01)));
        Test.stopTest();
    }
    
    @isTest
    public static void testgetEmailTemplate_Error() {
        Case sidraCase = new Case(
            RecordtypeId = SidraLiteManager.RECORDTYPE_SIDRA_LITE,
            Region__c = 'Americas',
            BSPCountry__c = 'Canada',
            SIDRA_Lite_Reason__c = 'Financial Security Non-compliance'
        );
        insert sidraCase;
        
        Test.startTest();
        try {
            String result = SidraLiteUtil.getEmailTemplate(sidraCase,'TYPE');
            System.assert(false, 'Exception expected');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testgetEmailTemplate_FoundOne() {
        String actionType = 'ACTIONTYPE';
        Account account = new Account(Name = 'test',Type = 'Passenger Only');
        insert account;
        
        Case sidraCase = new Case(
            RecordtypeId = SidraLiteManager.RECORDTYPE_SIDRA_LITE,
            accountId = account.id,
            Region__c = 'Americas',
            BSPCountry__c = 'Canada',
            SIDRA_Lite_Reason__c = 'Financial Security Non-compliance'
        );
        insert sidraCase;
        
        sidraCase = [SELECT Id, SIDRA_Lite_Reason__c, BSPCountry__c, Region__c, account.Type
            FROM Case WHERE Id = :sidraCase.Id];
        
        SidraLiteEmailTemplates__c template = new SidraLiteEmailTemplates__c(
            Name = 'template1',
            SidraLiteAction__c = actionType,
            SidraLiteReason__c = sidraCase.SIDRA_Lite_Reason__c,
            Country__c = sidraCase.BSPCountry__c,
            Region__c = sidraCase.Region__c,
            TypeOfCustomer__c = account.Type,
            EmailTemplate__c = 'RESULT TEMPLATE'
        );
        insert template;
        
        Test.startTest();
        String result = SidraLiteUtil.getEmailTemplate(sidraCase,actionType);
        Test.stopTest();
        System.assertEquals(template.EmailTemplate__c,result);
    }
    
    @isTest
    public static void testgetEmailTemplate_FoundMoreThanOne() {
        String actionType = 'ACTIONTYPE';
        Account account = new Account(Name = 'test',Type = 'Passenger Only');
        insert account;
        
        Case sidraCase = new Case(
            RecordtypeId = SidraLiteManager.RECORDTYPE_SIDRA_LITE,
            accountId = account.id,
            Region__c = 'Americas',
            BSPCountry__c = 'Canada',
            SIDRA_Lite_Reason__c = 'Financial Security Non-compliance'
        );
        insert sidraCase;
        
        sidraCase = [SELECT Id, SIDRA_Lite_Reason__c, BSPCountry__c, Region__c, account.Type
            FROM Case WHERE Id = :sidraCase.Id];
        
        SidraLiteEmailTemplates__c template1 = new SidraLiteEmailTemplates__c(
            Name = 'template1',
            SidraLiteAction__c = actionType,
            SidraLiteReason__c = sidraCase.SIDRA_Lite_Reason__c,
            Country__c = sidraCase.BSPCountry__c,
            Region__c = sidraCase.Region__c,
            TypeOfCustomer__c = account.Type,
            EmailTemplate__c = 'RESULT TEMPLATE'
        );
        insert template1;
        SidraLiteEmailTemplates__c template2 = template1.clone();
        template2.Country__c = 'All Region';
        insert template2;
        
        Test.startTest();
        String result = SidraLiteUtil.getEmailTemplate(sidraCase,actionType);
        Test.stopTest();
        System.assertEquals(template1.EmailTemplate__c,result);
    }
    
    @isTest
    public static void testgetMergeTemplate_Error() {
        Case sidraCase = new Case(
            RecordtypeId = SidraLiteManager.RECORDTYPE_SIDRA_LITE,
            Region__c = 'Americas',
            BSPCountry__c = 'Canada',
            SIDRA_Lite_Reason__c = 'Financial Security Non-compliance'
        );
        insert sidraCase;
        
        Test.startTest();
        try {
            String result = SidraLiteUtil.getMergeTemplate(sidraCase,'TYPE');
            System.assert(false, 'Exception expected');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testgetMergeTemplate_FoundOne() {
        String actionType = 'ACTIONTYPE';
        Account account = new Account(Name = 'test',Type = 'Passenger Only');
        insert account;
        
        Case sidraCase = new Case(
            RecordtypeId = SidraLiteManager.RECORDTYPE_SIDRA_LITE,
            accountId = account.id,
            Region__c = 'Americas',
            BSPCountry__c = 'Canada',
            SIDRA_Lite_Reason__c = 'Financial Security Non-compliance'
        );
        insert sidraCase;
        
        sidraCase = [SELECT Id, SIDRA_Lite_Reason__c, BSPCountry__c, Region__c, account.Type
            FROM Case WHERE Id = :sidraCase.Id];
        
        SidraLiteCongaTemplates__c template = new SidraLiteCongaTemplates__c(
            Name = 'template1',
            SidraLiteAction__c = actionType,
            SidraLiteReason__c = sidraCase.SIDRA_Lite_Reason__c,
            Country__c = sidraCase.BSPCountry__c,
            Region__c = sidraCase.Region__c,
            TypeOfCustomer__c = account.Type,
            EmailTemplate__c = 'RESULT TEMPLATE'
        );
        insert template;
        
        Test.startTest();
        String result = SidraLiteUtil.getMergeTemplate(sidraCase,actionType);
        Test.stopTest();
        System.assertEquals(template.EmailTemplate__c,result);
    }
    
    @isTest
    public static void testgetMergeTemplate_FoundMoreThanOne() {
        String actionType = 'ACTIONTYPE';
        Account account = new Account(Name = 'test',Type = 'Passenger Only');
        insert account;
        
        Case sidraCase = new Case(
            RecordtypeId = SidraLiteManager.RECORDTYPE_SIDRA_LITE,
            accountId = account.id,
            Region__c = 'Americas',
            BSPCountry__c = 'Canada',
            SIDRA_Lite_Reason__c = 'Financial Security Non-compliance'
        );
        insert sidraCase;
        
        sidraCase = [SELECT Id, SIDRA_Lite_Reason__c, BSPCountry__c, Region__c, account.Type
            FROM Case WHERE Id = :sidraCase.Id];
        
        SidraLiteCongaTemplates__c template1 = new SidraLiteCongaTemplates__c(
            Name = 'template1',
            SidraLiteAction__c = actionType,
            SidraLiteReason__c = sidraCase.SIDRA_Lite_Reason__c,
            Country__c = sidraCase.BSPCountry__c,
            Region__c = sidraCase.Region__c,
            TypeOfCustomer__c = account.Type,
            EmailTemplate__c = 'RESULT TEMPLATE'
        );
        insert template1;
        SidraLiteCongaTemplates__c template2 = template1.clone();
        template2.Country__c = 'All Region';
        insert template2;
        
        Test.startTest();
        String result = SidraLiteUtil.getMergeTemplate(sidraCase,actionType);
        Test.stopTest();
        System.assertEquals(template1.EmailTemplate__c,result);
    }
    
    @isTest
    public static void testisLastSidraCase() {
        Account account = new Account(Name = 'test');
        insert account;
        
        Case sidraCase = new Case(
            RecordtypeId = SidraLiteManager.RECORDTYPE_SIDRA_LITE,
            accountId = account.id,
            BSPCountry__c = 'Canada',
            SIDRA_Lite_Reason__c = 'Financial Security Non-compliance'
        );
        insert sidraCase;
        
        Test.startTest();
        Boolean result = SidraLiteUtil.isLastSidraCase(sidraCase);
        System.assertEquals(false, result);
        Test.stopTest();
    }
    
    @isTest
    public static void testSidraLiteCaseMustNotBeUpdated() {
        Case cse = new Case(Reason_for_Default__c = 'Non-payment');
        Test.startTest();
        Boolean result = SidraLiteUtil.SidraLiteCaseMustNotBeUpdated(cse);
        System.assertEquals(true, result);
        Test.stopTest();
    }
    
}