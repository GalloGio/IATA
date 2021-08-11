trigger UserTrigger on User (after delete, after insert, after update, after undelete, before delete, before insert, before update) {
	//create domain class
	Users users;

	//populate the appropriate records in domain class
	if(Trigger.isDelete) users = new Users(Trigger.old);
	else users = new Users(Trigger.new);

	if(Trigger.isBefore){
		if(Trigger.isInsert) users.onBeforeInsert();
		else if(Trigger.isUpdate) users.onBeforeUpdate(Trigger.oldMap);
		//else if(Trigger.isDelete) users.onBeforeDelete();
	} else{
		/* Commented because the methods are dummy and are impacting the release due to the lack of coverage
		if(Trigger.isInsert) users.onAfterInsert();
		else if(Trigger.isUpdate) users.onAfterUpdate(Trigger.oldMap);
		else if(Trigger.isDelete) users.onAfterDelete();
		else if(Trigger.isUndelete) users.onAfterUndelete();
		*/
	}
}