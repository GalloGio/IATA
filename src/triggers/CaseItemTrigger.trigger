trigger CaseItemTrigger on Case_Item__c (before delete, after insert, after update, after delete, after undelete) {
	//domain class
	CaseItems caseItems;

	if(Trigger.isBefore){
		if(Trigger.isDelete){
			caseItems = new CaseItems(Trigger.oldMap);
			caseItems.onBeforeDelete();
		}
	}

	if(Trigger.isAfter){
		if(Trigger.isInsert) {
			caseItems = new CaseItems(Trigger.newMap);
			caseItems.onAfterInsert();
		}
		if(Trigger.isUpdate){
			caseItems = new CaseItems(Trigger.newMap);
			caseItems.onAfterUpdate();
		}
		if(Trigger.isDelete){
			caseItems = new CaseItems(Trigger.oldMap);
			caseItems.onAfterDelete();
		}
		if(Trigger.isUndelete){
			caseItems = new CaseItems(Trigger.newMap);
			caseItems.onAfterUndelete();
		}
	}
}