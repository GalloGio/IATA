/**
 * Created by ppop on 8/6/2019.
 */

public with sharing class GADM_FileSharing {
    public static void assignGadmRecordType(List<ContentVersion> newValues) {
        List<GroupMember> internalGadmGroupMembers = [SELECT Id, UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'GADM_Internal_Users'];
        Set<Id> internalGadmGroupMemberIds = new Set<Id>();
        if(internalGadmGroupMembers != null && internalGadmGroupMembers.size() > 0){
            for(GroupMember gm: internalGadmGroupMembers){
                internalGadmGroupMemberIds.add(gm.UserOrGroupId);
            }
        }

        Id fileGadmRecordtype = Schema.SObjectType.ContentVersion.getRecordTypeInfosByName().get('GADM').getRecordTypeId();
        if (fileGadmRecordtype != null){
            for (ContentVersion cv: newValues) {
                if(internalGadmGroupMemberIds.contains(cv.CreatedById) && cv.RecordTypeId == null){
                    cv.RecordTypeId = fileGadmRecordtype;
                }
            }
        }
    }
}