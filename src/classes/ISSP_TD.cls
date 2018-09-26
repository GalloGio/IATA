public without sharing class ISSP_TD {

	public String recordTypeId {get; set;}
	//public String defaultTopic {get; set;}
	//public List <ISSP_TD_Reports__c> reportList {get; set;}
	public List <reportWrapper> reportList {get; set;}
	public List <reportWrapper> reportListTab2 {get; set;}
	public String accessLevel {get; set;}
	public Boolean dashboard_1_visible {get; set;}
	public Boolean dashboard_2_visible {get; set;}
	public Boolean dashboard_3_visible {get; set;}
	public Boolean dashboard_4_visible {get; set;}
	public Boolean dashboard_5_visible {get; set;}
	
	public Portal_Applications__c tdPremium {get; set;}
	public String conId {get; set;}

	public ISSP_TD(){
		
	}
	
	public PageReference pageLoad(){
		
		tdPremium = new Portal_Applications__c();
		List <Portal_Applications__c> tdServiceList = 
			[SELECT Id, Name, Agency__c, Aplication_Start_Icon__c, Application_icon__c,
			Application_icon_URL__c, Application_URL__c, Case_creation_record_type__c, Confirm_Box__c,
			Confirm_Text__c, Description__c, GSSA__c, Hide_on_Homepage__c,
			ICH_Airline__c, New_Window__c, Not_ICH_Airline__c, Record_type_for_App_Rigth__c,
			Requestable__c, Restricted_App__c, Visible__c, Service_Description__c, TD_Access_Level__c
			FROM Portal_Applications__c
			WHERE Name = 'Treasury Dashboard - Premium'];
		if (!tdServiceList.isEmpty()){
			tdPremium = tdServiceList[0];
		}
		List <User> userList = [SELECT Id, ContactId
    							FROM User WHERE Id = :UserInfo.getUserId()];
    	if (!userList.isEmpty()){
    		conId = userList[0].ContactId;
    	}
		
		List <ISSP_TD_Reports__c> allReportList = [SELECT Name, Label__c, URL__c, Order__c, Tab__c FROM ISSP_TD_Reports__c WHERE Active__c = true ORDER BY Order__c];
		
		recordTypeId = '';
		ISSP_Record_Type_Mgmt__c rtMgmt =  ISSP_Record_Type_Mgmt__c.getValues('Treasury Dashboard');
		if (rtMgmt != null){
			if (rtMgmt.Record_Type_Name__c != null){
				recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = :rtMgmt.Record_Type_Name__c LIMIT 1].Id;
			}
		}
		/*
		defaultTopic = '';
		ISSP_FAQ2Case_Default_Topic__c topicRecord =  ISSP_FAQ2Case_Default_Topic__c.getValues('Treasury Dashboard');
		if (topicRecord != null){
			if (topicRecord.Topic_Value__c != null){
				defaultTopic = topicRecord.Topic_Value__c;
			}
		}
		*/
		User myUser = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
		List <Portal_Application_Right__c> accessList = [SELECT Id, Portal_Application__r.TD_Access_Level__c,
														Portal_Application__r.TD_Included_Dashboards__c,
														Portal_Application__r.TD_Included_Reports__c
														FROM Portal_Application_Right__c
														WHERE Contact__c = :myUser.ContactId
														AND Portal_Application__r.Name LIKE 'Treasury Dashboard%'
														AND Right__c = 'Access Granted'];
		
		if (accessList.isEmpty()){
			PageReference pr = new PageReference('/ISSP_Homepage');
			return pr;
		}
		else{
			//TF - TD2 - different access levels for dashboards and reports
			accessLevel = accessList[0].Portal_Application__r.TD_Access_Level__c;
			dashboard_1_visible = false;
			dashboard_2_visible = false;
			dashboard_3_visible = false;
			dashboard_4_visible = false;
			dashboard_5_visible = false;

			if (accessList[0].Portal_Application__r.TD_Included_Dashboards__c != null){
				List<String> dashboardAccess = accessList[0].Portal_Application__r.TD_Included_Dashboards__c.split(';');
				for(String thisDashboard : dashboardAccess){
					if (thisDashboard == 'ISSP_TD_1'){
						dashboard_1_visible = true;
					}
					else if (thisDashboard == 'ISSP_TD_2'){
						dashboard_2_visible = true;
					}
					else if (thisDashboard == 'ISSP_TD_3'){
						dashboard_3_visible = true;
					}
					else if (thisDashboard == 'ISSP_TD_4'){
						dashboard_4_visible = true;
					}
					else if (thisDashboard == 'ISSP_TD_5'){
						dashboard_5_visible = true;
					}
				}
			}
			
			if (accessList[0].Portal_Application__r.TD_Included_Reports__c != null){
				List<String> reportAccess = accessList[0].Portal_Application__r.TD_Included_Reports__c.split(';');
				Set<String> reportAccessSet = new Set<String>();
				for (String thisReportName : reportAccess){
					reportAccessSet.add(thisReportName);
				}
				reportList = new List <reportWrapper>();
				reportListTab2 = new List <reportWrapper>();
				for (ISSP_TD_Reports__c thisReport : allReportList){
					reportWrapper newReport = new reportWrapper();
					newReport.reportRecord = thisReport;
					if (reportAccessSet.contains(thisReport.Name)){
						newReport.visible = true;
					}
					else{
						newReport.visible = false;
					}
					if (thisReport.Tab__c == 1 || thisReport.Tab__c == null){
						reportList.add(newReport);
					}
					else if (thisReport.Tab__c == 2){
						reportListTab2.add(newReport);
					}
				}
			}
			
			List<TwoFactorInfo> twoFactors = [SELECT UserId, Type FROM TwoFactorInfo where userID = :myUser.Id];
			if (twoFactors.isEmpty()){ //TO UNCOMMENT
				PageReference pr = new PageReference('/secur/logout.jsp');
				return pr;
			}
		}
		
		/*
		List <User> userList = [SELECT Id, ISSP_2FA_Key__c, ISSP_2FA_Valid_Session__c
								FROM User WHERE Id = :UserInfo.getUserId()];
		if (!userList.isEmpty()){
			if (!userList[0].ISSP_2FA_Valid_Session__c){
				PageReference pr = new PageReference('/ISSP_2FA');
				return pr;
			}
		}
		*/
		return null;
	}
	
	public static PageReference toLogout_TD(){
		// TO UNCOMMENT
		User myUser = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
		List <Portal_Application_Right__c> accessList = [SELECT Id FROM Portal_Application_Right__c
														WHERE Contact__c = :myUser.ContactId
														AND Portal_Application__r.Name LIKE 'Treasury Dashboard%'
														AND Right__c = 'Access Granted'];
		if (accessList.isEmpty()){
			PageReference pr = new PageReference('/ISSP_Homepage');
			return null;
		}
		else{
			List<TwoFactorInfo> twoFactors = [SELECT UserId, Type FROM TwoFactorInfo where userID = :myUser.Id];
			if (twoFactors.isEmpty()){
				PageReference pr = new PageReference('/secur/logout.jsp');
				return pr;
			}
		}
		
		return null;
	}
	
	public class reportWrapper {
		public Boolean visible {get; set;}
		public ISSP_TD_Reports__c reportRecord {get; set;}
    }
    
    @RemoteAction
    public static string newAppsRequest (string applicationId, string contactId){
        insert new Portal_Application_Right__c(Contact__c = contactId,Portal_Application__c = applicationId,Right__c = 'Access Requested');
        return 'ok';
    }
}