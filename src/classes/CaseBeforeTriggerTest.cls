@isTest
private class CaseBeforeTriggerTest {

    static final String PER = 'Percentage';
    static final String AM  = 'Amount';
    static final String TOT = 'Total';
    static final String BAL = 'Balance';
    public final static string SMALLAMOUNT = 'Small Amount (<50USD)';
    public final static string MINORPOLICY = 'Minor error policy';
    
    @isTest static void unitTest1() {
        ID hqrt = Schema.SObjectType.Account.RecordTypeInfosByName.get('Airline Headquarters').RecordTypeId ;
        ID CSRcaseRecordTypeID = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('BSPlink Customer Service Requests (CSR)');
        Id RT_Fin_Sec_Monitoring_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('IATA_Financial_Security_Monitoring');
        ID SIDRAcaseRecordTypeID = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('SIDRA');

        IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(name = 'suisse',ISO_Code__c ='SS',AIMS_Area_Name__c='suisse',AIMS_Area_ID__c= '1' );
        insert isoCountry;

        BusinessHours bHourObj = new BusinessHours();
        bHourObj = [Select id, name from BusinessHours where name =: 'EUR - France'];

        Account a = new Account( name ='IFAP ACCT',
                                 industry = 'pluto',
                                 IATA_ISO_Country__c=isoCountry.id,
                                 recordtypeID = hqrt,
                                 IATACode__c ='1234567',
                                 Type = 'IATA Cargo Agent',
                                 billingCountry = 'ss',Location_Type__c = 'AO',
                                 category__c = 'IATA Cargo Agent',
                                 sector__c = 'Cargo Agent');
        insert a;
         
        Contact con =new contact(lastname = 'pluto' ,
                                 phone = '123',
                                 accountid = a.id,
                                 Financial_Assessment_Contact__c = true);
        insert con;
                                
        test.startTest();
        
        // Insert correctly a case
        Case cas = new Case(recordtypeID = CSRcaseRecordTypeID,
                          Status = 'Assessment Performed',
                          Origin = 'asd',
                          IFAP_Area__c = 'asda',
                          Case_Creator_Email__c = 'gianluigi.test@gmail.com',
                          Accelya_Request_Type__c = 'General Queries',
                          Country_concerned__c = 'Italy',
                          contactid = con.id,
                          AccountId = a.id                         
        );
        insert cas; 
        // Insert correctly a case
        Case cas1 = new Case(recordtypeID = RT_Fin_Sec_Monitoring_Id,
                          Status = 'Assessment Performed',
                          Origin = 'asd',
                          Country_concerned_by_the_query__c = 'suisse',
                          Case_Creator_Email__c = 'gianluigi.test@gmail.com',
                          Accelya_Request_Type__c = 'General Queries',
                          Country_concerned__c = 'Italy',
                          contactid = con.id,
                          AccountId = a.id,
                          BusinessHoursId = bHourObj.id                      
        );
        insert cas1; 

        Case cas2 = new Case(recordtypeID = SIDRAcaseRecordTypeID,
                          Status = 'Assessment Performed',
                          Origin = 'asd',
                          DPC_Software__c = 'Multicarta',
                          parentid = cas.id,
                          Country_concerned__c = 'Italy',
                          contactid = con.id,
                          AccountId = a.id,
                          CS_Contact_Result__c = 'Agent closed'
                          //Update_AIMS_IRR__c = system.now(),
                          //Update_AIMS_DEF__c = system.now(),
                          //Update_AIMS_IRRWITH__c = system.now(),
                          //Update_AIMS_REI_DEFWITH__c = system.now(),
                          //Update_AIMS_TER__c = system.now(),
                          //IRR_Withdrawal_Reason__c = 'Small Amount (<50USD)'
        );
        insert cas2; 
        
        cas1.First_closure_date__c = system.today();
        cas1.First_Business_Day__c = system.today();
        cas1.Short_Payment_Date__c = system.today();

        update cas1;
    }

    @isTest static void unitTest2() {
        ID hqrt = Schema.SObjectType.Account.RecordTypeInfosByName.get('Airline Headquarters').RecordTypeId ;
        ID CSRcaseRecordTypeID = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('BSPlink Customer Service Requests (CSR)');
        Id RT_ICCS_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('FDS_ICCS_Product_Management');
        Id RT_ICCS_BA_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('FDS_ICCS_Bank_Account_Management');

        IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(name = 'suisse',ISO_Code__c ='SS',AIMS_Area_Name__c='suisse',AIMS_Area_ID__c= '1' );
        insert isoCountry;
        
        // Create a new Product
        Product2 p = new Product2(Name = 'BSP', Family = 'ICCS');
        insert p;
        
        // Create a new ICCS Product Country for this product
        ICCS_Product_Country__c pct = new ICCS_Product_Country__c(Product__c = p.Id, Country__c = isocountry.Id);
        insert pct;
        
        // Create a new ICCS Product Currency for this ICCS Product Country
        ICCS_Product_Currency__c pcr = new ICCS_Product_Currency__c(
            CurrencyIsoCode = 'USD', 
            ICCS_Product_Country__c = pct.Id, 
            ICCS_Code__c = 'BSPFR1', 
            Status__c = 'Active'
        );
        insert pcr;
        
        Account a = new Account( name ='IFAP ACCT',
                                 industry = 'pluto',
                                 IATA_ISO_Country__c=isoCountry.id,
                                 recordtypeID = hqrt,
                                 IATACode__c ='1234567',
                                 ICCS_Membership_Status__c = 'Member',
                                 Type = 'IATA Cargo Agent',
                                 billingCountry = 'ss',Location_Type__c = 'AO',
                                 category__c = 'IATA Cargo Agent',
                                 sector__c = 'Cargo Agent');
        insert a;
         
        Contact con =new contact(lastname = 'pluto' ,
                                 phone = '123',
                                 accountid = a.id,
                                 Financial_Assessment_Contact__c = true);
        insert con;
        
        // Create a new ICCS Bank Account for the airline
        List<ICCS_Bank_Account__c> ba = new List<ICCS_Bank_Account__c>(); 
        ba.add( new ICCS_Bank_Account__c(Name = 'QR1111', Account__c = a.Id, CurrencyIsoCode = 'USD', Status__c = 'Active', Description__c = 'asd'));
        //ba.add( new ICCS_Bank_Account__c(Name = 'QR2222', Account__c = a.Id, CurrencyIsoCode = 'USD', Status__c = 'Active', Description__c = 'asd'));
        //ba.add( new ICCS_Bank_Account__c(Name = 'QR3333', Account__c = a.Id, CurrencyIsoCode = 'USD', Status__c = 'Active', Description__c = 'asd'));
        //ba.add( new ICCS_Bank_Account__c(Name = 'QR4444', Account__c = a.Id, CurrencyIsoCode = 'USD', Status__c = 'Active', Description__c = 'asd'));
        //ba.add( new ICCS_Bank_Account__c(Name = 'QR5555', Account__c = a.Id, CurrencyIsoCode = 'USD', Status__c = 'Active', Description__c = 'asd'));
        insert ba;

        List<Product_Assignment__c> pas = new List<Product_Assignment__c>(); 
        pas.add( new Product_Assignment__c(Account__c = a.Id, Status__c = 'Active',ICCS_Product_Currency__c=pcr.id,ICCS_Bank_Account__c=ba[0].id, De_Activation_Date__c=date.today()));
        insert pas;
        
        BusinessHours bHourObj = new BusinessHours();
        bHourObj = [Select id, name from BusinessHours where name =: 'EUR - France'];
                                
        test.startTest();
        
        // Insert correctly a case
        Case cas = new Case(recordtypeID = RT_ICCS_BA_Id,
                          Status = 'Assessment Performed',
                          Origin = 'asd',
                          Casearea__c = 'ICCS – Delete Bank Account',
                          IFAP_Area__c = 'asda',
                          Country_concerned__c = 'Italy',
                          contactid = con.id,
                          AccountId = a.id                         
        );
        insert cas; 
        
        Case cas1 = new Case(recordtypeID = RT_ICCS_Id,
                          Status = 'Assessment Performed',
                          Origin = 'asd',
                          Casearea__c = 'ICCS – Delete Bank Account',
                          IFAP_Area__c = 'asda',
                          Country_concerned__c = 'Italy',
                          contactid = con.id,
                          AccountId = a.id,
                          ICCS_Product__c = 'BSP',
                          ICCS_Country__c = 'suisse',
                          ICCS_Currencies__c = 'USD'                      
        );
        insert cas1; 
        // Insert correctly a case
        
    }

    @istest static void test0() {
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
        
        test.stopTest();
    }
    
    @istest static void test1() {
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
                        ContactId = c.Id, AccountId = a.Id, ICCS_Product__c = 'BSP', ICCS_Country__c = 'France', ICCS_Currencies__c = 'USD', 
                        Accelerated_Function__c = true);  
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
        
        // Try to create an assignment case with the same product combination and test that it is not inserted
        try {
            Case cs2 = new Case(RecordTypeId = ICCS_RT_Id, Subject = 'test', Origin = 'Email', CaseArea__c = 'ICCS – Assign Product', Status = 'Open',
                        ContactId = c.Id, AccountId = a.Id, ICCS_Product__c = 'BSP', ICCS_Country__c = 'France', ICCS_Currencies__c = 'USD');
            insert cs2;
        } catch(Exception e) {}
        
        
        lstCases = [SELECT Id FROM Case WHERE RecordTypeId = :ICCS_RT_Id];
        System.AssertEquals(2,lstCases.size()); // Check that the case was not inserted
        
        // Try to inactivate the bank account linked to the PA record
        try {
            ba[0].Status__c = 'Inactive';
            update ba;
        }  catch(Exception e) {}
        //system.assertEquals(0, [SELECT Id, Status__c FROM ICCS_Bank_account__c WHERE Status__c = 'Inactive'].size()); // check that the status didn't change
        
        // Try to inactivate the ICCS Product Currency linked to the PA record
        try {
            pcr.Status__c = 'Inactive';
            update pcr;
        }  catch(Exception e) {}
        
        pcr = [SELECT Id, Status__c FROM ICCS_Product_Currency__c WHERE Id = :pcr.Id];
        //system.assertEquals('Active', pcr.Status__c); // check that the status didn't change
   
        List<Product_Assignment__c> pas = new List<Product_Assignment__c>(); 
        pas.add( new Product_Assignment__c(Account__c = a.Id, Status__c = 'Active',ICCS_Product_Currency__c=pcr.id,ICCS_Bank_Account__c=ba[0].id, De_Activation_Date__c=date.today()));
        insert pas;
        
        // Create a product update case, close it and check the product assignments have been changed        
        /*Case cs4 = new Case(RecordTypeId = ICCS_RT_Id, Subject = 'test', Origin = 'Email', CaseArea__c = 'ICCS – Update Payment Instructions', Status = 'Open',
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
        update cs4;*/

        test.stopTest();
    }
    
    @istest static void test2() {
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
    
    @istest static void test4() {
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
        system.assertEquals('USD', ba.CurrencyIsoCode);
        system.assertEquals('Active', ba.Status__c);
        
        // Create a bank account creation case
        Case cs1 = new Case(RecordTypeId = RT_ICCS_BA_Id, Subject = 'test', Origin = 'Email', CaseArea__c = 'ICCS – Create Bank Account', Status = 'Open',
                        ContactId = c.Id, AccountId = a.Id, ICCS_Bank_Account__c = ba.Id, CurrencyIsoCode = 'USD');  
        insert cs1;
        
        cs1 = [SELECT Id, Status, Documentation_Complete__c FROM Case WHERE Id = :cs1.Id ];
        system.assertEquals('Open', cs1.Status);
        
        cs1.Documentation_Complete__c = Date.today();
        update cs1;
        
        cs1 = [SELECT Id, Status, Documentation_Complete__c FROM Case WHERE Id = :cs1.Id ];
        system.assertEquals('In progress', cs1.Status);
        
        
        // Create a bank account delete case
        Case cs2 = new Case(RecordTypeId = RT_ICCS_BA_Id, Subject = 'test', Origin = 'Email', CaseArea__c = 'ICCS – Delete Bank Account', Status = 'Open',
                        ContactId = c.Id, AccountId = a.Id, ICCS_Bank_Account__c = ba.Id, CurrencyIsoCode = 'USD');  
        insert cs2;
        
        cs2.ownerid = testUser.id;
        cs2.Status = 'Closed';
        update cs2;
        
        ba = [SELECT Id, CurrencyIsoCode, Status__c FROM ICCS_Bank_Account__c WHERE Id = :ba.Id];
        //system.assertEquals('Inactive', ba.Status__c);
        
        test.stopTest();
    }
    @istest static void test5() {
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
//insert a SAAM case, AirlineCodingRTId case, RT_ICCS_ASP_Id case

    @istest static void testSingle1() {
    
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User testUser = New User(
            Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = testProfile.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test.username@test.com',
            License_Cost_Center__c = 'ISF005CH01'
        );
        insert testUser;
        
        Id RT_ICCS_ASP_Id = Schema.SObjectType.Case.RecordTypeInfosByName.get('FDS ASP Management').getRecordTypeId() ;
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(Name = 'France', ISO_Code__c = 'FR');
        insert country;
        
        Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('IATA_Airline');
        Account a = new Account(Name = 'Qatar Airways', Airline_designator__c = 'QR', ICCS_Membership_Status__c = 'Member', RecordTypeId = AirlineHQ_RT_Id);
        insert a;
        
        Id ContactStd_RT_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Contact').get('Standard_Contact');
        Contact c = new Contact(FirstName = 'Test', LastName = 'Contact', email = 'test@test.com', AccountId = a.Id, RecordTypeId = ContactStd_RT_Id);
        insert c;
        
        //////////////////////////
        test.startTest();
        
        // Insert correctly a case
        Case cas = new Case(recordtypeID = RT_ICCS_ASP_Id,
                          Status = 'Assessment Performed',
                          Origin = 'asd',
                          Casearea__c = 'FDS - Create Authorized Signatories Package',
                          IFAP_Area__c = 'asda',
                          Country_concerned__c = 'Italy',
                          contactid = c.id,
                          AccountId = a.id                         
        );
        insert cas; 
        
        cas.status = 'Closed';
        cas.Eligibility_Documents_Checklist_approved__c = true;
        cas.ownerid = testUser.id;
        update cas;
        
        ID AirlineCodingRTId = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('Airline_Coding_Application');
        // Insert correctly a case
        Case cas1 = new Case(recordtypeID = AirlineCodingRTId,
                          Status = 'Assessment Performed',
                          Origin = 'asd',
                          Casearea__c = 'FDS - Create Authorized Signatories Package',
                          IFAP_Area__c = 'asda',
                          Country_concerned__c = 'Italy',
                          contactid = c.id,
                          AccountId = a.id                         
        );
        insert cas1; 
        
        test.stopTest();
    }

    @isTest static void trgICCS_ASP_CaseTest() {
      // Create a new ISO Country
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(Name = 'France', ISO_Code__c = 'FR');
        insert country;
        
        // Create an Airline HQ account & a contact for it
        //Id AirlineHQ_RT_Id = Schema.SObjectType.Account.RecordTypeInfosByName.get('Airline Headquarters').RecordTypeId ;
        //Id AirlineHQ_RT_Id = mapRTIdsPerRTName.get('Airline Headquarters');
        Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('IATA_Airline');
        Account a = new Account(Name = 'Qatar Airways', Airline_designator__c = 'QR', ICCS_Membership_Status__c = 'Member', RecordTypeId = AirlineHQ_RT_Id);
        insert a;
        
        //Id ContactStd_RT_Id = Schema.SObjectType.Contact.RecordTypeInfosByName.get('Standard').RecordTypeId ;
        //Id ContactStd_RT_Id = mapRTIdsPerRTName.get('Standard');
        Id ContactStd_RT_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Contact').get('Standard_Contact');
        Contact c = new Contact(FirstName = 'Test', LastName = 'Contact', email = 'test@test.com', AccountId = a.Id, RecordTypeId = ContactStd_RT_Id);
        insert c;
        
        // create an Airline Coding Application case on the account
        ID AirlineCodingRTId = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('Airline_Coding_Application');
        Case cs_coding1 = new Case(recordtypeID = AirlineCodingRTId, Status = 'Open', AccountId = a.id, Subject = 'cs1');
        insert cs_coding1;
        
        //////////////////////////
        test.startTest();
        
        // Create a Case for the Account
        //Id RT_ICCS_ASP_Id = Schema.SObjectType.Case.RecordTypeInfosByName.get('FDS ASP Management').RecordTypeId ;
        //Id RT_ICCS_ASP_Id = mapRTIdsPerRTName.get('FDS ASP Management');
        Id RT_ICCS_ASP_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('FDS_ASP_Management');
        Case cs = new Case(RecordTypeId = RT_ICCS_ASP_Id, Subject = 'test', Origin = 'Email', CaseArea__c = 'FDS - Create Authorized Signatories Package', Status = 'Open',
                        ContactId = c.Id, AccountId = a.Id, Confirmation_Remarks__c = 'remarks', Eligibility_Documents_Checklist_approved__c = true);  
        insert cs;
        
        List<Case> lstCases = [SELECT Id, Account.Ongoing_Request_for_Documents__c FROM Case WHERE RecordTypeId = :RT_ICCS_ASP_Id];
        System.AssertEquals(1,lstCases.size());
        System.AssertEquals(true,lstCases[0].Account.Ongoing_Request_for_Documents__c);
        
        // try to open a new ASP case on the same account, check that it is not inserted
        try {
            Case cs2 = new Case(RecordTypeId = RT_ICCS_ASP_Id, Subject = 'test', Origin = 'Email', CaseArea__c = 'FDS - Create Authorized Signatories Package', Status = 'Open',
                        ContactId = c.Id, AccountId = a.Id, Confirmation_Remarks__c = 'remarks', Eligibility_Documents_Checklist_approved__c = true);
            insert cs2;
        } catch(Exception e) {}
        
        lstCases = [SELECT Id FROM Case WHERE RecordTypeId = :RT_ICCS_ASP_Id];
        System.AssertEquals(1,lstCases.size()); // Check that the case was not inserted
        
        
        cs.Status = 'Closed';
        update cs;
        
        lstCases = [SELECT Id, Account.Ongoing_Request_for_Documents__c FROM Case WHERE RecordTypeId = :RT_ICCS_ASP_Id];
        System.AssertEquals(1,lstCases.size());
        System.AssertEquals(false,lstCases[0].Account.Ongoing_Request_for_Documents__c);
        
        
        // try to open a new Airline Coding case on the same account, check that it is not inserted 
        Boolean isExceptionRaised = false;
        try {
          Case cs_coding2 = new Case(recordtypeID = AirlineCodingRTId, Status = 'Open', AccountId = a.id, Subject = 'cs2');
          insert cs_coding2;
        } catch(Exception e) {
          isExceptionRaised = true;
        }
        
        System.AssertEquals(true, isExceptionRaised);
        
        test.stopTest();
    }

    public static testmethod void TestSidraCases(){
        Case aCase;
        integer c = 0;
        ID SidraPcaseRecordTypeID = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('SIDRA');
            
        Account account1 = new Account(IATACode__c = '1234567');    // 7 digits
        account1.Name = 'Test account';
        account1.BillingCity = 'Montreal';
        account1.BillingCountry = 'Canada';
        account1.BillingStreet = 'some street';
        account1.Type = 'IATA Passenger Sales Agent';
        account1.Location_Type__c = 'HO';
        insert account1;
    
    
        Contact con = new Contact();
        con.FirstName = 'Dummy';
        con.LastName = 'Contact';
        con.Type_of_Contact__c = 'IFAP Contact';
        con.AccountId = account1.Id;
        con.Email = 'some@email.org';  
        con.Financial_Assessment_Contact__c = true;          
        insert con;
        
        List<Case> cases = new List<Case>();
        
        // SMALLAMOUNT
        cases.add(new Case( ContactId = con.Id,
                            AccountId = con.accountId,
                            Subject = 'TestCase Sidra Small Amount ' + c,
                            Origin = 'Web',
                            RecordTypeId = SidraPcaseRecordTypeID,
                            Description = 'description ' + c++,
                            Billing_Amount__c = 200,
                            Short_Payment_Amount__c = 50,
                            CurrencyExchangeRateUSD__c = 1,
                            SIDRA_exchange_rate_updated__c = true,
                            BSP_CASS__c = 'BSP'
        ));
        
        // NOT SMALLAMOUNT
        cases.add(new Case( ContactId = con.Id,
                            AccountId = con.accountId,
                            Subject = 'TestCase Sidra Small Amount ' + c,
                            Origin = 'Web',
                            RecordTypeId = SidraPcaseRecordTypeID,
                            Description = 'description ' + c++,
                            Billing_Amount__c = 200,
                            Short_Payment_Amount__c = 60,
                            CurrencyExchangeRateUSD__c = 1,
                            SIDRA_exchange_rate_updated__c = true,
                            BSP_CASS__c = 'BSP'
        ));
        
        // MINORPOLICY
        cases.add(new Case( ContactId = con.Id,
                            AccountId = con.accountId,
                            Subject = 'TestCase Sidra Small Amount ' + c,
                            Origin = 'Web',
                            RecordTypeId = SidraPcaseRecordTypeID,
                            Description = 'description ' + c++,
                            Billing_Amount__c = 2000,
                            Short_Payment_Amount__c = 100,
                            CurrencyExchangeRateUSD__c = 1,
                            SIDRA_exchange_rate_updated__c = true,
                            BSP_CASS__c = 'BSP'
        ));
        
        // NOT MINORPOLICY
        cases.add(new Case( ContactId = con.Id,
                            AccountId = con.accountId,
                            Subject = 'TestCase Sidra Small Amount ' + c,
                            Origin = 'Web',
                            RecordTypeId = SidraPcaseRecordTypeID,
                            Description = 'description ' + c++,
                            Billing_Amount__c = 2000,
                            Short_Payment_Amount__c = 101,
                            CurrencyExchangeRateUSD__c = 1,
                            SIDRA_exchange_rate_updated__c = true,
                            BSP_CASS__c = 'BSP'
        ));
        
        // MINORPOLICY
        cases.add(new Case( ContactId = con.Id,
                            AccountId = con.accountId,
                            Subject = 'TestCase Sidra Small Amount ' + c,
                            Origin = 'Web',
                            RecordTypeId = SidraPcaseRecordTypeID,
                            Description = 'description ' + c++,
                            Billing_Amount__c = 4000000,
                            Short_Payment_Amount__c = 150000,
                            CurrencyExchangeRateUSD__c = 1,
                            SIDRA_exchange_rate_updated__c = true,
                            BSP_CASS__c = 'BSP'
        ));
        
        // NOT MINORPOLICY
        cases.add(new Case( ContactId = con.Id,
                            AccountId = con.accountId,
                            Subject = 'TestCase Sidra Small Amount ' + c,
                            Origin = 'Web',
                            RecordTypeId = SidraPcaseRecordTypeID,
                            Description = 'description ' + c++,
                            Billing_Amount__c = 4000000,
                            Short_Payment_Amount__c = 160000,
                            CurrencyExchangeRateUSD__c = 1,
                            SIDRA_exchange_rate_updated__c = true,
                            BSP_CASS__c = 'BSP'
        ));
        
        insert cases;

        Test.StartTest();
        cases = [SELECT Id,Subject,  IRR_Withdrawal_Reason__c FROM Case];
        integer countSA = 0, countMP = 0, countN = 0;
        for(Case cs : cases){
            system.debug('=========== '+cs.Subject+' --> '+cs.IRR_Withdrawal_Reason__c);
            if(cs.IRR_Withdrawal_Reason__c == SMALLAMOUNT)  countSA++;
            else if(cs.IRR_Withdrawal_Reason__c == MINORPOLICY) countMP++;
            else    countN++;
        }
        
        system.assertEquals(1,countSA);
        system.assertEquals(2,countMP);
        system.assertEquals(3,countN);
        
        
        // From the fourth case with SMALL AMOUNT, IRR_Withdrawal_Reason__c will be set to null and Action_needed_Small_Amount__c will be set to true
        insert new Case(    ContactId = con.Id,
                            AccountId = con.accountId,
                            Subject = 'TestCase Sidra Small Amount ' + c,
                            Origin = 'Web',
                            RecordTypeId = SidraPcaseRecordTypeID,
                            Description = 'description ' + c++,
                            Billing_Amount__c = 4000000,
                            Short_Payment_Amount__c = 5,
                            CurrencyExchangeRateUSD__c = 1,
                            SIDRA_exchange_rate_updated__c = true,
                            BSP_CASS__c = 'BSP'
        );
        
        Case theCase;
        for(Case cs : cases){
            if(cs.IRR_Withdrawal_Reason__c != SMALLAMOUNT){
                theCase = cs;
                break;
            }
        }
        
        theCase.Billing_Amount__c = 400000;
        theCase.Short_Payment_Amount__c = 500;
        update theCase;
        
        
        cases = [SELECT Id, Subject, IRR_Withdrawal_Reason__c FROM Case ORDER BY Subject];
        countSA = 0; countN = 0; countMP = 0;
        for(Case cs : cases){
            if(cs.IRR_Withdrawal_Reason__c == SMALLAMOUNT)  countSA++;
            else if(cs.IRR_Withdrawal_Reason__c == MINORPOLICY) countMP++;
            else    countN++;
        }
        
        system.assertEquals(1,countSA);
        system.assertEquals(2,countMP);
        system.assertEquals(4,countN);
        
        
        
        cases = [SELECT Id, IRR_Withdrawal_Reason__c, Action_needed_Small_Amount__c 
                 FROM Case 
                 WHERE Subject = 'TestCase Sidra Small Amount 6' OR ID = :theCase.Id];
        //system.debug(LoggingLevel.ERROR, '==================== '+cases+' ===========================');
        system.assertEquals(2,cases.size());
        system.assertEquals(true,cases[0].Action_needed_Small_Amount__c);
        system.assertEquals(true,cases[1].Action_needed_Small_Amount__c);
        system.assertEquals(null,cases[0].IRR_Withdrawal_Reason__c);
        system.assertEquals(null,cases[1].IRR_Withdrawal_Reason__c);
        
        
        cases = [SELECT Id, IRR_Withdrawal_Reason__c, Action_needed_Small_Amount__c 
                 FROM Case 
                 WHERE Action_needed_Small_Amount__c = true
                 AND IRR_Withdrawal_Reason__c = null];
        system.assertEquals(2,cases.size());
    }
    
    
    // test new filter: only count minor error policy cases after the last reinstatement
    public static testmethod void TestSidraCases_2(){
        Case aCase;
        integer c = 0;
        ID SidraPcaseRecordTypeID = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('SIDRA');
            
        Account account1 = new Account(IATACode__c = '1234567');    // 7 digits
        account1.Name = 'Test account';
        account1.BillingCity = 'Montreal';
        account1.BillingCountry = 'Canada';
        account1.BillingStreet = 'some street';
        account1.Type = 'IATA Passenger Sales Agent';
        account1.Location_Type__c = 'HO';
        insert account1;
    
    
        Contact con = new Contact();
        con.FirstName = 'Dummy';
        con.LastName = 'Contact';
        con.Type_of_Contact__c = 'IFAP Contact';
        con.AccountId = account1.Id;
        con.Email = 'some@email.org';  
        con.Financial_Assessment_Contact__c = true;          
        insert con;
        
        List<Case> cases = new List<Case>();
        
        // SMALLAMOUNT
        cases.add(new Case( ContactId = con.Id,
                            AccountId = con.accountId,
                            Subject = 'TestCase Sidra Small Amount ' + c,
                            Origin = 'Web',
                            RecordTypeId = SidraPcaseRecordTypeID,
                            Description = 'description ' + c++,
                            Billing_Amount__c = 200,
                            Short_Payment_Amount__c = 50,
                            CurrencyExchangeRateUSD__c = 1,
                            BSP_CASS__c = 'BSP',
                            SIDRA_exchange_rate_updated__c = true
        ));
        
        
        // MINORPOLICY
        cases.add(new Case( ContactId = con.Id,
                            AccountId = con.accountId,
                            Subject = 'TestCase Sidra Small Amount ' + c,
                            Origin = 'Web',
                            RecordTypeId = SidraPcaseRecordTypeID,
                            Description = 'description ' + c++,
                            Billing_Amount__c = 2000,
                            Short_Payment_Amount__c = 100,
                            CurrencyExchangeRateUSD__c = 1,
                            BSP_CASS__c = 'BSP',
                            SIDRA_exchange_rate_updated__c = true
        ));
        
        
        // MINORPOLICY
        cases.add(new Case( ContactId = con.Id,
                            AccountId = con.accountId,
                            Subject = 'TestCase Sidra Small Amount ' + c,
                            Origin = 'Web',
                            RecordTypeId = SidraPcaseRecordTypeID,
                            Description = 'description ' + c++,
                            Billing_Amount__c = 4000000,
                            Short_Payment_Amount__c = 150000,
                            CurrencyExchangeRateUSD__c = 1,
                            BSP_CASS__c = 'BSP',
                            SIDRA_exchange_rate_updated__c = true
        ));
        
        
        insert cases;
        
        Case rei = new Case( ContactId = con.Id,
                            AccountId = con.accountId,
                            Subject = 'TestCase Sidra Small Amount ' + c,
                            Origin = 'Web',
                            RecordTypeId = SidraPcaseRecordTypeID,
                            Description = 'description ' + c++,
                            Billing_Amount__c = 4000000,
                            Short_Payment_Amount__c = 160000,
                            CurrencyExchangeRateUSD__c = 1,
                            SIDRA_exchange_rate_updated__c = true,
                            BSP_CASS__c = 'BSP',
                            Update_AIMS_REI_DEFWITH__c = Datetime.now(),
                            REI_ApprovalRejectin__c = 'Approved',
                            DEF_Withdrawal_Approval_Rejection__c = '');
        insert rei;
        
        Test.StartTest();
        
        // The fourth case with SMALL AMOUNT
        // Check that, because of the reinstatement case, Action_needed_Small_Amount__c is not set to true
        Case testcase = new Case(    ContactId = con.Id,
                            AccountId = con.accountId,
                            Subject = 'TestCase Sidra Small Amount ' + c,
                            Origin = 'Web',
                            RecordTypeId = SidraPcaseRecordTypeID,
                            Description = 'description ' + c++,
                            Billing_Amount__c = 4000000,
                            Short_Payment_Amount__c = 5,
                            CurrencyExchangeRateUSD__c = 1,
                            SIDRA_exchange_rate_updated__c = true,
                            BSP_CASS__c = 'BSP'
        );
        insert testcase;
        
        update testCase;        
        
        cases = [SELECT Id, IRR_Withdrawal_Reason__c, Action_needed_Small_Amount__c FROM Case WHERE ID = :testcase.Id];
        system.assertEquals(false, cases[0].Action_needed_Small_Amount__c);
    }
}