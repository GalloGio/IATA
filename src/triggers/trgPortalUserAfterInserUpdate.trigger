trigger trgPortalUserAfterInserUpdate on User (after insert, after update) {
    
    
    if(IECTestUtil.trgPortalUserAfterInserUpdate) return;
                                                
    
    //create apex sharing for Accounts in Hierarchy
    set<Id> userIdSet = new set<Id>();  
    set<Id> userIdSetAddGroup = new set<Id>();  
    set<Id> portalUserAdminIds = ISSP_Constant.adminIdSet;
    set<Id> portalISSProfileIds = ISSP_Constant.ISSProfileSet_forContentUser ;
    
    if(trigger.isUpdate)
    for(User u: trigger.New){
        if( ISSP_Constant.UserAccountChangeParent
            ||
            (u.ProfileId !=trigger.oldMap.get(u.Id).ProfileId 
            &&
             !portalUserAdminIds.contains(u.ProfileId)
                &&
             portalISSProfileIds.contains(u.ProfileId)//!portalUserAdminIds.contains(u.ProfileId)//u.ProfileId != ISSP_Constant.UserProfilesIDs.get('ISS Portal Delegated Admin User')
             )
        )userIdSet.add(u.Id);
    }
    if(userIdSet.size()>0){
    	if (!system.isFuture()){
	        if(!Test.isRunningTest())
	            ISSP_HierarchyAccountTeamAccounts.deleteHierarchyAccountTeamMemberAccounts(userIdSet);
	        else
	            delete [select Id from AccountTeamMember where UserId in:userIdSet and TeamMemberRole =:'Portal Administrator'];
    	}
    }
    userIdSet.clear();
    
    
    //EM: Handle portal fields at contact level
    map <Id,String> idportalusers = new map <Id,String>();
    map <Id,Id> contactid = new map <Id,Id>();
    if(trigger.isInsert)
    for(User u: trigger.New){
        if(portalUserAdminIds.contains(u.ProfileId))// == ISSP_Constant.UserProfilesIDs.get('ISS Portal Delegated Admin User')
            userIdSet.add(u.Id);
        
        system.debug('@@@u.Community__c: ' + u.Community__c);  
        system.debug('@@@u.UserType: ' + u.UserType); 
        system.debug('@@@u.contactId: ' + u.contactId);   
        if (!String.isBlank(u.Community__c) && u.UserType == 'PowerPartner' && u.contactId != null) {
        	idportalusers.put(u.id,u.community__c); 
        	contactid.put(u.contactid,u.id); 
        }
        
    }
    
    if(trigger.isUpdate)
    for(User u: trigger.New){
        if( //ISSP_Constant.UserAccountChangeParent
            //&&
            portalUserAdminIds.contains(u.ProfileId)// == ISSP_Constant.UserProfilesIDs.get('ISS Portal Delegated Admin User')
        )
        userIdSet.add(u.Id);
    }
    
    system.debug('\n\n\n userIdSet: '+userIdSet+'\n\n\n');
    if(userIdSet.size()>0 && !system.isFuture()){
        ISSP_HierarchyAccountTeamAccounts.HierarchyAccountTeamMemberAccounts(userIdSet); 
    } 

    
    for(User u: trigger.New){
    System.debug('RRR1 u.ProfileId'+u.ProfileId);
    system.debug('@@@u.contactId: ' +u.contactId);
    String Pro = u.ProfileId ;
    if(pro.length() == 18 )
    {
        pro = pro.substring(0,15);
    }
    
     System.debug('RRR1 pro '+pro );
     if(portalISSProfileIds.contains(pro))
        userIdSetAddGroup.add(u.Id);
     }
    
     System.debug('RRR1 userIdSetAddGroup '+userIdSetAddGroup);
     System.debug('RRR1 !system.isFuture() '+!system.isFuture());

    if(userIdSetAddGroup!= null && userIdSetAddGroup.size()>0&& !system.isFuture()){
        trg_ctrl_PortalUser.AddUsersToGroups(userIdSetAddGroup , 'ISSP_all_portal_users');
        if(!IECTestUtil.trgPortalUserAfterInserUpdate) IECTestUtil.trgPortalUserAfterInserUpdate = false;
    } 
    
    
    //Fill in portal contact fields
    
    if (idportalusers.size() > 1) {
    	Database.executeBatch(new HandleContactPortalFields(idportalusers,contactid));
    }
    //Single insertion, do not execute a batch
    else if (idportalusers.size() == 1) {
    	HandleContactPortalFields_Helper h = new HandleContactPortalFields_Helper();
		h.fillportalfields(null,idportalusers,contactid);
    }
    
}