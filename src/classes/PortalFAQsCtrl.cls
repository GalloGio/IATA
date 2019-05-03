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

        PortalFAQs__mdt portalFaqCMTD = [SELECT DataCategoryVisibility__c FROM PortalFAQs__mdt WHERE DeveloperName ='TestMetadata' LIMIT 1];

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

        System.debug('____ [cls DescribeDataCategoryGroupStructures - describeDataCategoryGroupStructureResults] subTopicDataCategoryMap - ' + subTopicDataCategoryMap.values());

        return subTopicDataCategoryMap.values();               
    }

    @AuraEnabled(cacheable=true)
    public static List<FAQ__kav> getArticlesFromSubtopic(String selectedParams) {
        String query = 'SELECT Title, Answer__c FROM FAQ__kav WHERE PublishStatus=\'Online\' WITH DATA CATEGORY FAQs__c BELOW ' + selectedParams + ' ORDER BY ArticleTotalViewCount DESC LIMIT 10';
        System.debug('____ [cls DescribeDataCategoryGroupStructures - getArticlesFromSubtopic] query - ' + query);

        List<FAQ__kav> articleList = Database.query(query);
        
        return articleList;
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