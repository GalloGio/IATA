@isTest
private class pkb_Test {

	static String siteName = 'PKB_TEST_' + String.valueOf(Crypto.getRandomInteger());    // use this to set the siteName prop of the pkb_Controller class
	static String publishStatus = 'draft'; // use this to set the pub status prop of the pkb_Controller
	static String lang = 'en_US';
	static PKB__c pkb;
	static SObject kavObj;
	static String objType;
	static PKB_Featured__c featured;
	static PKB_Featured__c keyword;
	static List<PKB_Article_Feedback_Deflection__c> pafds;
	class TestException extends Exception { }

	@isTest
	static void testController() {
		setupData();
		setupSettingsData();

		Id kaId = (Id)kavObj.get('KnowledgeArticleId');
		Id kavId = (Id)kavObj.get('Id');
		String articleNumber = (String)kavObj.get('ArticleNumber');

		String catString;

		// setupData will have instantiated kavObj, and if it hasn't, show the error and return
		if (kavObj == null) {
			return;
		}

		// set the fixed search results to all possible ids that should be returned via sosl throughout the code
		List<String> searchResults = new List<String> {
			keyword.Id,
			kavId
		};
		Test.setFixedSearchResults(searchResults);


		// refCon is an essentially empty instance of the controller that allows access to the public variables that refer
		// to the names of the various url params that will be used to set up tests
		pkb_Controller refCon = new pkb_Controller();
		pkb_Controller pkbCon;
		PageReference p;

		// test first with no params and empty KA
		p = new PageReference('/');
		Test.setCurrentPage(p);
		pkbCon = new pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
		System.assertNotEquals(pkbCon.publishStatus, null);

		// test with query of foo, language of english, and random category, and generate search RSS
		p = new PageReference('/');
		p.getParameters().put(refCon.queryParam, 'foor');
		p.getParameters().put(refCon.languageParam, lang);

		p.getParameters().put(refCon.categoryParam, catString);
		Test.setCurrentPage(p);
		pkbCon = new pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
		pkbCon.prepareSearchRSS();

		// test with actual article id, so that viewingArticle will be true in the controller
		p = new PageReference('/?id=' + kaId);
		Test.setCurrentPage(p);
		pkbCon = new pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle(Id = kaId)));
		pkbCon.prepareSearchRSS(); // to execute negative branch of first line of method

		// run through a bunch of the basic props
		System.assertNotEquals(pkbCon.pageTitle, null);
		System.assertNotEquals(pkbCon.selectedLanguageURL, null);
		pkbCon.selectedCategory = 'foo';
		System.assertNotEquals(pkbCon.selectedCategoryLabel, null);
		pkbCon.selectedCategory = '';
		System.assert(!pkbCon.caseCreateError);
		System.assert(!pkbCon.caseCreated);
		System.assert(!pkbCon.feedbackRecorded);
		System.assertNotEquals(pkbCon.languageOptions, null);
		System.assertEquals(pkbCon.currPage, 1);
		pkbCon.nextPage();
		pkbCon.prevPage();
		System.assertEquals(pkbCon.currPage, 1);

		// test basic defferal -- a deflection record should be created with an article associated to it since an article is being viewed
		pkbCon.deferred();
		pafds = [select Id, Session_ID__c from PKB_Article_Feedback_Deflection__c where Article_Number__c = :articleNumber];
		System.assert(pafds.size() == 1);


		//check that the deflection has been related to the contact
		pafds = [select Id, Session_ID__c from PKB_Article_Feedback_Deflection__c where Session_ID__c = :pkbCon.sessionId];
		System.assert(pafds.size() == 1);
		// test with contact us, while viewing article, and already entered question
		p = new PageReference('/');
		p.getParameters().put('id', kaId);
		p.getParameters().put(refCon.contactUsParam, refCon.contactUsValue);
		Test.setCurrentPage(p);
		pkbCon = new pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle(Id = kaId)));

		// should add another defferal record
		pkbCon.feedbackComments = 'some comments';
		pkbCon.recordArticleFeedback();
		pafds = [select Id from PKB_Article_Feedback_Deflection__c where Article_Number__c = :articleNumber];
		System.assert(pafds.size() == 2);

		// should add another defferal record
		pkbCon.contactUsDeferral();
		pafds = [select Id from PKB_Article_Feedback_Deflection__c where Article_Number__c = :articleNumber];
		System.assert(pafds.size() == 3);

		// set up for case creation
		pkbCon.theCud.firstName = 'Foo';
		pkbCon.theCud.lastName = 'Bar';
		pkbCon.theCud.email = ''; // should fail validation
		pkbCon.createCase();
		System.assert(pkbCon.caseCreateError);

		String validType = 'foo';
		if (!refCon.caseTypeOptions.isEmpty()) {
			for (SelectOption so : refCon.caseTypeOptions) {
				if (!isBlank(so.getValue())) validType = so.getValue();
				break;
			}
		}

		// email should fail
		pkbCon.theCud.firstName = 'Foo';
		pkbCon.theCud.lastName = 'Bar';
		pkbCon.theCud.email = 'foo';
		pkbCon.theCud.reqType = validType;
		pkbCon.createCase();

		// make email pass
		pkbCon.theCud.email = siteName + '@bar.com';
		pkbCon.createCase();
		System.assert(!pkbCon.caseCreateError);

		// flip the pkb setting to create account and contact
		pkb.Create_Contact_and_Account__c = true;
		update pkb;
		pkbCon.createCase();

		// set site admin to a fake user when testing
		pkbCon.siteAdmin = [SELECT Id, FirstName, LastName, Email FROM User WHERE Id = :UserInfo.getUserId()];
		pkbCon.createCase(); // this will succeed
		pkbCon.theCase = pkbCon.theCase.clone(false);
		pkbCon.theCud.firstName = '';
		pkbCon.theCud.lastName = '';
		pkbcon.theCud.email = null;
		pkbCon.insertRecords(); // this will fail due to setting first/last to null
		System.assert(pkbCon.caseCreateError);

		// requery the custom setting and assert that the value was flipped
		pkb = PKB__c.getInstance(siteName);
		System.assert(!pkb.Create_Contact_and_Account__c);

		// make theCud valid again but hijack theCase with a fake account id (which will throw a Dml Exception)
		pkbCon.theCase = pkbCon.theCase.clone(false);
		pkbCon.theCud.firstName = 'Foo';
		pkbCon.theCud.lastName = 'Bar';
		pkbCon.theCud.email = siteName + '@bar.com';
		pkbCon.theCud.reqType = validType;
		pkbCon.createCase();
		pkbCon.theCase.AccountId = '0013010101jQrdW'; // fake account number, on purpose, have to call this after createCase since createCase instantiates theCase
		pkbCon.insertRecords();
		System.assert(pkbCon.caseCreateError);

		// testing some static stuff and other independent operations
		TestException e = new TestException('Test Exception!!');
		pkb_Controller.debugException(e);
		pkbCon.notifyAdmin(null, e, 'some message here');

		pkbCon.selectedCategory = null;
		System.assertEquals(pkbCon.buildCategorySosl(), null);
		pkbCon.selectedCategory = 'foo_t:bar';
		System.assertNotEquals(pkbCon.buildCategorySosl(), null);

		pkb_Controller.initFromListOfArticleIds(null, lang);
		pkb_Controller.initFromListOfArticleIds(new List<String>(), lang);
		pkb_Controller.initFromListOfArticleIds(new List<String> {kaId}, lang);

		pkb_Controller.initFromListOfKAVIds(null, lang);
		pkb_Controller.initFromListOfKAVIds(new List<String>(), lang);
		pkb_Controller.initFromListOfKAVIds(new List<String> {kavId}, lang);

		User u = pkb_Controller.getSiteAdmin();
	}

	@isTest
	static void testSettingsController() {
		setupSettingsData();

		pkb_SettingsController refCon = new pkb_SettingsController();
		pkb_SettingsController pkbsc;
		PageReference p;

		// test with new record
		p = new PageReference('/?' + refCon.createSettingsParam + '=' + refCon.createSettingsValue);
		Test.setCurrentPage(p);
		pkbsc = new pkb_SettingsController(new ApexPages.StandardController(new PKB__c()));
		System.assert(pkbsc.creatingSettings);

		// test with existing record
		p = new PageReference('/?id=' + pkb.Id);
		Test.setCurrentPage(p);
		pkbsc = new pkb_SettingsController(new ApexPages.StandardController(pkb));
		System.assert(!pkbsc.creatingSettings);

		// there is at least one pkb settings record and so the settings options list is not empty
		System.assert(!pkbsc.settingsOptions.isEmpty());

		// this will fail the first time since there is no site named with this test's site name
		p = pkbsc.saveSettings();
		System.assertEquals(p, null);

		// throw the test bit and try again
		// save the settings and assert that the resulting page ref contains the id of the settings
		pkb_SettingsController.isRunningTest = true;
		p = pkbsc.saveSettings();
		System.assert(p.getUrl().contains(pkb.Id));
	}


	@isTest
	static void testSettings_CTI_keywords() {
		setupSettingsData();

		pkb_SettingsController refCon = new pkb_SettingsController();
		pkb_SettingsController pkbsc;
		PageReference p;

		// test with existing record
		p = new PageReference('/?id=' + pkb.Id);
		Test.setCurrentPage(p);
		pkbsc = new pkb_SettingsController(new ApexPages.StandardController(pkb));

		pkb.CTI_configuration__c = '';
		pkb.Add_Case_Id__c = false;

		p = pkbsc.saveSettings();
		System.assertEquals(p, null);

		PKB__c updatedElm = null;
		Map<String, PKB__c> settingsMap = PKB__c.getAll();
		if (settingsMap.containsKey(pkb.Name)) {
			updatedElm = settingsMap.get(pkb.Name);
		}

		system.assertEquals(updatedElm.Add_Case_Id__c, pkb.Add_Case_Id__c);

		//  try to save invalid keywords [[[[[p]43
		pkb.CTI_configuration__c = '[[[[[p]43';
		pkb.Add_Case_Id__c = true;

		p = pkbsc.saveSettings();
		System.assertEquals(p, null);

		updatedElm = null;
		settingsMap = PKB__c.getAll();
		if (settingsMap.containsKey(pkb.Name)) {
			updatedElm = settingsMap.get(pkb.Name);
		}

		system.assertEquals(updatedElm.Add_Case_Id__c, false);

		//  try to save invalid keywords [P]3[CN]
		pkb.CTI_configuration__c = '[P]3[CN]';
		pkb.Add_Case_Id__c = true;

		p = pkbsc.saveSettings();
		System.assertEquals(p, null);

		updatedElm = null;
		settingsMap = PKB__c.getAll();
		if (settingsMap.containsKey(pkb.Name)) {
			updatedElm = settingsMap.get(pkb.Name);
		}

		system.assertEquals(updatedElm.Add_Case_Id__c, false);

	}

	@isTest
	static void test_searchString() {
		setupData();
		setupSettingsData();

		Id kaId = (Id)kavObj.get('KnowledgeArticleId');
		Id kavId = (Id)kavObj.get('Id');
		String catString;
		// refCon is an essentially empty instance of the controller that allows access to the public variables that refer
		// to the names of the various url params that will be used to set up tests
		pkb_Controller refCon = new pkb_Controller();
		pkb_Controller pkbCon;
		PageReference p;

		// test first with no params and empty KA
		p = new PageReference('/');
		Test.setCurrentPage(p);
		pkbCon = new pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
		System.assertNotEquals(pkbCon.publishStatus, null);

		// test with query of foo, language of english, and random category, and generate search RSS
		p = new PageReference('/');
		p.getParameters().put(refCon.queryParam, 'fr');
		p.getParameters().put(refCon.languageParam, lang);

		p.getParameters().put(refCon.categoryParam, catString);
		Test.setCurrentPage(p);
		pkbCon = new pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
		//there was a search query but with less than 4 chars
		system.assertEquals(pkbCon.enteredSearchQuery, pkbCon.searchPrompt);

	}



	static void setupSettingsData() {
		// create custom settings collection based on siteName
		pkb = new PKB__c();
		pkb.Name = siteName;
		pkb.Category_Group_1__c = '1';
		pkb.Category_Group_2__c = '2';
		pkb.Category_Group_3__c = '3';
		pkb.Root_Category_1__c = '1';
		pkb.Root_Category_2__c = '2';
		pkb.Root_Category_3__c = '3';

		pkb.Create_Contact_and_Account__c = false;
		pkb.Display_Article_Summary__c = true;
		pkb.Multi_Language_Enabled__c = false;
		pkb.Popular_Articles_Size__c = 2;
		pkb.Related_Articles_Size__c = 2;
		pkb.Results_Page_Size__c = 2;
		insert pkb;
	}

	static void setupData() {
		// create article of first type found in the objects that end with __kav
		List<String> kavNames = new List<String>(pkb_Controller.kavNames);
		if (kavNames.isEmpty()) return;

		// set the controller's default pub status to draft so that the queries will find records
		pkb_Controller.DEFAULT_PUBLISH_STATUS = publishStatus;
		pkb_Controller.DEFAULT_SITE_NAME = siteName;

		objType = kavNames.get(0);

		kavObj = Schema.getGlobalDescribe().get(objType).newSObject();
		kavObj.put('Title', 'Foo Foo Foo!!!' + String.valueOf(Crypto.getRandomInteger()));
		kavObj.put('UrlName', 'foo-foo-foo' + String.valueOf(Crypto.getRandomInteger()));
		kavObj.put('Summary', 'This is a summary!!! Foo. Foo. Foo.');
		kavObj.put('Language', lang);
		insert kavObj;

		// requery the kavObj to get the KnowledgeArticleId on it that is created automatically
		String q = 'select ' + pkb_Controller.join(pkb_Controller.kavFields, ',') + ' from KnowledgeArticleVersion where Id = \'' + kavObj.get('Id') +  '\' and PublishStatus = :publishStatus';
		kavObj = (KnowledgeArticleVersion)Database.query(q);

		// create featured record
		featured = new PKB_Featured__c(
			Article_Number__c = (String)kavObj.get('ArticleNumber'),
			Is_Keyword_Article__c = false,
			PKB_Name__c = siteName
		);
		insert featured;

		// create keyword recommended record
		keyword = new PKB_Featured__c(
			Article_Number__c = (String)kavObj.get('ArticleNumber'),
			Is_Keyword_Article__c = true,
			Keyword__c = 'foo',
			PKB_Name__c = siteName
		);
		insert keyword;

	}

	// returns true if string is null or empty
	static Boolean isBlank(String s) {
		return ( s == null || s == '');
	}

}
