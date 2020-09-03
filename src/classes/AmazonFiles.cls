public with sharing class AmazonFiles {
	
	public Map<Id, AmazonFile__c> recordsMap { get; private set; }
	
	public AmazonFiles(Map<Id, AmazonFile__c> amazonFileMap) {
		recordsMap = amazonFileMap;
	}

	public void onAfterInsert(){
		//only fire integration if user making the insert is not integration user
		if(! CaseItems.getIsIntegrationUser()){
			//if Amazon File on a case, with a case item, fire platform event
			//map of Amazon File Ids and related Case Ids
			Map<Id,Id> amazonFileIdToCaseIdMap = getCaseIdWithAmazonFiles(recordsMap.values());
			//list of CaseItems that have a related Case with inserted Attachment
			List<Case_Item__c> caseItemList = [SELECT Id FROM Case_Item__c WHERE Case__c IN :amazonFileIdToCaseIdMap.values()];

			//call update on related case items to fire integration
			CaseItems caseItems = new CaseItems(new Map<Id,Case_Item__c>(caseItemList));
			caseItems.onAfterUpdate();
		}
	}

	public void onAfterUpdate(){
		//only fire integration if user making update is not integration user
		if(! CaseItems.getIsIntegrationUser()){
			//if Amazon File on a case, with a case item, fire platform event
			//map of Amazon File Ids and related Case Ids
			Map<Id,Id> amazonFileIdToCaseIdMap = getCaseIdWithAmazonFiles(recordsMap.values());
			//list of CaseItems that have a related Case with updated Amazon File
			List<Case_Item__c> caseItemList = [SELECT Id FROM Case_Item__c WHERE Case__c IN :amazonFileIdToCaseIdMap.values()];

			//call update on related case items to fire integration
			CaseItems caseItems = new CaseItems(new Map<Id,Case_Item__c>(caseItemList));
			caseItems.onAfterUpdate();
		}
	}

	public void onAfterDelete(){
		//only fire integration if user making delete is not integration user
		if(! CaseItems.getIsIntegrationUser()){
			//if Amazon File on a case, with a case item, fire platform event
			//map of Amazon File Ids and related Case Ids
			Map<Id,Id> amazonFileIdToCaseIdMap = getCaseIdWithAmazonFiles(recordsMap.values());
			//list of CaseItems that have a related Case with deleted Amazon File
			List<Case_Item__c> caseItemList = [SELECT Id FROM Case_Item__c WHERE Case__c IN :amazonFileIdToCaseIdMap.values()];

			//call update on related case items to fire integration
			CaseItems caseItems = new CaseItems(new Map<Id,Case_Item__c>(caseItemList));
			caseItems.onAfterUpdate();
		}
	}

	public void onAfterUndelete(){
		//only fire integration if user making delete is not integration user
		if(! CaseItems.getIsIntegrationUser()){
			//if Amazon File on a case, with a case item, fire platform event
			///map of Amazon File Ids and related Case Ids
			Map<Id,Id> amazonFileIdToCaseIdMap = getCaseIdWithAmazonFiles(recordsMap.values());
			//list of CaseItems that have a related Case with undeleted Amazon File
			List<Case_Item__c> caseItemList = [SELECT Id FROM Case_Item__c WHERE Case__c IN :amazonFileIdToCaseIdMap.values()];

			//call update on related case items to fire integration
			CaseItems caseItems = new CaseItems(new Map<Id,Case_Item__c>(caseItemList));
			caseItems.onAfterUpdate();
		}
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