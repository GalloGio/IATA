@isTest
public class howto_Controller_Test {
 
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
	static void test1() {
		Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '100';
        acc.RecordTypeId = recordTypeId;
        insert acc;
        
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = acc.Id;
        con.LastName = 'test';
        con.User_Portal_Status__c = 'Approved User';
        con.Email = 'test.issp.interface@testisspinterface.com';
        insert con;
        
        User thisUser = ISSP_ObjectFactory.createPortalUser(con);
        
        system.runAs(thisUser){
            howto_controller controller = new howto_controller();
            Set <String> stringSet = controller.feedbackSourceOptions;
            Map<String,String> stringMap = howto_controller.getActivePicklistOptions('test', 'test');
            List<Schema.PicklistEntry> stringList = howto_controller.getActivePicklistEntries('test', 'test');
            //controller.deferred();
            controller.recordArticleFeedback();
            String myTest = controller.allSearchParams;
        }
    }

    @isTest
	static void test_searchString() {

        Test.startTest();
        setupData();
        setupSettingsData();

        Id kaId = (Id)kavObj.get('KnowledgeArticleId');
        Id kavId = (Id)kavObj.get('Id');
        
        //How_To__kav faq1 = new How_To__kav(Language='fr', UrlName='test111'  , IsVisibleInPkb=true, Title='test111');
        //insert faq1 ; 

        //ApexPages.KnowledgeArticleVersionStandardController ctl =
        //                  new ApexPages.KnowledgeArticleVersionStandardController(faq1);
        //howto_controller controller = new howto_controller(ctl);
        
        Test.stopTest();
        
  }


    static void setupData() {
    // create article of first type found in the objects that end with __kav
    List<String> kavNames = new List<String>(pkb_Controller.kavNames);
    if (kavNames.isEmpty()) return;

    // set the controller's default pub status to draft so that the queries will find records
    pkb_Controller.DEFAULT_PUBLISH_STATUS = publishStatus;
    pkb_Controller.DEFAULT_SITE_NAME = siteName;

    objType = kavNames.get(0);

    System.debug('***** CUSTOM ARTICLE TYPE: ' +objType+ ' *****');

    kavObj = Schema.getGlobalDescribe().get(objType).newSObject();
    kavObj.put('Title','Foo Foo Foo!!!'+String.valueOf(Crypto.getRandomInteger()));
    kavObj.put('UrlName', 'foo-foo-foo'+String.valueOf(Crypto.getRandomInteger()));
    kavObj.put('Summary', 'This is a summary!!! Foo. Foo. Foo.');
    kavObj.put('Language', lang);
    insert kavObj;

    // requery the kavObj to get the KnowledgeArticleId on it that is created automatically
    String q = 'select ' +pkb_Controller.join(pkb_Controller.kavFields, ',')+ ' from KnowledgeArticleVersion where Id = \'' +kavObj.get('Id')+  '\' and PublishStatus = :publishStatus';
    kavObj = (KnowledgeArticleVersion)Database.query(q);

    // create featured record
    featured = new PKB_Featured__c(
      Article_Number__c = (String)kavObj.get('ArticleNumber'),
      Is_Keyword_Article__c = false,
      PKB_Name__c = siteName
    );
    insert featured;

    System.debug('***** FEATURED RECORD JUST CREATED: ' +featured.Id+ ' *****');
    System.debug(featured);

    // create keyword recommended record
    keyword = new PKB_Featured__c(
      Article_Number__c = (String)kavObj.get('ArticleNumber'),
      Is_Keyword_Article__c = true,
      Keyword__c = 'foo',
      PKB_Name__c = siteName
    );
    insert keyword;

    System.debug('***** KEYWORD RECORD JUST CREATED: ' +keyword.Id+ ' *****');
    System.debug(keyword);

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

}