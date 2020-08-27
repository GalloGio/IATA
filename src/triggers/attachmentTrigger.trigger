trigger attachmentTrigger on Attachment (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	//domain class
	Attachments attachments;

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
		List<String> lstRTValid = Apex_Setting__c.getValues('RT valid to reopen attachment trigger').Text_1__c.split(',');

		for(Attachment t : Trigger.new) {
			if(t.ParentId.getSObjectType() == Case.SObjectType){
				atts.add(t.ParentId);
			}
		}
		
		if(atts.size()>0){

			List<Case> caseList = [select id,Status, ClosedDate from Case where id IN: atts AND Status = 'Closed'
			 AND RecordType.DeveloperName IN: lstRTValid  AND ClosedDate=LAST_N_DAYS:14 AND Origin != 'Chat'];

			if(caseList.size() > 0){
				for(case c: caseList){
					c.Status = 'Reopen';
				} 
				update caseList;
			}
		}
	}

	if(Trigger.isAfter){
		if(Trigger.isInsert) {
			attachments = new Attachments(Trigger.newMap);
			attachments.onAfterInsert();
		}
		if(Trigger.isUpdate){
			attachments = new Attachments(Trigger.newMap);
			attachments.onAfterUpdate();
		}
		if(Trigger.isDelete){
			attachments = new Attachments(Trigger.oldMap);
			attachments.onAfterDelete();
		}
		if(Trigger.isUndelete){
			attachments = new Attachments(Trigger.newMap);
			attachments.onAfterUndelete();
		}
	}
}