/**
 * Created by LBERB on 17/10/2019.
 */

public with sharing class AccountTriggerHandler {

	public void OnAfterUpdate(List<Account> oldObjects, List<Account> updatedObjects, Map<Id, Account> updatedObjectsMap) {
		CustomerSyncUtils utils = new CustomerSyncUtils();

		// Synchronize to SAP/DMS
		utils.doSynchronisation(
				new List<CustomerSyncUtils.Context>{
						CustomerSyncUtils.Context.Standard,
						CustomerSyncUtils.Context.Branch
				},
				utils.getSObjectsToSynchronizeOnUpdate(oldObjects, updatedObjectsMap),
				SObjectSyncUtils.TYPE_UPDATE
		);
	}
}