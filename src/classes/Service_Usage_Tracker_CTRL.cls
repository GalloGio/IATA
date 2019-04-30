public without sharing class Service_Usage_Tracker_CTRL {


    @AuraEnabled
    public static boolean saveNewCacheEntry(String userId, String key) {
        boolean result = false;

        String cacheKey = userId + key;
        System.debug('cacheKey:: ' + cacheKey);
        Cache.SessionPartition sessionPartition = Cache.Session.getPartition('local.ServiceUsage');

        /*Set<String> allKeys = sessionPartition.getKeys();
        System.debug('all keys:: ' + allKeys);*/

        if(sessionPartition != null) {
            sessionPartition.put(cacheKey, true, 28800);
            result = true;
        }

        return result;
    }


    @AuraEnabled
    public static boolean saveUsageTracking(Id userId, String target, String service, String type) {
        Service_Usage__c usage = new Service_Usage__c();

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