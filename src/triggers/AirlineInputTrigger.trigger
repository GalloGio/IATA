trigger AirlineInputTrigger on Airline_Input__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
	if (Trigger.isInsert) {

		if (Trigger.isBefore) {

		} else if (Trigger.isAfter) {
			AirlineInputHandler.CopyAirlineInputToCaseComments(Trigger.newMap, Trigger.oldMap, Trigger.isUpdate, Trigger.isInsert);

		}


	} else if (Trigger.isUpdate) {

		if (Trigger.isBefore) {

		} else if (Trigger.isAfter) {
			AirlineInputHandler.CopyAirlineInputToCaseComments(Trigger.newMap, Trigger.oldMap, Trigger.isUpdate, Trigger.isInsert);

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
