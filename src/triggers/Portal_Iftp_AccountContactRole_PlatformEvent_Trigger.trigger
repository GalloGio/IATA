trigger Portal_Iftp_AccountContactRole_PlatformEvent_Trigger on AccountContactRole__e (after insert) {

    if(trigger.isAfter && trigger.isInsert){
        //Create records in IntegrationLogs
        List<Integration_Log__c> newIntegrationLogsList = new List<Integration_Log__c>();
        String RECTYPE_Track_Response = RecordTypeSingleton.getInstance().getRecordTypeId('Integration_Log__c', 'Track_Response');
        for (AccountContactRole__e event : Trigger.New) {
            System.debug('event ' + event);
            Integration_Log__c il = IntegrationLogUtils.createAccountContactRoleIntegrationLog(event.ReplayId, RECTYPE_Track_Response, event.RecordId__c);
            newIntegrationLogsList.add(il);
        }
        IntegrationLogUtils.insertIntoIntegrationLog(newIntegrationLogsList);
    }
}