public without sharing class PowerBI_Embedded_Container_CTRL {


    //private static String CUSTOM_SETTING_NAME = 'PowerBI account';
    private static String CUSTOM_SETTING_NAME = 'IATA_PowerBI_Test';

    private static String POWERBI_ACCESS_TOKEN = 'PowerBIaccessToken';
    private static String POWERBI_EXPIERS_ON = 'PowerBIexpiersOn';
    private static String POWERBI_REFRESH_TOKEN = 'PowerBIrefreshToken';


    public class PBIResponse {
        @AuraEnabled
        public List<PBIObject> value{get; set;}
    }

    public class PBIResult {
        @AuraEnabled
        public PBIObject workspace{get; set;}
        @AuraEnabled
        public List<PBIObject> dashboards{get;set;}
    }

    public class PBIObject {// abstract PBI object wrapper
        @AuraEnabled
        public String id{get;set;}
        @AuraEnabled
        public String displayName{get;set;}
        @AuraEnabled
        public String embedUrl{get;set;}
        @AuraEnabled
        public String name{get;set;} // needed for workspace name
    }

    private class OAuthResult {
        @AuraEnabled
        public String access_token {get; set;}
        @AuraEnabled
        public String refresh_token {get; set;}
        @AuraEnabled
        public Long expires_on {get;set;}

    }


    @AuraEnabled
    public static OAuthResult getAccessToken() {

        /*String accessToken = '';
        Long expiresOn = 0L;
        String refreshToken = '';*/

        OAuthResult result = new OAuthResult();

        Cache.OrgPartition orgPartition = Cache.Org.getPartition('local.PowerBI');

        if(orgPartition != null) {

            if(orgPartition.contains(POWERBI_ACCESS_TOKEN)) {

                result.access_token = (String)orgPartition.get(POWERBI_ACCESS_TOKEN);

                if(orgPartition.contains(POWERBI_EXPIERS_ON)) {

                    Long expiresOn = (Long)orgPartition.get(POWERBI_EXPIERS_ON);
                    //PowerBI is using timestamp without milliseconds - we need to divide by 1000
                    Long currentTime = (System.now().getTime())/1000;
                    if((expiresOn - 2000) < currentTime) {//token expired


                        if(orgPartition.contains(POWERBI_REFRESH_TOKEN)) {
                            //refresh token here
                            System.debug('token expired');
                            result = refreshToken(orgPartition);
                        }else{
                            //get new token
                            System.debug('no refresh token found in org cache');
                            result = getNewAccessToken(orgPartition);
                        }

                    }else{//token OK
                        result.expires_on = (Long)orgPartition.get(POWERBI_EXPIERS_ON);
                        if(orgPartition.contains(POWERBI_REFRESH_TOKEN)) {
                            //refreshToken = (String)orgPartition.get(POWERBI_REFRESH_TOKEN);

                            //result.access_token = accessToken;
                            //result.expires_on = expiresOn;
                            result.refresh_token = (String)orgPartition.get(POWERBI_REFRESH_TOKEN);
                        }else{
                            //get new token
                            System.debug('refresh token not found');
                            result = getNewAccessToken(orgPartition);
                        }

                    }

                }else{
                    //get new token
                    System.debug('expiresOn not found');
                    result = getNewAccessToken(orgPartition);
                }

            }else{
                //get new token
                System.debug('access token not found');
                result = getNewAccessToken(orgPartition);
            }
        }

        return result;
        /*PBI_OAuth__c oauth;

        List<PBI_OAuth__c> oauthList = [SELECT Id, Access_Token__c, Expires_On__c, Refresh_Token__c FROM PBI_OAuth__c LIMIT 1];
        if(!oauthList.isEmpty()) {

            Long currentTime = System.now().getTime();
            Long expiresOn = oauthList[0].Expires_On__c.getTime();
            System.debug('currentTime:: ' + currentTime);
            System.debug('expiresOn:: ' + expiresOn);

            if((expiresOn - 2000) < currentTime) {//expired

                oauth = refreshToken(oauthList[0]);

            }else{//OK

                oauth = oauthList[0];
            }
        }else{//no OAuth record

            oauth = getNewAccessToken();
        }

        return oauth;*/

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
    public static List<PBIObject> getWorkspacesInfo(String accessToken) {
        Http h = new Http();

        HttpRequest req = new HttpRequest();

        req.setEndpoint('https://api.powerbi.com/v1.0/myorg/groups');
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer '+accessToken);

        HttpResponse res = h.send(req);
        PBIResponse result = (PBIResponse)(JSON.deserialize(res.getBody(), PBIResponse.class));
        System.debug('getWorkspacesInfo() :: ' + result);

        return result.value;
    }

    @AuraEnabled
    public static List<PBIObject> getDashboards(String workspaceId, String accessToken){
        Http h = new Http();

        HttpRequest req = new HttpRequest();

        req.setEndpoint('https://api.powerbi.com/v1.0/myorg/groups/'+workspaceId+'/reports');
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer '+accessToken);

        HttpResponse res = h.send(req);
        PBIResponse result = (PBIResponse)(JSON.deserialize(res.getBody(), PBIResponse.class));
        System.debug('getDashboards() :: ' + result);

        return result.value;
    }

    @AuraEnabled
    public static List<PBIResult> getAllDashboards(String accessToken) {

        List<PBIObject> workspaces = getWorkspacesInfo(accessToken);
        List<PBIResult> ret;
        if(workspaces != null && workspaces.size() > 0) {
            ret = new List<PBIResult>();
            for(PBIObject w: workspaces) {
                PBIResult res = new PBIResult();
                res.workspace = w;
                List<PBIObject> dashboards = getDashboards(w.id, accessToken);
                if(dashboards != null && dashboards.size() > 0) {
                    List<PBIObject> dash = new List<PBIObject>();
                    for(PBIObject d: dashboards) {
                        dash.add(d);
                    }
                    res.dashboards = dash;
                }

                ret.add(res);
            }
        }

        System.debug('getAllDashboards:: ' + ret);
        return ret;
    }


    @AuraEnabled
    public static Map<String, List<Contact_Role_Service_Permission__c>> getAvailableDashboardCategoriesForUser(Id userId) {

        List<Contact_Roles__c> userRoles = Contact_Roles_Helper.getAllUserRoles(userId, 'GADM');
        Set<Id> roleIds = new Set<Id>();

        for(Contact_Roles__c role : userRoles) {
            roleIds.add(role.Id);
        }

        List<Contact_Role_Service_Permission__c> contactRolesServicePermissions = [SELECT Id, Name, Category__c, Contact_Role_Service__r.Contact_Role__r.Name, Url__c FROM Contact_Role_Service_Permission__c WHERE Contact_Role_Service__r.Contact_Role__c = :roleIds AND Contact_Role_Service__r.Service__r.Name = 'GADM' ORDER BY Category__c, Contact_Role_Service__r.Contact_Role__r.Name ASC];

        Map<String, List<Contact_Role_Service_Permission__c>> resultMap = new Map<String, List<Contact_Role_Service_Permission__c>>();

        for(Contact_Role_Service_Permission__c permission : contactRolesServicePermissions) {
            if(permission.Category__c != null) {
                if(resultMap.get(permission.Category__c) == null) {
                    resultMap.put(permission.Category__c, new List<Contact_Role_Service_Permission__c>{permission});
                }else{
                    resultMap.get(permission.Category__c).add(permission);
                }

            }else if(permission.Contact_Role_Service__r.Contact_Role__r.Name != null) {
                if(resultMap.get(permission.Contact_Role_Service__r.Contact_Role__r.Name) == null) {
                    resultMap.put(permission.Contact_Role_Service__r.Contact_Role__r.Name, new List<Contact_Role_Service_Permission__c>{permission});
                }else{
                    resultMap.get(permission.Contact_Role_Service__r.Contact_Role__r.Name).add(permission);
                }
            }
        }

        return resultMap;
    }

}