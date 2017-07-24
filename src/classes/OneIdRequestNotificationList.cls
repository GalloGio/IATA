public with sharing class OneIdRequestNotificationList {
	public OneIdRequestNotificationList() {
		
	}

	@AuraEnabled
	public static List<One_Id_User_Applications__c> getUserApps(){
		Id userId = Userinfo.getUserId();
		
		/*List<One_Id_User_Applications__c> applist = [SELECT App_Key__c, Identity_User__c, One_Id_App_Bundle__c, Application__c, One_Id_Service_provider_Config__c, Provisioning_Status__c, User_App_State__c, User_Provisioning_Request__c
		FROM One_Id_User_Applications__c
		LIMIT 10];*/
		List<One_Id_User_Applications__c> applist = [SELECT App_Key__c, 
                                                     Identity_User__c, 
                                                     One_Id_App_Bundle__c, 
                                                     Application__c, 
                                                     One_Id_Service_provider_Config__c, 
                                                     Provisioning_Status__c, 
                                                     User_App_State__c, 
                                                     User_Provisioning_Request__c, 
                                                     One_Id_App_Bundle__r.App_Picture_Url__c, 
                                                     One_Id_App_Bundle__r.Description__c, 
                                                     One_Id_App_Bundle__r.Service_Provider_Name__c, 
                                                     App_Name__c,
                                                     CreatedDate
		FROM One_Id_User_Applications__c
		WHERE Identity_User__c =:userId 
		AND User_App_State__c = 'Requested'
		ORDER BY CreatedDate
		LIMIT 10];
		return applist;
	}
}