public without sharing class GADM_TabsContainerController {

    @AuraEnabled
    public static boolean checkSessionCache(Id userId, String key) {
        /*System.debug('userID:: ' + userId);
        System.debug('target:: ' + key);*/
        String cacheKey = userId + key;
        Cache.SessionPartition sessionPartition = Cache.Session.getPartition('local.ServiceUsage');

        /*Set<String> allKeys = sessionPartition.getKeys();
        System.debug('all keys:: ' + allKeys);*/

        if(sessionPartition != null) {
            if(sessionPartition.contains(cacheKey)) {
                return true;
            }
        }
        return false;
    }

}