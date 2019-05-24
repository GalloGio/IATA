trigger IDCardApplicationTrigger on ID_Card_Application__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

	IDCardApplicationTriggerHandler.runHandler('IDCardApplicationTriggerHandler');

}