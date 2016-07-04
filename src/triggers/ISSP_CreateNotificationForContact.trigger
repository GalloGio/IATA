trigger ISSP_CreateNotificationForContact on Contact (before update, after insert) {
    //if(!Test.isRunningTest() )
    if(trigger.isUpdate && trigger.isBefore) 
    ISSP_CreateNotification.CreateNotificationForSobjectList(trigger.new);

    if(trigger.isInsert && trigger.isAfter){ //INC253595
		ISSP_CreateNotification.conAfterInsert(trigger.new, trigger.newMap);
    }
}