@isTest
public class PortalFAQsCtrlTest {
    @TestSetup
    public static void testSetup() {
        Id airlineRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');

        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) { // AVOID MIXED_DML_OPERATION
            Account acc = ISSP_ObjectFactory.createNewAccount();
            acc.Name = 'Account Test Portal Documents';
            acc.Sector__c = 'Airline';
            acc.Category__c = 'Passenger and Cargo';
            acc.RecordTypeId = airlineRT;
            insert acc;

            Contact con = ISSP_ObjectFactory.createNewContact();
            con.AccountId = acc.Id;
            con.FirstName = 'Contact';
            con.LastName = 'Test Portal Documents';
            con.Email = System.today().dayOfYear() + 'testemail1@csp.testclass';
            insert con;

            User usr = ISSP_ObjectFactory.createPortalUser(con);
            PortalFAQsSharingCtrl.validateUserFAQsPermissions(usr.id);

            FAQ__kav kavObj = new FAQ__kav();
            kavObj.Title = 'Sample Article Portal Test';
            kavObj.UrlName = 'Sample-Article-Portal-Test';
            kavObj.Summary = 'Summary';
            insert kavObj;
            
            //retrieve master article Id created on FAQ__kav record insertion
            //in order to get the KnowledgeArticleId
            kavObj = [SELECT KnowledgeArticleId FROM FAQ__kav WHERE Id = :kavObj.Id];
            //publish it
            KbManagement.PublishingService.publishArticle(kavObj.KnowledgeArticleId, true);

            DescribeDataCategoryGroupResult[] results = Schema.describeDataCategoryGroups(
                new String[] { 'KnowledgeArticleVersion'}
            );

            FAQ__DataCategorySelection tempCat = new FAQ__DataCategorySelection ();
            tempCat.DataCategoryGroupName = results[0].getName();
            tempCat.DataCategoryName = 'IEP_Support';
            tempCat.ParentId = kavObj.Id;

            insert tempCat;
        }
    }

    @isTest static void testGetFAQs() {
        User testUser = [SELECT Id FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];
        FAQ__kav kavObj = [SELECT Id, Title, ArticleNumber, PublishStatus FROM FAQ__kav WHERE Title = 'Sample Article Portal Test' LIMIT 1];

        Test.startTest();
        System.runAs(testUser) {
            PortalSearchFilterWrapper filtersWrapper = new PortalSearchFilterWrapper();
            filtersWrapper.searchText = 'Test Publish Online';
            filtersWrapper.faqsComponent = null;
            filtersWrapper.language = 'en_US';
            PortalFAQsCtrl.PagedResult resultsWithoutSubtopic = PortalFAQsCtrl.getFilteredFAQsResultsPage(JSON.serialize(filtersWrapper), '0');

            filtersWrapper.language = '';
            resultsWithoutSubtopic = PortalFAQsCtrl.getFilteredFAQsResultsPage(JSON.serialize(filtersWrapper), '0');

            PortalSearchFilterWrapper.faqsComponent faqsComponent = new PortalSearchFilterWrapper.faqsComponent();
            faqsComponent.faqSubtopicsList = new List<String>{'IEP_Support'};
            filtersWrapper.faqsComponent = faqsComponent;
            filtersWrapper.language = 'en_US';
            PortalFAQsCtrl.PagedResult resultsWithSubtopic = PortalFAQsCtrl.getFilteredFAQsResultsPage(JSON.serialize(filtersWrapper), '1');
        }
        Test.stopTest();
    }

    @isTest static void testGetArticles() {
        User testUser = [SELECT Id FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];

        Test.startTest();
        System.runAs(testUser) {
            List<FAQ__kav> article = PortalFAQsCtrl.getArticles('IEP_Support__c');
            List<FAQ__kav> articleByLanguage = PortalFAQsCtrl.getArticlesByLanguage('IEP_Support__c', 'en_US');
        }
    }

    @isTest static void testArticleFeedback() {
        User testUser = [SELECT Id FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];
        FAQ__kav kavObj = [SELECT Id, Title, ArticleNumber, PublishStatus FROM FAQ__kav WHERE Title = 'Sample Article Portal Test' LIMIT 1];

        Test.startTest();
        System.runAs(testUser) {
            String sessionCookie = CSP_Utils.randomUUID();
            PortalFAQsCtrl.createFeedback(kavObj.Id, kavObj.ArticleNumber, kavObj.Title, 'Search', 'This is a comment', sessionCookie, true);
            List<PKB_Article_Feedback_Deflection__c> feedback = [SELECT Id FROM PKB_Article_Feedback_Deflection__c WHERE Article_ID__c = :kavObj.Id];
            System.assertNotEquals(0, feedback.size());

            List<PKB_Article_Feedback_Deflection__c> articleFeedback = PortalFAQsCtrl.getArticlesFeedback('(\''+kavObj.Id+'\')', sessionCookie);
            System.assertNotEquals(0, articleFeedback.size());
        }
        Test.stopTest();
    }

    @isTest static void testUpdateArticleCategoriesAndApproval() {
        FAQ__kav kavObj = [SELECT Id, Categories__c, PublishStatus, ValidationStatus FROM FAQ__kav WHERE Title = 'Sample Article Portal Test' LIMIT 1];
        
        Test.startTest();
            ApexMessageHandling articleToUpdate;
            articleToUpdate = PortalFAQsCtrl.updateArticleCategories(new List<Id>{ kavObj.Id });
            System.assertEquals(false, articleToUpdate.isSuccess);

            FAQ__kav articleToSubmit = new FAQ__kav();
            articleToSubmit.Title = 'Sample Article Portal Test Draft';
            articleToSubmit.UrlName = 'Sample-Article-Portal-Test-Draft';
            articleToSubmit.Summary = 'Summary';
            articleToSubmit.ValidationStatus = 'Not Validated';
            insert articleToSubmit;
            
            DescribeDataCategoryGroupResult[] results = Schema.describeDataCategoryGroups(new String[] {'KnowledgeArticleVersion'});

            FAQ__DataCategorySelection tempCat = new FAQ__DataCategorySelection();
            tempCat.DataCategoryGroupName = results[0].getName();
            tempCat.DataCategoryName = 'RHC';
            tempCat.ParentId = articleToSubmit.Id;

            FAQ__DataCategorySelection tempCat2 = new FAQ__DataCategorySelection();
            tempCat2.DataCategoryGroupName = results[0].getName();
            tempCat2.DataCategoryName = 'CargoIS';
            tempCat2.ParentId = articleToSubmit.Id;
            insert new List<FAQ__DataCategorySelection>{ tempCat, tempCat2 };

            articleToUpdate = PortalFAQsCtrl.updateArticleCategories(new List<Id>{ articleToSubmit.Id });
            System.assertEquals(true, articleToUpdate.isSuccess);

            FAQ__kav kavObjUpdated = [SELECT Categories__c, PublishStatus, ValidationStatus FROM FAQ__kav WHERE Id = :articleToSubmit.Id LIMIT 1];
            System.assertNotEquals(null, kavObjUpdated.Categories__c);

            try {
                PortalFAQsCtrl.submitArticleForApproval(null, articleToSubmit.Id, UserInfo.getUserId(), 'This is a comment.');
            } catch(Exception e) {
                System.assert(e.getMessage().contains('No applicable approval process was found'), e.getMessage());
                PortalFAQsCtrl.submitArticleForApproval('KnowledgeFAQArticles', articleToSubmit.Id, UserInfo.getUserId(), 'This is a comment.');
            }
        Test.stopTest();
    }
}
