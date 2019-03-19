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
        
        for(ContentDocumentLink doc : newList) {
            if(doc.LinkedEntityId.getSObjectType() == bannerObject) {
                bannerContent.add(doc);
            }
        }

        if(!bannerContent.isEmpty()) {
            Id assetLibrary = [SELECT Id FROM ContentWorkspace WHERE DeveloperName = 'sfdc_asset_company_assets'].Id;

            for(ContentDocumentLink doc : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :assetLibrary]) {
                contents.add(doc.ContentDocumentId);
            }

            for(ContentDocumentLink doc : bannerContent) {
                if(!contents.contains(doc.ContentDocumentId)) {
                    doc.Visibility = 'AllUsers';
                    documentsToInsert.add(
                        new ContentDocumentLink(
                            ContentDocumentId = doc.ContentDocumentId, 
                            LinkedEntityId = assetLibrary,
                            ShareType = 'I',
                            Visibility  ='AllUsers'
                        )
                    );                    
                }       
            }

            insert documentsToInsert; 
        }
    }
}