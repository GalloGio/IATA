public without sharing class PowerBI_Embedded_Container_CTRL {


    @AuraEnabled
    public static boolean checkSessionCache(Id userId, String key) {

        String cacheKey = userId + key;
        Cache.SessionPartition sessionPartition = Cache.Session.getPartition('local.ServiceUsage');

        if(sessionPartition != null) {
            if(sessionPartition.contains(cacheKey)) {
                return true;
            }
        }
        return false;
    }


    @AuraEnabled
    public static Map<String, List<Contact_Role_Service_Permission__c>> getAvailableDashboardCategoriesForUser(Id userId) {

        List<Contact_Roles__c> userRoles = Contact_Roles_Helper.getGrantedUserRoles(userId, 'GADM');
        List<Contact_Roles__c> businessUnits = Contact_Roles_Helper.getGrantedBusinessUnits(userId, 'GADM');
        Set<Id> roleIds = new Set<Id>();

        for(Contact_Roles__c role : userRoles) {
            roleIds.add(role.Id);
        }

        for(Contact_Roles__c bu : businessUnits) {
            roleIds.add(bu.Id);
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