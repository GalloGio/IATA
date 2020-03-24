public with sharing class AccountTriggerHandler {
	public void OnAfterUpdate(List<Account> oldObjects, List<Account> updatedObjects, Map<Id, Account> updatedObjectsMap) {
		CustomerSyncUtils utils = new CustomerSyncUtils();
		utils.doSynchronisation(
				new List<CustomerSyncUtils.Context>{
						CustomerSyncUtils.Context.Standard,
						CustomerSyncUtils.Context.Branch
				},
				utils.getSObjectsToSynchronizeOnUpdate(oldObjects, updatedObjectsMap),
				Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete
		);
	}
}