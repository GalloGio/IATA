public without sharing class TreasuryDashboardReportCtrl {

	public static String SERVICE_PRINCIPAL_ACCESS_TOKEN = 'PrincipalAccessToken';
	public static String SERVICE_PRINCIPAL_EXPIERS_ON = 'PrincipalExpiresOn';



	@AuraEnabled
	public static PowerBI_Config__c getPowerBICredentials(String configurationName) {
		return PowerBiCtrl.getPowerBICredentials(configurationName);
	}


	@AuraEnabled
	public static PowerBiCtrl.ReportDetails getReportConfigDetails(String reportName) {
		return PowerBiCtrl.getReportConfigDetails(reportName);
	}



	@AuraEnabled
	public static PowerBiCtrl.OAuthResult getServicePrincipalAccessToken(PowerBI_Config__c conf) {
		Integer refreshSecondsToExpire = 1200;
		return PowerBiCtrl.retrieveAccessToken(conf, SERVICE_PRINCIPAL_ACCESS_TOKEN, SERVICE_PRINCIPAL_EXPIERS_ON, null, refreshSecondsToExpire);
	}

	@AuraEnabled
	public static PowerBiCtrl.EmbedTokenResult getServicePrincipalEmbedToken(String accessToken, String userId, String groupId, String reportId, String datasetId, PowerBI_Config__c conf) {
		Integer refreshMinutesToExpire = 20;
		return PowerBiCtrl.retrieveEmbedToken(accessToken, userId, groupId, reportId, datasetId, conf, refreshMinutesToExpire);
	}

}