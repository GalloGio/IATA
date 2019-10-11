public without sharing class PowerBI_Embedded_Container_CTRL {

    private static final String DEFAULT_PICTURE_NAME = 'default';


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

    private static Map<String, List<Contact_Role_Service_Permission__c>> getAvailableDashboardCategoriesForUser(Id userId) {

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

    @AuraEnabled
    public static List<CategoryWrapper> getCategories(Id userId) {

        List<CategoryWrapper> toReturn = new List<CategoryWrapper>();

        if(String.isNotBlank(userId)) {

            Map<String, List<Contact_Role_Service_Permission__c>> permissionsMap = getAvailableDashboardCategoriesForUser(userId);

            if(! permissionsMap.isEmpty()) {

                List<ContentDocument> contentDocuments = new List<ContentDocument>();

                List<GADM_Settings__mdt> gadmSettings = [SELECT Id, Files_Folder__c FROM GADM_Settings__mdt WHERE DeveloperName = 'GADM' LIMIT 1];
                if(! gadmSettings.isEmpty()) {
                    if(String.isNotBlank(gadmSettings[0].Files_Folder__c)) {
                        List<ContentWorkspace> workspace = [SELECT Id FROM ContentWorkspace WHERE Name = :gadmSettings[0].Files_Folder__c LIMIT 1];
                        if(! workspace.isEmpty()) {
                            contentDocuments = [SELECT Id, Title FROM ContentDocument WHERE ParentId = :workspace[0].Id];
                        }
                    }

                }

                Map<String, String> nameToDocumentIdMap = new Map<String, String>();
                for(ContentDocument document : contentDocuments) {
                    nameToDocumentIdMap.put(document.Title.toLowerCase(), document.Id);
                }

                //if used do not have access to category images, show categories without images
                if(nameToDocumentIdMap.isEmpty()){

                    for(String category : permissionsMap.keySet()) {
                        CategoryWrapper wrapper = new CategoryWrapper();
                        wrapper.name = category;
                        wrapper.permissions = permissionsMap.get(category);
                        toReturn.add(wrapper);
                    }
                    return toReturn;

                }


                for(String category : permissionsMap.keySet()) {

                    CategoryWrapper wrapper = new CategoryWrapper();
                    wrapper.name = category;
                    wrapper.permissions = permissionsMap.get(category);

                    if(nameToDocumentIdMap.get(category.toLowerCase())== null) {
                        if(nameToDocumentIdMap.get(DEFAULT_PICTURE_NAME) == null) {
                            toReturn.add(wrapper);
                            continue;
                        }
                        wrapper.pictureUrl = '/sfc/servlet.shepherd/document/download/' + nameToDocumentIdMap.get(DEFAULT_PICTURE_NAME);
                    }else{
                        wrapper.pictureUrl = '/sfc/servlet.shepherd/document/download/' + nameToDocumentIdMap.get(category.toLowerCase());
                    }

                    toReturn.add(wrapper);
                }


            }
        }

        return toReturn;
    }



    public class CategoryWrapper {
        @AuraEnabled
        public String pictureUrl {get; set;}
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public List<Contact_Role_Service_Permission__c> permissions {get; set;}
    }

}