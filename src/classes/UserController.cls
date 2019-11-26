public with sharing class UserController {

	@TestVisible
	static final Integer ITEMS_PER_PAGE = 50;

	@AuraEnabled(cacheable=true)
	public static Integer getItemsPerPage(){
		return ITEMS_PER_PAGE;
	}

	@AuraEnabled(cacheable=true)
	public static List<User> getGeneralPublicUsersByCategoryAndSector(String category, String sector, String country, String preferredLanguage, Integer page){

		if(page == null || page < 1){
			page = 1;
		}
		String query = 'SELECT Id, Name, ContactId, Contact.Name, Contact.Last_registration_notification_date__c, Contact.Preferred_Language__c, Contact.AccountId, Contact.Account.IATA_ISO_Country__r.Name, Contact.Account.Sector__c, Contact.Account.Category__c FROM User WHERE ContactId != null AND Contact.Account.Is_General_Public_Account__c = true ';
		query = generalublicQueryBuilder(query, category, sector, country, preferredLanguage);
		query += ' LIMIT ' + ITEMS_PER_PAGE + ' OFFSET ' + ITEMS_PER_PAGE * (page-1);
		List<User> result = Database.query(query);
		return result;
	}

	@AuraEnabled(cacheable=true)
	public static Integer getTotalGeneralPublicUsersByCategoryAndSector(String category, String sector, String country, String preferredLanguage){
		String query = 'SELECT COUNT() FROM User WHERE ContactId != null AND Contact.Account.Is_General_Public_Account__c = true ';
		query = generalublicQueryBuilder(query, category, sector, country, preferredLanguage);
		return Database.countQuery(query);
	}

	 private static String generalublicQueryBuilder(String query, String category, String sector, String country, String preferredLanguage){
		if(category != null && !string.isEmpty(category)){
			query += ' AND Contact.Account.Category__c = \'' + string.escapeSingleQuotes(category) + '\'' ;
		}
		if(sector != null && !string.isEmpty(sector)){
			query += ' AND Contact.Account.Sector__c = \'' + string.escapeSingleQuotes(sector) + '\'';
		}
		if(country != null && !string.isEmpty(country)){
			query += ' AND Contact.Account.IATA_ISO_Country__r.Name = \'' + string.escapeSingleQuotes(country) + '\'' ;
		}
		if(preferredLanguage != null && !string.isEmpty(preferredLanguage)){
			query += ' AND Contact.Preferred_Language__c = \'' + string.escapeSingleQuotes(preferredLanguage) + '\'' ;
		}
		return query;
	}

	@AuraEnabled(cacheable=true)
	public static List<User> getAllGeneralPublicUsersIds(){
		return [SELECT Id, ContactId FROM User WHERE ContactId != null AND Contact.Account.Is_General_Public_Account__c = true];
	}

	@AuraEnabled(cacheable=true)
	public static List<User> getAllCspCommunityUsers(String category, String sector, List<String> countries, String portalService , Integer page){

		if(page == null || page < 1){
			page = 1;
		}
		Integer offset = 0;

		String query = 'SELECT Id, Name, ContactId, Contact.Name, Contact.Preferred_Language__c, Contact.AccountId, Contact.Account.IATA_ISO_Country__r.Name, Contact.Account.Sector__c, Contact.Account.Category__c FROM User WHERE ContactId != null AND Id in (SELECT MemberId from NetworkMember where NetworkId = \'' + getNetworkId() + '\') ';
		query = communityQueryBuilder(query, category, sector,countries, portalService);
		query += ' LIMIT ' + ITEMS_PER_PAGE + ' OFFSET ' + ITEMS_PER_PAGE * (page-1);
		List<User> result = Database.query(query);
		return result;
	}

	@AuraEnabled(cacheable=true)
	public static Integer countCspCommunityUsers(String category, String sector, List<String> countries, String portalService){
		String query = 'SELECT COUNT() FROM User WHERE ContactId != null AND Id IN (SELECT MemberId from NetworkMember where NetworkId = \'' + getNetworkId() + '\') ';
		query = communityQueryBuilder(query, category, sector,countries, portalService);
		return Database.countQuery(query);
	}

	@AuraEnabled(cacheable=true)
	public static List<User> getFilteredCspCommunityIds(String category, String sector, List<String> countries, String portalService){
		String query = 'SELECT Id, Name, ContactId, Contact.Name, Contact.Preferred_Language__c, Contact.AccountId, Contact.Account.IATA_ISO_Country__r.Name, Contact.Account.Sector__c, Contact.Account.Category__c FROM User WHERE ContactId != null AND Id in (SELECT MemberId from NetworkMember where NetworkId = \'' + getNetworkId() + '\') ';
		query = communityQueryBuilder(query, category, sector,countries, portalService);
		return Database.query(query);
	}

	private static String communityQueryBuilder(String query, String category, String sector, List<String> countries, String portalService){
		 if(category != null && !string.isEmpty(category)){
			query += ' AND Contact.Account.Category__c = \'' + string.escapeSingleQuotes(category) + '\'' ;
		}
		if(sector != null && !string.isEmpty(sector)){
			query += ' AND Contact.Account.Sector__c = \'' + string.escapeSingleQuotes(sector) + '\'';
		}
		if(countries != null && countries.size() > 0 ){
			query += ' AND Contact.Account.IATA_ISO_Country__r.Name IN (\'' + String.join(countries, '\',\'') + '\')' ;
		}
		if(portalService != null && !string.isEmpty(portalService)){
			query += ' AND ContactId IN (SELECT Contact__c From  Portal_Application_Right__c WHERE Portal_Application__r.Name = \'' + portalService + '\' AND Right__c = \'Access Granted\') ';
		}
		return query;
	}

	static private Id getNetworkId(){
		return [SELECT Id FROM Network WHERE Name = 'CS Portal'].Id;
	}
}