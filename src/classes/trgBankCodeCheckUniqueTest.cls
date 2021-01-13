/*
 *  @author: Constantin BUZDUGA, blue-infinity
 *  @description: This is a test class for the trgBankCodeCheckUnique trigger on the ICCS Bank Account object.
 *
 */

@isTest
private class trgBankCodeCheckUniqueTest {
    @isTest
    static void test() {
        // Create a new ISO Country
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(Name = 'France', ISO_Code__c = 'FR');
        insert country;
        
        // Create a new Airline HQ account
        Id hqRTId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        Account a = new Account(Name='Test Airline HQ', RecordTypeId = hqRTId, IATA_ISO_Country__c = country.Id,
                        Airline_designator__c = 'AF');
        insert a;
        
        // Create a new ICCS Bank Account for the test account
        ICCS_Bank_Account__c ba = new ICCS_Bank_Account__c(Name = 'AF1234', Account__c = a.Id);
        insert ba;
        
        List<ICCS_Bank_Account__c> lstBankAccounts = [SELECT Id FROM ICCS_Bank_Account__c];
        System.AssertEquals(1,lstBankAccounts.size());
        
        // Create a new ICCS Bank Account for the test account with the same code as above, to test that its insertion is blocked
        try {
            ba = new ICCS_Bank_Account__c(Name = 'AF1234', Account__c = a.Id);
            insert ba;
        } catch(Exception e) {}
        
        lstBankAccounts = [SELECT Id FROM ICCS_Bank_Account__c];
        System.AssertEquals(1,lstBankAccounts.size()); // Check that the bank account was not inserted
        
        
    }
}