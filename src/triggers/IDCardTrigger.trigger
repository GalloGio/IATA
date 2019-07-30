trigger IDCardTrigger on ID_Card__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

	IDCardTriggerHandler.runHandler('IDCardTriggerHandler');
}