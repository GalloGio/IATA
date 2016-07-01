trigger ISSP_CreateNotificationForContact on Contact (before update) {
    //if(!Test.isRunningTest() )
    ISSP_CreateNotification.CreateNotificationForSobjectList(trigger.new);
}