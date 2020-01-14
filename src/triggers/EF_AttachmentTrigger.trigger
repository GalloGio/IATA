trigger EF_AttachmentTrigger on Attachment (after insert)
{
	List<Id> parentIdsList = new List<Id>();

	if(EF_AttachmentTriggerHandler.isMemberOfMassUploadGroup())
	{
		List<EF_Document_Log__c> toUploadList = new List<EF_Document_Log__c>();
		for(Attachment att : Trigger.new)
		{
			toUploadList.add(EF_AttachmentTriggerHandler.createDocumentLogRecord(att));
			ParentIdsList.add(att.ParentId);
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

	for(Attachment att : Trigger.new)
		ParentIdsList.add(att.ParentId);


	if(!parentIdsList.isEmpty()){
		List<Case> casesToUpdate = new List<Case>();
		Id RT_ICCS_MM_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'FDS_ICCS_Membership_Management');
		Id RT_ICCS_PM_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'FDS_ICCS_Product_Management');
		Id RT_ICCS_BAM_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'FDS_ICCS_Bank_Account_Management');
		Id RT_ICCS_ASP_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'FDS_ASP_Management');
		List<Id> ICCSRecordTypesList = new List<Id>{RT_ICCS_MM_Id, RT_ICCS_PM_Id, RT_ICCS_BAM_Id, RT_ICCS_ASP_Id};
		system.debug('query >>> '+[SELECT Id, New_interaction__c FROM Case WHERE Id IN :parentIdsList AND RecordTypeId IN :ICCSRecordTypesList]);

		for(Case c : [SELECT Id, New_interaction__c, OwnerId FROM Case WHERE Id IN :parentIdsList AND RecordTypeId IN :ICCSRecordTypesList]){
			if(UserInfo.getUserId() != c.OwnerId){
				c.New_interaction__c = 'New Attachment';
				//c.New_Interaction_Date__c = system.NOW();
				casesToUpdate.add(c);
			}
		}

		if(!casesToUpdate.isEmpty())
			update casesToUpdate;
	}
}
