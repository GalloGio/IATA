public with sharing class DescribeDataCategoryGroupStructures {
    
    public static List<DataCategoryWrapper> describeDataCategoryGroupStructureResults() {
        List<DescribeDataCategoryGroupResult> describeCategoryResult;
        List<DescribeDataCategoryGroupStructureResult> describeCategoryStructureResult;

        //Making the call to the describeDataCategoryGroups to get the list of category groups associated
        List<String> objType = new List<String>();
        objType.add('KnowledgeArticleVersion');
        describeCategoryResult = Schema.describeDataCategoryGroups(objType);
        
        System.debug('____ [cls DescribeDataCategoryGroupStructures - describeDataCategoryGroupStructureResults] describeCategoryResult - ' + describeCategoryResult);

        //Creating a list of pair objects to use as a parameter for the describe call
        List<DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
        
        //Looping throught the first describe result to create the list of pairs for the second describe call
        for(DescribeDataCategoryGroupResult singleResult : describeCategoryResult) {
            DataCategoryGroupSobjectTypePair p = new DataCategoryGroupSobjectTypePair();
            p.setSobject(singleResult.getSobject());
            p.setDataCategoryGroupName(singleResult.getName());
            pairs.add(p);
        }
        //From the returned map, get the category group name and sObject name
        System.debug('____ [cls DescribeDataCategoryGroupStructures - describeDataCategoryGroupStructureResults] pairs - ' + pairs);

        //Returns the categories available for the object in the category group specified
        describeCategoryStructureResult = Schema.describeDataCategoryGroupStructures(pairs, false);
        System.debug(LoggingLevel.FINE, '____ [cls DescribeDataCategoryGroupStructures - describeDataCategoryGroupStructureResults] describeCategoryStructureResult - ' + describeCategoryStructureResult);

        List<DataCategoryWrapper> lst_DataCategories = new List<DataCategoryWrapper>();
        for(DescribeDataCategoryGroupStructureResult oneResult : describeCategoryStructureResult) {
            System.debug(LoggingLevel.FINE, '[cls DescribeDataCategoryGroupStructures - describeDataCategoryGroupStructureResults] oneResult - ' + oneResult.getName());
            List<DataCategory> topCat2Group = oneResult.getTopCategories();

            for(DataCategory oneCat : topCat2Group) {
                System.debug(LoggingLevel.FINE, '[cls DescribeDataCategoryGroupStructures - describeDataCategoryGroupStructureResults] oneCat - ' + oneCat.getName());
                List<DataCategory> childCategories = oneCat.getChildCategories();

                if(!childCategories.isEmpty()) {
                    Map<String, String> mapChildCategories = new Map<String, String>();
                    for(DataCategory oneChildCat : childCategories) {
                        System.debug(LoggingLevel.FINE, '[cls DescribeDataCategoryGroupStructures - describeDataCategoryGroupStructureResults] oneChildCat - ' + oneChildCat.getName());
                        List<DataCategory> childCategories2ndLevel = oneChildCat.getChildCategories();

                        if(!childCategories2ndLevel.isEmpty()) {
                            Map<String, String> mapChildCategories2ndLevel = new Map<String, String>();
                            for(DataCategory oneChildCateg: childCategories2ndLevel) {
                                System.debug(LoggingLevel.FINE, '[cls DescribeDataCategoryGroupStructures - describeDataCategoryGroupStructureResults] oneChildCateg - ' + oneChildCateg.getName());
                                    List<DataCategory> childCategories3ndLevel = oneChildCateg.getChildCategories();

                                    if(!childCategories3ndLevel.isEmpty()) {
                                        Map<String, String> mapChildCategories3ndLevel = new Map<String, String>();
                                        for(DataCategory oneChildCategory : childCategories3ndLevel) {
                                            mapChildCategories3ndLevel.put(oneChildCategory.getLabel(), oneChildCategory.getName());
                                        }
                                        lst_DataCategories.add(createDataCategory(oneChildCateg.getName(), oneChildCateg.getLabel(), oneChildCat.getName(), oneChildCat.getLabel(), mapChildCategories3ndLevel));
                                    } else {
                                        mapChildCategories2ndLevel.put(oneChildCateg.getLabel(), oneChildCateg.getName());
                                    }
                            }

                            if(!mapChildCategories2ndLevel.isEmpty()) {
                                lst_DataCategories.add(createDataCategory(oneChildCat.getName(), oneChildCat.getLabel(), oneCat.getName(), oneCat.getLabel(), mapChildCategories2ndLevel));
                            }  
                        } else {
                            mapChildCategories.put(oneChildCat.getLabel(), oneChildCat.getName());                            
                        }
                    }

                    if(!mapChildCategories.isEmpty()) {
                        lst_DataCategories.add(createDataCategory(oneCat.getName(), oneCat.getLabel(), oneCat.getName(), oneCat.getLabel(), mapChildCategories));
                    }                    
                } else {
                    lst_DataCategories.add(createDataCategory(null, null, null, null, new Map<string,string>{oneCat.getLabel() => oneCat.getName()}));             
                }
            }       
        }
        
        System.debug(LoggingLevel.FINE, '____ [cls DescribeDataCategoryGroupStructures - describeDataCategoryGroupStructureResults] lst_DataCategories - ' + lst_DataCategories);

        return lst_DataCategories;
    }

    private static DataCategoryWrapper createDataCategory(String topicName, String topicLabel, String categoryName, String categoryLabel, Map<String, String> childs) {
        return new DataCategoryWrapper(
            topicName, 
            topicLabel, 
            categoryName,
            categoryLabel,
            childs
        );
    }

    public class DataCategoryWrapper {
        @AuraEnabled
        public String topicName {get;set;}
        @AuraEnabled
        public String topicLabel {get;set;} 
        @AuraEnabled
        public String categoryName {get;set;}
        @AuraEnabled
        public String categoryLabel {get;set;}
        @AuraEnabled
        public Map<String, String> childs {get;set;}

        public DataCategoryWrapper(String topicName, String topicLabel, String categoryName, String categoryLabel, Map<String, String> childs) {
            this.topicName = topicName;
            this.topicLabel = topicLabel;
            this.categoryName = categoryName;
            this.categoryLabel = categoryLabel;
            this.childs = childs;
        }                
    }
}