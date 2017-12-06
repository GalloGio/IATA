trigger AMS_AgencyAChangeCode on Agency_Applied_Change_code__c (before insert, after insert, after update/*before insert, before update*/) {

    if(!AMS_TriggerExecutionManager.checkExecution(Agency_Applied_Change_code__c.getSObjectType(), 'AMS_AgencyAChangeCode')) { return; }
    
    //DTULLO: Prevent trigger from running more than once
    if(AMS_AgencyAChangeCodeHandler.firstRun == true){
        AMS_AgencyAChangeCodeHandler.firstRun = false;
        if(Trigger.isBefore) {
            if(Trigger.isInsert){
                System.debug('Entering handleBeforeInsert');
                AMS_AgencyAChangeCodeHandler.handleBeforeInsert(Trigger.new);
                System.debug('Finished handleBeforeInsert');

            }
            
            if(Trigger.isUpdate){
                AMS_AgencyAChangeCodeHandler.handleBeforeUpdate(Trigger.new);
            }
        }
    
        if(Trigger.isAfter) {
            if(Trigger.isUpdate)
                AMS_AgencyAChangeCodeHandler.handleAfterUpdate(Trigger.new, trigger.OldMap);
            if(Trigger.isInsert){
                AMS_AgencyAChangeCodeHandler.handleAfterInsert(Trigger.new);
                new ANG_AgencyAChangeCodeTriggerHandler().onAfterInsert();
            }

        }
        AMS_AgencyAChangeCodeHandler.firstRun = true;
    }


/*
    List<Agency_Applied_Change_code__c> aACCtoUpdate = new List<Agency_Applied_Change_code__c>();

    Set<Id> agencyIds = new Set<Id>();

    for(Agency_Applied_Change_code__c aacc : Trigger.New){
        
        if(aacc.Active__c){
            
            agencyIds.add(aacc.Account__c);
        }
    }

    if(agencyIds.size() > 0){

        List<Agency_Applied_Change_code__c> elementsToUpdate = new List<Agency_Applied_Change_code__c>();
        for(Agency_Applied_Change_code__c aacc : [select id, Active__c , Account__c from Agency_Applied_Change_code__c where Active__c = true AND Account__c IN :agencyIds]){
    
            if(Trigger.newMap.containsKey(aacc.id) == false) {
                
                aacc.Active__c = false;
                elementsToUpdate.add(aacc);
            }   
        }
    
        if(elementsToUpdate.size() > 0){
            
            update elementsToUpdate;
        }
    }
    */

/*
    if(trigger.isInsert)
        System.debug('Processing before insert in AMS_AgencyAChangeCode trigger.');
    if(trigger.isUpdate)
        System.debug('Processing before update in AMS_AgencyAChangeCode trigger.');

    List<Agency_Applied_Change_code__c> aACCtoUpdate = new List<Agency_Applied_Change_code__c>();

    Set<Id> agencyIds = new Set<Id>();
    Set<Id> aaccIds = new Set<Id>();

    for(Agency_Applied_Change_code__c aacc: Trigger.New){
        agencyIds.add(aacc.Account__c);
    }

    // get all Agency Applied Change code's that have agencies regarding this update/insert
    List<Agency_Applied_Change_code__c> lastActiveCodeList = [select id, Active__c , Account__c from Agency_Applied_Change_code__c where Active__c = true AND Account__c IN :agencyIds];
    
    if(trigger.isInsert){
        System.debug('Processing before insert in AMS_AgencyAChangeCode trigger.');
        System.debug('LastActiveCodeList in INSERT size is ' + lastActiveCodeList.size());
    }
    
    if(trigger.isUpdate){
        System.debug('Processing before update in AMS_AgencyAChangeCode trigger.');
        System.debug('LastActiveCodeList in UPDATE size is ' + lastActiveCodeList.size());
    }


    


    Map<Id, Agency_Applied_Change_code__c> agencyToAppliedChangeCode = new Map<Id, Agency_Applied_Change_code__c>();

    for(Agency_Applied_Change_code__c aacc:lastActiveCodeList){
        agencyToAppliedChangeCode.put(aacc.Account__c, aacc);
    }

    for(Agency_Applied_Change_code__c acc : Trigger.New) {
    
        // if this agency has an active flag, we should update all the other agencies applied change code to inactive
        if(acc.Active__c == true){

            Agency_Applied_Change_code__c toUpdate = agencyToAppliedChangeCode.get(acc.Account__c);

            if(toUpdate != null && !aaccIds.contains(toUpdate.Id)){
                System.debug('Preparing to set AACC ' + toUpdate.Id + ' active flag to false.');
                toUpdate.Active__c = false;
                aACCtoUpdate.add(toUpdate);
                aaccIds.add(toUpdate.Id);
            }
        }
    }

    if(aACCtoUpdate.size() > 0){
        System.debug('Updating ' + aACCtoUpdate.size() + ' change codes.');
        update aACCtoUpdate;
    }
    
    /*if(Trigger.isBefore)
        if(Trigger.isInsert)
            AMS_AgencyAChangeCodeTriggerHandler.handleBeforeInsert(Trigger.new);
        if(Trigger.isUpdate)
            AMS_AgencyAChangeCodeTriggerHandler.handleBeforeUpdate(Trigger.new);*/

    
}