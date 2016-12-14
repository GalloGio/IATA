trigger EF_AttachmentTrigger on Attachment (after insert)
{
	if(EF_AttachmentTriggerHandler.isMemberOfMassUploadGroup())
	{
		List<EF_Document_Log__c> toUploadList = new List<EF_Document_Log__c>();
		for(Attachment att : Trigger.new)
		{
			toUploadList.add(EF_AttachmentTriggerHandler.createDocumentLogRecord(att));
		}

		if(toUploadList.size() > 0)
		{
			try
			{
				insert toUploadList;

			} catch(Exception e)
			{
				// EF_DocumentLogHelper.logError()
			}
		}
	}
}