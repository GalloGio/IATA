
public with sharing class ContentDocumentLinkTriggerHandler {
    public List<ContentDocumentLink> newList = (List<ContentDocumentLink>) Trigger.new;
    public List<ContentDocumentLink> oldList = (List<ContentDocumentLink>) Trigger.old;
    public Map<Id, ContentDocumentLink> newMap = (Map<Id, ContentDocumentLink>) Trigger.newMap;
    public Map<Id, ContentDocumentLink> oldMap = (Map<Id, ContentDocumentLink>) Trigger.oldMap;

    /* 
    * Execution Contexts
    */    

    public void onBeforeInsert() {
        updateVisibilityAccess();
    }

    public void onAfterInsert() {}

    public void onBeforeUpdate() {}

    public void onAfterUpdate() {}

    public void onBeforeDelete() {}

    public void onAfterDelete() {}

    public void onUndelete() {}

    /* 
    * Action Methods
    */    

    /* 
    * @description Include contents from sObject "ISSP_Banner__c" in Asset Library, so that all Portal Users will be able to see these contents
    * @description Content will only be shared with Asset Library if there isn't any reference to the content being uploaded
    * @params
    * @return
    */
    public void updateVisibilityAccess() {
        Set<Id> contents = new Set<Id>();
        List<ContentDocumentLink> bannerContent = new List<ContentDocumentLink>();
        List<ContentDocumentLink> documentsToInsert = new List<ContentDocumentLink>();
        Schema.SObjectType bannerObject = Schema.ISSP_Banner__c.getSObjectType();

        for (ContentDocumentLink doc : newList) {
            if (doc.LinkedEntityId.getSObjectType() == bannerObject) {
                bannerContent.add(doc);
            }
        }

        if (!bannerContent.isEmpty()) {
            Id assetLibrary = [SELECT Id FROM ContentWorkspace WHERE DeveloperName = 'sfdc_asset_company_assets'].Id;

            for (ContentDocumentLink doc : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :assetLibrary]) {
                contents.add(doc.ContentDocumentId);
            }

            for (ContentDocumentLink doc : bannerContent) {
                if (!contents.contains(doc.ContentDocumentId)) {
                    doc.Visibility = 'AllUsers';
                    documentsToInsert.add(
                            new ContentDocumentLink(
                                    ContentDocumentId = doc.ContentDocumentId,
                                    LinkedEntityId = assetLibrary,
                                    ShareType = 'I',
                                    Visibility = 'AllUsers'
                            )
                    );
                }
            }

            if (!documentsToInsert.isEmpty()) {
                insert documentsToInsert;
            }
        }
    }

    public static void shareExternally(List<ContentDocumentLink> newValues){
        Set<Id> objectIds = gadmParentsToBeSharedExternally(newValues);
        for(ContentDocumentLink cdl: newValues){
            if(objectIds.contains(cdl.LinkedEntityId)){
                cdl.ShareType = 'I';
                cdl.Visibility='AllUsers';
            }
        }
    }


    private static Set<Id> gadmParentsToBeSharedExternally(List<ContentDocumentLink> newValues){
        Map<string, string> prefixWithObjectName = allowedGADMObjectIdPrefixes();
        Map<string, List<Id>> objectsByPrefix = new Map<string, List<Id>>();
        for(ContentDocumentLink cdl: newValues){
            string prefix = ('' + cdl.LinkedEntityId).substring(0,3);
            if(prefixWithObjectName.keySet().contains(prefix)){
                string objName = prefixWithObjectName.get(prefix);
                List<Id> objects = objectsByPrefix.get(objName);
                if(objects != null){
                    objects.add(cdl.LinkedEntityId);
                } else {
                    objectsByPrefix.put(objName, new List<ID>{cdl.LinkedEntityId});
                }
            }
        }
        Set<Id> objectsToBeShared = new Set<Id>();
        List<Id> serviceNotificationIds = objectsByPrefix.get('Service_Notification__c');
        if(serviceNotificationIds != null) {
            List<Service_Notification__c> serviceNotifications = [SELECT Id FROM Service_Notification__c WHERE Service__r.Name = 'GADM' AND Id IN : serviceNotificationIds];
            for(Service_Notification__c sn: serviceNotifications){
                objectsToBeShared.add(sn.Id);
            }
        }

        List<Id> contactRoleServiceIds = objectsByPrefix.get('Contact_Role_Service__c');
        if(contactRoleServiceIds != null) {
            List<Contact_Role_Service__c> contactRoleServices = [SELECT Id FROM Contact_Role_Service__c WHERE Service__r.Name = 'GADM' AND Id IN : contactRoleServiceIds];
            for(Contact_Role_Service__c crs: contactRoleServices){
                objectsToBeShared.add(crs.Id);
            }
        }

        List<Id> contactRoleServicePermissionIds = objectsByPrefix.get('Contact_Role_Service_Permission__c');
        system.debug(contactRoleServicePermissionIds);
        if(contactRoleServicePermissionIds != null) {
            List<Contact_Role_Service_Permission__c> contactRoleServicePermissions = [SELECT Id FROM Contact_Role_Service_Permission__c WHERE Contact_Role_Service__r.Service__r.Name = 'GADM' AND Id IN : contactRoleServicePermissionIds];
            for(Contact_Role_Service_Permission__c crsp: contactRoleServicePermissions){
                objectsToBeShared.add(crsp.Id);
            }
        }

        return objectsToBeShared;

    }

    public static Map<string, string> allowedGADMObjectIdPrefixes(){
        List<string> objectNames = new List<String>{'Service_Notification__c', 'Contact_Role_Service__c', 'Contact_Role_Service_Permission__c'};
        Map<string,string> prefixes = new Map<string,string>();
        for(string objectName: objectNames){
            prefixes.put(getObjectIdPrefix(objectName), objectName);
        }
        return prefixes;
    }
    public static string getObjectIdPrefix(string objectName){
        Map<String, Schema.SObjectType> m  = Schema.getGlobalDescribe() ;
        Schema.SObjectType s = m.get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        String keyPrefix = r.getKeyPrefix();
        return keyPrefix;

    }
}