/*

This trigger is in charge to monitor Agencies Operation assignment. 
We don t want to have Operation assigned several time to the same agency.

*/
trigger AMS_Agency_OperationsTrigger on AMS_Agency_Operations__c (before insert, before update) {

    Integer i = 0;
    Integer j = 0;
    Integer k = 0;
    List<Integer> aI = new List<Integer>();
    Map<Id,AMS_Agency_Operations__c> mAMS_Agency_Operations = new Map<Id,AMS_Agency_Operations__c>();
    List<AMS_Agency_Operations__c> lAMS_Agency_OperationsUpdate = new List<AMS_Agency_Operations__c>();
    
    SET<Id> kAg = new SET<Id>();

    for(AMS_Agency_Operations__c AgOp : Trigger.new){
        kAg.add(AgOp.Agency__c);
    }
    List<AMS_Agency_Operations__c> lAMS_Agency_Operations = [SELECT id,Agency__c,Operation__c FROM AMS_Agency_Operations__c where Agency__c in :kAg]; 


    if(Trigger.isInsert || Trigger.isUpdate){
        for(AMS_Agency_Operations__c AgOp : Trigger.new){

            Boolean bError = False;
        
            for(AMS_Agency_Operations__c xAgOp : lAMS_Agency_Operations){
                
                if(AgOp.Agency__c == xAgOp.Agency__c && AgOp.Operation__c == xAgOp.Operation__c){
                    AgOp.Operation__c.addError('Agency Operation already exists');
                    bError = True;
                    break;
                }
            
            }

            if(bError == False){
                lAMS_Agency_OperationsUpdate.add(AgOp);
            }
        }

        
        AMS_AgencyUpdateHelper.agencyUpdate(lAMS_Agency_OperationsUpdate);
 
    }

    
}