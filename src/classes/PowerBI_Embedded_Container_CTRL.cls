public with sharing class PowerBI_Embedded_Container_CTRL {

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
        public String access_token {get; set;}
        public String refresh_token {get; set;}
        public String expires_on {get;set;}

    }

    public static String CUSTOM_SETTING_NAME = 'PowerBI account';

    @AuraEnabled
    public static String getAccessToken() {
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
        System.debug('result.access_token:: ' + result);

        return result.access_token;
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



        return result.value;
    }

    @AuraEnabled
    public static Map<PBIObject, List<PBIObject>> getDashboardsFromAllWorkspaces(String accessToken){
        return null;
    }

    @AuraEnabled
    public static List<PBIObject> getDashboards(String workspaceId, String accessToken){
        Http h = new Http();

        HttpRequest req = new HttpRequest();

        req.setEndpoint('https://api.powerbi.com/v1.0/myorg/groups/'+workspaceId+'/dashboards');
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer '+accessToken);


        HttpResponse res = h.send(req);

        PBIResponse result = (PBIResponse)(JSON.deserialize(res.getBody(), PBIResponse.class));

        //gotPBIObjects = result.value;
        //for(PBIObject o:gotPBIObjects) {

        // gotPBIObjLabels.add(new SelectOption(o.id, o.displayName));
        //PBIIdEmbedUrlMap.put(o.id, o.embedUrl);

        //}




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


        return ret;
    }

}