trigger ANG_RiskStatusDowngradeEventTrigger on ANG_Risk_Status_Downgrade__e (after insert)
{
	Set<Id> accounts = new Set<Id>();

	for (ANG_Risk_Status_Downgrade__e evt : Trigger.New)
	{
		String jsonContent = evt.Accounts__c;
		if (String.isNotBlank(jsonContent))
			accounts.addAll((Set<Id>) JSON.deserialize(jsonContent, Set<Id>.class));
	}

	System.debug(LoggingLevel.FINE, '____ [cls ANG_RiskStatusDowngradeEventTrigger] accounts: ' + accounts);

	if (! accounts.isEmpty())
	{
		// launch Apex Batch for this accounts
		Id jobId = Database.executeBatch(new ANG_RiskStatusDowngradeBatch(accounts), 1);
		System.debug(LoggingLevel.DEBUG, '____ [cls ANG_RiskStatusDowngradeEventTrigger] Executed batch ANG_RiskStatusDowngradeBatch with Id: ' + jobId);
	}

}
