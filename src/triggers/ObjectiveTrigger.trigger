trigger ObjectiveTrigger on Objective__c (after delete, after insert, after undelete,
after update, before delete, before insert, before update) {

	if ( Trigger.isBefore ) {
		if (Trigger.isInsert) {
			ObjectiveHandler.beforeInsert(Trigger.New);
		}
		if (Trigger.isUpdate) {
			ObjectiveHandler.beforeUpdate(Trigger.New, Trigger.Old);
		}
		if (Trigger.isDelete) {
			ObjectiveHandler.beforeDelete(Trigger.Old);
		}
	}

	if ( Trigger.isAfter ) {
		if (Trigger.isInsert) {
			ObjectiveHandler.afterInsert(Trigger.New);
		}
		if (Trigger.isUpdate) {
			ObjectiveHandler.afterUpdate(Trigger.New, Trigger.Old);
		}
		if (Trigger.isDelete) {
			ObjectiveHandler.afterDelete(Trigger.Old);
		}
	}

/*
	if ( Trigger.isBefore ) {
		if (Trigger.isInsert) {
			ObjectiveHandler.setObjectiveName( Trigger.new );
			ObjectiveHandler.updateAllSubobjectivesCreated( Trigger.new );
			ObjectiveHandler.updateParentCurrentValueBefore( Trigger.new );
		}
		if (Trigger.isUpdate) {
			ObjectiveHandler.updateObjectiveName( Trigger.new, Trigger.old );
			ObjectiveHandler.updateAllSubobjectivesCreated( Trigger.new );
			ObjectiveHandler.updateParentCurrentValueBefore( Trigger.new );
		}
		if (Trigger.isDelete) {
			ObjectiveHandler.updateParentCurrentValueBeforeIfDelete( Trigger.old );
		}
	}

	if ( Trigger.isAfter ) {
		if (Trigger.isInsert) {
			ObjectiveHandler.updateParentCurrentValueAfter();
			ObjectiveHandler.updateAllSubobjectivesCreatedinParent(Trigger.new);
		}
		if (Trigger.isUpdate) {
			ObjectiveHandler.updateParentCurrentValueAfter();
			ObjectiveHandler.updateAllSubobjectivesCreatedinParent(Trigger.new);
		}
		if (Trigger.isDelete) {
			ObjectiveHandler.updateParentCurrentValueAfter();
			ObjectiveHandler.updateAllSubobjectivesCreatedinParent(Trigger.old);
		}
	}
	*/

}
