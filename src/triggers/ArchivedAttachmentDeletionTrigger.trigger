/*
* This trigger will ask to futur task to delete all files in Amazon linked to to deleted records.
*
*/
trigger ArchivedAttachmentDeletionTrigger on Archived_Attachment__c (after delete) {
	List<String> files2delete = new List<String>();
	//create the list of file to delete
	system.debug('[ArchivedAttachmentDeletionTrigger] deletion of   '+Trigger.old.size()+' Archived_Attachment__c requested ');
	for(Archived_Attachment__c att:Trigger.old)
		files2delete.add(att.AWS_S3_URL__c.replaceFirst('/'+att.Bucket__c,''));
	//call delete futur
	ArchivedFuturAdapter.deleteFileOnAmazon(files2delete);
}
