/**
 * This trigger works after account update, the ISSP_AccountTriggerHandler.onAfterUpdate
 * checks for the following terms:
 * oldAcc.Accumulated_Irregularities__c != newAcc.Accumulated_Irregularities__c
 * AND mapRecordTypeNamesById.get(newAcc.RecordTypeId) = 'Agency' AND newAcc.Type = 'IATA Cargo Agent'.
 * If those terms are met a notification are sends to all contact of the account.
 * Created By:  Niv.Goldenberg 19-11-2014
 * Modified By: Niv.Goldenberg 20-11-2014
 */
trigger ISSP_Notification_Account_AfterUpdate on Account (after update)
{

	if(!AMS_TriggerExecutionManager.checkExecution(Account.getSObjectType(), 'ISSP_Notification_Account_AfterUpdate')) { return; }

	if(!ISSP_AccountTriggerHandler.preventTrigger)
	{
		ISSP_AccountTriggerHandler.preventTrigger = true;
		ISSP_AccountTriggerHandler.onAfterUpdate(trigger.oldMap, trigger.newMap);
	}
}
