public with sharing class ANG_AgencyAuthorizationTriggerHandler {

    public static final ID formOfPaymentRT = AMS_Utils.getId('Agency_Authorization__c','FormOfPayment');
    public static Map<Id,String> accountsName = new Map<Id,String>(); 
    public static void handleBeforeInsert(List<Agency_Authorization__c> newMap){
		verifyAAUniqueness(newMap);
	}

    public static void handleBeforeUpdate(List<Agency_Authorization__c> newMap, Map<Id,Agency_Authorization__c> oldMap){
		verifyAAUniqueness(newMap);
		removeUniqueId(newMap);
	}

	public static void removeUniqueId(List<Agency_Authorization__c> newMap){

		for(Agency_Authorization__c aa: newMap){
			if(aa.RecordTypeId == formOfPaymentRT && aa.Unique_Identifier__c <> null)
				aa.Unique_Identifier__c = null;
		}

	}

	public static void verifyAAUniqueness(List<Agency_Authorization__c> newMap){

		Set<Id> accountsInvolved = new Set<Id>();
		Map<Id,List<Agency_Authorization__c>> toVerifyAA = new Map<Id,List<Agency_Authorization__c>>();

		for(Agency_Authorization__c aa : newMap){

			if(aa.RecordTypeId == formOfPaymentRT && aa.Status__c == 'Active'){
				accountsInvolved.add(aa.Account__c);

				if(toVerifyAA.containsKey(aa.Account__c))
					toVerifyAA.get(aa.Account__c).add(aa);
				else
					toVerifyAA.put(aa.Account__c,new List<Agency_Authorization__c>{aa});
			}
		}

		List<Agency_Authorization__c> aaFromAccounts = [Select ID,Account__c, Account__r.IATACode__c,ANG_FormOfPayment_ID__c, RecordTypeId from Agency_Authorization__c where Account__c in:accountsInvolved and RecordTypeId = :formOfPaymentRT and Status__c = 'Active' and Id not in :newMap];

		Map<Id,List<Agency_Authorization__c>> accountsAAMap = new Map<Id,List<Agency_Authorization__c>>();

		For(Agency_Authorization__c aa: aaFromAccounts){

			if(accountsAAMap.containsKey(aa.Account__c)){
				accountsAAMap.get(aa.Account__c).add(aa);
			}
			else
				accountsAAMap.put(aa.Account__c, new List<Agency_Authorization__c>{aa});

			//Populate MapAccountName for show in error
			accountsName.put(aa.Account__c, aa.Account__r.IATACode__c);
		}

		For(Id accountId: accountsAAMap.keySet()){

			verifyAAPerAccountUniqueness(accountsAAMap.get(accountId),toVerifyAA.get(accountId));

		}

	}

	public static void verifyAAPerAccountUniqueness(List<Agency_Authorization__c> currentAccountList, List<Agency_Authorization__c> newAAValues){

		for(Agency_Authorization__c aa: newAAValues){

			if(hasMatchingConditions(aa,currentAccountList))
				aa.addError('There is already an Agency Authorization with the same Type/FormOfPayment for the Account ' + accountsName.get(aa.Account__c));
		}
	}

	public static boolean hasMatchingConditions(Agency_Authorization__c aa, List<Agency_Authorization__c> currentAccountList){

		for(Agency_Authorization__c aaElem: currentAccountList){

			if(aa.RecordTypeId == aaElem.RecordTypeId && aa.ANG_FormOfPayment_ID__c == aaElem.ANG_FormOfPayment_ID__c && aa.Id <> aaElem.Id){
				return true;
			}
		}

		return false;

	}
}