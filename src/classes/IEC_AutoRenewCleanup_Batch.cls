global class IEC_AutoRenewCleanup_Batch implements Database.Batchable<sObject>
{
	List<IEC_Event_Release__c> releases;
	String finalAction;

	global IEC_AutoRenewCleanup_Batch(List<IEC_Event_Release__c> lst, String fAction)
	{
		releases = lst;
		finalAction = fAction;
	}

	public void setProcessingStatus(Set<Id> releaseIds)
	{
		List<IEC_Event_Release__c> releasesToUpdate = [SELECT Id, Processing_Status__c FROM IEC_Event_Release__c WHERE Id IN:releaseIds];
		for(IEC_Event_Release__c release : releasesToUpdate) release.Processing_Status__c = 'Auto Renew Log Cleanup is processing ....';
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


		String query = 'SELECT Id FROM Order WHERE IEC_Event_Release__c!=null AND Is_Paid__c = false AND IEC_Event_Release__c IN (\'' + String.join(releaseIds, '\' , \'') + '\') ';

		return Database.getQueryLocator(query);
	}

	 	global void execute(Database.BatchableContext BC, List<sObject> scope){delete scope;}

	global void finish(Database.BatchableContext BC)
	{
		if(finalAction == 'GenerateEventAutoRenewals')
			for(IEC_Event_Release__c release : releases)  Database.executeBatch(new IEC_Event_Renewal_CreateOrders_Batch(release, null),Utility.getIntegerSetting('IEC Event renewal batch size'));
	}

}
