public without sharing class OneId_AccountSearch {
	public class SearchWrapper {
	    @AuraEnabled public List<Account> accList {get; set;}
	    @AuraEnabled public Integer totalResults {get; set;}
	}

	@AuraEnabled
	public static SearchWrapper searchAccounts(String search, String customerType, List<String> fieldsToQuery, List<String> fieldsToSearch, Map<String, String> filters){
		SearchWrapper sw = new SearchWrapper();

		System.debug(loggingLevel.FINE, '____ [cls OneId_AccountSearch - searchAccounts] search - ' + search);
		System.debug(loggingLevel.FINE, '____ [cls OneId_AccountSearch - searchAccounts] customerType - ' + customerType);
		System.debug(loggingLevel.FINE, '____ [cls OneId_AccountSearch - searchAccounts] fieldsToQuery - ' + fieldsToQuery);
		System.debug(loggingLevel.FINE, '____ [cls OneId_AccountSearch - searchAccounts] fieldsToSearch - ' + fieldsToSearch);
		System.debug(loggingLevel.FINE, '____ [cls OneId_AccountSearch - searchAccounts] filters - ' + filters);

		Set<String> recordTypesSet = ISSP_Constant.accountRecordTypeByUserType.get(customerType);
		if(customerType == 'Airline') recordTypesSet.addAll(ISSP_Constant.accountRecordTypeByUserType.get('NonIATAAgent'));

		String fieldString = 'SELECT Id, '+String.join(fieldsToQuery, ', ');

		String objectString = ' FROM Account WHERE RecordType.DeveloperName in :recordTypesSet';

		if(filters != null){
			for(String key : filters.keySet()){
				objectString += ' AND '+key+ ' = \''+filters.get(key)+'\'';
			}
		}

		Set<String> nonGeneralTypes = new Set<String>{'Airline', 'Agency', 'OtherCompany'};
		if(nonGeneralTypes.contains(customerType)) objectString += ' AND Sector__c != \'General Public\'';
		
		List<String> filterString = new List<String>();
		for(String field : fieldsToSearch){
			filterString.add(field+ ' LIKE  \'%' + search + '%\'');
		}
		if(!filterString.isEmpty()) objectString += ' AND ('+String.join(filterString, ' OR ')+')';
		
		System.debug(loggingLevel.FINE, '____ [cls OneId_AccountSearch - searchAccounts] recordTypesSet - ' + recordTypesSet);
		System.debug(loggingLevel.FINE, '____ [cls OneId_AccountSearch - searchAccounts] query - ' + fieldString+objectString);
		sw.accList = Database.query(fieldString+objectString);
		System.debug(loggingLevel.FINE, '____ [cls OneId_AccountSearch - searchAccounts] results - ' + sw.accList);

		System.debug(loggingLevel.FINE, '____ [cls OneId_AccountSearch - searchAccounts] query - ' + 'SELECT count()'+objectString);
		sw.totalResults = Database.countQuery('SELECT count()'+objectString);
		System.debug(loggingLevel.FINE, '____ [cls OneId_AccountSearch - searchAccounts] result - ' + sw.totalResults);
		return sw;
	}
}