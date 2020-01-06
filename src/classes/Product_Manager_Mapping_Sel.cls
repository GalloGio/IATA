/****************************************************************************************************
	Created by CGI, Thai 2015-08-21
		Class encapsulates query logic for "Product_Manager_Mapping__c"
****************************************************************************************************/

public class Product_Manager_Mapping_Sel {


/****************************************************************************************************
	Created by CGI, Thai 2015-08-21
		Return map between profit center and product manager
		Return all maps if no profit center is provided in passed map
		Code is covered in test method "test_setProductManager" of class "Product_Svc_Test"
****************************************************************************************************/
public static Map<String, Id> getProfitCenter_ManagerId(Set<String> setProfitCenter){
	Map<String, Id> mapProfitCenter_ManagerId = new Map<String, Id>();

	//*** build query command
	String SOQL = 'select Profit_Center__c, Product_Manager__c from Product_Manager_Mapping__c where Product_Manager__r.IsActive = true';
	if (setProfitCenter != null && setProfitCenter.size() > 0)
		SOQL += ' and Profit_Center__c in :setProfitCenter';

	//*** build and return map between profit center and product manager
	for (Product_Manager_Mapping__c pm : Database.query(SOQL))
	   mapProfitCenter_ManagerId.put(pm.Profit_Center__c, pm.Product_Manager__c);
	return mapProfitCenter_ManagerId;
} //*** end of "getProfitCenter_ManagerId"


} //*** end of class
