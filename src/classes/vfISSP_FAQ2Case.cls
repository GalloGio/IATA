/*
    Class that exposes contact support functionalities for Portal and NewGen APP (mobile), like Live Chat, Call Information and Case Creation.
    Used in ICE service and NewGen APP (mobile)
*/
//TRANSFORM 02/03/15 ==> includes new functionality algorithm  provided by Elliot ,
/**
 * Last update by Nurit and Niv 11/16/2014
 */
@RestResource(urlMapping='/newgenapp/v1/contactSupport/*')
global class vfISSP_FAQ2Case
{
    public class ButtonsInfoType{
        public Integer Order { get; set; }
        public String Category { get; set; }
        public String Name { get; set; }
        public String ButtonId { get; set; }
        public String DeploymentId { get; set; }
        public String Language { get; set; }
    }

    /* Buttons State */
    public static final String OnlyCancel   = 'OnlyCancel';
    public static final String CancelAndCreateACase   = 'CancelAndCreateACase';
    public static final String CancelAndSubmit   = 'CancelAndSubmit';
    public static final Id PARTNER_USER_ROLE = [SELECT id FROM CaseTeamRole WHERE Name = 'Partner User Role'].Id;
	public static final String IFG_TOPIC ='IATA_Financial_Gateway_IFG__c';

    //basto1p
    public static final String DEFAUL_CASE_LANG_CODE='en';
    public static final String BUTTON_NOT_ALLOWED='BUTTON_NOT_ALLOWED';
    public static final String BUT_CAT_PORTAL='BUT_CAT_1_PORTAL';
    public static final String BUT_CAT_COUNTRY='BUT_CAT_2_COUNTRY';
    public static final String BUT_CAT_ENGLISH='BUT_CAT_3_ENGLISH';
    public static final String BUT_CAT_EMERGENCY='BUT_CAT_4_EMERGENCY';
    public static final String BUT_CAT_ALL='BUT_CAT_ALL';

    public static final String LVA_CALL_US_GEN='LVA_CallUs_GEN';

	public static final Integer LVA_INTRO_VID_COOKIE_DEACTIVATED=-1;

    //Intro videos mode can be a popo up or a dialog modal window
    public static final String LVA_INTRO_VIDEO_MODE_POP_UP='LVA_INTRO_VIDEO_MODE_POP_UP';
    public static final String LVA_INTRO_VIDEO_MODE_DIALOG='LVA_INTRO_VIDEO_MODE_DIALOG';

    //basto1p - live agent v2 - config parameters
    public static final String LVA_CFG_INTRO_VIDEO_URL='LVA_CFG_INTRO_VIDEO_URL';
    public static final String LVA_CFG_INTRO_VIDEO_SECTORS='LVA_CFG_INTRO_VIDEO_SECTORS';
    public static final String LVA_CFG_INTRO_VIDEO_MODE='LVA_CFG_INTRO_VIDEO_MODE';
    public static final String LVA_CFG_INTRO_VIDEO_DISPLAY_TIMES='LVA_CFG_INTRO_VIDEO_DISPLAY_TIMES';


    public static final String LVA_CFG_FAQS_COUNTRIES_NOT_ALLOWED='LVA_CFG_FAQS_COUNTRIES_NOT_ALLOWED';

    //Emergency button enable for account (settins)
    public static final String LVA_CFG_ACCOUNT_EMERG_FIELD_NAME='LVA_CFG_ACCOUNT_EMERG_FIELD_NAME';
    public static final String LVA_CFG_ACCOUNT_EMERG_FIELD_VALUE='LVA_CFG_ACCOUNT_EMERG_FIELD_VALUE';
    public static final String LVA_CFG_ACCOUNT_EMERG_CHECK_HIERARCHY='LVA_CFG_ACCOUNT_EMERG_CHECK_HIERARCHY';
    public static final String LVA_CFG_ACCOUNT_EMERG_TOPIC_FILTER_AND='LVA_CFG_ACCOUNT_EMERG_TOPIC_FILTER_AND';

    //basto1p - live agent v2 cookies prefixs
    public static final String LVA_COOK_INTRO_VIDEO='LVA_COOK_INTRO_VIDEO';

	public LiveAgentButtonSettings__c butttonToShow {get; set;}


    //specific buttons
    public static final String SPC_BUTT_EMERGENCY='Emergency';

    public String currentButtonsToShow {get; set;}
    public boolean SHowButtons {get; set;}
    public String recordToCreate {get; set;}
    public list<SelectOption> lst_selectTopics {get;set;}
    public list<SelectOption> lst_selectsubTopics {get;set;}
    public list<SelectOption> lst_selectTopics_Emergencies {get;set;}
    public list<SelectOption> lst_selectAreasOfConcern {get;set;}

    public String topic { get; set; }
    public String topicLabel { get; set; }
    public String subtopic { get; set; }
    public String areaOfConcern { get; set; }
    public String concernedCountry { get; set; }
    public String selectedCountry { get; set; }
    public clsDataCategoryContainer DataCategoryContainer {get;set;}
    public list<ArticleViewLine> articleViewLines { get; set; }
    //public FAQ__kav selectedArtical { get; set; }
    public ArticleModalView SelectedArticleModalView {get; set;}
    public Id parentAccountId {get;set;} //TF - SP9-C5

    public boolean isAgencyUser {get;set;} //TF - SP9-C5
    public boolean isGSAUser {get;set;} //TF - SP9-C5
    public boolean isGSAOnly {get;set;} //TF - SP9-C5
    public String accountId {get;set;} //TF - SP9-C5
    public String myTopic {get;set;} //TF - SP9-C5
    public boolean isPWCProfile {get;set;}
    public boolean isDPCUser {get;set;}
    public boolean isIFG {get;set;}
    public static boolean isComplain {get;set;}//Indicates if the user clicked the "I wish to complain button"
    // compliments
    public static boolean isCompliment {get;set;}//Indicates if the user clicked the "Share a compliment button"
    // end compliments
    public List <SelectOption> airlines {get; set;}//TF GSA too many records error
    public Map<String,List<Services_Rendered__c>> gsaMap {get; set;}
    public String gsaSelectedCountry {get; set;}
    public List <SelectOption> gsaCountryList {get; set;}//TF GSA too many records error

    //ADDED to the Fields display by setting logic
    public List<ISSP_Case_Fields__c> ISSP_CaseFields_Lst {get;set;}
    public sectionRecordWrapper newSection {get; set;}
    public List<sectionRecordWrapper> fullList {get; set;}

    //Page SHOW Buttons in side Bar booleans , According to Record types
    public boolean isSISHelpDesk {get;set;}
    public boolean isIATAServiceRequest {get;set;}
    public boolean isPWCServiceRequest {get;set;}
    public boolean isDPCServiceRequest {get;set;}

    //Clicked Buttons in side Bar booleans ,
    public boolean Clicked_SISHelpDesk {get;set;}
    public boolean Clicked_IATAServiceRequest {get;set;}
    public boolean Clicked_PWCServiceRequest {get;set;}
    public boolean Clicked_DPCServiceRequest {get;set;}
    public boolean Clicked_EmergencyRequest {get;set;}

    //Added new Help Text to the Page
    public ISSP_HelpText__c ISSP_TopicHelptext {get;set;}
    public ISSP_HelpText__c ISSP_SubTopicHelptext {get;set;}

    //Added new Create button Functionality
    //public ISSP_CreateButtonURL__c ISSP_CreateButtonURL {get;set;}
    public String CreateButtonURL {get;set;}

    //Sector field of the Account
    public string Sector {get; set;}
    public string AccountISOCountry {get; set;}
    public String labelSubTopic = '';
    public  boolean isComplain1 = false;
    public  boolean isCompliment1 = false;

    public Boolean isTopicDefault = false; // INC263231

    public list<String> errorMessage {get; set;}

    public String iataCode {get;set;}
    //CNS
    public String communityName{ 
        get {
            if(callApexPagesParameters){
                return ApexPages.currentPage().getParameters().get('CommunityName'); 
            }
            else{
                return '';
            }
        }
        set;
    }
    public String commParam { get { if(communityName=='CNS'){ return '&CommunityName='+ communityName;} return ''; } set;}

    //basto1p live agent v2
    private static Map<String,LVA_Configs__mdt> LVAConfigs;
    private Map <String,LiveAgentButtonSettings__c> livAgConfButtonsMapBySectAndIsoC;
    private Map <String,String> livAgentCsButtonNameVsCategoryMap;
    public Map<String,buttonsInfoType> csButtonsList {
        get{
            //order by order number
            //csButtonsList.sort();

            return csButtonsList;
        }

        set;}
    public String csButtonsListJson {
        get{

            return JSON.serialize(csButtonsList);
        }
        set;}
    public String callUsFinalString {get; set;}
    // Map < Phone number, Available hours >
    public Map <String, String> callUsMap { get; set; }

    public Boolean isToShowFAQs {
        get{
            Boolean resVal=false;
            Boolean isItDefaultTopic=(topic.compareTo(Env.SelectOptionDefaultValue) == 0);

            if (isCompliment1){
                resVal=false;
            }
            else if ( isItDefaultTopic || String.isBlank(topic)){
                resVal=false;
            }
            else if (!isItDefaultTopic){
                resVal=true;
            }

            //basto1p - Live agent V2
            if (!areFAQsAllowedForCurrentCountry()){
                resVal=false;
            }

            system.debug('basto1p - isToShowFAQs='+resVal+'; isTopicDefault='+isTopicDefault+'; topic='+topic);
            return resVal;
        }
    set;}


	private static Boolean isCNSInitialized = false;
	public static Boolean isCNS {
		get{
			if (!isCNSInitialized) {
				isCNS=ISSP_Utilities.isCNS();
				isCNSInitialized=true;
                System.debug('basto1p - isCNS INITIALIZED.');
			}
//isCNS=true;//basto1p - test only
            System.debug('basto1p - isCNS='+isCNS);
			return isCNS;
		}
		set;
	}


	//basto1p live agent v2 intro video handle
    public Boolean isIntrovideoAlreadyShowed {
        get {
            String cookieNameStr=LVA_COOK_INTRO_VIDEO+UserInfo.getUserId()+livAgentIntroVidUrl;
            Integer CookieValCount=0;
			Boolean retVal=false;

            //get cookie with format username_getLivAgConfig(LVA_CFG_INTRO_VIDEO_URL)
            Cookie introVideoCookie = ApexPages.currentPage().getCookies().get(cookieNameStr);

            // If this is the first time the user is accessing the page,
            // create a new cookie with name 'counter', an initial value of '1',
            // path 'null', maxAge '-1', and isSecure 'false'.
            if (introVideoCookie == null) {
                introVideoCookie = new Cookie(cookieNameStr,'1',null,-1,false);
            }
			else{ // If this isn't the first time the user is accessing the page
				CookieValCount = Integer.valueOf(introVideoCookie.getValue());
//introVideoCookie = new Cookie(cookieNameStr, '0', null, -1, false);//basto1p - for tests
				if (CookieValCount != LVA_INTRO_VID_COOKIE_DEACTIVATED) {
					// create a new cookie, incrementing the value of the original count by 1
					introVideoCookie = new Cookie(cookieNameStr, String.valueOf(CookieValCount + 1), null, -1, false);
				}
            }

            // Set the new cookie for the page
            ApexPages.currentPage().setCookies(new Cookie[]{introVideoCookie});
			if (
				(CookieValCount>Integer.valueOf(getLivAgConfig(LVA_CFG_INTRO_VIDEO_DISPLAY_TIMES)))
			  ||(CookieValCount == LVA_INTRO_VID_COOKIE_DEACTIVATED)
			){
				retVal=true;
			}

			System.debug('basto1p - isIntrovideoAlreadyShowed retVal='+retVal+'; CookieValCount='+CookieValCount);
            return retVal;
        }
        set;
    }
    public String livAgentIntroVidUrl{
        get{
            String retVal='';

            String sectorsList='';
            String videoUrl='';
            integer i=1;
            do {
                sectorsList=getLivAgConfig(LVA_CFG_INTRO_VIDEO_SECTORS+i);
                videoUrl=getLivAgConfig(LVA_CFG_INTRO_VIDEO_URL+i);
                if (sectorsList!=null && sectorsList.containsIgnoreCase(this.Sector)){
                    retVal=videoUrl;
                    break;
                }
                i=i+1;
                System.debug('basto1p - sectorsList='+sectorsList);
            }
            while (videoUrl!=null);//when there is no video url it means the list is over

            return retVal;
        }
        set;
    }
    public String livAgentIntroVidMode{
        get{
            return getLivAgConfig(LVA_CFG_INTRO_VIDEO_MODE);
        }
        set;
    }
    public Boolean livAgentIntroVidIsAllowed{
        get{
            if (isCNS || (String.isBlank(livAgentIntroVidUrl))) {
                return false;
            }
            else{
                return true;
            }
        }
        set;
    }

    public String weLoveToHelpLabel{
        get{
            // there is a bug in sdalesforce: if using the character ' in label the parameter is not replaced
            String resultVal=String.format(Label.LVA_ReachOutUs, new List<String>{UserInfo.getFirstName()});

            //String resultVal=Label.LVA_ReachOutUs+' '+UserInfo.getName();
            return resultVal;
        }
        set;
    }

    // Added for NewGen APP - when a REST is called, there's no ApexPages Parameters and because of that
    // this was getting NullPointerException. 
    public Boolean callApexPagesParameters {
        get {
            // by default, call every Apex Pages Parameters
            return callApexPagesParameters == null ? true : callApexPagesParameters;
        }
        set;
    }


	public void livAgentIntroVidCloseAndDontRemenber(){
		String cookieNameStr=LVA_COOK_INTRO_VIDEO+UserInfo.getUserId()+livAgentIntroVidUrl;

		Cookie introVideoCookie = new Cookie(cookieNameStr,
											 String.valueOf(LVA_INTRO_VID_COOKIE_DEACTIVATED),
											 null, -1, false);
		// Set the new cookie for the page
		ApexPages.currentPage().setCookies(new Cookie[]{introVideoCookie});
	}

    public vfISSP_FAQ2Case()
    {
        //basto1p - live agent v2
        this.resetLiveAgentVars();
    }

    global class CustomerSupporWrapperGet {
        global Map <String, String> topicsMap { get; set; }
        global Map <String, String> subTopicsMap { get; set; }
        global Map <String, String> countryMap { get; set; }

        global CustomerSupporWrapperGet(){
            topicsMap = new Map <String, String>();
            subTopicsMap = new Map <String, String>();
            countryMap = new Map <String, String>();
        }
    }

    /**
    *    Get method for NewGenAPP mobile to have topic, subtopic and countries picklists
    **/
    @HttpGet
    global static CustomerSupporWrapperGet doGet(){
        CustomerSupporWrapperGet customerSupport = new CustomerSupporWrapperGet();

        vfISSP_FAQ2Case faq2Case = new vfISSP_FAQ2Case();
        faq2Case.pageLoad();
        // after page load, all the countries should be now in countryList list.
        if(faq2Case.countryList != null){
            for (SelectOption countrySelectOpt : faq2Case.countryList){
                // discard default values
                if(countrySelectOpt.getValue() == ''){
                    continue;
                }
                // create country map with calculated selectOption
                customerSupport.countryMap.put(countrySelectOpt.getValue(), countrySelectOpt.getLabel());
            }
        }
        // after page load, all the topics should be now in lst_selectTopics list.
        if(faq2Case.lst_selectTopics != null){
            for (SelectOption topicSelectOpt : faq2Case.lst_selectTopics){
                // discard default values
                if(topicSelectOpt.getLabel() == Env.SelectOptionDefaultValue){
                    continue;
                }
                // create topics map with calculated selectOption
                customerSupport.topicsMap.put(topicSelectOpt.getValue(), topicSelectOpt.getLabel());

                faq2Case.topic = topicSelectOpt.getValue();

                // calculate sub topic for each topic 

                faq2Case.lst_selectsubTopics = new list<SelectOption>();
                Integer index = Integer.valueOf(faq2Case.topic.trim());

                clsDataCategory selectDataCategory = faq2Case.DataCategoryContainer.lst_DataCategories[index];

                if (selectDataCategory.lst_childs.size() > 0){
                    for(Integer cIndex = 0; cIndex < selectDataCategory.lst_childs.size(); cIndex++){
                        clsDataCategory.CategoryChildWrapper childCat = selectDataCategory.lst_childs[cIndex];
                        faq2Case.lst_selectsubTopics.add(new SelectOption(childCat.CategoryName, childCat.CategoryLabel));
                    }

                    faq2Case.subtopic = selectDataCategory.CategoryName;
                }
                else{
                    faq2Case.lst_selectsubTopics.add(new SelectOption(Env.SelectOptionEmptyValue, Env.SelectOptionEmptyValue));
                    faq2Case.subtopic = selectDataCategory.CategoryName;
                }

                faq2Case.setSubTopicByPermissions();

                if(faq2Case.lst_selectsubTopics != null){
                    for (SelectOption subTopicSelectOpt : faq2Case.lst_selectsubTopics){
                        // discard default values
                        if(subTopicSelectOpt.getLabel() == Env.SelectOptionDefaultValue){
                            continue;
                        }
                        // create subtopics map with calculated selectOption
                        customerSupport.subTopicsMap.put(topicSelectOpt.getValue() + '#' + subTopicSelectOpt.getValue(), subTopicSelectOpt.getLabel());
                    }
                }

            }
        }

        return customerSupport;
    }

    global class CustomerSupporWrapperPost {
        global Map <String, buttonsInfoType> csButtonsMap { get; set; }
        global Map <String, String> callUsMap { get; set; }
        global String region { get; set; }
        global Case newCase { get; set; }

        global CustomerSupporWrapperPost(){
            csButtonsMap = new Map <String, buttonsInfoType>();
            callUsMap = new Map <String, String>();
            region = '';
        }
    }

    /**
    *    Post method for NewGenAPP mobile to have the live agent button and phone contact information 
    *       according to selected topic, subtopic and country
    *    If subject and description fields have value, it means that the user is trying to create a case
    **/
    @HttpPost
    global static CustomerSupporWrapperPost doPost(String topicCode, String subTopicCode, String countryIsoCode, 
                                String aditionalRecipients, String subject, String description, String origin){
        CustomerSupporWrapperPost customerSupport = new CustomerSupporWrapperPost();

        vfISSP_FAQ2Case faq2Case = new vfISSP_FAQ2Case();
        // bypass any apex page parametes calls, otherwise will get NullPointerException
        faq2Case.callApexPagesParameters = false;
        faq2Case.Clicked_EmergencyRequest = false;
        faq2Case.pageLoad();
        // set choosen topic, subtopic and country
        faq2Case.topic = topicCode;
        faq2Case.refreshTopicPickList();
        faq2Case.subtopic = subTopicCode;
        faq2Case.refreshSubTopicPickList();
        faq2Case.newCase.IFAP_Country_ISO__c = countryIsoCode;
        // calculate buttons and phone contact information
        faq2Case.setLiveAgentButtonsNames();

        customerSupport.csButtonsMap = faq2Case.csButtonsList;
        customerSupport.callUsMap = faq2Case.callUsMap;
        customerSupport.region = faq2Case.region;

        if(!String.isEmpty(subject) && !String.isEmpty(description)){
            faq2Case.newCase.subject = subject;
            faq2Case.newCase.description = description;
            for (sectionRecordWrapper section : faq2Case.fullList) {
                for (fieldRecordWrapper thisField : section.fieldList) {
                    if (thisField.fieldType == 'ccothers') {
                        thisField.fieldValueEntered = aditionalRecipients;
                    }
                }
            }
            faq2Case.newCase.Origin = origin;
            
            faq2Case.save();

            faq2Case.newCase = [SELECT  Id, Status, CaseNumber, Area_of_Concern__c, BSPCountry__c, Case_Language__c, Country_concerned_by_the_query__c,
                                    Description, IFAP_Country_ISO__c, Origin, Subject, SubTopic__c, Topic__c
                                FROM    Case 
                                WHERE   Id =: faq2Case.newCase.Id];
        }

        customerSupport.newCase = faq2Case.newCase;

        return customerSupport;
    }

    /*******************************************************************************************************
    * @description Loads all live agent configurations from LVA_Configs__mdt metadata type
    *
    * @return {void} Sets value of static variable map LVAConfigs with all configured values
    *
    * @example
    * this.loadLVAConfigurations();
    *
    * @history
    * -----------------------------------------------------------------------------------------------
    * Date         Created by                        Description
    * 2017-10-03   paulo.bastos@rightitservices.com  Creation
    ********************************************************************************************************/
    public static void loadLVAConfigurations() {
        if (LVAConfigs==null || LVAConfigs.size()<1) {

            LVAConfigs=new Map<String,LVA_Configs__mdt>();

            List<LVA_Configs__mdt> ConfigsList=[SELECT DeveloperName, MasterLabel, Value__c, ValueLong__c
                    FROM LVA_Configs__mdt
            ORDER BY MasterLabel ASC];

            //Get defaults from custom setting
            for(LVA_Configs__mdt ItemAux : ConfigsList)
            {
                LVAConfigs.put(ItemAux.DeveloperName,ItemAux);
            }

            System.debug('basto1p - LVAConfigs='+LVAConfigs);
        }
    }
    /*******************************************************************************************************
    * @description gets a live agent given configuration parameter value from LVA_Configs__mdt metadata type
    *
    * @param {String} Name of configuration parameter to get
    *
    * @return {String} Value of given configuration parameter
    *
    * @example
    * this.getLivAgConfig(LVA_CFG_INTRO_VIDEO_URL);
    *
    * @history
    * -----------------------------------------------------------------------------------------------
    * Date         Created by                        Description
    * 2017-10-03   paulo.bastos@rightitservices.com  Creation
    ********************************************************************************************************/
    public static string getLivAgConfig(String key){
        loadLVAConfigurations();

        if (LVAConfigs.containsKey(key)) {
            String retVal;

            retVal=LVAConfigs.get(key).Value__c;
            if (String.isBlank(retVal)){
                retVal=LVAConfigs.get(key).ValueLong__c;
            }
            return retVal;
        }
        else {
            System.debug('basto1p - Configuration KEY NOT FOUND:'+key);
            return null;
        }
    }

    /*******************************************************************************************************
    * @description Checks if FAQs items will are NOT allowed to be displayed in Case Portal User Interface
    *              Based in list of not allowed countries in configuration parameter existent in
    *              LVA_Configs.LVA_CFG_FAQS_COUNTRIES_NOT_ALLOWED
    *
    * @return {Boolean} True if FAQs are allowed, false if not
    *
    * @example
    * areFAQsAllowedForCurrentCountry();
    *
    * @history
    * -----------------------------------------------------------------------------------------------
    * Date         Created by                        Description
    * 2017-11-16   paulo.bastos@rightitservices.com  Creation
    ********************************************************************************************************/
    private static Boolean areFAQsAllowedForCurrentCountry(){
        Boolean resVal=true;
        //basto1p - LiveAgentv2 - only generates articles view if faqs area available for that country
        Id currentUserId=UserInfo.getUserId();
        String listCountriesFAQsNotAvailable=getLivAgConfig(LVA_CFG_FAQS_COUNTRIES_NOT_ALLOWED);
        String currentUserCountry=UserInfo.getLocale().substring(0, 2);
        List<LoginHistory> loginHistoryList;

        loginHistoryList=[SELECT CountryIso, UserId, LoginTime
        FROM LoginHistory
                WHERE UserId=:currentUserId
                ORDER BY LoginTime DESC
                LIMIT 1];
        if (loginHistoryList.size()>0){
                currentUserCountry=loginHistoryList[0].CountryIso;
        }

        System.debug('basto1p - isToShowFAQs.currentUserCountry='+currentUserCountry);
        System.debug('basto1p - isToShowFAQs.UserInfo.getLocale()=='+UserInfo.getLocale());
        if (String.isBlank(currentUserCountry)){
            resVal=false;
        }
        else if(listCountriesFAQsNotAvailable!=null&&
                listCountriesFAQsNotAvailable.containsIgnoreCase(currentUserCountry)){
            resVal=false;
        }

        return resVal;
    }

    public PageReference pageLoad() {
        errorMessage = new list<string>();

        SelectedArticleModalView = new ArticleModalView();
        //TF - SP9-C5
        isGSAUser = false;
        isGSAOnly = false;
        isPWCProfile = false;
        isDPCUser = false;
        isIFG = false;
        isToShowFAQs = false;
        //Page SHOW Buttons in side Bar booleans , According to Record types
        isSISHelpDesk       = false ;
        isIATAServiceRequest= false ;
        isPWCServiceRequest = false ;
        isDPCServiceRequest = false ;
        callUsMap = new Map <String, String>();

        //isComplain = false;
        newCase.Description = '';
        Id profileId=userinfo.getProfileId();

        //Call the new method that decides what Links the user allowed to see according to his case record type
        setCaseRecordTypeAccess();

        //Call for the new method that arrange the fields according to the Custom settings
        GenerateFieldsBySettings();

        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        if(profileName.startsWith('ISS Portal PwC')){  isPWCProfile = true; }
        if(profileName.startsWith('ISS Portal DPC') ){  isDPCUser= true; }
        if(profileName.startsWith('ISS Portal Agency') ){  isAgencyUser= true; }
        if(profileName.startsWith('ISS Portal GSA') ){
            isGSAUser= true;
            getGsaCountryList_2();
            }

        //TF - PwC and DPC users must be redirected to old page
        if (isPWCProfile || isDPCUser){
            PageReference pr;
            String retURL = ApexPages.currentPage().getParameters().get('retUrl');
            if(String.isNotBlank(retURL))
                pr = new PageReference('/ISSP_Case?mid=M1S1&retUrl=' + retURL + commParam);
            else
                pr = new PageReference('/ISSP_Case?mid=M1S1' + commParam);
            return pr;
        }
        //set Sector Field according to Account.Sector__c
        User user   = DAL_ISSP.getUser(Userinfo.getUserId());
        Contact con = DAL_ISSP.getContact(user.ContactId);
        Sector      = con.Account.Sector__c != null ? con.Account.Sector__c : '';
        AccountISOCountry = con.Account.IATA_ISO_Country__r.ISO_Code__c != null ? con.Account.IATA_ISO_Country__r.ISO_Code__c : '';
        this.parentAccountId = con.AccountId;

        //Call for the new method that arrange the fields according to the Custom settings
        GenerateFieldsBySettings();

        if(ApexPages.currentPage() != null){
            myTopic = ApexPages.currentPage().getParameters().get('topic');
        }
        this.currentButtonsToShow = OnlyCancel;
        SHowButtons = false ;
        labelSubTopic = Label.ISSP_F2CSubTopic;

        this.lst_selectTopics = new list<SelectOption>();
        //TF - line below commented because the initial value will now be set in initTopicsList, in case the topic has been set in the URL
        //this.lst_selectTopics.add(new SelectOption(Env.SelectOptionDefaultValue, Env.SelectOptionDefaultValue));
        this.lst_selectsubTopics = new list<SelectOption>();
        this.lst_selectsubTopics.add(new SelectOption(Env.SelectOptionDefaultValue, Env.SelectOptionDefaultValue));

        //Initiliaze Fields:
        this.topic = '';
        this.subtopic = '';
        this.DataCategoryContainer = new clsDataCategoryContainer();

        //this.DataCategoryContainer.print();
        initTopicsList();
        return null;
    }


    /*******************************************************************************************************
    * @description Sets chat buttons names according with:
    *                 a) subtopic selected (must be listed in Custom Setting
    *              ISSP FAQ2CaseLiveAgentTopics),
    *                 b) Account sector (field sector from user's account)
    *                 c) Country code (must be in list LiveAgent_Countries_Per_Button__c)
    *
    *
    * @return {Void} Updates this class list of buttons to display in visualsource page
    *                variable: livAgConfButtonsToDisplay
    *
    * @example
    * this.setLiveAgentButtonsNames();
    *
    * @history
    * -----------------------------------------------------------------------------------------------
    * Date         Created by                        Description
    * 2017-09-04   paulo.bastos@rightitservices.com  Creation
    ********************************************************************************************************/
    public void setLiveAgentButtonsNames(){
		System.debug('basto1p - BEGIN setLiveAgentButtonsNames');

        String mapKey;

        System.debug('basto1p - setLiveAgentButtonsNames - this.newCase.IFAP_Country_ISO__c='+this.newCase.IFAP_Country_ISO__c);

        //get info for button CallUs
        this.getAndSetCallUsString();

        //reset Lists
        this.resetLiveAgentVars();

        //basto1p live agent v2
        if (!String.isBlank(this.newCase.IFAP_Country_ISO__c) ){

            //////////////////////////////////////////////////////////////////////
            // get all configured live agent buttons for user sector
            // and portal and selected country languages
            // and set this.livAgConfButtonsMapBySectAndIsoC
            //////////////////////////////////////////////////////////////////////
            Map <String, LiveAgentButtonSettings__c> liveAgentConfList = LiveAgentButtonSettings__c.getAll();
            System.debug('basto1p - list custom setting mapp content: ' + liveAgentConfList.values());
            try {

                this.livAgConfButtonsMapBySectAndIsoC = new Map<String, LiveAgentButtonSettings__c>();
                String spcButtNameToAdd = '';
                String keyToAdd = '';
                String sectorToAdd = '';
                String regionToAdd = '';
                String languageToAdd = '';

                //Fill live agent configuration button map where map key is composed by sector and language in iso format
                for (LiveAgentButtonSettings__c butItem : liveAgentConfList.values()) {

                    Set<String> itemSectors = new Set<String>(butItem.sectors__c.split(','));
                    regionToAdd = butItem.Region__c;
                    if (regionToAdd == null) {
                        regionToAdd = '';
                    }
                    else{
                        regionToAdd=regionToAdd.toLowerCase().trim();
                    }

                    languageToAdd=butItem.Language__c;
                    if (languageToAdd == null) {
                        languageToAdd = '';
                    }
                    else{
                        languageToAdd=languageToAdd.toLowerCase().trim().substring(0, 2);
                    }

                    //add specific buttons here
                    if (butItem.Name == SPC_BUTT_EMERGENCY) {
                        spcButtNameToAdd = SPC_BUTT_EMERGENCY;
                    } else {
                        spcButtNameToAdd = '';
                    }

                    //decompose in sectores cofigured for this row
                    for (String itemSector : itemSectors) {

                        sectorToAdd=itemSector;
                        if (sectorToAdd == null) {
                            sectorToAdd = '';
                        }
                        else{
                            sectorToAdd=sectorToAdd.trim();
                        }

                        keyToAdd = spcButtNameToAdd +
                                sectorToAdd +
                                languageToAdd +
                                regionToAdd;
                        System.debug('basto1p - keyToAdd=' + keyToAdd);
                        this.livAgConfButtonsMapBySectAndIsoC.put(keyToAdd, butItem);
                    }
                }
            } catch (Exception e) {
                System.debug('basto1p - setLiveAgentButtonsNames Error getting buttons config: ' + e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                                '{!$Label.LiveAgentCustomSettingNotFound} ' + e));
            }
            System.debug('basto1p - setLiveAgentButtonsNames MY CONFIG MAPP this.livAgConfButtonsMapBySectAndIsoC=' +
                    this.livAgConfButtonsMapBySectAndIsoC);
            //////////////////////////////////////////////////////////////////////


            /////////////////////////////////////////////////////////////////////
            // For each existent buttons category validates:
            //    1) if button is allowed
            //    2) and get the button name to use for the category in this
            //       given context (sector, case country, topic subtopic)
            /////////////////////////////////////////////////////////////////////
            Set<String> languagesConfigured = new Set<String>();
            String languageToConfigure='';

            //Default Button name based in default language define: DEFAUL_CASE_LANG_CODE
            languageToConfigure=DEFAUL_CASE_LANG_CODE.toLowerCase();
            mapKey = this.Sector + languageToConfigure;
            this.getButtonNameFromConfigAndAddToList(mapKey, BUT_CAT_ENGLISH);
            mapKey = mapKey + this.region.toLowerCase();//checks also if there is a button with region defined
            //(to support region not be mandatory in custom setting LiveAgentButtonSettings)
            this.getButtonNameFromConfigAndAddToList(mapKey, BUT_CAT_ENGLISH);
            //update list of configured lagunage
            languagesConfigured.add(languageToConfigure);

            //Button names based on current user LANGUAGE in PORTAL
            //get user salesforce current language (when changing portal language user settings language is also updated)
            languageToConfigure=UserInfo.getLanguage().trim().substring(0, 2).toLowerCase();
            mapKey = this.Sector + languageToConfigure;
            this.getButtonNameFromConfigAndAddToList(mapKey, BUT_CAT_PORTAL);
            mapKey = mapKey + this.region.toLowerCase();//checks also if there is a button with region defined
            //(to support region not be mandatory in custom setting LiveAgentButtonSettings)
            this.getButtonNameFromConfigAndAddToList(mapKey, BUT_CAT_PORTAL);
            //update list of configured lagunage
            languagesConfigured.add(languageToConfigure);



            //Get country language based in country selected in case
            //(will the language to configure by default)
            languageToConfigure = newCase.IFAP_Country_ISO__c.toLowerCase();
            String choseenCountrySuppLangs ='';

            //if there is a mapping in iso country Object to its languages,
            //use that otherwise use country iso code for language code above
            List<IATA_ISO_Country__c> countryAux =
            [SELECT LVA_CountryLanguage__c FROM IATA_ISO_Country__c
                    WHERE (    ISO_Code__c =:languageToConfigure
                            OR ISO_Code__c =:languageToConfigure.toUpperCase() )
            ];
            if (    countryAux.size() > 0 &&
                    String.isNotBlank(countryAux[0].LVA_CountryLanguage__c)) {
                choseenCountrySuppLangs = countryAux[0].LVA_CountryLanguage__c;

                List<String> slectCountryLangList = new List<String>();
                slectCountryLangList.addAll(choseenCountrySuppLangs.split(','));

                System.debug('basto1p - slectCountryLangList='+slectCountryLangList);

                Boolean caseLangSelected=false;
                for(String langSupportedStr: slectCountryLangList){
                    langSupportedStr=langSupportedStr.trim().substring(0, 2).toLowerCase();

                    //if country language was not yet configured use it
                    if (!languagesConfigured.contains(langSupportedStr)
                        && caseLangSelected==false
                    ){
                        //language to use is the one not existent yet
                        languageToConfigure=langSupportedStr;
                        //update list of configured language
                        languagesConfigured.add(languageToConfigure);
                        caseLangSelected=true;

                        System.debug('basto1p - languageToConfigure='+languageToConfigure);
                    }
                }
            }

            //Button name based in COUNTRY and iso language code SLECTED in portal case
            mapKey = this.Sector + languageToConfigure;
            this.getButtonNameFromConfigAndAddToList(mapKey, BUT_CAT_COUNTRY);
            mapKey = mapKey + this.region.toLowerCase();//checks also if there is a button with region defined
            //(to support region not be mandatory in custom setting LiveAgentButtonSettings)
            this.getButtonNameFromConfigAndAddToList(mapKey, BUT_CAT_COUNTRY);


            //////////////////////////////////////////////////////////////////////
            // Check emergency enabled conditions
            // and add specific button name EMergency
            //////////////////////////////////////////////////////////////////////

            //Specific button key (emergency) - Language is allways english (DEFAUL_CASE_LANG_CODE) for this button
            mapKey = SPC_BUTT_EMERGENCY + this.Sector + DEFAUL_CASE_LANG_CODE;//choseenCountryLang
            this.getButtonNameFromConfigAndAddToList(mapKey, BUT_CAT_EMERGENCY);
            mapKey = mapKey + this.region.toLowerCase();//checks also if there is a button with region defined
            //(to support region not be mandatory in custom setting LiveAgentButtonSettings)
            this.getButtonNameFromConfigAndAddToList(mapKey, BUT_CAT_EMERGENCY);

            System.debug('basto1p - setLiveAgentButtonsNames Buttons added to list.');
            //////////////////////////////////////////////////////////////////////

        }
        System.debug('basto1p - Final buttons - setLiveAgentButtonsNames - this.csButtonsList='+this.csButtonsList);
    }

    /*******************************************************************************************************
    * @description Gets button name from configured buttons map (this.livAgConfButtonsMapBySectAndIsoC)
    *              and add it to buttons list to be displayed in visualsource page (this.csButtonsList)
    *              It uses map this.livAgentCsButtonNameVsCategoryMap check for duplicate buttons (avoid duplicated buttons)
    *              It also checks if given button is allowed to be displayed by calling this.isLiveAgentButtonAllowed func.
    *
    * @param {string} butMapConfigKey - This as a string composed by buttonName+Language+Region
    *                                   (that is a unique way of identify the button)
    * @param {string} buttonCategory - Button category/group/type this parameter is used to
    *                 identify group of buttons in user interface if needed, and also to allow doing
    *                 different validations in code (if/when it is redequired different validations
    *                 for different groups of buttons.
    *
    *
    * @example
    * this.getButtonNameFromConfigAndAddToList('AirlineEnglishptEurope','BUT_CAT_PORTAL'');
    *
    * @history
    * -----------------------------------------------------------------------------------------------
    * Date         Created by                        Description
    * 2017-09-07   paulo.bastos@rightitservices.com  Creation
    ********************************************************************************************************/
    public void getButtonNameFromConfigAndAddToList(String butMapConfigKey,String buttonCategory){
        // if we are in Emergenecy section show ONLY emergecncy button category
        if (Clicked_EmergencyRequest  && buttonCategory!=BUT_CAT_EMERGENCY) return;
        // if we are in a NON Emergency section show only non emergency buttons
        if (!Clicked_EmergencyRequest  && buttonCategory==BUT_CAT_EMERGENCY) return;
        
        String csButtonNameAux;
        LiveAgentButtonSettings__c csButtonSettObj;

        System.debug('basto1p - BEGIN getButtonNameFromConfigAndAddToList - butMapConfigKey='+butMapConfigKey+'; buttonCategory='+buttonCategory );
        if (this.livAgConfButtonsMapBySectAndIsoC.containsKey(butMapConfigKey)){

            csButtonSettObj=this.livAgConfButtonsMapBySectAndIsoC.get(butMapConfigKey);
            csButtonNameAux=csButtonSettObj.Name;

            //check if already added to List
            if (this.livAgentCsButtonNameVsCategoryMap.containsKey(csButtonNameAux)){
                System.debug('basto1p - getButtonNameFromConfigAndAddToList button ALREADY IN LIST Will not be added to list of buttons to display: '
                        +'buttonCategory='+buttonCategory
                        +'; csButtonNameAux='+csButtonNameAux);
            }
            else{
                //check if button is allowed
                //Category to check
                String butCategoryToCheckTopics;
                //For specific buttons an exception shall be added here
                //to search subtopics only allowed for his specific button category
                if (buttonCategory==BUT_CAT_EMERGENCY){
                    butCategoryToCheckTopics=buttonCategory;
                }
                //For normal buttons the topic must exist on "ISSP FAQ2CaseLiveAgentTopics" custtom setting
                else{
                    butCategoryToCheckTopics='';
                }
                if ( this.isLiveAgentButtonAllowed(this.livAgConfButtonsMapBySectAndIsoC.get(butMapConfigKey)
                                                    ,butCategoryToCheckTopics) ){
                    System.debug('basto1p - button allowed isLiveAgentButtonAllowed = TRUE, ADDED TO LISTS');
                    this.livAgentCsButtonNameVsCategoryMap.put(csButtonNameAux,buttonCategory);

                    ButtonsInfoType butInfoAux=new ButtonsInfoType();
                    butInfoAux.Name=csButtonNameAux;
                    butInfoAux.Category=buttonCategory;
                    butInfoAux.ButtonId=csButtonSettObj.ButtonId__c;
                    butInfoAux.DeploymentId=csButtonSettObj.DeploymentId__c;
                    butInfoAux.Language=csButtonSettObj.Language__c;

                    if (buttonCategory==BUT_CAT_PORTAL){
                        butInfoAux.Order=1;
                    }
                    else if(buttonCategory==BUT_CAT_COUNTRY){
                        butInfoAux.Order=2;
                    }
                    else if(buttonCategory==BUT_CAT_ENGLISH){
                        butInfoAux.Order=3;
                    }
                    else if(buttonCategory==BUT_CAT_EMERGENCY){
                        butInfoAux.Order=4;
                    }

                    this.csButtonsList.put(buttonCategory,butInfoAux);
                }
                else{
                    //log not found button
                    System.debug('basto1p - button not ALLOWED getButtonNameFromConfigAndAddToList.csButtonNameAux='+csButtonNameAux);
                }
            }
        }
        else{
            //log not found button configuration
            System.debug('basto1p - button NOT CONFIGURED for given sector and country language setLiveAgentButtonsNames.mapKey='+butMapConfigKey);
        }
    }


    /*******************************************************************************************************
    * @description Gets and sets "Call Us" user interface modal dialog content string (using phone number
    *              and Available hours) according with configuration in metadata type LVA_CallUsConfig__mdt
    *              based on User's Account Sector, and case concerned country field chosen.
    *              Sets also  variable with that string value.
    *
    * @return {String} retVal - Returns the string to be displayed in the modal window "Call US"
    *                           containing the phone number and available hours string, according with
    *                           users account sector and case country selected.
    *
    *
    * @example
    * this.getAndSetCallUsString();
    *
    * @history
    * -----------------------------------------------------------------------------------------------
    * Date         Created by                        Description
    * 2017-09-29   paulo.bastos@rightitservices.com  Creation
    ********************************************************************************************************/
    public String getAndSetCallUsString(){
        String retVal=Label.LVA_CallUsNoConfigAvailable;
        List<LVA_CallUsConfig__mdt> ListOfCallUsconfigs=new List<LVA_CallUsConfig__mdt>();

        // Check configration for user account sector and country selected for case
        if (newCase.IFAP_Country_ISO__c!=null) {
            ListOfCallUsconfigs = [SELECT DeveloperName,IsoCountry__c, Sector__c,PhoneNumber__c,AvailableHours__c
                    FROM LVA_CallUsConfig__mdt
                    WHERE Sector__c=:sector
                    AND (IsoCountry__c=:newCase.IFAP_Country_ISO__c.toLowerCase()
                         OR IsoCountry__c=:newCase.IFAP_Country_ISO__c.toUpperCase())
                    ];
        }

        // if nothing found for previous search
        //Check configration for user account sector only
        if (ListOfCallUsconfigs.size()==0){
            ListOfCallUsconfigs=[SELECT DeveloperName,IsoCountry__c, Sector__c,PhoneNumber__c,AvailableHours__c
                    FROM LVA_CallUsConfig__mdt
                    WHERE Sector__c=:sector AND (IsoCountry__c='' OR IsoCountry__c=null)];
        }

        // if nothing found for previous searchs
        // Check generic configuration
        if (ListOfCallUsconfigs.size()==0){
            ListOfCallUsconfigs=[SELECT DeveloperName,IsoCountry__c, Sector__c,PhoneNumber__c,AvailableHours__c
                    FROM LVA_CallUsConfig__mdt
                    WHERE DeveloperName=:LVA_CALL_US_GEN];
        }

        if (ListOfCallUsconfigs.size()>0){
            retVal=createCallUsString(ListOfCallUsconfigs[0]);
        }

        this.callUsFinalString=retVal;

        return retVal;
    }

    public String getCallUsEmergencyFinalString(){
        return
            Label.LVA_CallUsThruPhoneNum+' <b>'+Label.LVA_CallUsEmergencyPhoneNumber +'</b>'+
            '<br/>'+Label.LVA_CallUsAvailableHours+' <b>'+Label.LVA_CallUsEmergencyAvailableHours+'</b>';
    }

    /*******************************************************************************************************
    * @description Constructs modal window "Call Us" string to be displayed.
    *
    * @return {String} retVal - Returns the string to be displayed in the modal window "Call US",
    *                           containing the phone number and available hours, according with
    *                           given configuration item (from LVA_CallUsConfig__mdt).
    *
    *
    * @example
    * this.getAndSetCallUsString();
    *
    * @history
    * -----------------------------------------------------------------------------------------------
    * Date         Created by                        Description
    * 2017-09-29   paulo.bastos@rightitservices.com  Creation
    ********************************************************************************************************/
    public String createCallUsString(LVA_CallUsConfig__mdt item){
	callUsMap.put(item.PhoneNumber__c, item.AvailableHours__c);
        String retVal=Label.LVA_CallUsThruPhoneNum+' <b>'+item.PhoneNumber__c +'</b>'+
                '<br/>'+Label.LVA_CallUsAvailableHours+' <b>'+item.AvailableHours__c+'</b>';

        return retVal;
    }

    public Case newCase
    {
        get
        {
            if(null == newCase) {
                newCase = new Case();
            }
            return newCase;
        }
        set;
    }

    public Case newCase1
    {
        get
        {
            if(null == newCase1) {
                newCase1 = new Case();
            }
            return newCase1;
        }
        set;
    }

    public String encTopicLbl{
        get{
            for (SelectOption option :lst_selectTopics){
                if (option.getValue() == topic){
                    return EncodingUtil.urlEncode(option.getLabel(), 'UTF-8');
                }
            }
            return null;
        }
    }

    public String encSubtopicLbl{
        get{
            for (SelectOption option :lst_selectsubTopics){
                if (option.getValue() == subtopic){
                    return EncodingUtil.urlEncode(option.getLabel(), 'UTF-8');
                }
            }
            return null;
        }
    }

    public String encIsoCountry{
        get{
            return EncodingUtil.urlEncode(newCase.IFAP_Country_ISO__c, 'UTF-8');
        }
    }
    public String region{
        get{
            for (IATA_ISO_Country__c country : countries){
                if (country.ISO_Code__c == newCase.IFAP_Country_ISO__c){
                    return country.Region__c;
                }
            }
           return null;
        }
    }
    /* basto1p removed and replaced by the one below
    public Set<String>topicsToShowButton {
        get{
            if (topicsToShowButton == null){
                List<ISSP_FAQ2CaseLiveAgentTopics__c> topics =
                    [SELECT value__c FROM ISSP_FAQ2CaseLiveAgentTopics__c];
                topicsToShowButton = new Set<String>();
                for (ISSP_FAQ2CaseLiveAgentTopics__c topic :topics){
                    topicsToShowButton.add(topic.value__c);
                }
            }
            return topicsToShowButton;
        }
        set;
    }
    */
    /*******************************************************************************************************
   * @description Gets list of subtopics for which a button from a given category is allowed to be shown,
   *              If no button category is given it will return the list of all topics allowed for all buttons
   *
   * @param {string} buttonCategory - Category of button
   *
   *
   * @example
   * this.getTopicsToShowButtonFromACategory('BUT_CAT_EMERGENCY');
   *
   * @history
   * -----------------------------------------------------------------------------------------------
   * Date         Created by                        Description
   * 2017-09-18   paulo.bastos@rightitservices.com  Creation
   ********************************************************************************************************/
    public Set<String> getTopicsToShowButtonFromACategory(String buttonCategory) {
        Set<String> topicsToShowButtonFromACategory;
        List<ISSP_FAQ2CaseLiveAgentTopics__c> topicsAux= new List<ISSP_FAQ2CaseLiveAgentTopics__c>();

        if (String.isBlank(buttonCategory)) {
            String searchSubtopicsForAllButtons='%'+BUT_CAT_ALL+'%';
            topicsAux =
            [SELECT value__c FROM ISSP_FAQ2CaseLiveAgentTopics__c
                    WHERE
                    (LVA_ButtomCategories__c ='')
                OR  (LVA_ButtomCategories__c LIKE :searchSubtopicsForAllButtons)
            ];
        }
        else
        {
            String searchText='%'+buttonCategory+'%';
            topicsAux =
            [SELECT value__c FROM ISSP_FAQ2CaseLiveAgentTopics__c
                    WHERE
            (LVA_ButtomCategories__c LIKE :searchText)
            ];
        }

        topicsToShowButtonFromACategory = new Set<String>();
        for (ISSP_FAQ2CaseLiveAgentTopics__c topic :topicsAux){
            topicsToShowButtonFromACategory.add(topic.value__c);
        }
        return topicsToShowButtonFromACategory;
    }

    public Boolean showButton {
        get{
            Boolean resVal=false;

            //basto1p live agente v2
            if  (this.csButtonsList.size()>0){
                resVal=true;
            }

            return resVal;
        }
        set;
    }

    public Boolean isComplainLayout{
        get{
            System.debug('basto1p - isComplainLayout='+isComplain1);
            return isComplain1;
        }
        set;
    }

    public Boolean showChatButtons {
        get{
            Boolean resVal=false;

            //basto1p live agente v2
            if  (showButton){
                resVal=true;
            }

            //Dont show chat btton if is CNS
            if (isCNS){
                resVal=false;
            }
            return resVal;
        }
        set;
    }


    /*******************************************************************************************************
    * @description Checks primary conditions needed for a chat buttons to display
    *              based in:
    *                 a) subtopic selected (must be listed in Custom Setting
    *              ISSP FAQ2CaseLiveAgentTopics),
    *                 b) Country code (must be in list LiveAgent_Countries_Per_Button__c)
    *
    * @param {LiveAgentButtonSettings__c} ButtonItemConfig - Butom item with configuration details from
    *                                                        LiveAgentButtonSettings custtom setting
    *
    * @return {Boolean} resVal - Returns true if there is any live agent button in list to be displayed
    *
    * @example
    * this.isLiveAgentButtonAllowed(ButtonItemConfig);
    *
    * @history
    * -----------------------------------------------------------------------------------------------
    * Date         Created by                        Description
    * 2017-09-04   paulo.bastos@rightitservices.com  Creation
    ********************************************************************************************************/
    private Boolean isLiveAgentButtonAllowed(LiveAgentButtonSettings__c ButtonItemConfig, String butCategory){
		System.debug('basto1p - BEGIN isLiveAgentButtonAllowed butCategory='+butCategory);

        Boolean allowedSubTopic=false;
		Boolean resVal=false;


        Set<String> listofAllowedTopics=getTopicsToShowButtonFromACategory(butCategory);
/*
for (string topicver:listofAllowedTopics){
    system.debug('basto1p - isLiveAgentButtonAllowed topicver='+topicver);
}
*/
        system.debug('basto1p - isLiveAgentButtonAllowed listofAllowedTopics='+listofAllowedTopics);
        system.debug('basto1p - isLiveAgentButtonAllowed subtopic='+subtopic);


        //Check if subtopic is allowed
        allowedSubTopic=listofAllowedTopics.contains(subtopic);

        system.debug('basto1p - isLiveAgentButtonAllowed allowedSubTopic='+allowedSubTopic);

        //Specific Exceptions for subtopic not allowed
        if (       ( (allowedSubTopic!=true)
                    &&(Boolean.valueOf(getLivAgConfig(LVA_CFG_ACCOUNT_EMERG_TOPIC_FILTER_AND))==false)
                    )
                || ( (allowedSubTopic==true)
                        &&(Boolean.valueOf(getLivAgConfig(LVA_CFG_ACCOUNT_EMERG_TOPIC_FILTER_AND))==true) )
        ){

            //////////////////////////////////////////////////////////////////////
            // Check emergency enabled conditions
            // and add specific button name Emergency
            //////////////////////////////////////////////////////////////////////
            if (butCategory==BUT_CAT_EMERGENCY){
                //Check 24/7 (emergency) service/feature is enable for this user account (key account)
                ID uContactId = [SELECT ContactId FROM User WHERE id =: Userinfo.getUserid()].contactId;
                ID uAccId = [SELECT AccountId FROM Contact WHERE id =: uContactId].AccountId;

                do {
                    //Account accObj = [SELECT ID_Card_KeyAccount_features__c FROM Account WHERE id =:uAccId];
                    SObject accObj = Database.query('SELECT id, ParentId, ' + getLivAgConfig(LVA_CFG_ACCOUNT_EMERG_FIELD_NAME) +
                            ' FROM Account WHERE id =\'' + uAccId + '\'');

                    System.debug('basto1p - accObj=' + accObj);
                    String fieldValue = '';
                    if (accObj != null) {
                        fieldValue = String.valueOf(accObj.get(getLivAgConfig(LVA_CFG_ACCOUNT_EMERG_FIELD_NAME)));
                    }
                    System.debug('basto1p - fieldValue=' + fieldValue);

                    if (!String.isBlank(fieldValue) &&
                            fieldValue.contains(getLivAgConfig(LVA_CFG_ACCOUNT_EMERG_FIELD_VALUE))) {
                        allowedSubTopic = true;
                    } else {
                        allowedSubTopic = false;
                    }

                    System.debug('basto1p - setLiveAgentButtonsNames ' +
                            getLivAgConfig(LVA_CFG_ACCOUNT_EMERG_FIELD_NAME) + '=' +
                            fieldValue);

                    uAccId=(Id)accObj.get('ParentId');
                }
                while (    !String.isBlank(uAccId)
                        && (allowedSubTopic!=true)
                        && Boolean.valueOf(getLivAgConfig(LVA_CFG_ACCOUNT_EMERG_CHECK_HIERARCHY))==true);
            }
        }

        system.debug('basto1p - isLiveAgentButtonAllowed AFTER PROCESS EXCEOPTIONS to role allowedSubTopic='+allowedSubTopic);

	    resVal =   allowedSubTopic
			&& isAllowedCode(ButtonItemConfig.Name);

	    system.debug('basto1p - isLiveAgentButtonAllowed ButtonName='+ButtonItemConfig.Name+'resVal='+resVal);

	    return resVal;
    }

/*******************************************************************************************************
* @description Resets live agent settings and configuration variables
*
* @example
* this.resetLiveAgentVars();
*
* @history
* -----------------------------------------------------------------------------------------------
* Date         Created by                        Description
* 2017-09-13   paulo.bastos@rightitservices.com  Creation
********************************************************************************************************/
    private void resetLiveAgentVars(){
        //basto1p - live agent v2
        this.csButtonsList=new Map <String,buttonsInfoType>();
        this.livAgentCsButtonNameVsCategoryMap=new Map <String, String>();
    }


    private List<IATA_ISO_Country__c> countries{
        get{
            if (countries == null){
                countries = [SELECT Id, Name, ISO_Code__c, Region__c
                            FROM IATA_ISO_Country__c
                            WHERE Case_BSP_Country__c != null AND Case_BSP_Country__c != ''
                            LIMIT 10000 ];
            }
            return countries;
        }
        set;
    }

    private void resetCase() {
        //basto1p - live agent v2
        this.isToShowFAQs=false;

        this.newCase = new Case();
        this.newCase1 = new Case();
        
        isIFG = false;
        areaOfConcern = Env.SelectOptionDefaultValue ;
        this.lst_selectareasOfConcern = new list<SelectOption>();
        this.lst_selectareasOfConcern.add(new SelectOption(Env.SelectOptionEmptyValue, Env.SelectOptionEmptyValue));

        this.resetLiveAgentVars();
    }

    private void addDecsription() {


        String addDecsription ;
        if (isCompliment1 == false)
        {
             Integer index = Integer.valueOf(topic.trim());
             clsDataCategory selectDataCategory = this.DataCategoryContainer.lst_DataCategories[index];
             
             String areaOfConcernStr='';
             if (isIFG && areaOfConcern!='' && areaOfConcern!=null && !areaOfConcern.contains('-- None --')){
                areaOfConcernStr='\n'+Label.ISSP_Area_of_Concern+' - '+areaOfConcern+'\n';
             }
            
             addDecsription = Label.ISSP_F2CTopic + ' - '
                              + selectDataCategory.CategoryLabel + '\n'
                              + labelSubTopic + ' - '
                              + selectDataCategory.getLabelByNameCategory(subtopic)
                              + areaOfConcernStr;
        }else {
             addDecsription = Label.ISSP_F2CTopic + ' - '
                              + 'COMPLIMENT' + '\n'
                              + labelSubTopic + ' - '
                              + 'COMPLIMENT';
        }

        newCase.Description += '\n\n' + addDecsription;

        if(isComplain1 != null && iscomplain1 != false)
        {
            newCase.Description = '\n\n' + newCase.Description+'\n' +'-COMPLAINT-';
        }
        // compliment ED
        if(isCompliment1 != null && isCompliment1 != false)
        {
            newCase.Description = '\n\n' + newCase.Description+'\n' +'-COMPLIMENT-';
        }
        // end compliment
    }


    /*******************************************************************************************************
    * @description Checks if given chat button (butName) is allowed to be displayed in user interface
    *              by evaluating the following context:
    *                 1) current user account sector (this.sector)
    *                 2) current case selected country related region (this.region)
    *                 3) current case selected country (newCase1.IFAP_Country_ISO__c)
    *
    * @param {string} butName - Name of chat button to check if it is allowed
    *
    * @return {Boolean} resVal - true if allowed false if not
    *
    * @example
    * this.isAllowedCode('AirlineEnglishptEurope');
    *
    * @history
    * -----------------------------------------------------------------------------------------------
    * Date         Created by                        Description
    * ????-??-??   ???????                           Creation
    * 2017-09-07   paulo.bastos@rightitservices.com  Update for live agent v2
    ********************************************************************************************************/
    public Boolean isAllowedCode(String butName) {
        Boolean result=false;

        System.debug('basto1p - BEGIN isAllowedCode butName='+butName+'; this.sector='+this.sector+'; this.region='+this.region);

        //This query controlls when a specific chat button is shown
        /*
          Configuration is made related with allowing access of given chatt buttons
          For a given button name:
            1) if is configured Iso_Code__c, button is allowed for that country code
            2) if is configured only Region__c, button is allowed for all countries from that region
            3) if is configured only Sector__c, button is allowed for all users from that sector
               (independently of Region__c or Iso_Code__c)
            4) if is configured combination of Region__c and Sector__c, button is allowed for
               all countries from that region but only for users from that sector
        */
        List<LiveAgent_Countries_Per_Button__c> aCountries =
            [SELECT Iso_Code__c
            FROM LiveAgent_Countries_Per_Button__c
            WHERE
            (   Button_Name__c = :butName
             AND Iso_Code__c =:newCase.IFAP_Country_ISO__c
            )
            OR
            (    Button_Name__c = :butName
             AND Sector__c=:this.sector
             AND Region__c=:this.region)
            OR
            (    Button_Name__c = :butName
             AND Sector__c=:this.sector
             AND Region__c = ''
//             AND Iso_Code__c = ''
             )
            OR
            (    Button_Name__c = :butName
             AND Region__c=:this.region
             AND Sector__c = '')
            ];

        System.debug('basto1p - isAllowedCode QUERY RESULT:'+aCountries);

        if (aCountries.size()>0){
            result=true;
        }

        System.debug('basto1p - END isAllowedCode btnName='+butName
                +'; newCase.IFAP_Country_ISO__c='+newCase.IFAP_Country_ISO__c
                +'; result='+result);

        return result;
    }


    /*
        Actions
    */
    public Boolean isArticalSelected {get{ if(null == isArticalSelected) isArticalSelected = false; return isArticalSelected;} set;}

    public PageReference getSelectArtical() {
        string artid = ApexPages.currentPage().getParameters().get('artid');
        for(ArticleViewLine art : articleViewLines){
            if(art.theArticle.Id == artid) {
                //selectedArtical = art.theArticle;
                SelectedArticleModalView.SelectedArticle = art.theArticle;
                isArticalSelected = true;
                calculateViewAndSatisfied(SelectedArticleModalView.SelectedArticle);
                createArticleStatisticsRecords(SelectedArticleModalView.SelectedArticle, ENV.ArticleStatType.View);

                break;
            }
        }
        system.debug('selectedArtical >> '  + SelectedArticleModalView.SelectedArticle);
        return null;
    }

    /**
     *  1) Calculate the number of Viewed Articles
     *  2) Calculate the number of customer that found this article usful
     */
    public void calculateViewAndSatisfied(FAQ__kav theArticle) {
        System.debug('KTC - calculateViewAndSatisfied:');
        // Creating an AggregateResult of all records in Article Statistics object,
        // The records are grouped by their URL-Name and Stat-Type(view/satisfied/unsatisfied)
        AggregateResult[] articleStatRecords = [SELECT URL_Name__c, Stat_Type__c, Count(Id) Counting
                                        FROM ArticleStatistics__c
                                        WHERE URL_Name__c =: theArticle.UrlName
                                            GROUP BY URL_Name__c, Stat_Type__c];
        Integer artStatSize = Integer.valueOf(articleStatRecords.size());

        // Iterating over all 'articleStatRecords'
        for (Integer i = 0; i < artStatSize; i++) {
            String statType = String.valueOf(articleStatRecords[i].get('Stat_Type__c'));

            // If the satistic type of the group id 'View' --> will get the number of records in that group
            if (statType == ENV.ArticleStatType.View) {
                SelectedArticleModalView.ViewCount = Integer.valueOf(articleStatRecords[i].get('Counting'));
                System.debug('kerensen SelectedArticleModalView.ViewCount: ' + SelectedArticleModalView.ViewCount);
            }

            // The satistic type of the group id 'Satisfied'
            if (statType == ENV.ArticleStatType.Satisfied) {
                SelectedArticleModalView.SatisfiedCount = Integer.valueOf(articleStatRecords[i].get('Counting'));
                System.debug('kerensen SelectedArticleModalView.SatisfiedCount: ' + SelectedArticleModalView.SatisfiedCount);
            }
        }
        System.debug('KTC - SelectedArticleModalView: ' + SelectedArticleModalView);
    }

    // Cheching if the Article statistic is already exist or not
    public boolean isArticleStatisticExist (FAQ__kav theArticle, String statisticType) {
        List<ArticleStatistics__c> articleStaticsRecords = [SELECT CreatedById, URL_Name__c, Stat_Type__c, Timestamp__c, Topic__c, Sub_Topic__c
                                                    FROM ArticleStatistics__c
                                                    WHERE URL_Name__c =: theArticle.UrlName
                                                        AND Topic__c =: this.topic
                                                        AND Sub_Topic__c =: this.subtopic
                                                        AND CreatedById =: UserInfo.getUserId()
                                                        AND Stat_Type__c =: statisticType
                                                        AND DAY_ONLY(Timestamp__c) =: Date.Today()];

        System.debug('kerensen articleStaticsRecords: ' + articleStaticsRecords);
        System.debug('kerensen articleStaticsRecords.size(): ' + articleStaticsRecords.size());
        return articleStaticsRecords.size() > 0;

    }

    /**
     * Create an Article Atatistic record
     */
    public void createArticleStatisticsRecords(FAQ__kav theArticle, String statisticType) {
        if (theArticle == null || statisticType == null || statisticType == '') return;

        ArticleStatistics__c articleStatistic = new ArticleStatistics__c();

        // If this articleStatistic doesn't exist ---> Create
        if (!isArticleStatisticExist(theArticle, statisticType)) {
            try
            {
                Integer index = Integer.valueOf(this.topic.trim());
                clsDataCategory selectDataCategory = this.DataCategoryContainer.lst_DataCategories[index];

                // Set the record's field values
                articleStatistic.Stat_Type__c = statisticType;
                articleStatistic.Timestamp__c = DateTime.now();
                articleStatistic.URL_Name__c = theArticle.UrlName;
                articleStatistic.Topic__c = selectDataCategory.CategoryLabel;
                articleStatistic.Sub_Topic__c = selectDataCategory.getLabelByNameCategory(this.subtopic);

                //New added by request of sofyen
                articleStatistic.Article_Number__c  = theArticle.ArticleNumber;
                articleStatistic.Topic_English__c  = selectDataCategory.CategoryName;
                articleStatistic.Sub_Topic_English__c  = this.subtopic;

                insert articleStatistic;
                System.debug('kerensen Insert stat successful!: ' + articleStatistic.id);
            } catch (Exception e) {
              ApexPages.addMessages(e);
              System.debug('kerensen An error occurred: ' + e.getMessage());
            }
        }
    }

    public Pagereference create()
    {
        //Method that Provides the URL of Create Case button  ,
        //According to ISSP_CreateButtonURL__c "Custom setting"
        GenerateCreateCaseButtonURL();
        if (CreateButtonURL != null && CreateButtonURL != '')
        {
            Integer index = Integer.valueOf(topic.trim());
            clsDataCategory selectDataCategory = this.DataCategoryContainer.lst_DataCategories[index];
            String extraURL = '&topic='+selectDataCategory.CategoryLabel+'&subtopic='+selectDataCategory.getLabelByNameCategory(subtopic);
            return new Pagereference(CreateButtonURL+extraURL);
        }
        else
        {
            this.currentButtonsToShow = CancelAndSubmit;
            createArticleStatisticsRecords(SelectedArticleModalView.SelectedArticle, ENV.ArticleStatType.UnSatisfied);
            return null;
        }
    }

    public PageReference create1()
    {
        //resetCase();
        this.currentButtonsToShow = CancelAndSubmit;
        SHowButtons = true ;
        //createArticleStatisticsRecords(SelectedArticleModalView.SelectedArticle, ENV.ArticleStatType.UnSatisfied);
        return null;
    }

    // Create an Article Statistics record which is Stat type is Satisfied
    // We call this function when 'Thanks!' button is clicked
    public PageReference createSatisfiedRecord()
    {
        createArticleStatisticsRecords(SelectedArticleModalView.SelectedArticle, ENV.ArticleStatType.Satisfied);
        return new Pagereference('/ISSP_Homepage?mid=M0S1'+commParam);
    }

    public PageReference back()
    {
        string retURL = ApexPages.currentPage().getParameters().get('retURL');
        return new Pagereference(String.isNotBlank(retURL) ? retURL : '/ISSP_Homepage?mid=M0S1'+commParam);
    }
    //basto1p - live agent v2 cancel submit form
    public PageReference cancel()
    {
        string retURL = ApexPages.currentPage().getParameters().get('retURL');
        return new Pagereference(String.isNotBlank(retURL) ? retURL : '/ISSP_FAQ2Case?mid=M0S1'+commParam);
    }

    public PageReference save()
    {
        if (areaOfConcern!=null) {
            areaOfConcern = areaOfConcern.trim();
            if (areaOfConcern.contains('-- None --') || areaOfConcern.contains('-- Select --')) {
                areaOfConcern = '';
            }
            system.debug('basto1p - areaOfConcern=' + areaOfConcern.contains('-- None --') + ', isIFG=' + isIFG);
            system.debug('basto1p - newCase.areaOfConcern=' + newCase.Area_of_Concern__c);
        }
        else
        {
            areaOfConcern = '';
        }
    this.errorMessage = new list<String>();
        System.debug('basto1p - FAQ2Case.save isIFG='+isIFG);
        if( ((subtopic == null ||subtopic == '' ||subtopic == '-- Select --' || subTopic == topic))||//added &&iscompliment to bypass error message
            ((areaOfConcern == null || areaOfConcern == '') && isIFG==true && this.lst_selectareasOfConcern.size()>1) ||
            (newCase.IFAP_Country_ISO__c == null ||newCase.IFAP_Country_ISO__c == '')||
            (newCase.Subject == null ||newCase.Subject == '')||
            (newCase.Description == null ||newCase.Description == '')){

            string ErrFields = '';
            if((subtopic == null ||subtopic == ''||subtopic == '-- Select --'|| subTopic == topic)&&isCompliment1!= true){
               ErrFields += System.Label.ISSP_I_wish_to_complain_about +'xx, '+isCompliment1;
            }
            if((areaOfConcern == null || areaOfConcern == '') && isIFG==true && this.lst_selectareasOfConcern.size()>1){
               ErrFields += System.Label.ISSP_Area_of_Concern;
            }
            if((newCase.IFAP_Country_ISO__c == null ||newCase.IFAP_Country_ISO__c == '')){
               ErrFields += System.Label.Country_concerned_by_the_query +', ';
            }
            if(newCase.Subject == null ||newCase.Subject == ''){
                ErrFields += System.Label.ISSP_Subject + ', ';
            }
            if(newCase.Description == null ||newCase.Description == ''){
                ErrFields += System.Label.IDCard_Description+', ';
            }
            if(ErrFields != ''){
                system.debug('basto1p - ErrFields NOT EMPTY!!!');
                errorMessage = new list<string>();
                String errorString = ErrFields+' '+system.Label.ISSP_Should_be_mandatory;
                errorMessage.add(errorString);
                 //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,ErrFields+' '+system.Label.ISSP_Should_be_mandatory);
                 //ApexPages.addMessage(myMsg);
                 return null;
            }
        }

        newCase.Area_of_Concern__c=areaOfConcern;
        
        addDecsription();
        setRecordType(); //TF - SP11
        
        // find CC contacts
        list<Contact> listCCContacts = new list<Contact>();
        try {
            listCCContacts = validateCCOthers();
        } catch (CCOthersException e) {
            this.errorMessage.add(e.getMessage());
            return null;
        }
        
        //ASsign new CAse Record Type
        if(AssignNewCaseRecordType() != null){
            newCase.RecordTypeId = AssignNewCaseRecordType();
        }

        //Query for custom setting holding the topics and subtopics considered to be cns.
        Map <Id, ISSP_CNS_Topics_Subtopics__c> cnsTopics = new Map <Id, ISSP_CNS_Topics_Subtopics__c> ([select Id, Topic__c, Subtopics__c, Subtopics2__c from ISSP_CNS_Topics_Subtopics__c]);

        Map <String, ISSP_CNS_Topics_Subtopics__c> cnsTopicMap = new Map <String, ISSP_CNS_Topics_Subtopics__c> ();
        for(ISSP_CNS_Topics_Subtopics__c ct: cnsTopics.values()){
            cnsTopicMap.put(ct.Topic__c, ct);
        }

        if(isCNS || cnsTopicMap.containsKey(newCase.Topic__c.replace(' ', ''))) {
            newCase.CNSCase__c = true;
            newCase.Groups__c = 'CNS Team'; // important field to be used on E2C premium
        }
        newCase.Case_Language__c = null;
        
        //Specific case field values for Emergencies
        if (this.Clicked_EmergencyRequest) {
            newCase.Priority = 'Emergency';
        }

        system.debug('wwe newCase: ' + newCase );
        if (!isGSAOnly && (newCase.IATAcode__c == '' || newCase.IATAcode__c == null) && isGSAUser && isCompliment1!= true){
            errorMessage = new list<string>();
            errorMessage.add(Label.ISSP_Select_Airline);
            return null;
        }
        else if (isGSAOnly && accountId != null){
            newCase.Account_Concerned__c = accountId;
            system.debug('wwe1 newCase: ' + newCase );
            Database.insert(newCase);

            return new Pagereference('/ISSP_Case?caseId='+newCase.Id + commParam);
        }
        else{
            system.debug('wwe newCase2: ' + newCase );
            Database.insert(newCase);
            addCaseTeamContacts(newCase, listCCContacts);
            return new Pagereference('/ISSP_Case?caseId='+newCase.Id + commParam);
        }
    }



    public PageReference saveAttach()
    {system.debug('wwewwe IFAP_Country_ISO__c: ' + newCase.IFAP_Country_ISO__c );
         this.errorMessage = new list<String>();
         if( ((subtopic == null ||subtopic == '' ||subtopic == '-- Select --' || subTopic == topic)||
            (newCase.IFAP_Country_ISO__c == null ||newCase.IFAP_Country_ISO__c == '')||
            (newCase.Subject == null ||newCase.Subject == '')||
            (newCase.Description == null ||newCase.Description == ''))){



            string ErrFields = '';
            if((subtopic == null ||subtopic == ''||subtopic == '-- Select --'|| subTopic == topic )&&isCompliment1!= true){
               ErrFields += System.Label.ISSP_I_wish_to_complain_about +'yy, ';
            }
            if((newCase.IFAP_Country_ISO__c == null ||newCase.IFAP_Country_ISO__c == '')){
               ErrFields += System.Label.Country_concerned_by_the_query +', ';
            }
            if(newCase.Subject == null ||newCase.Subject == ''){
                ErrFields += System.Label.ISSP_Subject + ', ';
            }
            if(newCase.Description == null ||newCase.Description == ''){
                ErrFields += System.Label.IDCard_Description+', ';
            }
            if(ErrFields != ''){
                errorMessage = new list<string>();
                String errorString = ErrFields+' '+system.Label.ISSP_Should_be_mandatory;
                errorMessage.add(errorString);
                 //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,ErrFields+' '+system.Label.ISSP_Should_be_mandatory);
                 //ApexPages.addMessage(myMsg);
                 return null;
            }

        }

        addDecsription();
        setRecordType(); //TF - SP11

        //Query for custom setting holding the topics and subtopics considered to be cns.
        Map <Id, ISSP_CNS_Topics_Subtopics__c> cnsTopics = new Map <Id, ISSP_CNS_Topics_Subtopics__c> ([select Id, Topic__c, Subtopics__c, Subtopics2__c from ISSP_CNS_Topics_Subtopics__c]);

        Map <String, ISSP_CNS_Topics_Subtopics__c> cnsTopicMap = new Map <String, ISSP_CNS_Topics_Subtopics__c> ();
        for(ISSP_CNS_Topics_Subtopics__c ct: cnsTopics.values()){
            cnsTopicMap.put(ct.Topic__c, ct);
        }

        // find CC contacts
        list<Contact> listCCContacts = new list<Contact>();
        try {
            listCCContacts = validateCCOthers();
        } catch (CCOthersException e) {
            this.errorMessage.add(e.getMessage());
            return null;
        }

        if(isCNS || cnsTopicMap.containsKey(newCase.Topic__c.replace(' ', ''))) {
            newCase.CNSCase__c = true;
            newCase.Groups__c = 'CNS Team'; // important field to be used on E2C premium
        }

        //Specific case field values for Emergencies
        if (this.Clicked_EmergencyRequest) {
            newCase.Priority = 'Emergency';
        }

        //ASsign new CAse Record Type
        if(AssignNewCaseRecordType() != null){
            newCase.RecordTypeId = AssignNewCaseRecordType();
        }
        newCase.Case_Language__c = null;

        if (!isGSAOnly && (newCase.IATAcode__c == '' || newCase.IATAcode__c == null) && isGSAUser && isCompliment1!= true){
            errorMessage = new list<string>();
            errorMessage.add(Label.ISSP_Select_Airline);
            //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,System.Label.ISSP_Select_Airline);
            //ApexPages.addMessage(myMsg);
            return null;
        }
        else if (isGSAOnly && accountId != null){
            newCase.Account_Concerned__c = accountId;
            Database.insert(newCase);
            //return new Pagereference('/p/attach/NoteAttach?pid=' + newCase.Id + '&retURL=%2FISSP_Case?caseId='+ newCase.Id);
            return new Pagereference('/apex/ISSP_AddAttachment?caseid=' + newCase.Id + commParam);
        }
        else{
            Database.insert(newCase);
            addCaseTeamContacts(newCase, listCCContacts);
            //return new Pagereference('/p/attach/NoteAttach?pid=' + newCase.Id + '&retURL=%2FISSP_Case?caseId='+ newCase.Id);
            return new Pagereference('/apex/ISSP_AddAttachment?caseid=' + newCase.Id + commParam);
        }
    }

    /**
        Check cc input box, all emails inside must be in a valid contact
        Otherwise throw an error
    **/
    public class CCOthersException extends Exception {}
    private list<Contact> validateCCOthers() {
        // get ccother value entered by user
        String additionalCCField = '';
        for (sectionRecordWrapper section : this.fullList) {
            for (fieldRecordWrapper thisField : section.fieldList) {
                if (thisField.fieldType == 'ccothers' && thisField.fieldValueEntered!=null) {
                    additionalCCField = thisField.fieldValueEntered;
                }
            }
        }
        // separate input string in a list of emails
        list<String> listEmail = new list<String>();
        for (String ccemail: additionalCCField.replace(';',',').split(',')) {
            ccemail = ccemail.trim();
            if (ccemail!='') {
                listEmail.add(ccemail);
            }
        }
        list<Contact> listContact = [SELECT Id, Email FROM Contact WHERE email IN :listEmail];
        
        // Check that all emails were found
        list<String> listWrongEmails = new list<String>();
        for (String email: listEmail) {
            if (!isEmailInContactList(email, listContact)) {
                listWrongEmails.add(email);
            }
        }
        if (!listWrongEmails.isEmpty()) {
            throw new CCOthersException(Label.ISSP_CCOther_Wrong_Emails.replace('{0}',String.valueOf(listWrongEmails)));
        }
        return listContact;
    }

    /**
        Check if input email is one of the input contacts
    **/
    private Boolean isEmailInContactList(String email, list<Contact> listContact) {
        for (Contact contact: listContact) {
            if (email == contact.Email) {
                return true;
            }
        }
        return false;
    }

    /**
        Add Team Roles to input case, one per each contact
    **/
    private void addCaseTeamContacts(Case cse, list<Contact> listContact) {
        if (listContact.isEmpty()) return;
        list<CaseTeamMember > listCaseTeam = new list<CaseTeamMember>();
        list<String> listEmail = new list<String>();
        for (Contact contact: listContact) {
            listCaseTeam.add(new CaseTeamMember(
                ParentId = cse.Id,
                MemberId = contact.Id,
                TeamRoleId = PARTNER_USER_ROLE
            ));
            listEmail.add(contact.Email);
        }
        insert listCaseTeam;
        // update case.E2CP__AdditionalCC__c field with helper class to ignore permissions
        String stringEmails = String.join(listEmail,',');
        new E2CPFieldAccess(cse.Id).setAdditionalCC(stringEmails);
    }

    public   PageReference IwishtoComplain()
    {system.debug('JK22 isComplain IwishtoComplain START: ' + isComplain);
        resetCase();
        Clicked_SISHelpDesk = false;
        Clicked_IATAServiceRequest = false;
        Clicked_PWCServiceRequest = false;
        Clicked_DPCServiceRequest = false;
        Clicked_EmergencyRequest = false;
        GenerateFieldsBySettings();
        isComplain = true ;
        this.currentButtonsToShow = OnlyCancel;
        topic = Env.SelectOptionDefaultValue ;
        subtopic = Env.SelectOptionDefaultValue ;
        //this.currentButtonsToShow = CancelAndSubmit;
        //createArticleStatisticsRecords(SelectedArticleModalView.SelectedArticle, ENV.ArticleStatType.UnSatisfied);
        system.debug('JK22 isComplain IwishtoComplain END: ' + isComplain);
        labelSubTopic = Label.ISSP_I_wish_to_complain_about;
        isComplain1 = true ;
        isCompliment1 = false ;
        errorMessage = new list<string>();
        return null;
    }

    public PageReference createAnEmergency(){
        System.debug('createAnEmergency START: ' + this.Clicked_EmergencyRequest);
        resetCase();
        Clicked_SISHelpDesk = false;
        Clicked_IATAServiceRequest = false;
        Clicked_PWCServiceRequest = false;
        Clicked_DPCServiceRequest = false;
        Clicked_EmergencyRequest = true;
        GenerateFieldsBySettings();
        this.currentButtonsToShow = OnlyCancel;
        topic = Env.SelectOptionDefaultValue ;
        subtopic = Env.SelectOptionDefaultValue ;
        System.debug('createAnEmergency END: ' + this.Clicked_EmergencyRequest);
        labelSubTopic = 'I wish to create an emergency about';
        errorMessage = new list<string>();
        return null;
    }

    public PageReference GeneralQueueMethod(){
        resetCase();
        Clicked_SISHelpDesk = false;
        Clicked_IATAServiceRequest = false;
        Clicked_PWCServiceRequest = false;
        Clicked_DPCServiceRequest = false;
        Clicked_EmergencyRequest = false;
        GenerateFieldsBySettings();
        isComplain = false ;
        isCompliment = false;
        isComplain1 = false ;
        isCompliment1 = false ;
        this.currentButtonsToShow = OnlyCancel;
        topic = Env.SelectOptionDefaultValue ;
        subtopic = Env.SelectOptionDefaultValue ;
        labelSubTopic = Label.ISSP_F2CSubTopic;
        errorMessage = new list<string>();
        return null;
    }
// Compliment additions ED sept 2015
     public PageReference ComplimentGeneralQueueMethod(){
        resetCase();
        Clicked_SISHelpDesk = false;
        Clicked_IATAServiceRequest = false;
        Clicked_PWCServiceRequest = false;
        Clicked_DPCServiceRequest = false;
        Clicked_EmergencyRequest = false;
        GenerateFieldsBySettings();
        isCompliment = true;
        isComplain = false ;
        isComplain1 = false ;
        isCompliment1 = true ;
        this.currentButtonsToShow = CancelAndCreateACase;
        topic = '0' ;
        refreshSubTopicPickList();
        subtopic = Env.SelectOptionDefaultValue ;
        errorMessage = new list<string>();
        create();

        if(isCNS ) {
            List<IATA_ISO_Country__c> lsIsoCountries = [SELECT Id, ISO_Code__c, Name FROM IATA_ISO_Country__c WHERE Name = 'United States' LIMIT 1];
            if(!lsIsoCountries.isEmpty()) {
                this.newCase.IFAP_Country_ISO__c = lsIsoCountries[0].ISO_Code__c ;
                this.newCase1.IFAP_Country_ISO__c = lsIsoCountries[0].ISO_Code__c ;
            }
        }
        
        return null;
    }

    public void refreshTopicPickList()
    {
        System.debug('basto1p - refreshTopicPickList myTopic='+myTopic);
        system.debug('JK22 isComplain refreshTopicPickList START: ' + isComplain);
        resetCase();
        if (this.currentButtonsToShow!=CancelAndSubmit) {
            this.currentButtonsToShow = OnlyCancel;
        }
        system.debug('Kerensen refreshTopicPickList: After  resetCase(); '+topic+'     Env.SelectOptionDefaultValue===>'+Env.SelectOptionDefaultValue  );
        if (topic.compareTo(Env.SelectOptionDefaultValue) == 0)
        {system.debug('Kerensen refreshTopicPickList: IN If '  );

            this.lst_selectsubTopics = new list<SelectOption>();
            this.lst_selectsubTopics.add(new SelectOption(Env.SelectOptionDefaultValue, Env.SelectOptionDefaultValue));
            articleViewLines = new list<ArticleViewLine>();
            isTopicDefault = true; //INC263231
        }
        else
        {system.debug('Kerensen refreshTopicPickList: After  resetCase(); ELSE'  );
            this.lst_selectsubTopics = new list<SelectOption>();
            system.debug('TOPIC: ' + topic);
            Integer index = Integer.valueOf(topic.trim());
            system.debug('INTEGER: ' + index);
            isToShowFAQs = true;

            clsDataCategory selectDataCategory = this.DataCategoryContainer.lst_DataCategories[index];

            if (selectDataCategory.lst_childs.size() > 0)
            {
                this.lst_selectsubTopics.add(new SelectOption(Env.SelectOptionDefaultValue, Env.SelectOptionDefaultValue));
                
                // ONLY FOR EMERGENCIES list of available categories
                set<String> setEmergencyCategories = new set<String>();
                if(this.Clicked_EmergencyRequest==null) this.Clicked_EmergencyRequest=false;
                if (this.Clicked_EmergencyRequest) {
                    ISSP_FAQ2Case_Emergencies__c emergencyCategories = ISSP_FAQ2Case_Emergencies__c.getInstance(selectDataCategory.CategoryName);
                    if (emergencyCategories!=null && emergencyCategories.Subtopic__c!=null) {
                        setEmergencyCategories.addAll(emergencyCategories.Subtopic__c.split(','));
                    }
                }
                
                for(Integer cIndex = 0; cIndex < selectDataCategory.lst_childs.size(); cIndex++)
                {
                    clsDataCategory.CategoryChildWrapper childCat = selectDataCategory.lst_childs[cIndex];
                    if (this.Clicked_EmergencyRequest) {
                        if (setEmergencyCategories.contains(childCat.CategoryName)) {
                            this.lst_selectsubTopics.add(new SelectOption(childCat.CategoryName, childCat.CategoryLabel));
                        }
                    } else {
                        this.lst_selectsubTopics.add(new SelectOption(childCat.CategoryName, childCat.CategoryLabel));
                    }
                }

                subtopic = selectDataCategory.CategoryName;
                articleViewLines = buildArticleViewLines(selectDataCategory.topCategoryName, subtopic, Userinfo.getLanguage());
            }
            else
            {
                this.lst_selectsubTopics.add(new SelectOption(Env.SelectOptionEmptyValue, Env.SelectOptionEmptyValue));
                subtopic = selectDataCategory.CategoryName;
                articleViewLines = buildArticleViewLines(selectDataCategory.topCategoryName, subtopic, Userinfo.getLanguage());
            }
        }
        system.debug('SFI2 CALL setSubTopicByPermissions ' + topic + ' isTopicDefault ' + isTopicDefault);
        if(isTopicDefault != true) //INC263231
            setSubTopicByPermissions();
        
        system.debug('JK22 isComplain refreshTopicPickList END: ' + isComplain);
    }

   public void refreshSubTopicPickList(){

        resetCase();
       System.debug('basto1p - refreshSubTopicPickList myTopic='+myTopic);
        system.debug('TOPIC: ' + topic);
        Integer index = Integer.valueOf(topic.trim());
        system.debug('INTEGER: ' + index);
        clsDataCategory selectDataCategory = this.DataCategoryContainer.lst_DataCategories[index];
        system.debug('JK subtopic: ' + subtopic);

        // if strings are equals (subtopic empty)
        if (subtopic.compareTo(Env.SelectOptionDefaultValue) == 0)
        {
            subtopic = selectDataCategory.CategoryName;
            if (this.currentButtonsToShow!=CancelAndCreateACase) {
                this.currentButtonsToShow = CancelAndSubmit;
            }
            system.debug('JK1 this.currentButtonsToShow: ' + this.currentButtonsToShow);
        }
        else
        {
            if(isComplain != true){
                if (this.currentButtonsToShow!=CancelAndSubmit){
                    this.currentButtonsToShow = CancelAndCreateACase;
                }

                system.debug('JK2 this.currentButtonsToShow: ' + this.currentButtonsToShow);
            }else{
                this.currentButtonsToShow = CancelAndSubmit;
                system.debug('JK3 this.currentButtonsToShow: ' + this.currentButtonsToShow);
            }
        }

        articleViewLines = buildArticleViewLines(selectDataCategory.topCategoryName, subtopic, Userinfo.getLanguage());
        system.debug('JK this.currentButtonsToShow: ' + this.currentButtonsToShow);

        if(selectDataCategory.CategoryName.startsWith('CNS')) {
            List<IATA_ISO_Country__c> lsIsoCountries = [SELECT Id, ISO_Code__c, Name FROM IATA_ISO_Country__c WHERE Name = 'United States' LIMIT 1];
            if(!lsIsoCountries.isEmpty()) {
                this.newCase.IFAP_Country_ISO__c = lsIsoCountries[0].ISO_Code__c ;
                this.newCase1.IFAP_Country_ISO__c = lsIsoCountries[0].ISO_Code__c ;
                
                //this.setLiveAgentButtonsNames(); /* Change to this if live agent becomes available for CNS */
                this.getAndSetCallUsString();
            }
        }

       system.debug('basto1p before setIsIFG CategoryName='+selectDataCategory.CategoryName);
        //Set Areas of Concern Pick List
       setIsIFG(selectDataCategory.CategoryName);

       //basto1p Live Agent v2 (set topic label name)
       this.topicLabel=selectDataCategory.CategoryName;

       if (isIFG){
           List<IFG_AreasOfConcernMapp__mdt> SubTopicAreasOfConcernMappList;
           SubTopicAreasOfConcernMappList=[SELECT SubTopic__c, MasterLabel FROM IFG_AreasOfConcernMapp__mdt ORDER BY SubTopic__c ASC, MasterLabel ASC];
           
           this.lst_selectareasOfConcern = new list<SelectOption>();
           this.lst_selectareasOfConcern.add(new SelectOption(Env.SelectOptionEmptyValue, Env.SelectOptionEmptyValue));
           
           for (IFG_AreasOfConcernMapp__mdt AreasOfConcernItem : SubTopicAreasOfConcernMappList){
               system.debug('subtopic='+subtopic+'; AreasOfConcernItem.SubTopic='+AreasOfConcernItem.SubTopic__c);
               if (subtopic.Contains(AreasOfConcernItem.SubTopic__c)){
                   system.debug('ADDED subtopic='+subtopic+'; AreasOfConcernItem.SubTopic='+AreasOfConcernItem.MasterLabel);
                   this.lst_selectareasOfConcern.add(new SelectOption(AreasOfConcernItem.MasterLabel, AreasOfConcernItem.MasterLabel));
               }
           }
           /*
           this.lst_selectareasOfConcern.add(new SelectOption('SLB', 'Benfica'));
           this.lst_selectareasOfConcern.add(new SelectOption('SLB2', 'Benfica2'));
           */
       }
       else
       {
           this.lst_selectareasOfConcern = new list<SelectOption>();
           this.lst_selectareasOfConcern.add(new SelectOption(Env.SelectOptionEmptyValue, Env.SelectOptionEmptyValue));
       }
    }
    
    public void refreshAreasOfConcernPickList(){
        system.debug('basto1p - TOPIC: ' + topic);
        system.debug('basto1p - SUB-TOPIC: ' + subtopic);
        
    }
    public void setIsIFG(String categoryName){
        system.debug('basto1p - setIsIFG categoryName='+categoryName);
        if (categoryName==IFG_TOPIC) {
            isIFG=true;
        }
        else {
            isIFG=false;
        }
        system.debug('basto1p - isIFG='+isIFG);
    }
    
    /*
     * End Actions
    */

    /*
    public list<SelectOption> countryList
    {
        get {
            if (null == countryList) {
                countryList = new list<SelectOption>{ new SelectOption('', Env.SelectOptionEmptyValue)};
                for(IATA_ISO_Country__c iso : getIsoCountryList()) {
                    countryList.add(new SelectOption(iso.Name,iso.Name));
                }
            }
            return countryList;
        }
        set;
    }
    */

    public List<SelectOption> countryList {

        get {
        system.debug('LANGUAGE: ' + UserInfo.getLanguage());
        String currentLanguage = UserInfo.getLanguage();
        List<SelectOption> options = new List<SelectOption>();
        list<IATA_ISO_Country__c> isoList;
        /*list<IATA_ISO_Country__c> isoList = [select Name,Id, IATA_Contry_KR__c, IATA_COUNTRY_EN__c,
                                            IATA_Country_FR__c, IATA_Country_IT__c, IATA_Country_JP__c,
                                            IATA_Country_PT__c, IATA_Country_SP__c, IATA_Country_ZH__c
                                            from IATA_ISO_Country__c
                                            where Case_BSP_Country__c!=null
                                            and Case_BSP_Country__c!=''
                                            order by Name];*/
        if (currentLanguage == 'es'){
            isoList = [select Name,Id, IATA_Contry_KR__c, IATA_COUNTRY_EN__c,ISO_Code__c,
                        IATA_Country_FR__c, IATA_Country_IT__c, IATA_Country_JP__c,
                        IATA_Country_PT__c, IATA_Country_SP__c, IATA_Country_ZH__c
                        from IATA_ISO_Country__c
                        where Case_BSP_Country__c!=null
                        and Case_BSP_Country__c!=''
                        order by IATA_Country_SP__c];
        }
        else if (currentLanguage == 'ko'){
            isoList = [select Name,Id, IATA_Contry_KR__c, IATA_COUNTRY_EN__c,ISO_Code__c,
                        IATA_Country_FR__c, IATA_Country_IT__c, IATA_Country_JP__c,
                        IATA_Country_PT__c, IATA_Country_SP__c, IATA_Country_ZH__c
                        from IATA_ISO_Country__c
                        where Case_BSP_Country__c!=null
                        and Case_BSP_Country__c!=''
                        order by IATA_Contry_KR__c];
        }
        else if (currentLanguage == 'zh_CN'){
            isoList = [select Name,Id, IATA_Contry_KR__c, IATA_COUNTRY_EN__c,ISO_Code__c,
                        IATA_Country_FR__c, IATA_Country_IT__c, IATA_Country_JP__c,
                        IATA_Country_PT__c, IATA_Country_SP__c, IATA_Country_ZH__c
                        from IATA_ISO_Country__c
                        where Case_BSP_Country__c!=null
                        and Case_BSP_Country__c!=''
                        order by IATA_Country_ZH__c];
        }
        else if (currentLanguage == 'pt_BR'){
            isoList = [select Name,Id, IATA_Contry_KR__c, IATA_COUNTRY_EN__c,ISO_Code__c,
                        IATA_Country_FR__c, IATA_Country_IT__c, IATA_Country_JP__c,
                        IATA_Country_PT__c, IATA_Country_SP__c, IATA_Country_ZH__c
                        from IATA_ISO_Country__c
                        where Case_BSP_Country__c!=null
                        and Case_BSP_Country__c!=''
                        order by IATA_Country_PT__c];
        }
        else if (currentLanguage == 'fr'){
            isoList = [select Name,Id, IATA_Contry_KR__c, IATA_COUNTRY_EN__c,ISO_Code__c,
                        IATA_Country_FR__c, IATA_Country_IT__c, IATA_Country_JP__c,
                        IATA_Country_PT__c, IATA_Country_SP__c, IATA_Country_ZH__c
                        from IATA_ISO_Country__c
                        where Case_BSP_Country__c!=null
                        and Case_BSP_Country__c!=''
                        order by IATA_Country_FR__c];
        }
        else if (currentLanguage == 'ja'){
            isoList = [select Name,Id, IATA_Contry_KR__c, IATA_COUNTRY_EN__c,ISO_Code__c,
                        IATA_Country_FR__c, IATA_Country_IT__c, IATA_Country_JP__c,
                        IATA_Country_PT__c, IATA_Country_SP__c, IATA_Country_ZH__c
                        from IATA_ISO_Country__c
                        where Case_BSP_Country__c!=null
                        and Case_BSP_Country__c!=''
                        order by IATA_Country_JP__c];
        }
        else if (currentLanguage == 'it'){
            isoList = [select Name,Id, IATA_Contry_KR__c, IATA_COUNTRY_EN__c,ISO_Code__c,
                        IATA_Country_FR__c, IATA_Country_IT__c, IATA_Country_JP__c,
                        IATA_Country_PT__c, IATA_Country_SP__c, IATA_Country_ZH__c
                        from IATA_ISO_Country__c
                        where Case_BSP_Country__c!=null
                        and Case_BSP_Country__c!=''
                        order by IATA_Country_IT__c];
        }
        else{
            isoList = [select Name,Id, IATA_Contry_KR__c, IATA_COUNTRY_EN__c,ISO_Code__c,
                        IATA_Country_FR__c, IATA_Country_IT__c, IATA_Country_JP__c,
                        IATA_Country_PT__c, IATA_Country_SP__c, IATA_Country_ZH__c
                        from IATA_ISO_Country__c
                        where Case_BSP_Country__c!=null
                        and Case_BSP_Country__c!=''
                        order by Name];
        }
        options.add(new SelectOption('', '--None--'));
        for(IATA_ISO_Country__c iso : isoList){
            if (currentLanguage == 'es'){
                if (iso.IATA_Country_SP__c != null)
                    options.add(new SelectOption(iso.ISO_Code__c ,iso.IATA_Country_SP__c));
                else
                    options.add(new SelectOption(iso.ISO_Code__c ,iso.Name));
            }
            else if (currentLanguage == 'ko'){
                if (iso.IATA_Contry_KR__c != null)
                    options.add(new SelectOption(iso.ISO_Code__c,iso.IATA_Contry_KR__c));
                else
                    options.add(new SelectOption(iso.ISO_Code__c,iso.Name));
            }
            else if (currentLanguage == 'zh_CN'){
                if (iso.IATA_Country_ZH__c != null)
                    options.add(new SelectOption(iso.ISO_Code__c,iso.IATA_Country_ZH__c));
                else
                    options.add(new SelectOption(iso.ISO_Code__c,iso.Name));
            }
            else if (currentLanguage == 'pt_BR'){
                if (iso.IATA_Country_PT__c != null)
                    options.add(new SelectOption(iso.ISO_Code__c,iso.IATA_Country_PT__c));
                else
                    options.add(new SelectOption(iso.ISO_Code__c,iso.Name));
            }
            else if (currentLanguage == 'fr'){
                if (iso.IATA_Country_FR__c != null)
                    options.add(new SelectOption(iso.ISO_Code__c,iso.IATA_Country_FR__c));
                else
                    options.add(new SelectOption(iso.ISO_Code__c,iso.Name));
            }
            else if (currentLanguage == 'ja'){
                if (iso.IATA_Country_JP__c != null)
                    options.add(new SelectOption(iso.ISO_Code__c,iso.IATA_Country_JP__c));
                else
                    options.add(new SelectOption(iso.ISO_Code__c,iso.Name));
            }
            else if (currentLanguage == 'it'){
                if (iso.IATA_Country_IT__c != null)
                    options.add(new SelectOption(iso.ISO_Code__c,iso.IATA_Country_IT__c));
                else
                    options.add(new SelectOption(iso.ISO_Code__c,iso.Name));
            }
            else{
                options.add(new SelectOption(iso.ISO_Code__c,iso.Name));
            }
            //options.add(new SelectOption(iso.Name,iso.Name));
        }
        return options;
        }
        set;
    }

    /**
     * Last update by Nurit and Niv 11/16/2014
     *
     * Create a list with all articles for display.
     * Returns a list that contains the Top 5 voted article in my selected language.
     * If the article doesn't exist in my languag then the article will displayed in English language
     */
    public static list<ArticleViewLine> buildArticleViewLines(String headCat, String childCat, String lang)
    {
        //basto1p - LiveAgentv2 - only generates articles view if faqs area available for that country
        list<ArticleViewLine> articleViewLines = new list<ArticleViewLine>();
        if (areFAQsAllowedForCurrentCountry()) {
            String[] childCatList = String.isNotEmpty(childCat) ? new String[] {childCat} : null;
            //List<String> childCatList = String.isNotEmpty(childCat) ? new List<String> {childCat} : null;
            List<FAQ__kav> articalList = getArticalsByCat(headCat, childCatList);
            Map<ID, FAQ__kav> artical2ParentIdMap = new Map<ID, FAQ__kav>();
            Map<Id, FAQ__kav> parentIdToMyLanguageArticle_Map = new Map<Id, FAQ__kav>();
            Set<Id> parentVotIdsSet = new Set<Id>();

            // Iterating over all articles(for specific category) and creating a map between the articles and their parent's Id
            for (FAQ__kav oneArtical : articalList)
            {
                artical2ParentIdMap.put(oneArtical.KnowledgeArticleId, oneArtical);
            }

            // Top 5 articles
            list<FAQ__VoteStat> voteStatList =
                    getArticleVoteStatByIds(artical2ParentIdMap.keySet(), ENV.ArticleChannel.AllChannels);//todo chanel

            // Create a set Id with all top 5 articles
            for (FAQ__VoteStat article : voteStatList)
            {
                parentVotIdsSet.add(article.ParentId);
            }


            // From the Top 5 articles create a list with articles in my language
            /*
            List<FAQ__kav> myLanguageArticle_List = [SELECT Id, UrlName, Summary, Title, Language,
                    Answer__c ,
                    KnowledgeArticleId,
                    PublishStatus, ArticleNumber, LastPublishedDate
                    FROM FAQ__kav
                    WHERE KnowledgeArticleId IN :parentVotIdsSet AND Language =: lang AND PublishStatus = 'Online'];
            */
            List<FAQ__kav> myLanguageArticle_List = Database.query('SELECT Id, UrlName, Summary, Title, Language,'+
                    'Answer__c ,'+
                    'KnowledgeArticleId,'+
                    'PublishStatus, ArticleNumber, LastPublishedDate'+
                    ' FROM FAQ__kav'+
                    ' WHERE KnowledgeArticleId IN :parentVotIdsSet'+
                    ' AND Language =: lang '+
                    ' AND PublishStatus = \'Online\'');

            // Create a map with the parent Id of each article in 'myLanguageArticle_List'
            for (FAQ__kav otherlanguageArticle : myLanguageArticle_List) {
                parentIdToMyLanguageArticle_Map.put(otherlanguageArticle.KnowledgeArticleId, otherlanguageArticle);

            }

            // Iterating over 5 Top voted articles
            for (FAQ__VoteStat oneVoteStat : voteStatList)
            {
                FAQ__kav artical = new FAQ__kav();

                // If we have the article in other language
                if (parentIdToMyLanguageArticle_Map.containsKey(oneVoteStat.ParentId)) {
                    artical = parentIdToMyLanguageArticle_Map.get(oneVoteStat.ParentId);
                } else {
                    // If we dont have the article in our language then get the article in the english language
                    artical = artical2ParentIdMap.get(oneVoteStat.ParentId);
                }
                system.debug('Adding one');
                ArticleViewLine viewLine = new ArticleViewLine(artical, oneVoteStat);
                articleViewLines.add(viewLine);
            }
        }
        return articleViewLines;
    }

    private void initTopicsList()
    {
        this.DataCategoryContainer.lst_DataCategories.sort();
        if (myTopic != null && myTopic != ''){
            for(Integer index = 0; index < this.DataCategoryContainer.lst_DataCategories.size(); index++)
            {
                clsDataCategory cdc = this.DataCategoryContainer.lst_DataCategories[index];
                if (myTopic == cdc.CategoryLabel){
                    topic = String.valueOf(index);
                    this.lst_selectTopics.add(new SelectOption(String.valueOf(index),cdc.CategoryLabel));
                    this.lst_selectTopics.add(new SelectOption(Env.SelectOptionDefaultValue, Env.SelectOptionDefaultValue));
                }
            }
            for(Integer index = 0; index < this.DataCategoryContainer.lst_DataCategories.size(); index++)
            {
                clsDataCategory cdc = this.DataCategoryContainer.lst_DataCategories[index];
                if (myTopic != cdc.CategoryLabel)
                    this.lst_selectTopics.add(new SelectOption(String.valueOf(index),cdc.CategoryLabel));
            }
            refreshTopicPickList();
        }
        else{
            this.lst_selectTopics.add(new SelectOption(Env.SelectOptionDefaultValue, Env.SelectOptionDefaultValue));
            for(Integer index = 0; index < this.DataCategoryContainer.lst_DataCategories.size(); index++)
            {
                clsDataCategory cdc = this.DataCategoryContainer.lst_DataCategories[index];
                this.lst_selectTopics.add(new SelectOption(String.valueOf(index),cdc.CategoryLabel));
            }
        }
        setTopicByPermissions();
        
        //fill list for emergencies
        this.lst_selectTopics_Emergencies = new list<SelectOption>();
        for (SelectOption option: this.lst_selectTopics) {
            Integer index = getIndexValue(option.getValue());
            if (index==-1) {
                this.lst_selectTopics_Emergencies.add(option);
            } else {
                clsDataCategory cdc = this.DataCategoryContainer.lst_DataCategories[index];
                if (ISSP_FAQ2Case_Emergencies__c.getInstance(cdc.CategoryName)!=null) {
                    this.lst_selectTopics_Emergencies.add(option);
                }
            }
        }
    }
    
    private static Integer getIndexValue(String value) {
        try {
            return Integer.ValueOf(value);
        } catch (Exception e) {
            return -1;
        }
    }

    /*
        DAL
    */
    public static list<IATA_ISO_Country__c> getIsoCountryList()
    {
        return [SELECT Id, Name
                FROM IATA_ISO_Country__c
                WHERE Case_BSP_Country__c != null AND Case_BSP_Country__c != ''
                ORDER BY Name
                LIMIT 10000 ];
    }

    /**
        Return a SelectOption List with all IATA codes in the account hierarchy
    **/
    @TestVisible
    private List<List<SelectOption>> initIATACodeList(Id accountId) {
         List<List<SelectOption>> IATACodeList = new  List<List<SelectOption>>();
        try {
            // find all parents for current account
            Account currentAccount = [
                Select id, Name, IATAcode__c,
                    ParentId,
                    Parent.ParentId,
                    Parent.Parent.ParentId,
                    Parent.Parent.Parent.ParentId,
                    Parent.Parent.Parent.Parent.ParentId
                From Account
                Where id = :accountId ];

            // find the top parent
            Id parentId = null;
            if (currentAccount.ParentId == null ) {
                parentId = currentAccount.Id;
            } else if (currentAccount.Parent.ParentId == null ) {
                parentId = currentAccount.ParentId;
            } else if (currentAccount.Parent.Parent.ParentId == null ) {
                parentId = currentAccount.Parent.ParentId;
            } else if (currentAccount.Parent.Parent.Parent.ParentId == null ) {
                parentId = currentAccount.Parent.Parent.ParentId;
            } else if (currentAccount.Parent.Parent.Parent.Parent.ParentId == null ) {
                parentId = currentAccount.Parent.Parent.Parent.ParentId;
            } else {
                parentId = currentAccount.Parent.Parent.Parent.Parent.ParentId;
            }
            
            //Hierarchy Lists
            List<List<Account>> auxAccounts = new List<List<Account>>();
            List <Account> accountList2 = new List<Account>();
            List <Account> accountList3 = new List<Account>();
            List <Account> accountList4 = new List<Account>();
            List <Account> accountList5 = new List<Account>();
            List<SelectOption> none = new List<SelectOption>();
            none.add(new SelectOption('', '--None--'));
            IATACodeList.add(none);
            // Get all account in the hierarchy
            List <Account> accountList1 =
            [SELECT Id, IATAcode__c, Site, Location_type__c
                FROM Account
                WHERE IATAcode__c != null
                AND (Id = :parentId
                OR ParentId = :parentId
                OR Parent.ParentId = :parentId
                OR Parent.Parent.ParentId = :parentId
                OR Parent.Parent.Parent.ParentId = :parentId
                OR Parent.Parent.Parent.Parent.ParentId = :parentId)
                ORDER BY IATAcode__c ASC
                Limit 1000]; 
            auxAccounts.add(accountList1);
            if(accountList1.size() == 1000){
                accountList2 =
                [SELECT Id, IATAcode__c, Site, Location_type__c
                FROM Account
                WHERE IATAcode__c != null
                AND (Id = :parentId
                OR ParentId = :parentId
                OR Parent.ParentId = :parentId
                OR Parent.Parent.ParentId = :parentId
                OR Parent.Parent.Parent.ParentId = :parentId
                OR Parent.Parent.Parent.Parent.ParentId = :parentId)
                ORDER BY IATAcode__c ASC
                Limit 1000
                Offset 1000]; 
                auxAccounts.add(accountList2);
            }
            if(accountList2.size() == 1000){
                accountList3 =
                [SELECT Id, IATAcode__c, Site, Location_type__c
                FROM Account
                WHERE IATAcode__c != null
                AND (Id = :parentId
                OR ParentId = :parentId
                OR Parent.ParentId = :parentId
                OR Parent.Parent.ParentId = :parentId
                OR Parent.Parent.Parent.ParentId = :parentId
                OR Parent.Parent.Parent.Parent.ParentId = :parentId)
                ORDER BY IATAcode__c ASC
                Limit 1000
                Offset 2000]; 
                auxAccounts.add(accountList3);
            }
            if(accountList3.size() == 1000){
                accountList4 =
                [SELECT Id, IATAcode__c, Site, Location_type__c
                FROM Account
                WHERE IATAcode__c != null
                AND (Id = :parentId
                OR ParentId = :parentId
                OR Parent.ParentId = :parentId
                OR Parent.Parent.ParentId = :parentId
                OR Parent.Parent.Parent.ParentId = :parentId
                OR Parent.Parent.Parent.Parent.ParentId = :parentId)
                ORDER BY IATAcode__c ASC
                Limit 1000
                Offset 3000]; 
                auxAccounts.add(accountList4);
            }
            if(accountList4.size() == 1000){
                accountList5 =
                [SELECT Id, IATAcode__c, Site, Location_type__c
                FROM Account
                WHERE IATAcode__c != null
                AND (Id = :parentId
                OR ParentId = :parentId
                OR Parent.ParentId = :parentId
                OR Parent.Parent.ParentId = :parentId
                OR Parent.Parent.Parent.ParentId = :parentId
                OR Parent.Parent.Parent.Parent.ParentId = :parentId)
                ORDER BY IATAcode__c ASC
                Limit 1000
                Offset 4000]; 
                auxAccounts.add(accountList5);
            }
            if(auxAccounts!= null && auxAccounts.size() >0 ){ 
                for(List<Account> accounts : auxAccounts){
                    List<SelectOption> optionsAux = new List<SelectOption>();
                    for(Account acc : accounts){
                        optionsAux.add(new SelectOption(acc.IATAcode__c, acc.IATAcode__c + ' - ' + acc.Location_type__c)); 
                    }
                    if(optionsAux.size() > 0)
                        IATACodeList.add(optionsAux);
                }
            }
            // current account value as default
            this.newCase.IATACode__c = currentAccount.IATAcode__c;
            iataCode = this.newCase.IATACode__c;

        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        return IATACodeList;
        
    }
    
    // Get all catagory's articles in the english language
    public static list<FAQ__kav> getArticalsByCat(String cat, list<String> subCatList)
    {

        String queryText = 'SELECT Id ,UrlName ,Summary ,Title, Language, Answer__c'; //
        queryText +=  ',KnowledgeArticleId ,PublishStatus, ArticleNumber, LastPublishedDate';
        queryText += ' FROM FAQ__kav WHERE PublishStatus = \'Online\'';
        queryText += ' AND Language = \'en_US\'';
        queryText += ' with data category ' + cat; //Agency__c

        if(ISSP_Utilities.isNotEmpty(subCatList) )
        {
            queryText += ' BELOW (' + String.join(subCatList, ',') + ')'; //Accreditation__c Travel_Agent__c
        }

        queryText += ' limit 10000';

        System.debug('queryText for FAQ_kav>> ' + queryText);
        return (list<FAQ__kav>)Database.query(queryText);
    }

    // Create top 5 list of all articles
    public static list<sObject> getArticleVoteStatByIds(set<ID> knowledgeArticleIDs, String channelName)
    {
        return [SELECT Id, ParentId, NormalizedScore, Channel
                FROM FAQ__VoteStat
                WHERE ParentId IN : knowledgeArticleIDs AND Channel =: channelName
                ORDER BY NormalizedScore desc
                LIMIT 5];
    }

    /*
    Classes
    */
    public class ArticleViewLine
    {

        public FAQ__kav theArticle { get; private set;}
        public FAQ__VoteStat voteStat { get; set;}

        public ArticleViewLine(FAQ__kav article)
        {
            theArticle = article;
        }

        public ArticleViewLine(FAQ__kav article, FAQ__VoteStat voteStat)
        {
            this.theArticle = article;
            this.voteStat = voteStat;
        }

        public Boolean getHasVoteStat()
        {
            return null != voteStat && null != voteStat.NormalizedScore;
        }

        public String getPath()
        {
            return  '/articles/' + theArticle.Language + '/FAQ/' + theArticle.UrlName;
        }

    }

    public class ArticleModalView
    {
        public FAQ__kav SelectedArticle {get; set;}
        public Integer ViewCount {get; set;}
        public Integer SatisfiedCount {get; set;}

        public ArticleModalView()
        {
            ViewCount = 0;
            SatisfiedCount = 0;
        }
    }

    //TF - GSA too many records error
    public void refreshAirlineList(){
        system.debug('IN refreshAirlineList: ' + newCase.IFAP_Country_ISO__c);
        airlines = new List <SelectOption>();
        if (gsaMap.containsKey(newCase.IFAP_Country_ISO__c)){
            List <Services_Rendered__c> thisList = gsaMap.get(newCase.IFAP_Country_ISO__c);
            system.debug('airline list: ' + thisList);
            for (Services_Rendered__c thisService : thisList){
                airlines.add(new SelectOption(thisService.Services_Rendered_to_Airline__r.Site, thisService.Services_Rendered_to_Airline__r.Name));
            }
        }
        this.setLiveAgentButtonsNames();
    }
    public void getGsaCountryList_2() {
        system.debug('IN getGsaCountryList');
        gsaMap = new Map<String,List<Services_Rendered__c>>();//TF GSA
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--None--'));
        User myUser = [SELECT Id, Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId()];
        accountId = myUser.Contact.AccountId;
        List <Services_Rendered__c> servicesList = [SELECT Id, Services_Rendered_to_Airline__r.Site, Services_Rendered_to_Airline__r.Name,
                                                Services_Rendered_to_Airline__r.IATACode__c,
                                                ISO_Country_formula__c, ISO_Country_Code__c
                                                FROM Services_Rendered__c WHERE Services_Rendered_By__c = :accountId
                                                ORDER BY ISO_Country_formula__c];
        System.debug('servicesList - ' + servicesList);
        if (!servicesList.isEmpty()){
            for (Services_Rendered__c thisService : servicesList){
                if (gsaMap.containsKey(thisService.ISO_Country_Code__c)){
                    gsaMap.get(thisService.ISO_Country_Code__c).add(thisService);
                }
                else{
                    gsaMap.put(thisService.ISO_Country_Code__c, new List<Services_Rendered__c>{thisService});
                    system.debug('ADDING: ' + thisService.ISO_Country_Code__c);
                    options.add(new SelectOption(thisService.ISO_Country_Code__c, thisService.ISO_Country_formula__c));
                }
            }
        }
        //return options;
        gsaCountryList = options;
    }

    //TF - SP11
    public void setRecordType(){
        //set the Topic__c "English Value"
        if (isCompliment1 == false)
        {
            clsDataCategory cdc = this.DataCategoryContainer.lst_DataCategories[Integer.valueOf(topic)];
            newCase.Topic__c = ((cdc.CategoryName).replace('__c',' ')).replace('_',' ') ;
            //set the Topic__c "English Value"

            for(Integer cIndex = 0; cIndex < cdc.lst_childs.size(); cIndex++)
            {
                clsDataCategory.CategoryChildWrapper childCat = cdc.lst_childs[cIndex];
                if(subtopic == childCat.CategoryName)
                {
                     newCase.SubTopic__c =  ((childCat.CategoryName).replace('__c',' ')).replace('_',' ') ;
                }
            }
        }else
        {
            newCase.Topic__c = 'COMPLIMENT';
            newCase.SubTopic__c = 'COMPLIMENT';
            this.topic = '0';
        }

        // NewGenAPP when is called by APP, don't write on Origin field.
        if(callApexPagesParameters){
            //Set Origin to be PORTAL
            newCase.Origin = 'Portal';
        }


        Integer index = Integer.valueOf(topic.trim());
        clsDataCategory selectDataCategory = this.DataCategoryContainer.lst_DataCategories[index];
        String topicName = selectDataCategory.CategoryName;

        //Holds Final Matched Custom Setting if exists
        List <ISSP_FAQ2Case_Record_Type__c> FinalMatch_Lst = new List<ISSP_FAQ2Case_Record_Type__c>();
        //Represents the best matched Custom Setting
        ISSP_FAQ2Case_Record_Type__c ChoosenCS = new ISSP_FAQ2Case_Record_Type__c();
        //String to be used in the LIKE query
        string varCountry = '%' + newCase.IFAP_Country_ISO__c + '%';

        list<IATA_ISO_Country__c> lst_Country = new list<IATA_ISO_Country__c>([SELECT Id, Name , Case_BSP_Country__c , ISO_Code__c
                                                                                FROM IATA_ISO_Country__c
                                                                                WHERE ISO_Code__c  =: newCase.IFAP_Country_ISO__c
                                                                                LIMIT 1 ]);
        if(lst_Country != null && lst_Country.size() > 0){
            newCase.BSPCountry__c =  lst_Country[0].Case_BSP_Country__c ;
            newCase.Country_concerned_by_the_query__c = lst_Country[0].Case_BSP_Country__c ;
        }

        system.debug('basto1p topicName: ' + topicName);
        system.debug('basto1p subtopic: ' + subtopic);
        system.debug('basto1p parentCase.Compliment__c: ' + isComplain1);
        system.debug('basto1p varCountry: ' + varCountry);
        
        //select all matched custom settings
        List <ISSP_FAQ2Case_Record_Type__c> csList = [SELECT RecordType__c, OwnerId__c ,Topic__c ,SubTopic__c ,Complaint__c ,Country_concerned_by_the_query__c ,
                                                             Country_concerned_by_the_query2__c , Country_concerned_by_the_query3__c,
                                                             Flag_Assignment_Rules__c
                                                      FROM ISSP_FAQ2Case_Record_Type__c
                                                      WHERE
                                                            Complaint__c = :isComplain1
                                                            AND (Topic__c = :topicName
                                                                OR SubTopic__c = :subtopic
                                                                OR Country_concerned_by_the_query__c like: varCountry
                                                                OR Country_concerned_by_the_query2__c like: varCountry
                                                                OR Country_concerned_by_the_query3__c like: varCountry)];
        system.debug('KER0 csList: ' + csList);


        if(csList != null && csList.size() > 0 ) {
            system.debug('basto1p: csList NOT EMPTY');
            String userInput_Country = newCase.IFAP_Country_ISO__c ;

            //Holds All Topic match Cases
            List <ISSP_FAQ2Case_Record_Type__c> TopicMatch_Lst = new List<ISSP_FAQ2Case_Record_Type__c>();
            //
            List <ISSP_FAQ2Case_Record_Type__c> EmptyTopicMatch_Lst = new List<ISSP_FAQ2Case_Record_Type__c>();
            //Holds All Topic + Subtopic Matches Custom setting
            List <ISSP_FAQ2Case_Record_Type__c> SubTopicMatch_Lst = new List<ISSP_FAQ2Case_Record_Type__c>();
            //
            List <ISSP_FAQ2Case_Record_Type__c> EmptySubTopicMatch_Lst = new List<ISSP_FAQ2Case_Record_Type__c>();
             //
            List <ISSP_FAQ2Case_Record_Type__c> EmptySubTopicAndSubTopicMatch_Lst = new List<ISSP_FAQ2Case_Record_Type__c>();

            for(ISSP_FAQ2Case_Record_Type__c cs : csList){

                //Collect Topic Match Custom Settings
                if(cs.Topic__c != null && cs.Topic__c.contains(topicName)){
                   system.debug('basto1p: ADD TO TopicMatch_Lst'+cs.Topic__c);
                   TopicMatch_Lst.add(cs);
                }

                //Collect Empty Topic no-Match Custom Settings
                if(cs.Topic__c == null || cs.Topic__c == ''){
                   EmptyTopicMatch_Lst.add(cs);
                }

                //Collect Empty Topic ans SubTopics no-Match Custom Settings
                if((cs.Topic__c == null || cs.Topic__c == '') && (cs.SubTopic__c == null || cs.SubTopic__c == '') ){
                   EmptySubTopicAndSubTopicMatch_Lst.add(cs);
                }
            }

            //Collect the Topic + subtopic match Custom settings
            if(TopicMatch_Lst != null && TopicMatch_Lst.size() > 0)
            {
                for(ISSP_FAQ2Case_Record_Type__c tcs : TopicMatch_Lst){
                    if(tcs.SubTopic__c != null && tcs.SubTopic__c.contains(subtopic)){
                        SubTopicMatch_Lst.add(tcs);
                    }
                    if(tcs.SubTopic__c == null || tcs.SubTopic__c == ''){
                        EmptySubTopicMatch_Lst.add(tcs);
                    }
                }
                
                system.debug('basto1p: TopicMatch_Lst NOT EMPTY');
                
                if(SubTopicMatch_Lst != null && SubTopicMatch_Lst.size() > 0)
                {
                    //Check for country match
                    FinalMatch_Lst = RetriveMatchCountrySettings(SubTopicMatch_Lst , userInput_Country);
                }
                else{
                    //Topic + NO SubTopic Match Case
                    //Check for country match
                    if(EmptySubTopicMatch_Lst != null && EmptySubTopicMatch_Lst.size() > 0){
                        system.debug('basto1p: use EmptySubTopicMatch_Lst');
                        FinalMatch_Lst = RetriveMatchCountrySettings(EmptySubTopicMatch_Lst , userInput_Country);
                        system.debug('basto1p: FinalMatch_Lst='+FinalMatch_Lst);
                    }else{
                        FinalMatch_Lst = RetriveMatchCountrySettings(EmptySubTopicAndSubTopicMatch_Lst , userInput_Country);
                    }
                }
            }
            else{
                system.debug('basto1p: NO Topic Match Case');
                //NO Topic Match Case
                //Check for country match
                if(EmptyTopicMatch_Lst != null && EmptyTopicMatch_Lst.size() > 0){
                    FinalMatch_Lst = RetriveMatchCountrySettings(EmptyTopicMatch_Lst , userInput_Country);
                }
            }
        }

        if(FinalMatch_Lst != null && FinalMatch_Lst.size() > 0)
        {
            system.debug('basto1p: FinalMatch_Lst NOT EMPTY');
            ChoosenCS = FinalMatch_Lst[0];
            //Select the choosen Record Type
            String recordType = ChoosenCS.RecordType__c;
            List <RecordType> recordTypeList = [SELECT Id, Name FROM RecordType WHERE DeveloperName = :recordType AND sObjectType = 'Case'];

            if (!recordTypeList.isEmpty()){
                //Assign RecordType according to custom Settings
                newCase.RecordTypeId = recordTypeList[0].Id;

                system.debug('basto1p: FinalMatch_Lst recordType='+recordTypeList[0].Name);
                
                //Assign owenerId according to custom Settings
                if (ChoosenCS.OwnerId__c != null && ChoosenCS.OwnerId__c != ''){
                    newCase.OwnerId = ChoosenCS.OwnerId__c;
                }

                //TF - Add Flag_Assignment_Rules__c value to Description
                if (ChoosenCS.Flag_Assignment_Rules__c != null && ChoosenCS.Flag_Assignment_Rules__c != ''){
                    newCase.Description = newCase.Description+'\n\n' + ChoosenCS.Flag_Assignment_Rules__c;
                }
            }
        }
        if(isComplain1 == true){
            newCase.IsComplaint__c = true ;
        }
        if(isCompliment1 == true){
            newCase.Compliment__c = true ;
        }

    }


    //Description : Method that Retrive Custom setting "From input list" that have matching country with the input param inIFAPCountryISO
    // Input : List <ISSP_FAQ2Case_Record_Type__c>  , string
    // Output: List <ISSP_FAQ2Case_Record_Type__c>
    private List <ISSP_FAQ2Case_Record_Type__c> RetriveMatchCountrySettings (List <ISSP_FAQ2Case_Record_Type__c> inCS_Lst , string inIFAPCountryISO){
        system.debug('KER0 START RetriveMatchCountrySettings');
        List <ISSP_FAQ2Case_Record_Type__c> returnSetting_Lst =new List <ISSP_FAQ2Case_Record_Type__c>();
        for(ISSP_FAQ2Case_Record_Type__c cs : inCS_Lst){
            //Collect country Match Custom Settings
            if(CheckCountryMatch(cs.Country_concerned_by_the_query__c , newCase.IFAP_Country_ISO__c)){
                returnSetting_Lst.add(cs);
            }else{
                if(CheckCountryMatch(cs.Country_concerned_by_the_query2__c , newCase.IFAP_Country_ISO__c)){
                    returnSetting_Lst.add(cs);
                }
                else{
                        if(CheckCountryMatch(cs.Country_concerned_by_the_query3__c , newCase.IFAP_Country_ISO__c)){
                        returnSetting_Lst.add(cs);
                    }
                }
            }
        }
        system.debug('KER0 START RetriveMatchCountrySettings returnSetting_Lst==>' +returnSetting_Lst);
        return returnSetting_Lst;
    }

    @TestVisible
    private boolean CheckCountryMatch(string inCountryCS , string inIFAPCountryISO){
        system.debug('KER0 START CheckCountryMatch ' );
        if(inCountryCS != null &&
           inIFAPCountryISO != null &&
           (inCountryCS.contains(inIFAPCountryISO) || inCountryCS == 'ALL'))
        {
            system.debug('KER0 START CheckCountryMatch true' );
            return true ;
        }
        else{system.debug('KER0 START CheckCountryMatch false' );
            return false;
        }
    }


    //Method Description: build a structure of fields and sections to be displayed , according to the selected custom  seattings
    public PageReference GenerateFieldsBySettings(){
        //public List<ISSP_Case_Fields_2__c> myList {get; set;}
        //public Case newCase {get;set;}
        String profileId= userinfo.getProfileId() ;
        String profileIdforSoql = '%'+profileId+'%';
        System.debug('Ker99 profileId ==>'+profileId);

        boolean clickedService = false ;
        if(Clicked_SISHelpDesk == true || Clicked_IATAServiceRequest == true || Clicked_PWCServiceRequest == true || Clicked_DPCServiceRequest == true){

        ISSP_CaseFields_Lst = new List<ISSP_Case_Fields__c>([select Id ,AP_Case__c,Field_Name__c,Label__c,NOT_FDS__c,Order__c,
                                                                    Profile_Id_List__c,Read_Only__c,Required__c,Type__c
                                                            From ISSP_Case_Fields__c
                                                            Order by Order__c Asc]);/*WHERE profileId IN : Profile_Id_List__c Order by Order__c Asc */

        resetCase();
        this.currentButtonsToShow = CancelAndSubmit;
        createArticleStatisticsRecords(SelectedArticleModalView.SelectedArticle, ENV.ArticleStatType.UnSatisfied);
        clickedService = true;
        }else{
            ISSP_CaseFields_Lst = new List<ISSP_Case_Fields__c>([select Id ,AP_Case__c,Field_Name__c,Label__c,NOT_FDS__c,Order__c,
                                                                    Profile_Id_List__c,Read_Only__c,Required__c,Type__c
                                                             From ISSP_Case_Fields__c
                                                             WHERE Profile_Id_List__c LIKE : profileIdforSoql
                                                             OR Profile_Id_List__c =: ''
                                                             OR Profile_Id_List__c =: null
                                                             Order by Order__c Asc]);/*WHERE profileId IN : Profile_Id_List__c Order by Order__c Asc */
        }


        System.debug('Ker99 ISSP_CaseFields_Lst ==>'+ISSP_CaseFields_Lst);

        //newCase     = new Case();
        newSection  = new sectionRecordWrapper();
        fullList    = new List<sectionRecordWrapper>();

    if(ISSP_CaseFields_Lst != null && ISSP_CaseFields_Lst.size() > 0){
        for (ISSP_Case_Fields__c thisField : ISSP_CaseFields_Lst)
        {
            if (thisField.Type__c == 'Section'){
                newSection = new sectionRecordWrapper();
                newSection.section = thisField.Label__c;
                //newSection.Complaint = thisField.Complaint__c;

                fullList.add(newSection);
            }

            if(thisField.Type__c == 'Field'
                || thisField.Type__c == 'Checkbox'
                || thisField.Type__c == 'AirlineList'
                || thisField.Type__c == 'GSA_Only_Checkbox'
                || thisField.Type__c == 'bootstrap-select'
                || thisField.Type__c == 'ccothers'
                )
            {
                fieldRecordWrapper newField = new fieldRecordWrapper(thisField);
                // adding exception to a field
                if (newField.fieldType == 'bootstrap-select' && newField.fieldValue=='IATAcode__c') {
                    newField.listOptions = initIATACodeList(this.parentAccountId);
                }
                
                if (thisField.Profile_Id_List__c != '' && thisField.Profile_Id_List__c != null && clickedService == false)
                {
                    List<String> profileList =  thisField.Profile_Id_List__c.split(';');
                    for (String thisId : profileList)
                    {
                        if (thisId == UserInfo.getProfileId())
                        {
                          newField.rendered = true;
                        }
                        else
                        {
                          newField.rendered = false;
                        }
                    }
                }
                else
                {
                    newField.rendered = true;
                }

                newSection.fieldList.add(newField);
            }
        }
        return null;
    }else{
        fullList.add(newSection);
        return null;
    }
}


    //wrapper that holds the section structur
    public class sectionRecordWrapper {
        public String section {get; set;}
        //public boolean Complaint {get;set;}
        public List<fieldRecordWrapper> fieldList {get; set;}

        public sectionRecordWrapper(){
            section = '';
            //Complaint = false ;
            fieldList = new List<fieldRecordWrapper>();
        }
    }

    //Wrapper that holds the field structure
    public class fieldRecordWrapper {
        public String fieldName     {get; set;}
        public String fieldType     {get; set;}
        public String fieldValue    {get; set;}
        public String fieldValueEntered    {get; set;}
        public Boolean rendered     {get; set;}
        public Boolean required     {get; set;}
        public Boolean readonly     {get; set;}
        public Boolean NOT_FDS      {get; set;}
        public Boolean AP_CASE      {get; set;}
        //public Boolean Complaint    {get; set;}
        public Decimal orderNumber  {get; set;}
        public list<list<SelectOption>> listOptions {get; set;} 
        public list<SelectOption> listOptionsExtended {get; set;}

        public fieldRecordWrapper(ISSP_Case_Fields__c CS){
              this.fieldName    = CS.Label__c ;
              this.fieldType    = CS.Type__c ;
              this.fieldValue   = CS.Field_Name__c ;
              this.rendered     = true;
              this.required     = CS.Required__c ;
              this.readonly     = CS.Read_Only__c ;
              this.orderNumber  = CS.Order__c ;
              this.NOT_FDS      = CS.NOT_FDS__c ;
              this.AP_CASE      = CS.AP_Case__c ;
              //this.Complaint    = CS.Complaint__c ;
              this.listOptions  = new list<list<SelectOption>>();
              this.listOptionsExtended  = new list<SelectOption>();
        }
        public void addListOptions(list<SelectOption> inputOptions) {
            Integer maxElems = 1000;
            for (SelectOption option: inputOptions) {
                if (this.listOptions.size()<maxElems) {
                    //this.listOptions.add(option);
                } else {
                    //this.listOptionsExtended.add(option);
                }
                
            }
        }
    }

    //Defines which Linkes in the side Bar the User can see
    public void setCaseRecordTypeAccess(){
        User user = [select Id,languagelocalekey,ContactId,ProfileId from User where Id =:Userinfo.getUserId()];

        List<Portal_Application_Right__c> appsGrantedList = new List<Portal_Application_Right__c>([Select p.Application_Name__c,p.Portal_Application__r.Description__c,p.Portal_Application__r.Requestable__c,p.Application_icon_del__c, p.Portal_Application__r.New_Window__c,p.Right__c, p.Portal_Application__r.Application_icon_URL__c, p.Portal_Application__r.Name, p.Portal_Application__c, p.My_Apps__c, p.Contact__c, p.Application_Start_URL__c ,p.Case_creation_record_Type__c
                                                                                               From Portal_Application_Right__c p
                                                                                               where p.Contact__c =: user.ContactId and
                                                                                                     p.My_Apps__c = true and
                                                                                                    (p.Right__c = 'Access Granted'  or p.Right__c = 'Access Requested') and
                                                                                                     p.Portal_Application__r.Hide_on_Homepage__c = false]);
        if(appsGrantedList != null && appsGrantedList.size() > 0){
            for(Portal_Application_Right__c App: appsGrantedList){
                if(App.Case_creation_record_Type__c == 'IATA_Service_Request'){
                //    isIATAServiceRequest = true ;
                }
                if(App.Case_creation_record_Type__c == 'Cases_SIS_Help_Desk'){
                //    isSISHelpDesk = true ;
                }
                if(App.Case_creation_record_Type__c == 'ISS_Portal_PwC'){
                //    isPWCServiceRequest = true ;
                }
                if(App.Case_creation_record_Type__c == 'DPC_Service_Request'){
                //    isDPCServiceRequest = true ;
                }
            }
        }

        //isSISHelpDesk = true ;//basto1p - AQUI to remove only for test
    }

    //Input : RecordTypeName
    //Output : record Type ID
    @TestVisible
    private Id getCaseRecordTypeIdByName(String inRecordTypeName){
        SObjectType ObjType;
        map<String, Schema.RecordTypeInfo> TypeInfoMap;
        Schema.RecordTypeInfo TypeInfo;
        Id RecTypeId;

        // use Account sObject type as an example
        ObjType =  Case.SObjectType;
        TypeInfoMap = ObjType.getDescribe().getRecordTypeInfosByName();
        TypeInfo = TypeInfoMap.get(inRecordTypeName);
        if (TypeInfo != null) {
            return RecTypeId = TypeInfo.getRecordTypeId();
        }
        else return null ;
    }


    //method called when clicking on side bar to define which recordtype the new case will be
    public void CheckNewCaseRecordType(){
        string inRecordTypeName = Apexpages.currentPage().getParameters().get('myRecordType');

        //Clicked Buttons in side Bar booleans ,
        Clicked_SISHelpDesk = false;
        Clicked_IATAServiceRequest = false;
        Clicked_PWCServiceRequest = false;
        Clicked_DPCServiceRequest = false;
        Clicked_EmergencyRequest = false;

        if(inRecordTypeName == 'Cases_SIS_Help_Desk'){
            Clicked_SISHelpDesk = true ;
        }else if(inRecordTypeName == 'IATA_Service_Request'){
            Clicked_IATAServiceRequest = true ;
        }else if(inRecordTypeName == 'ISS_Portal_PwC'){
            Clicked_PWCServiceRequest = true;
        }else if(inRecordTypeName == 'DPC_Service_Request'){
            Clicked_DPCServiceRequest = true ;
        }
        GenerateFieldsBySettings();
    }

    public Id AssignNewCaseRecordType(){
        if(Clicked_SISHelpDesk == true){
            return getCaseRecordTypeIdByName('Cases_SIS_Help_Desk');
        }else if(Clicked_IATAServiceRequest == true){
            return getCaseRecordTypeIdByName('IATA_Service_Request');
        }else if(Clicked_PWCServiceRequest == true){
            return getCaseRecordTypeIdByName('ISS_Portal_PwC');
        }else if(Clicked_DPCServiceRequest == true ){
            return getCaseRecordTypeIdByName('DPC_Service_Request');
        }else{
            return null;
        }
    }

    public PageReference GenerateTopicHelpText(){
        if(topic != Env.SelectOptionDefaultValue){ // INC263231 - IF topic was the default don't do the logic
            Integer index = Integer.valueOf(this.topic.trim());
            clsDataCategory selectDataCategory = this.DataCategoryContainer.lst_DataCategories[index];

            List<ISSP_HelpText__c> ISSP_TopicHelptext_Lst = new List<ISSP_HelpText__c> ([ select Id ,Topic__c , SubTopic__c , HelpText_Label_API__c
                                                                                          From ISSP_HelpText__c
                                                                                          WHERE Topic__c =: selectDataCategory.CategoryName
                                                                                          AND SubTopic__c =: null]);

            System.debug('Kerensen1 ISSP_TopicHelptext_Lst ==>'+ISSP_TopicHelptext_Lst);
            if(ISSP_TopicHelptext_Lst != null && ISSP_TopicHelptext_Lst.size() > 0){
                ISSP_TopicHelptext = ISSP_TopicHelptext_Lst[0];
            }else{
                ISSP_TopicHelptext = new ISSP_HelpText__c();
            }
        }
            return null;

    }


    public PageReference GeneratesubTopicHelpText(){

        System.debug('Kerensen1 START GenerateTopicHelpText ==>'+subtopic);
        if(subtopic != Env.SelectOptionDefaultValue){  // INC263231 - IF topic was the default don't do the logic
            Integer index = Integer.valueOf(this.topic.trim());
            clsDataCategory selectDataCategory = this.DataCategoryContainer.lst_DataCategories[index];

            List<ISSP_HelpText__c> ISSP_SubTopicHelptext_Lst = new List<ISSP_HelpText__c> ([ select Id ,Topic__c , SubTopic__c , HelpText_Label_API__c
                                                                                          From ISSP_HelpText__c
                                                                                          WHERE
                                                                                              Topic__c =: selectDataCategory.CategoryName
                                                                                          And SubTopic__c =:subtopic
                                                                                          And SubTopic__c != null]);

            System.debug('Kerensen1 ISSP_SubTopicHelptext_Lst ==>'+ISSP_SubTopicHelptext_Lst);
            if(ISSP_SubTopicHelptext_Lst != null && ISSP_SubTopicHelptext_Lst.size() > 0){
                ISSP_SubTopicHelptext = ISSP_SubTopicHelptext_Lst[0];
            }else{
                ISSP_SubTopicHelptext = new ISSP_HelpText__c();
            }
        }
        return null;
    }

    // Method display topic and subtopic according to Custom Setting "ISSP_FAQ2Case_Permissions__c" Permissions
    private void setTopicByPermissions(){
        //Help Selectoptuion List
        list<SelectOption> tmpselectTopicsList = new list<SelectOption>();
        boolean isIFGUser = ISSP_Utilities.isIFGUser();

        //Select Custom Setting to set permissions
        List <ISSP_FAQ2Case_Permissions__c> PermissionList = [SELECT Sector_Permission__c, Name ,Topic__c ,SubTopic__c, ISO_Country__c
                                                            FROM ISSP_FAQ2Case_Permissions__c
                                                            Where Subtopic__c =: null
                                                            AND Topic__c != null
                                                            ];
        system.debug('SFI PermissionList: ' + PermissionList);
        system.debug('SFI PermissionList SIZE: ' + PermissionList.size());

        if(PermissionList != null && PermissionList.size() > 0){
            for (SelectOption top : this.lst_selectTopics)
            {
                //set the Topic "English Value"
                string TopicinEnglish = '';
                String CategoryNameItem='';
                if (top.getValue() != '-- Select --')
                {
                    clsDataCategory cdc = this.DataCategoryContainer.lst_DataCategories[Integer.valueOf(top.getValue())];
                    TopicinEnglish = ((cdc.CategoryName).replace('__c','')) ;//.replace('_',' ')
                    CategoryNameItem=cdc.CategoryName;
                }else{
                    TopicinEnglish ='-- Select --';
                }
                //set the Topic "English Value"

                boolean FoundExcludePermission = false ;
                for (ISSP_FAQ2Case_Permissions__c  per : PermissionList)
                {
                    //Check if the topic has matched Custom setting record
                    if (per.topic__c != null && per.topic__c.contains(TopicinEnglish))
                    {
                    if ( per.Sector_Permission__c != null
                        && ( (per.Sector_Permission__c.contains(Sector) && !isCNS && !per.Sector_Permission__c.startsWith('CNS')) ||
                            per.Sector_Permission__c.contains('All') ||
                            (isCNS && per.Sector_Permission__c.startsWith('CNS')) )
                        && per.ISO_Country__c != null
                        && (per.ISO_Country__c.contains(AccountISOCountry) || per.ISO_Country__c.contains('All')) )
                        {
                            FoundExcludePermission = true ;
                        }
                    }
                }
                //If topic has permission add it to the display List
                if (!FoundExcludePermission)
                {
                    //system.debug('basto1p - TopicinEnglish='+TopicinEnglish);
                    if(!isIFGUser && CategoryNameItem.equals(IFG_TOPIC)){
                        continue;
                    }else{
                        tmpselectTopicsList.add(top);
                    }

                }
            }

            // Prepare Subtopics final list to display
            if (tmpselectTopicsList != null && tmpselectTopicsList.size() > 0)
            {
                this.lst_selectTopics.clear();
                this.lst_selectTopics = tmpselectTopicsList ;
            }
        }
    }


    // Method display topic and subtopic according to Custom Setting "ISSP_FAQ2Case_Permissions__c" Permissions
    private void setSubTopicByPermissions(){
        Integer index = Integer.valueOf(topic.trim());
        clsDataCategory selectDataCategory = this.DataCategoryContainer.lst_DataCategories[index];

        //Help Selectoptuion List
        list<SelectOption> tmpselectSubTopicsList = new list<SelectOption>();

        //Select Custom Setting to set permissions
        List <ISSP_FAQ2Case_Permissions__c> PermissionList = [SELECT Sector_Permission__c, Name ,Topic__c ,SubTopic__c, ISO_Country__c
                                                              FROM ISSP_FAQ2Case_Permissions__c
                                                              Where Subtopic__c != null];
        system.debug('SFI2 PermissionList: ' + PermissionList);

        if(PermissionList != null && PermissionList.size() > 0){
            for (SelectOption subtop : this.lst_selectsubTopics)
            {
                boolean FoundExcludePermission = false ;
                string subtopicVal = subtop.getValue() == 'Fees__c' || subtop.getValue() == 'Changes__c' ? ','+(subtop.getValue()).replace('__c','') : (subtop.getValue()).replace('__c','') ;
                for (ISSP_FAQ2Case_Permissions__c  per : PermissionList)
                {
                    //Check if the topic has matched Custom setting record
                    if ( per.Sector_Permission__c != null && per.Sector_Permission__c.contains(Sector)
                        && per.Subtopic__c != null && per.Subtopic__c.contains(subtopicVal)
                        && (selectDataCategory.CategoryName == per.topic__c || per.topic__c == null || per.topic__c == '')
                        && per.ISO_Country__c != null
                        && (per.ISO_Country__c.contains(AccountISOCountry) || per.ISO_Country__c.contains('All')) )
                    {
                        FoundExcludePermission = true ;
                    }
                }
                //If subtopic has permission add it to the display List
                if (!FoundExcludePermission)
                {
                    tmpselectSubTopicsList.add(subtop);
                }
            }
            // Prepare Subtopics final list to display
            if (tmpselectSubTopicsList != null && tmpselectSubTopicsList.size() > 0)
            {
                this.lst_selectsubTopics.clear();
                this.lst_selectsubTopics = tmpselectSubTopicsList ;
            }
        }
    }

    public PageReference copyCountryISO(){
        this.newCase.IFAP_Country_ISO__c = newCase1.IFAP_Country_ISO__c ;

        setLiveAgentButtonsNames();

        return null;
    }



    public void GenerateCreateCaseButtonURL(){
        System.debug('Kerensen2 START GenerateCreateButtonURL ==>');
        Integer index = Integer.valueOf(this.topic.trim());
        clsDataCategory selectDataCategory = this.DataCategoryContainer.lst_DataCategories[index];

        List<ISSP_FAQ2Case_CreateCaseURL__c> ISSP_CreateButtonURL_Lst = new List<ISSP_FAQ2Case_CreateCaseURL__c> ([ select Id ,Topic__c , SubTopic__c , URL__c
                                                                                      From ISSP_FAQ2Case_CreateCaseURL__c
                                                                                      WHERE
                                                                                          Topic__c =: selectDataCategory.CategoryName
                                                                                      And SubTopic__c =:subtopic
                                                                                      And SubTopic__c != null]);

        System.debug('Kerensen2 ISSP_CreateButtonURL_Lst ==>' + ISSP_CreateButtonURL_Lst);
        if(ISSP_CreateButtonURL_Lst != null && ISSP_CreateButtonURL_Lst.size() > 0){
            CreateButtonURL = ISSP_CreateButtonURL_Lst[0].URL__c;

        }
    }
}