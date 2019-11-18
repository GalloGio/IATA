/**
 * Created by ppop on 6/7/2019.
 */

trigger ServiceNotificationRoleTrigger on Service_Notification_Role__c (after insert, after update, before delete) {
    if((Trigger.IsAfter && (Trigger.IsInsert || Trigger.IsUpdate)) ||  (Trigger.IsBefore && Trigger.IsDelete)) {
        ShareObjectsToExternalUsers.reshareNotificationsWithUsers(Trigger.new ,Trigger.oldMap);
    }
}