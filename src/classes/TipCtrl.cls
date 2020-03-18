public without sharing class TipCtrl {

	public static String POWERBI_ACCESS_TOKEN = 'PowerBIaccessToken';
	public static String POWERBI_EXPIERS_ON = 'PowerBIexpiersOn';
	public static String POWERBI_REFRESH_TOKEN = 'PowerBIrefreshToken';

	@AuraEnabled
	public static PowerBI_Config__c getPowerBICredentials(String configurationName) {
		return PowerBiCtrl.getPowerBICredentials(configurationName);
	}

	@AuraEnabled
	public static PowerBiCtrl.OAuthResult getAccessToken(PowerBI_Config__c conf) {

		if(conf == null) {
			return null;
		}

		Cache.OrgPartition orgPartition = null;
		PowerBiCtrl.OAuthResult result = new PowerBiCtrl.OAuthResult();

		//Tests run on sandbox without org cache(SIT) would fail
		if(Test.isRunningTest()){

			try{
				orgPartition = Cache.Org.getPartition('local.PowerBI');
			}catch(Cache.Org.OrgCacheException e) {
				return PowerBiCtrl.getNewAccessToken(conf);
			}

		} else {
			orgPartition = Cache.Org.getPartition('local.PowerBI');
		}

		if (orgPartition != null) {

			String applicationSufix = conf.Application_Identifier__c;

			if (orgPartition.contains(POWERBI_ACCESS_TOKEN+applicationSufix)) {

				result.access_token = (String) orgPartition.get(POWERBI_ACCESS_TOKEN+applicationSufix);

				if (orgPartition.contains(POWERBI_EXPIERS_ON+applicationSufix)) {

					Long expiresOn = (Long) orgPartition.get(POWERBI_EXPIERS_ON+applicationSufix);


					//PowerBI is using timestamp without milliseconds - we need to divide by 1000
					Long currentTime = (System.now().getTime()) / 1000;

					if ((expiresOn - 360) < currentTime) {//token will expire in 6 minutes


						if (orgPartition.contains(POWERBI_REFRESH_TOKEN+applicationSufix)) {
							//refresh token here
							String refreshToken = (String)orgPartition.get(POWERBI_REFRESH_TOKEN+applicationSufix);
							result = PowerBiCtrl.refreshToken(refreshToken, conf);
							saveAccessTokenInOrgCache(orgPartition, result, conf);
						} else {
							//get new token
							result = PowerBiCtrl.getNewAccessToken(conf);
							saveAccessTokenInOrgCache(orgPartition, result, conf);
						}

					} else {//token OK
						result.expires_on = (Long) orgPartition.get(POWERBI_EXPIERS_ON+applicationSufix);

						if (orgPartition.contains(POWERBI_REFRESH_TOKEN+applicationSufix)) {

							result.refresh_token = (String) orgPartition.get(POWERBI_REFRESH_TOKEN+applicationSufix);

						} else {
							//refresh token not found - get new token
							result = PowerBiCtrl.getNewAccessToken(conf);
							saveAccessTokenInOrgCache(orgPartition, result, conf);
						}

					}

				} else {
					//expiresOn not found - get new token
					result = PowerBiCtrl.getNewAccessToken(conf);
					saveAccessTokenInOrgCache(orgPartition, result, conf);
				}

			} else {
				//access token not found - get new token
				result = PowerBiCtrl.getNewAccessToken(conf);
				saveAccessTokenInOrgCache(orgPartition, result, conf);
			}
		}

		return result;
	}

	private static void saveAccessTokenInOrgCache(Cache.OrgPartition orgPartition, PowerBiCtrl.OAuthResult result, PowerBI_Config__c conf) {
		if(result.error != null) {
			TransformationHelper.sendEmailSupport('FATAL: PowerBI Master Account Access token: ' + conf.Name + ' ' + result.error, 'PowerBI Master Account Access token: ' + conf.Name + ' ' +result.error);
			throw new transformationException('PowerBI Master Account Access token: ' + result.error);
		}
		else if(result.access_token != null && result.expires_on != null && result.refresh_token != null) {
			String applicationSufix = conf.Application_Identifier__c;
			orgPartition.put(POWERBI_ACCESS_TOKEN + applicationSufix, result.access_token, 3600);
			orgPartition.put(POWERBI_EXPIERS_ON + applicationSufix, result.expires_on, 3600);
			orgPartition.put(POWERBI_REFRESH_TOKEN + applicationSufix, result.refresh_token, 3600);
		}

	}

	@AuraEnabled
	public static PowerBiCtrl.ReportDetailResult getReportsDetails(String accessToken, String reportId, PowerBI_Config__c conf) {
		return PowerBiCtrl.getReportsDetails(accessToken, reportId, conf);
	}


	@AuraEnabled
	public static PowerBiCtrl.EmbedTokenResult getEmbedToken(String accessToken, String userId, String groupId, String reportId, String datasetId, PowerBI_Config__c conf) {

		if(conf == null) {
			return null;
		}

		PowerBiCtrl.EmbedTokenResult result = new PowerBiCtrl.EmbedTokenResult();
		Cache.SessionPartition sessionPartition = null;

		String reportIdReplaced = reportId.replaceAll('-', '');
		String cacheKey = conf.Application_Identifier__c + reportIdReplaced;

		//Tests run on sandbox without org cache(SIT) would fail
		if(Test.isRunningTest()) {

			try{

				sessionPartition = Cache.Session.getPartition('local.PowerBiSession');

			}catch(Cache.Session.SessionCacheException e) {

				return PowerBiCtrl.getEmbedToken(accessToken, userId,  groupId, reportId, datasetId, conf);

			}

		} else {

			sessionPartition = Cache.Session.getPartition('local.PowerBiSession');

		}


		if(sessionPartition != null) {

			if(sessionPartition.contains(cacheKey)) {

				result.token = (String)sessionPartition.get(cacheKey);

				if(sessionPartition.contains(cacheKey+'expireson')) {

					//expireson present in cache
					String cacheExpireson = (String)sessionPartition.get(cacheKey + 'expireson');
					if(String.isNotBlank(cacheExpireson)) {

						Datetime expiresonDatetime = getExpiresOnDatetime(cacheExpireson);
						
						if(expiresonDatetime.addMinutes(-10) < Datetime.now()) {
							//token expires in less than 10 minutes - get new
							result = PowerBiCtrl.getEmbedToken(accessToken, userId, groupId, reportId, datasetId, conf);
							saveEmbedTokenInSessionCache(sessionPartition, result, conf, cacheKey);

						} else {
							//token is OK
							result.expiration = cacheExpireson;

						}

					}

				} else {
					//no expires on in cache
					result = PowerBiCtrl.getEmbedToken(accessToken, userId, groupId, reportId, datasetId, conf);
					saveEmbedTokenInSessionCache(sessionPartition, result, conf, cacheKey);
				}

			} else {
				// no embed token in cache
				result = PowerBiCtrl.getEmbedToken(accessToken, userId, groupId, reportId, datasetId, conf);
				saveEmbedTokenInSessionCache(sessionPartition, result, conf, cacheKey);
			}

		}


		return result;
	}


	private static Datetime getExpiresOnDatetime(String expiresOn) {
		String expiresonString = '"' + expiresOn + '"';
		Datetime expiresonDatetime = (DateTime)JSON.deserialize(expiresonString, DateTime.class);
		return expiresonDatetime;
	}

	private static void saveEmbedTokenInSessionCache(Cache.SessionPartition sessionPartition, PowerBiCtrl.EmbedTokenResult result, PowerBI_Config__c conf, String cacheKey) {
		if(result.error != null) {
			TransformationHelper.sendEmailSupport('FATAL: PowerBI Master Account Embed token: ' + conf.Name + ' ' + result.error, 'PowerBI Master Account Embed token: ' + conf.Name + ' ' +result.error);
			throw new transformationException('PowerBI Master Account Embed token: ' + result.error);
		} else if(result.token != null && result.expiration != null){

			sessionPartition.put(cacheKey, result.token, 3600);
			sessionPartition.put(cacheKey+'expireson', result.expiration, 3600);

		}
	}



}