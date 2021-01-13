public with sharing class EF_LocationCodeHandler
{

	// Ensures that the selected Location Code on Billing Agreement also exists on Contract
	public static void verifyBaLocationCodeExistsOnContract(List<EF_Location_Code__c> newList, Map<Id, EF_Location_Code__c> oldMap)
	{
		Set<Id> baIds = new Set<Id>();
		List<EF_Location_Code__c> toBeValidated = new List<EF_Location_Code__c>();

		for(EF_Location_Code__c code : newList)
		{
			if(code.EF_Airline_Billing_Agreement__c != null)
			{
				baIds.add(code.EF_Airline_Billing_Agreement__c);
				toBeValidated.add(code);
			}
		}

		if(baIds.size() > 0)
		{
			Map<Id, EF_Billing_Agreement__c> baIdMap = new Map<Id, EF_Billing_Agreement__c>([select Contract__c, Id from EF_Billing_Agreement__c where Id in :baIds]);
			Set<Id> contractIds = new Set<Id>();
			for(EF_Billing_Agreement__c ba : baIdMap.values())
			{
				contractIds.add(ba.Contract__c);
			}

			Map<Id, Set<String>> contractIdLocationCodeNameMap = new Map<Id, Set<String>>();
			List<EF_Location_Code__c> contractLocationsList = [select id, Location_Code__c, Location_Code__r.Name, Contract__c
																from EF_Location_Code__c where Contract__c in :contractIds];
			for(EF_Location_Code__c lc : contractLocationsList)
			{
				if(contractIdLocationCodeNameMap.get(lc.Contract__c) == null)
				{
					contractIdLocationCodeNameMap.put(lc.Contract__c, new Set<String>());
					contractIdLocationCodeNameMap.get(lc.Contract__c).add(lc.Location_Code__c);
				} else
				{
					contractIdLocationCodeNameMap.get(lc.Contract__c).add(lc.Location_Code__c);
				}
			}

			for(EF_Location_Code__c lc : toBeValidated)
			{
				EF_Billing_Agreement__c relatedBa = baIdMap.get(lc.EF_Airline_Billing_Agreement__c);
				Set<String> locationCodeIdsUnderContract = contractIdLocationCodeNameMap.get(relatedBa.Contract__c);
				if(locationCodeIdsUnderContract != null)
				{
					if(!locationCodeIdsUnderContract.contains(lc.Location_Code__c))
					{
						lc.addError('Selected Location Code is not present on the Contract related to the Billing Agreement.');
					}
				} else
				{
					lc.addError('There are no Location Codes on Contract. Please add at least one before attempting adding any to the Billing Agreement.');
				}
			}
		}
	}
}
