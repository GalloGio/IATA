trigger CommentTrigger on Comment__c (after delete, after insert, after undelete,
after update, before delete, before insert, before update) {

	if ( Trigger.isBefore ) {
		if (Trigger.isInsert) {
			CommentHandler.setObjectiveInfo(Trigger.new[0]);
		}
		if (Trigger.isUpdate) {
			//CommentHandler.setObjectiveInfo(Trigger.new[0]);
		}
		if (Trigger.isDelete) {
		}
	}

	if ( Trigger.isAfter ) {
		if (Trigger.isInsert) {
		}
		if (Trigger.isUpdate) {
		}
		if (Trigger.isDelete) {
		}
	}
}
