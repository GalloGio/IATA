trigger ParticipantTrigger on Participant__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
	if (Trigger.isInsert) {

		if (Trigger.isBefore) {

        } else if (Trigger.isAfter) {
            ParticipantHelper.FlagParticipatingContacts(Trigger.new);

        }


    } else if (Trigger.isUpdate) {

        if (Trigger.isBefore) {

        } else if (Trigger.isAfter) {


        }


    } else if (Trigger.isDelete) {

        if (Trigger.isBefore) {
			ParticipantHelper.blockDeletingFromInactiveGroups(Trigger.old);


        } else if (Trigger.isAfter) {
            ParticipantHelper.UnflagParticipatingContacts(Trigger.old);
        }


    } else if (Trigger.isUnDelete) {

        if (Trigger.isAfter) {

        }

    }
}
