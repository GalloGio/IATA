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
		
		for(Attachment t : Trigger.new) {
			if(t.ParentId.getSObjectType() == Case.SObjectType){
				atts.add(t.ParentId);
			}
		}
		
		if(atts.size()>0){

			List<Case> caseList = [select id,Status from Case where id IN: atts AND Status = 'Closed'];

			if(caseList.size() > 0){
				for(case c: caseList){
					c.Status = 'Reopen';
				} 
				update caseList;
			}
		}
	}
}