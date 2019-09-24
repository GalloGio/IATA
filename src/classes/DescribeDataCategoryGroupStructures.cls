public with sharing class DescribeDataCategoryGroupStructures {

    @AuraEnabled
    public static List<DescribeDataCategoryGroupStructures.FAQCategoryWrapper> getFaqsStructure(){

        //Get the structure that the user have access to
        List<DataCategory> lstUserAccess = getUserFaqsDescribeDataCategoryGroupStructureResult().get(0).getTopCategories();

        //Get all the subtopics
        Set<String> setSubtopicsForUser = new Set<String>();
        if(lstUserAccess != null && !lstUserAccess.isEmpty()){
            for(DataCategory firstLevel : lstUserAccess){
                System.debug(LoggingLevel.FINE, '[cls DescribeDataCategoryGroupStructures - getFaqsStructure] firstLevel - ' + firstLevel.getName());
                if(firstLevel.getChildCategories().isEmpty()){
                    //if it's empty then it's a subtopic and we have to add to our subtopics set
                    setSubtopicsForUser.add(firstLevel.name);
                }else{
                    //not a subtopic, continue in the category tree
                    for(DataCategory secondLevel : firstLevel.getChildCategories()){
                        System.debug(LoggingLevel.FINE, '[cls DescribeDataCategoryGroupStructures - getFaqsStructure] secondLevel - ' + secondLevel.getName());
                        if(secondLevel.getChildCategories().isEmpty()){
                            //if it's empty then it's a subtopic and we have to add to our subtopics set
                            setSubtopicsForUser.add(secondLevel.name);
                        }else{
                            //not a subtopic, continue in the category tree
                            for(DataCategory thirdLevel : secondLevel.getChildCategories()){
                                System.debug(LoggingLevel.FINE, '[cls DescribeDataCategoryGroupStructures - getFaqsStructure] thirdLevel - ' + thirdLevel.getName());
                                if(thirdLevel.getChildCategories().isEmpty()){
                                    //if it's empty then it's a subtopic and we have to add to our subtopics set
                                    setSubtopicsForUser.add(thirdLevel.name);
                                }else{
                                    //not a subtopic, continue in the category tree
                                    for(DataCategory forthLevel : thirdLevel.getChildCategories()){
                                        System.debug(LoggingLevel.FINE, '[cls DescribeDataCategoryGroupStructures - getFaqsStructure] forthLevel - ' + forthLevel.getName());
                                        if(forthLevel.getChildCategories().isEmpty()){
                                            //if it's empty then it's a subtopic and we have to add to our subtopics set
                                            setSubtopicsForUser.add(forthLevel.name);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        //get the user language for returning the approppriate language
        String userLanguage = UserInfo.getLanguage();
        User usr = CSP_Utils.getLoggedUser();
        
        //get the matadata list that contains the tree
        List<PortalFAQs__mdt> lstCustomMetadataFaqs = [SELECT DataCategoryName__c,DataTopicName__c,DataSubtopicName__c,CategoryExceptions__c,
                                SectorExceptions__c,DataCategoryLabel_en_US__c,DataCategoryLabel_ar__c,DataCategoryLabel_de__c,
                                DataCategoryLabel_es__c,DataCategoryLabel_fr__c,DataCategoryLabel_in__c,DataCategoryLabel_it__c,
                                DataCategoryLabel_ja__c,DataCategoryLabel_ko__c,DataCategoryLabel_pt_BR__c,DataCategoryLabel_ru__c,
                                DataCategoryLabel_th__c,DataCategoryLabel_TR__c,DataCategoryLabel_vi__c,DataCategoryLabel_zh_CN__c,
                    			Order__c 
                				FROM PortalFAQs__mdt WHERE FAQsStructure__c = true ORDER BY Order__c ASC NULLS LAST];


        //having the subtopics set, start construct the structure from the subtopics back to the categories
        //the key to this map is a concatenation of the category with topic, because you can have the same topic name in different categories
        Map<String,List<DescribeDataCategoryGroupStructures.FAQSubtopicWrapper>> mapCategoryNameTopicNameAndLstSubtopics = new Map<String,List<DescribeDataCategoryGroupStructures.FAQSubtopicWrapper>>();
        List<String> categories = new List<String>();

        //let's process the list of subtopics to get their labels translated
        for(PortalFAQs__mdt faqSubtopicAux : lstCustomMetadataFaqs){

            //this if filters the metadata that does have all three fields filled: the category, topic and subtopic
            categories = faqSubtopicAux.CategoryExceptions__c != null ? faqSubtopicAux.CategoryExceptions__c.split(';') : new List<String>();
            if((!categories.contains(usr.Contact.Account.Category__c)) && 
                    (faqSubtopicAux.DataCategoryName__c != null && faqSubtopicAux.DataCategoryName__c != '') && 
                    (faqSubtopicAux.DataTopicName__c != null && faqSubtopicAux.DataTopicName__c != '') && 
                    (faqSubtopicAux.DataSubtopicName__c != null && faqSubtopicAux.DataSubtopicName__c != '')){
                
                //concatenate the key to access the map
                String categoryAndTopicNames = faqSubtopicAux.DataCategoryName__c + '_' + faqSubtopicAux.DataTopicName__c;


                //if it's a subtopic that the user have access to, inserts it in the map to be returned 
                if(setSubtopicsForUser.contains(faqSubtopicAux.DataSubtopicName__c)){
                    
                    //if the map does not contain this topic yet, then insert the topic and a new list of subtopics with just this subtopic
                    if(!mapCategoryNameTopicNameAndLstSubtopics.containsKey(categoryAndTopicNames)){
                        
                        List<DescribeDataCategoryGroupStructures.FAQSubtopicWrapper> lstAux = new List<DescribeDataCategoryGroupStructures.FAQSubtopicWrapper>();
                        lstAux.add(new DescribeDataCategoryGroupStructures.FAQSubtopicWrapper(faqSubtopicAux.DataSubtopicName__c, getFAQLabelWithUserLanguage(userLanguage, faqSubtopicAux ), getFAQLabelWithUserLanguage('en_US', faqSubtopicAux )));
                        mapCategoryNameTopicNameAndLstSubtopics.put(categoryAndTopicNames, lstAux);

                    }else{
                        //else, insert into the existing map
                        mapCategoryNameTopicNameAndLstSubtopics.get(categoryAndTopicNames).add(new DescribeDataCategoryGroupStructures.FAQSubtopicWrapper(faqSubtopicAux.DataSubtopicName__c, getFAQLabelWithUserLanguage(userLanguage, faqSubtopicAux ), getFAQLabelWithUserLanguage('en_US', faqSubtopicAux )));
                    }
                }
            }
        }

        //final list to return with the already existing wrapper class
        Map<String,List<DescribeDataCategoryGroupStructures.FAQTopicWrapper>> mapCategoryNameAndLstTopics = new Map<String,List<DescribeDataCategoryGroupStructures.FAQTopicWrapper>>();

        //now let's process the list of topics from the metadata to get their labels translated
        for(PortalFAQs__mdt faqTopicAux : lstCustomMetadataFaqs){

            //this if filters the metadata that does have all just the category and topic filled
            categories = faqTopicAux.CategoryExceptions__c != null ? faqTopicAux.CategoryExceptions__c.split(';') : new List<String>();
            if((!categories.contains(usr.Contact.Account.Category__c)) && 
                    (faqTopicAux.DataCategoryName__c != null && faqTopicAux.DataCategoryName__c != '') && 
                    (faqTopicAux.DataTopicName__c != null && faqTopicAux.DataTopicName__c != '') && 
                    (faqTopicAux.DataSubtopicName__c == null || faqTopicAux.DataSubtopicName__c == '')){

                //concatenate the key to access the map
                String categoryAndTopicNames = faqTopicAux.DataCategoryName__c + '_' + faqTopicAux.DataTopicName__c;

                if(mapCategoryNameTopicNameAndLstSubtopics.containsKey(categoryAndTopicNames)){

                    //checks if there is already a category in the map
                    if(!mapCategoryNameAndLstTopics.containsKey(faqTopicAux.DataCategoryName__c)){
                        
                        List<DescribeDataCategoryGroupStructures.FAQTopicWrapper> lstAux = new List<DescribeDataCategoryGroupStructures.FAQTopicWrapper>();
                        lstAux.add(new DescribeDataCategoryGroupStructures.FAQTopicWrapper(faqTopicAux.DataTopicName__c, getFAQLabelWithUserLanguage(userLanguage, faqTopicAux ), getFAQLabelWithUserLanguage('en_US', faqTopicAux ),  mapCategoryNameTopicNameAndLstSubtopics.get(categoryAndTopicNames)));
                        mapCategoryNameAndLstTopics.put(faqTopicAux.DataCategoryName__c, lstAux);

                    }else{
                        //else, insert into the existing map
                        mapCategoryNameAndLstTopics.get(faqTopicAux.DataCategoryName__c).add(new DescribeDataCategoryGroupStructures.FAQTopicWrapper(faqTopicAux.DataTopicName__c, getFAQLabelWithUserLanguage(userLanguage, faqTopicAux ), getFAQLabelWithUserLanguage('en_US', faqTopicAux ), mapCategoryNameTopicNameAndLstSubtopics.get(categoryAndTopicNames)));
                    }

                }

            }

        }

        //process the list of metadata to get categories labels
        //final list to return with the already existing wrapper class
        List<DescribeDataCategoryGroupStructures.FAQCategoryWrapper> lstFinalCategories = new List<DescribeDataCategoryGroupStructures.FAQCategoryWrapper>();

        //now let's process the list of categories from the metadata to get their labels translated
        for(PortalFAQs__mdt faqCategoryAux : lstCustomMetadataFaqs){

            //this if filters the metadata that does have all just the category
            categories = faqCategoryAux.CategoryExceptions__c != null ? faqCategoryAux.CategoryExceptions__c.split(';') : new List<String>();
            if((!categories.contains(usr.Contact.Account.Category__c)) && 
                (faqCategoryAux.DataCategoryName__c != null && faqCategoryAux.DataCategoryName__c != '') && 
                    (faqCategoryAux.DataTopicName__c == null || faqCategoryAux.DataTopicName__c == '') && 
                    (faqCategoryAux.DataSubtopicName__c == null || faqCategoryAux.DataSubtopicName__c == '')){

                //if the map from the previous iteration contains the category, then process it
                if(mapCategoryNameAndLstTopics.containsKey(faqCategoryAux.DataCategoryName__c)){

                    lstFinalCategories.add(new DescribeDataCategoryGroupStructures.FAQCategoryWrapper(faqCategoryAux.DataCategoryName__c, getFAQLabelWithUserLanguage(userLanguage, faqCategoryAux ), getFAQLabelWithUserLanguage('en_US', faqCategoryAux ), mapCategoryNameAndLstTopics.get(faqCategoryAux.DataCategoryName__c)));

                }
            }
        }

        return lstFinalCategories;
    }

    /*
    * @description Get user access to the FAQs Data Category Setup based on Data Category Visibility from Role, Profile and/or Permission Sets
    * @params
    * @return List<DescribeDataCategoryGroupStructureResult>
    */
    public static List<DescribeDataCategoryGroupStructureResult> getUserFaqsDescribeDataCategoryGroupStructureResult(){
        List<DescribeDataCategoryGroupResult> describeCategoryResult;
        List<DescribeDataCategoryGroupStructureResult> describeCategoryStructureResult;
        //Making the call to the describeDataCategoryGroups to get the list of category groups associated
        List<String> objType = new List<String>();
        objType.add('KnowledgeArticleVersion');
        describeCategoryResult = Schema.describeDataCategoryGroups(objType);

        //Creating a list of pair objects to use as a parameter for the describe call
        List<DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
        
        //Looping throught the first describe result to create the list of pairs for the second describe call
        for(DescribeDataCategoryGroupResult singleResult : describeCategoryResult) {
            DataCategoryGroupSobjectTypePair p = new DataCategoryGroupSobjectTypePair();
            p.setSobject(singleResult.getSobject());
            p.setDataCategoryGroupName(singleResult.getName());
            pairs.add(p);
        }

        //Returns the categories available for the object in the category group specified
        describeCategoryStructureResult = Schema.describeDataCategoryGroupStructures(pairs, false);

        return describeCategoryStructureResult;
    }

    private static String getFAQLabelWithUserLanguage(String userLanguage, PortalFAQs__mdt faqMetaAux){
        //fallback to default label if user language was not found
        String defaultLabel = faqMetaAux.DataCategoryLabel_en_US__c;

        SObject faqObject = faqMetaAux;
        String dataCatLanguage = (String) faqObject.get('DataCategoryLabel_' + userLanguage + '__c');

        if(String.isNotBlank(dataCatLanguage)){
            defaultLabel = dataCatLanguage;
        }

        return defaultLabel;
    }

    public class DataCategoryWrapper {
        @AuraEnabled
        public String topicName {get;set;}
        @AuraEnabled
        public String topicLabel {get;set;} 
        @AuraEnabled
        public String topicLabelEn {get;set;} 
        @AuraEnabled
        public String categoryName {get;set;}
        @AuraEnabled
        public String categoryLabel {get;set;}
        @AuraEnabled
        public String categoryLabelEn {get;set;}
        @AuraEnabled
        public Map<String, String> childs {get;set;}
        @AuraEnabled
        public Map<String, String> childsEn {get; set;}

        public DataCategoryWrapper(String topicName, String topicLabel,String topicLabelEn, String categoryName, String categoryLabel, String categoryLabelEn, Map<String, String> childs, Map<String, String> childsEn) {
            this.topicName = topicName;
            this.topicLabel = topicLabel;
            this.topicLabelEn = topicLabelEn;
            this.categoryName = categoryName;
            this.categoryLabel = categoryLabel;
            this.categoryLabelEn = categoryLabelEn;
            this.childs = childs;
            this.childsEn = childsEn;
        }                
    }

    public class FAQCategoryWrapper{
        @AuraEnabled
        public String categoryName {get;set;}
        @AuraEnabled
        public String categoryLabel {get;set;}
        @AuraEnabled
        public String categoryLabelEn {get; set;}
        @AuraEnabled
        public List<DescribeDataCategoryGroupStructures.FAQTopicWrapper> lstTopics {get;set;}

        public FAQCategoryWrapper(){}

        public FAQCategoryWrapper(String categoryName, String categoryLabel, String categoryLabelEn, List<DescribeDataCategoryGroupStructures.FAQTopicWrapper> lstTopics){
            this.categoryName = categoryName;
            this.categoryLabel = categoryLabel;
            this.categoryLabelEn = categoryLabelEn;
            this.lstTopics = lstTopics;
        }
    }

    public class FAQTopicWrapper{
        @AuraEnabled
        public String topicName {get;set;}
        @AuraEnabled
        public String topicLabel {get;set;}
        @AuraEnabled
        public String topicLabelEn {get;set;}
        @AuraEnabled
        public List<DescribeDataCategoryGroupStructures.FAQSubtopicWrapper> lstSubtopics {get;set;}

        public FAQTopicWrapper(){}

        public FAQTopicWrapper(String topicName, String topicLabel, String topicLabelEn, List<DescribeDataCategoryGroupStructures.FAQSubtopicWrapper> lstSubtopics){
            this.topicName = topicName;
            this.topicLabel = topicLabel;
            this.topicLabelEn = topicLabelEn;
            this.lstSubtopics = lstSubtopics;
        }
    }

    public class FAQSubtopicWrapper{
        @AuraEnabled
        public String subtopicName {get;set;}
        @AuraEnabled
        public String subtopicLabel {get;set;}
        @AuraEnabled
        public String subtopicLabelEn {get;set;}

        public FAQSubtopicWrapper(){}

        public FAQSubtopicWrapper(String subtopicName, String subtopicLabel, String subtopicLabelEn){
            this.subtopicName = subtopicName;
            this.subtopicLabel = subtopicLabel;
            this.subtopicLabelEn = subtopicLabelEn;
        }
    }



}