/*
 * @author: Constantin BUZDUGA, blue-infinity
 * @description: This is a test class for the clsICCSPMCaseCloseController APEX class.
 *      
 */

@isTest
private class clsICCSPMCaseCloseControllerTest {
    static testMethod void test() {
        // Create a new ISO Country
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(Name = 'France', ISO_Code__c = 'FR');
        insert country;
        
        // Create a new Product
        Product2 p = new Product2(Name = 'BSP', Family = 'ICCS');
        insert p;
        
        // Create a new ICCS Product Country for this product
        ICCS_Product_Country__c pct = new ICCS_Product_Country__c(Product__c = p.Id, Country__c = country.Id);
        insert pct;
        
        // Create a new ICCS Product Currency for this ICCS Product Country
        ICCS_Product_Currency__c pcr = new ICCS_Product_Currency__c(CurrencyIsoCode = 'USD', ICCS_Product_Country__c = pct.Id, ICCS_Code__c = 'BSPFR1', Status__c = 'Active');
        insert pcr;
        
        // Create an Airline HQ account & a contact for it
        //RecordType RT_AirlineHQ = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'IATA_Airline'];
        Id AirlineHQ_RT_Id = Schema.SObjectType.Account.RecordTypeInfosByName.get('Airline Headquarters').RecordTypeId ;
        Account a = new Account(Name = 'Qatar Airways', Airline_designator__c = 'QR', ICCS_Membership_Status__c = 'Member', RecordTypeId = AirlineHQ_RT_Id);
        insert a;
        
        //RecordType RT_ContactStd = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'Standard_Contact'];
        Id ContactStd_RT_Id = Schema.SObjectType.Contact.RecordTypeInfosByName.get('Standard').RecordTypeId ;
        Contact c = new Contact(FirstName = 'Test', LastName = 'Contact', email = 'test@test.com', AccountId = a.Id, RecordTypeId = ContactStd_RT_Id, Contact_on_Close_Case__c = true);
        insert c;
        
        // Create a new ICCS Bank Account for the airline
        ICCS_Bank_Account__c ba = new ICCS_Bank_Account__c(Name = 'QR1234', Account__c = a.Id, CurrencyIsoCode = 'USD', Status__c = 'Active', Description__c = 'asd');
        insert ba;
        
        // Create ICCS Cases for the Account
        Id ICCS_RT_Id = Schema.SObjectType.Case.RecordTypeInfosByName.get('FDS ICCS Product Management').RecordTypeId ;
        Case cs = new Case(RecordTypeId = ICCS_RT_Id, Subject = 'test', Origin = 'Email', CaseArea__c = 'ICCS – Assign Product', Status = 'Open',
                        ContactId = c.Id, AccountId = a.Id, ICCS_Product__c = 'BSP', ICCS_Country__c = 'France', ICCS_Currencies__c = 'USD',
                        ICCS_Bank_Account__c = ba.Id);  
        insert cs;
        
        Case cs2 = new Case(RecordTypeId = ICCS_RT_Id, Subject = 'test', Origin = 'Email', CaseArea__c = 'ICCS – Remove Product', Status = 'Open',
                        ContactId = c.Id, AccountId = a.Id, ICCS_Product__c = 'BSP', ICCS_Country__c = 'Italy', ICCS_Currencies__c = 'USD',
                        ICCS_Bank_Account__c = ba.Id);  
        //insert cs2;
        
        
        //////////////////////////
        test.startTest();
        
        // 1st case
        ApexPages.StandardController std = new ApexPages.StandardController(cs);
        clsICCSPMCaseCloseController ctrl = new clsICCSPMCaseCloseController(std);
        
        try {
            // won't work, emtpy fields
            ctrl.SaveCase();
        } catch (Exception e) {}
        
        ctrl.status = 'Closed';
        ctrl.strCaseComments = 'abc';
        PageReference pRef = ctrl.SaveCase();
        
        // 2nd case 
        insert cs2;
        
        std = new ApexPages.StandardController(cs2);
        ctrl = new clsICCSPMCaseCloseController(std);
        
        ctrl.status = 'Closed';
        ctrl.strCaseComments = 'abc';
        pRef = ctrl.SaveCase();
        
        test.stopTest();
        //////////////////////////
    }
}