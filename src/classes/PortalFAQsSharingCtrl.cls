/**
 * Created by pvavruska on 6/21/2019.
 */

public with sharing class PortalFAQsSharingCtrl {


    @future
    public static void shareFAQs(){
        //When user is registered/logs in - assign permission sets based on user's related account
        List<String> permsetNames = new List<String>();
        Map<String,Id> permToId = new Map<String,Id>();

        List <PermissionSet> setList = [SELECT Id,Name FROM PermissionSet WHERE Name IN:permsetNames];
        if (!setList.isEmpty()){

        }

    }

    /*public static void updateSIS_permissionSet(Set<Id> contactIdSet, Set<Id> contactRemoveIdSet){
        system.debug('FUTURE METHOD, ADD: ' + contactIdSet);
        system.debug('FUTURE METHOD, REMOVE: ' + contactRemoveIdSet);
        String permissionSetId = '';

        if (!setList.isEmpty()){
            permissionSetId = setList[0].Id;
        }
        if (permissionSetId != ''){
            if (!contactIdSet.isEmpty()){
                List <User> userList = [SELECT Id FROM User WHERE ContactId IN :contactIdSet AND IsActive = true];
                Set <Id> userSetId = new Set <Id>();
                Map <Id, Id> userMap = new Map <Id, Id>();
                if (!userList.isEmpty()){
                    for (User thisUser : userList){
                        userSetId.add(thisUser.Id);
                        userMap.put(thisUser.Id, thisUser.Id);
                    }
                    List <PermissionSetAssignment> assignmentList = [SELECT Id, AssigneeId FROM PermissionSetAssignment
                    WHERE AssigneeId IN :userSetId
                    AND PermissionSetId = :permissionSetId];
                    if (!assignmentList.isEmpty()){
                        for (PermissionSetAssignment thisAssignment : assignmentList){
                            if (userMap.containsKey(thisAssignment.AssigneeId)){
                                userMap.remove(thisAssignment.AssigneeId);
                            }
                        }
                    }
                    if (!userMap.isEmpty()){
                        List <PermissionSetAssignment> newPermissionList = new List <PermissionSetAssignment>();
                        List <Id> idList = userMap.values();
                        for (Id thisId : idList){
                            PermissionSetAssignment newPermission = new PermissionSetAssignment();
                            newPermission.AssigneeId = thisId;
                            newPermission.PermissionSetId = permissionSetId;
                            newPermissionList.add(newPermission);
                        }
                        insert newPermissionList;
                    }
                }
            }
            if (!contactRemoveIdSet.isEmpty()){
                List <User> userListRemove = [SELECT Id FROM User WHERE ContactId IN :contactRemoveIdSet AND IsActive = true];
                Set <Id> userSetIdRemove = new Set <Id>();
                if (!userListRemove.isEmpty()){
                    for (User thisUser : userListRemove){
                        userSetIdRemove.add(thisUser.Id);
                    }
                    List <PermissionSetAssignment> assignmentListRemove = [SELECT Id, AssigneeId FROM PermissionSetAssignment
                    WHERE AssigneeId IN :userSetIdRemove
                    AND PermissionSetId = :permissionSetId];
                    if (!assignmentListRemove.isEmpty()){
                        delete assignmentListRemove;
                    }

                }
            }
        }
    }*/

}