
public without sharing class TreasuryDashboardCtrl {

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

	/* USE THIS AS GCS PORTAL DOES*/
	/*@AuraEnabled
	public static String premiumAccessRequest(String applicationId, String applicationName, String contactId) {
		return PortalServicesCtrl.newAppsRequestICCS(applicationId, applicationName, contactId);
	}*/


	/*FROM ORIGINAL PAGE*/
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

}
