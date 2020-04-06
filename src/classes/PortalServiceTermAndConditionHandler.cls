public without sharing class PortalServiceTermAndConditionHandler
{

    /****************************************************************************************************
            Call trigger method corresponding to trigger event
    ****************************************************************************************************/
    public static void triggerHandler() {
        if (trigger.isBefore){
            if (trigger.isInsert){
                onBeforeInsert();
            }
            else if (trigger.isUpdate){
                onBeforeUpdate();
            }
        }
        if (trigger.isAfter){
            if (trigger.isInsert){
                onAfterInsert();
            }
            else if (trigger.isUpdate){
                onAfterUpdate();
            }
        }
    }
    
    private static void onBeforeInsert() {
        setInitialVersion();
    }

    private static void onBeforeUpdate(){
        setInitialVersion();
    }

    private static void onAfterInsert() {
        updateRelatedTermsAndConditions();
    }

    private static void onAfterUpdate(){
        updateRelatedTermsAndConditions();
    }

    private static void setInitialVersion(){
        for(Term_And_Condition__c tc : (List<Term_And_Condition__c>) trigger.new){
            if(tc.Previous_Version__c == null){
                tc.Initial_Version__c = null;
            }
            else{
                System.debug('previous version Id : ' + tc.Previous_Version__c);
                Term_And_Condition__c previousVersion = [SELECT Initial_Version__c FROM Term_And_Condition__c WHERE Id =: tc.Previous_Version__c];
                if(previousVersion.Initial_Version__c == null){
                    tc.Initial_Version__c = tc.Previous_Version__c;
                }
                else{
                    tc.Initial_Version__c = previousVersion.Initial_Version__c;
                }
            }
        }
    }

    private static void updateRelatedTermsAndConditions(){
        // If record is set as the latest, update related terms and conditions and set the Is_Latest__c value to false
        // Furthermore, we have to update the Service Term and Condition records referencing the old versions
        
        // Consider only the records in the trigger with Is_Latest__c = true
        Map<Id,Id> tcInitialMap = new Map<Id,Id>();
        
        for(Term_And_Condition__c tc : (List<Term_And_Condition__c>) trigger.new){
            if(tc.Is_Latest__c){
                if(tc.Initial_Version__c == null){
                    tcInitialMap.put(tc.Id, tc.Id);
                }
                else{
                    tcInitialMap.put(tc.Initial_Version__c, tc.Id);
                }
            }
        }

        // List of T&C records for which Is_Latest__c must be set to false
        List<Term_And_Condition__c> tcsToUpdate = new List<Term_And_Condition__c>();

        // Map needed to reparent Service Term and Condition records targeting T&C that will be updated
        Map<Id,Id> reparentingMap = new Map<Id,Id>();

        for(Term_And_Condition__c relatedTc : [SELECT Id, Initial_Version__c, Is_Latest__c FROM Term_And_Condition__c WHERE Id in : tcInitialMap.keySet() OR Initial_Version__c in : tcInitialMap.keySet()]){
            // update the records with Is_Latest__c = true, except the records in the trigger
            Id initialVersionId = relatedTc.Initial_Version__c != null ? relatedTc.Initial_Version__c : relatedTc.Id;

            if(tcInitialMap.get(initialVersionId) != relatedTc.Id && relatedTc.Is_Latest__c){
                relatedTc.Is_Latest__c = false;
                tcsToUpdate.add(relatedTc);
                reparentingMap.put(relatedTc.Id, tcInitialMap.get(initialVersionId));
            }
        }

        System.debug('reparenting map keyset: ' + reparentingMap.keySet());

        System.debug('Term and Condition records to update : ' + tcsToUpdate.size());
        if(!tcsToUpdate.isEmpty()){
            // Update Service Term and Condition records
            List<Service_Term_and_Condition__c> stcsToUpdate = new List<Service_Term_and_Condition__c>();
            for(Service_Term_and_Condition__c stc : [SELECT Id, Term_Condition__r.Id FROM Service_Term_and_Condition__c WHERE Term_Condition__c in : reparentingMap.keySet()]){
                stcsToUpdate.add(new Service_Term_and_Condition__c(
                    Id = stc.Id,
                    Term_Condition__c = reparentingMap.get(stc.Term_Condition__r.Id)
                ));
            }

            System.debug('Service Term and Condition records to update : ' + stcsToUpdate.size());
            if(!stcsToUpdate.isEmpty()){
                update stcsToUpdate;
            }

            // Update T&C records
            update tcsToUpdate;
        }
    }
}