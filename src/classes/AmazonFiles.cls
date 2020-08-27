public with sharing class AmazonFiles {
	public Map<Id, AmazonFile__c> recordsMap { get; private set; }
	
	public AmazonFiles(Map<Id, AmazonFile__c> amazonFileMap) {
		recordsMap = amazonFileMap;
	}

	public void onAfterInsert(){
		//if Amazon File on a case, with a case item, fire platform event
		//map of Amazon File Ids and related Case Ids
		Map<Id,Id> amazonFileIdToCaseIdMap = getCaseIdWithAmazonFiles(recordsMap.values());
		//list of CaseItems that have a related Case with inserted Attachment
		List<Case_Item__c> caseItemList = [SELECT Id FROM Case_Item__c WHERE Case__c IN :amazonFileIdToCaseIdMap.values()];
		CaseItems.publishCaseItemsPlatformEvent(new Map<Id, Case_Item__c>(caseItemList), true, false, false, false);
	}

	public void onAfterUpdate(){
		//if Amazon File on a case, with a case item, fire platform event
		//map of Amazon File Ids and related Case Ids
		Map<Id,Id> amazonFileIdToCaseIdMap = getCaseIdWithAmazonFiles(recordsMap.values());
		//list of CaseItems that have a related Case with updated Amazon File
		List<Case_Item__c> caseItemList = [SELECT Id FROM Case_Item__c WHERE Case__c IN :amazonFileIdToCaseIdMap.values()];
		CaseItems.publishCaseItemsPlatformEvent(new Map<Id, Case_Item__c>(caseItemList), false, true, false, false);
	}
	
	public void onAfterDelete(){
		//if Amazon File on a case, with a case item, fire platform event
		//map of Amazon File Ids and related Case Ids
		Map<Id,Id> amazonFileIdToCaseIdMap = getCaseIdWithAmazonFiles(recordsMap.values());
		//list of CaseItems that have a related Case with deleted Amazon File
		List<Case_Item__c> caseItemList = [SELECT Id FROM Case_Item__c WHERE Case__c IN :amazonFileIdToCaseIdMap.values()];
		CaseItems.publishCaseItemsPlatformEvent(new Map<Id, Case_Item__c>(caseItemList), false, false, true, false);
	}
	
	public void onAfterUndelete(){
		//if Amazon File on a case, with a case item, fire platform event
		///map of Amazon File Ids and related Case Ids
		Map<Id,Id> amazonFileIdToCaseIdMap = getCaseIdWithAmazonFiles(recordsMap.values());
		//list of CaseItems that have a related Case with undeleted Amazon File
		List<Case_Item__c> caseItemList = [SELECT Id FROM Case_Item__c WHERE Case__c IN :amazonFileIdToCaseIdMap.values()];
		CaseItems.publishCaseItemsPlatformEvent(new Map<Id, Case_Item__c>(caseItemList), false, false, false, true);
	}
	  
	//creates a map of CaseId and Amazon File Id for Cases with Amazon Files
	private Map<Id,Id> getCaseIdWithAmazonFiles(List<AmazonFile__c> amazonFileList){
		Map<Id,Id> amazonFileIdToCaseIdMap = new Map<Id,Id>();
		for(AmazonFile__c amazonFile : amazonFileList){
			amazonFileIdToCaseIdMap.put(amazonFile.Id, amazonFile.Case__c);
		}
		return amazonFileIdToCaseIdMap;
	}
}
