/*

This trigger is in charge to monitor Agencies Operation assignment. 
We don t want to have Operation assigned several time to the same agency.

*/
trigger AMS_Agency_OperationsTrigger on AMS_Agency_Operations__c (before insert, before update) {

    if(!AMS_TriggerExecutionManager.checkExecution(AMS_Agency_Operations__c.getSObjectType(), 'AMS_Agency_OperationsTrigger')) { return; }
    
    Integer i = 0;
    Integer j = 0;
    Integer k = 0;
    List<Integer> aI = new List<Integer>();
    Map<Id,AMS_Agency_Operations__c> mAMS_Agency_Operations = new Map<Id,AMS_Agency_Operations__c>();
    List<AMS_Agency_Operations__c> lAMS_Agency_OperationsUpdate = new List<AMS_Agency_Operations__c>();
    
    SET<Id> kAg = new SET<Id>();

    for(AMS_Agency_Operations__c AgOp : Trigger.new){
        kAg.add(AgOp.Account__c);
    }
    List<AMS_Agency_Operations__c> lAMS_Agency_Operations = [SELECT id,Account__c,Operation__c FROM AMS_Agency_Operations__c where Account__c in :kAg]; 


    if(Trigger.isInsert || Trigger.isUpdate){
        for(AMS_Agency_Operations__c AgOp : Trigger.new){

            Boolean bError = False;
        
            for(AMS_Agency_Operations__c xAgOp : lAMS_Agency_Operations){
                
                if(AgOp.Account__c == xAgOp.Account__c && AgOp.Operation__c == xAgOp.Operation__c){
                    AgOp.Operation__c.addError('Agency Operation already exists');
                    bError = True;
                    break;
                }
            
            }

            if(bError == False){
                lAMS_Agency_OperationsUpdate.add(AgOp);
            }
        }

        
        //FM - 22-09-2016 - stop creating "agency update" Records
        //AMS_AgencyUpdateHelper.agencyUpdate(lAMS_Agency_OperationsUpdate);
 
    }

    
}