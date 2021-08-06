global class RecordRetrievalLightningImplementation extends odigocti.RecordRetrievalLightningInterface_V3 {
	public override SearchResult SearchRecords(
		string phoneNumber,
		String internationalPhoneNumber,
		String localPhoneNumber,
		String folderId,
		String skill,
		String callId,
		String type,
		String IVRNumber
	) {
		Integer IATACodeStringPosition = 5; // FolderId will have the IATACode, must identity which position is
		String IATACode = '';
		localPhoneNumber = (!String.isBlank(localPhoneNumber)) ? localPhoneNumber.replaceFirst('^0+', '') : '';
		String searchExpression = localPhoneNumber;
		if (!String.isBlank(folderId)) {
			List<String> folderIdStrings = folderId.split('#');
			if (folderIdStrings.size()>=IATACodeStringPosition) {
				IATACode = folderIdStrings[IATACodeStringPosition];
			}
		}
		//prepare the object that will be returned to the odigo CTI
		SearchResult result = new SearchResult();

		/**
		* if is needed to manage some action when do a callback, put code here
		*/
		if ('callback'.equals(type) || 'outbound'.equals(type) || 'internal'.equals(type)) {
			result.objectType = 'Nothing';
			Set<String> setIds = new Set<String>();
			result.recordIds = setIds;
			return result;
		} else if (String.isBlank(searchExpression)) {
			result.objectType = 'Nothing';
			Set<String> setIds = new Set<String>();
			result.recordIds = setIds;
			return result;
		} else {
			/**
			 * Searching for phone and iata code in Contacts/Accounts.
			 * If nothing found, perform a SOSL search in phone fields (Contacs & Accounts)
			 */
			if (!String.isBlank(searchExpression) && searchExpression.length() > 2) {
				/**
				 * looking for every contact and account that as this phone number and iata code 
				 */
				String queryPhones = '\\+*'+internationalPhoneNumber.replaceFirst('^0+', '')+' OR '+localPhoneNumber+' OR '+phoneNumber;
				List < List < SObject >> searchList = new List < List < SObject >>();
				if (IATACode != '') { 
					searchExpression += ' OR ' + IATACode;
					String phoneWildcard = '%'+localPhoneNumber+'%';
					List<Contact> contactList = [SELECT Id, AccountId, IATA_Code__c, Account.Site, Phone, PhoneNational__c, MobilePhone, OtherPhone, Account.Phone FROM Contact WHERE (Phone LIKE :phoneWildcard OR PhoneNational__c LIKE :phoneWildcard OR MobilePhone LIKE :phoneWildcard OR OtherPhone LIKE :phoneWildcard OR Account.Phone LIKE :phoneWildcard) OR Account.Site = :IATACode OR IATA_Code__c = :IATACode LIMIT 1000];
					if (contactList.size() > 0) {
						searchList = performSearchInData(contactList, localPhoneNumber, IATACode);
					}
				}
				if (searchList.isEmpty()) {
					searchList = [
						FIND :queryPhones 
						IN PHONE FIELDS
						RETURNING 
						Contact(Id, AccountId), 
						Account(Id)
					];
				}
				if (!searchList.isEmpty()) {
					List < Account > accounts = new List<Account>();
					List < Contact > contacts = ((List < Contact > ) searchList[0]);
					if (searchList.size() > 1) {
						accounts = ((List < Account > ) searchList[1]);
					}
					if (!contacts.isEmpty()) {
						/**
						 * we found only one matching contact, so we open it
						 */
						if (contacts.size() == 1) {
							result.objectType = 'Url';
							Set < String > setIds = new Set < String > ();
							setIds.add('/lightning/cmp/c__AccountDashboardCTI?c__origin=Account&c__accountId=' + contacts[0].AccountId + '&c__contactId=' + contacts[0].Id);
							result.recordIds = setIds;
							return result;

						} else if (contacts.size() > 1) {
							/**
							 * Multiple contacts were found, we open the search page
							 */
							result.objectType = 'Search'; //keyword to open the search page
							Set < String > setIds = new Set < String > ();
							setIds.add(searchExpression); //what to search
							result.recordIds = setIds;
							return result;
						}

					} else if (!accounts.isEmpty()) {
						/**
						 * we found only one matching account, so we open it
						 */
						if (accounts.size() == 1) {
							result.objectType = 'Url';
							Set < String > setIds = new Set < String > ();
							setIds.add('/lightning/cmp/c__AccountDashboardCTI?c__origin=Account&c__accountId=' + accounts[0].id);
							result.recordIds = setIds;
							return result;

						} else if (accounts.size() > 1) {
							/**
							 * Multiple account were found, we open the search page
							 */
							result.objectType = 'Search'; //keyword to open the search page
							Set < String > setIds = new Set < String > ();
							setIds.add(searchExpression); //what to search
							result.recordIds = setIds;
							return result;
						}
					}
				}
			}
		}
		/**
		 * AT THIS POINT, WE DIDN'T FIND ANYTHING, SO WE NEED A DEFAULT BEHAVIOR
		 * We direct to the search page
		 */
		result.objectType = 'Search'; //keyword to open the search page
		Set < String > setIds = new Set < String > ();
		setIds.add(searchExpression); 	//what to search
		result.recordIds = setIds;

		return result;
	}

	/**
	 * Get and Split Contacts and Accounts
	 */
	private static List<List<SObject>> performSearchInData(List<Contact> contactList, String phoneToCheck, String iatacodeToCheck) {
		List<List<SObject>> searchList = new List<List<SObject>>();
		List<Contact> contactRecords = new List<Contact>();
		List<Contact> contactIATARecords = new List<Contact>();
		List<Account> accountRecords = new List<Account>();
		Set<Id> accountIds = new Set<Id>();
		
		if (!contactList.isEmpty()) {
			String allPhones = '';
			for (Contact contact : contactList) {
				accountIds.add(contact.AccountId);
				allPhones = contact.Phone + ' ' + contact.PhoneNational__c + ' ' + contact.MobilePhone + ' ' + contact.OtherPhone + ' ' +contact.Account.Phone;
				if (allPhones.contains(phoneToCheck) && (contact.Account.Site == iatacodeToCheck || contact.IATA_Code__c == iatacodeToCheck)) {
					contactIATARecords.add(contact);
				} else if (allPhones.contains(phoneToCheck)) {
					contactRecords.add(contact);
				}
			}
			if (!contactIATARecords.isEmpty()) {
				searchList.add(contactIATARecords);
			} else {
				searchList.add(contactRecords);
			}

			if (!accountIds.isEmpty()) {
				for (Id aId:accountIds) {
					Account acc = new Account();
					acc.Id = aId;
					accountRecords.add(acc);
				}
				searchList.add(accountRecords);
			}
		}
		return searchList;
	}
}