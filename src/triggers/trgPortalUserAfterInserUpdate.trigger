trigger trgPortalUserAfterInserUpdate on User (after insert, after update) {
    
    
    if(IECTestUtil.trgPortalUserAfterInserUpdate || ANG_UserTriggerHandler.doNotRun) return;
                                                
    
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
    
    
    
    if(trigger.isInsert)
    for(User u: trigger.New){
        if(portalUserAdminIds.contains(u.ProfileId))// == ISSP_Constant.UserProfilesIDs.get('ISS Portal Delegated Admin User')
            userIdSet.add(u.Id);
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
    
}