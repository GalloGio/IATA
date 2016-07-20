trigger AMS_AgencyRelathionshipTrigger on AMS_Agencies_relationhip__c (after insert, after update) {
    List<AMS_Agencies_relationhip__c > relationInMainHierarchy = new List<AMS_Agencies_relationhip__c >();
    
    //delete previous relation ship for agencies in Main Hierarchies
    List<String> hierarchiesIds = new List<String>();
    Id rtMain = Schema.SObjectType.AMS_Agencies_Hierarchy__c.getRecordTypeInfosByName().get('MAIN').getRecordTypeId();
    List<String> newRelationChildrenIds = new List<String>();
    for(AMS_Agencies_relationhip__c r:Trigger.new){
        newRelationChildrenIds.add(r.Child_Agency__c);
        hierarchiesIds.add(r.Hierarchy__c);
        
    }
    //look for relationship in trigger in a main H
    Map<Id,AMS_Agencies_Hierarchy__c> mainHierarchies = new Map<Id,AMS_Agencies_Hierarchy__c>( [select Id from AMS_Agencies_Hierarchy__c where recordTypeId = :rtmain and Id in :hierarchiesIds ]);

    
    if(Trigger.isUpdate){
        AMS_AgencyUpdateHelper.agencyRelathionshipUpdate(Trigger.new);
    }
    
    if(Trigger.isInsert){
        AMS_AgencyUpdateHelper.updateAccountWithParentId(Trigger.new);
        
        //look for relation with same children thant trigger content and in  same main H but not concerned by this trigger
        List<AMS_Agencies_relationhip__c > oldrelation2delete = [select id from AMS_Agencies_relationhip__c  where Child_Agency__c in :newRelationChildrenIds and (not Id in :Trigger.newMap.keyset()) and Hierarchy__c in :mainHierarchies.keySet() ];
        //delete them
        delete oldrelation2delete ;
     }
        
     //jfo 16/10/15 hotfix to set ChildAgency;Account.Parent to ParentAgency;Account
     Map<String,String> parentChildrenMap = new map<String,String>();
     for(AMS_Agencies_relationhip__c r:trigger.new){
         if(mainHierarchies.get(r.Hierarchy__c )!=null )
             parentChildrenMap.put(r.Parent_agency__c,r.Child_Agency__c);
     }  
     if(parentChildrenMap.size()>0){
         Map<Id, AMS_Agency__c> parentAgencies = new Map<Id, AMS_Agency__c>([select Id, Account__c, Account__r.Id, Account__r.ParentId from Ams_agency__c where Id in :parentChildrenMap.keySet()]);
         Map<Id, AMS_Agency__c> childAgencies = new Map<Id, AMS_Agency__c>([select Id, Account__c, Account__r.Id, Account__r.ParentId from Ams_agency__c where Id in :parentChildrenMap.values()]);
         List<Account> accounts2update = new List<Account>();
         for(String parentAgencyId:parentChildrenMap.keySet()){
             Account parentAccount =  parentAgencies.get(parentAgencyId).Account__r;
             Account childAccount =  childAgencies.get(parentChildrenMap.get(parentAgencyId)).Account__r;
             childAccount.parentId = parentAccount .Id;
             accounts2update .add(childAccount);
         } 
         if(accounts2update.size()>0)
             update accounts2update ;
     }
    
}