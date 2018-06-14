trigger ISSP_CreateNotificationForContact on Contact (before update, after insert, after update) {
    //if(!Test.isRunningTest() )
    if(trigger.isUpdate && trigger.isBefore) 
    ISSP_CreateNotification.CreateNotificationForSobjectList(trigger.new);

    if(trigger.isInsert && trigger.isAfter){ //INC253595

    	for (Contact con : Trigger.new) {
	       //only send the notification if the Portal Status is Pending / Contact created by Portal
	       if (con.User_Portal_Status__c == ISSP_Constant.NEW_CONTACT_STATUS)
	        	ISSP_CreateNotification.SendEmailToPortalAdminNewContact(trigger.new);   
   		}
    	
    } 
    	
}