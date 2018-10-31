trigger PriceTableTrigger on Price_Table__c (before insert, before update) {
	
	PriceTableTriggerHandler ptHandler = new PriceTableTriggerHandler();
	ptHandler.run();
}