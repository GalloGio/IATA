public without sharing class CW_OneSourceGxAProvision {
    

    @future(callout=true)
    public static void provisionDeprovisionContacts(Id contactToProvision, String roleToProvision, Boolean isProvision){
        ICG_Contact_Role_Detail__c roleToProvisionDeserialized = (ICG_Contact_Role_Detail__c) JSON.deserialize(roleToProvision, ICG_Contact_Role_Detail__c.class);
        //Provision one role per station when is company admin
        if(isProvision == true) CaseIFAPHandler.getContactInfo(new List<Id>{contactToProvision});
        List<User> user = [Select id, UserName from User where ContactId =:roleToProvisionDeserialized.ContactId__c limit 1];
        if(!user.isEmpty()){
            if(roleToProvisionDeserialized.ICG_Role__c == 'Company Admin'){
                Account_Role__c accRole = [Select id, Account__c from Account_Role__c where Id = :roleToProvisionDeserialized.Account_Role__c];
                String opsHierarchy = CW_Utilities.getOpsHierarchyNameFromAccountId(accRole.Account__c);
                //Provision all company admins
                //Reusing private area method to encapsulate all the ops hierarchy in the same methods
                Map<String,CW_PrivateAreaController.OpsHierarchyDataWrapper> allHierarchy = (Map<String,CW_PrivateAreaController.OpsHierarchyDataWrapper>) JSON.deserialize(CW_PrivateAreaController.getUserFacilities(accRole.Account__c),Map<String,CW_PrivateAreaController.OpsHierarchyDataWrapper>.class);
                Set<Id> stationsId = new Set<Id>();
                if(allHierarchy.get(opsHierarchy) != null){
                    for(CW_PrivateAreaController.CompanyWrapper cw :  allHierarchy.get(opsHierarchy).companyList){
                        if(cw.stations != null){
                            for(ICG_Account_Role_Detail__c st : cw.stations){
                                
                                if(st.isApproved__c == true){
                                    if(isProvision == true) provisionUserRole(UserInfo.getOrganizationId().substring(0, 15) + '@' + user[0].UserName,roleToProvisionDeserialized.Contact_Email__c, st.Global_ID__c);
                                    else 
                                    {
                                        //this part is to get all the stations id, and do not deprovision a user from a station when the user is not company admin anymore but has
                                        //active station managers for specific stations.
                                        stationsId.add(st.Id);
                                    }
                                }
                            }
                            if(isProvision == false){
                                //Do not deprovision role of user if he has already active station managers roles
                                Map<Id, ICG_Account_Role_Detail__c> mapStationsAndRoles = new Map<Id, ICG_Account_Role_Detail__c>( [Select Id, (Select id from ICG_Contact_Role_Details__r where isApproved__c = true AND ICG_Role__c='Facility Manager' and ContactId__c = :roleToProvisionDeserialized.ContactId__c) FROM ICG_Account_Role_Detail__c where Id IN : stationsId]);
                                for(ICG_Account_Role_Detail__c st : cw.stations){
                                    if(st.isApproved__c == true && mapStationsAndRoles.get(st.Id).ICG_Contact_Role_Details__r.isEmpty()){
                                        deprovisionUserRole(UserInfo.getOrganizationId().substring(0, 15) + '@' + user[0].UserName,roleToProvisionDeserialized.Contact_Email__c, st.Global_ID__c);
                                    }
                                }
                            }
                        }
                    }
                }
        
            }else if(roleToProvisionDeserialized.ICG_Role__c == 'Facility Manager' && roleToProvisionDeserialized.Station_Global_ID__c != null){
                if(isProvision == true) provisionUserRole(UserInfo.getOrganizationId().substring(0, 15) + '@' + user[0].UserName,roleToProvisionDeserialized.Contact_Email__c, roleToProvisionDeserialized.Station_Global_ID__c);
                else deprovisionUserRole(UserInfo.getOrganizationId().substring(0, 15) + '@' + user[0].UserName,roleToProvisionDeserialized.Contact_Email__c, roleToProvisionDeserialized.Station_Global_ID__c);
            }

            //Deprovision User if is never more admin of any facility
            if(isProvision == false){
                List<ICG_Contact_Role_Detail__c> contactRoleDetailsOfContact = [Select id from ICG_Contact_Role_Detail__c where isApproved__c = true AND (ICG_Role__c='Facility Manager' OR ICG_Role__c ='Company Admin') and ContactId__c = :roleToProvisionDeserialized.ContactId__c];
                if(contactRoleDetailsOfContact.isEmpty()){
                    CaseIFAPHandler.WrapperUserForJSON wrapper = new CaseIFAPHandler.WrapperUserForJSON();
                    wrapper.emailId = roleToProvisionDeserialized.Contact_Email__c;
                    wrapper.salesForceUserEmailId = UserInfo.getOrganizationId().substring(0, 15) + '@' + user[0].UserName;
                    wrapper.contactStatus = 'Disable';
                    system.debug('Disable User');
                    CaseIFAPHandler.sendJSON(JSON.serialize(wrapper), 'users');
                }
            }
        }
    }

    public static void provisionOrDeprovisionStations(List<ICG_Account_Role_Detail__c> newStations, Map<Id,ICG_Account_Role_Detail__c> oldMap){
        List<ICG_Account_Role_Detail__c> provisionStationsList = new List<ICG_Account_Role_Detail__c>();
        List<ICG_Account_Role_Detail__c> deprovisionStationsList = new List<ICG_Account_Role_Detail__c>();
        if(newStations != null){
            for (ICG_Account_Role_Detail__c st : newStations){
                if(st.isApproved__c == true && (oldMap == null || oldMap != null && (oldMap.get(st.Id).isApproved__c == false || st.Street_Nr_For__c != oldMap.get(st.Id).Street_Nr_For__c
                || st.City_FOR__c != oldMap.get(st.Id).City_FOR__c || st.Postal_Code_FOR__c != oldMap.get(st.Id).Postal_Code_FOR__c || st.Country_FOR__c != oldMap.get(st.Id).Country_FOR__c))) provisionStationsList.add(st);
                else if(st.isApproved__c == false && oldMap != null && oldMap.get(st.Id).isApproved__c == true) deprovisionStationsList.add(st);
            }
        }else if(newStations == null && oldMap != null){
            for (ICG_Account_Role_Detail__c st : oldMap.values()){
                //Deprovision already provisionoed stations, so the ones that were approved
                if(st.isApproved__c == true) deprovisionStationsList.add(st);
            }
        }

        
        for(ICG_Account_Role_Detail__c st : provisionStationsList){
            //One future call per station because there are several queries performed per station
            //to get all company admins, and provision them.
            if(Limits.getLimitFutureCalls() > 0) provisionStation(JSON.serialize(st));
        }
        for(ICG_Account_Role_Detail__c st : deprovisionStationsList){
            if(Limits.getLimitFutureCalls() > 0) deProvisionStation(JSON.serialize(st));
        }
    }
    public static void provisionOrDeprovisionRolesAndContacts(List<ICG_Contact_Role_Detail__c> newList, Map<Id,ICG_Contact_Role_Detail__c> oldMap) {
        Map<Id,ICG_Contact_Role_Detail__c> mapContactIdRoleToProvision = new Map<Id,ICG_Contact_Role_Detail__c>();
        Map<Id,ICG_Contact_Role_Detail__c> mapContactIdRoleToDeprovision = new Map<Id,ICG_Contact_Role_Detail__c>();
        if(newList != null){
            for(ICG_Contact_Role_Detail__c crd : newList) {
                //New Company Admins or Facility Managers
                if(crd.isApproved__c == true && (crd.ICG_Role__c == 'Company Admin' || crd.ICG_Role__c == 'Facility Manager')
                            && (oldMap == null || (oldMap != null && (oldMap.get(crd.Id).isApproved__c == false || oldMap.get(crd.Id).Contact_Name__c != crd.Contact_Name__c
                            || oldMap.get(crd.Id).Contact_Email__c != crd.Contact_Email__c)))) {
                                mapContactIdRoleToProvision.put(crd.ContactId__c,crd);
                }else if(crd.isApproved__c == false && (crd.ICG_Role__c == 'Company Admin' || crd.ICG_Role__c == 'Facility Manager')
                && (oldMap != null && (oldMap.get(crd.Id).isApproved__c == true))) {
                    mapContactIdRoleToDeprovision.put(crd.ContactId__c,crd);

                }
            }
        }else if(newList == null && oldMap != null){
            for (ICG_Contact_Role_Detail__c crd : oldMap.values()){
                //Deprovision already provisionoed roles, so the ones that were approved
                if(crd.isApproved__c == true) {
                    mapContactIdRoleToDeprovision.put(crd.ContactId__c,crd);
                }
            }
        }
		
        for(String conId : mapContactIdRoleToProvision.keySet()){
            //It has to be one by one as the user has always to be provisioned before the role.
            //That means that I cannot send async the user and the role separated, because the role can reach the system
            //before the user and cause an issue.
            if(Limits.getLimitFutureCalls() > 0) provisionDeprovisionContacts(conId,JSON.serialize(mapContactIdRoleToProvision.get(conId)),true);
        }
        for(String conId : mapContactIdRoleToDeprovision.keySet()){
            //It has to be one by one as the user has always to be provisioned before the role.
            //That means that I cannot send async the user and the role separated, because the role can reach the system
            //before the user and cause an issue.
            if(Limits.getLimitFutureCalls() > 0) provisionDeprovisionContacts(conId,JSON.serialize(mapContactIdRoleToDeprovision.get(conId)),false);
        }
	}

    @future(callout=true)
    public static void deProvisionStation(String serializedStation){
        system.debug('Station deprovisioned');
        ICG_Account_Role_Detail__c station = (ICG_Account_Role_Detail__c)JSON.deserialize(serializedStation, ICG_Account_Role_Detail__c.class);
        CaseIFAPHandler.WrapperCompanyForJSON stationDeprovision = new CaseIFAPHandler.WrapperCompanyForJSON(station,'Disable');
        CaseIFAPHandler.sendJSON(JSON.serialize(stationDeprovision), 'accounts');
    }
    @future(callout=true)
    public static void provisionStation(String serializedStation){
        system.debug('Station provisioned');
        ICG_Account_Role_Detail__c station = (ICG_Account_Role_Detail__c)JSON.deserialize(serializedStation, ICG_Account_Role_Detail__c.class);
        CaseIFAPHandler.WrapperCompanyForJSON stationProvision = new CaseIFAPHandler.WrapperCompanyForJSON(station,'Active');
        CaseIFAPHandler.sendJSON(JSON.serialize(stationProvision), 'accounts');
        //Provision all company admins
        List<Contact> contactsToProvision = CW_Utilities.getCompanyadminContactsFromAccountId(station.AccountId__c);
        Map<Id,User> mapContactIdUser = new Map<Id,User>();
        for(Contact con : contactsToProvision){
            mapContactIdUser.put(con.Id, null);
        }
        for (User u : [Select Id, UserName, ContactId from User where ContactId IN : mapContactIdUser.keySet()]){
            mapContactIdUser.put(u.ContactId,u);
        }
        for(Contact con : contactsToProvision){
            provisionUserRole(UserInfo.getOrganizationId().substring(0, 15) + '@' + mapContactIdUser.get(con.Id).UserName,con.Email, station.Global_ID__c);
        }
    }

    public static void provisionUserRole(String salesForceUserEmailId, String contactEmail,String stationGlobalId){
        system.debug('Provision user role');
        CaseIFAPHandler.WrapperUserRoleForJSON roleBody = new CaseIFAPHandler.WrapperUserRoleForJSON(salesForceUserEmailId, contactEmail, stationGlobalId, 'Active');
        CaseIFAPHandler.sendJSON(JSON.serialize(roleBody), 'roles');
    }
    public static void deProvisionUserRole(String salesForceUserEmailId, String contactEmail,String stationGlobalId){
        system.debug('Deprovision user role');
        CaseIFAPHandler.WrapperUserRoleForJSON roleBody = new CaseIFAPHandler.WrapperUserRoleForJSON(salesForceUserEmailId, contactEmail, stationGlobalId, 'Disable');
        CaseIFAPHandler.sendJSON(JSON.serialize(roleBody), 'roles');
    }

}
