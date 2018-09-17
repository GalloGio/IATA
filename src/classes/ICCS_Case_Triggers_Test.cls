/*
 *  @author: Constantin BUZDUGA, blue-infinity
 *  @description: This is a test class for the trgICCSCaseValidation, trgICCSManageProductAssignment, trgPreventProdCurrencyInactivation
 *      and trgPreventBankAccountInactivation triggers on the Case object. Testing done in a single class because most of the required code was common. 
 *
 */

@isTest
private class ICCS_Case_Triggers_Test {
    
    static final String PER = 'Percentage';
    static final String AM  = 'Amount';
    static final String TOT = 'Total';
    static final String BAL = 'Balance';
    
    
    static testMethod void test0() {
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
        //Id AirlineHQ_RT_Id = Schema.SObjectType.Account.RecordTypeInfosByName.get('Airline Headquarters').RecordTypeId ;
        Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('IATA_Airline');
        Account a = new Account(Name = 'Qatar Airways', Airline_designator__c = 'QR', ICCS_Membership_Status__c = 'Member', RecordTypeId = AirlineHQ_RT_Id);
        insert a;
        
        //RecordType RT_ContactStd = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'Standard_Contact'];
        //Id ContactStd_RT_Id = Schema.SObjectType.Contact.RecordTypeInfosByName.get('Standard').RecordTypeId ;
        Id ContactStd_RT_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Contact').get('Standard_Contact');
        Contact c = new Contact(FirstName = 'Test', LastName = 'Contact', email = 'test@test.com', AccountId = a.Id, RecordTypeId = ContactStd_RT_Id);
        insert c;
        
        // Create a new ICCS Bank Account for the airline
        List<ICCS_Bank_Account__c> ba = new List<ICCS_Bank_Account__c>(); 
        ba.add( new ICCS_Bank_Account__c(Name = 'QR1111', Account__c = a.Id, CurrencyIsoCode = 'USD', Status__c = 'Active', Description__c = 'asd'));
        ba.add( new ICCS_Bank_Account__c(Name = 'QR2222', Account__c = a.Id, CurrencyIsoCode = 'USD', Status__c = 'Active', Description__c = 'asd'));
        ba.add( new ICCS_Bank_Account__c(Name = 'QR3333', Account__c = a.Id, CurrencyIsoCode = 'USD', Status__c = 'Active', Description__c = 'asd'));
        ba.add( new ICCS_Bank_Account__c(Name = 'QR4444', Account__c = a.Id, CurrencyIsoCode = 'USD', Status__c = 'Active', Description__c = 'asd'));
        ba.add( new ICCS_Bank_Account__c(Name = 'QR5555', Account__c = a.Id, CurrencyIsoCode = 'USD', Status__c = 'Active', Description__c = 'asd'));
        insert ba;
        
        //////////////////////////
        test.startTest();
        
        // Create a Case for the Account
        //RecordType RT_ICCS = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND DeveloperName = 'IDFS_ICCS_Process'];
        //Id ICCS_RT_Id = Schema.SObjectType.Case.RecordTypeInfosByName.get('FDS ICCS Product Management').RecordTypeId ;
        Id ICCS_RT_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('FDS_ICCS_Product_Management');
        Case cs = new Case(RecordTypeId = ICCS_RT_Id, Subject = 'test', Origin = 'Email', CaseArea__c = 'ICCS – Assign Product', Status = 'Open',
                        ContactId = c.Id, AccountId = a.Id, ICCS_Product__c = 'BSP', ICCS_Country__c = 'France', ICCS_Currencies__c = 'USD');  
        insert cs;
        
        List<Case> lstCases = [SELECT Id FROM Case];
        System.AssertEquals(1,lstCases.size());
        
        // Create another Case which should raise an error and not get inserted, because the product combination is invalid
        try {
            Case cs2 = new Case(RecordTypeId = ICCS_RT_Id, Subject = 'test', Origin = 'Email', CaseArea__c = 'ICCS – Assign Product', Status = 'Open',
                        ContactId = c.Id, AccountId = a.Id, ICCS_Product__c = 'BSP', ICCS_Country__c = 'Germany', ICCS_Currencies__c = 'USD');
                        system.debug('###############  AAAAAAAAAAAAATTTTENZIONEEEEEEEEEEEEEEEEEEEEEEE= ');
            insert cs2;
        } catch(Exception e) {}
        system.debug('###############  STAMPO I PRODUCT CURRENCY');
        for(ICCS_Product_Currency__c pc : [SELECT Id, Currency__c, Country__c, Product__c FROM ICCS_Product_Currency__c WHERE Status__c = 'Active' ])
            system.debug('############### product currency trovato: '+pc.Product__c + '-' + pc.Country__c + '-' + pc.Currency__c);
        
        lstCases = [SELECT Id FROM Case WHERE RecordTypeId = :ICCS_RT_Id];
        System.AssertEquals(1,lstCases.size()); // Check that the case was not inserted
        
        //  Update the case and set the status to "Submitted"
        cs.Status = 'Submitted';
        
        //need to have a bank account when case status changes to Submitted
        ICCS_BankAccount_To_Case__c batc = new ICCS_BankAccount_To_Case__c(Case__c=cs.id, ICCS_Bank_Account__c=ba[0].id, Split_Type__c=TOT);
        boolean exceptionRaised = false;
        try{insert batc;}catch(Exception e){exceptionRaised = true;}
        system.assertEquals(false,exceptionRaised);
        
        update cs;
        
        
        // try to update the subject, test that it didn't change
        try {
            cs.subject = 'new subj';
            update cs;
        } catch(Exception e) {}
        cs = [SELECT Id, Subject, Status FROM Case WHERE Id = :cs.Id];
        system.assertEquals('test', cs.Subject);
        
        // When closing the case it should return error because no ICCS_BankAccount_To_Case is bounded to the case.
        //first delete the previously added bank account
        //Update the case and set the status to "In Progress" in order to remove the BA
        cs.Status = 'In Progress';
        update cs;
        delete batc;
        
        exceptionRaised = false;
        cs.Status = 'Closed';
        try{
            update cs;
        }catch(Exception e){
            exceptionRaised = true;
        }
        system.assertEquals(true,exceptionRaised);
        
        // Test ICCS_BankAccount_To_Case validations
        // bad data: total instruction has both percentage and amount
        batc = new ICCS_BankAccount_To_Case__c(Case__c=cs.id, ICCS_Bank_Account__c=ba[0].id, Split_Type__c=TOT, Percentage__c=10, Amount__c=10000);
        exceptionRaised = false;
        try{insert batc;}catch(Exception e){exceptionRaised = true;}
        system.assertEquals(true,exceptionRaised);
        
        // insert a total instruction 
        batc = new ICCS_BankAccount_To_Case__c(Case__c=cs.id, ICCS_Bank_Account__c=ba[0].id, Split_Type__c=TOT);
        exceptionRaised = false;
        try{insert batc;}catch(Exception e){exceptionRaised = true;}
        system.assertEquals(false,exceptionRaised);
        
        // bad data: other instructions not allowed if there is a total
        ICCS_BankAccount_To_Case__c batc2 = new ICCS_BankAccount_To_Case__c(Case__c=cs.id, ICCS_Bank_Account__c=ba[0].id, Split_Type__c=PER, Percentage__c=50);
        exceptionRaised = false;
        try{insert batc2;}catch(Exception e){exceptionRaised = true;}
        system.assertEquals(true,exceptionRaised);
        
        // change total to percentage
        batc.Split_type__c = AM;
        batc.Amount__c = 4000;
        batc.Percentage__c = null; 
        update batc;
        batc2.ICCS_Bank_Account__c = ba[1].id;
        insert batc2;
        ICCS_BankAccount_To_Case__c batc3 = new ICCS_BankAccount_To_Case__c(Case__c=cs.id, ICCS_Bank_Account__c=ba[2].id, Split_Type__c=BAL);   
        insert batc3;

        // bad data: it's not possible to add two Balance
        ICCS_BankAccount_To_Case__c batcerr = new ICCS_BankAccount_To_Case__c(Case__c=cs.id, ICCS_Bank_Account__c=ba[0].id, Split_Type__c=BAL);
        exceptionRaised = false;
        try{insert batcerr;}catch(Exception e){exceptionRaised = true;}
        system.assertEquals(true,exceptionRaised);
        
        // bad data: percentage must be < 100
        batcerr = new ICCS_BankAccount_To_Case__c(Case__c=cs.id, ICCS_Bank_Account__c=ba[0].id, Split_Type__c=PER, Percentage__c = 110);
        exceptionRaised = false;
        try{insert batcerr;}catch(Exception e){exceptionRaised = true;}
        system.assertEquals(true,exceptionRaised);
        
        
        /*
        // Update the case status to Closed, test that it did change and test that the Product Assignment record was created
        update cs;
        cs = [SELECT Id, Subject, Status, isClosed FROM Case WHERE Id = :cs.Id];
        system.assertEquals('Closed', cs.Status);
        system.assertEquals(true, cs.isClosed);
        
        List<Product_Assignment__c> lstPAs = [SELECT Id, Status__c FROM Product_Assignment__c];
        system.assertEquals(3, lstPAs.size());
        system.assertEquals('Active', lstPAs[0].Status__c);
        
        // Try to create an assignment case with the same product combination and test that it is not inserted
        try {
            Case cs2 = new Case(RecordTypeId = ICCS_RT_Id, Subject = 'test', Origin = 'Email', CaseArea__c = 'ICCS – Assign Product', Status = 'Open',
                        ContactId = c.Id, AccountId = a.Id, ICCS_Product__c = 'BSP', ICCS_Country__c = 'France', ICCS_Currencies__c = 'USD');
            insert cs2;
        } catch(Exception e) {}
        
        
        lstCases = [SELECT Id FROM Case WHERE RecordTypeId = :ICCS_RT_Id];
        System.AssertEquals(1,lstCases.size()); // Check that the case was not inserted
        
        // Try to inactivate the bank account linked to the PA record
        try {
            ba[0].Status__c = 'Inactive';
            update ba;
        }  catch(Exception e) {}
        

        system.assertEquals(0, [SELECT Id, Status__c FROM ICCS_Bank_account__c WHERE Status__c = 'Inactive'].size()); // check that the status didn't change
        
        // Try to inactivate the ICCS Product Currency linked to the PA record
        try {
            pcr.Status__c = 'Inactive';
            update pcr;
        }  catch(Exception e) {}
        
        pcr = [SELECT Id, Status__c FROM ICCS_Product_Currency__c WHERE Id = :pcr.Id];
        system.assertEquals('Active', pcr.Status__c); // check that the status didn't change
        
        
        
        // Create a product update case, close it and check the product assignments have been changed        
        Case cs4 = new Case(RecordTypeId = ICCS_RT_Id, Subject = 'test', Origin = 'Email', CaseArea__c = 'ICCS – Update Payment Instructions', Status = 'Open',
                        ContactId = c.Id, AccountId = a.Id, ICCS_Product__c = 'BSP', ICCS_Country__c = 'France', ICCS_Currencies__c = 'USD');
        insert cs4;
        
        List<ICCS_BankAccount_To_Case__c> batcs = new List<ICCS_BankAccount_To_Case__c>();
        batcs.add( new ICCS_BankAccount_To_Case__c(Case__c=cs4.id, ICCS_Bank_Account__c=ba[0].id, Split_Type__c=PER, Percentage__c=50));
        batcs.add( new ICCS_BankAccount_To_Case__c(Case__c=cs4.id, ICCS_Bank_Account__c=ba[4].id, Split_Type__c=PER, Percentage__c=30));
        
        
        exceptionRaised = false;
        try{insert batcs;}catch(Exception e){exceptionRaised = true;}
        system.assertEquals(false,exceptionRaised);
        
        cs4.Status = 'Closed';
        try{update cs4;}catch(Exception e){exceptionRaised = true;}
        system.assertEquals(true,exceptionRaised); 
        
        exceptionRaised = false;
        insert new ICCS_BankAccount_To_Case__c(Case__c=cs4.id, ICCS_Bank_Account__c=ba[3].id, Split_Type__c=BAL);       
        
        cs4.Status = 'Closed';
        update cs4;

        
        lstPAs = [SELECT Id, Status__c FROM Product_Assignment__c WHERE Status__c = 'Inactive'];
        system.assertEquals(2, lstPAs.size());
        lstPAs = [SELECT Id, Status__c FROM Product_Assignment__c];
        system.assertEquals(5, lstPAs.size());
        
        
        */
        // Create a product removal Case, close it and test that the Product Assignments have been inactivated
        /*Case cs3 = new Case(RecordTypeId = ICCS_RT_Id, Subject = 'test', Origin = 'Email', CaseArea__c = 'ICCS � Remove Product', Status = 'Open',
                        ContactId = c.Id, AccountId = a.Id, ICCS_Product__c = 'BSP', ICCS_Country__c = 'France', ICCS_Currencies__c = 'USD');
        insert cs3;
        
        cs3.Status = 'Closed';
        update cs3;
        
        lstPAs = [SELECT Id, Status__c FROM Product_Assignment__c WHERE Status__c = 'Inactive'];
        system.assertEquals(5, lstPAs.size());
        
        
        // Try to create a removal case with the same product combination and test that it is not inserted
        /*exceptionRaised = false;
        try {
            Case cs2 = new Case(RecordTypeId = ICCS_RT_Id, Subject = 'test', Origin = 'Email', CaseArea__c = 'ICCS � Remove Product', Status = 'Open',
                        ContactId = c.Id, AccountId = a.Id, ICCS_Product__c = 'BSP', ICCS_Country__c = 'France', ICCS_Currencies__c = 'USD');
            insert cs2;
        } catch(Exception e) {exceptionRaised = true;}
        
        system.assertEquals(true,exceptionRaised); 
        lstCases = [SELECT Id FROM Case WHERE RecordTypeId = :ICCS_RT_Id];
        System.AssertEquals(3,lstCases.size()); // Check that the case was not inserted; 3 cases present, cs1, cs3 and cs4
        */
        test.stopTest();
    }
    
    static testMethod void test1() {
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User testUser = New User(

            Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = testProfile.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test.username@test.com',
            License_Cost_Center__c = 'ISF005CH01'
        );
        insert testUser;
    
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
        //Id AirlineHQ_RT_Id = Schema.SObjectType.Account.RecordTypeInfosByName.get('Airline Headquarters').RecordTypeId ;
        Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('IATA_Airline');
        Account a = new Account(Name = 'Qatar Airways', Airline_designator__c = 'QR', ICCS_Membership_Status__c = 'Member', RecordTypeId = AirlineHQ_RT_Id);
        insert a;
        
        //RecordType RT_ContactStd = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'Standard_Contact'];
        //Id ContactStd_RT_Id = Schema.SObjectType.Contact.RecordTypeInfosByName.get('Standard').RecordTypeId ;
        Id ContactStd_RT_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Contact').get('Standard_Contact');
        Contact c = new Contact(FirstName = 'Test', LastName = 'Contact', email = 'test@test.com', AccountId = a.Id, RecordTypeId = ContactStd_RT_Id);
        insert c;
        
        // Create a new ICCS Bank Account for the airline
        List<ICCS_Bank_Account__c> ba = new List<ICCS_Bank_Account__c>(); 
        ba.add( new ICCS_Bank_Account__c(Name = 'QR1111', Account__c = a.Id, CurrencyIsoCode = 'USD', Status__c = 'Active', Description__c = 'asd'));
        ba.add( new ICCS_Bank_Account__c(Name = 'QR2222', Account__c = a.Id, CurrencyIsoCode = 'USD', Status__c = 'Active', Description__c = 'asd'));
        ba.add( new ICCS_Bank_Account__c(Name = 'QR3333', Account__c = a.Id, CurrencyIsoCode = 'USD', Status__c = 'Active', Description__c = 'asd'));
        ba.add( new ICCS_Bank_Account__c(Name = 'QR4444', Account__c = a.Id, CurrencyIsoCode = 'USD', Status__c = 'Active', Description__c = 'asd'));
        ba.add( new ICCS_Bank_Account__c(Name = 'QR5555', Account__c = a.Id, CurrencyIsoCode = 'USD', Status__c = 'Active', Description__c = 'asd'));
        insert ba;
        
        //////////////////////////
        test.startTest();
        
        // Create a Case for the Account
        //RecordType RT_ICCS = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND DeveloperName = 'IDFS_ICCS_Process'];
        //Id ICCS_RT_Id = Schema.SObjectType.Case.RecordTypeInfosByName.get('FDS ICCS Product Management').RecordTypeId ;
        Id ICCS_RT_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('FDS_ICCS_Product_Management');
        Case cs = new Case(RecordTypeId = ICCS_RT_Id, Subject = 'test', Origin = 'Email', CaseArea__c = 'ICCS – Assign Product', Status = 'Open',
                        ContactId = c.Id, AccountId = a.Id, ICCS_Product__c = 'BSP', ICCS_Country__c = 'France', ICCS_Currencies__c = 'USD');  
        insert cs;
        
        List<Case> lstCases = [SELECT Id FROM Case];
        System.AssertEquals(1,lstCases.size());
         
        //need to have a bank account when case status changes to Submitted
        ICCS_BankAccount_To_Case__c batc = new ICCS_BankAccount_To_Case__c(Case__c=cs.id, ICCS_Bank_Account__c=ba[0].id, Split_Type__c=TOT);
        insert batc;
        
        cs.ownerid = testUser.id;
        cs.Status = 'Closed';
        update cs;
        
        cs = [SELECT Id, Subject, Status, isClosed FROM Case WHERE Id = :cs.Id];
        system.assertEquals('Closed', cs.Status);
        system.assertEquals(true, cs.isClosed);
        
        List<Product_Assignment__c> lstPAs = [SELECT Id, Status__c FROM Product_Assignment__c];
        system.assertEquals(1, lstPAs.size());
        system.assertEquals('Active', lstPAs[0].Status__c);        
        
        // Try to create an assignment case with the same product combination and test that it is not inserted
        try {
            Case cs2 = new Case(RecordTypeId = ICCS_RT_Id, Subject = 'test', Origin = 'Email', CaseArea__c = 'ICCS – Assign Product', Status = 'Open',
                        ContactId = c.Id, AccountId = a.Id, ICCS_Product__c = 'BSP', ICCS_Country__c = 'France', ICCS_Currencies__c = 'USD');
            insert cs2;
        } catch(Exception e) {}
        
        
        lstCases = [SELECT Id FROM Case WHERE RecordTypeId = :ICCS_RT_Id];
        System.AssertEquals(1,lstCases.size()); // Check that the case was not inserted
        
        // Try to inactivate the bank account linked to the PA record
        try {
            ba[0].Status__c = 'Inactive';
            update ba;
        }  catch(Exception e) {}
        

        system.assertEquals(0, [SELECT Id, Status__c FROM ICCS_Bank_account__c WHERE Status__c = 'Inactive'].size()); // check that the status didn't change
        
        // Try to inactivate the ICCS Product Currency linked to the PA record
        try {
            pcr.Status__c = 'Inactive';
            update pcr;
        }  catch(Exception e) {}
        
        pcr = [SELECT Id, Status__c FROM ICCS_Product_Currency__c WHERE Id = :pcr.Id];
        system.assertEquals('Active', pcr.Status__c); // check that the status didn't change
        
        
        
        // Create a product update case, close it and check the product assignments have been changed        
        Case cs4 = new Case(RecordTypeId = ICCS_RT_Id, Subject = 'test', Origin = 'Email', CaseArea__c = 'ICCS – Update Payment Instructions', Status = 'Open',
                        ContactId = c.Id, AccountId = a.Id, ICCS_Product__c = 'BSP', ICCS_Country__c = 'France', ICCS_Currencies__c = 'USD');
        insert cs4;
        
        List<ICCS_BankAccount_To_Case__c> batcs = new List<ICCS_BankAccount_To_Case__c>();
        batcs.add( new ICCS_BankAccount_To_Case__c(Case__c=cs4.id, ICCS_Bank_Account__c=ba[0].id, Split_Type__c=PER, Percentage__c=50));
        batcs.add( new ICCS_BankAccount_To_Case__c(Case__c=cs4.id, ICCS_Bank_Account__c=ba[4].id, Split_Type__c=PER, Percentage__c=30));
        
        
        boolean exceptionRaised = false;
        try{insert batcs;}catch(Exception e){exceptionRaised = true;}
        system.assertEquals(false,exceptionRaised);
        
        cs4.Status = 'Closed';
        try{update cs4;}catch(Exception e){exceptionRaised = true;}
        system.assertEquals(true,exceptionRaised); 
        
        exceptionRaised = false;
        insert new ICCS_BankAccount_To_Case__c(Case__c=cs4.id, ICCS_Bank_Account__c=ba[3].id, Split_Type__c=BAL);       
        
        cs4.ownerid = testUser.id;
        cs4.Status = 'Closed';
        update cs4;

        
        lstPAs = [SELECT Id, Status__c FROM Product_Assignment__c WHERE Status__c = 'Inactive'];
        system.assertEquals(0, lstPAs.size());
        lstPAs = [SELECT Id, Status__c FROM Product_Assignment__c];
        system.assertEquals(3, lstPAs.size());
        
        
        
        // Create a product removal Case, close it and test that the Product Assignments have been inactivated
        /*Case cs3 = new Case(RecordTypeId = ICCS_RT_Id, Subject = 'test', Origin = 'Email', CaseArea__c = 'ICCS � Remove Product', Status = 'Open',
                        ContactId = c.Id, AccountId = a.Id, ICCS_Product__c = 'BSP', ICCS_Country__c = 'France', ICCS_Currencies__c = 'USD');
        insert cs3;
        
        cs3.Status = 'Closed';
        update cs3;
        
        lstPAs = [SELECT Id, Status__c FROM Product_Assignment__c WHERE Status__c = 'Inactive'];
        system.assertEquals(5, lstPAs.size());
        
        
        // Try to create a removal case with the same product combination and test that it is not inserted
        /*exceptionRaised = false;
        try {
            Case cs2 = new Case(RecordTypeId = ICCS_RT_Id, Subject = 'test', Origin = 'Email', CaseArea__c = 'ICCS � Remove Product', Status = 'Open',
                        ContactId = c.Id, AccountId = a.Id, ICCS_Product__c = 'BSP', ICCS_Country__c = 'France', ICCS_Currencies__c = 'USD');
            insert cs2;
        } catch(Exception e) {exceptionRaised = true;}
        
        system.assertEquals(true,exceptionRaised); 
        lstCases = [SELECT Id FROM Case WHERE RecordTypeId = :ICCS_RT_Id];
        System.AssertEquals(3,lstCases.size()); // Check that the case was not inserted; 3 cases present, cs1, cs3 and cs4
        */
        test.stopTest();
    }
    
    
    
    
    
    static testMethod void test2() {
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
        //Id AirlineHQ_RT_Id = Schema.SObjectType.Account.RecordTypeInfosByName.get('Airline Headquarters').RecordTypeId ;
        Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('IATA_Airline');
        Account a = new Account(Name = 'Qatar Airways', Airline_designator__c = 'QR', ICCS_Membership_Status__c = 'Member', RecordTypeId = AirlineHQ_RT_Id);
        insert a;
        
        //RecordType RT_ContactStd = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'Standard_Contact'];
        //Id ContactStd_RT_Id = Schema.SObjectType.Contact.RecordTypeInfosByName.get('Standard').RecordTypeId ;
        Id ContactStd_RT_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Contact').get('Standard_Contact');
        Contact c = new Contact(FirstName = 'Test', LastName = 'Contact', email = 'test@test.com', AccountId = a.Id, RecordTypeId = ContactStd_RT_Id);
        insert c;
        
        // Create a new ICCS Bank Account for the airline
        List<ICCS_Bank_Account__c> ba = new List<ICCS_Bank_Account__c>(); 
        ba.add( new ICCS_Bank_Account__c(Name = 'QR1111', Account__c = a.Id, CurrencyIsoCode = 'USD', Status__c = 'Active', Description__c = 'asd'));
        ba.add( new ICCS_Bank_Account__c(Name = 'QR2222', Account__c = a.Id, CurrencyIsoCode = 'USD', Status__c = 'Active', Description__c = 'asd'));
        ba.add( new ICCS_Bank_Account__c(Name = 'QR3333', Account__c = a.Id, CurrencyIsoCode = 'USD', Status__c = 'Active', Description__c = 'asd'));
        ba.add( new ICCS_Bank_Account__c(Name = 'QR4444', Account__c = a.Id, CurrencyIsoCode = 'USD', Status__c = 'Active', Description__c = 'asd'));
        ba.add( new ICCS_Bank_Account__c(Name = 'QR5555', Account__c = a.Id, CurrencyIsoCode = 'USD', Status__c = 'Active', Description__c = 'asd'));
        insert ba;
        
        
        
        
        List<Product_Assignment__c> pas = new List<Product_Assignment__c>(); 
        pas.add( new Product_Assignment__c(Account__c = a.Id, Status__c = 'Inactive',ICCS_Product_Currency__c=pcr.id,ICCS_Bank_Account__c=ba[0].id, De_Activation_Date__c=date.today()));
        pas.add( new Product_Assignment__c(Account__c = a.Id, Status__c = 'Inactive',ICCS_Product_Currency__c=pcr.id,ICCS_Bank_Account__c=ba[1].id, De_Activation_Date__c=date.today()));
        pas.add( new Product_Assignment__c(Account__c = a.Id, Status__c = 'Inactive',ICCS_Product_Currency__c=pcr.id,ICCS_Bank_Account__c=ba[2].id, De_Activation_Date__c=date.today()));
        pas.add( new Product_Assignment__c(Account__c = a.Id, Status__c = 'Inactive',ICCS_Product_Currency__c=pcr.id,ICCS_Bank_Account__c=ba[3].id, De_Activation_Date__c=date.today().addDays(-2)));
        pas.add( new Product_Assignment__c(Account__c = a.Id, Status__c = 'Inactive',ICCS_Product_Currency__c=pcr.id,ICCS_Bank_Account__c=ba[4].id, De_Activation_Date__c=date.today().addDays(-4)));
        insert pas;
        
        
        ProductAssignmentRelListCtrl page = new ProductAssignmentRelListCtrl(new ApexPages.StandardController(a));
        system.assertEquals(3,page.pas.size());
    }
    
    /*
    static testMethod void test3() {
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User testUser = New User(

            Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = testProfile.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test.username@test.com',
            License_Cost_Center__c = 'ISF005CH01'
        );
        insert testUser;
    
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
        //Id AirlineHQ_RT_Id = Schema.SObjectType.Account.RecordTypeInfosByName.get('Airline Headquarters').RecordTypeId ;
        Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('IATA_Airline');
        Account a = new Account(Name = 'Qatar Airways', Airline_designator__c = 'QR', ICCS_Membership_Status__c = 'Member', RecordTypeId = AirlineHQ_RT_Id);
        insert a;
        
        //RecordType RT_ContactStd = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'Standard_Contact'];
        //Id ContactStd_RT_Id = Schema.SObjectType.Contact.RecordTypeInfosByName.get('Standard').RecordTypeId ;
        Id ContactStd_RT_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Contact').get('Standard_Contact');
        Contact c = new Contact(FirstName = 'Test', LastName = 'Contact', email = 'test@test.com', AccountId = a.Id, RecordTypeId = ContactStd_RT_Id);
        insert c;
        
        // Create a new ICCS Bank Account for the airline
        List<ICCS_Bank_Account__c> ba = new List<ICCS_Bank_Account__c>(); 
        ba.add( new ICCS_Bank_Account__c(Name = 'QR1111', Account__c = a.Id, CurrencyIsoCode = 'USD', Status__c = 'Active', Description__c = 'asd'));
        ba.add( new ICCS_Bank_Account__c(Name = 'QR2222', Account__c = a.Id, CurrencyIsoCode = 'USD', Status__c = 'Active', Description__c = 'asd'));
        ba.add( new ICCS_Bank_Account__c(Name = 'QR3333', Account__c = a.Id, CurrencyIsoCode = 'USD', Status__c = 'Active', Description__c = 'asd'));
        ba.add( new ICCS_Bank_Account__c(Name = 'QR4444', Account__c = a.Id, CurrencyIsoCode = 'USD', Status__c = 'Active', Description__c = 'asd'));
        ba.add( new ICCS_Bank_Account__c(Name = 'QR5555', Account__c = a.Id, CurrencyIsoCode = 'USD', Status__c = 'Active', Description__c = 'asd'));
        insert ba;
        
        //////////////////////////
        test.startTest();
        
        // Create a Case for the Account
        //RecordType RT_ICCS = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND DeveloperName = 'IDFS_ICCS_Process'];
        //Id ICCS_RT_Id = Schema.SObjectType.Case.RecordTypeInfosByName.get('FDS ICCS Product Management').RecordTypeId ;
        Id ICCS_RT_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('FDS_ICCS_Product_Management');
        Case cs = new Case(RecordTypeId = ICCS_RT_Id, Subject = 'test', Origin = 'Email', CaseArea__c = 'ICCS – Assign Product', Status = 'Open',
                        ContactId = c.Id, AccountId = a.Id, ICCS_Product__c = 'BSP', ICCS_Country__c = 'France', ICCS_Currencies__c = 'USD');  
        insert cs;
        
        List<Case> lstCases = [SELECT Id FROM Case];
        System.AssertEquals(1,lstCases.size());
         
        //need to have a bank account when case status changes to Submitted
        ICCS_BankAccount_To_Case__c batc = new ICCS_BankAccount_To_Case__c(Case__c=cs.id, ICCS_Bank_Account__c=ba[0].id, Split_Type__c=TOT);
        insert batc;
        
        cs.ownerid = testUser.id;
        cs.Status = 'Closed';
        update cs;
        
        cs = [SELECT Id, Subject, Status, isClosed FROM Case WHERE Id = :cs.Id];
        system.assertEquals('Closed', cs.Status);
        system.assertEquals(true, cs.isClosed);
        
        List<Product_Assignment__c> lstPAs = [SELECT Id, Status__c FROM Product_Assignment__c];
        system.assertEquals(1, lstPAs.size());
        system.assertEquals('Active', lstPAs[0].Status__c);
        
        // Create a product update case, close it and check the product assignments have been changed        
        Case cs4 = new Case(RecordTypeId = ICCS_RT_Id, Subject = 'test', Origin = 'Email', CaseArea__c = 'ICCS – Update Payment Instructions', Status = 'Open',
                        ContactId = c.Id, AccountId = a.Id, ICCS_Product__c = 'BSP', ICCS_Country__c = 'France', ICCS_Currencies__c = 'USD');
        insert cs4;
        
        List<ICCS_BankAccount_To_Case__c> batcs = new List<ICCS_BankAccount_To_Case__c>();
        batcs.add( new ICCS_BankAccount_To_Case__c(Case__c=cs4.id, ICCS_Bank_Account__c=ba[0].id, Split_Type__c=PER, Percentage__c=50));
        batcs.add( new ICCS_BankAccount_To_Case__c(Case__c=cs4.id, ICCS_Bank_Account__c=ba[4].id, Split_Type__c=PER, Percentage__c=30));
        
        
        boolean exceptionRaised = false;
        try{insert batcs;}catch(Exception e){exceptionRaised = true;}
        system.assertEquals(false,exceptionRaised);
        
        cs4.Status = 'Closed';
        try{update cs4;}catch(Exception e){exceptionRaised = true;}
        system.assertEquals(true,exceptionRaised); 
        
        exceptionRaised = false;
        insert new ICCS_BankAccount_To_Case__c(Case__c=cs4.id, ICCS_Bank_Account__c=ba[3].id, Split_Type__c=BAL);       
        
        cs4.ownerid = testUser.id;
        cs4.Status = 'Closed';
        update cs4;

        
        lstPAs = [SELECT Id, Status__c FROM Product_Assignment__c WHERE Status__c = 'Inactive'];
        system.assertEquals(0, lstPAs.size());
        lstPAs = [SELECT Id, Status__c FROM Product_Assignment__c];
        system.assertEquals(3, lstPAs.size());
        
        
        
        // Create a product removal Case, close it and test that the Product Assignments have been inactivated
        Case cs3 = new Case(RecordTypeId = ICCS_RT_Id, Subject = 'test', Origin = 'Email', CaseArea__c = 'ICCS – Remove Product', Status = 'Open',
                        ContactId = c.Id, AccountId = a.Id, ICCS_Product__c = 'BSP', ICCS_Country__c = 'France', ICCS_Currencies__c = 'USD');
        insert cs3;
        
        cs3.Status = 'Closed';
        update cs3;
        
        lstPAs = [SELECT Id, Status__c FROM Product_Assignment__c WHERE Status__c = 'Inactive'];
        system.assertEquals(3, lstPAs.size());
        
        
        // Try to create a removal case with the same product combination and test that it is not inserted
        /*exceptionRaised = false;
        try {
            Case cs2 = new Case(RecordTypeId = ICCS_RT_Id, Subject = 'test', Origin = 'Email', CaseArea__c = 'ICCS � Remove Product', Status = 'Open',
                        ContactId = c.Id, AccountId = a.Id, ICCS_Product__c = 'BSP', ICCS_Country__c = 'France', ICCS_Currencies__c = 'USD');
            insert cs2;
        } catch(Exception e) {exceptionRaised = true;}
        
        system.assertEquals(true,exceptionRaised); 
        lstCases = [SELECT Id FROM Case WHERE RecordTypeId = :ICCS_RT_Id];
        System.AssertEquals(3,lstCases.size()); // Check that the case was not inserted; 3 cases present, cs1, cs3 and cs4
        *//*
        test.stopTest();
    }
    */
    
    
    static testMethod void test4() {
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User testUser = New User(

            Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = testProfile.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test.username@test.com',
            License_Cost_Center__c = 'ISF005CH01'
        );
        insert testUser;
    
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
        //Id AirlineHQ_RT_Id = Schema.SObjectType.Account.RecordTypeInfosByName.get('Airline Headquarters').RecordTypeId ;
        Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('IATA_Airline');
        Account a = new Account(Name = 'Qatar Airways', Airline_designator__c = 'QR', ICCS_Membership_Status__c = 'Member', RecordTypeId = AirlineHQ_RT_Id);
        insert a;
        
        //RecordType RT_ContactStd = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'Standard_Contact'];
        //Id ContactStd_RT_Id = Schema.SObjectType.Contact.RecordTypeInfosByName.get('Standard').RecordTypeId ;
        Id ContactStd_RT_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Contact').get('Standard_Contact');
        Contact c = new Contact(FirstName = 'Test', LastName = 'Contact', email = 'test@test.com', AccountId = a.Id, RecordTypeId = ContactStd_RT_Id);
        insert c;
        
        // Create a new ICCS Bank Account for the airline
        ICCS_Bank_Account__c ba = new ICCS_Bank_Account__c(Name = 'QR1111', Account__c = a.Id, CurrencyIsoCode = 'USD', Status__c = 'Active', Description__c = 'asd');
        insert ba;
        
        //////////////////////////
        test.startTest();
        
        // Create a Case for the Account
        Id RT_ICCS_BA_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('FDS_ICCS_Bank_Account_Management');
        Case cs = new Case(RecordTypeId = RT_ICCS_BA_Id, Subject = 'test', Origin = 'Email', CaseArea__c = 'ICCS – Update Bank Account', Status = 'Open',
                        ContactId = c.Id, AccountId = a.Id, ICCS_Bank_Account__c = ba.Id, CurrencyIsoCode = 'EUR');  
        insert cs;
         
        //need to have a bank account when case status changes to Submitted
        //ICCS_BankAccount_To_Case__c batc = new ICCS_BankAccount_To_Case__c(Case__c=cs.id, ICCS_Bank_Account__c=ba[0].id, Split_Type__c=TOT);
        //insert batc;
        
        cs.ownerid = testUser.id;
        cs.Status = 'Closed';
        update cs;
        
        ba = [SELECT Id, CurrencyIsoCode, Status__c FROM ICCS_Bank_Account__c WHERE Id = :ba.Id];
        system.assertEquals('EUR', ba.CurrencyIsoCode);
        system.assertEquals('Active', ba.Status__c);
        
        // Create a bank account creation case
        Case cs1 = new Case(RecordTypeId = RT_ICCS_BA_Id, Subject = 'test', Origin = 'Email', CaseArea__c = 'ICCS – Create Bank Account', Status = 'Open',
                        ContactId = c.Id, AccountId = a.Id, ICCS_Bank_Account__c = ba.Id, CurrencyIsoCode = 'EUR');  
        insert cs1;
        
        cs1 = [SELECT Id, Status, Documentation_Complete__c FROM Case WHERE Id = :cs1.Id ];
        system.assertEquals('Open', cs1.Status);
        
        cs1.Documentation_Complete__c = Date.today();
        update cs1;
        
        cs1 = [SELECT Id, Status, Documentation_Complete__c FROM Case WHERE Id = :cs1.Id ];
        system.assertEquals('In progress', cs1.Status);
        
        
        // Create a bank account delete case
        Case cs2 = new Case(RecordTypeId = RT_ICCS_BA_Id, Subject = 'test', Origin = 'Email', CaseArea__c = 'ICCS – Delete Bank Account', Status = 'Open',
                        ContactId = c.Id, AccountId = a.Id, ICCS_Bank_Account__c = ba.Id, CurrencyIsoCode = 'EUR');  
        insert cs2;
        
        cs2.ownerid = testUser.id;
        cs2.Status = 'Closed';
        update cs2;
        
        ba = [SELECT Id, CurrencyIsoCode, Status__c FROM ICCS_Bank_Account__c WHERE Id = :ba.Id];
        system.assertEquals('Inactive', ba.Status__c);
        
        test.stopTest();
    }
    
    
    
    
    static testMethod void test5() {
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
        //Id AirlineHQ_RT_Id = Schema.SObjectType.Account.RecordTypeInfosByName.get('Airline Headquarters').RecordTypeId ;
        Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('IATA_Airline');
        Account a = new Account(Name = 'Qatar Airways', Airline_designator__c = 'QR', ICCS_Membership_Status__c = 'Member', RecordTypeId = AirlineHQ_RT_Id);
        insert a;
        
        //RecordType RT_ContactStd = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'Standard_Contact'];
        //Id ContactStd_RT_Id = Schema.SObjectType.Contact.RecordTypeInfosByName.get('Standard').RecordTypeId ;
        Id ContactStd_RT_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Contact').get('Standard_Contact');
        Contact c = new Contact(FirstName = 'Test', LastName = 'Contact', email = 'test@test.com', AccountId = a.Id, RecordTypeId = ContactStd_RT_Id);
        insert c;
        
        // Create a new ICCS Bank Account for the airline
        ICCS_Bank_Account__c ba = new ICCS_Bank_Account__c(Name = 'QR1111', Account__c = a.Id, CurrencyIsoCode = 'USD', Status__c = 'Active', Description__c = 'asd');
        insert ba;
        
        //////////////////////////
        test.startTest();
        
        Id RT_ICCS_CD_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('FDS_ICCS_CitiDirect');
        
        // Create a Case for the Account
        
        list<Case> cases = new list<Case>();
        cases.add(new Case(RecordTypeId = RT_ICCS_CD_Id, Subject = 'test', Origin = 'Email', CaseArea__c = 'ICCS - Assign CitiDirect Rights', Status = 'Open',
                        ContactId = c.Id, AccountId = a.Id, Reason1__c = 'Login & Password', Documentation_received__c = 'CitiDirect Request Form'));  
        cases.add(new Case(RecordTypeId = RT_ICCS_CD_Id, Subject = 'test', Origin = 'Email', CaseArea__c = 'ICCS - Assign AFRD CitiDirect Rights', Status = 'Open',
                        ContactId = c.Id, AccountId = a.Id, Reason1__c = 'User management', Documentation_received__c = 'AFRD - CitiDirect Request Form'));  
        cases.add(new Case(RecordTypeId = RT_ICCS_CD_Id, Subject = 'test', Origin = 'Email', CaseArea__c = 'ICCS - Remove CitiDirect Rights', Status = 'Open',
                        ContactId = c.Id, AccountId = a.Id, Reason1__c = 'Termination', Documentation_received__c = 'CitiDirect Request Form'));  
        insert cases;
        
        
        update cases;
        
        
        
        test.stopTest();
    }
}