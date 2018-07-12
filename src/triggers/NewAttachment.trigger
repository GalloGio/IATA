trigger NewAttachment on Attachment (after insert) {
	
	List<Case> caseList = new List<Case>();
	ID SISRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Cases_SIS_Help_Desk');
	for(Attachment a : Trigger.new){
		
		caseList = [Select id, casenumber, subject from Case where recordtypeId =: SISRecordTypeID and id =: a.ParentId limit 1 for update];
	}
	
	if(caseList.size() > 0){
		
		caseList[0].Has_Attachments__c = true;
		System.debug('Has Attachments - ' + caseList[0].Has_Attachments__c);
	}
	
	update caseList;
	
	
	// if the attachment is linked to an Authorized Signatories Package record, update the ASP Effective Date on the record to today()
	AuthorizedSignatoriesPackageHandler.UpdateASPEffectiveDateOnASP(Trigger.new);
	
	// if the attachment is linked to an Authorized Signatory record, update the ASP Effective Date on the record to today()
	AuthorizedSignatoriesPackageHandler.UpdateASPEffectiveDateOnAS(Trigger.new);
	
}