/**
 * Trigger that checks there is only one active service for any given (service type, consumer) pair
 */
 
trigger trgCheckOnlyOneActiveService on Services_Rendered__c (before insert, before update, after insert, after update, after delete) {  

    set<String> setValidServicesRendered = AirlineSuspensionChildCaseCreationBatch.SET_VALID_PARITICIPATIONS;

    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        map<string,map<Id,list<Services_Rendered__c>>> IndexsPerIdAccount = new map<string,map<Id,list<Services_Rendered__c>>>();
        set<Id> accountIds = new set<Id>();
        List<Services_Rendered__c> listServices = new List<Services_Rendered__c>();
        map<string,list<Services_Rendered__c>>  servicesPerKey = new map<string,list<Services_Rendered__c>>();
        
        set<Id> servicesUpdated = new set<Id>();
        
        for (Services_Rendered__c sr : Trigger.new) {
            if(trigger.isUpdate)
                    servicesUpdated.add(sr.id);  
            
            if(setValidServicesRendered.contains(sr.Services_Rendered_Type__c) &&
                sr.Services_Rendered_Status__c == 'Active' ){
                 
                  String   key = sr.Services_Rendered_to_Airline__c + sr.Services_Rendered_Type__c + sr.Services_Rendered_By__c;
                    if( servicesPerKey.get(key) == null)
                      servicesPerKey.put(key, new list<Services_Rendered__c>());
                   servicesPerKey.get(key).add(sr);
                 
                }
        
        }
        
        for(String Key: servicesPerKey.keySet()){
                if(servicesPerKey.get(key).size()> 1){
                    for(Services_Rendered__c ser:servicesPerKey.get(key)){
                        ser.addError('The data you are trying to insert has duplicates'); // THIS HAPPENS WHEN THE LIST OF SERVIECES ENTERED HAS DUPLICATES
                    }
                    servicesPerKey.remove(key);     
                 } else {
                     for(Services_Rendered__c ser:servicesPerKey.get(key))
                         accountIds.add(ser.Services_Rendered_to_Airline__c);  
                 }
                
         }   
                                        
        if(!servicesPerKey.isEmpty()){

            for(Services_Rendered__c sr:[SELECT Id, Services_Rendered_to_Airline__c,Services_Rendered_Type__c,Services_Rendered_By__c
                                                FROM Services_Rendered__c 
                                                WHERE Services_Rendered_to_Airline__c In:accountIds
                                                AND  Services_Rendered_Status__c = 'Active'
                                                AND ID NOT IN: servicesUpdated]){
                                                
                                                string key = sr.Services_Rendered_to_Airline__c + sr.Services_Rendered_Type__c + sr.Services_Rendered_By__c;
                               
                                                if(servicesPerKey.get(key)<>null) {
                                                for(Services_Rendered__c ser:servicesPerKey.get(key))
                                                   ser.addError('Error:Service already exists!');
                                                 ///  throw new transformationException('this is my falut');
                                                    }
        
                                                }

        }
    }
    
    // update the Airline CASS / BSP Participations field at Airline HQ account level
    if (Trigger.isAfter) {
    	ServiceRenderedCaseLogic.CalculateAirlineParticipations(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.isDelete);
    }
}