public with sharing class AWW_AccountProfileCtrl {

    @AuraEnabled
    public static String getUserAccessRights() {
        List<PermissionSetAssignment> permissions = [
            SELECT PermissionSet.Name
            FROM PermissionSetAssignment 
            WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSet.Name IN ('AMP_admin','AMP_Profile_Visibility')
        ];

        if(permissions.isEmpty()) {
            return 'no access';
        } else {
            return (permissions[0].PermissionSet.Name == 'AMP_admin' ? 'full' : 'read');
        }
    }
}