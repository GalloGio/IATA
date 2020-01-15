public without sharing class GADM_TabsContainerController {

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
	public static List<Contact_Roles__c> getUserGrantedRoles(Id userId) {
		return Contact_Roles_Helper.getGrantedUserRoles(userId, 'GADM');
	}
}
