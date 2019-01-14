trigger AMS_AgencyUpdatesTrigger on AMS_Agency_Updates__c (
	    before insert, 
	    before update, 
	    before delete, 
	    after insert, 
	    after update, 
	    after delete, 
	    after undelete)
    {


        if(trigger.isAfter && trigger.isInsert){
            new ANG_agencyEventTriggerHandler().onAfterInsert();
        }
    	
        if(trigger.isAfter && trigger.isUpdate){

            List<AMS_Agency_Updates__c> sentUpdates = new List<AMS_Agency_Updates__c>();
            for(AMS_Agency_Updates__c updatedAgency : Trigger.New)
            {
                if(updatedAgency.Update_Type__c == 'Update_Sent' && trigger.OldMap.get(updatedAgency.Id).Update_Type__c != 'Update_Sent')
				{
                    Set<Id> setSentUpdates = new Set<Id>();
                    for(AMS_Agency_Updates__c su: sentUpdates){
                        setSentUpdates.add(su.Account__c);
                    }
                    
                    if(setSentUpdates.contains(updatedAgency.Account__c)==false){
                    	sentUpdates.add(updatedAgency);
                        if(AMS_AgencyUpdateHelper.accSentToExternalSystemFlag.contains(updatedAgency.Account__c)==false){
                            AMS_AgencyUpdateHelper.accSentToExternalSystemFlag.add(updatedAgency.Account__c);
                        }                    	
                    }
                }
            }
            System.debug(sentUpdates);
            AMS_AgencyUpdateHelper.accountUpdate(sentUpdates);
        }
}