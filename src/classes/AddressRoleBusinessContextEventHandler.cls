public without sharing class AddressRoleBusinessContextEventHandler {
	public void OnAfterInsert(List<AddressRoleBusinessContext__e> addressRoleBusinessContextEvents){
		createIntegrationLog(addressRoleBusinessContextEvents);
	}

	private void createIntegrationLog(List<AddressRoleBusinessContext__e> addressRoleBusinessContextEvents){
		Map<Id, Address_Role_Business_Context__c> addressRoleBusinessContextById = getAddressRoleBusinessContextById(addressRoleBusinessContextEvents);
		List<AddressRoleBusinessContext__e> addressRoleBusinessContextEventsToProcess = new List<AddressRoleBusinessContext__e>();
		for(AddressRoleBusinessContext__e addressRoleBusinessContextEvent : addressRoleBusinessContextEvents){
			if(addressRoleBusinessContextById.containsKey(addressRoleBusinessContextEvent.RecordId__c)){
				Address_Role_Business_Context__c addressRoleBusinessContext = addressRoleBusinessContextById.get(addressRoleBusinessContextEvent.RecordId__c);
				if(eventIsSentFromFlow(addressRoleBusinessContext) || eventIsSentFromBillingAddress(addressRoleBusinessContext)){
					addressRoleBusinessContextEventsToProcess.add(addressRoleBusinessContextEvent);
				}
			}
		}
		if(!addressRoleBusinessContextEventsToProcess.isEmpty())
			doCreateIntegrationLog(addressRoleBusinessContextEventsToProcess);
	}

	private Map<Id, Address_Role_Business_Context__c> getAddressRoleBusinessContextById(List<AddressRoleBusinessContext__e> addressRoleBusinessContextEvents){
		return new Map<Id, Address_Role_Business_Context__c>([
				SELECT Id, Address_Role__r.Role_Type__c, Account_Activation_Context_Status__c
				FROM Address_Role_Business_Context__c
				WHERE Id IN :getAddressRoleBusinessContextIds(addressRoleBusinessContextEvents)
		]);
	}

	private Set<Id> getAddressRoleBusinessContextIds(List<AddressRoleBusinessContext__e> addressRoleBusinessContextEvents){
		Set<Id> addressRoleBusinessContextIds = new Set<Id>();
		for(AddressRoleBusinessContext__e addressRoleBusinessContextEvent : addressRoleBusinessContextEvents){
			addressRoleBusinessContextIds.add(addressRoleBusinessContextEvent.RecordId__c);
		}
		return addressRoleBusinessContextIds;
	}

	private Boolean eventIsSentFromFlow(Address_Role_Business_Context__c addressRoleBusinessContext){
		return addressRoleBusinessContext.Address_Role__r.Role_Type__c == 'Business' && addressRoleBusinessContext.Account_Activation_Context_Status__c == 'Pending';
	}

	private Boolean eventIsSentFromBillingAddress(Address_Role_Business_Context__c addressRoleBusinessContext){
		return addressRoleBusinessContext.Address_Role__r.Role_Type__c == 'Billing';
	}

	private void doCreateIntegrationLog(List<AddressRoleBusinessContext__e> addressRoleBusinessContextEvents){
		List<Integration_Log__c> integrationLogs = new List<Integration_Log__c>();
		for(AddressRoleBusinessContext__e addressRoleBusinessContextEvent : addressRoleBusinessContextEvents){
			integrationLogs.add(new Integration_Log__c(
					Object_Type__c = 'Address_Role_Business_Context__c',
					Record_Id__c = addressRoleBusinessContextEvent.RecordId__c,
					RecordId__c = addressRoleBusinessContextEvent.RecordId__c,
					External_Transaction_Id__c = addressRoleBusinessContextEvent.ReplayId,
					Status__c = 'In Progress'
			));
		}
		insert integrationLogs;
	}
}