trigger Account_Role_Platform_Event on AccountRole__e (after insert) {

	if(trigger.isAfter && trigger.isInsert){
		//Create records in IntegrationLogs
		List<Integration_Log__c> newIntegrationLogsList = new List<Integration_Log__c>();
		String RECTYPE_Track_Response = RecordTypeSingleton.getInstance().getRecordTypeId('Integration_Log__c', 'Track_Response');
		for (AccountRole__e event : Trigger.New) {
			if(event.RecordType__c == 'ITP'){
				Integration_Log__c il = IntegrationLogUtils.createAccountRoleIntegrationLog(event.ReplayId, RECTYPE_Track_Response, event.RecordId__c);
				EventBus.TriggerContext.currentContext().setResumeCheckpoint(event.ReplayId);
				newIntegrationLogsList.add(il);
				System.debug('il - ' + il);
			}
		}
		if(newIntegrationLogsList.size() > 0){
			IntegrationLogUtils.insertIntoIntegrationLog(newIntegrationLogsList);
			System.debug('newIntegrationLogsList - ' + newIntegrationLogsList);
		}
	}

}
