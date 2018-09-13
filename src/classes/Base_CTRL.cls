public with sharing class Base_CTRL {
	@auraEnabled
	public static One_Id_Service_Provider_Config__c loadConfig(String serviceName) {
		if(String.isNotBlank(serviceName)) {
			One_Id_Service_Provider_Config__c config = [select id, Max_Number_Of_Primary_User__c, Max_Number_Of_Secondary_User__c, Service_Provider_Name__c, Service_Bundle__r.name, Customer_Type_Activation__c  FROM One_Id_Service_Provider_Config__c  WHERE Service_Provider_Name__c =: serviceName LIMIT 1];
			return config;
		}
		return null;

	}
}