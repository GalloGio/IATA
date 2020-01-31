trigger TopicAssignmentTrigger on TopicAssignment (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

	if (Trigger.isInsert) {
		if (Trigger.isBefore) {
			TopicAssignmentHelper.AccountTopicValidation(Trigger.New);
		}
	}
}
