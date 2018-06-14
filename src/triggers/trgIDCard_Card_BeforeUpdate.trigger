trigger trgIDCard_Card_BeforeUpdate on ID_Card__c (before update) {
    // Get the profilename of the current user 
    ID idUserProfile = UserInfo.getProfileId();
    list<Profile> profileName = [Select Name from Profile where Id =: idUserProfile limit 1];
    

    // In case the card is already sent to AIMS, only administrator or automated process can update the card
    for (ID_Card__c card : trigger.new){
       
        if (card.Sent_to_AIMS_on__c != null){
            // The automated process need to update the status of the card and also the Validity dates when we get cards info from AIMS           
            if (profileName[0].name.toLowerCase() != 'restricted profile - automated process' && !profileName[0].name.containsIgnoreCase('system administrator')){
                if(card.Received_From_AIMS__c == null)
                    card.addError(Label.Card_can_t_be_updated);
            }
        }
    }

    for (ID_Card__c updatedIdCard: Trigger.old) { // Get Old values of the object
        ID_Card__c newIdCard = Trigger.newMap.get(updatedIdCard.ID); // New values
                                          
        if ((updatedIdCard.Card_Status__c != null && newIdCard.Card_Status__c != null) && (updatedIdCard.Card_Status__c != '' && newIdCard.Card_Status__c != '')) {
            
            if (updatedIdCard.Card_Status__c == IDCardUtil.CARDSTATUS_VALID && newIdCard.Card_Status__c == IDCardUtil.CARDSTATUS_CANCELED ) {
               //make sure not to set flag twice.
                //if(newIdCard.MustSyncWithAIMS__c != true)                    
                    //newIdCard.MustSyncWithAIMS__c = true;
            }            
        }        
    }
   
}