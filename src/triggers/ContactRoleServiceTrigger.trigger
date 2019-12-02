/**
 * Created by ppop on 8/7/2019.
 */

trigger ContactRoleServiceTrigger on Contact_Role_Service__c (after insert, after update, after delete) {
    if(Trigger.IsAfter) {
        ShareObjectsToExternalUsers.reshareContactRoleServices(Trigger.new ,Trigger.oldMap);
    }
}