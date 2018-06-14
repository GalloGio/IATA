trigger trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete on Account (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {

    if(!AMS_TriggerExecutionManager.checkExecution(Account.getSObjectType(), 'trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete')) { return; }
    
    if( //Test.isRunningTest()||
     TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndeleteGet()) return ; 

   
    List<Account> accountsToChange;
    List<Account> acctToUpdate;
    
    if(trigger.isInsert && trigger.isBefore){
        accountsToChange = 
            ISSP_FillTopParent.getAccountsToInsert(trigger.new);
        if(!accountsToChange.isEmpty()) ISSP_FillTopParent.accountsBeforeInsertTopParent(accountsToChange);
    }
    else if(trigger.isUpdate && trigger.isAfter){
        acctToUpdate = // Get accts to update 
            ISSP_FillTopParent.getAcctsToUpdate(trigger.newMap, trigger.oldMap);
        if(!acctToUpdate.isEmpty())ISSP_FillTopParent.accountsAfterUpdateTopParent(acctToUpdate, trigger.newMap, trigger.oldMap);
    }
    else if(trigger.isBefore && trigger.isDelete){
        ISSP_FillTopParent.accountsAfterDeleteTopParent(trigger.oldMap);
    }
    else if(trigger.isBefore && trigger.isUpdate){
        system.debug('CHECK OUT TopParentBeforeUpdate');
        if(!AMS_AgencyRelationshipTriggerHandler.AMS_HierarchyProcess){
            system.debug('CHECK IN TopParentBeforeUpdate');
            acctToUpdate = // Get accts to update 
                ISSP_FillTopParent.getAcctsToUpdate(trigger.newMap, trigger.oldMap);
            // Update the accounts:
            ISSP_FillTopParent.accountsBeforeUpdateTopParent(acctToUpdate, trigger.oldMap, trigger.newMap);
        }
    }
    
        
        set<Id> accIdSet = new set<Id>();
        
        if(trigger.isInsert && trigger.isBefore)
        if(accountsToChange!= null && accountsToChange.size()>0){
            for(Account acc : accountsToChange){
                if(acc.Top_Parent__c!=null)
                    accIdSet.add(acc.Top_Parent__c);
                else
                    accIdSet.add(acc.Id);
            }
        }
        
        if(trigger.isAfter&& trigger.isUpdate)
        if(acctToUpdate!= null && acctToUpdate.size()>0){
            for(Account acc : acctToUpdate){
                if(acc.Top_Parent__c!=null)
                    accIdSet.add(acc.Top_Parent__c);
                else
                    accIdSet.add(acc.Id);
                if(trigger.oldMap.get(acc.Id).Top_Parent__c!=null)
                    accIdSet.add(trigger.oldMap.get(acc.Id).Top_Parent__c);
            }
        }
        
        if(accIdSet.isEmpty()) return;
        
        set<Id> userIdSet = new set<Id>();
        for(AccountTeamMember atm : [select Id,UserId from AccountTeamMember where AccountId in:accIdSet and TeamMemberRole =:'Portal Administrator']){
            userIdSet.add(atm.UserId);
        }
        system.debug('\n\n\n accIdSet:'+accIdSet+'\n\n\n');
        system.debug('\n\n\n userIdSet:'+userIdSet+'\n\n\n');
        ISSP_Constant.UserAccountChangeParent = true;
        update [select Id from User where Id in:userIdSet];
    
}