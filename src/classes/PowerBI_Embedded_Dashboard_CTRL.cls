public without sharing class PowerBI_Embedded_Dashboard_CTRL {

    private static String POWERBI_ACCESS_TOKEN = 'PowerBIaccessToken';
    private static String POWERBI_EXPIERS_ON = 'PowerBIexpiersOn';
    private static String POWERBI_REFRESH_TOKEN = 'PowerBIrefreshToken';

    private static String CUSTOM_SETTING_NAME = 'IATA_PowerBI_Test';

    private class OAuthResult {
        @AuraEnabled
        public String access_token {get; set;}
        @AuraEnabled
        public String refresh_token {get; set;}
        @AuraEnabled
        public Long expires_on {get;set;}

    }


    private class EmbedTokenResult {
        @AuraEnabled
        public String token {get; set;}
        @AuraEnabled
        public String tokenId {get; set;}
        @AuraEnabled
        public String expiration {get; set;}
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

    @AuraEnabled
    public static OAuthResult getAccessToken() {

        /*String accessToken = '';
        Long expiresOn = 0L;
        String refreshToken = '';*/

        OAuthResult result = new OAuthResult();

        Cache.OrgPartition orgPartition = Cache.Org.getPartition('local.PowerBI');

        if (orgPartition != null) {

            if (orgPartition.contains(POWERBI_ACCESS_TOKEN)) {

                result.access_token = (String) orgPartition.get(POWERBI_ACCESS_TOKEN);

                if (orgPartition.contains(POWERBI_EXPIERS_ON)) {

                    Long expiresOn = (Long) orgPartition.get(POWERBI_EXPIERS_ON);
                    //PowerBI is using timestamp without milliseconds - we need to divide by 1000
                    Long currentTime = (System.now().getTime()) / 1000;
                    if ((expiresOn - 2000) < currentTime) {//token expired


                        if (orgPartition.contains(POWERBI_REFRESH_TOKEN)) {
                            //refresh token here
                            System.debug('token expired');
                            result = refreshToken(orgPartition);
                        } else {
                            //get new token
                            System.debug('no refresh token found in org cache');
                            result = getNewAccessToken(orgPartition);
                        }

                    } else {//token OK
                        result.expires_on = (Long) orgPartition.get(POWERBI_EXPIERS_ON);
                        if (orgPartition.contains(POWERBI_REFRESH_TOKEN)) {
                            //refreshToken = (String)orgPartition.get(POWERBI_REFRESH_TOKEN);

                            //result.access_token = accessToken;
                            //result.expires_on = expiresOn;
                            result.refresh_token = (String) orgPartition.get(POWERBI_REFRESH_TOKEN);
                        } else {
                            //get new token
                            System.debug('refresh token not found');
                            result = getNewAccessToken(orgPartition);
                        }

                    }

                } else {
                    //get new token
                    System.debug('expiresOn not found');
                    result = getNewAccessToken(orgPartition);
                }

            } else {
                //get new token
                System.debug('access token not found');
                result = getNewAccessToken(orgPartition);
            }
        }

        return result;
    }

    private static OAuthResult getNewAccessToken(Cache.Orgpartition orgPartition) {
        System.debug('getNewAccessToken');
        PowerBI_Config__c conf = PowerBI_Config__c.getValues(CUSTOM_SETTING_NAME);
        if(conf == null) {
            System.debug('PowerBI config with name "'+CUSTOM_SETTING_NAME+'" not found!');
            return null; // todo: should redirect to error page or something
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
        System.debug('result:: ' + result);

        if(orgPartition != null) {
            orgPartition.put(POWERBI_ACCESS_TOKEN, result.access_token, 3600);
            orgPartition.put(POWERBI_EXPIERS_ON, result.expires_on, 3600);
            orgPartition.put(POWERBI_REFRESH_TOKEN, result.refresh_token, 3600);
        }
        return result;
        /*String accessToken = result.access_token;
        Long expiresOn = Long.valueOf(result.expires_on) * 1000;
        String refreshToken = result.refresh_token;

        PBI_OAuth__c oaAuth = new PBI_OAuth__c();
        oaAuth.Access_Token__c = accessToken;
        oaAuth.Expires_On__c = Datetime.newInstance(expiresOn);
        oaAuth.Refresh_Token__c = refreshToken;

        insert oaAuth;
        return oaAuth;*/
    }


    private static OAuthResult refreshToken(Cache.Orgpartition orgPartition) {
        System.debug('refreshToken');
        String refreshToken = (String)orgPartition.get(POWERBI_REFRESH_TOKEN);

        PowerBI_Config__c conf = PowerBI_Config__c.getValues(CUSTOM_SETTING_NAME);
        if(conf == null) {
            System.debug('PowerBI config with name "'+CUSTOM_SETTING_NAME+'" not found!');
            return null; // todo: should redirect to error page or something
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
        System.debug('refresh_token result:: ' + result);

        orgPartition.put(POWERBI_ACCESS_TOKEN, result.access_token, 3600);
        orgPartition.put(POWERBI_EXPIERS_ON, result.expires_on, 3600);
        orgPartition.put(POWERBI_REFRESH_TOKEN, result.refresh_token, 3600);

        return result;

        /*String accessToken = result.access_token;
        Long expiresOn = Long.valueOf(result.expires_on) * 1000;
        String refreshToken = result.refresh_token;

        //update new token data
        oAuth.Access_Token__c = accessToken;
        oAuth.Expires_On__c = Datetime.newInstance(expiresOn);
        oAuth.Refresh_Token__c = refreshToken;

        update oAuth;
        return oAuth;*/
    }

    @AuraEnabled
    public static User getUserDetail(Id userId) {
        return [SELECT Id, Federation_ID__c FROM User WHERE Id = :userId LIMIT 1];
    }


    @AuraEnabled      //TODO: - dataset details
    public static String getDataset(String accessToken, String datasetId) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();

        req.setEndpoint('https://api.powerbi.com/v1.0/myorg/datasets/' +datasetId);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + accessToken);

        System.debug('request:: ' + req.toString());
        HttpResponse res = h.send(req);

        //EmbedTokenResult result = (EmbedTokenResult)(JSON.deserialize(res.getBody(), EmbedTokenResult.class));
        String result = res.getBody();
        System.debug('getDataset result.getBody():: ' + result);

        return result;
    }



    @AuraEnabled          //THIS WILL RETURN FEDERATION ID //TODO:get dataseteId for report
    public static String getReportsDetails(String accessToken, String reportId) {

        //groupId = 'bb322fe5-1f26-4bc6-892a-811d6a625ba1';
        //String reportId = '39d42f7a-0a92-49cc-aef8-1a6c851143dd';

        Http h = new Http();
        HttpRequest req = new HttpRequest();

        req.setEndpoint('https://api.powerbi.com/v1.0/myorg/reports/' +reportId);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + accessToken);

        System.debug('request:: ' + req.toString());
        HttpResponse res = h.send(req);

        //EmbedTokenResult result = (EmbedTokenResult)(JSON.deserialize(res.getBody(), EmbedTokenResult.class));
        String result = res.getBody();
        System.debug('embegetReportsDetailsdToken response:: ' + res.getBody());
        System.debug('getReportsDetails result.getBody():: ' + result);

        return result;
    }

    @AuraEnabled
    public static EmbedTokenResult getEmbedToken(String accessToken, String federationId, String groupId, String reportId, String datasetId) {
        System.debug('getEmbedToken - groupId: ' +groupId);
        System.debug('getEmbedToken - reportId: ' +reportId);
        System.debug('getEmbedToken - federationId: ' +federationId);

        IdentityData identityData = new IdentityData();
        identityData.username = federationId;
        identityData.roles = new List<String>();
        identityData.datasets = new List<String>{datasetId};//TODO:temporal static solution

        RequestData requestData = new RequestData();
        requestData.identities = new List<IdentityData> {identityData};
        requestData.accessLevel = 'View';


        String sBody = JSON.serialize(requestData);
        System.debug('sBody:: ' + sBody);

        Http h = new Http();
        HttpRequest req = new HttpRequest();

        req.setEndpoint('https://api.powerbi.com/v1.0/myorg/groups/' + groupId + '/reports/' + reportId + '/GenerateToken');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setBody(sBody);

        System.debug('request:: ' + req.toString());
        HttpResponse res = h.send(req);

        EmbedTokenResult result = (EmbedTokenResult)(JSON.deserialize(res.getBody(), EmbedTokenResult.class));
        System.debug('embedToken response:: ' + res.getBody());
        System.debug('embedToken result.getBody():: ' + result);

        return result;

    }

}