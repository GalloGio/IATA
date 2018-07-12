global class ISSP_internal_Case_topic_subtopic {

public list<SelectOption> lst_selectTopics {get;set;}
public list<SelectOption> lst_selectsubTopics {get;set;}
public String topic { get; set; }
public String subtopic { get; set; }
public boolean isEditMode { get; set; }
public String myTopic {get;set;}  

public Case parentCase { get; set; }

public clsDataCategoryContainer DataCategoryContainer {get;set;}

public list<String> errorMessage {get; set;}

    public ISSP_internal_Case_topic_subtopic(ApexPages.StandardController stdController) 
    {     

    }

        public PageReference pageLoad() {
        errorMessage = new list<string>();
                isEditMode = false ;
        ID CaseId = ApexPages.currentPage().getParameters().get('Id');
        //TODO : slecet the case according to the CaseId and get the topic /Subtopic
        List<Case> Case_List = new List<Case>([select Id , Topic__c , SubTopic__c ,Compliment__c ,IFAP_Country_ISO__c , 
                                                      Origin ,BSPCountry__c ,Country_concerned_by_the_query__c ,IsComplaint__c ,
                                                      RecordTypeId , OwnerId , Description 
                                                From Case 
                                                Where id =: CaseId]);
        if (Case_List != null && Case_List.size() > 0)
        {
                parentCase = new Case();
                parentCase = Case_List[0];
        }


        this.lst_selectTopics = new list<SelectOption>();
        this.lst_selectsubTopics = new list<SelectOption>();
        this.lst_selectsubTopics.add(new SelectOption(Env.SelectOptionDefaultValue, Env.SelectOptionDefaultValue));
        this.DataCategoryContainer = new clsDataCategoryContainer();
         

        //Initialize the main page
        initTopicsList();
            return null;
        }


        private void initTopicsList()
        { 
                this.DataCategoryContainer.lst_DataCategories.sort();
			System.debug('basto1p - lst_DataCategories.lst_DataCategories.size='+this.DataCategoryContainer.lst_DataCategories.size());
            System.debug('basto1p - lst_DataCategories.lst_DataCategories='+this.DataCategoryContainer.lst_DataCategories);
                if (parentCase.Topic__c != null && parentCase.Topic__c != ''){
                System.debug('basto1p - NOT NULL parentCase.Topic__c='+parentCase.Topic__c);
                    String tmpTopic = (parentCase.Topic__c).replace(' ' ,'_');
                        for(Integer index = 0; index < this.DataCategoryContainer.lst_DataCategories.size(); index++)
                        {
                                clsDataCategory cdc = this.DataCategoryContainer.lst_DataCategories[index];

                                if (cdc.CategoryName.contains(tmpTopic)){
                                    System.debug('XoYo INNN index '+index);
                                        topic = String.valueOf(index);
                                        this.lst_selectTopics.add(new SelectOption(String.valueOf(index),cdc.CategoryLabel));
                                        this.lst_selectTopics.add(new SelectOption(Env.SelectOptionDefaultValue, Env.SelectOptionDefaultValue));
                                }
                        }
                        for(Integer index = 0; index < this.DataCategoryContainer.lst_DataCategories.size(); index++)
                        {
                                clsDataCategory cdc = this.DataCategoryContainer.lst_DataCategories[index];
                                if (tmpTopic != cdc.CategoryName)
                                        this.lst_selectTopics.add(new SelectOption(String.valueOf(index),cdc.CategoryLabel));
                        }
                        refreshTopicPickList();
                }
                else{
                    System.debug('basto1p - NULL parentCase.Topic__c!');
                        this.lst_selectTopics.add(new SelectOption(Env.SelectOptionDefaultValue, Env.SelectOptionDefaultValue));
                        for(Integer index = 0; index < this.DataCategoryContainer.lst_DataCategories.size(); index++)
                        {
                                clsDataCategory cdc = this.DataCategoryContainer.lst_DataCategories[index];
                                this.lst_selectTopics.add(new SelectOption(String.valueOf(index),cdc.CategoryLabel));
                        }
                }
        }


        public void refreshTopicPickList()
        {   
            system.debug('basto1p refreshTopicPickList.topic='+topic);
            if (topic.compareTo(Env.SelectOptionDefaultValue) == 0)
            {
                this.lst_selectsubTopics = new list<SelectOption>();
                this.lst_selectsubTopics.add(new SelectOption(Env.SelectOptionDefaultValue, Env.SelectOptionDefaultValue));
            }       
            else
            {
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
                }
                else
                {
                    this.lst_selectsubTopics.add(new SelectOption(Env.SelectOptionEmptyValue, Env.SelectOptionEmptyValue));
                    subtopic = selectDataCategory.CategoryName;
                }
            } 
            if (parentCase.SubTopic__c != null && parentCase.SubTopic__c != '')
            {
                refreshSubTopicPickList();
            }
            
        }
        
       public void refreshSubTopicPickList()     {
            Integer index = Integer.valueOf(topic.trim());

            clsDataCategory selectDataCategory = this.DataCategoryContainer.lst_DataCategories[index];
            System.debug('basto1p - index='+index+' parentCase.SubTopic__c='+parentCase.SubTopic__c+'; selectDataCategory.lst_childs.size()='+selectDataCategory.lst_childs.size());
            if (parentCase.SubTopic__c == null || parentCase.SubTopic__c == '')
            {
                //subtopic = selectDataCategory.CategoryName;
            }
            else
            {
                String tmpSubTopic = (parentCase.SubTopic__c).replace(' ' ,'_');
                for(integer cindex = 0; cindex < selectDataCategory.lst_childs.size(); cindex++)
                {
                    clsdatacategory.categorychildwrapper childcat = selectDataCategory.lst_childs[cindex];  
                    system.debug('xoyo childcat.categoryname '+childcat.categoryname);
                    if (childcat.CategoryName.contains(tmpsubtopic))
                    {
                        system.debug('xoyo innn index '+index);
                        subtopic = childcat.CategoryName ;
                    }
                }
            }
        }

        
        public PageReference ChangemodeMethod() {
            if (isEditMode == true)
            {
                    isEditMode = false;
                    return null ;
            }else{
                    isEditMode = true ;
                    this.topic = Env.SelectOptionDefaultValue;
                    refreshTopicPickList();
            return null;
            } 
        }

         

    public PageReference SaveTopicSubtopic(){

        string ErrFields = ''; 
        if(topic == null ||topic == ''||topic == '-- Select --' ) {
            ErrFields += 'Topic ,' ;
        }
        if(subtopic == null ||subtopic == ''||subtopic == '-- Select --'|| subTopic == topic) {
            ErrFields += 'Subtopic ' ;
        }
         
        if(ErrFields != ''){
            errorMessage = new list<string>();
            String errorString = ErrFields+' '+system.Label.ISSP_Should_be_mandatory;
            errorMessage.add(errorString);
            return null;
        }else{
            //set the Topic__c "English Value"
            if (parentCase.Compliment__c == false)
            {
                clsDataCategory cdc = this.DataCategoryContainer.lst_DataCategories[Integer.valueOf(topic)];
                parentCase.Topic__c = ((cdc.CategoryName).replace('__c',' ')).replace('_',' ') ;
                System.debug('Kero11 parentCase.Topic__c - ' + parentCase.Topic__c);
                //set the Topic__c "English Value"

                for(Integer cIndex = 0; cIndex < cdc.lst_childs.size(); cIndex++)
                {
                    clsDataCategory.CategoryChildWrapper childCat = cdc.lst_childs[cIndex];  
                    if(subtopic == childCat.CategoryName)
                    {
                         parentCase.SubTopic__c =  ((childCat.CategoryName).replace('__c',' ')).replace('_',' ') ;
                    }
                }
                System.debug('Kero11 parentCase.SubTopic__c - ' + parentCase.SubTopic__c);
            }else{
                parentCase.Topic__c = 'COMPLIMENT';
                parentCase.SubTopic__c = 'COMPLIMENT';
                this.topic = '0';
            }

            //Set Origin to be PORTAL
            parentCase.Origin = 'Portal'; 


            Integer index = Integer.valueOf(topic.trim());
            clsDataCategory selectDataCategory = this.DataCategoryContainer.lst_DataCategories[index];
            String topicName = selectDataCategory.CategoryName;

            //Holds Final Matched Custom Setting if exists
            List <ISSP_FAQ2Case_Record_Type__c> FinalMatch_Lst = new List<ISSP_FAQ2Case_Record_Type__c>();
            //Represents the best matched Custom Setting
            ISSP_FAQ2Case_Record_Type__c ChoosenCS = new ISSP_FAQ2Case_Record_Type__c();
            //String to be used in the LIKE query 
            string varCountry = '%' + parentCase.IFAP_Country_ISO__c + '%';

            list<IATA_ISO_Country__c> lst_Country = IATAIsoCountryDAO.getIsoCountryByIsoCodes(new Set<String>{parentCase.IFAP_Country_ISO__c});
            
            if(lst_Country != null && lst_Country.size() > 0){
                parentCase.BSPCountry__c =  lst_Country[0].Case_BSP_Country__c ;
                parentCase.Country_concerned_by_the_query__c = lst_Country[0].Case_BSP_Country__c ;
            }

            system.debug('KER0 topicName: ' + topicName);
            system.debug('KER0 subtopic: ' + subtopic);
            system.debug('KER0 parentCase.Compliment__c: ' + parentCase.Compliment__c);
            system.debug('KER0 varCountry: ' + varCountry);

            //select all matched custom settings
            List <ISSP_FAQ2Case_Record_Type__c> csList = [SELECT RecordType__c, OwnerId__c ,Topic__c ,SubTopic__c ,Complaint__c ,Country_concerned_by_the_query__c , 
                                                                 Country_concerned_by_the_query2__c , Country_concerned_by_the_query3__c,
                                                                 Flag_Assignment_Rules__c
                                                                FROM ISSP_FAQ2Case_Record_Type__c
                                                                WHERE 
                                                                Complaint__c = :parentCase.IsComplaint__c
                                                                AND (Topic__c = :topicName
                                                                    OR SubTopic__c = :subtopic
                                                                    OR Country_concerned_by_the_query__c like: varCountry
                                                                    OR Country_concerned_by_the_query2__c like: varCountry
                                                                    OR Country_concerned_by_the_query3__c like: varCountry)];
            system.debug('KER0 csList: ' + csList);


            if(csList != null && csList.size() > 0 ) {
                String userInput_Country = parentCase.IFAP_Country_ISO__c ;
            
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
                system.debug('KER0 TopicMatch_Lst: ' + TopicMatch_Lst);
                //Collect the Topic + subtopic match Custom settings
                if(TopicMatch_Lst != null && TopicMatch_Lst.size() > 0)
                {
                    for(ISSP_FAQ2Case_Record_Type__c tcs : TopicMatch_Lst){
                    system.debug('KER0xo tcs.SubTopic__c: ' + tcs.SubTopic__c);
                    system.debug('KER0xo subtopic: ' + subtopic);
                        if(tcs.SubTopic__c != null && tcs.SubTopic__c.contains(subtopic)){
                            SubTopicMatch_Lst.add(tcs);
                        }
                        if(tcs.SubTopic__c == null || tcs.SubTopic__c == ''){
                            EmptySubTopicMatch_Lst.add(tcs);
                        }
                    }
                    system.debug('KER0 SubTopicMatch_Lst  : ' + SubTopicMatch_Lst);
                    if(SubTopicMatch_Lst != null && SubTopicMatch_Lst.size() > 0)
                    {
                        //Check for country match
                        FinalMatch_Lst = RetriveMatchCountrySettings(SubTopicMatch_Lst , userInput_Country);
                        system.debug('KER0 T + ST _Country matches  : ' + FinalMatch_Lst);
                    }
                    else{
                        //Topic + NO SubTopic Match Case
                        //Check for country match
                        if(EmptySubTopicMatch_Lst != null && EmptySubTopicMatch_Lst.size() > 0){
                            FinalMatch_Lst = RetriveMatchCountrySettings(EmptySubTopicMatch_Lst , userInput_Country);
                            system.debug('KER0 SubTopicMatch_Lst  ELSE: ' + FinalMatch_Lst);
                        }else{
                            FinalMatch_Lst = RetriveMatchCountrySettings(EmptySubTopicAndSubTopicMatch_Lst , userInput_Country); 
                            system.debug('KER0 SubTopicMatch_Lst  ELSE: ' + FinalMatch_Lst);
                        }
                    }
                }
                else{
                    //NO Topic Match Case
                    //Check for country match
                    if(EmptyTopicMatch_Lst != null && EmptyTopicMatch_Lst.size() > 0){
                        FinalMatch_Lst = RetriveMatchCountrySettings(EmptyTopicMatch_Lst , userInput_Country);
                    }
                    system.debug('KER0 TopicMatch_Lst ELSE: ' + FinalMatch_Lst);
                }
            }
            system.debug('KER0xxo FinalMatch_Lst'+FinalMatch_Lst);

            if(FinalMatch_Lst != null && FinalMatch_Lst.size() > 0)
            {
                ChoosenCS = FinalMatch_Lst[0];
                //Select the choosen Record Type
                String recordType = ChoosenCS.RecordType__c;
                Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', recordType);

                if (String.isNotBlank(recordTypeId)){
                    //Assign RecordType according to custom Settings
                    parentCase.RecordTypeId = recordTypeId;
                    system.debug('KER0 parentCase.RecordTypeId'+parentCase.RecordTypeId);
                    system.debug('KER0 ChoosenCS.OwnerId__c'+ChoosenCS.OwnerId__c);

                    //Assign owenerId according to custom Settings
                    if (ChoosenCS.OwnerId__c != null && ChoosenCS.OwnerId__c != ''){
                        parentCase.OwnerId = ChoosenCS.OwnerId__c;
                        system.debug('KER0 parentCase.OwnerId '+parentCase.OwnerId );
                    }
                    

                    addDecsription() ;
                    //TF - Add Flag_Assignment_Rules__c value to Description
                    if (ChoosenCS.Flag_Assignment_Rules__c != null && ChoosenCS.Flag_Assignment_Rules__c != ''){
                        parentCase.Description = parentCase.Description+'\n\n' + ChoosenCS.Flag_Assignment_Rules__c;
                    }
                }
            }

            //Fetching the assignment rules on case
            AssignmentRule AR = new AssignmentRule();
            AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];

            //Creating the DMLOptions for "Assign using active assignment rules" checkbox
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;

            //Setting the DMLOption on Case instance
            parentCase.setOptions(dmlOpts);
            Database.update(parentCase, false);
            return null;
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
            if(CheckCountryMatch(cs.Country_concerned_by_the_query__c , parentCase.IFAP_Country_ISO__c)){
                returnSetting_Lst.add(cs);
            }else{
                if(CheckCountryMatch(cs.Country_concerned_by_the_query2__c , parentCase.IFAP_Country_ISO__c)){
                    returnSetting_Lst.add(cs);
                }
                else{
                        if(CheckCountryMatch(cs.Country_concerned_by_the_query3__c , parentCase.IFAP_Country_ISO__c)){
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


    @TestVisible private void addDecsription() {
        

        String addDecsription ;
        if (parentCase.Compliment__c == false)
        {
             Integer index = Integer.valueOf(topic.trim());
             clsDataCategory selectDataCategory = this.DataCategoryContainer.lst_DataCategories[index];
             addDecsription = Label.ISSP_F2CTopic + ' - ' 
                              + selectDataCategory.CategoryLabel + '\n' 
                              + Label.ISSP_F2CSubTopic + ' - '  
                              + selectDataCategory.getLabelByNameCategory(subtopic); 
        }else {
             addDecsription = Label.ISSP_F2CTopic + ' - ' 
                              + 'COMPLIMENT' + '\n' 
                              + Label.ISSP_F2CSubTopic + ' - '  
                              + 'COMPLIMENT'; 
        }
        parentCase.Description = '';
        parentCase.Description += '\n\n' + addDecsription;
        
        if(parentCase.Compliment__c != null && parentCase.Compliment__c != false)
        {
            parentCase.Description = '\n\n' + parentCase.Description+'\n' +'-COMPLAINT-';
        }
        // compliment ED
        if(parentCase.IsComplaint__c != null && parentCase.IsComplaint__c != false)
        {
            parentCase.Description = '\n\n' + parentCase.Description+'\n' +'-COMPLIMENT-';
        }
        // end compliment
    }


}