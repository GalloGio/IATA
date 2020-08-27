public with sharing class Attachments {
	public Map<Id, Attachment> recordsMap { get; private set; }

	public Attachments(Map<Id,Attachment> attachmentMap) {
		recordsMap = attachmentMap;
	}

	public void onAfterInsert(){
		//if attachment on a case, with a case item, fire platform event
		//map of Attachment Ids and related Case Ids
		Map<Id,Id> attachmentIdToCaseIdMap = getCaseIdWithAttachments(recordsMap.values());
		//list of CaseItems that have a related Case with inserted Attachment
		List<Case_Item__c> caseItemList = [SELECT Id FROM Case_Item__c WHERE Case__c IN :attachmentIdToCaseIdMap.values()];
		CaseItems.publishCaseItemsPlatformEvent(new Map<Id, Case_Item__c>(caseItemList), true, false, false, false);
	}

	public void onAfterUpdate(){
		//if attachment on a case, with a case item, fire platform event
		//map of Attachment Ids and related Case Ids
		Map<Id,Id> attachmentIdToCaseIdMap = getCaseIdWithAttachments(recordsMap.values());
		//list of CaseItems that have a related Case with updated Attachment
		List<Case_Item__c> caseItemList = [SELECT Id FROM Case_Item__c WHERE Case__c IN :attachmentIdToCaseIdMap.values()];
		CaseItems.publishCaseItemsPlatformEvent(new Map<Id, Case_Item__c>(caseItemList), false, true, false, false);
	}
	
	public void onAfterDelete(){
		//if attachment on a case, with a case item, fire platform event
		//map of Attachment Ids and related Case Ids
		Map<Id,Id> attachmentIdToCaseIdMap = getCaseIdWithAttachments(recordsMap.values());
		//list of CaseItems that have a related Case with deleted Attachment
		List<Case_Item__c> caseItemList = [SELECT Id FROM Case_Item__c WHERE Case__c IN :attachmentIdToCaseIdMap.values()];         
		CaseItems.publishCaseItemsPlatformEvent(new Map<Id, Case_Item__c>(caseItemList), false, false, true, false);
	}
	
	public void onAfterUndelete(){
		//if attachment on a case, with a case item, fire platform event
		///map of Attachment Ids and related Case Ids
		Map<Id,Id> attachmentIdToCaseIdMap = getCaseIdWithAttachments(recordsMap.values());
		//list of CaseItems that have a related Case with undeleted Attachment
		List<Case_Item__c> caseItemList = [SELECT Id FROM Case_Item__c WHERE Case__c IN :attachmentIdToCaseIdMap.values()];         
		CaseItems.publishCaseItemsPlatformEvent(new Map<Id, Case_Item__c>(caseItemList), false, false, false, true);
	}
	  
	//creates a map of CaseId and AttachmentId for Cases with Attachments
	private Map<Id,Id> getCaseIdWithAttachments(List<Attachment> attachmentList){
		Map<Id,Id> attachmentIdToCaseIdMap = new Map<Id,Id>();
		for(Attachment attachment : attachmentList){
			attachmentIdToCaseIdMap.put(attachment.Id, attachment.ParentId);
		}
		return attachmentIdToCaseIdMap;
	}
}