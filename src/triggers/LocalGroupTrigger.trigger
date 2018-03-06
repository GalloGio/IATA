trigger LocalGroupTrigger on LocalGovernance__c (before insert, before update, before delete) {

    localgroupTriggerHandler handler = new localgroupTriggerHandler();

    List<Profile> sysAdminId = [SELECT Id FROM Profile WHERE  Name = 'System Administrator' LIMIT 1];
    List<Profile> accManagmTeam = [SELECT Id FROM Profile WHERE  Name = 'Account management team' LIMIT 1]; //INC298981

    // If the record is new or if the country has changed I get IATA ISO Country
    Set<ID> countryIds = new Set<ID>();
    Set<ID> clusterIds = new Set<ID>();
    List<LocalGovernance__c> localGroupsToDelete = new List<LocalGovernance__c>();

    if(!Trigger.isDelete){

    for(LocalGovernance__c lg : Trigger.new){
        if(Trigger.isInsert || (Trigger.isUpdate && Trigger.oldmap.get(lg.ID).Country__c!=lg.Country__c))
            countryIds.add(lg.Country__c);
    }
    for(LocalGovernance__c lg : Trigger.new){
        if(Trigger.isInsert || (Trigger.isUpdate && Trigger.oldmap.get(lg.ID).Cluster__c!=lg.Cluster__c))
            clusterIds.add(lg.Cluster__c);
    }


    // I update the Local Group adding Region, Country manager and IATA office FROM COUNTRY
    if(countryIds.size()>0){
        Map<Id,IATA_ISO_Country__c> countryMap = new Map<Id,IATA_ISO_Country__c> ([SELECT Name, Region__c, Country_Manager__c, ISS_Office_Location__c
                                                                                   FROM IATA_ISO_Country__c
                                                                                   WHERE ID IN :countryIds]);
        for(LocalGovernance__c lg : Trigger.new){
            IATA_ISO_Country__c myCountry = countryMap.get(lg.Country__c);
            if(myCountry!=null){
                lg.Region__c = myCountry.Region__c;
                lg.IATA_Local_Office__c = myCountry.ISS_Office_Location__c;
                // It should be possible to change manually the country manager -> if it hasn't been changed manually I put the one read from the new country
                if((Trigger.isInsert && lg.Group_Owner__c==null) || (Trigger.isUpdate && Trigger.oldMap.get(lg.ID).Group_Owner__c==lg.Group_Owner__c))
                    lg.Group_Owner__c = myCountry.Country_Manager__c;
            }
        }
    }
    // I update the Local Group adding Region, Country manager and IATA office FROM CLUSTER
    if(clusterIds.size()>0){
        Map<Id,Cluster__c> clusterMap = new Map<Id,Cluster__c> ([SELECT Name, Region__c, Country_Manager__c, IATA_Local_Office__c
                                                                 FROM Cluster__c
                                                                 WHERE ID IN :clusterIds]);
        for(LocalGovernance__c lg : Trigger.new){
            Cluster__c myCluster = clusterMap.get(lg.Cluster__c);
            if(myCluster!=null){
                lg.Region__c = myCluster.Region__c;
                lg.IATA_Local_Office__c = myCluster.IATA_Local_Office__c;
                // It should be possible to change manually the country manager -> if it hasn't been changed manually I put the one read from the new country
                if((Trigger.isInsert && lg.Group_Owner__c==null) || (Trigger.isUpdate && Trigger.oldMap.get(lg.ID).Group_Owner__c==lg.Group_Owner__c))
                    lg.Group_Owner__c = myCluster.Country_Manager__c;
            }
        }
    }


    // For Account Management project, update the Under field if not filled in
    // Rules:
    //   * don't change the Under if Under != null
    //   * if the group is top level group, Under = null, ELSE
    //   * if parent is top level group, Under = null, ELSE
    //   * if parent's Reporting To is top level group, Under = parentId, ELSE
    //   * else Under = parent's Under__c

    set<Id> setReportingToIds = new set<Id>();

    for ( LocalGovernance__c lg : Trigger.new) {
        if (lg.AM_Under__c == null && !lg.AM_Top_Level_Group__c && lg.Reporting_to__c != null) {
            setReportingToIds.add(lg.Reporting_to__c);
        }
    }

    if (!setReportingToIds.isEmpty()) {
        map<Id, LocalGovernance__c> mapReportingToGroupsPerId = new map<Id, LocalGovernance__c>([SELECT Id, AM_Top_Level_Group__c, AM_Under__c, Reporting_to__c, Reporting_to__r.AM_Top_Level_Group__c
                                                                                                 FROM LocalGovernance__c
                                                                                                 WHERE Id IN :setReportingToIds
                                                                                                 AND AM_Top_Level_Group__c = false]);
        for (LocalGovernance__c lg : Trigger.new) {
            if (lg.AM_Under__c == null && !lg.AM_Top_Level_Group__c && lg.Reporting_to__c != null) {

                LocalGovernance__c parentGroup = mapReportingToGroupsPerId.get( lg.Reporting_to__c );

                if (parentGroup != null) {
                    if (parentGroup.Reporting_to__c != null && parentGroup.Reporting_to__r.AM_Top_Level_Group__c == true) {
                        lg.AM_Under__c = parentGroup.Id;
                    } else {
                        lg.AM_Under__c = parentGroup.AM_Under__c;
                    }
                }

            }
        }

    }

    // disable deactivation if child groups are inactive
    List<LocalGovernance__c> lsAllGroups = [SELECT Id, Reporting_to__c, Active__c FROM LocalGovernance__c];
    for (LocalGovernance__c lg : Trigger.new) {
        if(lg.Active__c == false && Trigger.oldMap.get(lg.Id).Active__c == true) {
            List<LocalGovernance__c> allChildren = handler.getAllChildren(lg.Id, lsAllGroups);
            if(handler.hasActiveGroups(allChildren)) {
                lg.addError('cannot deactive if child groups are active');
            }
        }

    }

  }
    // Industry Groups can be deleted only for System Administrators
   /*/ localGroupsToDelete =  trigger.isDelete? trigger.old : trigger.New;*/
    //localGroupsToDelete.size()>0
    if( Trigger.isDelete ){

        for(LocalGovernance__c g : trigger.Old){
            if( UserInfo.getProfileId() == sysAdminId[0].Id || UserInfo.getProfileId() == accManagmTeam[0].Id){
                system.debug('[LocalGroupTrigger] delete industry group:  ' + g.Id);
            }
            else {
                g.addError('<b>Industry Groups can only be deleted by System Administrators or by Account management team.</b>', false);
            }
        }


        // do not allow the deletion of groups that have groups reporting to them
        set<Id> lstNoDeletionGroupIds = new set<Id>();
        for (LocalGovernance__c lg : [SELECT Id, Reporting_To__c from LocalGovernance__c WHERE Reporting_To__c IN :trigger.oldMap.keyset()]) {
            lstNoDeletionGroupIds.add(lg.Reporting_to__c);
        }

        for (Id groupId : lstNoDeletionGroupIds) {
            trigger.oldMap.get(groupId).addError('This Industry Groups cannot be deleted because there are groups reporting to it.');
        }

    }

}
