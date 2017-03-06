//TRANSFORM 02/03/15 ==> includes new functionality algorithm  provided by Elliot ,
/**
 * Last update by Nurit and Niv 11/16/2014
 */
public without sharing class vfISSP_FAQ2Case 
{
    /* Buttons State */
    public static final String OnlyCancel   = 'OnlyCancel';
    public static final String CancelAndCreateACase   = 'CancelAndCreateACase';
    public static final String CancelAndSubmit   = 'CancelAndSubmit';

    public String currentButtonsToShow {get; set;}
    public boolean SHowButtons {get; set;}
    public String recordToCreate {get; set;}
    public list<SelectOption> lst_selectTopics {get;set;}
    public list<SelectOption> lst_selectsubTopics {get;set;}
    public String topic { get; set; }
    public String subtopic { get; set; }
    public String concernedCountry { get; set; }
    public String selectedCountry { get; set; }
    public clsDataCategoryContainer DataCategoryContainer {get;set;}
    public list<ArticleViewLine> articleViewLines { get; set; }
    //public FAQ__kav selectedArtical { get; set; }
    public ArticleModalView SelectedArticleModalView {get; set;}

    public boolean isAgencyUser {get;set;} //TF - SP9-C5
    public boolean isGSAUser {get;set;} //TF - SP9-C5
    public boolean isGSAOnly {get;set;} //TF - SP9-C5
    public String accountId {get;set;} //TF - SP9-C5
    public String myTopic {get;set;} //TF - SP9-C5
    public boolean isPWCProfile {get;set;}
    public boolean isDPCUser {get;set;}
    public static boolean isComplain {get;set;}//Indecates if the user clicked the "I wish to complain button"
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

    //Added new Help Text to the Page 
    public ISSP_HelpText__c ISSP_TopicHelptext {get;set;} 
    public ISSP_HelpText__c ISSP_SubTopicHelptext {get;set;}
    
    //Added new Create button Functionality
    //public ISSP_CreateButtonURL__c ISSP_CreateButtonURL {get;set;}  
    public String CreateButtonURL {get;set;}  

    //Sector field of the Account
    public string Sector {get; set;}
    public String labelSubTopic = '';
    public  boolean isComplain1 = false;
    public  boolean isCompliment1 = false;

    public Boolean isTopicDefault = false; // INC263231

    public list<String> errorMessage {get; set;}

    //CNS
    public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}
    public String commParam { get { if(communityName=='CNS'){ return '&CommunityName='+ communityName;} return ''; } set;}

    public vfISSP_FAQ2Case() 
    {     

    }
    
    public PageReference pageLoad() {
        errorMessage = new list<string>();
        
        SelectedArticleModalView = new ArticleModalView();
        //TF - SP9-C5
        isGSAUser = false;
        isGSAOnly = false;
        isPWCProfile = false;
        isDPCUser = false;
        
        //Page SHOW Buttons in side Bar booleans , According to Record types
        isSISHelpDesk       = false ;
        isIATAServiceRequest= false ;
        isPWCServiceRequest = false ;
        isDPCServiceRequest = false ;

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


        myTopic = ApexPages.currentPage().getParameters().get('topic');
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
    public Set<String>topicsToShowButton {
        get{
            if (topicsToShowButton == null){
                List<ISSP_FAQ2CaseLiveAgentTopics__c> topics = [SELECT value__c FROM ISSP_FAQ2CaseLiveAgentTopics__c];
                topicsToShowButton = new Set<String>();
                for (ISSP_FAQ2CaseLiveAgentTopics__c topic :topics){
                    topicsToShowButton.add(topic.value__c);
                }
            }
            return topicsToShowButton;
        }
        set;
    }
    public Boolean showButton {
        get{
            //in the future if more chat buttons are required we need a dynamic way to pass the button name - for the moment we don't know the rules
            return topicsToShowButton.contains(subtopic) && isAllowedCode('AirlineEnglish') && isAllowedSector('AirlineEnglish');
        }
        set;
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
        this.newCase = new Case();
        this.newCase1 = new Case();
    } 

    private void addDecsription() {
        

        String addDecsription ;
        if (isCompliment1 == false)
        {
             Integer index = Integer.valueOf(topic.trim());
             clsDataCategory selectDataCategory = this.DataCategoryContainer.lst_DataCategories[index];
             addDecsription = Label.ISSP_F2CTopic + ' - ' 
                              + selectDataCategory.CategoryLabel + '\n' 
                              + labelSubTopic + ' - '  
                              + selectDataCategory.getLabelByNameCategory(subtopic); 
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
	    public Boolean isAllowedCode(String btnName) {

        List<LiveAgent_Countries_Per_Button__c> aCountries = [SELECT Iso_Code__c FROM LiveAgent_Countries_Per_Button__c WHERE Button_Name__c = :btnName];
        Set<String> aCodes = new Set<String>();
        for (LiveAgent_Countries_Per_Button__c aCountry :aCountries){
            aCodes.add(aCountry.Iso_Code__c);
        }
        return aCodes.contains(newCase.IFAP_Country_ISO__c);
    }

    public Boolean isAllowedSector(string btnName) {

        LiveAgentButtonSettings__c labs = new LiveAgentButtonSettings__c();
        try{
            labs = LiveAgentButtonSettings__c.getAll().get(btnName);
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'{!$Label.LiveAgentCustomSettingNotFound} '+e));
            return false;
        }
        Set<String> aSectors =  new Set<String>(labs.sectors__c.split(','));
        return aSectors.contains(sector);
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
    
    public PageReference save() 
    {   
       
        if( ((subtopic == null ||subtopic == '' ||subtopic == '-- Select --' || subTopic == topic))||//added &&iscompliment to bypass error message
            (newCase.IFAP_Country_ISO__c == null ||newCase.IFAP_Country_ISO__c == '')||
            (newCase.Subject == null ||newCase.Subject == '')||
            (newCase.Description == null ||newCase.Description == '')){

            string ErrFields = ''; 
            if((subtopic == null ||subtopic == ''||subtopic == '-- Select --'|| subTopic == topic)&&isCompliment1!= true){
               ErrFields += System.Label.ISSP_I_wish_to_complain_about +'xx, '+isCompliment1;
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

        //ASsign new CAse Record Type
        if(AssignNewCaseRecordType() != null){
            newCase.RecordTypeId = AssignNewCaseRecordType();
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
            return new Pagereference('/ISSP_Case?caseId='+newCase.Id + commParam);
        } 
    }

    
    
    public PageReference saveAttach() 
    {system.debug('wwewwe IFAP_Country_ISO__c: ' + newCase.IFAP_Country_ISO__c );
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
        
        //ASsign new CAse Record Type
        if(AssignNewCaseRecordType() != null){
            newCase.RecordTypeId = AssignNewCaseRecordType();
        }
        
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
            //return new Pagereference('/p/attach/NoteAttach?pid=' + newCase.Id + '&retURL=%2FISSP_Case?caseId='+ newCase.Id);
            return new Pagereference('/apex/ISSP_AddAttachment?caseid=' + newCase.Id + commParam);
        }
    }

    public   PageReference IwishtoComplain() 
    {system.debug('JK22 isComplain IwishtoComplain START: ' + isComplain);
        resetCase();
        Clicked_SISHelpDesk = false;
        Clicked_IATAServiceRequest = false;
        Clicked_PWCServiceRequest = false;
        Clicked_DPCServiceRequest = false;
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

    public PageReference GeneralQueueMethod(){
        resetCase();
        Clicked_SISHelpDesk = false;
        Clicked_IATAServiceRequest = false;
        Clicked_PWCServiceRequest = false;
        Clicked_DPCServiceRequest = false;
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
        return null;
    }
    
    public void refreshTopicPickList()
    {   
        system.debug('JK22 isComplain refreshTopicPickList START: ' + isComplain);
        resetCase(); 
        this.currentButtonsToShow = OnlyCancel;
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

            clsDataCategory selectDataCategory = this.DataCategoryContainer.lst_DataCategories[index];

            if (selectDataCategory.lst_childs.size() > 0)
            {
                this.lst_selectsubTopics.add(new SelectOption(Env.SelectOptionDefaultValue, Env.SelectOptionDefaultValue));
                for(Integer cIndex = 0; cIndex < selectDataCategory.lst_childs.size(); cIndex++)
                {
                    clsDataCategory.CategoryChildWrapper childCat = selectDataCategory.lst_childs[cIndex];  
                    this.lst_selectsubTopics.add(new SelectOption(childCat.CategoryName, childCat.CategoryLabel));
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
        
   public void refreshSubTopicPickList()     {
        
        resetCase();
        system.debug('TOPIC: ' + topic);
        Integer index = Integer.valueOf(topic.trim());
        system.debug('INTEGER: ' + index);
        clsDataCategory selectDataCategory = this.DataCategoryContainer.lst_DataCategories[index];
        system.debug('JK subtopic: ' + subtopic);
        if (subtopic.compareTo(Env.SelectOptionDefaultValue) == 0)
        {
            subtopic = selectDataCategory.CategoryName;
            this.currentButtonsToShow = CancelAndSubmit; 
            system.debug('JK1 this.currentButtonsToShow: ' + this.currentButtonsToShow);
        }
        else
        {
            if(isComplain != true){
                this.currentButtonsToShow = CancelAndCreateACase;
                system.debug('JK2 this.currentButtonsToShow: ' + this.currentButtonsToShow);
            }else{
                this.currentButtonsToShow = CancelAndSubmit; 
                system.debug('JK2 this.currentButtonsToShow: ' + this.currentButtonsToShow);
            }
        }
        articleViewLines = buildArticleViewLines(selectDataCategory.topCategoryName, subtopic, Userinfo.getLanguage());
        system.debug('JK this.currentButtonsToShow: ' + this.currentButtonsToShow);

        if(selectDataCategory.CategoryName.startsWith('CNS')) {
            String USAid = [SELECT Id, ISO_Code__c, Name FROM IATA_ISO_Country__c WHERE Name = 'United States'].ISO_Code__c;
            this.newCase.IFAP_Country_ISO__c = usaId ;
            this.newCase1.IFAP_Country_ISO__c = usaId ;
        }
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
        String[] childCatList = String.isNotEmpty(childCat) ? new String[] {childCat} : null;   
        //List<String> childCatList = String.isNotEmpty(childCat) ? new List<String> {childCat} : null;
        List<FAQ__kav> articalList = getArticalsByCat(headCat, childCatList);   
        Map<ID, FAQ__kav> artical2ParentIdMap = new Map<ID, FAQ__kav>();
        Map<Id, FAQ__kav> parentIdToMyLanguageArticle_Map = new Map<Id, FAQ__kav>();
        Set<Id> parentVotIdsSet= new Set<Id>();
        
        // Iterating over all articles(for specific category) and creating a map between the articles and their parent's Id
        for(FAQ__kav oneArtical : articalList) 
        {  
            artical2ParentIdMap.put(oneArtical.KnowledgeArticleId, oneArtical); 
        }
        
        // Top 5 articles
        list<FAQ__VoteStat> voteStatList = getArticleVoteStatByIds(artical2ParentIdMap.keySet(), ENV.ArticleChannel.AllChannels);//todo chanel
        
        // Create a set Id with all top 5 articles
        for(FAQ__VoteStat article : voteStatList) 
        {  
            parentVotIdsSet.add(article.ParentId);
        }
        
        // From the Top 5 articles create a list with articles in my language
        List<FAQ__kav> myLanguageArticle_List = [SELECT Id, UrlName, Summary, Title, Language,
         Answer__c , 
         KnowledgeArticleId,
                                                    PublishStatus, ArticleNumber, LastPublishedDate 
                                                    FROM FAQ__kav 
                                                    WHERE KnowledgeArticleId IN :parentVotIdsSet AND Language =: lang AND PublishStatus = 'Online'];
        
        // Create a map with the parent Id of each article in 'myLanguageArticle_List'
        for (FAQ__kav otherlanguageArticle : myLanguageArticle_List) {
            parentIdToMyLanguageArticle_Map.put(otherlanguageArticle.KnowledgeArticleId, otherlanguageArticle);
           
        }

        list<ArticleViewLine> articleViewLines = new list<ArticleViewLine>();
        
        // Iterating over 5 Top voted articles 
        for(FAQ__VoteStat oneVoteStat : voteStatList) 
        {
            FAQ__kav artical = new FAQ__kav();
            
            // If we have the article in other language
            if (parentIdToMyLanguageArticle_Map.containsKey(oneVoteStat.ParentId)){
                artical = parentIdToMyLanguageArticle_Map.get(oneVoteStat.ParentId);
            } 
            else {
                // If we dont have the article in our language then get the article in the english language
                artical = artical2ParentIdMap.get(oneVoteStat.ParentId);
            }
            system.debug('Adding one');
            ArticleViewLine viewLine = new ArticleViewLine(artical, oneVoteStat);
            articleViewLines.add(viewLine);
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

        //Set Origin to be PORTAL
        newCase.Origin = 'Portal'; 


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
                if(SubTopicMatch_Lst != null && SubTopicMatch_Lst.size() > 0)
                {
                    //Check for country match
                    FinalMatch_Lst = RetriveMatchCountrySettings(SubTopicMatch_Lst , userInput_Country);
                }
                else{
                    //Topic + NO SubTopic Match Case
                    //Check for country match
                    if(EmptySubTopicMatch_Lst != null && EmptySubTopicMatch_Lst.size() > 0){
                        FinalMatch_Lst = RetriveMatchCountrySettings(EmptySubTopicMatch_Lst , userInput_Country);
                    }else{
                        FinalMatch_Lst = RetriveMatchCountrySettings(EmptySubTopicAndSubTopicMatch_Lst , userInput_Country); 
                    }
                }
            }
            else{
                //NO Topic Match Case
                //Check for country match
                if(EmptyTopicMatch_Lst != null && EmptyTopicMatch_Lst.size() > 0){
                    FinalMatch_Lst = RetriveMatchCountrySettings(EmptyTopicMatch_Lst , userInput_Country);
                }
            }
        }

        if(FinalMatch_Lst != null && FinalMatch_Lst.size() > 0)
        {
            ChoosenCS = FinalMatch_Lst[0];
            //Select the choosen Record Type
            String recordType = ChoosenCS.RecordType__c;
            List <RecordType> recordTypeList = [SELECT Id FROM RecordType WHERE DeveloperName = :recordType AND sObjectType = 'Case'];

            if (!recordTypeList.isEmpty()){
                //Assign RecordType according to custom Settings
                newCase.RecordTypeId = recordTypeList[0].Id;

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
                )
            {
                fieldRecordWrapper newField = new fieldRecordWrapper(thisField);

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
    }

    //Input : RecordTypeName
    //Output : record Type ID
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
        if(Clicked_SISHelpDesk = true){
            return getCaseRecordTypeIdByName('Cases_SIS_Help_Desk');
        }else if(Clicked_IATAServiceRequest = true){
            return getCaseRecordTypeIdByName('IATA_Service_Request');
        }else if(Clicked_PWCServiceRequest = true){
            return getCaseRecordTypeIdByName('ISS_Portal_PwC');
        }else if(Clicked_DPCServiceRequest = true ){
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

        //Select Custom Setting to set permissions
        List <ISSP_FAQ2Case_Permissions__c> PermissionList = [SELECT Sector_Permission__c, Name ,Topic__c ,SubTopic__c 
                                                            FROM ISSP_FAQ2Case_Permissions__c
                                                            Where Subtopic__c =: null
                                                            AND Topic__c != null
                                                            ];
        system.debug('SFI PermissionList: ' + PermissionList);
        system.debug('SFI PermissionList SIZE: ' + PermissionList.size());

        Boolean isCNS = ISSP_Utilities.isCNS();

        if(PermissionList != null && PermissionList.size() > 0){
            for (SelectOption top : this.lst_selectTopics)
            {
                //set the Topic "English Value"
                string TopicinEnglish = '';
                if (top.getValue() != '-- Select --')
                {
                    clsDataCategory cdc = this.DataCategoryContainer.lst_DataCategories[Integer.valueOf(top.getValue())];
                    TopicinEnglish = ((cdc.CategoryName).replace('__c','')) ;//.replace('_',' ')
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
                        if ((per.Sector_Permission__c != null && per.Sector_Permission__c.contains(Sector) && !isCNS && !per.Sector_Permission__c.startsWith('CNS'))||
                            per.Sector_Permission__c.contains('All') ||
                            (isCNS && per.Sector_Permission__c.startsWith('CNS')))
                        {
                            FoundExcludePermission = true ;
                        }
                    }
                }
                //If topic has permission add it to the display List
                if (!FoundExcludePermission)
                {
                    tmpselectTopicsList.add(top);
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
        List <ISSP_FAQ2Case_Permissions__c> PermissionList = [SELECT Sector_Permission__c, Name ,Topic__c ,SubTopic__c 
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
                    if (per.Subtopic__c != null && per.Subtopic__c.contains(subtopicVal) &&
                        (selectDataCategory.CategoryName == per.topic__c || per.topic__c == null || per.topic__c == ''))
                    {
                        if (per.Sector_Permission__c != null && per.Sector_Permission__c.contains(Sector))
                        {
                            FoundExcludePermission = true ;
                        }
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