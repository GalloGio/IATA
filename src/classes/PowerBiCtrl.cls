
public without sharing class PowerBiCtrl {


	public class OAuthResult {
		@AuraEnabled
		public String access_token {get; set;}
		@AuraEnabled
		public String refresh_token {get; set;}
		@AuraEnabled
		public Long expires_on {get;set;}
		@AuraEnabled
		public String error {get; set;}

	}


	public class EmbedTokenResult {
		@AuraEnabled
		public String token {get; set;}
		@AuraEnabled
		public String tokenId {get; set;}
		@AuraEnabled
		public String expiration {get; set;}
		@AuraEnabled
		public EmbedError error {get; set;}
	}

	public class ReportDetailResult {
		@AuraEnabled
		public String id {get; set;}
		@AuraEnabled
		public String name {get; set;}
		@AuraEnabled
		public String webUrl {get; set;}
		@AuraEnabled
		public String embedUrl {get; set;}
		@AuraEnabled
		public String datasetId {get; set;}
		@AuraEnabled
		public String error {get; set;}
	}

	public class DatasetDetailResult {
		@AuraEnabled
		public String id {get; set;}
		@AuraEnabled
		public String name {get; set;}
		@AuraEnabled
		public String isRefreshable {get; set;}
		@AuraEnabled
		public String isEffectiveIdentityRequired {get; set;}
		@AuraEnabled
		public String isEffectiveIdentityRolesRequired {get; set;}
		@AuraEnabled
		public String error {get; set;}
	}

	public class ReportDetails {
		@AuraEnabled
		public String reportId {get; set;}
		@AuraEnabled
		public String groupId {get; set;}
		@AuraEnabled
		public String reportLabel {get; set;}
		@AuraEnabled
		public String type {get; set;}
	}

	private class RequestData{
		String accessLevel;
		List<IdentityData> identities;
	}

	private class IdentityData{
		String username;
		List<String> roles;
		List<String> datasets;
		List<String> reports;
	}


	public class EmbedError {
		@AuraEnabled
		public String code {get; set;}
		@AuraEnabled
		public String message {get; set;}
	}


	public static PowerBI_Config__c getPowerBICredentials(String configurationName) {
		PowerBI_Cred__c powerBiCred = PowerBI_Cred__c.getInstance(configurationName);
		if(powerBiCred != null) {
			String credName = UserInfo.getOrganizationId().substring(0,15) == '00D2000000008TF'  ? powerBiCred.Prod_Configuration__c : powerBiCred.Dev_Configuration__c;
			PowerBI_Config__c config = PowerBI_Config__c.getValues(credName);
			if(config != null) {
				return config;

			}else{
				TransformationHelper.sendEmailSupport('FATAL: PowerBi Config ' + credName ,'PowerBi Config   ' + credName);
				throw new transformationException('Error Credentials PowerBI - no credentials found!');
			}

		}else{
			TransformationHelper.sendEmailSupport('FATAL: PowerBI Cred ' + configurationName ,'PowerBI Cred   ' + configurationName);
			throw new transformationException('Error Credentials PowerBI - no credentials found!');
		}
	}


	public static ReportDetails getReportConfigDetails(String reportName) {
		ReportDetails detailsToReturn = new ReportDetails();

		List<PowerBI_Report_Config__mdt> reportDetails = [SELECT Id, Label, Group_Id_Dev__c, Group_Id_Prod__c, Report_Id_Dev__c, Report_Id_Prod__c, Type__c FROM PowerBI_Report_Config__mdt WHERE DeveloperName = :reportName];
		if(! reportDetails.isEmpty()) {

			PowerBI_Report_Config__mdt reportDetail = reportDetails[0];

			if(reportDetail.Label != null) {
				detailsToReturn.reportLabel = reportDetail.Label;
			}

			if(reportDetail.Type__c != null) {
				detailsToReturn.type = reportDetail.Type__c;
			}

			Boolean isProd = UserInfo.getOrganizationId().substring(0,15) == '00D2000000008TF';
			if(isProd) {
				if(reportDetail.Group_Id_Prod__c != null) {
					detailsToReturn.groupId = reportDetail.Group_Id_Prod__c;
				}
				if(reportDetail.Report_Id_Prod__c != null) {
					detailsToReturn.reportId = reportDetail.Report_Id_Prod__c;
				}
				//use DEV config
			}else{
				if(reportDetail.Group_Id_Dev__c != null) {
					detailsToReturn.groupId = reportDetail.Group_Id_Dev__c;
				}
				if(reportDetail.Report_Id_Dev__c != null) {
					detailsToReturn.reportId = reportDetail.Report_Id_Dev__c;
				}

			}

		}

		return detailsToReturn;

	}


	public static OAuthResult getNewAccessToken(PowerBI_Config__c conf) {

		if(conf == null) {
			return null;
		}

		HttpRequest req = new HttpRequest();
		req.setEndpoint('callout:'+conf.Named_Credentials__c + '/' + conf.Tenant_Id__c+'/oauth2/token');

		String sBody = buildBodyForAccessToken(conf);

		req.setMethod('POST');
		req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
		req.setBody(sBody);

		Http h = new Http();
		HttpResponse res = h.send(req);
		OAuthResult result = (OAuthResult)(JSON.deserialize(res.getBody(), OAuthResult.class));

		return result;

	}

	@TestVisible
	public static OAuthResult refreshToken(String refreshToken, PowerBI_Config__c conf) {

		if(conf == null) {
			return null;
		}

		String refreshTokenString;
		if(Test.isRunningTest()){
			refreshTokenString = 'refreshTokenString';
		} else {
			refreshTokenString = refreshToken;
		}

		HttpRequest req = new HttpRequest();
		req.setEndpoint('callout:'+conf.Named_Credentials__c + '/' + conf.Tenant_Id__c+'/oauth2/token');
		String sBody=
				'grant_type=refresh_token'
						+ '&refresh_token=' + EncodingUtil.urlEncode(refreshTokenString, 'UTF-8')
						+ '&client_id=' + EncodingUtil.urlEncode(conf.ClientId__c, 'UTF-8')
						+ '&resource=' + EncodingUtil.urlEncode(conf.Resource__c, 'UTF-8')
						+ '&username={!$Credential.Username}'
						+ '&password={!$Credential.Password}';

		req.setMethod('POST');
		req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
		req.setBody(sBody);

		Http h = new Http();
		HttpResponse res = h.send(req);
		OAuthResult result = (OAuthResult)(JSON.deserialize(res.getBody(), OAuthResult.class));

		return result;

	}


	public static DatasetDetailResult getDataset(String accessToken, String datasetId, PowerBI_Config__c conf) {
		Http h = new Http();
		HttpRequest req = new HttpRequest();

		req.setEndpoint(conf.Details_Resource__c + '/v1.0/myorg/datasets/' +datasetId);
		req.setMethod('GET');
		req.setHeader('Authorization', 'Bearer ' + accessToken);

		HttpResponse res = h.send(req);
		DatasetDetailResult result = (DatasetDetailResult)(JSON.deserialize(res.getBody(), DatasetDetailResult.class));

		return result;
	}



	public static ReportDetailResult getReportsDetails(String accessToken, String reportId, PowerBI_Config__c conf) {

		Http h = new Http();
		HttpRequest req = new HttpRequest();

		req.setEndpoint(conf.Details_Resource__c + '/v1.0/myorg/reports/' +reportId);
		req.setMethod('GET');
		req.setHeader('Authorization', 'Bearer ' + accessToken);


		HttpResponse res = h.send(req);
		ReportDetailResult result = (ReportDetailResult)(JSON.deserialize(res.getBody(), ReportDetailResult.class));

		return result;
	}


	public static EmbedTokenResult getEmbedToken(String accessToken, String userId, String groupId, String reportId, String datasetId, PowerBI_Config__c conf) {

		String sBody = buildBodyForEmbedToken(userId, reportId, datasetId, conf);

		Http h = new Http();
		HttpRequest req = new HttpRequest();

		req.setEndpoint(conf.Details_Resource__c + '/v1.0/myorg/groups/' + groupId + '/reports/' + reportId + '/GenerateToken');
		req.setMethod('POST');
		req.setHeader('Authorization', 'Bearer ' + accessToken);
		req.setHeader('Content-Type', 'application/json');
		req.setHeader('Accept', 'application/json');
		req.setBody(sBody);

		HttpResponse res = h.send(req);
		EmbedTokenResult result = (EmbedTokenResult)(JSON.deserialize(res.getBody(), EmbedTokenResult.class));

		return result;

	}


	private static String buildBodyForAccessToken(PowerBI_Config__c conf) {
		String sBody='';

		if(String.isNotBlank(conf.Report_Resource__c)) {

			if('https://app.powerbi.com/reportEmbed'.equals(conf.Report_Resource__c)) {

				sBody=
						'grant_type=password'
								+ '&client_id=' + EncodingUtil.urlEncode(conf.ClientId__c, 'UTF-8')
								+ '&resource=' + EncodingUtil.urlEncode(conf.Resource__c, 'UTF-8')
								+ '&username={!$Credential.Username}'
								+ '&password={!$Credential.Password}';

			}else if('https://app.powerbi.com/rdlEmbed'.equals(conf.Report_Resource__c)) {

				sBody=
						'grant_type=client_credentials'
								+ '&client_id={!$Credential.Username}'
								+ '&resource=' + EncodingUtil.urlEncode(conf.Resource__c, 'UTF-8')
								+ '&client_secret={!$Credential.Password}';

			}

		}

		return sBody;
	}


	private static String buildBodyForEmbedToken(String userId, String reportId, String datasetId, PowerBI_Config__c conf) {
		User user = [SELECT Id, FederationIdentifier FROM User WHERE Id = :userId];

		IdentityData identityData = new IdentityData();
		identityData.username = user.FederationIdentifier;

		if('https://app.powerbi.com/reportEmbed'.equals(conf.Report_Resource__c)) {
			identityData.roles = new List<String>{'SFDC'};
			identityData.datasets = new List<String>{datasetId};
		}else if('https://app.powerbi.com/rdlEmbed'.equals(conf.Report_Resource__c)) {
			identityData.reports = new List<String>{reportId};
		}

		RequestData requestData = new RequestData();
		requestData.identities = new List<IdentityData> {identityData};
		requestData.accessLevel = 'View';

		String sBody = JSON.serialize(requestData);

		return sBody;
	}


	public static PowerBiCtrl.EmbedTokenResult retrieveEmbedToken(String accessToken, String userId, String groupId, String reportId, String datasetId, PowerBI_Config__c conf, Integer minutesToExpire) {

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

						if(expiresonDatetime.addMinutes(minutesToExpire*(-1)) < Datetime.now()) {
							//token expires in less than minutesToExpire minutes - get new
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


	public static PowerBiCtrl.OAuthResult retrieveAccessToken(PowerBI_Config__c conf, String accessTokenKey, String expiresOnKey, String refreshTokenKey, Integer secondsToExpire) {

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

			if (orgPartition.contains(accessTokenKey+applicationSufix)) {

				result.access_token = (String) orgPartition.get(accessTokenKey+applicationSufix);

				if (orgPartition.contains(expiresOnKey+applicationSufix)) {

					Long expiresOn = (Long) orgPartition.get(expiresOnKey+applicationSufix);

					//PowerBI is using timestamp without milliseconds - we need to divide by 1000
					Long currentTime = (System.now().getTime()) / 1000;

					if ((expiresOn - secondsToExpire) < currentTime) {//token will expire in secondsToExpire

						if (String.isNotBlank(refreshTokenKey) && orgPartition.contains(refreshTokenKey+applicationSufix)) {
							//refresh token here
							String refreshToken = (String)orgPartition.get(refreshTokenKey+applicationSufix);
							result = PowerBiCtrl.refreshToken(refreshToken, conf);
							saveAccessTokenInOrgCache(orgPartition, result, conf, accessTokenKey, expiresOnKey, refreshTokenKey);
						} else {
							//get new token
							result = PowerBiCtrl.getNewAccessToken(conf);
							saveAccessTokenInOrgCache(orgPartition, result, conf, accessTokenKey, expiresOnKey, refreshTokenKey);
						}

					} else {//token OK
						result.expires_on = expiresOn;

						if (String.isNotBlank(refreshTokenKey) && orgPartition.contains(refreshTokenKey+applicationSufix)) {

							result.refresh_token = (String) orgPartition.get(refreshTokenKey+applicationSufix);

						} else if(String.isNotBlank(refreshTokenKey)){
							//refresh token not found - get new token
							result = PowerBiCtrl.getNewAccessToken(conf);
							saveAccessTokenInOrgCache(orgPartition, result, conf, accessTokenKey, expiresOnKey, refreshTokenKey);
						}

					}

				} else {
					//expiresOn not found - get new token
					result = PowerBiCtrl.getNewAccessToken(conf);
					saveAccessTokenInOrgCache(orgPartition, result, conf, accessTokenKey, expiresOnKey, refreshTokenKey);
				}

			} else {
				//access token not found - get new token
				result = PowerBiCtrl.getNewAccessToken(conf);
				saveAccessTokenInOrgCache(orgPartition, result, conf, accessTokenKey, expiresOnKey, refreshTokenKey);
			}
		}

		return result;
	}

	private static Datetime getExpiresOnDatetime(String expiresOn) {
		String expiresonString = '"' + expiresOn + '"';
		Datetime expiresonDatetime = (DateTime)JSON.deserialize(expiresonString, DateTime.class);
		return expiresonDatetime;
	}

	private static void saveAccessTokenInOrgCache(Cache.OrgPartition orgPartition, PowerBiCtrl.OAuthResult result, PowerBI_Config__c conf, String accessTokenKey, String expiresOnKey, String refreshTokenKey) {
		if(result.error != null) {
			TransformationHelper.sendEmailSupport('FATAL: PowerBI Access token: ' + conf.Name + ' ' + result.error, 'PowerBI Access token: ' + conf.Name + ' ' +result.error);
			throw new transformationException('PowerBI Access token: ' + result.error);
		}
		else if(result.access_token != null && result.expires_on != null) {
			String applicationSufix = conf.Application_Identifier__c;
			orgPartition.put(accessTokenKey + applicationSufix, result.access_token, 3600);
			orgPartition.put(expiresOnKey + applicationSufix, result.expires_on, 3600);
			if(refreshTokenKey != null && result.refresh_token != null) {
				orgPartition.put(refreshTokenKey + applicationSufix, result.refresh_token, 3600);
			}
		}

	}

	private static void saveEmbedTokenInSessionCache(Cache.SessionPartition sessionPartition, PowerBiCtrl.EmbedTokenResult result, PowerBI_Config__c conf, String cacheKey) {
		if(result.error != null) {
			TransformationHelper.sendEmailSupport('FATAL: PowerBI Embed token: ' + conf.Name + ' ' + result.error, 'PowerBI Embed token: ' + conf.Name + ' ' +result.error);
			throw new transformationException('PowerBI Embed token: ' + result.error);
		} else if(result.token != null && result.expiration != null){

			sessionPartition.put(cacheKey, result.token, 3600);
			sessionPartition.put(cacheKey+'expireson', result.expiration, 3600);

		}
	}


}

