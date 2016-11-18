trigger EF_DocumentLogTrigger on EF_Document_Log__c (before insert, after update)
{
	if(Trigger.isBefore && Trigger.isInsert)
	{
		// TODO: place log line of successful attachment insertion
	}

	if(Trigger.isBefore && Trigger.isUpdate)
	{
		// Ensure that mandatory fields are set up correctly:
		for(EF_Document_Log__c l : Trigger.new)
		{
			if(EF_DocumentLogHelper.validateMandatoryFields(l))
				l.Status__c = 'Metadata Updated';
			else
				l.Status__c = 'Attachment - Failure';
		}
	}

	if(Trigger.isAfter && Trigger.isUpdate)
	{
		EF_DocumentLogHelper.updateLogRecords(Trigger.new, Trigger.oldMap);
	}
}