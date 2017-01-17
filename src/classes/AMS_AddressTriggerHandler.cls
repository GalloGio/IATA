public with sharing class AMS_AddressTriggerHandler {

	public static void handleBeforeUpdate(List<AMS_Address__C> addressList) {

		verifyAddressUniqueness(addressList);
	}

	public static void handleBeforeInsert(List<AMS_Address__C> addressList) {

		verifyAddressUniqueness(addressList);
	}



	public static void verifyAddressUniqueness(List<AMS_Address__C> addressList){

		Set<Id> addressesIds = new Set<Id>();

		Set<Id> accountAddresses = new Set<Id>();

		for(AMS_Address__c addr : addressList){
			System.debug('Check the address ' + addr);
			accountAddresses.add(addr.Account__c);
			if(addr.Id != null)
				addressesIds.add(addr.Id);
		}

		Set<AMS_Address__c> allAddresses = new Set<AMS_Address__c>();

		//System.debug('accountAddresses is:' + accountAddresses);

		// let's get all the addresses of the account involved that are not in the trigger
		List<AMS_Address__c> allOldAddresses = [SELECT Id, Account__c, Address_Type__c from AMS_Address__C where Account__r.Id in :accountAddresses and Id not in :addressList];

		//System.debug('All old Addresses:' + allOldAddresses);

		// add the old addresses to the set
		allAddresses.addAll(allOldAddresses);

		// add the new changed/added addresses to the set
		allAddresses.addAll(addressList);

		// we should have the full list to inspect.
		// now lets divide the addresses between accounts

		Map<Id,List<AMS_Address__C>> addressesByAccount = new Map<Id,List<AMS_Address__C>>();

		for(AMS_Address__c addr : allAddresses){

			if(addressesByAccount.containsKey(addr.Account__c)){

				addressesByAccount.get(Addr.Account__c).add(addr);
			}
			else{
				addressesByAccount.put(addr.Account__c, new List<AMS_Address__C>{addr});
			}
		}

		// that we have the map divided per account, let's see if there are any duplicates

		List<AMS_Address__C> addressListOfAccount = new List<AMS_Address__C>();

		for(Id accountId : addressesByAccount.keySet()){

			addressListOfAccount = addressesByAccount.get(accountId);
		
			checkForDuplicatedTypes(addressListOfAccount,addressesIds);
		}
		

	}

	public static void checkForDuplicatedTypes(List<AMS_Address__C> addressListOfAccount,Set<Id> addressesIds ){

		Set<String> allTypesOfAddress = new Set<String>();

		//System.debug('Checking the list of Addresses to be inserted' + addressListOfAccount);
		//System.debug('All addresses Ids involved directly on the insert/update process');

		for(AMS_Address__C addr: addressListOfAccount){

			if(addr.Address_Type__c == null)// no need to check it.
				continue;

			String[] types = addr.Address_Type__c.split(';');

			for(String typeAdd: types){

				//System.debug('Checking for Address with Id ' + addr.id + ' and types ' + types + ' against ' + allTypesOfAddress);

				if(allTypesOfAddress.contains(typeAdd)){

					if(addr.Id == null || addressesIds.contains(addr.Id))
						addr.addError('The type ' + typeAdd + ' in the Address to insert/update is duplicated in the Account Addresses');

				}else{
					// as we have other specific validation for primary addressses , we will skipp this type for validation.
					if(typeAdd != 'Primary')
						allTypesOfAddress.add(typeAdd);
				}
			}
		}
	}
}