/*
 * This trigger fires on every Authorized Signatories Package event and calls the appropriate method from the AuthorizedSignatoriesPackageHandler class.
 */
trigger AuthorizedSignatoriesPackageTrigger on Authorized_Signatories_Package__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
	if (Trigger.isInsert) {

		if (Trigger.isBefore) {

			AuthorizedSignatoriesPackageHandler.AllowOnlyOneASPPerAccount(Trigger.new);

		} else if (Trigger.isAfter) {
			AuthorizedSignatoriesPackageHandler.UpdateASPEffectiveDate(Trigger.new);
		}


	} else if (Trigger.isUpdate) {

		if (Trigger.isBefore) {

		} else if (Trigger.isAfter) {
			AuthorizedSignatoriesPackageHandler.UpdateASPEffectiveDate(Trigger.new);
		}


	} else if (Trigger.isDelete) {

		if (Trigger.isBefore) {

		} else if (Trigger.isAfter) {

		}


	} else if (Trigger.isUnDelete) {

		if (Trigger.isAfter) {

		}

	}
}
