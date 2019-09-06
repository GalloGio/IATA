public with sharing class PortalFAQsCtrl {

    public static Integer RESULTS_PER_PAGE = 10;

    public static PortalFAQs__mdt portalFaqCMTD{
        get{            
            if(portalFaqCMTD==null){
                if(!Test.isRunningTest()){
                    portalFaqCMTD=[SELECT DataCategoryVisibility__c FROM PortalFAQs__mdt WHERE DeveloperName ='PortalFAQs' LIMIT 1];
                }else{
                    portalFaqCMTD=new  PortalFAQs__mdt(DataCategoryVisibility__c='[{"topicName":"Accreditation_Travel_Agent","topicLabel":"Accreditation Travel Agent","childs":{"IATA ID Card":"ID_Card","Irregularities & Defaults":"PAX_Irregularities_Defaults"}}]');
                }
            }
            return portalFaqCMTD;
        }
        set;
    } 

    @AuraEnabled(cacheable=true)    
    public static List<DescribeDataCategoryGroupStructures.DataCategoryWrapper> getCategoryTiles() {
        List<DescribeDataCategoryGroupStructures.DataCategoryWrapper> lstOriginal = PortalFAQsCtrl.getFAQsInfo();

        List<DescribeDataCategoryGroupStructures.DataCategoryWrapper> lstAux = new List<DescribeDataCategoryGroupStructures.DataCategoryWrapper>();
        
        for(DescribeDataCategoryGroupStructures.DataCategoryWrapper globalWrapperAux : lstOriginal){

            Boolean found = false;

            for(DescribeDataCategoryGroupStructures.DataCategoryWrapper wrapperAux : lstAux){
                if(wrapperAux.categoryName == globalWrapperAux.categoryName){
                    found = true;
                    break;
                }
            }

            if(!found){
                if(globalWrapperAux.categoryName != 'All'){
                    lstAux.add(globalWrapperAux);
                }
            }


        }



        return lstAux;               
    }

    @AuraEnabled(cacheable=true)    
    public static List<DescribeDataCategoryGroupStructures.DataCategoryWrapper> getFAQsInfo() {
        List<DescribeDataCategoryGroupStructures.DataCategoryWrapper> userAccess = DescribeDataCategoryGroupStructures.describeDataCategoryGroupStructureResults();

        
        List<DescribeDataCategoryGroupStructures.DataCategoryWrapper> faqList = (List<DescribeDataCategoryGroupStructures.DataCategoryWrapper>) JSON.deserialize(portalFaqCMTD.DataCategoryVisibility__c, List<DescribeDataCategoryGroupStructures.DataCategoryWrapper>.class);

        Set<String> hasTopicAccess = new Set<String>();
        for(DescribeDataCategoryGroupStructures.DataCategoryWrapper dctw2 : userAccess) {
            for(String st : dctw2.childs.keySet()) {
                hasTopicAccess.add(dctw2.childs.get(st));
            }
        }

        Map<String, DescribeDataCategoryGroupStructures.DataCategoryWrapper> subTopicDataCategoryMap = new Map<String, DescribeDataCategoryGroupStructures.DataCategoryWrapper>();
        for(DescribeDataCategoryGroupStructures.DataCategoryWrapper dcwTopic : faqList) {
            if(!dcwTopic.childs.keySet().isEmpty()) {
                for(String dcwSubTopic : dcwTopic.childs.keySet()) {
                    if(hasTopicAccess.contains(dcwTopic.childs.get(dcwSubTopic))) {
                        if(!subTopicDataCategoryMap.containsKey(dcwTopic.topicName)) {
                            subTopicDataCategoryMap.put(dcwTopic.topicName, new DescribeDataCategoryGroupStructures.DataCategoryWrapper(dcwTopic.topicName, dcwTopic.topicLabel, dcwTopic.categoryName, dcwTopic.categoryLabel, new Map<String, String>()));
                        }

                        subTopicDataCategoryMap.get(dcwTopic.topicName).childs.put(dcwSubTopic, dcwTopic.childs.get(dcwSubTopic));
                    }
                }
            }
        }

        System.debug(LoggingLevel.FINE, '____ [cls PortalFAQsCtrl - getFAQsInfo] subTopicDataCategoryMap - ' + subTopicDataCategoryMap.values());

        return subTopicDataCategoryMap.values();               
    }

    @AuraEnabled(cacheable=true)
    public static List<FAQ__kav> getArticles(String selectedParams) {
        String query = 'SELECT Id, ArticleNumber, Title, Answer__c FROM FAQ__kav WHERE PublishStatus=\'Online\' WITH DATA CATEGORY FAQs__c BELOW ' + String.escapeSingleQuotes(selectedParams) + ' ORDER BY ArticleTotalViewCount DESC LIMIT 15';
        System.debug(LoggingLevel.FINE, '____ [cls PortalFAQsCtrl - getArticles] query - ' + query);

        return Database.query(query);
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

        List<FAQ__kav> lstToReturn = new List<FAQ__kav>();
        //Create an empty default return object
        PagedResult result = new PagedResult();
        result.records = lstToReturn;
        result.totalItemCount = 0;

        if(filtersWrapper != null && filtersWrapper.searchText != null && filtersWrapper.searchText != '') {

            List<String> subtopics = new List<String>();
            if(filtersWrapper.faqsComponent == null || filtersWrapper.faqsComponent.faqSubtopicsList == null || filtersWrapper.faqsComponent.faqSubtopicsList.isEmpty()){
                List<DescribeDataCategoryGroupStructures.DataCategoryWrapper> lstStructure = PortalFAQsCtrl.getFAQsInfo();
                if(lstStructure != null && !lstStructure.isEmpty()){
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

            String levels = '(' + String.join(subtopics,' , ') + ' ) ';
            
            String queryPartOne = 'FIND \'' + String.escapeSingleQuotes(filtersWrapper.searchText) + '\' IN ALL FIELDS '+
                           'RETURNING FAQ__kav(Id, ArticleNumber, Title, Answer__c WHERE PublishStatus = \'online\' ';
            String queryPartTwo = ' ) WITH DATA CATEGORY FAQs__c BELOW ' + levels ;


            //Since SOSL don't have count, the first requested page is queried to all records
            //and then the count is retrived from the returned results list. For the next pages
            //limit and offset is used to improve loading times. 
            if(requestedPageAux == 0){
                String finalQuery = queryPartOne + queryPartTwo;
                List<List<SObject>> searchList = Search.query(finalQuery);
                List<FAQ__kav> tmpList = (List<FAQ__kav>)searchList[0];

                for(Integer i = 0; i<tmpList.size() && i < PortalFAQsCtrl.RESULTS_PER_PAGE; i++){
                    lstToReturn.add(tmpList.get(i));
                }
                
                result.records = lstToReturn;
                result.totalItemCount = tmpList.size();
            }else{
                Integer offset = requestedPageAux * PortalFAQsCtrl.RESULTS_PER_PAGE;
                String offsetQuery = ' LIMIT ' + PortalFAQsCtrl.RESULTS_PER_PAGE + ' OFFSET ' + offset + ' ';

                String finalQuery = queryPartOne + offsetQuery + queryPartTwo;

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

}