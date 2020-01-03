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
			Boolean hasAMPadmin = false;
			Boolean hasAMPProfileVisibility = false;
			for(PermissionSetAssignment psa: permissions){
				if(psa.PermissionSet.Name == 'AMP_admin'){
					hasAMPadmin = true;
				}
				if(psa.PermissionSet.Name == 'AMP_Profile_Visibility'){
					hasAMPProfileVisibility = true;
				}
			}
			if(hasAMPadmin){
				return 'full';
			}else if(hasAMPProfileVisibility){
				return 'read';
			}else{
				return 'no access';
			}
		}
	}
}
