trigger attachmentTrigger on Attachment (before insert, before update, before delete, after insert) {
	if(Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)) {
		List<Id> lsParentIds = new List<Id>();
		for(Attachment t : Trigger.new) {
			lsParentIds.add(t.ParentId);
		}

		Map<Id, LocalGovernance_Meeting__c> mpLGM =
			new Map<Id, LocalGovernance_Meeting__c>([SELECT Id, Name, Local_GoverNance__r.Active__c FROM LocalGovernance_Meeting__c WHERE Id IN :lsParentIds]);
		for(Attachment t : Trigger.new) {
			if(mpLGM.containsKey(t.ParentId) && !mpLGM.get(t.ParentId).Local_GoverNance__r.Active__c) t.addError('cannot modify for inactive groups');
		}
	}
	if(Trigger.isBefore && Trigger.isDelete) {
		List<Id> lsParentIds = new List<Id>();
		for(Attachment t : Trigger.old) {
			lsParentIds.add(t.ParentId);
		}

		Map<Id, LocalGovernance_Meeting__c> mpLGM =
		new Map<Id, LocalGovernance_Meeting__c>([SELECT Id, Name, Local_GoverNance__r.Active__c FROM LocalGovernance_Meeting__c WHERE Id IN :lsParentIds]);
		for(Attachment t : Trigger.old) {
			if(mpLGM.containsKey(t.ParentId) && !mpLGM.get(t.ParentId).Local_GoverNance__r.Active__c) t.addError('cannot modify for inactive groups');
		}
	}
	
	if(Trigger.isAfter && Trigger.isInsert) {  
		
		List<Id> atts = new List<Id>();
		List<String> VALID_RT = new list<String>{
					'CasesEurope', 'Cases_Global', 'CasesAmericas', 'CasesMENA', 'ExternalCasesIDFSglobal',	
					'Cases_China_North_Asia', 'ComplaintIDFS', 'Inter_DPCs', 'Invoicing_Collection_Cases',
					 'Cases_SIS_Help_Desk', 'InternalCasesEuropeSCE', 'CS_Process_IDFS_ISS', 'ID_Card_Application'
				};
			
		for(Attachment t : Trigger.new) {
			if(t.ParentId.getSObjectType() == Case.SObjectType){
				atts.add(t.ParentId);
			}
		}
		
		if(atts.size()>0){

			List<Case> caseList = [select id,Status, ClosedDate from Case where id IN: atts AND Status = 'Closed'
			 AND RecordType.DeveloperName IN : VALID_RT AND ClosedDate=LAST_N_DAYS:14 AND Origin != 'Chat'];

			if(caseList.size() > 0){
				for(case c: caseList){
					c.Status = 'Reopen';
				} 
				update caseList;
			}
		}
	}
}