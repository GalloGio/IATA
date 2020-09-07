trigger ICG_Capability_Assignment_Group on ICG_Capability_Assignment_Group__c(after insert, after update) {
	if (Trigger.isAfter) {
		if (Trigger.isInsert) {
			CW_ICG_Capability_Asgmt_Group_Handler.handleAfterInsert(Trigger.newMap);
		} else if (Trigger.isUpdate) {
			CW_ICG_Capability_Asgmt_Group_Handler.handleAfterUpdate(Trigger.newMap);
		}
	}
}