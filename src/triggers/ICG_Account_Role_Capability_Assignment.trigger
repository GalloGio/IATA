trigger ICG_Account_Role_Capability_Assignment on ICG_Account_Role_Capability_Assignment__c(before insert, after insert) {
	CW_ICG_Acc_Role_Cap_Assignment_Handler handler = new CW_ICG_Acc_Role_Cap_Assignment_Handler();
	if (Trigger.isInsert) {
		if (Trigger.isAfter) {
			handler.afterInsertFinally();
		} else if (Trigger.isBefore) {
			handler.prepareBeforeInsert();
		}
	}
}