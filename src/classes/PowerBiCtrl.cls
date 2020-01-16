
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
        public String error {get; set;}
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
    }

    private class ServicePrincipalIdentityData{
        String username;
        List<String> roles;
        List<String> reports;
    }

    private class ServicePrincipalRequestData {
        String accessLevel;
        List<ServicePrincipalIdentityData> identities;
    }



    public class ServicePrincipalAccessTokenResult {
        @AuraEnabled
        public Long expires_on {get; set;}
        @AuraEnabled
        public String access_token {get; set;}
        @AuraEnabled
        public String error {get; set;}
    }


    public class ServicePrincipalEmbedTokenResult {
        @AuraEnabled
        public String token {get; set;}
        @AuraEnabled
        public String expiration {get; set;}
        @AuraEnabled
        public EmbedError error {get; set;}

    }

    public class EmbedError {
        @AuraEnabled
        public String code {get; set;}
        @AuraEnabled
        public String message {get; set;}
    }


    @AuraEnabled
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


    @AuraEnabled
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

        String sBody=
                'grant_type=password'
                        + '&client_id=' + EncodingUtil.urlEncode(conf.ClientId__c, 'UTF-8')
                        + '&resource=' + EncodingUtil.urlEncode(conf.Resource__c, 'UTF-8')
                        + '&username={!$Credential.Username}'
                        + '&password={!$Credential.Password}';

        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody(sBody);

        Http h = new Http();
        HttpResponse res = h.send(req);
        System.debug('getNewAccessToken:: '+res.getBody());
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
        System.debug('getDataset:: '+res.getBody());
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

    //@AuraEnabled
    public static EmbedTokenResult getEmbedToken(String accessToken, String userId, String groupId, String reportId, String datasetId, PowerBI_Config__c conf) {

        IdentityData identityData = new IdentityData();
        identityData.username = userId;
        identityData.roles = new List<String>{'SFDC'};
        identityData.datasets = new List<String>{datasetId};

        RequestData requestData = new RequestData();
        requestData.identities = new List<IdentityData> {identityData};
        requestData.accessLevel = 'View';

        String sBody = JSON.serialize(requestData);

        Http h = new Http();
        HttpRequest req = new HttpRequest();

        req.setEndpoint(conf.Details_Resource__c + '/v1.0/myorg/groups/' + groupId + '/reports/' + reportId + '/GenerateToken');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setBody(sBody);

        HttpResponse res = h.send(req);
        System.debug('getEmbedToken:: '+res.getBody());
        EmbedTokenResult result = (EmbedTokenResult)(JSON.deserialize(res.getBody(), EmbedTokenResult.class));

        return result;

    }


    public static ServicePrincipalAccessTokenResult getServicePrincipalAccessToken(PowerBI_Config__c conf) {

        if(conf == null) {
            return null;
        }

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:'+conf.Named_Credentials__c + '/' + conf.Tenant_Id__c+'/oauth2/token');

        String sBody=
                'grant_type=client_credentials'
                        + '&client_id={!$Credential.Username}'
                        + '&resource=' + EncodingUtil.urlEncode(conf.Resource__c, 'UTF-8')
                        + '&client_secret={!$Credential.Password}';

        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody(sBody);

        Http h = new Http();
        HttpResponse res = h.send(req);
        System.debug('sp access token:: ' + res.getBody());
        ServicePrincipalAccessTokenResult result = (ServicePrincipalAccessTokenResult)(JSON.deserialize(res.getBody(), ServicePrincipalAccessTokenResult.class));
        System.debug('sp access token result:: ' + result);

        return result;

    }


    public static ServicePrincipalEmbedTokenResult getServicePrincipalEmbedToken(String accessToken, String userId, String groupId, String reportId, PowerBI_Config__c conf) {

        ServicePrincipalIdentityData identityData = new ServicePrincipalIdentityData();
        identityData.username = userId;
        //identityData.roles = new List<String>{'SFDC'};
        identityData.reports = new List<String>{reportId};

        ServicePrincipalRequestData requestData = new ServicePrincipalRequestData();
        requestData.identities = new List<ServicePrincipalIdentityData> {identityData};
        requestData.accessLevel = 'View';

        String sBody = JSON.serialize(requestData);

        Http h = new Http();
        HttpRequest req = new HttpRequest();

        req.setEndpoint(conf.Details_Resource__c + '/v1.0/myorg/groups/' + groupId + '/reports/' + reportId + '/GenerateToken');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setBody(sBody);

        System.debug('sp embed token request:: ' + req);

        HttpResponse res = h.send(req);
        System.debug('res body:: ' + res.getBody());
        ServicePrincipalEmbedTokenResult result = (ServicePrincipalEmbedTokenResult)(JSON.deserialize(res.getBody(), ServicePrincipalEmbedTokenResult.class));
        System.debug('sp embed token result:: ' + result);

        return result;

    }


}

