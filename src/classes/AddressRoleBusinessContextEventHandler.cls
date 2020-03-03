public without sharing class AddressRoleBusinessContextEventHandler {
	public void OnAfterInsert(List<AddressRoleBusinessContext__e> addressRoleBusinessContextEvents){
		updateIntegrationLog(addressRoleBusinessContextEvents);
	}

	/**
	 * For each Address Role Business Context Event, if an Integration Log if found, we will updated it with the event Id
	 *
	 * @param List<AddressRoleBusinessContext__e>
	 */
	private void updateIntegrationLog(List<AddressRoleBusinessContext__e> addressRoleBusinessContextEvents){
		Map<Id, String> eventIdByARBCId = new Map<Id, String>();
		
		for(AddressRoleBusinessContext__e addressRoleBusinessContextEvent : addressRoleBusinessContextEvents){
			eventIdByARBCId.put(addressRoleBusinessContextEvent.RecordId__c, addressRoleBusinessContextEvent.ReplayId);
		}

		List<Integration_Log__c> integrationLogs = new List<Integration_Log__c>();
		for(Integration_Log__c integrationLog : [
			SELECT Id, RecordId__c
			FROM Integration_Log__c
			WHERE RecordId__c IN : eventIdByARBCId.keySet()
		]){
			integrationLog.External_Transaction_Id__c = eventIdByARBCId.get(integrationLog.RecordId__c);
			integrationLogs.add(integrationLog);
		}
		if(integrationLogs.size() > 0){
			update integrationLogs;
		}
	}
}