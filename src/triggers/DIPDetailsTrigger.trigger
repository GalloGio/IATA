trigger DIPDetailsTrigger on DIP_Details__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
	if (Trigger.isInsert) {

		if (Trigger.isBefore) {

		} else if (Trigger.isAfter) {

		}


	} else if (Trigger.isUpdate) {

		if (Trigger.isBefore) {
		   DIPdetailsUtil.UpdateRecordApprovers(Trigger.New, Trigger.oldMap);
		} else if (Trigger.isAfter) {

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
