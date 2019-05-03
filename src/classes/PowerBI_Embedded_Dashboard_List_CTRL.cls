public with sharing class PowerBI_Embedded_Dashboard_List_CTRL {

    /*public class PBIResponse {
        @AuraEnabled
        public List<PBIObject> value{get; set;}

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

    @AuraEnabled
    public static List<PBIObject> getWorkspacesInfo(String accessToken) {
        Http h = new Http();

        HttpRequest req = new HttpRequest();

        req.setEndpoint('https://api.powerbi.com/v1.0/myorg/groups');
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer '+accessToken);


        HttpResponse res = h.send(req);

        System.debug('raw: '+res);
        System.debug('body: '+res.getBody());

        PBIResponse result = (PBIResponse)(JSON.deserialize(res.getBody(), PBIResponse.class));

        System.debug(result);

        return result.value;
    }

    @AuraEnabled
    public static List<PBIObject> getDashboardsFromAllWorkspaces(String accessToken){
        List<PBIObject> workspaces = getWorkspacesInfo(accessToken);
        Map<PBIObject, List<PBIObject>> workspaceToReportsMap = new Map<PBIObject, List<PBIObject>>();
        if(workspaces != null && workspaces.size() > 0) {
            for(PBIObject w: workspaces) {
                List<PBIObject> dashboards = getDashboards(w.id, accessToken);
                if(dashboards != null && dashboards.size() > 0) {
                    for(PBIObject d: dashboards) {
                        if(workspaceToReportsMap.get(w) == null)
                            workspaceToReportsMap.put(w, new List<PBIObject>());

                        workspaceToReportsMap.get(w).add(d);
                    }
                }
            }
        }

        System.debug('±±± map looks like this: '+ workspaceToReportsMap);
        return null;
    }


    @AuraEnabled
    public static List<PBIObject> getDashboardsFromWorkspaces(List<String> workspaceIds, String accessToken){

        for(String workspaceId: workspaceIds) {
            Http h = new Http();

            HttpRequest req = new HttpRequest();

            req.setEndpoint('https://api.powerbi.com/v1.0/myorg/groups/'+workspaceId+'/dashboards');
            req.setMethod('GET');
            req.setHeader('Authorization', 'Bearer '+accessToken);


            HttpResponse res = h.send(req);

            System.debug('raw: '+res);
            System.debug('body: '+res.getBody());

            PBIResponse result = (PBIResponse)(JSON.deserialize(res.getBody(), PBIResponse.class));
        }
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

        System.debug('raw: '+res);
        System.debug('body: '+res.getBody());

        PBIResponse result = (PBIResponse)(JSON.deserialize(res.getBody(), PBIResponse.class));

        //gotPBIObjects = result.value;
        //for(PBIObject o:gotPBIObjects) {

        // gotPBIObjLabels.add(new SelectOption(o.id, o.displayName));
        //PBIIdEmbedUrlMap.put(o.id, o.embedUrl);

        //}

        System.debug('=====LABELS: '+result);


        return result.value;
    }*/


    @AuraEnabled
    public static boolean checkSessionCache(Id userId, String target) {
        String key = userId + target;
        Cache.SessionPartition sessionPartition = Cache.Session.getPartition('local.ServiceUsage');

        if(sessionPartition != null) {
            if(sessionPartition.contains(key)) {
                return true;
            }
        }
        return false;
    }

}