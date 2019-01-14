public with sharing class Attachment_Svc 
{
	public static void validateTnCAttachmentExist(List<Attachment> attachments)
	{
		Attachment_sel attachmentSelector = new Attachment_sel(); 

		Set<Id> tncIds = new Set<Id>();
		for(Attachment attach : attachments)
		{
			//-- Validate Parent is a T&C record
			if(attach.ParentId.getSObjectType() == Schema.Term_and_Condition__c.SObjectType)
			{
				tncIds.add(attach.ParentId);	
			}
		}

		Map<Id, List<Attachment>> attachmentsByParent =  attachmentSelector.getAttachments(tncIds);
		
		for(Attachment attach : attachments)
		{
			if(attachmentsByParent.containsKey(attach.ParentId))
			{
				//-- TnC already have attachment 
				Attachment existingAttachment = attachmentsByParent.get(attach.ParentId)[0];
				attach.addError('T&C already has attachment:'+existingAttachment.Name);
			}
		}
	}

	public static void validateAttachmentIsPDF(List<Attachment> attachments)
	{
		//@todo: bulk it
		for(Attachment attach : attachments)
		{
			if(attach.ParentId.getSobjectType() == Term_and_Condition__c.SobjectType && ( !attach.Name.contains('.pdf')))
			{
				attach.addError('Attachment for T&C must be PDF document');
			}
		}
	}

	/****************************************************************************************************
        Created by Kevin Ky 2015-12-21
            Delete all the giving Attachments
    ****************************************************************************************************/
    public static void deleteAttachments(List<Attachment> attachments){
        String prefixOrder = Order.sObjectType.getDescribe().getKeyPrefix();
        List<Attachment> lstAttachmentToDelete = new List<Attachment>();
        for (Attachment a : attachments)
            if (String.valueOf(a.ParentId).startsWith(prefixOrder))
                lstAttachmentToDelete.add(a);
        delete lstAttachmentToDelete; 
    }

	/****************************************************************************************************
	    Created by David D 02/2016
	    	Set Attachment_Changed__c flag when attachment changed (deleted and replaced buy a new one), 
	    	or new version of T&C comes
	****************************************************************************************************/
    public static void setTnCDeletedFlag(List<Attachment> attachments)
    {
    	Set<Id> tncIds = new Set<Id>();
    	for(Attachment attach : attachments)
        {
            if(attach.ParentId.getSobjectType() == Term_and_Condition__c.SobjectType)
            {
                tncIds.add(attach.ParentId);
            }
        }

        if(tncIds.size() > 0)
        {
        	List<Term_and_Condition__c> tncs = [SELECT Id, Attachment_Changed__c FROM Term_and_Condition__c WHERE Id IN :tncIds];
        	for(Term_and_Condition__c tnc : tncs)
        	{
        		tnc.Attachment_Changed__c = true;
        		tnc.Status__c = 'Draft';
        	}

        	update tncs;
        }
    }

}