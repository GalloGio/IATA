public without sharing class Service_Usage_Tracker_CTRL {


    @AuraEnabled
    public static boolean saveNewCacheEntry(String userId, String key) {
        boolean result = false;

        String cacheKey = userId + key;
        
        Cache.SessionPartition sessionPartition = Cache.Session.getPartition('local.ServiceUsage');


        if(sessionPartition != null) {
            sessionPartition.put(cacheKey, true, 28800);
            result = true;
        }

        return result;
    }

    @AuraEnabled
    public static boolean saveUsageTracking(Id userId, String target, String service, String type) {
        return saveUsageTracking(userId, target, service, type, null);
    }

    @AuraEnabled
    public static boolean saveUsageTracking(Id userId, String target, String service, String type, string key) {
        Service_Usage__c usage = new Service_Usage__c();

        if(service == 'GADM'){
            usage.Account_Role__c = Contact_Roles_Helper.getUserAccountContactRoleForGadmUser(userId);
        }
        if(type == 'Dashboard' && (key instanceOf Id)) {

            usage.Dashboard_Id__c = Id.valueOf(key);
        }
        usage.User__c = userId;
        usage.Action_Date__c = Datetime.now();
        usage.Service__c = service;
        usage.Target__c = target;
        usage.Type__c = type;

        try{

            insert usage;
            return true;

        }catch(Exception e) {

            return false;

        }

    }


}