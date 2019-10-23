public with sharing class PortalFAQsCtrl {

    public static Integer RESULTS_PER_PAGE = 10;
    public static String LANGUAGE;

    /*
    * @description Return a FAQ structure based on the user visibility.
    * @description Joining metadata records from Portal FAQs with setup configuration from Data Category Visibility if internal user or just metadata records if guest user
    * @params
    * @return List<DescribeDataCategoryGroupStructures.DataCategoryWrapper>
    */
    @AuraEnabled(cacheable=true)    
    public static List<DescribeDataCategoryGroupStructures.DataCategoryWrapper> getFAQsInfo() {
        return convertStructure(DescribeDataCategoryGroupStructures.getFaqsStructure());               
    }

    /*
    * @description Same as getFAQsInfo method, but here is specific for guest user because we're setting the language
    * @params String lang
    * @return List<FAQCategoryWrapper>
    */
    @AuraEnabled(cacheable=true)    
    public static List<DescribeDataCategoryGroupStructures.DataCategoryWrapper> getFAQsInfoByLanguage(String lang) {
        return convertStructure(DescribeDataCategoryGroupStructures.getPublicFaqsStructure(lang));               
    }

    @AuraEnabled(cacheable=false)
    public static void updateMetadata(String strNewMetadata){
        List<MetadataWrapper> lstNewMetadata =  (List<MetadataWrapper>)JSON.deserialize(strNewMetadata , List<MetadataWrapper>.class);

        List<PortalFAQs__mdt> lstCurrentMetadata = DescribeDataCategoryGroupStructures.getAllFAQs();
        List<DescribeDataCategoryGroupStructures.FAQCategoryWrapper> lstFAQsStructure = DescribeDataCategoryGroupStructures.getFAQDataCategorySetupStructure();
        String userLanguage = UserInfo.getLanguage();

        List<CustomMetadataCallback.CustomMetadataType> customMetadataToUpsert = new List<CustomMetadataCallback.CustomMetadataType>();

        for(MetadataWrapper metaAux : lstNewMetadata){
            PortalFAQs__mdt metaFound = null;

            for(PortalFAQs__mdt currentMetaAux : lstCurrentMetadata){                
                if( (String.isNotBlank(metaAux.categoryName) && String.isBlank(metaAux.topicName) && String.isBlank(metaAux.subtopicName) && currentMetaAux.DataCategoryName__c == metaAux.categoryName) ||
                    (String.isNotBlank(metaAux.categoryName) && String.isNotBlank(metaAux.topicName) && String.isBlank(metaAux.subtopicName) && currentMetaAux.DataCategoryName__c == metaAux.categoryName && currentMetaAux.DataTopicName__c == metaAux.topicName) || 
                    (String.isNotBlank(metaAux.categoryName) && String.isNotBlank(metaAux.topicName) && String.isNotBlank(metaAux.subtopicName) && currentMetaAux.DataCategoryName__c == metaAux.categoryName && currentMetaAux.DataTopicName__c == metaAux.topicName && currentMetaAux.DataSubtopicName__c == metaAux.subtopicName)
                ){
                    metaFound = currentMetaAux; 
                    break;
                }
            }


            if(metaFound != null){
                // update just the order and active fields, because the other are the same
                CustomMetadataCallback.CustomMetadataType cmdtDT = new CustomMetadataCallback.CustomMetadataType(); 
                cmdtDT.strMDTAndRecord = 'PortalFAQs__mdt.' + metaFound.DeveloperName;
                cmdtDT.strMasterLabel = metaFound.MasterLabel;
                cmdtDT.fieldLIST = new List<String>{ 'Order__c', 'Active__c'};
                cmdtDT.valueLIST = new List<Object>{ Integer.valueof(metaAux.order), true};
                customMetadataToUpsert.add(cmdtDT);
            }else{
                //insert new meta
                
                //new category
                if(String.isNotBlank(metaAux.categoryName) && String.isBlank(metaAux.topicName) && String.isBlank(metaAux.subtopicName)){
                    
                    String hashBase64SHA1 = EncodingUtil.convertToHex(Crypto.generateDigest('SHA1',Blob.valueOf(metaAux.categoryName)));
                    String label = DescribeDataCategoryGroupStructures.getLabelFromDescribe('' + metaAux.categoryName, null, null, 'category', lstFAQsStructure );

                    CustomMetadataCallback.CustomMetadataType cmdtDT = new CustomMetadataCallback.CustomMetadataType(); 
                    cmdtDT.strMDTAndRecord = 'PortalFAQs__mdt.' + 'x' + hashBase64SHA1.substring(0,34);
                    cmdtDT.strMasterLabel = '' + 'x' + hashBase64SHA1.substring(0,34);
                    cmdtDT.fieldLIST = new List<String>{'DataCategoryName__c', 'FAQsStructure__c', 'Order__c', 'Active__c', 'DataCategoryLabel_'+ userLanguage + '__c'};
                    cmdtDT.valueLIST = new List<Object>{'' + metaAux.categoryName, true, Integer.valueof(metaAux.order), true, '' + label};
                    customMetadataToUpsert.add(cmdtDT);

                }

                //new topic
                if(String.isNotBlank(metaAux.categoryName) && String.isNotBlank(metaAux.topicName) && String.isBlank(metaAux.subtopicName)){
                    
                    String hashBase64SHA1 = EncodingUtil.convertToHex(Crypto.generateDigest('SHA1', Blob.valueOf(metaAux.categoryName + metaAux.topicName)));
                    String label = DescribeDataCategoryGroupStructures.getLabelFromDescribe('' + metaAux.categoryName, '' + metaAux.topicName, null, 'topic', lstFAQsStructure );

                    CustomMetadataCallback.CustomMetadataType cmdtDT = new CustomMetadataCallback.CustomMetadataType(); 
                    cmdtDT.strMDTAndRecord = 'PortalFAQs__mdt.' + 'x' + hashBase64SHA1.substring(0,34);
                    cmdtDT.strMasterLabel = '' + 'x' + hashBase64SHA1.substring(0,34);
                    cmdtDT.fieldLIST = new List<String>{'DataCategoryName__c', 'DataTopicName__c', 'FAQsStructure__c', 'Order__c', 'Active__c', 'DataCategoryLabel_'+ userLanguage + '__c'};
                    cmdtDT.valueLIST = new List<Object>{'' + metaAux.categoryName, '' + metaAux.topicName, true, Integer.valueof(metaAux.order), true, '' + label};
                    customMetadataToUpsert.add(cmdtDT);

                }

                //new subtopic
                if(String.isNotBlank(metaAux.categoryName) && String.isNotBlank(metaAux.topicName) && String.isNotBlank(metaAux.subtopicName)){
                    
                    String hashBase64SHA1 = EncodingUtil.convertToHex(Crypto.generateDigest('SHA1',Blob.valueOf(metaAux.categoryName + metaAux.topicName + metaAux.subtopicName)));
                    String label = DescribeDataCategoryGroupStructures.getLabelFromDescribe('' + metaAux.categoryName, '' + metaAux.topicName, '' + metaAux.subtopicName, 'subtopic', lstFAQsStructure );

                    CustomMetadataCallback.CustomMetadataType cmdtDT = new CustomMetadataCallback.CustomMetadataType(); 
                    cmdtDT.strMDTAndRecord = 'PortalFAQs__mdt.' + 'x' + hashBase64SHA1.substring(0,34);
                    cmdtDT.strMasterLabel = '' + 'x' + hashBase64SHA1.substring(0,34);
                    cmdtDT.fieldLIST = new List<String>{'DataCategoryName__c', 'DataTopicName__c', 'DataSubtopicName__c', 'FAQsStructure__c', 'Order__c', 'Active__c', 'DataCategoryLabel_'+ userLanguage + '__c'};
                    cmdtDT.valueLIST = new List<Object>{'' + metaAux.categoryName, '' + metaAux.topicName,'' + metaAux.subtopicName, true, Integer.valueof(metaAux.order), true, '' + label};
                    customMetadataToUpsert.add(cmdtDT);

                }


            }
        }

        CustomMetadataCallback.Upsert_MDT_Value(customMetadataToUpsert);
    }

    public class MetadataWrapper{
        @AuraEnabled
        public String categoryName {get; set;}
        @AuraEnabled
        public String topicName {get; set;}
        @AuraEnabled
        public String subtopicName {get; set;}
        @AuraEnabled
        public String order {get; set;}

        public MetadataWrapper(){}

    }

    private static List<DescribeDataCategoryGroupStructures.DataCategoryWrapper> convertStructure(List<DescribeDataCategoryGroupStructures.FAQCategoryWrapper> lstToConvert){
        List<DescribeDataCategoryGroupStructures.DataCategoryWrapper> lstToReturn = new List<DescribeDataCategoryGroupStructures.DataCategoryWrapper>();

        for(DescribeDataCategoryGroupStructures.FAQCategoryWrapper categoryAux : lstToConvert){
            for(DescribeDataCategoryGroupStructures.FAQTopicWrapper topicAux : categoryAux.lstTopics){
                Map<String,String> mapSubtopics = new Map<String,String>();
                Map<String,String> mapSubtopicsEn = new Map<String,String>();
                for(DescribeDataCategoryGroupStructures.FAQSubtopicWrapper subtopicAux : topicAux.lstSubtopics){
                    mapSubtopics.put(subtopicAux.subtopicLabel, subtopicAux.subtopicName);
                    mapSubtopicsEn.put(subtopicAux.subtopicName, subtopicAux.subtopicLabelEn);
                }

                lstToReturn.add(new DescribeDataCategoryGroupStructures.DataCategoryWrapper(topicAux.topicName, topicAux.topicLabel, topicAux.topicLabelEn,
                                                                                            categoryAux.categoryName, categoryAux.categoryLabel, categoryAux.categoryLabelEn,
                                                                                            mapSubtopics, mapSubtopicsEn));
            }
        }

        return lstToReturn;
    }

    @AuraEnabled
    public static List<FAQ__kav> getArticlesByLanguage(String selectedParams, String lang) {
        LANGUAGE = lang;
        
        return getArticlesWithParam(selectedParams, 15);
    }

    @AuraEnabled(cacheable=true)
    public static List<FAQ__kav> getArticles(String selectedParams) {
        return getArticlesWithParam(selectedParams, 15);
    }

    @AuraEnabled(cacheable=true)
    public static List<FAQ__kav> getArticlesWithParam(String selectedParams, Integer limitParam) {
        String queryOne = 'SELECT Id, ArticleNumber, Title, Answer__c FROM FAQ__kav WHERE PublishStatus=\'Online\'';
        String queryTwo = String.isNotBlank(LANGUAGE) ? ' AND Language = \'' + LANGUAGE + '\'' : '';
        String queryThree = ' WITH DATA CATEGORY FAQs__c BELOW ' + String.escapeSingleQuotes(selectedParams) + ' ORDER BY ArticleTotalViewCount DESC LIMIT ' + limitParam;
        
        String finalQuery = queryOne + queryTwo + queryThree;
        System.debug(LoggingLevel.FINE, '____ [cls PortalFAQsCtrl - getArticles] finalQuery - ' + finalQuery);

        return Database.query(finalQuery);
    }

    @AuraEnabled(cacheable=true)
    public static List<PKB_Article_Feedback_Deflection__c> getArticlesFeedback(String articleIds, String sessionCookie) {
        String query = 'SELECT Article_ID__c, Article_Title__c, Deflection__c FROM PKB_Article_Feedback_Deflection__c WHERE Session_ID__c = \'' + String.escapeSingleQuotes(sessionCookie) + '\' AND Article_ID__c IN ' + articleIds;
        System.debug(LoggingLevel.FINE, '____ [cls PortalFAQsCtrl - getArticlesFeedback] query - ' + query); 

        return Database.query(query);
    }

    @AuraEnabled(cacheable=true)
    public static String getArticleTitle(String articleId) {
        return [SELECT Title FROM FAQ__kav WHERE Id = :articleId].Title;
    }

    @AuraEnabled
    public static void createFeedback(String articleId, String articleNumber, String articleTitle, String feedbackSource, String feedbackComments, String sessionId, Boolean isDeferred) {
        // validate that the feedback source option is a valid option
        Set<String> feedbackSourceOptions = pkb_Controller.getActivePicklistOptions('PKB_Article_Feedback_Deflection__c', 'Feedback_Source__c').keySet();

        String fs = (feedbackSourceOptions.contains(feedbackSource) ? feedbackSource : null);

        PKB_Article_Feedback_Deflection__c articleFeedback = new PKB_Article_Feedback_Deflection__c(
            Article_ID__c = articleId,
            Article_Number__c = articleNumber,
            Article_Title__c = articleTitle,
            Feedback_Source__c = fs,
            Comments__c = feedbackComments != null ? feedbackComments : '',
            Session_ID__c = sessionId,
            Deflection__c = isDeferred
        );

        insert articleFeedback;
    }

    /*
        This method is used for CS Portal searchbar. 
        @refinedSearchSerialized - is a serialized filter object sent from the LWC controller for further filtering 
    */
    @AuraEnabled (cacheable=true)
    public static PagedResult getFilteredFAQsResultsPage(String searchKey, String requestedPage){
        PortalSearchFilterWrapper filtersWrapper = (PortalSearchFilterWrapper) JSON.deserialize(searchKey, PortalSearchFilterWrapper.class);
        Integer requestedPageAux = integer.valueof(requestedPage);
        System.debug(LoggingLevel.FINE, '[cls PortalFAQsCtrl - getFilteredFAQsResultsPage] filtersWrapper - ' + filtersWrapper);
        List<FAQ__kav> lstToReturn = new List<FAQ__kav>();
        //Create an empty default return object
        PagedResult result = new PagedResult();
        result.records = lstToReturn;
        result.totalItemCount = 0;

        if(filtersWrapper != null && filtersWrapper.searchText != null && filtersWrapper.searchText != '') {

            List<String> subtopics = new List<String>();
            if(filtersWrapper.faqsComponent == null || filtersWrapper.faqsComponent.faqSubtopicsList == null || filtersWrapper.faqsComponent.faqSubtopicsList.isEmpty()){
                List<DescribeDataCategoryGroupStructures.DataCategoryWrapper> lstStructure = new List<DescribeDataCategoryGroupStructures.DataCategoryWrapper>();
                //Get FAQ structure based on the user visibility
                if(String.isNotBlank(filtersWrapper.language)) {
                    lstStructure = PortalFAQsCtrl.getFAQsInfoByLanguage(filtersWrapper.language);
                } else {
                    lstStructure = PortalFAQsCtrl.getFAQsInfo();
                }

                if(!lstStructure.isEmpty()) {
                    for(DescribeDataCategoryGroupStructures.DataCategoryWrapper category : lstStructure){
                        if(category.categoryName != 'All'){
                            for(String subtopicAux : category.childs.values()){
                                subtopics.add(subtopicAux+'__c');
                            }
                        }
                    }
                }
            }
            else{
                for(String subtopicAux : filtersWrapper.faqsComponent.faqSubtopicsList){
                    subtopics.add(subtopicAux + '__c');
                }
            }

            String levels = '';
            if(!subtopics.isEmpty()) levels = '(' + String.join(subtopics,' , ') + ' ) ';
            
            String queryPartOne = 'FIND \'' + String.escapeSingleQuotes(filtersWrapper.searchText) + '\' IN ALL FIELDS '+
                           'RETURNING FAQ__kav(Id, ArticleNumber, Title, Answer__c WHERE PublishStatus = \'online\'';
            String queryLanguage = filtersWrapper.guestUser != null && filtersWrapper.guestUser ? ' AND Language = \'' + filtersWrapper.language + '\'' : '';
            String queryPartTwo = ' WITH DATA CATEGORY FAQs__c BELOW ' + levels ;


            //Since SOSL don't have count, the first requested page is queried to all records
            //and then the count is retrived from the returned results list. For the next pages
            //limit and offset is used to improve loading times. 
            if(requestedPageAux == 0){
                String finalQuery;
                if(String.isNotBlank(queryLanguage)) {
                    finalQuery = queryPartOne + queryLanguage + ')';
                } else {
                    finalQuery = queryPartOne + ')';
                }
                if(String.isNotBlank(levels)) finalQuery += queryPartTwo;

                System.debug(LoggingLevel.FINE, '[cls PortalFAQsCtrl - getFilteredFAQsResultsPage] finalQuery - ' + finalQuery);
                List<List<SObject>> searchList = Search.query(finalQuery);
                List<FAQ__kav> tmpList = (List<FAQ__kav>)searchList[0];

                for(Integer i = 0; i<tmpList.size() && i < PortalFAQsCtrl.RESULTS_PER_PAGE; i++){
                    lstToReturn.add(tmpList.get(i));
                }
                
                result.records = lstToReturn;
                result.totalItemCount = tmpList.size();
            }else{
                Integer offset = requestedPageAux * PortalFAQsCtrl.RESULTS_PER_PAGE;
                String offsetQuery = ' LIMIT ' + PortalFAQsCtrl.RESULTS_PER_PAGE + ' OFFSET ' + offset + ')';

                String finalQuery = queryPartOne + offsetQuery;
                if(String.isNotBlank(queryPartTwo)) finalQuery += queryPartTwo;
                
				System.debug(LoggingLevel.FINE, '[cls PortalFAQsCtrl - getFilteredFAQsResultsPage] finalQuery - ' + finalQuery);
                List<List<SObject>> searchList = Search.query(finalQuery);
                List<FAQ__kav> tmpList = (List<FAQ__kav>)searchList[0];
                result.records = tmpList;
            }
            
        }
        
        return result;
    }

    public class PagedResult {
        @AuraEnabled
        public Integer totalItemCount { get;set; }        
        @AuraEnabled
        public SObject[] records { get;set; }
    }
    @AuraEnabled
    public static ApexMessageHandling updateArticleCategories(List<Id> articleTypeIds) {
        List<FAQ__kav> lstArticleType =
            [SELECT Id, Categories__c
            FROM FAQ__kav
            WHERE Id IN:articleTypeIds AND PublishStatus = 'Draft' AND ValidationStatus != 'Pending publication'];

        if(!lstArticleType.isEmpty()) {
            List<FAQ__DataCategorySelection> lstDC =
                [SELECT ParentId, DataCategoryName
                FROM FAQ__DataCategorySelection
                WHERE ParentId IN:articleTypeIds];

            Map<Id, String> datacategoryNameMap = new Map<Id, String>();
            String str;
            for(FAQ__DataCategorySelection dcObj:lstDC) {
                if(datacategoryNameMap.containsKey(dcObj.ParentId)) {
                    str = datacategoryNameMap.get(dcObj.ParentId);
                    datacategoryNameMap.put(dcObj.ParentId, str + ',' + dcObj.DataCategoryName);
                }
                else {
                    datacategoryNameMap.put(dcObj.ParentId, dcObj.DataCategoryName);
                }
            }

            for(FAQ__kav artObj:lstArticleType) {
                if(datacategoryNameMap.containsKey(artObj.Id)) {
                    artObj.Categories__c = datacategoryNameMap.get(artObj.Id);
                }
            }

            try {
                update lstArticleType;
                return new ApexMessageHandling();
            } catch(DmlException e) {
                return new ApexMessageHandling(false, e.getMessage());
            }   
        } else {
            return new ApexMessageHandling(false, Label.CSP_PendingApproval);
        }
    }

    @AuraEnabled
    public static void submitArticleForApproval(String approvalNameOrId, Id recordId, Id userId, String comments) {
        AMS_OSCAR_ApprovalHelper.submit(approvalNameOrId, recordId, userId, comments);
    }
}