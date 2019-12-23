/**
* This trigger is run when an Archived Email Message is deleted.
* It will ask for deletion of linked objects:
*  - Archived_Attachment__c (Before delete)
*  - EmailMessage (after delete)
*
*/
trigger ArchivedMessageDeletionTrigger on Archived_Message__c (before delete) {


	List<Archived_Attachment__c> attachments2delete = [select Id from Archived_Attachment__c where ArchivedMessage__c in :Trigger.oldMap.keySet()];
	system.debug('[ArchivedMessageDeletionTrigger] delete  '+attachments2delete.size()+' Archived_Attachment__c ');
	delete attachments2delete;

}
