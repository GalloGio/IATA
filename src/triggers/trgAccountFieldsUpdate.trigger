trigger trgAccountFieldsUpdate on Case (before insert) {
    /* Created Date - 10-June-2010*/
    /* 
       This trigger is used to assign the Account Id to
       the account fields in the case record from the 
       customer portal
    */
    
    Set<Id> ContIds = new Set<Id>();
    List<Contact> lstConts = new List<Contact>();
    Profile profile;
    List<Profile> profileList = new List<Profile>();
    String profileName, profileId;
    
    if(Trigger.isInsert){  
    	
    	profileId = UserInfo.getProfileId();
    	System.debug('Profile ID : '+profileId);
    	//if(UserInfo.getProfileId() != null){      
        	profileList = [SELECT Id,Name FROM Profile WHERE Id =: UserInfo.getProfileId() limit 1];
        	
        	if(profileList.size() > 0){
        		
        		profileName = profileList[0].Name;
        	}
    	//}	
        //[CASE CLEANUP 2017] - No such profile "Overage High Volume Customer Portal User Cloned"
        /*if(profileName != null){
        	
            //profileName = profile.Name;
            System.debug('Profile Name : ' + profileName);
            //if(profileName.contains('Customer Portal Manager Standard Cloned')){
            //if(profileName.contains('Overage High Volume Customer Portal User Cloned')){
            if('Overage High Volume Customer Portal User Cloned'.equals(profileName)){
                for(Case newCase : Trigger.New){
                    if(newCase.ContactId != null){
                        ContIds.add(newCase.ContactId);
                    }                              
                }
                lstConts = [SELECT Id, AccountId FROM Contact WHERE Id IN: ContIds];
                for(Case newCase : Trigger.New){
                    for(Integer i=0;i<lstConts.Size();i++){
                        if(newCase.ContactId != null){
                            if(newCase.ContactId == lstConts[i].Id){
                                newCase.AccountId = lstConts[i].AccountId;
                                //newCase.Power_User_Account__c = lstConts[i].AccountId;
                                newCase.IsVisibleInSelfService = True;
                                //System.debug('Power User Account : ' + newCase.Power_User_Account__c);
                                break;
                            }
                        }
                    }
                }
            }
        }*/                                
    }
    
}