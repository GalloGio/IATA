trigger PriceTableTrigger on Price_Table__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	
	PriceTableTriggerHandler.runHandler('PriceTableTriggerHandler');
}