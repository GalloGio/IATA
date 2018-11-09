trigger ISSP_ContactAfterInsert on Contact (after insert,after update) {
    
    //if(ISSP_UserTriggerHandler.preventOtherTrigger)
      //  return;
    
    list<Contact> contactsFromMigrationList = new list<Contact>();
    list<Contact> contactsWithStatusEqualToInactivList = new list<Contact>();
    list<Contact> contactsToDisable_TD = new list<Contact>();
    set<string> contactsForUserUpdateIdSet = new set<string>();
    set<string> contactsForUserdeActivateIdSet = new set<string>();
   
    Set<Id> contactsToProcess = new Set<Id>();
    Map<Id, Id> contactsToProcessMap = new Map<Id, Id>();
    
    for(Contact con:trigger.new){
        contactsToProcess.add(con.Id);
    }
    if (!contactsToProcess.isEmpty()){
        List <User> userList = [SELECT Id, Profile.Name, ContactId,ContactKaviId__c,Is_Kavi_Internal_User__c FROM User WHERE ContactId = :contactsToProcess OR ContactKaviId__c =:contactsToProcess];
        if (!userList.isEmpty()){
            for (User thisUser : userList){
                if (thisUser.Profile.Name.startsWith('ISS')){
                    if (!contactsToProcessMap.containsKey(thisUser.ContactId)){
                        contactsToProcessMap.put(thisUser.ContactId, thisUser.ContactId);
                    }
                }
                //if (thisUser.Profile.Name == 'KaviProvisioningUser'){
                //    if (!contactsToProcessMap.containsKey(thisUser.ContactKaviId__c)){
                //       contactsToProcessMap.put(thisUser.ContactKaviId__c, thisUser.ContactKaviId__c);
                //   }
                //}
                if (thisUser.Is_Kavi_Internal_User__c){
                    if (!contactsToProcessMap.containsKey(thisUser.ContactKaviId__c)){
                       contactsToProcessMap.put(thisUser.ContactKaviId__c, thisUser.ContactKaviId__c);
                   }
                }
            }
        }
    }
        
    for(Contact con:trigger.new){
        
        if (contactsToProcessMap.containsKey(con.Id)){
            system.debug('PROCESSING THIS CONTACT FOR PORTAL');


            //if(con.Is_from_migration__c)
            //    contactsFromMigrationList.add(con);
            Contact oldCon;  
            if(trigger.isUpdate){
                oldCon = trigger.oldMap.get(con.Id);
                system.debug('con.LastName '+con.LastName);
                system.debug('oldCon.LastName '+oldCon.LastName);
                if(
                    con.FirstName != oldCon.FirstName ||
                    con.LastName != oldCon.LastName ||
                    con.Email != oldCon.Email ||
                    con.Title != oldCon.Title ||
                    con.Preferred_Language__c != oldCon.Preferred_Language__c 
                ){
                    contactsForUserUpdateIdSet.add(con.Id);
                }
                if (con.AccountId != oldCon.AccountId){
                    contactsToDisable_TD.add(con);
                }
            }
            if((con.User_Portal_Status__c == 'Deactivate' || con.User_Portal_Status__c == 'Deactivated') && con.User_Portal_Status__c!= oldCon.User_Portal_Status__c ||
    
                ((con.Status__c == 'Inactive' || con.Status__c == 'Retired' || con.Status__c == 'Left Company / Relocated' ) 
    
                  && (trigger.isinsert || con.Status__c!= oldCon.Status__c) )
             ){
                contactsWithStatusEqualToInactivList.add(con);
            }
            
            if(((con.Status__c == 'Inactive') || (con.Kavi_User__c != null & (con.Status__c == 'Retired' || con.Status__c == 'Left Company / Relocated') ) )// || con.Status__c == 'Retired' || con.Status__c == 'Left Company / Relocated' ) 
                  && (trigger.isinsert || con.Status__c!= oldCon.Status__c )){
                    contactsForUserdeActivateIdSet.add(con.Id);
                    if (con.Kavi_User__c != null){
                        contactsWithStatusEqualToInactivList.add(con);
                    }
            }
        }
    }
    
    //Mass User Creation
    //if(contactsFromMigrationList.size()>0)
    //    ISSP_PortalUserStatusChange.maasUserCreation(contactsFromMigrationList);
    
    // Update user by contact changes
    // Update Portal Application Rights - to Access Denide If contact Status is inactiv
    system.debug('\n\n KIKEcontactsForUserUpdateIdSet '+ contactsForUserUpdateIdSet+'\n\n');
    if(contactsForUserUpdateIdSet.size()>0)
        ISSP_PortalUserStatusChange.futureUpdateUsers(contactsForUserUpdateIdSet);
    
    // Update Portal Application Rights - to Access Denide If contact Status is inactiv
    system.debug('\n\n contactsWithStatusEqualToInactivList '+contactsWithStatusEqualToInactivList+'\n\n');
    if(contactsWithStatusEqualToInactivList.size()>0){
        list<Portal_Application_Right__c> parList = [select Id,Right__c from Portal_Application_Right__c where Contact__c in:contactsWithStatusEqualToInactivList];
        for(Portal_Application_Right__c par :parList ){
            par.Right__c = 'Access Denied';
        }
        update parList;
    }
    
    // Unactivate Users
    if(contactsForUserdeActivateIdSet.size()>0){
        ISSP_PortalUserStatusChange.futureDeactivateUsers(contactsForUserdeActivateIdSet);
    }
    
    Set<Id> contactIdSet = new Set<Id>();
    
    if (contactsToDisable_TD.size() > 0){
        list<Portal_Application_Right__c> tdList = [SELECT Id, Right__c
                                                FROM Portal_Application_Right__c
                                                WHERE Contact__c in:contactsToDisable_TD
                                                AND Right__c = 'Access Granted'
                                                AND Portal_Application__r.Name LIKE 'Treasury Dashboard%'];
        if (!tdList.isEmpty()){
            for(Portal_Application_Right__c par : tdList){
                par.Right__c = 'Access Denied';
            }
            update tdList;
        }

        list<Portal_Application_Right__c> kaviList = [SELECT Id, Right__c, Contact__c
                                                FROM Portal_Application_Right__c
                                                WHERE Contact__c in:contactsToDisable_TD
                                                AND Right__c = 'Access Granted'
                                                AND Portal_Application__r.Name LIKE 'Standards Setting Workspace%'];
        if (!kaviList.isEmpty()){
            for(Portal_Application_Right__c par : kaviList){
                contactIdSet.add(par.Contact__c);
            }
        }
    }

	if(!HigherLogicIntegrationHelper.preventTrigger && contactIdSet.size() > 0){
		HigherLogicIntegrationHelper.preventTrigger = true;
		HigherLogicIntegrationHelper.updateMembersRelationships(contactIdSet);
	}
				
}