trigger Queue_BeforeUpd_UpdateQueueId on Auto_Queue__c (before insert, before update) {
	Auto_Queue_Triggers.findId(Trigger.New);
}
