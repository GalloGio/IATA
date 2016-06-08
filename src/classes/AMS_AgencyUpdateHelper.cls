public without sharing class AMS_AgencyUpdateHelper {

    public static Set<Id> accSentToExternalSystemFlag = new Set<Id>();

    public static void agencyRelathionshipUpdate(List<SObject> updatedRecords){
        List<AMS_Agency_Updates__c> agencyUpdateToInsert = new List<AMS_Agency_Updates__c>();
        Set<Id> setIds = new Set<Id>();//set of ids that are not agency relathionship
        Set<Id> idsToQuery = new Set<Id>();
        for(SObject obj: updatedRecords){
            if(obj.getSObjectType() != Schema.AMS_Agencies_relationhip__c.getSObjectType())
                setIds.add(obj.Id);
            else
                idsToQuery.add(obj.Id);
        }

        //get all records updated that are related to a agency relathionship
        Map<ID,AMS_Agencies_relationhip__c> agenciesRel = new Map<ID,AMS_Agencies_relationhip__c>([Select id from AMS_Agencies_relationhip__c where Hierarchy__c In :setIds]);
        idsToQuery.addAll(agenciesRel.keySet());

        //get the already existing Agency Updates related to the agency relationships to ensure that there is only one record in agency update
        //related to a agency relathionship
        List<AMS_Agency_Updates__c> aulist = [select id, RelationShip__c from AMS_Agency_Updates__c where RelationShip__c in :idsToQuery and Update_Type__c <> 'Update_Sent'];
        Set<Id> agenciesAlreadyUpdated = new Set<Id>();
        for(AMS_Agency_Updates__c au: aulist){
            agenciesAlreadyUpdated.add(au.RelationShip__c);
        }

        //remove agencies that already have an agency update record
        idsToQuery.removeAll(agenciesAlreadyUpdated);

        //create the Agency Update records
        for(Id toCreate: idsToQuery){
            AMS_Agency_Updates__c aux = new AMS_Agency_Updates__c(RelationShip__c = toCreate, Update_Type__c = 'Update');
            agencyUpdateToInsert.add(aux);
        }

        if(agencyUpdateToInsert.size() > 0)
            insert agencyUpdateToInsert;

        return;
    }

    public static void agencyUpdate(List<SObject> updatedRecords){
        List<AMS_Agency_Updates__c> agencyUpdateToInsert = new List<AMS_Agency_Updates__c>();
        Set<Id> agencyIds = new Set<Id>();
        for(SObject obj: updatedRecords){
            if(obj.getSObjectType() != Schema.Account.getSObjectType()){
                agencyIds.add((Id)obj.get('Account__c'));//all the fields relating to Agency in every other object as API name Agency__c
            }
            else
                agencyIds.add(obj.Id);
        }

        //get the already existing Agency Updates related to the agency to ensure that there is only one record in agency update related to the agency
        List<AMS_Agency_Updates__c> aulist = [select id, Account__c from AMS_Agency_Updates__c where Account__c in :agencyIds and Update_Type__c <> 'Update_Sent'];
        Set<Id> agenciesAlreadyUpdated = new Set<Id>();
        for(AMS_Agency_Updates__c au: aulist){
            agenciesAlreadyUpdated.add(au.Account__c);
        }

        //remove agencies that already have an agency update record
        agencyIds.removeAll(agenciesAlreadyUpdated);

        system.debug('accSentToExternalSystemFlag: ' + accSentToExternalSystemFlag);
        //remove agencies that have been updated on integration with SAP 
        agencyIds.removeAll(accSentToExternalSystemFlag);

        //create the Agency Update records
        for(Id toCreate: agencyIds){
            AMS_Agency_Updates__c aux = new AMS_Agency_Updates__c(Account__c = toCreate, Update_Type__c = 'Update');
            agencyUpdateToInsert.add(aux);
        }

        if(agencyUpdateToInsert.size() > 0)
            insert agencyUpdateToInsert;

        return;
    }

    public static void accountUpdate(List<AMS_Agency_Updates__c> sentUpdates) {   
        List<Account> integratedAccounts = new List<Account>();
        for(AMS_Agency_Updates__c updatedAgency : sentUpdates){
            integratedAccounts.add(new Account(Id = updatedAgency.Account__c, Sent_to_External_System__c = true));
        }

        update integratedAccounts;
    }
    
    
    
    /*AMSFTS: duplicated code
    public static void updateAccountWithParentId(List<AMS_Agencies_relationhip__c> relationships){
         //need to query again to retrieve some fields of parent object
        
        List<Id> agencyIds = new List<Id>(); 
        List<Id> relationshipids = new List<Id>(); 
        Map<Id,Id> AgChildToAgParent = new Map<Id,Id>(); 
        
        for(AMS_Agencies_relationhip__c h : relationships){
            relationshipids.add(h.id);
            AgChildToAgParent.put(h.Child_Account__c, h.Parent_Account__c);
            agencyIds.add(h.Child_Account__c);
            agencyIds.add(h.Parent_Account__c);
        }
        relationships = [SELECT Id, Child_Account__c, Parent_Account__c, Hierarchy__r.RecordType.DeveloperName FROM AMS_Agencies_relationhip__c WHERE Id IN :relationshipids];
        Map<Id,Account> IdToAgencies = new Map<Id,Account>([SELECT Name, Id FROM Account WHERE Id IN :agencyIds]); 
              

        
        // updating the child account with the id of the parent
        Map<Id,Account> accountsToUpdate = new Map<Id,Account>();
        for(AMS_Agencies_relationhip__c h : relationships){
            if(h.Hierarchy__r.RecordType.DeveloperName == 'MAIN'){
                Account ch = IdToAgencies.get(h.Child_Account__c);
                if(accountsToUpdate.get(ch.Id)!=null){
                    continue;
                }
                Id parentid = IdToAgencies.get(h.Parent_Account__c).Id;
                ch.ParentId = parentid;
                if(parentid!=null)
                    accountsToUpdate.put(ch.id,ch);
            }
        }
        
        if(accountsToUpdate.size()>0)
            update accountsToUpdate.values();
        
    }*/
}