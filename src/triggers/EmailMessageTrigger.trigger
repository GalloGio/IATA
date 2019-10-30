trigger EmailMessageTrigger on EmailMessage (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    if (Trigger.isInsert) {
        if (Trigger.isAfter) {
            EmailMessageHandler.SetTheNOISentDateOnParentCase(Trigger.new);
            EmailMessageHandler.sendEmailToSenderWhenCaseClosed(Trigger.new);
            EmailMessageHandler.sendEmailToSenderWhenCaseOpened(Trigger.new); //ACAMBAS - WMO-395

            // sprint6 kpi value creation on email send action
            EmailMessageKPIHandler.createKPIValues(Trigger.new);
        }
    }
}