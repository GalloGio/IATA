public without sharing class ISSP_CurrencyCenterUtil {
	
	public static Boolean checkIfUserHasAccessToService(){
		Boolean result = false;

		User u = [SELECT Id,ContactId From User WHERE Id =: UserInfo.getUserId()];
		if(u != null){
			List<Portal_Application_Right__c> par = [SELECT Id FROM Portal_Application_Right__c 
												WHERE Contact__c =: u.ContactId 
												AND Right__c = 'Access Granted'
												AND (Contact_User_Portal_Status__c = 'Approved User' OR Contact_User_Portal_Status__c = 'Approved Admin')
												AND Application_Start_URL__c = '/ISSP_CurrencyCenterHome'];
			if(par.size()>0)
				result = true;
		}

		return result;

	}

	public static void stampVisitDateTime(Integer interval){
		User u = [SELECT Id,ContactId From User WHERE Id =: UserInfo.getUserId()];
		if(u != null){
			List<Portal_Application_Right__c> parList = [SELECT Id,ICCS_Currency_Center_Current_Visit__c,ICCS_Currency_Center_Previous_Visit__c
												FROM Portal_Application_Right__c 
												WHERE Contact__c =: u.ContactId 
												AND Right__c = 'Access Granted'
												AND (Contact_User_Portal_Status__c = 'Approved User' OR Contact_User_Portal_Status__c = 'Approved Admin')
												AND Application_Start_URL__c = '/ISSP_CurrencyCenterHome'
												ORDER BY LastModifiedDate DESC
												LIMIT 1];
			if(parList.size()>0){
				Portal_Application_Right__c par = parList[0];
				//get diff in miliseconds
				Long diff = System.now().getTime() - (par.ICCS_Currency_Center_Current_Visit__c != null ? par.ICCS_Currency_Center_Current_Visit__c.getTime() : 0);
				//convert to hours
				diff = diff / (60 * 60 * 1000);
				if(par != null && diff >= interval){
					par.ICCS_Currency_Center_Previous_Visit__c = par.ICCS_Currency_Center_Current_Visit__c;
					par.ICCS_Currency_Center_Current_Visit__c = System.now();
					update par;
				}
			}
		}
	}

	public static Datetime getPreviousVisitDateTime(){
		Datetime result;

		User u = [SELECT Id,ContactId From User WHERE Id =: UserInfo.getUserId()];
		if(u != null){
			List<Portal_Application_Right__c> par = [SELECT Id,ICCS_Currency_Center_Previous_Visit__c
												FROM Portal_Application_Right__c 
												WHERE Contact__c =: u.ContactId 
												AND Right__c = 'Access Granted'
												AND (Contact_User_Portal_Status__c = 'Approved User' OR Contact_User_Portal_Status__c = 'Approved Admin')
												AND Application_Start_URL__c = '/ISSP_CurrencyCenterHome'
												ORDER BY LastModifiedDate DESC
												LIMIT 1];
			if(par.size()>0){
				result = par[0].ICCS_Currency_Center_Previous_Visit__c;
			}
			else
				result = null;
		}
		return result;
	}

}