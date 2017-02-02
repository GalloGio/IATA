@isTest
public class howto_Controller_Test {
    class TestException extends Exception { }
    
    @testSetup static void initData() {
        Id rtHQ =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Airline Headquarters').getRecordTypeId();
        //String recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'IATA_Airline'].Id;
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        //UserRole portalRole = [Select Id From UserRole Where Name = 'None' Limit 1];
        UserRole portalRole = [Select Id From UserRole Where Name = 'Director General' Limit 1];
        User portalAccountOwner1 = new User(
            //Role =  'Director General',                           
            UserRoleId = portalRole.Id,
            ProfileId = testProfile.Id,
            Username = System.now().millisecond() + 'test2@test.com',
            Alias = 'batman',
            Email = 'standarduser1@testorg.com',
            EmailEncodingKey = 'UTF-8',
            Firstname = 'Bruce',
            Lastname = 'Wayne',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            //  PortalRole = 'Manager',
            License_Cost_Center__c = 'ISF005CH01',
            TimeZoneSidKey = 'America/Chicago',
            UserPermissionsKnowledgeUser = true
        );
        insert portalAccountOwner1;
        //Manage Articles - FAQs permission set
        /*  List<PermissionSet> pms = [select id from PermissionSet where id = '0PSw00000004aYW'];
PermissionSetAssignment psa = new PermissionSetAssignment
(PermissionSetId = pms[0].id, AssigneeId = portalAccountOwner1.id);
insert psa;*/
        
        //to create portar user with contacts
        System.runAs(portalAccountOwner1) {
            Account portalAccount1 = new Account(
                Name = 'TestAccount',
                OwnerId = portalAccountOwner1.Id,
                IATACode__c = '100',
                RecordTypeId = rtHQ
            );
            insert portalAccount1;
            
            Contact con = ISSP_ObjectFactory.createNewContact();
            con.AccountId = portalAccount1.id;
            // con.Owner = testUser;
            con.LastName = 'test';
            con.User_Portal_Status__c = 'Approved User';
            con.Email = 'test.issp.interface@testisspinterface.com';
            insert con;
            
            Profile portalProfile = [SELECT Id FROM Profile WHERE Name LIKE 'ISS Portal (Partner)' Limit 1];
            User testUser = New User(
                Alias = 'standt', Email = 'standarduser@testorg.com',
                EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                ContactId = con.Id,
                ProfileId = portalProfile.Id,
                LocaleSidKey = 'en_US',
                // PortalRole = 'Manager',
                TimeZoneSidKey = 'America/Los_Angeles', UserName = 'test.username@test.com'
                //License_Cost_Center__c = 'ISF005CH01'
                // UserPermissionsKnowledgeUser = true
            );
            insert testUser;
        }
    }
    
    @isTest static void test_howto_Controller() {
        Test.startTest();
        
        
        User testUser1 = [select email from user where email = :'standarduser1@testorg.com'];
        //  User testUser = [select email from user where email = :'standarduser@testorg.com'];
        
        system.runAs(testUser1) {
            How_To__kav faq1 = new How_To__kav(Language = 'fr', UrlName = 'test111', IsVisibleInPkb=true, Title = 'test111');
            insert faq1 ;
            
            faq1 = [SELECT KnowledgeArticleId, PublishStatus, id FROM How_To__kav WHERE Id = :faq1.Id];
            KbManagement.PublishingService.publishArticle(faq1.KnowledgeArticleId , true);    
            
            ApexPages.KnowledgeArticleVersionStandardController ctl =
                new ApexPages.KnowledgeArticleVersionStandardController(faq1);
            howto_controller controller1 = new howto_controller();
            howto_controller controller = new howto_controller(ctl);
            
            Set <String> stringSet = controller.feedbackSourceOptions;
            String queryParam = controller.queryParam;
            String languageParam = controller.languageParam;
            String feedbackParam = controller.feedbackParam;
            String feedbackSourceParam = controller.feedbackSourceParam;
            String feedbackContactUs = controller.feedbackContactUs;
            String feedbackSearch = controller.feedbackSearch;
            String feedbackRelated = controller.feedbackRelated;
            String feedbackComments = controller.feedbackComments;
            String faqHome = controller.faqHome;
            String kavExtension = controller.kavExtension;
            Integer relatedArticles = controller.relatedArticles;
            String selectedLanguageURL = controller.selectedLanguageURL;
            String myTest = controller.allSearchParams;
            Map<String, String> stringMap = howto_controller.getActivePicklistOptions('test', 'test');
            List<Schema.PicklistEntry> stringList = howto_controller.getActivePicklistEntries('test', 'test');
            howto_controller.getActivePicklistOptions('test', 'test');
            controller.recordArticleFeedback();
            howto_controller.KnowledgeArticleData kn = new  howto_controller.KnowledgeArticleData();            
            try{
                controller.deferred();
            }catch(Exception e){                
            }
            
            
        }      
        Test.stopTest();
    }
    
}