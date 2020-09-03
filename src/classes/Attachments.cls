public with sharing class Attachments {
	public Map<Id, Attachment> recordsMap { get; private set; }

	public Attachments(Map<Id,Attachment> attachmentMap) {
		recordsMap = attachmentMap;
	}

	public void onAfterInsert(){
		//only fire integration if user making the insert is not integration user
		if(! CaseItems.getIsIntegrationUser()){
			//if attachment on a case, with a case item, fire platform event
			//map of Attachment Ids and related Case Ids
			Map<Id,Id> attachmentIdToCaseIdMap = getCaseIdWithAttachments(recordsMap.values());
			//list of CaseItems that have a related Case with inserted Attachment
			List<Case_Item__c> caseItemList = [SELECT Id FROM Case_Item__c WHERE Case__c IN :attachmentIdToCaseIdMap.values()];
			
			//call update on related case items to fire integration
			CaseItems caseItems = new CaseItems(new Map<Id,Case_Item__c>(caseItemList));
			caseItems.onAfterUpdate();
		}
	}

	public void onAfterUpdate(){
		//only fire integration if user making update is not integration user
		if(! CaseItems.getIsIntegrationUser()){
			//if attachment on a case, with a case item, fire platform event
			//map of Attachment Ids and related Case Ids
			Map<Id,Id> attachmentIdToCaseIdMap = getCaseIdWithAttachments(recordsMap.values());
			//list of CaseItems that have a related Case with updated Attachment
			List<Case_Item__c> caseItemList = [SELECT Id FROM Case_Item__c WHERE Case__c IN :attachmentIdToCaseIdMap.values()];

			//call update on related case items to fire integration
			CaseItems caseItems = new CaseItems(new Map<Id,Case_Item__c>(caseItemList));
			caseItems.onAfterUpdate();
		}
	}
	
	public void onAfterDelete(){
		//only fire integration if user making delete is not integration user
		if(! CaseItems.getIsIntegrationUser()){
			//if attachment on a case, with a case item, fire platform event
			//map of Attachment Ids and related Case Ids
			Map<Id,Id> attachmentIdToCaseIdMap = getCaseIdWithAttachments(recordsMap.values());
			//list of CaseItems that have a related Case with deleted Attachment
			List<Case_Item__c> caseItemList = [SELECT Id FROM Case_Item__c WHERE Case__c IN :attachmentIdToCaseIdMap.values()];         
			
			//call update on related case items to fire integration
			CaseItems caseItems = new CaseItems(new Map<Id,Case_Item__c>(caseItemList));
			caseItems.onAfterUpdate();
		}
	}
	
	public void onAfterUndelete(){
		//only fire integration if user making delete is not integration user
		if(! CaseItems.getIsIntegrationUser()){
			//if attachment on a case, with a case item, fire platform event
			///map of Attachment Ids and related Case Ids
			Map<Id,Id> attachmentIdToCaseIdMap = getCaseIdWithAttachments(recordsMap.values());
			//list of CaseItems that have a related Case with undeleted Attachment
			List<Case_Item__c> caseItemList = [SELECT Id FROM Case_Item__c WHERE Case__c IN :attachmentIdToCaseIdMap.values()];         
			
			//call update on related case items to fire integration
			CaseItems caseItems = new CaseItems(new Map<Id,Case_Item__c>(caseItemList));
			caseItems.onAfterUpdate();
		}
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