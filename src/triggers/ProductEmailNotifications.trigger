/****************************************************************************************************
	Created by Kevin Ky 2015-12-23
****************************************************************************************************/
trigger ProductEmailNotifications on Product_Email_Notification__c (after delete, after insert, after update, before delete, before insert, before update) {
	ProductEmailNotification_Dom.triggerHandler();
}
