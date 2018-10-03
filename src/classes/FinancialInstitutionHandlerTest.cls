@isTest
public with sharing class FinancialInstitutionHandlerTest {

    static testMethod void testupdateChildFinancialSecurities() {
        Account account = new Account(
            Name='test Account',
            RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IATA_Agency').getRecordTypeId(),
            Location_Type__c='HO');
        insert account;
        
        Case cse = new Case();
        insert cse;
        
        Financial_Institution__c institution = new Financial_Institution__c(
            Related_IATA_agent_account__c = account.Id,
            First_Call_Letter_Required__c = 'No'
        );
        insert institution;
        
        Integer numElements = 2001;
        ANG_FinancialSecurityTriggerHandler.BLOCK_TRIGGER_EXECUTION = true;
        list<Financial_Security__c> listSecurities = new list<Financial_Security__c>();
        for (Integer i=0; i<numElements;i++) {
            listSecurities.add(new Financial_Security__c(
                Financial_Institution__c = institution.Id,
                Account__c = account.Id,
                Region__c = 'Europe',
                Reception_Date__c = Date.today(),
                Reasonforrequest__c = 'New Application',
                Reception_Case__c = cse.Id,
                Expiry_Date__c = Date.today().addMonths(3),
                Security_Type__c = 'Bank Guarantee'
            ));
            if (listSecurities.size()==200) {
                insert listSecurities;
                listSecurities = new list<Financial_Security__c>();
            }
        }
        insert listSecurities;
        ANG_FinancialSecurityTriggerHandler.BLOCK_TRIGGER_EXECUTION = false;
        
        Test.startTest();
        institution.First_Call_Letter_Required__c = 'Yes';
        update institution;
        Test.stopTest();
        
        list<Financial_Security__c> result = [
            SELECT Id 
            FROM Financial_Security__c 
            WHERE Financial_Institution__c=:institution.Id
            AND First_Call_Letter_required1__c = 'Yes'];
        System.assert(result.size()==numElements);
    }
}