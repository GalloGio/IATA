trigger AMS_AgencyUpdatesTrigger on AMS_Agency_Updates__c (
	    before insert, 
	    before update, 
	    before delete, 
	    after insert, 
	    after update, 
	    after delete, 
	    after undelete)
    {
    	
        if(trigger.isAfter && trigger.isUpdate){

            List<AMS_Agency_Updates__c> sentUpdates = new List<AMS_Agency_Updates__c>();
            for(AMS_Agency_Updates__c updatedAgency : Trigger.New)
            {
                if(updatedAgency.Update_Type__c == 'Update_Sent' && trigger.OldMap.get(updatedAgency.Id).Update_Type__c != 'Update_Sent')
				{
                    sentUpdates.add(updatedAgency);
                    AMS_AgencyUpdateHelper.accSentToExternalSystemFlag.add(updatedAgency.Account__c);
                }
            }
            AMS_AgencyUpdateHelper.accountUpdate(sentUpdates);
        }
}