trigger ICG_Capability_Assignment_Group on ICG_Capability_Assignment_Group__c(before insert, before update, after insert, after update) {
	if (Trigger.isBefore) {
		if (Trigger.isInsert || Trigger.isUpdate) {
			CW_ICG_Capability_Asgmt_Group_Handler.handleBulkBefore(Trigger.new);
		}
		if (Trigger.isInsert) {
			CW_ICG_Capability_Asgmt_Group_Handler.handleBeforeInsert(Trigger.new);
		} else if (Trigger.isUpdate) {
			CW_ICG_Capability_Asgmt_Group_Handler.handleBeforeUpdate(Trigger.oldMap, Trigger.new);
		}
	}
	if (Trigger.isAfter) {
		if (Trigger.isInsert) {
			CW_ICG_Capability_Asgmt_Group_Handler.handleAfterInsert(Trigger.newMap);
		} else if (Trigger.isUpdate) {
			CW_ICG_Capability_Asgmt_Group_Handler.handleAfterUpdate(Trigger.oldMap, Trigger.newMap);
		}
	}
}