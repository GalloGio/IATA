/*
this trigger is in cahrge of setting agency Operations is country changed
*/
trigger AMS_AgencyOperationTrigger on AMS_Agency__c (after insert, after update) {

  /*  Id rtpax = Schema.SObjectType.AMS_Agency__c.getRecordTypeInfosByName().get('PASSENGER').getRecordTypeId();
    Id rtcargo  =  Schema.SObjectType.AMS_Agency__c.getRecordTypeInfosByName().get('CARGO').getRecordTypeId();
  if(Trigger.isUpdate){
        //FM - 22-09-2016 - stop creating "agency update" Records
        //AMS_AgencyUpdateHelper.agencyUpdate(Trigger.new);

        Set<String> accountIds = new Set<String>();
        for(AMS_Agency__c ag: Trigger.new){
            accountIds.add(ag.Account__c);
        }
        //AMS_AgencyHelper.updateAccounts(Trigger.oldMap, Trigger.newMap, accountIds);
    }
        
        
    //Operations assignment update:
    //we want to set all operation to a dedicated Operation based on their Countries
    List<AMS_Agency__c > operationHelpercandidate = new List<AMS_Agency__c >();
    
        //cannot be working on creation because need to have a primary address linled
    
    if(Trigger.isInsert)
        for(AMS_Agency__c  ag:Trigger.new){
            if(ag.Country__c!=null && ag.IATACode__c !=null ){
                system.debug('[AMS_AgencyTrigger] updated Primary Address for Agency '+ag.Id);
                operationHelpercandidate.add(ag);
            }
        }
    else if(Trigger.isUpdate){
        for(AMS_Agency__c  ag:Trigger.new){
            //consider agency with iata code with NEW primary Address  OR agencies with Address with new iata code
            if((ag.Country__c!=trigger.oldMap.get(ag.Id).Country__c && ag.IATACode__c!=null) || (ag.Country__c!=null && ag.IATACode__c!=null && trigger.oldMap.get(ag.Id).IATACode__c==null)){
                system.debug('[AMS_AgencyTrigger] updated Primary Address for Agency '+ag.Id);
                operationHelpercandidate.add(ag);
            }
        }
    }
    if(operationHelpercandidate.size()>0){
        system.debug('[AMS_AgencyTrigger] updating Operation for '+operationHelpercandidate.size()+' Agencies');
        AMS_AgencyHelper.updateAgenciesOperations(operationHelpercandidate);
    }*/
}