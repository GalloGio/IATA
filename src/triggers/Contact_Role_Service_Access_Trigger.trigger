trigger Contact_Role_Service_Access_Trigger on Contact_Role_Service_Access__c (before insert, before update) {

    ContactRoleServiceAccessTriggerHandler triggerHandler = new ContactRoleServiceAccessTriggerHandler();

    /*Before Insert */
    if(Trigger.isInsert && Trigger.isBefore) {
        triggerHandler.OnBeforeInsert(Trigger.New);
    }

    /*Before Update*/
    if(Trigger.isUpdate && Trigger.isBefore) {
        triggerHandler.OnBeforeUpdate(Trigger.Old, Trigger.New, Trigger.oldMap);
    }


}