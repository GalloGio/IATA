public with sharing class EF_RelatedRecordsHandler
{
	public static void validateOnlyContractOrBaSelected(List<EF_Related_Records__c> newList)
	{
		for(EF_Related_Records__c rec : newList)
		{
			if(rec.Contract__c != null && rec.EF_Billing_Agreement__c != null)
				rec.addError('Only select either a Contract or Billing Agreement, but not both.');
		}
	}

	public static void updateHistoryOfRelationshipChanges(Map<Id, EF_Related_Records__c> newMap)
	{
		Set<Id> contractIds = new Set<Id>();
		Set<Id> baIds = new Set<Id>();
		for(EF_Related_Records__c rr : newMap.values())
		{
			if(rr.Contract__c != null)
				contractIds.add(rr.Contract__c);
			if(rr.EF_Billing_Agreement__c != null)
				baIds.add(rr.EF_Billing_Agreement__c);
		}
		Map<Id, EF_Billing_Agreement__c> baMap = new Map<Id, EF_Billing_Agreement__c>([select Id, EF_History__c from EF_Billing_Agreement__c where Id in :baIds]);
		Map<Id, Contract> contractMap = new Map<Id, Contract>([select Id, EF_History__c from Contract where Id in :contractIds]);
		List<sObject> toUpdateList = new List<sObject>();

		for(EF_Related_Records__c rr : newMap.values())
		{
			if(rr.Contract__c != null)
			{
				toUpdateList.add(writeHistoryLine(contractMap.get(rr.Contract__c), rr));
			}

			if(rr.EF_Billing_Agreement__c != null)
			{
				toUpdateList.add(writeHistoryLine(baMap.get(rr.EF_Billing_Agreement__c), rr));
			}
		}

		update toUpdateList;
	}

	public static sObject writeHistoryLine(sObject recordToUpdate, EF_Related_Records__c rr)
	{
		String currentTime = System.now().format('dd MMM yyyy HH:mm ');
		String currentUser = UserInfo.getName();
		String comments = 'Set '+rr.Name + ' to: ';
		if(rr.Case__c != null)
			comments = comments + ' [Case: ' + rr.Case_Name__c + '] ';
		if(rr.Contact__c != null)
			comments = comments + ' [Contact: ' + rr.Contact_Name__c + '] ';

		String commentsHistory = (String) recordToUpdate.get('EF_History__c');
		if(commentsHistory == null)
			commentsHistory = '';

		String oldHistory = commentsHistory;
		commentsHistory = currentTime + ' by ' + currentUser + ': ' + comments.trim() + '\n';
		commentsHistory = commentsHistory + oldHistory.trim();
		recordToUpdate.put('EF_History__c', commentsHistory);
		return recordToUpdate;
	}
}
