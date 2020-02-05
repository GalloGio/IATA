public without sharing class PowerBI_Embedded_Dashboard_CTRL {

	private static String POWERBI_ACCESS_TOKEN = 'PowerBIaccessToken';
	private static String POWERBI_EXPIERS_ON = 'PowerBIexpiersOn';
	private static String POWERBI_REFRESH_TOKEN = 'PowerBIrefreshToken';

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
	}

	private class RequestData{
		String accessLevel;
		List<IdentityData> identities;
	}

	private class IdentityData{
		String username;
		List<String> roles;
		List<String> datasets;
	}

	private static PowerBI_Config__c getPowerBICredentials(String configurationName) {
		PowerBI_Cred__c powerBiCred = PowerBI_Cred__c.getInstance(configurationName);
		if(powerBiCred != null) {
			String credName = UserInfo.getOrganizationId().substring(0,15) == '00D2000000008TF'  ? powerBiCred.Prod_Configuration__c : powerBiCred.Dev_Configuration__c;
			PowerBI_Config__c config = PowerBI_Config__c.getValues(credName);
			if(config != null) {
				return config;

			}else{
				TransformationHelper.sendEmailSupport('FATAL: PowerBi Config ' + credName ,'PowerBi Config   ' + credName);
				throw new transformationException('Error Credentials - no credentials found!');
			}

		}else{
			TransformationHelper.sendEmailSupport('FATAL: PowerBI Cred ' + configurationName ,'PowerBI Cred   ' + configurationName);
			throw new transformationException('Error Credentials - no credentials found!');
		}
	}

	@AuraEnabled
	public static boolean checkSessionCache(Id userId, String key) {

		String cacheKey = userId + key;
		Cache.SessionPartition sessionPartition = null;
		try{
			sessionPartition = Cache.Session.getPartition('local.ServiceUsage');
		} catch (Exception e) {}

		if(sessionPartition != null) { if(sessionPartition.contains(cacheKey)) { return true; }}
		return false;
	}

	@AuraEnabled
	public static OAuthResult getAccessToken() {

		Cache.OrgPartition orgPartition = null;
		OAuthResult result = new OAuthResult();

		if(Test.isRunningTest()){
			return getNewAccessToken(null);
		} else {
			orgPartition = Cache.Org.getPartition('local.PowerBI');
		}

		if (orgPartition != null) {

			if (orgPartition.contains(POWERBI_ACCESS_TOKEN)) {

				result.access_token = (String) orgPartition.get(POWERBI_ACCESS_TOKEN);

				if (orgPartition.contains(POWERBI_EXPIERS_ON)) {

					Long expiresOn = (Long) orgPartition.get(POWERBI_EXPIERS_ON);

					//PowerBI is using timestamp without milliseconds - we need to divide by 1000
					Long currentTime = (System.now().getTime()) / 1000;

					if ((expiresOn - 120) < currentTime) {//token will expire in 2 minutes


						if (orgPartition.contains(POWERBI_REFRESH_TOKEN)) {
							//refresh token here
							result = refreshToken(orgPartition);
						} else {
							//get new token
							result = getNewAccessToken(orgPartition);
						}

					} else {//token OK
						result.expires_on = (Long) orgPartition.get(POWERBI_EXPIERS_ON);
						if (orgPartition.contains(POWERBI_REFRESH_TOKEN)) {

							result.refresh_token = (String) orgPartition.get(POWERBI_REFRESH_TOKEN);
						} else {
							//refresh token not found - get new token
							result = getNewAccessToken(orgPartition);
						}

					}

				} else {
					//expiresOn not found - get new token
					result = getNewAccessToken(orgPartition);
				}

			} else {
				//access token not found - get new token

				result = getNewAccessToken(orgPartition);
			}
		}

		return result;
	}

	private static OAuthResult getNewAccessToken(Cache.Orgpartition orgPartition) {
		PowerBI_Config__c conf = getPowerBICredentials('GADM');

		if(conf == null) {
			return null;
		}

		Http h = new Http();
		String sBody=
				'grant_type=password'
						+ '&client_id=' + EncodingUtil.urlEncode(conf.ClientId__c, 'UTF-8')
						+ '&resource=' + EncodingUtil.urlEncode(conf.Resource__c, 'UTF-8')
						+ '&username='+conf.Username__c
						+ '&password='+conf.Password__c;

		HttpRequest req = new HttpRequest();

		req.setEndpoint('https://login.microsoftonline.com/'+conf.Tenant_Id__c+'/oauth2/token');
		req.setMethod('POST');
		req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
		req.setBody(sBody);

		HttpResponse res = h.send(req);

		OAuthResult result = (OAuthResult)(JSON.deserialize(res.getBody(), OAuthResult.class));

		if(result.error != null) {
			TransformationHelper.sendEmailSupport('FATAL: PowerBI Access token: ' + conf.Name + ' ' + result.error, 'PowerBI Access token: ' + conf.Name + ' ' +result.error);
			throw new transformationException('Error PowerBI access token: ' + result.error);
		}

		if(orgPartition != null) {
			orgPartition.put(POWERBI_ACCESS_TOKEN, result.access_token, 3600);
			orgPartition.put(POWERBI_EXPIERS_ON, result.expires_on, 3600);
			orgPartition.put(POWERBI_REFRESH_TOKEN, result.refresh_token, 3600);
		}
		return result;

	}

	@TestVisible
	private static OAuthResult refreshToken(Cache.Orgpartition orgPartition) {
		String refreshToken;
		if(Test.isRunningTest()){
			refreshToken = 'refreshTokenString';
		} else {
			refreshToken = (String)orgPartition.get(POWERBI_REFRESH_TOKEN);
		}

		PowerBI_Config__c conf = getPowerBICredentials('GADM');
		if(conf == null) {
			return null;
		}

		Http h = new Http();
		String sBody=
				'grant_type=refresh_token'
						+ '&refresh_token=' + EncodingUtil.urlEncode(refreshToken, 'UTF-8')
						+ '&client_id=' + EncodingUtil.urlEncode(conf.ClientId__c, 'UTF-8')
						+ '&resource=' + EncodingUtil.urlEncode(conf.Resource__c, 'UTF-8')
						+ '&username='+conf.Username__c
						+ '&password='+conf.Password__c;

		HttpRequest req = new HttpRequest();

		req.setEndpoint('https://login.microsoftonline.com/'+conf.Tenant_Id__c+'/oauth2/token');
		req.setMethod('POST');
		req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
		req.setBody(sBody);

		HttpResponse res = h.send(req);

		OAuthResult result = (OAuthResult)(JSON.deserialize(res.getBody(), OAuthResult.class));
		if(orgPartition != null) {
			orgPartition.put(POWERBI_ACCESS_TOKEN, result.access_token, 3600);
			orgPartition.put(POWERBI_EXPIERS_ON, result.expires_on, 3600);
			orgPartition.put(POWERBI_REFRESH_TOKEN, result.refresh_token, 3600);
		}

		return result;

	}

	@AuraEnabled
	public static User getUserDetail(Id userId) {
		return [SELECT Id, Federation_ID__c FROM User WHERE Id = :userId LIMIT 1];
	}


	@AuraEnabled
	public static DatasetDetailResult getDataset(String accessToken, String datasetId) {
		Http h = new Http();
		HttpRequest req = new HttpRequest();

		req.setEndpoint('https://api.powerbi.com/v1.0/myorg/datasets/' +datasetId);
		req.setMethod('GET');
		req.setHeader('Authorization', 'Bearer ' + accessToken);

		HttpResponse res = h.send(req);

		DatasetDetailResult result = (DatasetDetailResult)(JSON.deserialize(res.getBody(), DatasetDetailResult.class));

		return result;
	}



	@AuraEnabled
	public static ReportDetailResult getReportsDetails(String accessToken, String reportId) {

		Http h = new Http();
		HttpRequest req = new HttpRequest();

		req.setEndpoint('https://api.powerbi.com/v1.0/myorg/reports/' +reportId);
		req.setMethod('GET');
		req.setHeader('Authorization', 'Bearer ' + accessToken);

		HttpResponse res = h.send(req);

		ReportDetailResult result = (ReportDetailResult)(JSON.deserialize(res.getBody(), ReportDetailResult.class));
		return result;
	}

	@AuraEnabled
	public static EmbedTokenResult getEmbedToken(String accessToken, String federationId, String groupId, String reportId, String datasetId) {

		IdentityData identityData = new IdentityData();
		identityData.username = federationId;
		identityData.roles = new List<String>{'SFDC'};
		identityData.datasets = new List<String>{datasetId};

		RequestData requestData = new RequestData();
		requestData.identities = new List<IdentityData> {identityData};
		requestData.accessLevel = 'View';

		String sBody = JSON.serialize(requestData);

		Http h = new Http();
		HttpRequest req = new HttpRequest();

		req.setEndpoint('https://api.powerbi.com/v1.0/myorg/groups/' + groupId + '/reports/' + reportId + '/GenerateToken');
		req.setMethod('POST');
		req.setHeader('Authorization', 'Bearer ' + accessToken);
		req.setHeader('Content-Type', 'application/json');
		req.setHeader('Accept', 'application/json');
		req.setBody(sBody);

		HttpResponse res = h.send(req);

		EmbedTokenResult result = (EmbedTokenResult)(JSON.deserialize(res.getBody(), EmbedTokenResult.class));

		return result;

	}

}
