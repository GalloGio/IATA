trigger Portal_Iftp_AccountRole_PlatformEvent_Trigger on AccountRole__e (after insert) {

    if(trigger.isAfter && trigger.isInsert){
        //Create records in IntegrationLogs
        List<Integration_Log__c> newIntegrationLogsList = new List<Integration_Log__c>();
        String RECTYPE_Track_Response = RecordTypeSingleton.getInstance().getRecordTypeId('Integration_Log__c', 'Track_Response');
        for (AccountRole__e event : Trigger.New) {
            Integration_Log__c il = IntegrationLogUtils.createAccountRoleIntegrationLog(event.ReplayId, RECTYPE_Track_Response, event.RecordId__c);
            newIntegrationLogsList.add(il);
            System.debug('il - ' + il);
        }
        IntegrationLogUtils.insertIntoIntegrationLog(newIntegrationLogsList);
        System.debug('newIntegrationLogsList - ' + newIntegrationLogsList);
    }
}