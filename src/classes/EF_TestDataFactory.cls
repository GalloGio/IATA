public with sharing class EF_TestDataFactory
{
    
    public static void createBaseData()
    {
        createCustomSettings();

        List <EF_Related_Records__c> locationList = new List <EF_Related_Records__c> ();
        EF_Related_Records__c locationMain = new EF_Related_Records__c(name='Main',
            recordTypeId = Schema.SObjectType.EF_Related_Records__c.getRecordTypeInfosByName().get('Location').getRecordTypeId() 
            );
        locationList.add(locationMain);
        for(Integer i=1; i<5; i++)
        {
            EF_Related_Records__c location = new EF_Related_Records__c (name=String.valueOf(i),
                recordTypeId = Schema.SObjectType.EF_Related_Records__c.getRecordTypeInfosByName().get('Location').getRecordTypeId() 
                );
            locationList.add(location);
        }

        insert locationList;

        // create iso country 
        IATA_ISO_Country__c iso_country = new IATA_ISO_Country__c (
            name='United States',
            ISO_Code__c ='US',
            ISO_Code_Numeric__c=1,
            currencyIsoCode = 'USD');
        insert iso_country;

        //create account 
        Account client = new Account(
            Name='Test Account client',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Standard Account').getRecordTypeId(),
            Sector__c = 'IATA Supplier',
            Category__c = 'ANSP',
            EF_type__c = 'E&F Client',
            EF_Status__c = 'Active',
            EF_SubStatus__c='None',
            EF_Effective_Date__c = Date.today(),
            IATA_ISO_Country__c = iso_country.Id,
            Reason_for_creation__c = 'new client needed'
            );
        
        insert client;

        //create account 
        Account customer = new Account(
            Name='Test Account customer',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Standard Account').getRecordTypeId(),
            Sector__c = 'IATA Supplier',
            Category__c = 'ANSP',
            EF_type__c = 'E&F Operator',
            EF_Status__c = 'Active',
            EF_SubStatus__c='None',
            EF_Effective_Date__c = Date.today(),
            IATA_ISO_Country__c = iso_country.Id,
            Reason_for_creation__c = 'new customer needed'
            );
        
        insert customer;

        //create contract
        Contract contract = new Contract (
            accountId= client.Id,
            CCF_Number__c= '1',
            Budget_Section__c='aaaa',
            CCF_Amount__c=250000,
            ContractTerm=12,
            EF_Allow_Billing_Agreements__c = 'Allowed',
            EF_Billing_Currency__c = 'USD;QAR',
            EF_Payment_Currency__c = 'USD;QAR',
            EF_Data_Currency__c = 'USD;QAR',
            RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('E&F Client Agreement').getRecordTypeId(),
            StartDate= Date.today(),
            Type__c='Revenue',
            EF_Status__c='Active'
            );
        insert contract;

        //create location currencies
        EF_Location_Currency__c locCurrency = new EF_Location_Currency__c (
            Contract__c = contract.Id,
            Location_ID__c = [select Id, Name from EF_Related_Records__c where Name='Main' limit 1].Id,
            EF_Billing_Currency__c='QAR'
            );
        insert locCurrency;
        
        EF_Approve_Fields__c approvalBillingAgreementFields = new EF_Approve_Fields__c(Name='BillingAgreement', Billing_Agreement_Fields__c='Airline__c,Billing_Currency__c,EF_Location_ID__c,Payment_Currency__c,Payment_Method__c');
        insert approvalBillingAgreementFields;
    }
    
    
     public static void createBaseDataWithoutLocCurr()
    {
        createCustomSettings();

        List <EF_Related_Records__c> locationList = new List <EF_Related_Records__c> ();
        EF_Related_Records__c locationMain = new EF_Related_Records__c(name='Main',
            recordTypeId = Schema.SObjectType.EF_Related_Records__c.getRecordTypeInfosByName().get('Location').getRecordTypeId() 
            );
        locationList.add(locationMain);
        for(Integer i=1; i<5; i++)
        {
            EF_Related_Records__c location = new EF_Related_Records__c (name=String.valueOf(i),
                recordTypeId = Schema.SObjectType.EF_Related_Records__c.getRecordTypeInfosByName().get('Location').getRecordTypeId() 
                );
            locationList.add(location);
        }

        insert locationList;

        // create iso country 
        IATA_ISO_Country__c iso_country = new IATA_ISO_Country__c (
            name='United States',
            ISO_Code__c ='US',
            ISO_Code_Numeric__c=1,
            currencyIsoCode = 'USD');
        insert iso_country;

        //create account 
        Account client2 = new Account(
            Name='Test Account client2',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Standard Account').getRecordTypeId(),
            Sector__c = 'IATA Supplier',
            Category__c = 'ANSP',
            EF_type__c = 'E&F Client',
            EF_Status__c = 'Active',
            EF_SubStatus__c='None',
            EF_Effective_Date__c = Date.today(),
            IATA_ISO_Country__c = iso_country.Id,
            Reason_for_creation__c = 'new client needed'
            );
        
        insert client2;

        //create account 
        Account customer2 = new Account(
            Name='Test Account customer2',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Standard Account').getRecordTypeId(),
            Sector__c = 'IATA Supplier',
            Category__c = 'ANSP',
            EF_type__c = 'E&F Operator',
            EF_Status__c = 'Active',
            EF_SubStatus__c='None',
            EF_Effective_Date__c = Date.today(),
            IATA_ISO_Country__c = iso_country.Id,
            Reason_for_creation__c = 'new customer needed'
            );
        
        insert customer2;

        //create contract
        Contract contract2 = new Contract (
            accountId= client2.Id,
            CCF_Number__c= '1',
            Budget_Section__c='aaaa',
            CCF_Amount__c=250000,
            ContractTerm=12,
            EF_Allow_Billing_Agreements__c = 'Allowed',
            EF_Payment_Currency__c = 'USD;QAR',
            EF_Data_Currency__c = 'USD;QAR',
            RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('E&F Client Agreement').getRecordTypeId(),
            StartDate= Date.today(),
            Type__c='Revenue',
            EF_Status__c='Active'
            );
        insert contract2;

    }

    public static void createCustomSettings()
    {
        EF_Approve_Fields__c appr1 = new EF_Approve_Fields__c();
        appr1.Billing_Agreement_Fields__c = 'Airline__c,Billing_Currency__c,EF_Location_ID__c,Payment_Currency__c,Payment_Method__c,Location_Code__c';
        appr1.Name = 'BillingAgreement';
        EF_Approve_Fields__c appr2 = new EF_Approve_Fields__c();
        appr2.Contract_Fields__c = 'EF_Payment_Terms__c,EF_Billing_Frequency__c,EF_Admin_Fee__c,CCF_Number__c,EF_Group_Code__c';
        appr2.Name = 'Contract';
        List<EF_Approve_Fields__c> approvals = new List<EF_Approve_Fields__c>{appr1, appr2};
        insert approvals;
    }

    public static User getEfStaffUser(String efUserRole)
    {
        User manager = [select id from User limit 1].get(0);
        Id pr = [select id from Profile where name = 'E&F staff' limit 1].Id;
        System.debug('@@@@ '+pr);
        User u1 = new User(FirstName='Test1 User',Division='UnitTest',Manager=manager,
                           EF_Billing_Agreement_Approver__c=manager.Id,
                           EF_Contract_Approver__c=manager.Id, 
                           EF_User_Role__c=efUserRole,License_Cost_Center__c='AAA000AA00',
                           Username='efUnit@test.ch', LastName='Test1', 
                           Email='test1@iata.org', Alias='Test1', CommunityNickname='Test1', 
                           TimeZoneSidKey='Europe/Brussels', LocaleSidKey='en_US', 
                           EmailEncodingKey='UTF-8', ProfileId=pr, LanguageLocaleKey='en_US');
        insert u1;
        return u1;
    }

}