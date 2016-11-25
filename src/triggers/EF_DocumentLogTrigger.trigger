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
		Set<Id> toAmazonList = EF_DocumentLogHelper.identifyDocumentsForAmazonProcessing(Trigger.new, Trigger.oldMap);
		if(toAmazonList.size() > 0)
		{
			// Start the Amazon processing
			EF_DocumentLogHelper.createAmazonAttachmentsFromAttachments(toAmazonList);
		}

		Set<Id> standardAttachmentsToDelete = EF_DocumentLogHelper.identifyDocumentsWithSuccessfulAmazonProcessing(Trigger.new, Trigger.oldMap);
		if(standardAttachmentsToDelete.size() > 0)
		{
			// Delete the standard attachments
			List<Attachment> stAttachmentstoDelete = [select Id from Attachment where Id in :standardAttachmentsToDelete];
			
			Map<Id, EF_Document_Log__c> logRecords = EF_DocumentLogHelper.getLogRecordsToUpdateMap(standardAttachmentsToDelete);
			List<EF_Document_Log__c> updateList = logRecords.values();
			
			try
			{
				delete stAttachmentstoDelete;
				for(EF_Document_Log__c dl : updateList)
				{
					EF_DocumentLogHelper.setStatus(dl, 'Process Completed', 'File uploaded to Amazon WS and standard Attachment deleted.');
					dl.AttachmentId__c = null;
				}
				
			} catch(Exception e)
			{
				// Log failure
				for(EF_Document_Log__c dl : updateList)
				{
					EF_DocumentLogHelper.setStatus(dl, 'Attachment - Delete Error', 'File uploaded to Amazon WS, but the standard Attachment could not be deleted. [' +e+']');
				}				
			}

			if(updateList.size() > 0)
				update updateList;
		}
	}
}