public with sharing class PortalFAQsCtrl {

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

        PortalFAQs__mdt portalFaqCMTD = [SELECT DataCategoryVisibility__c FROM PortalFAQs__mdt WHERE DeveloperName ='PortalFAQs' LIMIT 1];

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
    public static List<FAQ__kav> getSearchArticles(String searchTerm) {
        String query = 'FIND \'' + String.escapeSingleQuotes(searchTerm) + '\' IN ALL FIELDS RETURNING FAQ__kav(Id, ArticleNumber, Title, Answer__c WHERE PublishStatus = \'online\' LIMIT 5 OFFSET 1)';
        System.debug(LoggingLevel.FINE, '____ [cls PortalFAQsCtrl - getSearchArticles] query - ' + query);

        List<List<SObject>> searchList = Search.query(query);
        List<FAQ__kav> kavs = (List<FAQ__kav>)searchList[0];

        return kavs;
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
    public static List<FAQ__kav> getFaqsList(String refinedSearchSerialized, Boolean moreFields){
        //User userAux = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        //String contactId = userAux.ContactId;

        System.debug('refinedSearchSerialized: ' + refinedSearchSerialized);
        FilteringObject refinedSearch = null;
        if(refinedSearchSerialized != null && refinedSearchSerialized != ''){
            refinedSearch = (FilteringObject) JSON.deserialize(refinedSearchSerialized, FilteringObject.class);
        }
        System.debug('refinedSearch: ' + refinedSearch);

        //base query 
        String finalQuery = 'SELECT Title';

        if(moreFields) finalQuery += ', ArticleNumber, Answer__c';

        finalQuery += ' FROM FAQ__kav WHERE PublishStatus= \'Online\' ';

        //Add the clauses for further filtering 
        if(refinedSearch != null ){
            finalQuery += ' AND (Title LIKE \'%' + refinedSearch.searchText + '%\' OR Summary LIKE \'%' + refinedSearch.searchText + '%\' )';
        }

        finalQuery += ' LIMIT 10 ';

        System.debug('finalQuery: ' + finalQuery);

        List<FAQ__kav> lstArticles = Database.query(finalQuery);

        System.debug('lstArticles: ' + lstArticles);

        return lstArticles;
    }



    /*
        Classes for the search filtering 
    
    */

    public class FilteringObject {

        @AuraEnabled
        public String searchText {get; set;}

        //the rest of the filters should be here too

        public FilteringObject(){}


    }



}