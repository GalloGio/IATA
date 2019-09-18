trigger Contact_Role_Service_Access_Trigger on Contact_Role_Service_Access__c (before insert, before update, after update, after insert, after delete) {

    ContactRoleServiceAccessTriggerHandler triggerHandler = new ContactRoleServiceAccessTriggerHandler();
    /*Before Insert */
    if(Trigger.isInsert && Trigger.isBefore) {
        triggerHandler.OnBeforeInsert(Trigger.New);
    }

    /*After Insert */
    if(Trigger.isInsert && Trigger.isAfter) {
        triggerHandler.OnAfterInsert(Trigger.New);
    }

    /*Before Update*/
    if(Trigger.isUpdate && Trigger.isBefore) {
        triggerHandler.OnBeforeUpdate(Trigger.Old, Trigger.New, Trigger.oldMap);
    }

    /*After Update*/
    if(Trigger.isUpdate && Trigger.isAfter){
        ContactRoleServiceAccessTriggerHandler.notifyUserAboutStatusChange(Trigger.oldMap, Trigger.new);
        triggerHandler.OnAfterUpdate(Trigger.New, Trigger.oldMap);
    }

    /*After Delete*/
    if(Trigger.isDelete && Trigger.isAfter) {
        triggerHandler.OnAfterDelete(Trigger.old);
    }

    if(Trigger.isAfter) {
        ShareObjectsToExternalUsers.shareObjectsByRoleAccessChange(Trigger.new ,Trigger.oldMap);
    }
}