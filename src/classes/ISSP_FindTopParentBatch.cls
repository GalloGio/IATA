global with sharing class ISSP_FindTopParentBatch  implements Database.Batchable<sObject>{
	global string query = 'Select a.Top_Parent__c, a.Parent.Top_Parent__c, a.Parent.ParentId, a.ParentId, a.Id ,(Select Id From Accounts__r) From Account a where a.ParentId = null';
	global Database.QueryLocator start(Database.BatchableContext BC){
		system.debug('\n\n\n\n  $$$$$' +query );
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope){
		ISSP_Constant.fiilTopBatch = true;
		List<Account> listToUpdate = new List<Account>();
		for(Account acc: (List<Account>)scope){
			if(acc.Accounts__r.size() > 0)
				listToUpdate.add(acc);
		}
		system.debug('\n\n\n\n  $$$$$' +listToUpdate );
		database.update(listToUpdate,false);
	}

	global void finish(Database.BatchableContext BC){
   		ISSP_Constant.fiilTopBatch = false;
	}
}
