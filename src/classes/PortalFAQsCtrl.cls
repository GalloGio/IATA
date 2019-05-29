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
        String query = 'FIND \'' + String.escapeSingleQuotes(searchTerm) + '\' IN ALL FIELDS RETURNING FAQ__kav(Id, ArticleNumber, Title, Answer__c WHERE PublishStatus = \'online\' LIMIT 6 OFFSET 1)';
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

    @AuraEnabled(cacheable=true)
    public static String randomUUID() {
        String kHexChars = '0123456789abcdefABCDEF';
        String returnValue = '';
        Integer nextByte = 0;
        for(Integer i = 0; i < 16; i++){
            if(i==4 || i==6 || i==8 || i==10){
                returnValue += '-';
            }
            //generate a "byte"; i.e., number in range [-2^7,2^7-1]
            nextByte = (Math.round(Math.random() * 255)-128) & 255;

            if(i==6){
                nextByte = nextByte & 15;
                nextByte = nextByte | (4 << 4);
            }
            if(i==8){
                nextByte = nextByte & 63;
                nextByte = nextByte | 128;
            }

            returnValue += charAt(kHexChars,nextByte >> 4);
            returnValue += charAt(kHexChars,nextByte & 15);
        }
        return returnValue;
    }

    private static String charAt(String str, Integer index) {
        if(str == null){
            return null;
        }
        if(str.length() <= 0){
            return str;
        }
        if(index < 0 || index >= str.length()){
            return null;
        }
        return str.substring(index, index+1);
    }

    /*
        This method is used for CS Portal searchbar. 
        @refinedSearchSerialized - is a serialized filter object sent from the LWC controller for further filtering 
    */
    @AuraEnabled (cacheable=true)
    public static List<KnowledgeArticleVersion> getFaqsList(String refinedSearchSerialized){
        //User userAux = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        //String contactId = userAux.ContactId;

        System.debug('refinedSearchSerialized: ' + refinedSearchSerialized);
        FilteringObject refinedSearch = null;
        if(refinedSearchSerialized != null && refinedSearchSerialized != ''){
            refinedSearch = (FilteringObject) JSON.deserialize(refinedSearchSerialized, FilteringObject.class);
        }
        System.debug('refinedSearch: ' + refinedSearch);

        //base query 
        String finalQuery = 'SELECT Id, UrlName, Title, Summary, LastPublishedDate ' + 
                            'FROM KnowledgeArticleVersion ' +
                            'WHERE PublishStatus= \'Online\' ';

        //Add the clauses for further filtering 
        if(refinedSearch != null ){
            finalQuery += ' AND (Title LIKE \'%' + refinedSearch.searchText + '%\' OR Summary LIKE \'%' + refinedSearch.searchText + '%\' )';
        }

        finalQuery += ' LIMIT 10 ';

        System.debug('finalQuery: ' + finalQuery);

        List<KnowledgeArticleVersion> lstArticles = Database.query(finalQuery);

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