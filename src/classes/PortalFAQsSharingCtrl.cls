/**
 * Created by pvavruska on 6/21/2019.
 */

public with sharing class PortalFAQsSharingCtrl {

    PRIVATE STATIC FINAL STRING DEFAULT_PERMSET_NAME = 'FAQ_DEFAULT';
    private static User currentUser;
    private static Account userAccount;
    private static IATA_ISO_Country__c accountCountry;

    private class FAQsVisibilitySettings{
        public String sector;
        public String category;
        public String permsetName;
        public List<String> permsetNames;
        public String iso_countries1;
        public String iso_countries2;
        public String iso_countries3;
    }


    @future
    public static void shareFAQs(Id userId){
        String countryCode;
        String accountSector;
        String accountCategory;

        List<User> userInfo = [SELECT Id,AccountId,Account.Sector__c,Account.Category__c,Account.IATA_ISO_Country__r.ISO_Code__c FROM User WHERE Id =:userId];

        //countryCode = userInfo

        List<String> permsetNames = new List<String>();
        Map<String,Id> permissionNameToId = new Map<String,Id>();

        String settingsQuery = 'SELECT Permission_Set_Name__c FROM PortalFAQs__mdt WHERE';


        List<PortalFAQs__mdt> settings = [
                SELECT Permission_Set_Name__c
                FROM PortalFAQs__mdt
                WHERE
                (
                        ISO_Country_Codes1__c LIKE :countryCode OR ISO_Country_Codes2__c LIKE :countryCode OR ISO_Country_Codes3__c LIKE :countryCode
                        OR ISO_Country_Codes1__c = 'All'
                )
                AND (Account_Sector__c = :accountSector)
                AND (Account_Categories__c LIKE :accountCategory OR Account_Categories__c = 'All')
        ];

        if(!settings.isEmpty()){
            for(PortalFAQs__mdt setting:settings){
                permsetNames.add(setting.Permission_Set_Name__c);
            }
        }else{
            settings = [SELECT Permission_Set_Name__c FROM PortalFAQs__mdt WHERE DeveloperName =: DEFAULT_PERMSET_NAME]
        }

        if(!permsetNames.isEmpty()) {
            List <PermissionSet> setList = [SELECT Id,Name FROM PermissionSet WHERE Name IN:permsetNames];
            if (!setList.isEmpty()) {
                List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();

                PermissionSetAssignment newPermission;
                for(PermissionSet permSet : setList){
                    newPermission   = new PermissionSetAssignment();
                    newPermission.AssigneeId = userId;
                    newPermission.PermissionSetId = permSet.Id;
                    assignments.add(newPermission);
                }

                if(!assignments.isEmpty()){
                    insert assignments;
                }

            }

        }
    }


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


}