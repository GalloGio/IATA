/**
 * Created by ppop on 6/19/2019.
 */

trigger DataSubmissionTrigger on Data_Submission__c (after update) {
    if(Trigger.IsUpdate && Trigger.IsAfter){
        DataSubmissionTriggerHandler.notifyExternalUsers(Trigger.oldMap, Trigger.new);
    }
}