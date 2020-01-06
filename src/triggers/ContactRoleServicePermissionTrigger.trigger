/**
 * Created by ppop on 8/6/2019.
 */

trigger ContactRoleServicePermissionTrigger on Contact_Role_Service_Permission__c (after insert, after update, after delete) {
	if(Trigger.IsAfter) {
		ShareObjectsToExternalUsers.reshareContactRoleServicePermissions(Trigger.new ,Trigger.oldMap);
	}
}
