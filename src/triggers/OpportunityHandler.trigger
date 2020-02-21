/*
 * This trigger fires on every opportunity event and calls the appropriate method from the RCRMUtil class.
 */
trigger OpportunityHandler on Opportunity (after delete, after insert, after undelete, after update, before delete, before insert, before update) {

	if (Trigger.isInsert) {

		if (Trigger.isBefore) {

		} else if (Trigger.isAfter) {

			RCRMUtil.HandleRCRMOpportunityAfterInsert(Trigger.newMap);

		}


	} else if (Trigger.isUpdate) {

		if (Trigger.isBefore) {

			//RCRMUtil.ValidateRCRMOppAmountWhenClosing(Trigger.newMap, Trigger.oldMap);

			RCRMUtil.HandleRCRMOpportunityBeforeUpdate(Trigger.newMap, Trigger.oldMap);

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
