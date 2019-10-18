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
        if(category != null && !string.isEmpty(category)){
            query += ' AND Contact.Account.Category__c = \'' + string.escapeSingleQuotes(category) + '\'' ;
        }
        if(sector != null && !string.isEmpty(sector)){
            query += ' AND Contact.Account.Sector__c = \'' + string.escapeSingleQuotes(sector) + '\'' ;
        }
        if(country != null && !string.isEmpty(country)){
            query += ' AND Contact.Account.IATA_ISO_Country__r.Name = \'' + string.escapeSingleQuotes(country) + '\'' ;
        }
        if(preferredLanguage != null && !string.isEmpty(preferredLanguage)){
            query += ' AND Contact.Preferred_Language__c = \'' + string.escapeSingleQuotes(preferredLanguage) + '\'' ;
        }
        query += ' LIMIT ' + ITEMS_PER_PAGE + ' OFFSET ' + ITEMS_PER_PAGE * (page-1);
        System.debug('VALINHO QUERY');
        System.debug(query);
        List<User> result = Database.query(query);
        return result;
    }

    @AuraEnabled(cacheable=true)
    public static Integer getTotalGeneralPublicUsersByCategoryAndSector(String category, String sector, String country, String preferredLanguage){
        String query = 'SELECT COUNT() FROM User WHERE ContactId != null AND Contact.Account.Is_General_Public_Account__c = true ';
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
        return Database.countQuery(query);
    }

    @AuraEnabled(cacheable=true) 
    public static List<User> getAllGeneralPublicUsersIds(){
        return [SELECT Id, ContactId FROM User WHERE ContactId != null AND Contact.Account.Is_General_Public_Account__c = true];
    }
}