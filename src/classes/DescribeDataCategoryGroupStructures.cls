public with sharing class DescribeDataCategoryGroupStructures {

    public static String LANGUAGE = 'en_US';

    /*
    * @description Same as getFaqsStructure method, but here is specific for guest user because we're setting the language
    * @params String lang
    * @return List<FAQCategoryWrapper>
    */
    @AuraEnabled
    public static List<FAQCategoryWrapper> getPublicFaqsStructure(String lang) {
        LANGUAGE = lang;
        
        return getFaqsStructure();
    }

    /*
    * @description Return a FAQ structure based on the user visibility.
    * @description Joining metadata records from Portal FAQs with setup configuration from Data Category Visibility if internal user or just metadata records if guest user
    * @params
    * @return List<FAQCategoryWrapper>
    */
    @AuraEnabled
    public static List<FAQCategoryWrapper> getFaqsStructure() {
        //get matadata list that contains the tree
        List<PortalFAQs__mdt> lstCustomMetadataFaqs = getAllFAQs();

        //if internal user, compare and return a FAQ structure based on what the user is allowed to see.
        //if guest user, just returns a FAQ structure based on metadata records.
        if(!CSP_Utils.isGuestUser()) {
            LANGUAGE = UserInfo.getLanguage();
            User usr = CSP_Utils.getLoggedUser();
            Set<String> setSubtopicsForUser = getUserAccessonFAQs();

            //having the subtopics set, start construct the structure from the subtopics back to the categories
            //the key to this map is a concatenation of the category with topic, because you can have the same topic name in different categories
            Map<String,List<FAQSubtopicWrapper>> mapCategoryNameTopicNameAndLstSubtopics = new Map<String,List<FAQSubtopicWrapper>>();
            List<String> categories = new List<String>();
            //let's process the list of subtopics to get their labels translated
            for(PortalFAQs__mdt faqSubtopicAux : lstCustomMetadataFaqs) {
                //this if filters the metadata that does have all three fields filled: the category, topic and subtopic
                categories = faqSubtopicAux.CategoryExceptions__c != null ? faqSubtopicAux.CategoryExceptions__c.split(';') : new List<String>();
                if((!categories.contains(usr.Contact.Account.Category__c)) && 
                        (faqSubtopicAux.DataCategoryName__c != null && faqSubtopicAux.DataCategoryName__c != '') && 
                        (faqSubtopicAux.DataTopicName__c != null && faqSubtopicAux.DataTopicName__c != '') && 
                        (faqSubtopicAux.DataSubtopicName__c != null && faqSubtopicAux.DataSubtopicName__c != '')) {
                    
                    //concatenate the key to access the map
                    String categoryAndTopicNames = faqSubtopicAux.DataCategoryName__c + '_' + faqSubtopicAux.DataTopicName__c;
                    //if it's a subtopic that the user have access to, inserts it in the map to be returned 
                    if(setSubtopicsForUser.contains(faqSubtopicAux.DataSubtopicName__c)){
                        //if the map does not contain this topic yet, then insert the topic and a new list of subtopics with just this subtopic
                        if(!mapCategoryNameTopicNameAndLstSubtopics.containsKey(categoryAndTopicNames)) {
                            List<FAQSubtopicWrapper> lstAux = new List<FAQSubtopicWrapper>();
                            lstAux.add(new FAQSubtopicWrapper(faqSubtopicAux.DataSubtopicName__c, getFAQLabelWithUserLanguage(LANGUAGE, faqSubtopicAux )));
                            mapCategoryNameTopicNameAndLstSubtopics.put(categoryAndTopicNames, lstAux);
                        } else {
                            //else, insert into the existing map
                            mapCategoryNameTopicNameAndLstSubtopics.get(categoryAndTopicNames).add(new FAQSubtopicWrapper(faqSubtopicAux.DataSubtopicName__c, getFAQLabelWithUserLanguage(LANGUAGE, faqSubtopicAux )));
                        }
                    }
                }
            }

            //final list to return with the already existing wrapper class
            Map<String,List<FAQTopicWrapper>> mapCategoryNameAndLstTopics = new Map<String,List<FAQTopicWrapper>>();
            //now let's process the list of topics from the metadata to get their labels translated
            for(PortalFAQs__mdt faqTopicAux : lstCustomMetadataFaqs) {
                //this if filters the metadata that does have all just the category and topic filled
                categories = faqTopicAux.CategoryExceptions__c != null ? faqTopicAux.CategoryExceptions__c.split(';') : new List<String>();
                if((!categories.contains(usr.Contact.Account.Category__c)) && 
                        (faqTopicAux.DataCategoryName__c != null && faqTopicAux.DataCategoryName__c != '') && 
                        (faqTopicAux.DataTopicName__c != null && faqTopicAux.DataTopicName__c != '') && 
                        (faqTopicAux.DataSubtopicName__c == null || faqTopicAux.DataSubtopicName__c == '')) {

                    //concatenate the key to access the map
                    String categoryAndTopicNames = faqTopicAux.DataCategoryName__c + '_' + faqTopicAux.DataTopicName__c;
                    if(mapCategoryNameTopicNameAndLstSubtopics.containsKey(categoryAndTopicNames)) {
                        //checks if there is already a category in the map
                        if(!mapCategoryNameAndLstTopics.containsKey(faqTopicAux.DataCategoryName__c)) {
                            List<FAQTopicWrapper> lstAux = new List<FAQTopicWrapper>();
                            lstAux.add(new FAQTopicWrapper(faqTopicAux.DataTopicName__c, getFAQLabelWithUserLanguage(LANGUAGE, faqTopicAux ), mapCategoryNameTopicNameAndLstSubtopics.get(categoryAndTopicNames)));
                            mapCategoryNameAndLstTopics.put(faqTopicAux.DataCategoryName__c, lstAux);
                        } else {
                            //else, insert into the existing map
                            mapCategoryNameAndLstTopics.get(faqTopicAux.DataCategoryName__c).add(new FAQTopicWrapper(faqTopicAux.DataTopicName__c, getFAQLabelWithUserLanguage(LANGUAGE, faqTopicAux ), mapCategoryNameTopicNameAndLstSubtopics.get(categoryAndTopicNames)));
                        }
                    }
                }
            }

            //process the list of metadata to get categories labels
            //final list to return with the already existing wrapper class
            List<FAQCategoryWrapper> lstFinalCategories = new List<FAQCategoryWrapper>();
            //now let's process the list of categories from the metadata to get their labels translated
            for(PortalFAQs__mdt faqCategoryAux : lstCustomMetadataFaqs) {
                //this if filters the metadata that does have all just the category
                categories = faqCategoryAux.CategoryExceptions__c != null ? faqCategoryAux.CategoryExceptions__c.split(';') : new List<String>();
                if((!categories.contains(usr.Contact.Account.Category__c)) && 
                    (faqCategoryAux.DataCategoryName__c != null && faqCategoryAux.DataCategoryName__c != '') && 
                        (faqCategoryAux.DataTopicName__c == null || faqCategoryAux.DataTopicName__c == '') && 
                        (faqCategoryAux.DataSubtopicName__c == null || faqCategoryAux.DataSubtopicName__c == '')) {

                    //if the map from the previous iteration contains the category, then process it
                    if(mapCategoryNameAndLstTopics.containsKey(faqCategoryAux.DataCategoryName__c)) {
                        lstFinalCategories.add(new FAQCategoryWrapper(faqCategoryAux.DataCategoryName__c, getFAQLabelWithUserLanguage(LANGUAGE, faqCategoryAux ), mapCategoryNameAndLstTopics.get(faqCategoryAux.DataCategoryName__c)));
                    }
                }
            }

            return lstFinalCategories;
        } else {
            //if guest user, just returns a FAQ structure based on metadata records

            //having the subtopics set, start construct the structure from the subtopics back to the categories
            //the key to this map is a concatenation of the category with topic, because you can have the same topic name in different categories
            Map<String,List<FAQSubtopicWrapper>> mapCategoryNameTopicNameAndLstSubtopics = new Map<String,List<FAQSubtopicWrapper>>();
            List<String> categories = new List<String>();
            //let's process the list of subtopics to get their labels translated
            for(PortalFAQs__mdt faqSubtopicAux : lstCustomMetadataFaqs) {
                //this if filters the metadata that does have all three fields filled: the category, topic and subtopic
                if((faqSubtopicAux.DataCategoryName__c != null && faqSubtopicAux.DataCategoryName__c != '') && 
                        (faqSubtopicAux.DataTopicName__c != null && faqSubtopicAux.DataTopicName__c != '') && 
                        (faqSubtopicAux.DataSubtopicName__c != null && faqSubtopicAux.DataSubtopicName__c != '')) {
                    
                    //concatenate the key to access the map
                    String categoryAndTopicNames = faqSubtopicAux.DataCategoryName__c + '_' + faqSubtopicAux.DataTopicName__c;
                        //if the map does not contain this topic yet, then insert the topic and a new list of subtopics with just this subtopic
                        if(!mapCategoryNameTopicNameAndLstSubtopics.containsKey(categoryAndTopicNames)) {
                            List<FAQSubtopicWrapper> lstAux = new List<FAQSubtopicWrapper>();
                            lstAux.add(new FAQSubtopicWrapper(faqSubtopicAux.DataSubtopicName__c, getFAQLabelWithUserLanguage(LANGUAGE, faqSubtopicAux)));
                            mapCategoryNameTopicNameAndLstSubtopics.put(categoryAndTopicNames, lstAux);
                        } else {
                            //else, insert into the existing map
                            mapCategoryNameTopicNameAndLstSubtopics.get(categoryAndTopicNames).add(new FAQSubtopicWrapper(faqSubtopicAux.DataSubtopicName__c, getFAQLabelWithUserLanguage(LANGUAGE, faqSubtopicAux)));
                        }
                }
            }

            //final list to return with the already existing wrapper class
            Map<String,List<FAQTopicWrapper>> mapCategoryNameAndLstTopics = new Map<String,List<FAQTopicWrapper>>();
            //now let's process the list of topics from the metadata to get their labels translated
            for(PortalFAQs__mdt faqTopicAux : lstCustomMetadataFaqs) {
                //this if filters the metadata that does have all just the category and topic filled
                if((faqTopicAux.DataCategoryName__c != null && faqTopicAux.DataCategoryName__c != '') && 
                        (faqTopicAux.DataTopicName__c != null && faqTopicAux.DataTopicName__c != '') && 
                        (faqTopicAux.DataSubtopicName__c == null || faqTopicAux.DataSubtopicName__c == '')) {

                    //concatenate the key to access the map
                    String categoryAndTopicNames = faqTopicAux.DataCategoryName__c + '_' + faqTopicAux.DataTopicName__c;
                    if(mapCategoryNameTopicNameAndLstSubtopics.containsKey(categoryAndTopicNames)) {
                        //checks if there is already a category in the map
                        if(!mapCategoryNameAndLstTopics.containsKey(faqTopicAux.DataCategoryName__c)) {
                            List<FAQTopicWrapper> lstAux = new List<FAQTopicWrapper>();
                            lstAux.add(new FAQTopicWrapper(faqTopicAux.DataTopicName__c, getFAQLabelWithUserLanguage(LANGUAGE, faqTopicAux), mapCategoryNameTopicNameAndLstSubtopics.get(categoryAndTopicNames)));
                            mapCategoryNameAndLstTopics.put(faqTopicAux.DataCategoryName__c, lstAux);
                        } else {
                            //else, insert into the existing map
                            mapCategoryNameAndLstTopics.get(faqTopicAux.DataCategoryName__c).add(new FAQTopicWrapper(faqTopicAux.DataTopicName__c, getFAQLabelWithUserLanguage(LANGUAGE, faqTopicAux), mapCategoryNameTopicNameAndLstSubtopics.get(categoryAndTopicNames)));
                        }
                    }
                }
            }

            //process the list of metadata to get categories labels
            //final list to return with the already existing wrapper class
            List<FAQCategoryWrapper> lstFinalCategories = new List<FAQCategoryWrapper>();
            //now let's process the list of categories from the metadata to get their labels translated
            for(PortalFAQs__mdt faqCategoryAux : lstCustomMetadataFaqs) {
                //this if filters the metadata that does have all just the category
                if((faqCategoryAux.DataCategoryName__c != null && faqCategoryAux.DataCategoryName__c != '') && 
                        (faqCategoryAux.DataTopicName__c == null || faqCategoryAux.DataTopicName__c == '') && 
                        (faqCategoryAux.DataSubtopicName__c == null || faqCategoryAux.DataSubtopicName__c == '')) {

                    //if the map from the previous iteration contains the category, then process it
                    if(mapCategoryNameAndLstTopics.containsKey(faqCategoryAux.DataCategoryName__c)) {
                        lstFinalCategories.add(new FAQCategoryWrapper(faqCategoryAux.DataCategoryName__c, getFAQLabelWithUserLanguage(LANGUAGE, faqCategoryAux), mapCategoryNameAndLstTopics.get(faqCategoryAux.DataCategoryName__c)));
                    }
                }
            }

            return lstFinalCategories;
        }
    }

    /*
    * @description Get only subtopics level from user access to the FAQs Data Category Setup based on Data Category Visibility from Role, Profile and/or Permission Sets
    * @params
    * @return List<PortalFAQs__mdt>
    */
    private static Set<String> getUserAccessonFAQs() {
        //Get the structure that the user have access to
        List<DescribeDataCategoryGroupStructureResult> categoryGroups = getUserFaqsDescribeDataCategoryGroupStructureResult();
        
        if(!categoryGroups.isEmpty()) {
            List<DataCategory> lstUserAccess = categoryGroups.get(0).getTopCategories();

            //Get all the subtopics
            Set<String> setSubtopicsForUser = new Set<String>();

            for(DataCategory firstLevel : lstUserAccess) {
                System.debug(LoggingLevel.FINE, '[cls DescribeDataCategoryGroupStructures - getFaqsStructure] firstLevel - ' + firstLevel.getName());
                if(firstLevel.getChildCategories().isEmpty()) {
                    //if it's empty then it's a subtopic and we have to add to our subtopics set
                    setSubtopicsForUser.add(firstLevel.name);
                } else {
                    //not a subtopic, continue in the category tree
                    for(DataCategory secondLevel : firstLevel.getChildCategories()) {
                        System.debug(LoggingLevel.FINE, '[cls DescribeDataCategoryGroupStructures - getFaqsStructure] secondLevel - ' + secondLevel.getName());
                        if(secondLevel.getChildCategories().isEmpty()) {
                            //if it's empty then it's a subtopic and we have to add to our subtopics set
                            setSubtopicsForUser.add(secondLevel.name);
                        } else {
                            //not a subtopic, continue in the category tree
                            for(DataCategory thirdLevel : secondLevel.getChildCategories()) {
                                System.debug(LoggingLevel.FINE, '[cls DescribeDataCategoryGroupStructures - getFaqsStructure] thirdLevel - ' + thirdLevel.getName());
                                if(thirdLevel.getChildCategories().isEmpty()){
                                    //if it's empty then it's a subtopic and we have to add to our subtopics set
                                    setSubtopicsForUser.add(thirdLevel.name);
                                } else {
                                    //not a subtopic, continue in the category tree
                                    for(DataCategory forthLevel : thirdLevel.getChildCategories()) {
                                        System.debug(LoggingLevel.FINE, '[cls DescribeDataCategoryGroupStructures - getFaqsStructure] forthLevel - ' + forthLevel.getName());
                                        if(forthLevel.getChildCategories().isEmpty()) {
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

            return setSubtopicsForUser;
        } else {
            return new Set<String>();
        }
    }

    public static List<FAQCategoryWrapper> getFAQDataCategorySetupStructure(){
        List<FAQCategoryWrapper> lstToReturn = new List<FAQCategoryWrapper>();

        //Get the structure that the user have access to
        List<DescribeDataCategoryGroupStructureResult> categoryGroups = getUserFaqsDescribeDataCategoryGroupStructureResult();

        if(!categoryGroups.isEmpty()) {
            List<DataCategory> lstUserAccess = categoryGroups.get(0).getTopCategories();

            //if the user have access to 'all' iterate three times as the first one will give just the all metadata, else iterate twice as the 
            // first iteration already gives the categories
            if(lstUserAccess.get(0).name == 'All'){
                for(DataCategory firstLevel : lstUserAccess) {
                    if(!firstLevel.getChildCategories().isEmpty()) {
                        for(DataCategory secondLevel : firstLevel.getChildCategories()) {
                            //get the categories
                            FAQCategoryWrapper faqCategoryWrapperAux = new FAQCategoryWrapper();
                            faqCategoryWrapperAux.categoryName = secondLevel.getName();
                            faqCategoryWrapperAux.categoryLabel = secondLevel.getLabel();
                            faqCategoryWrapperAux.lstTopics = new List<FAQTopicWrapper>();

                            if(!secondLevel.getChildCategories().isEmpty()) {
                                //get topics
                                for(DataCategory thirdLevel : secondLevel.getChildCategories()) {
                                    FAQTopicWrapper faqtopicWrapperAux = new FAQTopicWrapper();
                                    faqtopicWrapperAux.topicName = thirdLevel.getName();
                                    faqtopicWrapperAux.topicLabel = thirdLevel.getLabel();
                                    faqtopicWrapperAux.lstSubtopics = new List<FAQSubtopicWrapper>();
                                    
                                    if(!thirdLevel.getChildCategories().isEmpty()) {
                                        for(DataCategory forthLevel : thirdLevel.getChildCategories()){
                                            FAQSubtopicWrapper faqsubtopicWrapperAux = new FAQSubtopicWrapper();
                                            faqsubtopicWrapperAux.subtopicName = forthLevel.getName();
                                            faqsubtopicWrapperAux.subtopicLabel = forthLevel.getLabel();
                                            faqtopicWrapperAux.lstSubtopics.add(faqsubtopicWrapperAux);
                                        }
                                    }


                                    faqCategoryWrapperAux.lstTopics.add(faqtopicWrapperAux);
                                }
                            }
                            lstToReturn.add(faqCategoryWrapperAux);
                        }
                    }
                }
            }else{
                for(DataCategory firstLevel : lstUserAccess) {
                    //get the categories
                    FAQCategoryWrapper faqCategoryWrapperAux = new FAQCategoryWrapper();
                    faqCategoryWrapperAux.categoryName = firstLevel.getName();
                    faqCategoryWrapperAux.categoryLabel = firstLevel.getLabel();
                    faqCategoryWrapperAux.lstTopics = new List<FAQTopicWrapper>();

                    if(!firstLevel.getChildCategories().isEmpty()) {
                        for(DataCategory secondLevel : firstLevel.getChildCategories()) {
                            FAQTopicWrapper faqtopicWrapperAux = new FAQTopicWrapper();
                            faqtopicWrapperAux.topicName = secondLevel.getName();
                            faqtopicWrapperAux.topicLabel = secondLevel.getLabel();
                            faqtopicWrapperAux.lstSubtopics = new List<FAQSubtopicWrapper>();

                            if(!secondLevel.getChildCategories().isEmpty()) {
                                for(DataCategory thirdLevel : secondLevel.getChildCategories()){
                                    FAQSubtopicWrapper faqsubtopicWrapperAux = new FAQSubtopicWrapper();
                                    faqsubtopicWrapperAux.subtopicName = thirdLevel.getName();
                                    faqsubtopicWrapperAux.subtopicLabel = thirdLevel.getLabel();
                                    faqtopicWrapperAux.lstSubtopics.add(faqsubtopicWrapperAux);
                                }
                            }

                            faqCategoryWrapperAux.lstTopics.add(faqtopicWrapperAux);
                        }
                    }
                    lstToReturn.add(faqCategoryWrapperAux);
                }
            }
        }
        return lstToReturn;
    }

    /*
    * @description Get all records flagged with FAQsStructure from Portal FAQs Custom Metadata Type
    * @params
    * @return List<PortalFAQs__mdt>
    */
    @AuraEnabled
    public static List<PortalFAQs__mdt> getAllFAQs() {
        return [SELECT DataCategoryName__c, DataTopicName__c, DataSubtopicName__c, CategoryExceptions__c, 
                    SectorExceptions__c, DataCategoryLabel_en_US__c, DataCategoryLabel_ar__c, DataCategoryLabel_de__c, 
                    DataCategoryLabel_es__c, DataCategoryLabel_fr__c, DataCategoryLabel_in__c, DataCategoryLabel_it__c, 
                    DataCategoryLabel_ja__c, DataCategoryLabel_ko__c, DataCategoryLabel_pt_BR__c, DataCategoryLabel_ru__c, 
                    DataCategoryLabel_th__c, DataCategoryLabel_TR__c, DataCategoryLabel_vi__c, DataCategoryLabel_zh_CN__c,
                    Order__c,DeveloperName, MasterLabel, Label  
                FROM PortalFAQs__mdt WHERE FAQsStructure__c = true ORDER BY Order__c ASC NULLS LAST];
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

    /*
        Returns the label for the requested level, give the structure
        @levelName -> can be 'category', 'topic', 'subtopic'
    */
    public static String getLabelFromDescribe(String catName, String topName, String subTopName, String levelName, List<DescribeDataCategoryGroupStructures.FAQCategoryWrapper> lstDescribeWrapper ){
        String labelStr = '';
        
        if(levelName == 'category'){
            for(DescribeDataCategoryGroupStructures.FAQCategoryWrapper categoryWrapperAux : lstDescribeWrapper){
                if(categoryWrapperAux.categoryName == catName){
                    labelStr = categoryWrapperAux.categoryLabel;
                    break;
                }
            }
        }
        if(levelName == 'topic'){
            for(DescribeDataCategoryGroupStructures.FAQCategoryWrapper categoryWrapperAux : lstDescribeWrapper){
                for(DescribeDataCategoryGroupStructures.FAQTopicWrapper topicWrapperAux : categoryWrapperAux.lstTopics){
                    if(topicWrapperAux.topicName == topName){
                        labelStr = topicWrapperAux.topicLabel;
                        break;
                    }
                }
            }
        }
        if(levelName == 'subtopic'){
            for(DescribeDataCategoryGroupStructures.FAQCategoryWrapper categoryWrapperAux : lstDescribeWrapper){
                for(DescribeDataCategoryGroupStructures.FAQTopicWrapper topicWrapperAux : categoryWrapperAux.lstTopics){
                    for(DescribeDataCategoryGroupStructures.FAQSubtopicWrapper subtopicWrapperAux : topicWrapperAux.lstSubtopics){
                        if(subtopicWrapperAux.subtopicName == subTopName){
                            labelStr = subtopicWrapperAux.subtopicLabel;
                            break;
                        }
                    }
                }
            }
        }

        return labelStr;
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

        public FAQCategoryWrapper(String categoryName, String categoryLabel, List<FAQTopicWrapper> lstTopics){
            this.categoryName = categoryName;
            this.categoryLabel = categoryLabel;
            this.lstTopics = lstTopics;
        }
    }

    public class FAQTopicWrapper{
        @AuraEnabled
        public String topicName {get;set;}
        @AuraEnabled
        public String topicLabel {get;set;}
        @AuraEnabled
        public List<FAQSubtopicWrapper> lstSubtopics {get;set;}

        public FAQTopicWrapper(){}

        public FAQTopicWrapper(String topicName, String topicLabel, List<FAQSubtopicWrapper> lstSubtopics){
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
