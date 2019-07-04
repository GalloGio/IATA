public without sharing class DAL_WithoutSharing {

private static Id USERID = Userinfo.getUserId();

@AuraEnabled(cacheable=false)
public static String performCheckonPoll(String permSetSSO, Integer failedCount){
	List<PermissionSetAssignment> permissionSetList = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId =: USERID AND PermissionSetId IN (select id from PermissionSet Where name =: permSetSSO)];

	if(!permissionSetList.isEmpty()) {
		return 'Success';
	} else {
		List<UserProvisioningRequest> userProvisioningList = [SELECT id FROM UserProvisioningRequest WHERE SalesforceUserId =: USERID AND State = 'Failed'];
		if(userProvisioningList.size() != failedCount) {
			return 'Error';
		}
	}
	return 'Incomplete';
}
}