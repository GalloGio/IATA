
public without sharing class TreasuryDashboardCtrl {

	public static String POWERBI_ACCESS_TOKEN = 'PowerBIaccessToken';
	public static String POWERBI_EXPIERS_ON = 'PowerBIexpiersOn';
	public static String POWERBI_REFRESH_TOKEN = 'PowerBIrefreshToken';

	public class UserInformation {
		@AuraEnabled
		public User user {get; set;}
		@AuraEnabled
		public Boolean hasTwoFactor {get; set;}
		@AuraEnabled
		public Boolean isStandardUser {get; set;}
		@AuraEnabled
		public Boolean isPremiumUser {get; set;}
		@AuraEnabled
		public Portal_Applications__c tdPremium {get; set;}
	}


	@AuraEnabled
	public static PowerBI_Config__c getPowerBICredentials(String configurationName) {
		return PowerBiCtrl.getPowerBICredentials(configurationName);
	}


	@AuraEnabled
	public static PowerBiCtrl.ReportDetails getReportConfigDetails(String reportName) {
		return PowerBiCtrl.getReportConfigDetails(reportName);
	}


	@AuraEnabled
	public static UserInformation getUserInformation() {

		UserInformation userInfoToReturn = new UserInformation();
		userInfoToReturn.user = null;
		userInfoToReturn.hasTwoFactor = false;
		userInfoToReturn.isStandardUser = false;
		userInfoToReturn.isPremiumUser = false;
		userInfoToReturn.tdPremium = null;

		List<User> users = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];


		List <Portal_Applications__c> tdServicePremiumList = [SELECT Id, Name, Agency__c, Aplication_Start_Icon__c, Application_icon__c,
				Application_icon_URL__c, Application_URL__c, Case_creation_record_type__c, Confirm_Box__c,
				Confirm_Text__c, Description__c, GSSA__c, Hide_on_Homepage__c,
				ICH_Airline__c, New_Window__c, Not_ICH_Airline__c, Record_type_for_App_Rigth__c,
				Requestable__c, Restricted_App__c, Visible__c, Service_Description__c, TD_Access_Level__c
		FROM Portal_Applications__c
		WHERE Name = 'Treasury Dashboard - Premium'];

		if(! tdServicePremiumList.isEmpty()) {
			userInfoToReturn.tdPremium =  tdServicePremiumList[0];
		}

		if(! users.isEmpty()) {
			//get user
			userInfoToReturn.user = users[0];

			//get two factor
			List<TwoFactorInfo> twoFactors = [SELECT UserId, Type FROM TwoFactorInfo where userID = :users[0].Id];
			if (twoFactors.isEmpty()) {

				//user does not have two factor

			} else {

				userInfoToReturn.hasTwoFactor = true;

			}

			/* Check for Bypass_TD_2FA permission set
			This permission set is used for automation testing user to bypass the 2FA check on Treasury Dashboard page.
			 */
			List<String> resultList = hasBypass2FA(new List<String>{users[0].Id});
			if(! resultList.isEmpty()) {
				if('true'.equals(resultList[0])) {
					userInfoToReturn.hasTwoFactor = true;
				}
			}

			//get is standard user
			List <Portal_Application_Right__c> accessList = [
					SELECT Id, Portal_Application__r.TD_Access_Level__c,
							Portal_Application__r.TD_Included_Dashboards__c,
							Portal_Application__r.TD_Included_Reports__c
					FROM Portal_Application_Right__c
					WHERE Contact__c = :users[0] .ContactId
					AND Portal_Application__r.Name LIKE 'Treasury Dashboard%'
					AND Right__c = 'Access Granted'
			];
			//TreasuryDashboard access not granted
			if (accessList.isEmpty()) {

				//no Standard Dashboard access

			} else {//access granted

				userInfoToReturn.isStandardUser = true;

				if (accessList[0].Portal_Application__r.TD_Included_Dashboards__c != null) {
					List<String> dashboardAccess = accessList[0].Portal_Application__r.TD_Included_Dashboards__c.split(';');
					for (String thisDashboard : dashboardAccess) {

						if (thisDashboard == 'ISSP_TD_5') {
							userInfoToReturn.isStandardUser = false;
							userInfoToReturn.isPremiumUser = true;
							break;

						}
					}

				}


			}

		}

		return userInfoToReturn;

	}


	@AuraEnabled
	public static String premiumAccessRequest(String applicationId, String contactId) {
		return requestTreasuryDashboardPremium(applicationId, contactId);
	}


	@RemoteAction
	public static String requestTreasuryDashboardPremium (String applicationId, String contactId){
		insert new Portal_Application_Right__c(Contact__c = contactId,Portal_Application__c = applicationId,Right__c = 'Access Requested');
		return 'ok';
	}

	@AuraEnabled
	public static String getCaseRecordTypeId() {
		String caseRecordTypeId = '';

		ISSP_Record_Type_Mgmt__c rtMgmt =  ISSP_Record_Type_Mgmt__c.getValues('Treasury Dashboard');
		if (rtMgmt != null){
			if (rtMgmt.Record_Type_Name__c != null){
				caseRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', rtMgmt.Record_Type_Name__c);
			}
		}

		return caseRecordTypeId;
	}


	@AuraEnabled
	public static PowerBiCtrl.OAuthResult getAccessToken(PowerBI_Config__c conf) {
		Integer refreshSecondsToExpire = 360;
		return PowerBiCtrl.retrieveAccessToken(conf, POWERBI_ACCESS_TOKEN, POWERBI_EXPIERS_ON, POWERBI_REFRESH_TOKEN, refreshSecondsToExpire);
	}

	@AuraEnabled
	public static PowerBiCtrl.DatasetDetailResult getDataset(String accessToken, String datasetId, PowerBI_Config__c conf) {
		return PowerBiCtrl.getDataset(accessToken, datasetId, conf);
	}

	@AuraEnabled
	public static PowerBiCtrl.ReportDetailResult getReportsDetails(String accessToken, String reportId, PowerBI_Config__c conf) {
		return PowerBiCtrl.getReportsDetails(accessToken, reportId, conf);
	}


	@AuraEnabled
	public static PowerBiCtrl.EmbedTokenResult getEmbedToken(String accessToken, String userId, String groupId, String reportId, String datasetId, PowerBI_Config__c conf) {
		Integer refreshMinutesToExpire = 10;
		return PowerBiCtrl.retrieveEmbedToken(accessToken, userId, groupId, reportId, datasetId, conf, refreshMinutesToExpire);
	}


	/*
	This method is used in Accept Terms and 2FA 2 login flow and Treasury Dashboard page for bypassing 2FA for users
	that have Bypass_TD_2FA permission set assigned.
	 */
	@InvocableMethod
	public static List<String> hasBypass2FA(List<String> userId) {
		List<String> resultList = new List<String>();
		List<PermissionSetAssignment> permissionsList = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :userId[0] AND PermissionSet.Name = 'Bypass_TD_2FA'];
		if(! permissionsList.isEmpty()) {
			resultList.add('true');
		}else{
			resultList.add('false');
		}

		return resultList;
	}




}