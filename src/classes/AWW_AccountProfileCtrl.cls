public with sharing class AWW_AccountProfileCtrl {

    @AuraEnabled
    public static String getUserAccessRights() {
        List<PermissionSetAssignment> permissions = [
            SELECT PermissionSet.Name
            FROM PermissionSetAssignment 
            WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSet.Name IN ('AGM_FullAccess','AGM_ReadAccess')
        ];

        if(permissions.isEmpty()) {
            return 'no access';
        } else {
            return (permissions[0].PermissionSet.Name == 'AGM_FullAccess' ? 'full' : 'read');
        }
    }
}