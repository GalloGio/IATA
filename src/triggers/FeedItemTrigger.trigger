trigger FeedItemTrigger on FeedItem (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

	if (Trigger.isInsert) {
		if (Trigger.isAfter) {

			FeedItemHelper.CheckPostTopics(Trigger.New);

		}
	}
}
