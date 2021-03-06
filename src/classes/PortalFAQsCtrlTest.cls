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

			List<PermissionSet> permSet = [SELECT Id FROM PermissionSet WHERE Name = 'All_DataCategories_Visible' LIMIT 1];
			String permissionId = permSet[0].Id;

			PermissionSetAssignment ps = new PermissionSetAssignment();
			ps.AssigneeId = usr.Id;
			ps.PermissionSetId = permissionId;
			insert ps;

			FAQ__kav kavObj = new FAQ__kav();
			kavObj.Title = 'Sample Article Portal Test';
			kavObj.UrlName = 'Sample-Article-Portal-Test';
			kavObj.Summary = 'Summary';
			kavObj.language = 'en_US';
			
			FAQ__kav kavObj2 = new FAQ__kav();
			kavObj2.Title = 'Sample Article Portal Test';
			kavObj2.UrlName = 'Sample-Article-Portal-Test';
			kavObj2.Summary = 'Summary';
			kavObj2.language = 'pt_BR';
			
			insert new list<FAQ__kav>{kavObj,kavObj2};
			
			System.runAs(usr) { 
				PortalKnowledge__c faqCategory = new PortalKnowledge__c();
				faqCategory.Name = 'Travel';
				faqCategory.FAQsStructure__c = true;
				faqCategory.DataCategoryName__c = 'Travel';
				faqCategory.DataCategoryLabel_en_US__c = 'Travel';
				faqCategory.Order__c = 1;

				PortalKnowledge__c faqTopic = new PortalKnowledge__c();
				faqTopic.Name = 'IATA EasyPay';
				faqTopic.FAQsStructure__c = true;
				faqTopic.DataCategoryName__c = 'Travel';
				faqTopic.DataTopicName__c = 'IATA_EasyPay';
				faqTopic.DataCategoryLabel_en_US__c = 'TravelCategory';
				faqTopic.Order__c = 1;

				PortalKnowledge__c faqSubtopic = new PortalKnowledge__c();
				faqSubtopic.Name = 'Changes to my Agency';
				faqSubtopic.FAQsStructure__c = true;
				faqSubtopic.DataCategoryName__c = 'Travel';
				faqSubtopic.DataTopicName__c = 'IATA_EasyPay';
				faqSubtopic.DataSubtopicName__c = 'PAX_Changes_to_my_Agency';
				faqSubtopic.DataCategoryLabel_en_US__c = 'Changes to my Agency';
				faqSubtopic.Order__c = 1;
				insert new List<PortalKnowledge__c>{ faqCategory, faqTopic, faqSubtopic };
			}
			//retrieve master article Id created on FAQ__kav record insertion
			//in order to get the KnowledgeArticleId
			kavObj = [SELECT KnowledgeArticleId FROM FAQ__kav WHERE Id = :kavObj.Id];
			kavObj2 = [SELECT KnowledgeArticleId FROM FAQ__kav WHERE Id = :kavObj2.Id];
			
			DescribeDataCategoryGroupResult[] results = Schema.describeDataCategoryGroups(
				new String[] { 'KnowledgeArticleVersion'}
				);
				
			FAQ__DataCategorySelection tempCat = new FAQ__DataCategorySelection ();
			tempCat.DataCategoryGroupName = results[0].getName();
			tempCat.DataCategoryName = 'Travel';
			tempCat.ParentId = kavObj.Id;
			
			FAQ__DataCategorySelection tempCat2 = new FAQ__DataCategorySelection ();
			tempCat2.DataCategoryGroupName = results[0].getName();
			tempCat2.DataCategoryName = 'Travel';
			tempCat2.ParentId = kavObj2.Id;
			
			insert new list<FAQ__DataCategorySelection>{tempCat,tempCat2};
			//publish it
			KbManagement.PublishingService.publishArticle(kavObj.KnowledgeArticleId, true);
			KbManagement.PublishingService.publishArticle(kavObj2.KnowledgeArticleId, true);
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
			filtersWrapper.language = 'pt_BR';
			filtersWrapper.guestUser = true;
			CSP_Utils.PagedResult resultsWithoutSubtopic = PortalFAQsCtrl.getFilteredFAQsResultsPage(JSON.serialize(filtersWrapper), '0');

			filtersWrapper.language = '';
			resultsWithoutSubtopic = PortalFAQsCtrl.getFilteredFAQsResultsPage(JSON.serialize(filtersWrapper), '0');

			PortalSearchFilterWrapper.faqsComponent faqsComponent = new PortalSearchFilterWrapper.faqsComponent();
			faqsComponent.faqSubtopicsList = new List<String>{'Travel'};
			filtersWrapper.faqsComponent = faqsComponent;
			filtersWrapper.language = 'pt_BR';
			filtersWrapper.guestUser = true;
			CSP_Utils.PagedResult resultsWithSubtopic = PortalFAQsCtrl.getFilteredFAQsResultsPage(JSON.serialize(filtersWrapper), '1');

		   
		}
		Test.stopTest();
	}

	@isTest static void testGetArticles() {
		User testUser = [SELECT Id FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];

		Test.startTest();
		System.runAs(testUser) {
			List<FAQ__kav> articleList = PortalFAQsCtrl.getArticles('Travel__c');            
			system.assertEquals(0,articleList.size());
            
			List<FAQ__kav> articleByLanguage = PortalFAQsCtrl.getArticlesByLanguage('Travel__c', 'pt_BR');
			system.assertEquals(0,articleByLanguage.size());
            
		}
		Test.stopTest();
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

	@isTest static void testGetArticleTitle() {
		FAQ__kav faqka=[SELECT KnowledgeArticleId FROM FAQ__kav limit 1];
		String title=PortalFAQsCtrl.getArticleTitle(faqka.Id);
		System.assertEquals('Sample Article Portal Test',title);

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

	@isTest static void portalGlobalSearch() {

		User testUser = [SELECT Id FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];

		Test.startTest();
		System.runAs(testUser) {
			CSP_Utils.PagedResult test = new CSP_Utils.PagedResult();

			PortalSearchFilterWrapper.faqsComponent faqsComponent = new PortalSearchFilterWrapper.faqsComponent();
			faqsComponent.faqSubtopicsList = new List<String> {'Travel'};
			faqsComponent.show = true;

			PortalSearchFilterWrapper filtersWrapper = new PortalSearchFilterWrapper();
			filtersWrapper.searchText = 'Travel';
			filtersWrapper.faqsComponent = faqsComponent;
			filtersWrapper.language = 'en_US';

			test = PortalGlobalSearchCtrl.portalGlobalSearch(JSON.serialize(filtersWrapper), 'FAQS');
		}
		Test.stopTest();
	}

	@isTest static void testGetArticleByURLName() {

		User testUser = [SELECT Id FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];

		Test.startTest();
		System.runAs(testUser) {
			CSP_Utils.PagedResult test = new CSP_Utils.PagedResult();

			PortalSearchFilterWrapper filtersWrapper = new PortalSearchFilterWrapper();
			filtersWrapper.UrlName = 'Sample-Article-Portal-TESSST';
			filtersWrapper.language = 'en_US';
			filtersWrapper.guestUser = true;
			
			test = PortalFAQsCtrl.getFilteredFAQsResultsPage(JSON.serialize(filtersWrapper), '0');
			
			system.assertEquals(0,test.records.size());
			
			filtersWrapper.UrlName = 'Sample-Article-Portal-Test3';
			test = PortalFAQsCtrl.getFilteredFAQsResultsPage(JSON.serialize(filtersWrapper), '0');
			system.assertEquals(0,test.records.size());
		}
		Test.stopTest();
	}

	@isTest static void testGetArticleShareableLink() {
		
		faq__kav article= [SELECT id,CS_Portal_link__c FROM faq__kav LIMIT 1];

		String link=PortalFAQsCtrl.getShareableLink(article.id);
		system.assertEquals(link,article.CS_Portal_link__c);


	}
	

	@isTest static void testGetTroubleshootingArticle() {
		
		
		User testUser = [SELECT Id FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];

		Test.startTest();
		System.runAs(testUser) {
			CSP_Utils.PagedResult result=PortalFAQsCtrl.getTroubleshootingArticle('en_US');
			system.assertEquals(null,result);

			ISSP_CS__c val= new ISSP_CS__c(
				name='TroubleShootingArticleId',
				value__C='Sample-Article-Portal-Test'
			);
			insert val;

			result=PortalFAQsCtrl.getTroubleshootingArticle('en_US');
			system.assertEquals(0,result.records.size());
		}

	}

}
