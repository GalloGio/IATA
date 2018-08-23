/*
 *  @author: Constantin BUZDUGA, blue-infinity
 *  @description: This is a test class for the cslICCSPdfPAGeneratorController APEX class.
 *
 */

@isTest
private class cslICCSPdfPAGeneratorControllerTest {
    static testMethod void test() {
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
        // create an email template
            EmailTemplate et = new EmailTemplate(DeveloperName = 'ICCS_Notification', Name = 'ICCS_Notification', HtmlValue = '<html></html>', Subject = 'test template',
                            FolderId = thisUser.Id, TemplateType = 'text');
            insert et;
        }
        
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
        Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;
        Account a = new Account(Name = 'Qatar Airways', Airline_designator__c = 'QR', ICCS_Membership_Status__c = 'Member', RecordTypeId = AirlineHQ_RT_Id);
        insert a;
        
        Id ContactStd_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        Contact c = new Contact(FirstName = 'Test', LastName = 'Contact', email = 'test@test.com', AccountId = a.Id, RecordTypeId = ContactStd_RT_Id, Contact_on_Close_Case__c = true);
        insert c;
        
        // Create a new ICCS Bank Account for the airline
        ICCS_Bank_Account__c ba = new ICCS_Bank_Account__c(Name = 'QR1234', Account__c = a.Id, CurrencyIsoCode = 'USD', Status__c = 'Active', Description__c = 'asd');
        insert ba;
        
        // Create an ICCS Case for the Account
        Id ICCS_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'FDS_ICCS_Product_Management') ;
        Case cs = new Case(RecordTypeId = ICCS_RT_Id, Subject = 'test', Origin = 'Email', CaseArea__c = 'ICCS – Assign Product', Status = 'Open',
                        ContactId = c.Id, AccountId = a.Id, ICCS_Product__c = 'BSP', ICCS_Country__c = 'France', ICCS_Currencies__c = 'USD');  
        insert cs;
        
        ICCS_BankAccount_To_Case__c batc = new ICCS_BankAccount_To_Case__c(ICCS_Bank_Account__c=ba.id,Case__c=cs.id,Split_Type__c='Total');
        insert batc;
        
        // Update the case status to Closed
        cs.Status = 'Closed';
        update cs;
        
        test.startTest();
        
        // ICCS case
        ApexPages.StandardController std = new ApexPages.StandardController(a);
        cslICCSPdfPAGeneratorController ctrl = new cslICCSPdfPAGeneratorController(std);
        
        ctrl.sendPDF('ICCS_Notification', c.Id, cs.Id);
        
        String iataLogo = ctrl.IATALogoURL;
        String iccsLogo = ctrl.ICCSLogoURL;
        
        test.stopTest();
        
    }
}