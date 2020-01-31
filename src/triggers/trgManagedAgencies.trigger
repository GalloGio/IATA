trigger trgManagedAgencies on Managed_agency__c (before insert, before update) {

		List<String> accountIDs  = new List<String>();
		Map<String, Integer> keyContactPerAccount = new Map<String, Integer>();
		Map<String, Integer> delegatePerAccount = new Map<String, Integer>();
		List<String> cids = new List<String>();
		for (Managed_agency__c ma : Trigger.new) {
				accountIds.add(ma.Account__c);
				cids.add(ma.contact__c);
		}

		// check exisiting  account delegate and key contact
		List<Managed_agency__c> accountsManagedAgenciesrecord = [select account__c, delegate__c from Managed_agency__c where account__c in :accountIds];
		for (Managed_agency__c ma : accountsManagedAgenciesrecord ) {
				if (ma.delegate__c) {
						if (delegatePerAccount.containsKey(ma.account__c))
								delegatePerAccount.put(ma.account__c,  delegatePerAccount.get(ma.account__c) + 1);
						else
								delegatePerAccount.put(ma.account__c,  1);
				} else {
						if (keyContactPerAccount .containsKey(ma.account__c))
								keyContactPerAccount .put(ma.account__c,  keyContactPerAccount .get(ma.account__c) + 1);
						else
								keyContactPerAccount .put(ma.account__c,  1);
				}
		}

		for (Managed_agency__c ma : Trigger.new) {
				if (keyContactPerAccount .containsKey(ma.account__c) && ma.delegate__c == false)
						ma.adderror('Account can only have one key contact. Please define record as a delegate');
				if (delegatePerAccount.get(ma.account__c) == 10 && ma.delegate__c )
						ma.adderror('Account can only hav two delegates');
		}

		//check if contact is member of agency hierarchy
		//contact must be a bart of agency OR sub agencies
		//can only be done if trigger concerns < Managed_agency__c records.. else too much queries risk
		/*
		if(trigger.new.size()<10){
			 List<Contact> contacts = [select Id, IATA_code__c, AccountID from  contact where Id in :cids];
			 List<Account> accounts = [select IATACode__C, Id, ParentId from Account where Id in :accountIDs ];
			 Map<Managed_agency__c,List<String>> app2check = new Map<Managed_agency__c,List<String>>();
			 for(Managed_agency__c ma:Trigger.new){
					 for(contact c:contacts){
							 if(c.Id == ma.contact__c){
									 if(c.accountId!=ma.account__c){
											 app2check.put(ma,new List<String>{c.AccountId});
									 }
							 }
					 }
			 }

			 do {
					 try{
							 List<Managed_agency__c> founded = new List<Managed_agency__c>();
							 List<Managed_agency__c> onError = new List<Managed_agency__c>();
							 for(Managed_agency__c ma:app2check.keySet()){
									 List<Account> accs = [select IATACode__C, Id, ParentId from Account where ParentId in :app2check.get(ma) ];
									 app2check.get(ma).clear();
									 for(Account acc:accs){
											 if(acc.Id==ma.account__c)
													 founded.add(ma);
											 else
													 app2check.get(ma).add(acc.Id);
									 }
							 }
							 for(Managed_agency__c ma:founded)
									 app2check.remove(ma);
							 for(Managed_agency__c ma:app2check.keySet()){
									 if(app2check.get(ma).size()==0){
											 onError.add(ma);
											 ma.addError('This contact is not in selected account hierarchy');
									 }
							 }
							 for(Managed_agency__c ma:onError)
									 app2check.remove(ma);
					 }catch(Exception e){
							 system.debug('Exeption when check contact...'+e.getMessage());
					 }
			 }while(app2check.size()>0);
		}
		*/
}
