trigger LocalGroupTrigger on LocalGovernance__c (before insert, before update, before delete) {
    
    List<Profile> sysAdminId = [SELECT Id FROM Profile WHERE  Name = 'System Administrator' LIMIT 1];
    
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
  }  
    // Local Groups can be deleted only for System Administrators
   /*/ localGroupsToDelete =  trigger.isDelete? trigger.old : trigger.New;*/
    //localGroupsToDelete.size()>0
    if( Trigger.isDelete ){   
        
        for(LocalGovernance__c g : trigger.Old){
            if(UserInfo.getProfileId() == sysAdminId[0].Id){
                system.debug('[LocalGroupTrigger] delete local group:  ' + g.Id);
            }
            else {
                g.addError('<b>Local groups can only be deleted by System Administrators.</b>', false);
            }   
        }
        
    }
    
}