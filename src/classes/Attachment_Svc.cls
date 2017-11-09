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

	//FM 06-11-2017 - AMSU28 - add "submitted" state to OSCAR record when agents attach something to the case
	public static void validateAttachmentIsCase_DGR_Certification(List<Attachment> attachments)
	{
		System.debug('Attachment_Svc - validateAttachmentIsCase_DGR_Certification');
		List<AMS_OSCAR__c> updOscar = new List<AMS_OSCAR__c>();
		Set<Id> oscarIds = new Set<Id>();

		for(Attachment attach : attachments)
		{
			if(attach.ParentId.getSobjectType() == AMS_OSCAR__c.SobjectType)
			{
				oscarIds.add(attach.ParentId);
			}
		}
		System.debug('oscarIds: ' + oscarIds);
		List<AMS_OSCAR__c> lOSCAR = [Select Id, Status__c from AMS_OSCAR__c 
											where id in :oscarIds 
											AND Process__c = :AMS_Utils.CERTIFICATION 
											AND Status__c in ('Accepted_Future Date','Renewal not completed')];

		System.debug('lOSCAR: ' + lOSCAR);

		List<Attachment> lAuxAttach = [SELECT ParentId,Name FROM Attachment WHERE ParentId in :oscarIds];
		Map<ID, Integer> mAuxAttach = new Map<ID, Integer>();

		//Populate Map with the number of attachments that exist in the OSCARs		
		for(Attachment attch : lAuxAttach){
			if(!mAuxAttach.containsKey(attch.ParentId)){
				mAuxAttach.put(attch.ParentId, 1);
			}else{
				Integer i = mAuxAttach.get(attch.ParentId) + 1;
				mAuxAttach.put(attch.ParentId, i);
			}
		}		

		System.debug('mAuxAttach: ' + mAuxAttach);

		for(AMS_OSCAR__c auxOscar : lOSCAR){
			if(auxOscar != null){

				//Check for other attachments
				Integer attachSize = 0;
				if(mAuxAttach.containsKey(auxOscar.Id)){
					attachSize = mAuxAttach.get(auxOscar.Id);
				}
				
				System.debug('attachSize: ' + attachSize);
				//only set the status on the 1st attachment loaded
				if(attachSize == 1){
					
					auxOscar.Status__c = 'Submitted';
					
					updOscar.add(auxOscar);
				}
			}
		}

		System.debug('updOscar: ' + updOscar);
		//if anny update the status of the cases
		update updOscar;
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