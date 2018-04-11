trigger OperationalCalendar on Operational_Calendar__c (
    before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            OperationalCalendarHandler.beforeInsert(Trigger.new);
        }
    }
}