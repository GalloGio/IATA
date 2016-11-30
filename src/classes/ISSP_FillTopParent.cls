public without sharing class ISSP_FillTopParent {
	/*************Before Insert:************************/
	/* 
	 * Parameter: List of accounts with a valid parent.
	 * The objective is to change the Top_Parent.
	 */
	public static void accountsBeforeInsertTopParent(List<Account> newAccounts){
		// Make a set of parent ids:
		Set<Id> parentsIds = new Set<Id>();
		for(Account acct : newAccounts){
			parentsIds.add(acct.ParentId);
		}
		// Get the parents, in order to get their Top_Parent:
		Map<String, Account> parentAccoounts = new Map<String, Account>([
		                                                                 Select a.Top_Parent__c, a.ParentId, a.Name 
		                                                                 From Account a
		                                                                 Where a.Id IN :parentsIds
		                                                                 ]);
		// Finally, assign the new Top_Parent
		// if parent.top_parent == null, current.top_parent = parent.//
		// else, current.top_parent == parent.top_parent//
		for(Account acct : newAccounts){
			Account parentAcct = parentAccoounts.get(acct.ParentId);
			if(parentAcct.Top_Parent__c == null){
				acct.Top_Parent__c = parentAcct.Id;
			} else{
				acct.Top_Parent__c = parentAcct.Top_Parent__c;
			}
		}
	}

	/*
	 * Returns subset (list) of accounts which their parent is not null.
	 */
	public static List<Account> getAccountsToInsert(List<Account> triggerAcct){
		List<Account> acctsToChange = new List<Account>();
		for(Account acct : triggerAcct){
			if(acct.ParentId != null){
				acctsToChange.add(acct);
			}
		}
		return acctsToChange;
	}
	/*************End Before Insert:************************/

	/*
	 * Get the accounts to update their Top parent.
	 * Parameter: trigger.old, trigger.new
	 */
	public static List<Account> getAcctsToUpdate(Map<Id,Account> newAccts, Map<Id,Account> oldAccts){
		// Add to the final list only accounts that their
		// parent has been changed:
		List<Account> listToReturn = new List<Account>();
		for(Account acct : newAccts.values()){
			if(acct.ParentId != oldAccts.get(acct.Id).ParentId || ISSP_Constant.fiilTopBatch){
				system.debug('****Enter');
				listToReturn.add(acct);
			}
		}
		return listToReturn;
	}
	/*************After Update:************************/
	/*
	 * Update the accounts in the list given as the parameter.
	 * This methos assumes that all accounts in the list should be
	 * updated.
	 * The method is changing the account's top_parent (root) according
	 * to their parent's top parent, and updates top_parent field for 
	 * all the accounts that are in the hierarchy of the updated account.
	 */
	public static void accountsAfterUpdateTopParent(List<Account> acctsToUpdate, Map<Id, Account> triggerNew, Map<Id, Account> triggerOld){

		if(!ISSP_Constant.fiilTopBatch){
			// Populate a set of ids of accounts whose their TopParent is in the
			// list of new updated accounts:
			Set<Id> idsAcctToUpdate = new Set<id>();
			for(Account acct : acctsToUpdate){
				if(triggerOld.get(acct.Id).Top_Parent__c != null){
					idsAcctToUpdate.add(triggerOld.get(acct.Id).Top_Parent__c);
				} else{
					idsAcctToUpdate.add(acct.Id);
				}

			}
			// Get all accounts with Top_Parent in the Top_Parent
			// of the accounts-to-be-updated-list.
			// Meaning: get all full trees of all accounts-to-be-updated
			List<Account> accountsByTopParent = new List<Account>([
			                                                       Select a.Top_Parent__c, a.ParentId 
			                                                       From Account a
			                                                       Where a.Top_Parent__c IN :idsAcctToUpdate
			                                                       ]);
			// Create map of sets, key: root of the tree (Top_Parent).
			// Value: a set of ids of accounts that are under the account
			// to be updated in the hierarchy.
			Map<Id, Set<String>> parentToNodes = new Map<Id, Set<String>>();
			for(Account acct : acctsToUpdate){ // Add first the initial node - the account to be updated
				//parentToNodes.put(acct.Top_Parent__c, new Set<String>{acct.Id});
				if(triggerOld.get(acct.Id).Top_Parent__c == null){
					parentToNodes.put(triggerOld.get(acct.Id).Id, new Set<String>{acct.Id});
				}else{
					parentToNodes.put(triggerOld.get(acct.Id).Top_Parent__c, new Set<String>{acct.Id});
				}
			}


			// Go through the accountsByTopParent, pop, add to the compatible set
			Integer addedThisIteration = 0;
			Integer thisAccountPlace = 0;
			List<Integer> placesToRemove = new List<Integer>();
			while(true){
				addedThisIteration = 0;
				thisAccountPlace = 0;
				placesToRemove.clear();
				for(Account acct : accountsByTopParent){
					String nextAccountId = acct.Id;
					String nextAccountParentId =  acct.ParentId;
					String nextAccountTopParent = acct.Top_Parent__c;
					Set<String> tempSet = parentToNodes.get(nextAccountTopParent);
					if(tempSet != null 
							&& tempSet.contains(nextAccountParentId)
							&& !tempSet.contains(nextAccountId)){
						// If the set in the map contains the parent id, it means that 
						// the current account is somewhere down his hierarchy, therefore
						// we add him to the same set.
						tempSet.add(nextAccountId);
						placesToRemove.add(thisAccountPlace);
						addedThisIteration += 1;
					}
					thisAccountPlace += 1;
				}
				if(addedThisIteration == 0){
					// If the loop went through all of the accounts, 
					// and added none, then there is nothing more to add.
					break;
				}
			}
			// Change all of the account whose ids are in the map:
			Set<String> allIdsToChange = new Set<String>();
			for(Set<String> nextSet : parentToNodes.values()){
				allIdsToChange.addAll(nextSet);
			}
			List<Account> acctToChangeRoot = new List<Account>([
			                                                    Select a.Top_Parent__c, a.ParentId , a.Name
			                                                    From Account a
			                                                    Where a.Id IN :allIdsToChange
			                                                    ]);
			/*acctToChangeRoot are the accounts that needs to be changed + source nodes*/
			List<Account> childAcctsToChange = new List<Account>();
			for(Account acct : acctToChangeRoot){
				if(!triggerNew.containsKey(acct.Id)){
					childAcctsToChange.add(acct); // Add the childs in the hierarchy
				}
			}
			// Map that maps the old top parent to the new ones.
			Map<String, String> topParentOldToNew = new Map<String, String>();
			for(Account acct : acctsToUpdate){
				if(triggerNew.get(acct.id).Top_Parent__c == null){
					topParentOldToNew.put(triggerOld.get(acct.Id).Top_Parent__c, acct.Id);
				} else if(triggerOld.get(acct.Id).Top_Parent__c == null){ // The old top parent is null
					topParentOldToNew.put(acct.Id, triggerNew.get(acct.id).Top_Parent__c);
				} 
				else{
					topParentOldToNew.put(
							triggerOld.get(acct.Id).Top_Parent__c, triggerNew.get(acct.id).Top_Parent__c);
				}	
			}

			for(Account acct : childAcctsToChange){
				acct.Top_Parent__c = topParentOldToNew.get(acct.Top_Parent__c);
			}
			update childAcctsToChange;
		}
		else{
			list<Account> childAccList  = [select Parent.Top_Parent__c,Top_Parent__c,ParentId from Account where ParentId in:trigger.newMap.keySet()];
			for(Account acc : childAccList){
				if(acc.Parent.Top_Parent__c!=null)
					acc.Top_Parent__c = acc.Parent.Top_Parent__c;
				else
					acc.Top_Parent__c = acc.ParentId;
			}
			update childAccList;
		}
		return;
	}
	/*************End After Update:************************/
	/*************Before Update:************************/
	/*
	 * Trigger - before update on Account obj.
	 * All it does is updating the node's Top_Parent.
	 * The AfterUpdate trigger will update it's hierarchy.
	 */
	public static void accountsBeforeUpdateTopParent(List<Account> acctsToUpdate, Map<Id, Account> oldTrigger, Map<Id, Account> newTrigger){
		Set<Id> parentIds = new Set<Id>();
		for(Account acct : acctsToUpdate){
			parentIds.add(acct.ParentId);
		}
		// Get a map of parent nodes
		Map<String, Account> parentNodes = new Map<String, Account>([
		                                                             Select a.Top_Parent__c, a.ParentId, a.Name 
		                                                             From Account a
		                                                             Where a.Id IN :parentIds
		                                                             ]);
		// Iterate through new accounts, and change their Top_Parent
		for(Account acct : acctsToUpdate){
			Account parent = parentNodes.get(acct.ParentId);
			if(acct.ParentId == null){
				acct.Top_Parent__c = null;
			} else if(parent.Top_Parent__c == null){
				acct.Top_Parent__c = acct.ParentId;
			} else{ // parent.Top_Parent__c is not null
				acct.Top_Parent__c = parent.Top_Parent__c;
			}
		}
	}
	/*************End Before Update:************************/

	/*************Before Delete:************************/
	/*
	 * Update the direct children of each deleted account.
	 * This method changes their Parent and updated, which
	 * fires up the Update trigger, that will change their Top_Parent.
	 */
	public static void accountsAfterDeleteTopParent(Map<Id, Account> deletedAccounts){
		// Select all childs for each deleted account
		Set<Id> deletedIds = new Set<Id>(); 
		deletedIds = deletedAccounts.keySet();
		system.debug('\n\n\n\n KEYSET \n' + deletedIds + '\n\n\n\n');
		// Get all child accounts:
		List<Account> childAccounts = new List<Account>([
		                                                 Select a.Top_Parent__c, a.ParentId, a.Name 
		                                                 From Account a
		                                                 Where a.ParentId IN :deletedIds
		                                                 ]);
		Map<String, Account> deletedAccountsQuery = new Map<String, Account>([
		                                                                      Select a.Top_Parent__c, a.ParentId, a.Name 
		                                                                      From Account a
		                                                                      Where a.Id IN :deletedIds
		                                                                      ]);
		// Iterete through the children and assign new Parent:
		for(Account acct : childAccounts){
			Account prevParent = deletedAccountsQuery.get(acct.ParentId);
			if(prevParent.ParentId == null){ // If the deleted account had no parent
				acct.ParentId = null;
			} else{
				acct.ParentId = prevParent.ParentId;
			}
		}
		update childAccounts;
	}
	/*************End Before Delete:************************/

}