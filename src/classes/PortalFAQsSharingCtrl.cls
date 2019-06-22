/**
 * Created by pvavruska on 6/21/2019.
 */

public with sharing class PortalFAQsSharingCtrl {

    PRIVATE STATIC FINAL STRING x;

    private class FAQsVisibilitySettings{
        public String sector;
        public String category;
        public String permsetName;
        public List<String> permsetNames;
        public String iso_countries1;
        public String iso_countries2;
        public String iso_countries3;
    }

    //Get


    @future
    public static void shareFAQs(List<Id> userId){
        Account userAccount;
        //When user is registered/logs in - assign permission sets based on user's related account
        //Permset names to be set from relevant metadata types - from metadata csvs, to list of strings 
        List<String> permsetNames = new List<String>();
        Map<String,Id> permToId = new Map<String,Id>();

        List <PermissionSet> setList = [SELECT Id,Name FROM PermissionSet WHERE Name IN:permsetNames];
        if (!setList.isEmpty()){
        }

        //Get custom metadata based on Sector, Category - All is valid, ISO_Country__c (2chars) - in 3fields, All is valid
        //Custom metadata contain permission set name

        List<Account> accs= [SELECT Id,Category__c,Sector__c FROM Account LIMIT 50];

        Map<String,PermissionSet> sectorPermSets = Map<String,PermissionSet>();
        Map<String,PermissionSet> categoryPermSets = Map<String,PermissionSet>();
        Map<String,PermissionSet> countryPermSets = Map<String,PermissionSet>();

        List<FAQsVisibilitySettings> settings = new List<FAQsVisibilitySettings>();



        for(FAQsVisibilitySettings setting: settings){
            if(!String.isBlank(setting.sector)){
                sectorPermSets.put(setting.permsetName,setting);
            }

            if(!String.isBlank(setting.category)){
                sectorPermSets.put(setting.permsetName,setting);
            }

            if(!String.isBlank(setting.iso_countries1) || !String.isBlank(setting.iso_countries2) || !String.isBlank(setting.iso_countries3)){
                //Get country permission set based on country code (ideally check if 1,2,3 country fields contains  Account's) ->
                //
                sectorPermSets.put(setting.permsetName,setting);
            }
        }


        /**
        *
        * PERM SETS MUST BE COUNTRY-VALID -> check country_iso1,2,3 for a match. if not matching, don't assign.
        *
        * */

        List<Id> userIds = new List<Id>();

        List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();

        Map<Id,List<Id>> userIdtoPermSetIds = new Map<Id,List<Id>>();

        for(Id userId :userIds){
            if(userIdtoPermSetIds.containsKey(userId) &&  userIdtoPermSetIds.containsKey(userId) != null){

                List<Id> userPermSets = userIdtoPermSetIds.get(userId);


                PermissionSetAssignment newPermission;
                for(Id permissionSetId : userPermSets){
                    newPermission   = new PermissionSetAssignment();
                    newPermission.AssigneeId = userId;
                    newPermission.PermissionSetId = permissionSetId;
                    assignments.add(newPermission);
                }
            }

        }

        if(!assignments.isEmpty()){
            insert assignments;
        }

        // HANDLE DEFAULT ASSIGNMENTS IF NO MATCHING CRITERIA FOR PERMISSIONSETS FOUND



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
        }
    }*/


    /**
     * Removes all Permission Sets for portal FAQs (Data Categories) assigned to User with a given userId.
     * @param userId
     */

    public static void removeFAQPermissions(String userId){
        String permset_prefix = 'FAQ_Visibility%';

        List <PermissionSetAssignment> assignmentListRemove = [SELECT Id, AssigneeId FROM PermissionSetAssignment
        WHERE AssigneeId =: userId
        AND PermissionSet.Name LIKE :permset_prefix];


        if (!assignmentListRemove.isEmpty()){
            delete assignmentListRemove;
        }
    }

}