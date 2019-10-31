public with sharing class clsDataCategoryContainer {
	
	public list<clsDataCategory> lst_DataCategories {get;set;}

	/**
	 * [clsDataCategoryContainer description]
	 * @return [description]
	 */
	public clsDataCategoryContainer() {

		this.lst_DataCategories = new list<clsDataCategory>();
	
		list<DescribeDataCategoryGroupResult> describeCategoryResult = new list<DescribeDataCategoryGroupResult>();
	    list<DescribeDataCategoryGroupStructureResult> describeCategoryStructureResult;
	
	    //list<DataCategory> set_TopDataCategories      = new list<DataCategory>();
	    list<DataCategoryGroupSobjectTypePair> pairs = new list<DataCategoryGroupSobjectTypePair>();
	
	    //Creating the list of sobjects to use for the describe 
		list<String> objType = new list<String>{'KnowledgeArticleVersion','Question'};
		//list<String> objType = new list<String>{'FAQ__kav','Question'};

         //Describe Call 
    
        describeCategoryResult = Schema.describeDataCategoryGroups(objType);
   
        //Using the results and retrieving the information     
        for(Integer x = 0; x < describeCategoryResult.size(); x++){
        	DescribeDataCategoryGroupResult singleResult = describeCategoryResult[x];
            DataCategoryGroupSobjectTypePair p = new DataCategoryGroupSobjectTypePair();
            p.setSobject(singleResult.getSobject());
            p.setDataCategoryGroupName(singleResult.getName());
            pairs.add(p);
        } 
    	describeCategoryStructureResult = Schema.describeDataCategoryGroupStructures(pairs, false);
        
        for(DescribeDataCategoryGroupStructureResult oneResult : describeCategoryStructureResult){
            list<DataCategory> topCat2Group = oneResult.getTopCategories();
            for(DataCategory oneCat : topCat2Group) {
                list<DataCategory> childCategories = oneCat.getChildCategories();
                for(DataCategory oneChildCat : childCategories) {                    
                    if(CSP_Utils.CSPortalRedirectExists()){                        
                        list<DataCategory> childCategories2ndLevel = oneChildCat.getChildCategories();
                        for(DataCategory oneChildCateg: childCategories2ndLevel){
                            lst_DataCategories.add(new clsDataCategory(oneResult.name,oneResult.label,oneChildCateg.getName(),oneChildCateg.getLabel(),oneChildCateg.getChildCategories()));   
                        }   
                    }else{                      
                        lst_DataCategories.add(new clsDataCategory(oneResult.name
                                                                   ,oneResult.label    
                                                                   ,oneChildCat.getName()
                                                                   ,oneChildCat.getLabel()
                                                                   ,oneChildCat.getChildCategories()));   
                        
                    }
                }
            } 
        }
    }

	/**
	 * [print description]
	 * @return [description]
	 */
	public void print(){
		
        //system.debug('** DataCategoryContainer Data **');
		for(clsDataCategory cdc : lst_DataCategories){
	       cdc.print();
		}
	}
}