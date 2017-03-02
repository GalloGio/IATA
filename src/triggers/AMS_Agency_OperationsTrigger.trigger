/*

This trigger is in charge to monitor Agencies Operation assignment. 
We don t want to have Operation assigned several time to the same agency.

*/
trigger AMS_Agency_OperationsTrigger on AMS_Agency_Operations__c (before insert, before update) {

    if(!AMS_TriggerExecutionManager.checkExecution(AMS_Agency_Operations__c.getSObjectType(), 'AMS_Agency_OperationsTrigger')) { return; }
    
    if(Trigger.isInsert || Trigger.isUpdate){

        Set<Id> kAg = new Set<Id>();

        for(AMS_Agency_Operations__c ag : Trigger.new){
            if(
                ag.Account__c != null && ag.Operation__c != null 
                && 
                (Trigger.isInsert || ag.Account__c != Trigger.oldMap.get(ag.Id).Account__c || ag.Operation__c != Trigger.oldMap.get(ag.Id).Operation__c)
            ){
                kAg.add(ag.Account__c);
            }
        }

        if(kAg.isEmpty()) return;
        
        //FM - 22-09-2016 - stop creating "agency update" Records
        //List<AMS_Agency_Operations__c> lAMS_Agency_OperationsUpdate = new List<AMS_Agency_Operations__c>();

        Set<String> operationsCheck = new Set<String>();
        for(AMS_Agency_Operations__c ag : [SELECT id,Account__c,Operation__c FROM AMS_Agency_Operations__c where Account__c in :kAg AND Operation__c != '']){
            operationsCheck.add(ag.Account__c+''+ag.Operation__c);
        }

        for(AMS_Agency_Operations__c ag : Trigger.new){
                
            if(!operationsCheck.add(ag.Account__c+''+ag.Operation__c)) ag.Operation__c.addError('Agency Operation already exists');
            //FM - 22-09-2016 - stop creating "agency update" Records
            //else lAMS_Agency_OperationsUpdate.add(ag);
        }
        
        //FM - 22-09-2016 - stop creating "agency update" Records
        //AMS_AgencyUpdateHelper.agencyUpdate(lAMS_Agency_OperationsUpdate);
    } 
}