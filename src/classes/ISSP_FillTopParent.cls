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
    public static void accountsAfterUpdateTopParent(List<Account> acctsToUpdate, Map<Id, Account> triggerOld){

		Map<Id, Id> newTopParents = new Map<Id, Id>();
		Map<Id, Set<Id>> hierarchies = new Map<Id, Set<Id>>();

		for(Account a : acctsToUpdate){
			Id triggerOldParent = triggerOld.get(a.Id).Top_Parent__c;
			Id oldParent = triggerOldParent == null ? a.Id : triggerOldParent;

			if(!hierarchies.containsKey(oldParent)) 
				hierarchies.put(oldParent, new Set<Id>());
			hierarchies.get(oldParent).add(a.Id);

			newTopParents.put(oldParent, a.Top_Parent__c == null ? a.Id : a.Top_Parent__c);
		}

		List<Account> childsToUpdate = new List<Account>();
		for(Account child : [SELECT Id, ParentId, Parent.ParentId, Top_Parent__c FROM Account WHERE Top_Parent__c IN :hierarchies.keySet()]){
			Set<Id> hierarchy = hierarchies.get(child.Top_Parent__c);

			if(hierarchy.contains(child.ParentId) || hierarchy.contains(child.Parent.ParentId)){
				child.Top_Parent__c = newTopParents.get(child.Top_Parent__c);
				childsToUpdate.add(child);
			}
		}

		if(!childsToUpdate.isEmpty()) 
			update childsToUpdate;
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