@isTest
private class CaseBeforeTriggerTest {

    static final String PER = 'Percentage';
    static final String AM  = 'Amount';
    static final String TOT = 'Total';
    static final String BAL = 'Balance';
    public final static string SMALLAMOUNT = 'Small Amount (<50USD)';
    public final static string MINORPOLICY = 'Minor error policy';
    private static final string CASE_RECORDTYPE_FSM = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('IATA Financial Security Monitoring');
    private static final string NCRecordTypeID = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('SAAM');
    public static final String PAX = 'Travel Agent';
    public static final String CARGO = 'Cargo Agent';


    @isTest static void unitTest1() {
        ID hqrt = Schema.SObjectType.Account.RecordTypeInfosByName.get('Airline Headquarters').RecordTypeId ;
        ID CSRcaseRecordTypeID = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('BSPlink Customer Service Requests (CSR)');
        Id RT_Fin_Sec_Monitoring_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('IATA_Financial_Security_Monitoring');
        ID SIDRAcaseRecordTypeID = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('SIDRA');
        ID AmericacaseRecordTypeID = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('CasesAmericas');

        IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(name = 'suisse',ISO_Code__c ='SS',AIMS_Area_Name__c='suisse',AIMS_Area_ID__c= '1' );
        insert isoCountry;

        BusinessHours bHourObj = new BusinessHours();
        bHourObj = [Select id, name from BusinessHours where name =: 'EUR - France'];
        List<Account> accounts = new List<Account>();
        Account a = new Account( name ='IFAP ACCT',
                                 industry = 'Travel Agent',
                                 IATA_ISO_Country__c=isoCountry.id,
                                 recordtypeID = hqrt,
                                 IATACode__c ='1234',
                                 Site_Index__c = '1234',  
                                 Type = 'IATA Cargo Agent',
                                 billingCountry = 'ss',Location_Type__c = 'AO',
                                 category__c = 'IATA Cargo Agent',
                                 sector__c = 'Cargo Agent');
        accounts.add(a);
        //lstMatchedAccounts
        Account b = new Account( name ='IFAP ACCT1',
                                 industry = 'Travel Agent',
                                 IATA_ISO_Country__c=isoCountry.id,
                                 recordtypeID = hqrt,
                                 IATACode__c ='0123456',
                                 Site_Index__c = '1234',
                                 Type = 'IATA Cargo Agent',
                                 billingCountry = 'ss',Location_Type__c = 'AO',
                                 category__c = 'IATA Cargo Agent',
                                 sector__c = 'Cargo Agent');
        accounts.add(b);

        Account c = new Account( name ='test',
                                 industry = 'Travel Agent',
                                 IATA_ISO_Country__c=isoCountry.id,
                                 recordtypeID = hqrt,
                                 IATACode__c ='1234',
                                 Site_Index__c = '1234',  
                                 Type = 'IATA Cargo Agent',
                                 billingCountry = 'ss',Location_Type__c = 'AO',
                                 category__c = 'IATA Cargo Agent',
                                 sector__c = 'Cargo Agent');
        accounts.add(c);
        insert accounts;
         
        Contact con =new contact(lastname = 'pluto' ,
                                 firstname = 'test',
                                 phone = '123',
                                 accountid = accounts[0].id,
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

        Case cas3 = new Case(recordtypeID = AmericacaseRecordTypeID,
                          Status = 'Action Needed',
                          Origin = 'asd',
                          Region__c = 'Americas',
                          BSPCountry__c = 'Anguilla',
                          IATAcode__c = '12345 SS',
                          parentid = cas.id,
                          Country_concerned__c = 'Italy',
                          contactid = con.id,
                          AccountId = a.id
        );
        insert cas3; 
        cas3.IATAcode__c = '1234567';
        update cas3;

        Case cas4 = new Case(recordtypeID = AmericacaseRecordTypeID,
                          Status = 'Action Needed',
                          Origin = 'asd',
                          Region__c = 'Americas',
                          BSPCountry__c = 'Anguilla',
                          IATAcode__c = '01234567 SS',
                          parentid = cas.id,
                          Country_concerned__c = 'Italy',
                          contactid = con.id,
                          AccountId = a.id
        );
        insert cas4;
        cas4.IATAcode__c = '0123456789';
        update cas4;

        Case cas5 = new Case(recordtypeID = AmericacaseRecordTypeID,
                          Status = 'Action Needed',
                          Origin = 'asd',
                          Region__c = 'Americas',
                          BSPCountry__c = 'Anguilla',
                          IATAcode__c = '1234 SS',
                          parentid = cas.id,
                          Country_concerned__c = 'Italy',
                          contactid = con.id,
                          AccountId = a.id
        );
        insert cas5; 
    }
    
    @isTest static void testISSP_Case_3() {
        ID hqrt = Schema.SObjectType.Account.RecordTypeInfosByName.get('Airline Headquarters').RecordTypeId ;
        
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User testUser = New User(
            Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = testProfile.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test.username@test.com',
            License_Cost_Center__c = 'ISF005CH01'
        );
        insert testUser;

        IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(name = 'suisse',ISO_Code__c ='SS',AIMS_Area_Name__c='suisse',AIMS_Area_ID__c= '1' );
        insert isoCountry; 

        Account a = new Account( name ='IFAP ACCT',
                                 industry = 'pluto',
                                 IATA_ISO_Country__c=isoCountry.id,
                                 recordtypeID = hqrt,
                                 IATACode__c ='1234567',
                                 Site_Index__c = '1234567',
                                 Type = 'IATA Cargo Agent',
                                 billingCountry = 'ss',Location_Type__c = 'AO',
                                 category__c = 'IATA Cargo Agent',
                                 sector__c = 'Cargo Agent');
        insert a;

        Contact con =new contact(lastname = 'pluto' ,
                                 firstname = 'test',
                                 phone = '123',
                                 accountid = a.id,
                                 User_Portal_Status__c = 'Approved Admin',
                                 Financial_Assessment_Contact__c = true);
        insert con;

        Case_Reason_Service__c CRS = new Case_Reason_Service__c(
                    Name = 'BSP Direct - Member',
                    Provider_Required__c = false,
                    Service__c = 'BSP Participation');
        insert CRS;

        ID recordTypeId = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('IDFS Airline Participation Process');
        Case c = new Case(
                    Subject = 'test 1',
                    Status = 'Draft',
                    AccountId = a.id,
                    ContactId = con.id,
                    Region__c = 'Europe',
                    RecordTypeId = recordTypeId,
                    CaseArea__c = 'Airline Joining',
                    Reason1__c = 'BSP Direct - Member');
        insert c;
    }

/*
    @isTest static void unitTestPortal() {
        ID hqrt = Schema.SObjectType.Account.RecordTypeInfosByName.get('Airline Headquarters').RecordTypeId ;
        ID PortalsharingRTID = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('External Cases (InvoiceWorks)');
        Id RT_ICC_Id = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('Invoicing Collection Cases');
        ID RecId = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('Cases_SIS_Help_Desk');
        
        IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(name = 'suisse',ISO_Code__c ='SS',AIMS_Area_Name__c='suisse',AIMS_Area_ID__c= '1' );
        insert isoCountry;

        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User testUser = New User(
            Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = testProfile.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test.username@test.com',
            License_Cost_Center__c = 'ISF005CH01'
        );
        insert testUser;
        
        Product_Category__c PC = new Product_Category__c(
                Name = 'test',
                Active__c = true,
                Short_Description__c = 'test test');
        insert PC;
        
        BusinessHours bHourObj = new BusinessHours();
        bHourObj = [Select id, name from BusinessHours where name =: 'EUR - France'];

        Account a = new Account( name ='IFAP ACCT',
                                 industry = 'pluto',
                                 IATA_ISO_Country__c=isoCountry.id,
                                 recordtypeID = hqrt,
                                 IATACode__c ='1234567',
                                 Site_Index__c = '1234567',
                                 Type = 'IATA Cargo Agent',
                                 billingCountry = 'ss',Location_Type__c = 'AO',
                                 category__c = 'IATA Cargo Agent',
                                 sector__c = 'Cargo Agent');
        insert a;
        
        Account aICH = new Account( name ='ICH ACCT',
                                 industry = 'pluto',
                                 IATA_ISO_Country__c=isoCountry.id,
                                 recordtypeID = hqrt,
                                 IATACode__c ='1834567',
                                 Site_Index__c = '1834567',
                                 Type = 'IATA Cargo Agent',
                                 billingCountry = 'ss',Location_Type__c = 'AO',
                                 category__c = 'IATA Cargo Agent',
                                 sector__c = 'Cargo Agent');
        insert aICH;
         
        Contact con =new contact(lastname = 'pluto' ,
                                 phone = '123',
                                 accountid = a.id,
                                 User_Portal_Status__c = 'Approved Admin',
                                 Financial_Assessment_Contact__c = true);
        insert con;
        
        Contact conICH =new contact(lastname = 'ICH Help Desk' ,
                                 phone = '321',
                                 accountid = aICH.id,
                                 Financial_Assessment_Contact__c = true);
        insert conICH;
                           
        EmailTemplate__c template = new EmailTemplate__c( 
                        Template_Language__c = 'English', 
                        IATA_ISO_Country__c = isoCountry.Id, 
                        Agent_Type__c='All');
        insert template;
        
        test.startTest();
        
        // Insert correctly a case
        Case cas = new Case(recordtypeID = PortalsharingRTID,
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
        Case cas1 = new Case(recordtypeID = RT_ICC_Id,
                          Status = 'Open',
                          Casearea__c = 'Collection', 
                          Reason1__c = 'Debt Recovery',
                          contactid = con.id,
                          AccountId = a.id,
                          BusinessHoursId = bHourObj.id                      
        );
        insert cas1; 

        Case cas2 = new Case(recordtypeID = RecId,
                          Status = 'Open',
                          Origin = 'asd',
                          DPC_Software__c = 'Multicarta',
                          parentid = cas.id,
                          Country_concerned__c = 'Italy',
                          contactid = conICH.id,
                          AccountId = aICH.id
        );
        insert cas2; 
        
        update cas2;
        string prodCat = PC.id;
        Case cas3 = new Case(recordtypeID = NCRecordTypeID,
                          Status = 'Open',
                          Region__c = 'Americas',
                          BSPCountry__c = 'Anguilla',
                          CaseArea__c = 'Accreditation Products',
                          Reason1__c = 'PAX/CARGO Certificate',
                          Product_Category_ID__c = prodCat,
                          IATACodeProduct__c = '38222693',
                          QuantityProduct__c = '2',
                          contactid = con.id,
                          AccountId = a.id
        );
        insert cas3; 
        
        cas3.ownerid = testUser.id;
        cas3.status = 'closed';
        System.runAs(testUser) {
          update cas3;
        }
        

    }
	*/
    //*********************************

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
                                 firstname = 'test',
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
        ID PortalsharingRTID = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('External Cases (InvoiceWorks)');
        ID sisHelpDeskCaseRecordTypeID = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get(Label.Cases_SIS_Help_Desk);
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
        List <Case> lcs = new List<Case>();
        Case cs3 = new Case(RecordTypeId = sisHelpDeskCaseRecordTypeID, Subject = 'test', Origin = 'Email', CaseArea__c = 'ICH', Status = 'Open',
                        ContactId = c.Id, AccountId = a.Id, ICCS_Product__c = 'BSP', ICCS_Country__c = 'France', ICCS_Currencies__c = 'USD', Type='General Question');  
        lcs.add(cs3);

        Case cs4 = new Case(RecordTypeId = sisHelpDeskCaseRecordTypeID, Subject = 'test', Origin = 'Email', CaseArea__c = 'SIS', Status = 'Open',
                        ContactId = c.Id, AccountId = a.Id, ICCS_Product__c = 'BSP', ICCS_Country__c = 'France', ICCS_Currencies__c = 'USD', Type='aa');  
        lcs.add(cs4);

         Case cs5 = new Case(RecordTypeId = PortalsharingRTID, Subject = 'test', Origin = 'Email', CaseArea__c = 'SIS', Status = 'Open',
                        ContactId = c.Id, AccountId = a.Id, ICCS_Product__c = 'BSP', ICCS_Country__c = 'France', ICCS_Currencies__c = 'USD');  
        lcs.add(cs5);
        try{insert lcs;}catch(Exception e){exceptionRaised = true;}
        system.assertEquals(true,exceptionRaised);

        ID caseRecordType = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('ID Card Application');
        Case cs6 = new Case(RecordTypeId = caseRecordType, Subject = 'test', Origin = 'Email', CaseArea__c = 'ICCS – Assign Product', Status = 'Open',
                        ContactId = c.Id, AccountId = a.Id, ICCS_Product__c = 'BSP', ICCS_Country__c = 'France', ICCS_Currencies__c = 'USD', ID_Card_Status__c = IDCardUtil.CASECARDSTATUS_APPROVED);
        insert cs6;


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
        
        // Try to create an assignment case with the same product combination and test that it is not inserted
        try {
            Case cs2 = new Case(RecordTypeId = ICCS_RT_Id, Subject = 'test', Origin = 'Email', CaseArea__c = 'ICCS – Assign Product', Status = 'Open',
                        ContactId = c.Id, AccountId = a.Id, ICCS_Product__c = 'BSP', ICCS_Country__c = 'France', ICCS_Currencies__c = 'USD');
            insert cs2;
        } catch(Exception e) {}
        
        
        lstCases = [SELECT Id FROM Case WHERE RecordTypeId = :ICCS_RT_Id];
        //System.AssertEquals(2,lstCases.size()); // Check that the case was not inserted
        
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
        //system.assertEquals('USD', ba.CurrencyIsoCode);
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
    
    @istest static void testInsertSeda() {
    
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User testUser = New User(
            Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = testProfile.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test.username@test.com',
            License_Cost_Center__c = 'ISF005CH01'
        );
        insert testUser;
        
        Id RT_SEDA = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('SEDA');
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
        Case cas = new Case(recordtypeID = RT_SEDA,
                          Status = 'Assessment Performed',
                          Origin = 'asd',
                          Casearea__c = 'FDS - Create Authorized Signatories Package',
                          IFAP_Area__c = 'asda',
                          Country_concerned__c = 'Italy',
                          contactid = c.id,
                          AccountId = a.id,
                          CS_Contact_Result__c = 'Agent closed',
                          Demand_by_Email_Fax__c = DateTime.now()
        );
        insert cas;
        test.stopTest();
        
        Case resultCase = [Select Id, CS_Rep_Contact_Customer__c FROM Case WHERE Id = :cas.Id];
        System.assertEquals(UserInfo.getUserId(),resultCase.CS_Rep_Contact_Customer__c);
    }
    
    @istest static void testUpdateSeda() {
    
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User testUser = New User(
            Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = testProfile.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test.username@test.com',
            License_Cost_Center__c = 'ISF005CH01'
        );
        insert testUser;
        
        Id RT_SEDA = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('SEDA');
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(Name = 'France', ISO_Code__c = 'FR');
        insert country;
        
        Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('IATA_Airline');
        Account a = new Account(Name = 'Qatar Airways', Airline_designator__c = 'QR', ICCS_Membership_Status__c = 'Member', RecordTypeId = AirlineHQ_RT_Id);
        insert a;
        
        Id ContactStd_RT_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Contact').get('Standard_Contact');
        Contact c = new Contact(FirstName = 'Test', LastName = 'Contact', email = 'test@test.com', AccountId = a.Id, RecordTypeId = ContactStd_RT_Id);
        insert c;
        
        // Insert correctly a case
        Case cas = new Case(recordtypeID = RT_SEDA,
                          Status = 'Assessment Performed',
                          Origin = 'asd',
                          Casearea__c = 'FDS - Create Authorized Signatories Package',
                          IFAP_Area__c = 'asda',
                          Country_concerned__c = 'Italy',
                          contactid = c.id,
                          AccountId = a.id,
                          CS_Contact_Result__c = 'Agent closed',
                          Demand_by_Email_Fax__c = null
        );
        insert cas;
        
        Case resultCase = [Select Id, Demand_by_Email_Fax__c, CS_Rep_Contact_Customer__c FROM Case WHERE Id = :cas.Id];
        System.assertEquals(null,resultCase.CS_Rep_Contact_Customer__c);
        
        test.startTest();
        cas.Demand_by_Email_Fax__c = DateTime.now();
        update cas;
        test.stopTest();
        
        resultCase = [Select Id, CS_Rep_Contact_Customer__c FROM Case WHERE Id = :cas.Id];
        System.assertEquals(UserInfo.getUserId(),resultCase.CS_Rep_Contact_Customer__c);
    }

    @isTest static void trgICCS_ASP_CaseTest() {
      
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
        //System.AssertEquals(true,lstCases[0].Account.Ongoing_Request_for_Documents__c);
        
        // try to open a new ASP case on the same account, check that it is not inserted
        try {
            Case cs2 = new Case(RecordTypeId = RT_ICCS_ASP_Id, Subject = 'test', Origin = 'Email', CaseArea__c = 'FDS - Create Authorized Signatories Package', Status = 'Open',
                        ContactId = c.Id, AccountId = a.Id, Confirmation_Remarks__c = 'remarks', Eligibility_Documents_Checklist_approved__c = true);
            insert cs2;
        } catch(Exception e) {}
        
        lstCases = [SELECT Id FROM Case WHERE RecordTypeId = :RT_ICCS_ASP_Id];
        System.AssertEquals(1,lstCases.size()); // Check that the case was not inserted
        
        cs.ownerid = testUser.id;
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
        Case cas01 = new Case( ContactId = con.Id,
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
        );
        insert cas01;
        
        // MINORPOLICY
        Case cas02 = new Case( ContactId = con.Id,
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
        );
        insert cas02;
        
        // MINORPOLICY
        /*Case cas03 = new Case( ContactId = con.Id,
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
        );
        insert cas03;
        
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
        insert rei;*/
        
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

//*********************************************************************
    
    //Create County codes
    private static list<IATA_ISO_Country__c> CreateCountryCodes(){
      list<IATA_ISO_Country__c> lsISO = new list<IATA_ISO_Country__c>();
      lsISO.add(new IATA_ISO_Country__c(Name='South Africa', ISO_CODE__c='ZA', Region__c='Africa & Middle East'));
      lsISO.add(new IATA_ISO_Country__c(Name='United States', ISO_CODE__c='US', Region__c='Americas'));
      lsISO.add(new IATA_ISO_Country__c(Name='Japan', ISO_CODE__c='JP', Region__c='Asia & Pacific'));
      lsISO.add(new IATA_ISO_Country__c(Name='Hong Kong SAR, China', ISO_CODE__c='HK', Region__c='China & North Asia'));
      lsISO.add(new IATA_ISO_Country__c(Name='United Kingdom', ISO_CODE__c='GB', Region__c='Europe'));
      return lsISO;
    }
    
    //Create Account
    private static void CreateAccounts(list<IATA_ISO_Country__c> lsIso, integer iNumAccnt) {
      list<Account> listAccount = new list<Account>();
      for ( Integer i = 0; i < iNumAccnt; i++ ) {
        string sIndustry = 'Cargo Agent';
        string sType = 'IATA Cargo Agent';
        if(math.mod(i,2)==0)
          listAccount.add( new Account( Name = 'account' + i, AIMS_ID__c = String.ValueOf(i), Industry='Travel Agent', Type = 'IATA Passenger Sales Agent', Location_Type__c = 'HO', IATA_ISO_Country__c = lsIso[i].ID, Reason_for_creation__c = 'test') );
        else
          listAccount.add( new Account( Name = 'account' + i, AIMS_ID__c = String.ValueOf(i), Industry='Cargo Agent', Type = 'IATA Cargo Agent', Location_Type__c = 'HO', IATA_ISO_Country__c = lsIso[i].ID, Reason_for_creation__c = 'test'));
      }
      
      insert listAccount;
  //    return listAccount;
    }

    //Create FA Contacts
    private static list<Contact> CreateContacts(list<Account> lsAccnt) {
      list<Contact> listcontact = new list<Contact>();
      for(integer i=0; i<lsAccnt.size(); i++)
        listcontact.add( new Contact( FirstName = 'Name', LastName = 'TestName ' + i, AccountId = lsAccnt[i].Id, Financial_Assessment_Contact__c = true, Email='test.preprod@test.org') );
      return listcontact;
    }

    //Create Cases
    private static list<Case> CreateCases(list<Account> lsAccnt, map<id, id> mapCasesCreated, map<string, EmailTemplate__c> mapTemplates){
      list<Case> lsCase = new list<Case>();
      map<id, id> mapContact = new map<id,id>();
      
      set<id> setAccntId = new set<id>();
      
      for(Account ac:lsAccnt)
        setAccntId.add(ac.Id);
        
      for(Contact c: [select AccountId, Id from Contact where AccountId in:setAccntId])
        mapContact.put(c.AccountId, c.Id);
      
      for(Account accnt:lsAccnt){
        Case newCase = new Case();
        newCase.RecordTypeId = CASE_RECORDTYPE_FSM;
        newCase.Reporting_date__c = system.today();
        newCase.Subject = accnt.Country_ISO_Code__c + '-FS_UPDATE-Sales_Monitoring-2015-01'; 
        newCase.Description = 'Annual Financial Review 2015_';
        //newCase.ContactId = accnt.Contacts.isEmpty()?null:accnt.Contacts[0].Id;
        newCase.ContactId = mapContact.get(accnt.Id);
        newCase.AccountId = accnt.Id;
        newCase.Region__c = accnt.Region_formula__c;
        newCase.CCG_Participant__c = accnt.CCG_Participant__c;
        newCase.Current_held_FS_amount__c = 1000;
        newCase.Financial_Security_Amount_2__c = 2000;
        newCase.CurrencyISOCode = 'USD';
        EmailTemplate__c et = mapTemplates.get('FSM_' + accnt.Country_ISO_Code__c + '_English');
        
        system.debug(logginglevel.ERROR, 'DTULLO CaseKey: ' + 'FSM_' + accnt.Country_ISO_Code__c + '_English');
        system.debug(logginglevel.ERROR, 'DTULLO Template: ' + et);
        
        newCase.Reminder_EmailTemplate__c = et.id;
        if(mapCasesCreated != null)
          newCase.ParentId = mapCasesCreated.get(accnt.Id);
        newCase.Request_Expiry_Date__c = system.today()+30;
        lsCase.add(newCase);
      }
      return lsCase;
    }
    
    private static map<string, EmailTemplate__c> CreateTemplates(list<IATA_ISO_Country__c> lsISO){
      Recordtype recordtypeFSM = [Select Id, DeveloperName From RecordType where developerName like 'FSM' and sObjectType = 'EmailTemplate__c'];
      list<EmailTemplate__c> lsET = new list<EmailTemplate__c>();
      for(IATA_ISO_Country__c iso:lsISO){
        lsET.add(new EmailTemplate__c(RecordtypeId = recordtypeFSM.Id, Template_Language__c = 'English', IATA_ISO_Country__c = iso.Id, Agent_Type__c='All'));//, UniqueId__c = ('FSM_' + iso.ISO_CODE__c + '_English')));
      }
      
      insert lsET;
      map<string, EmailTemplate__c> oReturn = new map<string, EmailTemplate__c>();
      for(EmailTemplate__c et:[select UniqueId__c, Id from EmailTemplate__c]){
        oReturn.put(et.UniqueId__c, et);
      }
      
      return oReturn;
    }
    
    
    private static list<Case> CreateFSMCases(){
      list<IATA_ISO_Country__c> lsISO = CreateCountryCodes();
      insert lsISO;
      system.assert(lsISO.size()==5);
      
      map<string, EmailTemplate__c> mapTemplates = CreateTemplates(lsISO);
      system.assert(mapTemplates.size()==5);
      
      CreateAccounts(lsISO, 2); 
      
      list<Account> lsAccnt = [select Id, Name, Country_ISO_Code__c,Region_formula__c,CCG_Participant__c from Account];
      system.assert(lsAccnt.size()==2);
      
      insert CreateContacts(lsAccnt);
      system.assert([select id from Contact].size()==lsAccnt.size());
      
      list<Case> lsCaseFSM = CreateCases(lsAccnt, null, mapTemplates);
      insert lsCaseFSM;
      
      return lsCaseFSM;
    }
    
    private static Case getNCCase(Case FSMCase){
      Case NCCase = new Case();
      NCCase.RecordTypeId = NCRecordTypeID;
      NCCase.ContactId = FSMCase.ContactId;
      NCCase.Type_of_customer__c = FSMCase.IFAP_Agent_Type__c;
      NCCase.AccountId = FSMCase.AccountId;
      NCCase.ParentId = FSMCase.Id;
      NCCase.Origin = 'Internal Case';
      NCCase.CaseArea__c = 'Accreditation Process';
      NCCase.Reason1__c = 'FA/ FS Non-Compliance';
      NCCase.New_IFAP_Deadline_date__c = system.today().addDays(10);
      return NCCase;
    }
    
    
    private static list<Case> getFSMCases(){
      return [Select Id, Status, RecordTypeId, Account.Industry, FS_Letter_Sent__c, isClosed
                , FS_Deadline_Date__c, FS_Second_Deadline_Date__c, FS_Third_Deadline_Date__c
                , firstFSnonComplianceDate__c, secondFSnonComplianceDate__c, FS_third_non_compliance_date__c
                from Case c where RecordTypeId = :CASE_RECORDTYPE_FSM];
    }
    
    private static Date getMondayIfOnWeekend(date deaddate){
      Date RefDate = date.NewInstance(1900,1,7);
      integer dayOfWeek = math.mod(RefDate.daysBetween(deaddate),7);
      if(dayOfWeek==0)//Sunday
        return deaddate.addDays(1);
      else if(dayOfWeek==6)//Saturday
        return deaddate.addDays(2);
      else
        return deaddate;
    }
    
    private static list<Case> getInsertedNCCase(){return [select Id from Case where RecordTypeId=:NCRecordTypeID];}
    
    //First Non-compliance
    @istest static void FirstNonComplianceTest(){
      list<Case> lsCaseFSM = CreateFSMCases();
      system.assert(lsCaseFSM.size()>0);
      
      test.StartTest();
      
      list<Case> lsNCCase = new list<Case>();
      for(Case FSMCase: lsCaseFSM)
        lsNCCase.add(getNCCase(FSMCase));
      
      system.assert(lsNCCase.size() == lsCaseFSM.size());
      
      //Generate Exception (letter NOT sent)
      try{
        insert lsNCCase;
      }catch(Exception e){} 
      
      //No NCC Inserted: letter not sent (FS_Deadline_Date__c==null)
      system.assert(getInsertedNCCase().size()==0);
      
      //Letter sent (in the future) (Error)
      for(Case FSMCase: lsCaseFSM)
        FSMCase.FS_Deadline_Date__c = system.today().addDays(10);
      
      update lsCaseFSM;
      
      
      try{
        insert lsNCCase;
      }catch(exception e){}
      
      system.assert(getInsertedNCCase().size()==0);
      
      //Letter sent (in the past)
      for(Case FSMCase: lsCaseFSM)
        FSMCase.FS_Deadline_Date__c = system.today().addDays(-10);
      
      update lsCaseFSM;
      
      insert lsNCCase;
      
      //NCC Inserted. one per FSMCase
      system.assert(getInsertedNCCase().size()==lsCaseFSM.size());
      
      system.debug(Logginglevel.ERROR, 'DTULLO getInsertedNCCase().size() --> ' + getInsertedNCCase().size());
      system.debug(Logginglevel.ERROR, 'DTULLO lsCaseFSM().size() --> ' + lsCaseFSM.size());
      
      //loop through FSMCase and check dates
      for(Case FSMCase:getFSMCases()){
        system.debug(Logginglevel.ERROR, 'DTULLO FSMCase.Account.Industry --> ' + FSMCase.Account.Industry);
        system.assert(FSMCase.firstFSnonComplianceDate__c==system.today());
        if(FSMCase.Account.Industry==PAX){
          system.assert(FSMCase.FS_Second_Deadline_Date__c == getMondayIfOnWeekend(date.Today().addDays(31)));
        }
        
        if(FSMCase.Account.Industry==CARGO){
          system.assert(FSMCase.FS_Second_Deadline_Date__c == system.today().addDays(10));
        }
      }
      
      test.StopTest();
    }
    
    
    //Simulate 2nd non-compliance
    @istest static void SecondNonComplianceTest(){
      list<Case> lsCaseFSM = CreateFSMCases();
      system.assert(lsCaseFSM.size()>0);
      
      test.StartTest();
      
      //Letter sent (in the past)
      for(Case CaseFSM:lsCaseFSM)
        CaseFSM.FS_Deadline_Date__c = system.today().addDays(-10);
      
      update lsCaseFSM;
      
      list<Case> lsNCCase = new list<Case>();
      
      //Create First non-compliance (correctly)
      for(Case FSMCase: lsCaseFSM)
        lsNCCase.add(getNCCase(FSMCase));
      
      insert lsNCCase;
      
      system.assert(getInsertedNCCase().size() == lsCaseFSM.size());
      
      lsNCCase.clear();
      //Create Second non-compliance Generate Exception: 2nd deadline date > today
      for(Case FSMCase: lsCaseFSM)
        lsNCCase.add(getNCCase(FSMCase));

      try{
        insert lsNCCase;
      }catch(Exception e){} 
      
      system.assert(getInsertedNCCase().size()==lsCaseFSM.size());
      
      //Modify second deadline date (simulate to less than today)
      for(Case FSMCase: lsCaseFSM)
        FSMCase.FS_Second_Deadline_Date__c = system.today().addDays(-9);
      
      update lsCaseFSM;
      
      insert lsNCCase;
      
      //NCC Inserted. one per FSMCase
      system.assert(getInsertedNCCase().size()>0);
      system.assert(getInsertedNCCase().size()==(lsCaseFSM.size()*2));
      
      //loop through FSMCase and check dates
      for(Case FSMCase:getFSMCases()){
        system.assert(FSMCase.secondFSnonComplianceDate__c==system.today());
        if(FSMCase.Account.Industry==PAX){
          system.assert(FSMCase.FS_Third_Deadline_Date__c == getMondayIfOnWeekend(Date.newInstance(Date.today().addMonths(2).year(), Date.today().addMonths(2).month(), 1).addDays(-1)));
        }
        
        if(FSMCase.Account.Industry==CARGO){
          system.assert(FSMCase.FS_Third_Deadline_Date__c == system.today().addDays(10));
        }
      }
      
      test.StopTest();
    }
    
    //Simulate 3rd non-compliance
    @istest static void ThirdNonComplianceTest(){
      list<Case> lsCaseFSM = CreateFSMCases();
      system.assert(lsCaseFSM.size()>0);
      test.StartTest();
      
      //Letter sent (in the past)
      for(Case CaseFSM:lsCaseFSM)
        CaseFSM.FS_Deadline_Date__c = system.today().addDays(-10);
      
      update lsCaseFSM;
      
      list<Case> lsNCCase = new list<Case>();
      
      //Create First non-compliance (correctly)
      for(Case FSMCase: lsCaseFSM)
        lsNCCase.add(getNCCase(FSMCase));
      
      insert lsNCCase;
      
      system.assert(getInsertedNCCase().size() == lsCaseFSM.size());
      
      
      //Create Second non-compliance
      for(Case FSMCase: lsCaseFSM)
        FSMCase.FS_Second_Deadline_Date__c = system.today().addDays(-9);
      
      update lsCaseFSM;
      
      lsNCCase.clear();
      for(Case FSMCase: lsCaseFSM)
        lsNCCase.add(getNCCase(FSMCase));

      try{
        insert lsNCCase;
      }catch(Exception e){} 
      
      system.assert(getInsertedNCCase().size()==(lsCaseFSM.size()*2));
      
      //Create 3rd non-compliance. Generate error because 3rd deadline > today()
      lsNCCase.clear();
      for(Case FSMCase: lsCaseFSM)
        lsNCCase.add(getNCCase(FSMCase));
      
      try{
        insert lsNCCase;
      }catch(Exception e){} 
      
      system.assert(getInsertedNCCase().size()==(lsCaseFSM.size()*2));
      
      //Modify second deadline date (simulate to less than today)
      for(Case FSMCase: lsCaseFSM)
        FSMCase.FS_third_Deadline_Date__c = system.today().addDays(-8);
      
      update lsCaseFSM;
      
      insert lsNCCase;
      
      system.assert(getInsertedNCCase().size()>0);
      system.assert(getInsertedNCCase().size()==(lsCaseFSM.size()*3));
      
      //loop through FSMCase and check dates
      for(Case FSMCase:getFSMCases()){
        system.assert(FSMCase.FS_third_non_compliance_date__c==system.today());
      }
      
      test.StopTest();
    }

    //Simulate 4th non-compliance (error)
    @istest static void fourthNonComplianceTest(){
      list<Case> lsCaseFSM = CreateFSMCases();
      system.assert(lsCaseFSM.size()>0);
      
      test.StartTest();
      //simulate all 3 non-compliance are already sent
      for(Case FSMCase:lsCaseFSM){
        FSMCase.FS_Deadline_Date__c = system.today().addDays(-10);
        FSMCase.FS_Second_Deadline_Date__c = system.today().addDays(-9);
        FSMCase.FS_Third_Deadline_Date__c = system.today().addDays(-8);
        FSMCase.firstFSnonComplianceDate__c=system.today();
        FSMCase.secondFSnonComplianceDate__c=system.today();
        FSMCase.FS_third_non_compliance_date__c=system.today();
      }
      
      update lsCaseFSM;
      
      list<Case> lsNCCase = new list<Case>();
      
      //Create First non-compliance (correctly)
      for(Case FSMCase: lsCaseFSM)
        lsNCCase.add(getNCCase(FSMCase));
      
      try{
        insert lsNCCase;
      }catch(exception e){}
      
      system.assert(getInsertedNCCase().size() == 0);
      
      test.StopTest();
    }
    
    
    //Simulate 4th non-compliance (error)
    @istest static void CaseClosedTest(){
      Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User testUser = New User(
            Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = testProfile.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test.username@test.com',
            License_Cost_Center__c = 'ISF005CH01'
        );
        insert testUser;
      
      list<Case> lsCaseFSM = CreateFSMCases();
      system.assert(lsCaseFSM.size()>0);
      
      test.StartTest();
      //simulate all 3 non-compliance are already sent
      for(Case FSMCase:lsCaseFSM){
        FSMCase.FS_Deadline_Date__c = system.today().addDays(-10);
        system.debug(Logginglevel.ERROR, 'DTULLO Account ID --> ' + FSMCase.AccountId);
        system.debug(Logginglevel.ERROR, 'DTULLO Contact ID --> ' + FSMCase.ContactId);
        FSMCase.ownerid = testUser.id;
        FSMCase.status = 'Closed';
      }
      System.runAs(testUser) {
          update lsCaseFSM;
      }
      
      list<Case> lsNCCase = new list<Case>();
      
      //Create First non-compliance (correctly)
      for(Case FSMCase: lsCaseFSM)
        lsNCCase.add(getNCCase(FSMCase));
      
      try{
        insert lsNCCase;
      }catch(exception e){}
      
      system.assert(getInsertedNCCase().size() == 0);
      
      test.StopTest();
    }
    
    
    //First Non-compliance: Cargo with wrong New Ifap Deadline Date
    @istest static void FirstNonComplianceTestOnlyCargo(){
      list<Case> lsCaseFSM = CreateFSMCases();
      
      lsCaseFSM = getFSMCases();
      
      system.assert(lsCaseFSM.size()>0);
      
      test.StartTest();
      
      list<Case> lsNCCase = new list<Case>();
      for(Case FSMCase: lsCaseFSM)
        FSMCase.FS_Deadline_Date__c = system.today().addDays(-10);
      
      update lsCaseFSM;
      
      for(Case FSMCase: lsCaseFSM){
        if(FSMCase.Account.Industry == CARGO){
          lsNCCase.add(getNCCase(FSMCase));
        }
      }
      
      system.assert(lsNCCase.size()>0);
      
      for(case NCCase:lsNCCase){
        NCCase.New_IFAP_Deadline_date__c = null;
      }
      
      try{
        insert lsNCCase;
      }catch(exception e){}
      
      system.assert(getInsertedNCCase().size()==0);
      
      for(case NCCase:lsNCCase){
        NCCase.New_IFAP_Deadline_date__c = system.today().addDays(-5);
      }
      
      try{
        insert lsNCCase;
      }catch(exception e){}
      
      system.assert(getInsertedNCCase().size()==0);
      
      for(case NCCase:lsNCCase){
        NCCase.New_IFAP_Deadline_date__c = system.today().addDays(5);
      }
      
      insert lsNCCase;
      
      system.assert(getInsertedNCCase().size()==lsNCCase.size());
      
      //loop through FSMCase (cargo only) and check dates
      for(Case FSMCase:getFSMCases()){
        if(FSMCase.Account.Industry==CARGO){
          system.assert(FSMCase.FS_Second_Deadline_Date__c == system.today().addDays(5));
          system.assert(FSMCase.firstFSnonComplianceDate__c==system.today());
        }
      }
      
      //SECOND NON-COMPLIANCE
      for(Case FSMCase: lsCaseFSM){
        FSMCase.FS_Second_Deadline_Date__c = system.today().addDays(-9);
      }
      
      update lsCaseFSM;
      
      lsNCCase.clear();
      
      for(Case FSMCase: lsCaseFSM){
        if(FSMCase.Account.Industry == CARGO){
          lsNCCase.add(getNCCase(FSMCase));
        }
      }
      
      system.assert(lsNCCase.size()>0);
      
      for(case NCCase:lsNCCase){
        NCCase.New_IFAP_Deadline_date__c = null;
      }
      
      try{
        insert lsNCCase;
      }catch(exception e){}
      
      system.assert(getInsertedNCCase().size()==lsNCCase.size());
      
      for(case NCCase:lsNCCase){
        NCCase.New_IFAP_Deadline_date__c = system.today().addDays(-5);
      }
      
      try{
        insert lsNCCase;
      }catch(exception e){}
      
      system.assert(getInsertedNCCase().size()==lsNCCase.size());
      
      for(case NCCase:lsNCCase){
        NCCase.New_IFAP_Deadline_date__c = system.today().addDays(5);
      }
      
      insert lsNCCase;
      
      system.assert(getInsertedNCCase().size()==lsNCCase.size()*2);
      
      test.StopTest();
    }
    @istest static void TestUpdate(){
      Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User testUser = New User(
            Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = testProfile.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test.username@test.com',
            License_Cost_Center__c = 'ISF005CH01'
        );
        insert testUser;
      
      list<Case> lsCaseFSM = CreateFSMCases();
      system.assert(lsCaseFSM.size()>0);
      
      test.StartTest();
      //simulate all 3 non-compliance are already sent
      for(Case FSMCase:lsCaseFSM){
        FSMCase.FS_Deadline_Date__c = system.today().addDays(-10);
      }
      
      update lsCaseFSM;
      
      list<Case> lsNCCase = new list<Case>();
      
      for(Case FSMCase: lsCaseFSM)
        lsNCCase.add(getNCCase(FSMCase));
      
      try{
        insert lsNCCase;
      }catch(exception e){}
      
      system.assert(getInsertedNCCase().size() == lsCaseFSM.size());
      
      
      for(Case FSMCase:lsCaseFSM){
        FSMCase.FS_Deadline_Date__c = null;
      }
      
      update lsCaseFSM;
      
      try{
        update lsNCCase;
      }catch(exception e){}
      
      system.assert(getInsertedNCCase().size() == lsCaseFSM.size());
      
      
      for(Case FSMCase:lsCaseFSM){
        FSMCase.FS_Deadline_Date__c = system.today().addDays(-10);
        FSMCase.ownerid = testUser.id;
        FSMCase.Status = 'Closed';
      }
      System.runAs(testUser) {
          update lsCaseFSM;
      }
      
      try{
        update lsNCCase;
      }catch(exception e){}
      
      system.assert(getInsertedNCCase().size() == lsCaseFSM.size());
      
      
      test.StopTest();
    }
    
    @istest static void TestMultiFSM(){
      list<Case> lsCaseFSM = CreateFSMCases();
      system.assert(lsCaseFSM.size()>0);
      
      test.StartTest();
      
      for(Case FSMCase:lsCaseFSM){
        FSMCase.FS_Deadline_Date__c = system.today().addDays(-10);
      }
      
      update lsCaseFSM;
      
      list<Case> lsNCCase = new list<Case>();
      
      //Create First non-compliance (correctly)
      for(Case FSMCase: lsCaseFSM)
        lsNCCase.add(getNCCase(FSMCase));
        
      for(Case FSMCase: lsCaseFSM)
        lsNCCase.add(getNCCase(FSMCase));
      
      try{
        insert lsNCCase;
      }catch(exception e){}
      
      system.assert(getInsertedNCCase().size() == 0);
      
      test.StopTest();
    }

    @isTest static void DeleteBeforeTest() {
       
       ID hqrt =Schema.SObjectType.Account.RecordTypeInfosByName.get('Airline Headquarters').RecordTypeId ;
       ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('IATA_Financial_Review'); 
         
       IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(name = 'suisse',ISO_Code__c ='SS',AIMS_Area_Name__c='suisse',AIMS_Area_ID__c= '1' );
       insert isoCountry;
            
       Account a = new Account( name ='IFAP ACCT',
                    industry = 'pluto',
                    IATA_ISO_Country__c=isoCountry.id,
                                     recordtypeID = hqrt,
                                     IATACode__c ='1234567',
                                     Type = 'IATA Cargo Agent',
                                     billingCountry = 'ss',Location_Type__c = 'AO');
       insert a;
       
       Contact con =new contact(lastname = 'pluto' ,
                    firstname = 'test',
                    phone = '123',
                    accountid = a.id,
                    Financial_Assessment_Contact__c = true);
       insert con;
                   
       date dead = date.today().addDays(40);
       
       Case c = new Case(recordtypeID = IFAPcaseRecordTypeID,
                 Origin = 'asd',
                 IFAP_Area__c = 'asda',
                 Financial_Review_Type__c ='bla',
                 IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
                 Deadline_Date__c = dead,
                 contactid = con.id,
                 AccountId = a.id,
                 Assessment_Performed_Date__c = date.today(),
                 Financial_Review_Result__c = 'Satisfactory - No Action'                                
                 );
       
       insert c;
      
    Database.DeleteResult RESULT = DATABASE.DElEtE(c,false);
    
    string errorMessage = Result.getErrors()[0].message;
    
    system.assertEquals(errorMessage,'Deleting an IFAP case is not allowed' );      
      
   }

   /*@isTest static void testProcessISSTrigger() {

        IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(name = 'Canada',ISO_Code__c ='CA',AIMS_Area_ID__c= '1',CurrencyIsoCode = 'CAD' );
        insert isoCountry;
        ID IFAPcaseRecordTypeID = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('IATA Financial Review');

        // create test account
        Account account = new Account(IATACode__c = '1234567');    // 7 digits
        account.Name = 'Test account';
        account.BillingCity = 'Montreal';
        account.BillingCountry = 'Canada';
        account.BillingStreet = 'some street';
        account.Type = 'IATA Passenger Sales Agent';
        account.Location_Type__c = 'HO';

        insert account;

        Contact contact = new Contact();
        contact.FirstName = 'Dummy';
        contact.LastName = 'Contact';
        contact.Type_of_Contact__c = 'IFAP Contact';
        contact.AccountId = account.Id;
        contact.Email = 'some@email.org';
        contact.Financial_Assessment_Contact__c = true;
        insert contact;

        Case caseParent = new case();
        caseParent.ContactId = contact.Id;
        caseParent.AccountId = account.Id;
        caseParent.Subject = 'Test Case 1';
        caseParent.Description = 'Test Case 1';
        caseParent.RecordTypeId = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('IATA Financial Review');
        caseParent.Status = 'Agent Notified (Mail)';
        caseParent.Origin = 'Agent Financial Review Notification';
        caseParent.FA_Letter_Sent__c = false;
        caseParent.IFAP_Financial_Year__c = '2012';
        caseParent.Financial_Review_Type__c = 'Annual';
        caseParent.IFAP_Financial_Year__c = '2012';
        caseParent.Deadline_Date__c = Date.today().addDays(30);
        insert caseParent;


        /////////////////////////////////////////
        // create child case of type Process ISS

        Case caseChild = new case(); 
        caseChild.ContactId = contact.Id;
        caseChild.AccountId = account.Id;
        caseChild.Subject = 'Test Case 1';
        caseChild.Description = 'Test Case 1';
        caseChild.Subject = 'Test Case child';
        caseChild.Description = 'Test Case child';
        caseChild.ParentId = caseParent.Id;
        caseChild.RecordTypeId = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('SAAM');

        Case caseChild3 = new case(); 
        caseChild3.ContactId = contact.Id;
        caseChild3.AccountId = account.Id;
        caseChild3.Subject = 'Test Case 1';
        caseChild3.Description = 'Test Case 1';
        caseChild3.CaseArea__c = 'Accreditation Process';
        caseChild3.Reason1__c = 'FA/ FS Non-Compliance';
        caseChild3.Origin = 'Internal Case';
        caseChild3.ParentId = caseParent.Id;
        caseChild3.RecordTypeId = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('SAAM');
        
        Test.startTest();

        // should throw error
        try {
            insert caseChild;
            system.assert(false);
        } catch (Exception ex) {
            system.assert(true);
        }

        caseParent.FA_Letter_Sent__c = true;
        update caseParent;

        // should not throw error
        try {
            insert caseChild;
            system.assert(true);
        } catch (Exception ex) {
            system.assert(false);
        }

        caseParent.FS_Letter_Sent__c = false;
        caseParent.Status = 'Financial Security Requested';
        update caseParent;

        // should throw error
        try {
            update caseChild;
            system.assert(false);
        } catch (Exception ex) {
            system.assert(true);
        }

        caseParent.FS_Letter_Sent__c = true;
        caseParent.Status = 'Financial Security Requested';
        update caseParent;

        // should not throw error
        try {
            update caseChild;
            system.assert(true);
        } catch (Exception ex) {
            system.assert(false);
        }

        caseParent.Status = 'Financial Security Requested';   
        caseParent.firstFSnonComplianceDate__c = null;
        //caseParent.FS_Deadline_Date__c = date.newinstance(2017,06,30);
        update caseParent;
        try{
            insert caseChild3;
        }catch(Exception ex) {}
        Test.stopTest();
    }*/

    @isTest static void testProcessISSTrigger2() {

        IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(name = 'Canada',ISO_Code__c ='CA',AIMS_Area_ID__c= '1',CurrencyIsoCode = 'CAD' );
        insert isoCountry;
        ID IFAPcaseRecordTypeID = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('IATA Financial Review');

        // create test account
        Account account = new Account(IATACode__c = '1234567');    // 7 digits
        account.Name = 'Test account';
        account.BillingCity = 'Montreal';
        account.BillingCountry = 'Canada';
        account.BillingStreet = 'some street';
        account.Type = 'IATA Passenger Sales Agent';
        account.Location_Type__c = 'HO';

        insert account;

        Contact contact = new Contact();
        contact.FirstName = 'Dummy';
        contact.LastName = 'Contact';
        contact.Type_of_Contact__c = 'IFAP Contact';
        contact.AccountId = account.Id;
        contact.Email = 'some@email.org';
        contact.Financial_Assessment_Contact__c = true;
        insert contact;

        Case caseParent = new case();
        caseParent.ContactId = contact.Id;
        caseParent.AccountId = account.Id;
        caseParent.Subject = 'Test Case 1';
        caseParent.Description = 'Test Case 1';
        caseParent.RecordTypeId = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('IATA Financial Review');
        caseParent.Status = 'Agent Notified (Mail)';
        caseParent.Origin = 'Agent Financial Review Notification';
        caseParent.FA_Letter_Sent__c = false;
        caseParent.IFAP_Financial_Year__c = '2012';
        caseParent.Financial_Review_Type__c = 'Annual';
        caseParent.IFAP_Financial_Year__c = '2012';
        caseParent.Deadline_Date__c = Date.today().addDays(30);
        insert caseParent;


        /////////////////////////////////////////
        // create child case of type Process ISS

        Case caseChild = new case(); 
        caseChild.ContactId = contact.Id;
        caseChild.AccountId = account.Id;
        caseChild.Subject = 'Test Case 1';
        caseChild.Description = 'Test Case 1';
        caseChild.Subject = 'Test Case child';
        caseChild.Description = 'Test Case child';
        caseChild.ParentId = caseParent.Id;
        caseChild.RecordTypeId = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('SAAM');

        Case caseChild2 = new case(); 
        caseChild2.ContactId = contact.Id;
        caseChild2.AccountId = account.Id;
        caseChild2.Subject = 'Test Case 1';
        caseChild2.Description = 'Test Case 1';
        caseChild2.Status = 'Open';
        caseChild2.Reason1__c = 'FA/ FS Non-Compliance';
        caseChild2.ParentId = caseParent.Id;
        caseChild2.RecordTypeId = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('SAAM');

        Test.startTest();
        
        caseParent.Status = 'Agent to be Notified';
        update caseParent;
        try{
          insert caseChild2;
        }catch (Exception ex) {}
        Test.stopTest();
    }

    @isTest static void testProcessISSTrigger3() {

        IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(name = 'Canada',ISO_Code__c ='CA',AIMS_Area_ID__c= '1',CurrencyIsoCode = 'CAD' );
        insert isoCountry;
        ID IFAPcaseRecordTypeID = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('IATA Financial Review');

        // create test account
        Account account = new Account(IATACode__c = '1234567');    // 7 digits
        account.Name = 'Test account';
        account.BillingCity = 'Montreal';
        account.BillingCountry = 'Canada';
        account.BillingStreet = 'some street';
        account.Type = 'IATA Passenger Sales Agent';
        account.Location_Type__c = 'HO';

        insert account;

        Contact contact = new Contact();
        contact.FirstName = 'Dummy';
        contact.LastName = 'Contact';
        contact.Type_of_Contact__c = 'IFAP Contact';
        contact.AccountId = account.Id;
        contact.Email = 'some@email.org';
        contact.Financial_Assessment_Contact__c = true;
        insert contact;

        Case caseParent = new case();
        caseParent.ContactId = contact.Id;
        caseParent.AccountId = account.Id;
        caseParent.Subject = 'Test Case 1';
        caseParent.Description = 'Test Case 1';
        caseParent.RecordTypeId = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('IATA Financial Review');
        caseParent.Status = 'Agent Notified (Mail)';
        caseParent.Origin = 'Agent Financial Review Notification';
        caseParent.FA_Letter_Sent__c = false;
        caseParent.FS_Letter_Sent__c = true;
        caseParent.IFAP_Financial_Year__c = '2012';
        caseParent.Financial_Review_Type__c = 'Annual';
        caseParent.IFAP_Financial_Year__c = '2012';
        caseParent.firstFAnonComplianceDate__c = date.today();
        caseParent.firstFSnonComplianceDate__c = date.today();
        caseParent.secondFSnonComplianceDate__c = null;
        caseParent.Deadline_Date__c = date.today().adddays(31);
        caseParent.FA_Second_Deadline_Date__c = date.today().adddays(61);
        caseParent.FS_Deadline_Date__c = date.today().adddays(31);
        caseParent.FS_Second_Deadline_Date__c = date.today().adddays(61);
        insert caseParent;

        Case caseChild3 = new case(); 
        caseChild3.ContactId = contact.Id;
        caseChild3.AccountId = account.Id;
        caseChild3.Subject = 'Test Case 1';
        caseChild3.Description = 'Test Case 1';
        caseChild3.CaseArea__c = 'Accreditation Process';
        caseChild3.Reason1__c = 'FA/ FS Non-Compliance';
        caseChild3.Origin = 'Internal Case';
        caseChild3.ParentId = caseParent.Id;
        caseChild3.RecordTypeId = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('SAAM');
        
        Case caseChild = new case(); 
        caseChild.ContactId = contact.Id;
        caseChild.AccountId = account.Id;
        caseChild.Subject = 'Test Case 1';
        caseChild.Description = 'Test Case 1';
        caseChild.CaseArea__c = 'Accreditation Process';
        caseChild.Reason1__c = 'FA/ FS Non-Compliance';
        caseChild.Origin = 'Internal Case';
        caseChild.ParentId = caseParent.Id;
        caseChild.RecordTypeId = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('SAAM');

        Test.startTest();

        try{
            insert caseChild3;
        }catch(Exception ex) {}

        caseParent.firstFAnonComplianceDate__c = null;
        caseParent.Deadline_Date__c = null;
        caseParent.FA_Second_Deadline_Date__c = null;
        update caseParent;
        try{
            insert caseChild;
        }catch(Exception ex) {}

        Test.stopTest();
    }

    @isTest static void testProcessISSTrigger4() {

        IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(name = 'Canada',ISO_Code__c ='CA',AIMS_Area_ID__c= '1',CurrencyIsoCode = 'CAD' );
        insert isoCountry;
        ID IFAPcaseRecordTypeID = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('IATA Financial Review');

        // create test account
        Account account = new Account(IATACode__c = '1234567');    // 7 digits
        account.Name = 'Test account';
        account.BillingCity = 'Montreal';
        account.BillingCountry = 'Canada';
        account.BillingStreet = 'some street';
        account.Type = 'IATA Passenger Sales Agent';
        account.Location_Type__c = 'HO';

        insert account;

        Contact contact = new Contact();
        contact.FirstName = 'Dummy';
        contact.LastName = 'Contact';
        contact.Type_of_Contact__c = 'IFAP Contact';
        contact.AccountId = account.Id;
        contact.Email = 'some@email.org';
        contact.Financial_Assessment_Contact__c = true;
        insert contact;

        Case caseParent = new case();
        caseParent.ContactId = contact.Id;
        caseParent.AccountId = account.Id;
        caseParent.Subject = 'Test Case 1';
        caseParent.Description = 'Test Case 1';
        caseParent.RecordTypeId = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('IATA Financial Review');
        caseParent.Status = 'Financial Security Requested';
        caseParent.Origin = 'Agent Financial Review Notification';
        caseParent.FA_Letter_Sent__c = false;
        caseParent.FS_Letter_Sent__c = true;
        caseParent.IFAP_Financial_Year__c = '2012';
        caseParent.Financial_Review_Type__c = 'Annual';
        caseParent.IFAP_Financial_Year__c = '2012';
        caseParent.firstFSnonComplianceDate__c = date.today();
        caseParent.secondFSnonComplianceDate__c = null;
        caseParent.FS_Deadline_Date__c = date.newinstance(2017,03,20);
        caseParent.FS_Second_Deadline_Date__c = date.newinstance(2017,04,20);
        insert caseParent;

        Case caseChild3 = new case(); 
        caseChild3.ContactId = contact.Id;
        caseChild3.AccountId = account.Id;
        caseChild3.Subject = 'Test Case 1';
        caseChild3.Description = 'Test Case 1';
        caseChild3.CaseArea__c = 'Accreditation Process';
        caseChild3.Reason1__c = 'FA/ FS Non-Compliance';
        caseChild3.Origin = 'Internal Case';
        caseChild3.ParentId = caseParent.Id;
        caseChild3.RecordTypeId = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('SAAM');

        Test.startTest();

        try{
            insert caseChild3;
        }catch(Exception ex) {}

        Test.stopTest();
    }

    @isTest static void testProcessISSTrigger5() {

        IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(name = 'Canada',ISO_Code__c ='CA',AIMS_Area_ID__c= '1',CurrencyIsoCode = 'CAD' );
        insert isoCountry;
        ID IFAPcaseRecordTypeID = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('IATA Financial Review');

        // create test account
        Account account = new Account(IATACode__c = '1234567');    // 7 digits
        account.Name = 'Test account';
        account.BillingCity = 'Montreal';
        account.BillingCountry = 'Canada';
        account.BillingStreet = 'some street';
        account.Type = 'IATA Passenger Sales Agent';
        account.Location_Type__c = 'HO';
        insert account;

        Contact contact = new Contact();
        contact.FirstName = 'Dummy';
        contact.LastName = 'Contact';
        contact.Type_of_Contact__c = 'IFAP Contact';
        contact.AccountId = account.Id;
        contact.Email = 'some@email.org';
        contact.Financial_Assessment_Contact__c = true;
        insert contact;

        Case caseParent = new case();
        caseParent.ContactId = contact.Id;
        caseParent.AccountId = account.Id;
        caseParent.Subject = 'Test Case 1';
        caseParent.Description = 'Test Case 1';
        caseParent.RecordTypeId = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('IATA Financial Review');
        caseParent.Status = 'Financial Security';
        caseParent.Origin = 'Agent Financial Review Notification';
        caseParent.FA_Letter_Sent__c = false;
        caseParent.FS_Letter_Sent__c = true;
        caseParent.IFAP_Financial_Year__c = '2012';
        caseParent.Financial_Review_Type__c = 'Annual';
        caseParent.IFAP_Financial_Year__c = '2012';
        caseParent.firstFAnonComplianceDate__c = date.today();
        caseParent.secondFAnonComplianceDate__c = null;
        caseParent.Deadline_Date__c = date.newinstance(2020,06,29);
        caseParent.FA_Second_Deadline_Date__c = date.newinstance(2020,06,30);
        insert caseParent;

        Case caseChild3 = new case(); 
        caseChild3.ContactId = contact.Id;
        caseChild3.AccountId = account.Id;
        caseChild3.Subject = 'Test Case 1';
        caseChild3.Description = 'Test Case 1';
        caseChild3.CaseArea__c = 'Accreditation Process';
        caseChild3.Reason1__c = 'FA/ FS Non-Compliance';
        caseChild3.Origin = 'Internal Case';
        caseChild3.ParentId = caseParent.Id;
        caseChild3.RecordTypeId = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('SAAM');

        Case caseChild2 = new case(); 
        caseChild2.ContactId = contact.Id;
        caseChild2.AccountId = account.Id;
        caseChild2.Subject = 'Test Case 1';
        caseChild2.Description = 'Test Case 1';
        caseChild2.CaseArea__c = 'Accreditation Process';
        caseChild2.Reason1__c = 'FA/ FS Non-Compliance';
        caseChild2.Origin = 'Internal Case';
        caseChild2.ParentId = caseParent.Id;
        caseChild2.RecordTypeId = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('SAAM');

        Test.startTest();
        caseParent.Deadline_Date__c = date.newinstance(2017,04,29);
        caseParent.FA_Second_Deadline_Date__c = date.newinstance(2017,04,29);
        update caseParent;
        try{
            insert caseChild3;
        }catch(Exception ex) {}

        caseParent.secondFAnonComplianceDate__c = date.today();
        update caseParent;
        try{
            insert caseChild2;
        }catch(Exception ex) {}

        Test.stopTest();
    }
  }