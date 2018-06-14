public without sharing class faq_controller {

	public String feedbackSource { get; set; }
	public FAQ__kav theArticle { get; set; }
	public KnowledgeArticleData theKad { get; set; }
	public String feedbackComments { get; set; }
	public String sessionId { get; set; }
	
	
	/* ***** URL PARAM CONSTANTS AND GETTERS ***** */
	  public final static String QUERY_PARAM = 'q';
	  public final static String LANGUAGE_PARAM = 'lang';
	  public final static String CATEGORY_PARAM = 'c';
	  public final static String SESSION_PARAM = 's';
	  public final static String FEEDBACK_PARAM = 'f';
	  public final static String FEEDBACK_SOURCE_PARAM = 'fs';

	  public String queryParam            { get { return QUERY_PARAM; } }
	  public String languageParam         { get { return LANGUAGE_PARAM; } }
	  public String feedbackParam         { get { return FEEDBACK_PARAM; } }
	  public String feedbackSourceParam   { get { return FEEDBACK_SOURCE_PARAM; } }
	  
	  // values for the feedback source param; these *MUST* match the picklist values for the Feedback_Source__c field of the deflection object
	  private final static String FEEDBACK_CONTACT_US = 'ContactUs';
	  private final static String FEEDBACK_SEARCH = 'Search';
	  private final static String FEEDBACK_RELATED = 'RelatedArticle';
	  public String feedbackContactUs     { get { return FEEDBACK_CONTACT_US; } }
	  public String feedbackSearch        { get { return FEEDBACK_SEARCH; } }
	  public String feedbackRelated       { get { return FEEDBACK_RELATED; } }
	  
	  //CNS
    public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}
	  
	  // this also needs to be public to allow setting during unit tests
  	  public static String DEFAULT_SITE_NAME = Site.getName();
      
   	  private final static String FAQ_HOME_PAGE = '/faq_home';
      public String faqHome       { get { return FAQ_HOME_PAGE; } }
  
	/* ***** KAV EXTENSION, used in VF pages when need to derive article type name from whole object name ***** */
  private final static String KAV_EXTENSION = '__kav';
  public String kavExtension          { get { return KAV_EXTENSION; } }
	
	public faq_controller() { }

  /* ***** CONTROLLER EXTENSION CONSTRUCTOR ***** */
	public faq_controller(ApexPages.KnowledgeArticleVersionStandardController sc){
		
		theArticle = (FAQ__kav)sc.getRecord();
		theKad = new KnowledgeArticleData(theArticle.Id);
		
		// populate the props with ural param values as needed
    	String q = ApexPages.currentPage().getParameters().get(QUERY_PARAM);
    	String l = ApexPages.currentPage().getParameters().get(LANGUAGE_PARAM);
    	String fs = ApexPages.currentPage().getParameters().get(FEEDBACK_SOURCE_PARAM);
    	
    	if (!isBlank(l)) {
    		selectedLanguage = String.escapeSingleQuotes(l);
    	} else {
    		//Get language from Portal user's record
    		selectedLanguage = UserInfo.getLanguage();
    	}
    	
    	if (!isBlank(fs)) feedbackSource = fs; // need to validate this value is in the picklist when inserting
    		
		pkb_Controller pkbCtrl = new pkb_Controller(); 
		Cookie sessionCookie = ApexPages.currentPage().getCookies().get('PKB2SessionId');
	    if (sessionCookie == null) {
	        sessionId = pkbCtrl.randomUUID();
	        sessionCookie = new Cookie('PKB2SessionId', sessionId, '/', -1, false);
	        ApexPages.currentPage().setCookies(new Cookie[]{sessionCookie});
	    } else {
	        sessionId = sessionCookie.getValue();
	    }
	    
	    List<PKB_Article_Feedback_Deflection__c> afds = [
          select
            Id
          from PKB_Article_Feedback_Deflection__c
          where
            Session_ID__c = :sessionId and
            Article_Number__c = :theKad.articleNumber
        ];
        feedbackRecorded = !afds.isEmpty();
        
        if (!isBlank(q) && q.length() > 2) {
        	urlSearchQuery = q;
    	}else{
        	String errorMsg  = System.Label.PKB2_js_search_string_length;
        	errorMsg = errorMsg.replace('NNN','3');
        	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,errorMsg));
     	}
		
	}

	public class KnowledgeArticleData {
	    public String id                     { get; set; } // note this is the ID of the KnowledgeArticle record, not the ID of the KAV record
	    public String kavid                     { get; set; } //and the Id of the KAV record
	    public String title                  { get; set; }
	    public String summary                { get; set; }
	    public String urlName                { get; set; }
	    public String articleTypeName        { get; set; }
	    public String articleTypeLabel       { get; set; }
	    public DateTime lastModifiedDate     { get; set; }
	    public DateTime firstPublishedDate   { get; set; }
	    public DateTime lastPublishedDate    { get; set; }
	    public String articleNumber          { get; set; }
	    public KnowledgeArticleVersion theAV { get; set; }

	    // ctor for empty KAD
	    public KnowledgeArticleData() { }

	    // ctor that takes an already constructed-KAV record
	    public KnowledgeArticleData(KnowledgeArticleVersion kav) {
	      init(kav);
	    }

	    // ctore that takes the ID of a KnowledgeArticle record and queries the KAV record from it
	    public KnowledgeArticleData(Id i) {
	   	  system.debug('article id: ' + i);
	   	  
	      String q = '';
	      String pub = pkb_Controller.DEFAULT_PUBLISH_STATUS;
	      q += 'select ' +join(kavFields, ',')+ ' from KnowledgeArticleVersion';
	      q += ' where PublishStatus = :pub and Id = :i limit 1';
	      system.debug('FAQ query: ' + q);
	      KnowledgeArticleVersion kav = (KnowledgeArticleVersion)Database.query(q);
	      init(kav);
	    }

    	public void init(KnowledgeArticleVersion kav) {
        	this.theAV = kav;
	      
	      id = this.theAV.KnowledgeArticleId;
	      kavid = this.theAV.Id;
	      title = this.theAV.Title;
	      summary = this.theAV.Summary;
	      urlName = this.theAV.UrlName; 
	      articleTypeName = getKAVDescribeById(id).getLocalName();
	      articleTypeLabel = getKAVDescribeById(id).getLabel();
	      lastModifiedDate = this.theAV.LastModifiedDate;
	      firstPublishedDate = this.theAV.FirstPublishedDate;
	      lastPublishedDate = this.theAV.LastPublishedDate;
	      articleNumber = this.theAV.ArticleNumber;
	    }
	  }


  // these fields must be queried when instantiating a KAD wrapper object, so this set is
  // used in the sosl and soql queries to ensure that all queries get the right fields
  public static Set<String> kavFields {
    get {
        if (kavFields == null) {
            kavFields = new Set<String>{
          'Id'
          ,'Title'
          ,'Summary'
          ,'UrlName'
          ,'ArticleNumber'
          ,'LastModifiedDate'
          ,'FirstPublishedDate'
          ,'LastPublishedDate'
          ,'Language'
          ,'PublishStatus'
          ,'KnowledgeArticleId'
            };
        }
      return kavFields;
    }
    private set;
  }
    
    public Boolean feedbackRecorded {
    	set;
    	get {
      	if (feedbackRecorded == null) feedbackRecorded = false;
      		return feedbackRecorded;
    	}
  	}
    
    public void createDeferral(Boolean isDeferred) {
	    // validate that the feedback source option is a valid option
	    String fs = (feedbackSourceOptions.contains(feedbackSource) ? feedbackSource : null);
	
	    PKB_Article_Feedback_Deflection__c afd = new PKB_Article_Feedback_Deflection__c(
	      Article_ID__c = theKad.Id,
	      Article_Number__c = theKad.ArticleNumber,
	      Article_Title__c = theKad.Title,
	      Feedback_Source__c = fs,
          Contact__c = popContact(),
	      Comments__c = feedbackComments,
	      Session_ID__c = sessionId,
	      Deflection__c = isDeferred,
	      Keyword_Searched__c = urlSearchQuery
	    );
	    insert afd;
	}
    
    private Id popContact(){
        User user = DAL_ISSP.getUser(Userinfo.getUserId());
        Contact con = DAL_ISSP.getContact(user.ContactId);
        return con.Id;
    }
	
	public Set<String> feedbackSourceOptions {
    	set;
    	get {
      		if (feedbackSourceOptions == null) feedbackSourceOptions = getActivePicklistOptions('PKB_Article_Feedback_Deflection__c', 'Feedback_Source__c').keySet();
      		return feedbackSourceOptions;
    	}
	}
	
	public static Map<String,String> getActivePicklistOptions(String so, String field) {
	    Map<String,String> options = new Map<String,String>();
	
	    for (Schema.PicklistEntry ple : getActivePicklistEntries(so, field)) {
	      options.put(ple.getValue(), ple.getLabel());
	    }
	    return options;
	}
	
  	public static List<Schema.PicklistEntry> getActivePicklistEntries(String so, String field) {
	    Map<String,Schema.SOBjectType> gd = Schema.getGlobalDescribe();
	    List<Schema.PicklistEntry> ples = new List<Schema.PicklistEntry>();
	
	    // return empty list if object name was not found in the schema
	    if (!gd.containsKey(so)) return ples;
	
	    Schema.DescribeSObjectResult sor = gd.get(so).getDescribe();
	    Map<String,Schema.SObjectField> sofs = sor.fields.getMap();
	
	    // return empty list if field name was not found in the object's field list
	    if (!sofs.containsKey(field)) return ples;
	
	    Schema.DescribeFieldResult dfr = sofs.get(field).getDescribe();
	
	    // return empty list if the field type is not picklist
	    if (dfr.getType() != Schema.DisplayType.Picklist) return ples;
	
	    for (Schema.PicklistEntry ple : dfr.getPicklistValues()) {
	      if (ple.isActive()) {
	        ples.add(ple);
	      }
	    }
	    return ples;
  	}
  	
  	public void deferred() {
	    createDeferral(true);
	    feedbackRecorded = true;
	}
	
	public void recordArticleFeedback() {
	    if (!isBlank(feedbackComments)) {
	        createDeferral(false);
	      feedbackRecorded = true;
	    }
	}
	
	public static Boolean isBlank(String s) {
    	return ( s == null || s == '');
  	}
  	
  public static String join(List<String> strings, String c) {
    if (strings == null || strings.isEmpty()) return null;

    String sep = (isBlank(c) ? ',' : c);
    Integer i, size;
    String s = strings[0];

    size = strings.size();
    for (i = 1; i < size; i++) {
      s += (sep + strings[i]);
    }
    return s;
  }
  
  // version of join method that takes a set of strings
  public static String join(Set<String> strings, String c) {
    return join(new List<String>(strings), c);
  }
  
  public String siteName { get { return DEFAULT_SITE_NAME; } }

  /* ***** CUSTOM SETTINGS (note that defaults are retrieved from the pkb_SettingsController) ***** */

  private PKB__c kbSettings { get { return PKB__c.getValues(siteName); }  }
  public Integer relatedArticles    { get { return (kbSettings == null ? pkb_SettingsController.DEFAULT_RELATED_SIZE : Integer.valueOf(kbSettings.Related_Articles_Size__c)); } }
 
  
  /* ***** DYNAMIC RETRIEVAL OF ARTICLE TYPES VIA DESCRIBES AND OBJECT ID PREFIXES ***** */

  public static Set<String> kavNames {
    set;
    get {
        if (kavNames == null) {
            kavNames = new Set<String>();
        Map<String,Schema.SOBjectType> gd = Schema.getGlobalDescribe();

        for (String s : gd.keySet()) {
          if (s.contains(KAV_EXTENSION)) {
            kavNames.add(s);
          }
        }
        }
      return kavNames;
    }
  }
  
  public static Map<String,Schema.DescribeSObjectResult> kavObjPrefixMap {
    get {
        if (kavObjPrefixMap == null) {
            kavObjPrefixMap = new Map<String,Schema.DescribeSObjectResult>();
        Map<String,Schema.SOBjectType> gd = Schema.getGlobalDescribe();
        Schema.DescribeSObjectResult sor;
        for (String s : kavNames) {
            sor = gd.get(s).getDescribe();
            kavObjPrefixMap.put(sor.getKeyPrefix().toLowerCase(), sor);
        }
        }
      return kavObjPrefixMap;
    }
  }

  public static Schema.DescribeSObjectResult getKAVDescribeById(String i) {
    if (isBlank(i) || i.length() < 15) return null;
    return kavObjPrefixMap.get(i.substring(0,3).toLowerCase());
  }
  
   public String selectedLanguage {
    set;
    get {
        system.debug('selectedLanguage: ' + selectedLanguage);
        if (isBlank(selectedLanguage)){
        	//No lang in URL so get logged in user's language
                    selectedLanguage = UserInfo.getLanguage();
        }
            return selectedLanguage;
   		}
   	}
   	
   	public String selectedLanguageURL {
    get {
      return '/' + selectedLanguage+'/';
    }
  }
   	
  /* ***** SEARCH RELATED PROPS AND METHODS ***** */

  public String selectedCategory { get; set; } 	
  public String urlSearchQuery { get; set; }
   	
   	// url-formatted (e.g. key1=value1&key2=value2) string containing the params related to a search
  public String allSearchParams {
    get {
        String s;
        List<String> keyValues = new List<String>();
        if (!isBlank(urlSearchQuery))   keyValues.add(QUERY_PARAM+ '=' +EncodingUtil.urlEncode(urlSearchQuery, 'UTF-8'));
        if (!isBlank(selectedLanguage)) keyValues.add(LANGUAGE_PARAM+ '=' +EncodingUtil.urlEncode(selectedLanguage, 'UTF-8'));
        if (!isBlank(selectedCategory)) keyValues.add(CATEGORY_PARAM+ '=' +EncodingUtil.urlEncode(selectedCategory, 'UTF-8'));
        s = join(keyValues, '&');
      return s;
    }
  }
    
}