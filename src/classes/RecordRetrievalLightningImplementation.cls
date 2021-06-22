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
		Integer IATACodeStringPosition = 6; // FolderId will have the IATACode, must identity which position is
		String IATACode = '';
		if (folderId != '' && folderId.indexOf('#') > 0 ) {
			IATACode = folderId.split('#')[IATACodeStringPosition];
		}
		//prepare the object that will be returned to the odigo CTI
		SearchResult result = new SearchResult();

		/**
		* Looking for an object using the folder ID. This is mostly usefull for cases. If you don't do
			any case you can remove this "if" completly
		*/
		if ('callback'.equals(type) && !String.isBlank(folderId) && folderId.length() > 2) {
			/**
			 * This is looking for a Case, but you can set whatever you want
			 */
			List < List < SObject >> searchList = [
				FIND: FolderId
				IN ALL FIELDS
				RETURNING Case(Id)
			];

			if (searchList != null && searchList.size() > 0) {
				List < Case > casesLst = ((List < Case > ) searchList[0]);
				if (casesLst != null) {
					/**
					 * we only found one case, so we open it
					 */
					if (casesLst.size() == 1) {
						result.objectType = 'Case'; //any time of object you want to open. In this case, a Case
						Set < String > setIds = new Set < String > ();
						setIds.add(casesLst[0].id);
						result.recordIds = setIds;
						return result;
					} else if (casesLst.size() > 1) {
						result.objectType = 'Search'; //keyword to open the search page
						Set < String > setIds = new Set < String > ();
						setIds.add(folderId); // what to search in the search page
						result.recordIds = setIds;
						return result;
					}
				}
			}
		} else {
			/**
			 * searching by folder id takes priority over the basic searching
			 */
			if (!String.isBlank(localPhoneNumber) && localPhoneNumber.length() > 2) {
				/**
				 * looking for every contact and account that as this phone number and iata code in all fields
				 */
				String queryPhones = '\\+*'+internationalPhoneNumber.replaceFirst('^0+', '')+' OR '+localPhoneNumber+' OR '+phoneNumber;
				//if (IATACode != '') { queryPhones += ' OR '+IATACode; }

				List < List < SObject >> searchList = [
						FIND :queryPhones 
						IN PHONE FIELDS
						RETURNING 
						Contact(Id, AccountId), 
						Account(Id)
					];

				if (searchList != null && searchList.size() > 0) {
					List < Contact > contacts = ((List < Contact > ) searchList[0]);
					List < Account > accounts = ((List < Account > ) searchList[1]);
					if (contacts != null && contacts.size() > 0) {
						/**
						 * we found only one matching contact, so we open it
						 */
						if (contacts.size() == 1) {
							result.objectType = 'Url';
							Set < String > setIds = new Set < String > ();
							setIds.add('/apex/AccountDashboardCTI?Id=' + contacts[0].AccountId + '&contactId=' + contacts[0].Id);
							result.recordIds = setIds;
							return result;

						} else if (contacts.size() > 1) {
							/**
							 * Multiple contacts were found, we open the search page
							 */
							result.objectType = 'Search'; //keyword to open the search page
							Set < String > setIds = new Set < String > ();
							setIds.add(localPhoneNumber); //what to search
							result.recordIds = setIds;
							return result;
						}

					} else if (accounts != null && accounts.size() > 0) {
						/**
						 * we found only one matching account, so we open it
						 */
						if (accounts.size() == 1) {
							result.objectType = 'Url';
							Set < String > setIds = new Set < String > ();
							setIds.add('/apex/AccountDashboardCTI?Id=' + accounts[0].id);
							result.recordIds = setIds;
							return result;

						} else if (accounts.size() > 1) {
							/**
							 * Multiple account were found, we open the search page
							 */
							result.objectType = 'Search'; //keyword to open the search page
							Set < String > setIds = new Set < String > ();
							setIds.add(localPhoneNumber); //what to search
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
		setIds.add(localPhoneNumber); 	//what to search
		result.recordIds = setIds;

		return result;
	}
}