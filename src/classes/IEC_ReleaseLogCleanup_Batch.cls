/********************************************
 *	Description: This batch class is use to perform IEC_Event_Release_Log__c
 *	Author: David D
 *	Version: 1.0
 *
 ***********************************************/
global class IEC_ReleaseLogCleanup_Batch implements Database.Batchable<sObject>
{
	List<IEC_Event_Release__c> releases;
	String finalAction;

	global IEC_ReleaseLogCleanup_Batch(List<IEC_Event_Release__c> lst, String fAction)
	{
		releases = lst;
		finalAction = fAction;
	}

	public void setProcessingStatus(Set<Id> releaseIds)
	{
		List<IEC_Event_Release__c> releasesToUpdate = [SELECT Id, Processing_Status__c FROM IEC_Event_Release__c WHERE Id IN:releaseIds];
		for(IEC_Event_Release__c release : releasesToUpdate)
			release.Processing_Status__c = 'Auto Renew Log Cleanup is processing ....';

		update releasesToUpdate;
	}

	global Database.QueryLocator start(Database.BatchableContext BC)
	{
		List<String> releaseIds = new List<String>();
		Set<Id> setReleaseIds = new Set<Id>();
		for(IEC_Event_Release__c release : releases)
		{
			releaseIds.add(release.Id);
			setReleaseIds.add(release.Id);
		}

		setProcessingStatus(setReleaseIds);

		String query = 'SELECT Id FROM IEC_Event_Release_Log__c WHERE 	IEC_Event_Release__c IN (\'' + String.join(releaseIds, '\' , \'') + '\') ';

		return Database.getQueryLocator(query);
	}

	 	global void execute(Database.BatchableContext BC, List<sObject> scope)
	 	{
		delete scope;
	}

	global void finish(Database.BatchableContext BC)
	{
		if(finalAction == 'ClearAutoRenewals')
		{
			Database.executeBatch(new IEC_AutoRenewCleanup_Batch(releases, 'GenerateEventAutoRenewals'));
		}
	}

}
