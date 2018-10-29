public with sharing class FinancialInstitutionHandler {

    public static list<Id> LIST_UPDATED_FINANCIALINSTITUTIONS;

    public static void doBeforeUpdate(map<Id,Financial_Institution__c> mapNews, map<Id,Financial_Institution__c> mapOlds) {
        findChangesInFirstCallLetterRequired(mapNews,mapOlds);
    }
    
    public static void doAfterUpdate(list<Financial_Institution__c> listNews) {
        updateChildFinancialSecurities();
    }
    
    /**
        find F. Institutions with changes in field First_Call_Letter_Required__c
    **/
    public static void findChangesInFirstCallLetterRequired(map<Id,Financial_Institution__c> mapNews, map<Id,Financial_Institution__c> mapOlds) {
        LIST_UPDATED_FINANCIALINSTITUTIONS = new list<Id>();
        for (Financial_Institution__c newInstitution: mapNews.values()) {
            Financial_Institution__c oldInstitution = mapOlds.get(newInstitution.Id);
            if (newInstitution.First_Call_Letter_Required__c != oldInstitution.First_Call_Letter_Required__c) {
                LIST_UPDATED_FINANCIALINSTITUTIONS.add(newInstitution.Id);
            }
        }
    }
    
    /**
        Use previously seached Institutions to update their security records
    **/
    public static void updateChildFinancialSecurities() {
        list<Financial_Institution__c> listInstitution = [
            SELECT Id, First_Call_Letter_Required__c,
                (SELECT Id, First_Call_Letter_required1__c
                FROM Financial_Securities__r)
            FROM Financial_Institution__c
            WHERE Id IN :LIST_UPDATED_FINANCIALINSTITUTIONS
        ];
        list<Financial_Security__c> listUpdateSecurities = new list<Financial_Security__c>();
        for (Financial_Institution__c institution: listInstitution) {
            for (Financial_Security__c security: institution.Financial_Securities__r) {
                security.First_Call_Letter_required1__c = institution.First_Call_Letter_Required__c;
                listUpdateSecurities.add(security);
            }
        }
        if (!listUpdateSecurities.isEmpty()) {
            BatchUpdate.run(listUpdateSecurities,20);
        }
    }
}