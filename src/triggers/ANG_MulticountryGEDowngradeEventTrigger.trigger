trigger ANG_MulticountryGEDowngradeEventTrigger on ANG_Multicountry_GE_Downgrade__e (after insert)
{
	Set<Id> geAccounts = new Set<Id>();
    
    for (ANG_Multicountry_GE_Downgrade__e evt : Trigger.New)
    {
        String jsonContent = evt.GE_Accounts__c;
        if (String.isNotBlank(jsonContent))
            geAccounts.addAll((Set<Id>) JSON.deserialize(jsonContent, Set<Id>.class));
    }
    System.debug('ANG_MulticountryGEDowngradeEventTrigger with GE accounts: ' + geAccounts);

    if (! geAccounts.isEmpty())
    {
        // launch Apex Batch for this GE accounts
        Id jobId = Database.executeBatch(new ANG_MulticoutryGEDowngradeBatch(geAccounts), 1);
        System.debug('executed batch ANG_MulticoutryGEDowngradeBatch with id: ' + jobId);
    }
}