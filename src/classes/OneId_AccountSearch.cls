public without sharing class OneId_AccountSearch {
	public class SearchWrapper {
	    @AuraEnabled public List<Account> accList {get; set;}
	    @AuraEnabled public Integer totalResults {get; set;}
	}

	@AuraEnabled
	public static SearchWrapper searchAccounts(String search, String customerType, List<String> fieldsToQuery, List<String> fieldsToSearch, Map<String, String> filters){

		// ADD Injection security
		search = String.escapeSingleQuotes(search);
		SearchWrapper sw = new SearchWrapper();

		System.debug(loggingLevel.FINE, '____ [cls OneId_AccountSearch - searchAccounts] search - ' + search);
		System.debug(loggingLevel.FINE, '____ [cls OneId_AccountSearch - searchAccounts] customerType - ' + customerType);
		System.debug(loggingLevel.FINE, '____ [cls OneId_AccountSearch - searchAccounts] fieldsToQuery - ' + fieldsToQuery);
		System.debug(loggingLevel.FINE, '____ [cls OneId_AccountSearch - searchAccounts] fieldsToSearch - ' + fieldsToSearch);
		System.debug(loggingLevel.FINE, '____ [cls OneId_AccountSearch - searchAccounts] filters - ' + filters);

		Set<String> recordTypesSet = ISSP_Constant.accountRecordTypeByUserType.get(customerType);
		if(customerType == 'Agency')
			recordTypesSet.addAll(ISSP_Constant.accountRecordTypeByUserType.get('NonIATAAgent'));

		String fieldString = 'SELECT Id, '+String.join(fieldsToQuery, ', ');
        String limitString = ' LIMIT 20';

		String objectString = ' FROM Account WHERE RecordType.DeveloperName in :recordTypesSet';

		if(filters != null){
			for(String key : filters.keySet()){
				objectString += ' AND '+key+ ' = \''+filters.get(key)+'\'';
			}
		}

		Set<String> nonGeneralTypes = new Set<String>{'Airline', 'Agency', 'OtherCompany',AMS_Utils.customerTypePass};
		if(nonGeneralTypes.contains(customerType))
			objectString += ' AND Sector__c != \'General Public\'';
		
		List<String> filterString = new List<String>();
		for(String field : fieldsToSearch){
			filterString.add(field+ ' LIKE  \'%' + search + '%\'');
		}
		if(!filterString.isEmpty())
			objectString += ' AND ('+String.join(filterString, ' OR ')+')';
		
		System.debug(loggingLevel.FINE, '____ [cls OneId_AccountSearch - searchAccounts] recordTypesSet - ' + recordTypesSet);
		System.debug(loggingLevel.FINE, '____ [cls OneId_AccountSearch - searchAccounts] query - ' + fieldString+objectString);
		sw.accList = Database.query(fieldString+objectString+limitString);
		System.debug(loggingLevel.FINE, '____ [cls OneId_AccountSearch - searchAccounts] results - ' + sw.accList);

		System.debug(loggingLevel.FINE, '____ [cls OneId_AccountSearch - searchAccounts] query - ' + 'SELECT count()'+objectString);
		sw.totalResults = Database.countQuery('SELECT count()'+objectString);
		System.debug(loggingLevel.FINE, '____ [cls OneId_AccountSearch - searchAccounts] result - ' + sw.totalResults);

		//Start Mehdi:
		// add a new search in case the first search with filter country returns null. The second search will return for airline headquarter from any country.
		if(sw.accList.isEmpty() && customerType =='Airline'){
			String objectString_HQ = ' FROM Account WHERE RecordType.DeveloperName = \'IATA_Airline\' AND Sector__c != \'General Public\'';

			List<String> filterString_HQ = new List<String>();

			for(String field : fieldsToSearch){
				filterString_HQ.add(field+ ' LIKE  \'%' + search + '%\'');
			}

			if(!filterString_HQ.isEmpty())	objectString_HQ += ' AND ('+String.join(filterString_HQ, ' OR ')+')';

			System.debug(loggingLevel.FINE, '____ [cls OneId_AccountSearch - searchAccounts] query - ' + fieldString+objectString_HQ);
			sw.accList = Database.query(fieldString+objectString_HQ+limitString);
			System.debug(loggingLevel.FINE, '____ [cls OneId_AccountSearch - searchAccounts] results - ' + sw.accList);
			System.debug(loggingLevel.FINE, '____ [cls OneId_AccountSearch - searchAccounts] query - ' + 'SELECT count()'+objectString_HQ);
			sw.totalResults = Database.countQuery('SELECT count()'+objectString_HQ);
			System.debug(loggingLevel.FINE, '____ [cls OneId_AccountSearch - searchAccounts] result - ' + sw.totalResults);
		}
		//End Mehdi

		return sw;
	}
}