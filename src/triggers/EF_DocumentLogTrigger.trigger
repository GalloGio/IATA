trigger EF_DocumentLogTrigger on EF_Document_Log__c (before insert, before update, after update)
{
	if(Trigger.isBefore && Trigger.isInsert)
	{
		for(EF_Document_Log__c dl : Trigger.new)
		{
			EF_DocumentLogHelper.setStatus(dl, 'Attachment - Uploaded', 'The standard attachment was successfully uploaded with ID: '+dl.AttachmentId__c+'.');
		}
	}

	if(Trigger.isBefore && Trigger.isUpdate)
	{
		EF_DocumentLogHelper.identifyDocumentsWithCompleteMetadata(Trigger.new, Trigger.oldMap);
		
	}

	if(Trigger.isAfter && Trigger.isUpdate)
	{
		List<EF_Document_Log__c> toAmazonList = EF_DocumentLogHelper.identifyDocumentsForAmazonProcessing(Trigger.new, Trigger.oldMap);
		System.debug('**************** toAmazonList '+toAmazonList);
		if(toAmazonList.size() > 0)
		{
			// TODO: start the Amazon processing
		}

		Set<Id> standardAttachmentsToDelete = EF_DocumentLogHelper.identifyDocumentsWithSuccessfulAmazonProcessing(Trigger.new, Trigger.oldMap);
		// TODO: have a list of EF_Document_Logs to be updated with success or failure status...


		if(standardAttachmentsToDelete.size() > 0)
		{
			// Delete the standard attachments
			List<Attachment> stAttachmentstoDelete = [select Id from Attachment where Id in :standardAttachmentsToDelete];
			try
			{
				delete stAttachmentstoDelete;
				// Log success
			} catch(Exception e)
			{
				// Log failure
			}
		}
	}
}