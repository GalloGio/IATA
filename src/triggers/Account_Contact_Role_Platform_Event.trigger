trigger Account_Contact_Role_Platform_Event on AccountContactRole__e (after insert) {

    if(trigger.isAfter && trigger.isInsert){
        
        //Create records in IntegrationLogs
        List<Integration_Log__c> newIntegrationLogsList = new List<Integration_Log__c>();
        String RECTYPE_Track_Response = RecordTypeSingleton.getInstance().getRecordTypeId('Integration_Log__c', 'Track_Response');
        for (AccountContactRole__e event : Trigger.New) {
            System.debug('event ' + event);
            if(event.RecordType__c == 'ITP'){
                Integration_Log__c il = IntegrationLogUtils.createAccountContactRoleIntegrationLog(event.ReplayId, RECTYPE_Track_Response, event.RecordId__c);
                EventBus.TriggerContext.currentContext().setResumeCheckpoint(event.replayId); 
                newIntegrationLogsList.add(il);
            }
        }
        if(newIntegrationLogsList.size() > 0){
            IntegrationLogUtils.insertIntoIntegrationLog(newIntegrationLogsList);
        }
    }
    
}