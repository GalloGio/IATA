trigger OperationalImprovement on Operational_Improvements__c (
	before insert, before update, before delete, after insert, after update, after delete, after undelete) {

	if (Trigger.isBefore) {
		if (Trigger.isInsert) {
			OperationalImprovementsHandler.beforeInsert(Trigger.new);
		}
		if (Trigger.isUpdate) {
			OperationalImprovementsHandler.beforeUpdate(Trigger.newMap, Trigger.oldMap);
		}
	}
}
