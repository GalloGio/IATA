@isTest
private class EF_LocationCurrencyTriggerTest {

    @testSetup 
    static void setup() {

        // set test data
        // 
        // Create EF Related records with record type Location
        List <EF_Related_Records__c> locationList = new List <EF_Related_Records__c> ();

        EF_Related_Records__c locationMain = new EF_Related_Records__c (
            name='Main',
            recordTypeId = Schema.SObjectType.EF_Related_Records__c.getRecordTypeInfosByName().get('Location').getRecordTypeId() 
            );

        locationList.add(locationMain);

        for(Integer i=1; i<5; i++){
            EF_Related_Records__c location = new EF_Related_Records__c (
                name = 'Main_' + String.valueOf(i),
                recordTypeId = Schema.SObjectType.EF_Related_Records__c.getRecordTypeInfosByName().get('Location').getRecordTypeId() 
            );
            locationList.add(location);
        }

        insert locationList;        

        // create iso country 
        IATA_ISO_Country__c iso_country = new IATA_ISO_Country__c (
            name = 'United States',
            ISO_Code__c ='US',
            ISO_Code_Numeric__c = 1,
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
            EF_Effective_Date__c = Date.today(),
            IATA_ISO_Country__c = iso_country.Id,
            Reason_for_creation__c = 'new client needed'
            );
        
        insert client;
                
        //create contract
        Contract contract = new Contract (
        	accountId= client.Id,
        	CCF_Number__c= '1',
        	Budget_Section__c='aaaa',
        	CCF_Amount__c=250000,
        	ContractTerm=12,
            RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('E&F Client Agreement').getRecordTypeId(),
        	StartDate= Date.today(),
        	Type__c='Revenue',
            EF_Status__c='Active'
        	);
        
        insert contract;
    }

    @isTest static void EF_LocationCurrencyTrigger_AddFirstLocationCurrency() {
        Contract ct = [select Id, AccountId, Account.Name, EF_Billing_Currency__c from Contract where Account.Name = 'Test Account Client'];
        
        // Add one billing currency to the contract.
        EF_Location_Currency__c efl = new EF_Location_Currency__c(
                EF_Billing_Currency__c = 'USD',
                Contract__c = ct.Id,
                Location_ID__c = [select Id, Name from EF_Related_Records__c where Name = 'Main' limit 1].Id
            );

        Test.startTest();
            insert efl;
        Test.stopTest();
        
        Contract ctAfter = [select Id, AccountId, Account.Name, EF_Billing_Currency__c from Contract where Account.Name = 'Test Account Client'];               
        
        System.assertEquals(ctAfter.EF_Billing_Currency__c, 'USD');                    
    }

    @isTest static void EF_LocationCurrencyTrigger_AddSecondLocationCurrency() {    
        Contract ct = [select Id, AccountId, Account.Name, EF_Billing_Currency__c from Contract where Account.Name = 'Test Account Client'];
        
        // Add two billing currency to the contract.
        EF_Location_Currency__c efl_1 = new EF_Location_Currency__c(
                EF_Billing_Currency__c = 'EUR',
                Contract__c = ct.Id,
                Location_ID__c = [select Id, Name from EF_Related_Records__c where Name = 'Main_1' limit 1].Id
            );
        
        EF_Location_Currency__c efl_2 = new EF_Location_Currency__c(
                EF_Billing_Currency__c = 'USD',
                Contract__c = ct.Id,
                Location_ID__c = [select Id, Name from EF_Related_Records__c where Name = 'Main_2' limit 1].Id
            );
        
        Test.startTest();
            insert efl_1;
            insert efl_2;
        Test.stopTest();        
        
        Contract ctAfter = [select Id, AccountId, Account.Name, EF_Billing_Currency__c from Contract where Account.Name = 'Test Account Client'];               
                
        System.assertEquals(ctAfter.EF_Billing_Currency__c, 'USD;EUR');
    }
    
    @isTest static void EF_LocationCurrencyTrigger_AddRepeatedLocationCurrency() {    
        Contract ct = [select Id, AccountId, Account.Name, EF_Billing_Currency__c from Contract where Account.Name = 'Test Account Client'];
        
        // Add a repeated billing currency to the contract.
        EF_Location_Currency__c efl_1 = new EF_Location_Currency__c(
                EF_Billing_Currency__c = 'USD',
                Contract__c = ct.Id,
                Location_ID__c = [select Id, Name from EF_Related_Records__c where Name = 'Main_3' limit 1].Id
            );
        
        EF_Location_Currency__c efl_2 = new EF_Location_Currency__c(
                EF_Billing_Currency__c = 'USD',
                Contract__c = ct.Id,
                Location_ID__c = [select Id, Name from EF_Related_Records__c where Name = 'Main_4' limit 1].Id
            );
        
        Test.startTest();
            insert efl_1;
            insert efl_2;
        Test.stopTest();
               
        Contract ctAfter = [select Id, AccountId, Account.Name, EF_Billing_Currency__c from Contract where Account.Name = 'Test Account Client'];               
        
        System.assertEquals(ctAfter.EF_Billing_Currency__c, 'USD');
    }

    @isTest static void EF_LocationCurrencyTrigger_AddRepeatedLocation() {    
        Contract ct = [select Id, AccountId, Account.Name, EF_Billing_Currency__c from Contract where Account.Name = 'Test Account Client'];
        
        // Add a repeated location.
        EF_Location_Currency__c efl_1 = new EF_Location_Currency__c(
                EF_Billing_Currency__c = 'USD',
                Contract__c = ct.Id,
                Location_ID__c = [select Id, Name from EF_Related_Records__c where Name = 'Main' limit 1].Id
            );
        
        EF_Location_Currency__c efl_2 = new EF_Location_Currency__c(
                EF_Billing_Currency__c = 'EUR',
                Contract__c = ct.Id,
                Location_ID__c = [select Id, Name from EF_Related_Records__c where Name = 'Main' limit 1].Id
            );
        
        try {
            Test.startTest();
                insert efl_1;
                insert efl_2;
            Test.stopTest();
        } catch (System.DmlException e) {
            System.assertEquals(e.getMessage(), 'Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, The location chosen has already been added to the contract.: [Location_ID__c]');
        }
    }

    @isTest static void EF_LocationCurrencyTrigger_DeleteLocationCurrency() {    
        Contract ct = [select Id, AccountId, Account.Name, EF_Billing_Currency__c from Contract where Account.Name = 'Test Account Client'];
        
        // Add a repeated location.
        EF_Location_Currency__c efl_1 = new EF_Location_Currency__c(
                EF_Billing_Currency__c = 'USD',
                Contract__c = ct.Id,
                Location_ID__c = [select Id, Name from EF_Related_Records__c where Name = 'Main' limit 1].Id
            );
        
        EF_Location_Currency__c efl_2 = new EF_Location_Currency__c(
                EF_Billing_Currency__c = 'EUR',
                Contract__c = ct.Id,
                Location_ID__c = [select Id, Name from EF_Related_Records__c where Name = 'Main_1' limit 1].Id
            );
        
        Test.startTest();
            insert efl_1;
            insert efl_2;
            delete efl_2;
        Test.stopTest();
        
        Contract ctAfter = [select Id, AccountId, Account.Name, EF_Billing_Currency__c from Contract where Account.Name = 'Test Account Client'];               
        
        System.assertEquals(ctAfter.EF_Billing_Currency__c, 'USD');
    }   
    
    @isTest static void EF_LocationCurrencyTrigger_DeleteAllLocationCurrency() {    
        Contract ct = [select Id, AccountId, Account.Name, EF_Billing_Currency__c from Contract where Account.Name = 'Test Account Client'];
        
        // Add a repeated location.
        EF_Location_Currency__c efl_1 = new EF_Location_Currency__c(
                EF_Billing_Currency__c = 'USD',
                Contract__c = ct.Id,
                Location_ID__c = [select Id, Name from EF_Related_Records__c where Name = 'Main' limit 1].Id
            );
        
        EF_Location_Currency__c efl_2 = new EF_Location_Currency__c(
                EF_Billing_Currency__c = 'EUR',
                Contract__c = ct.Id,
                Location_ID__c = [select Id, Name from EF_Related_Records__c where Name = 'Main_1' limit 1].Id
            );

        EF_Location_Currency__c efl_3 = new EF_Location_Currency__c(
                EF_Billing_Currency__c = 'GBP',
                Contract__c = ct.Id,
                Location_ID__c = [select Id, Name from EF_Related_Records__c where Name = 'Main_2' limit 1].Id
            );
        
        
        Test.startTest();
            insert efl_1;
            insert efl_2;
        	insert efl_3;
        
            delete efl_3;
        	delete efl_2;
        	delete efl_1;
        Test.stopTest();
        
        Contract ctAfter = [select Id, AccountId, Account.Name, EF_Billing_Currency__c from Contract where Account.Name = 'Test Account Client'];               
        
        System.assertEquals(ctAfter.EF_Billing_Currency__c, null);
    }   

    @isTest static void EF_LocationCurrencyTrigger_DeleteAllDiffOrderLocationCurrency() {    
        Contract ct = [select Id, AccountId, Account.Name, EF_Billing_Currency__c from Contract where Account.Name = 'Test Account Client'];
        
        // Add a repeated location.
        EF_Location_Currency__c efl_1 = new EF_Location_Currency__c(
                EF_Billing_Currency__c = 'USD',
                Contract__c = ct.Id,
                Location_ID__c = [select Id, Name from EF_Related_Records__c where Name = 'Main' limit 1].Id
            );
        
        EF_Location_Currency__c efl_2 = new EF_Location_Currency__c(
                EF_Billing_Currency__c = 'EUR',
                Contract__c = ct.Id,
                Location_ID__c = [select Id, Name from EF_Related_Records__c where Name = 'Main_1' limit 1].Id
            );

        EF_Location_Currency__c efl_3 = new EF_Location_Currency__c(
                EF_Billing_Currency__c = 'GBP',
                Contract__c = ct.Id,
                Location_ID__c = [select Id, Name from EF_Related_Records__c where Name = 'Main_2' limit 1].Id
            );
        
        
        Test.startTest();
            insert efl_1;
            insert efl_2;
        	insert efl_3;
        
        	delete efl_1;
            delete efl_3;
        	delete efl_2;        	
        Test.stopTest();
                       
        Contract ctAfter = [select Id, AccountId, Account.Name, EF_Billing_Currency__c from Contract where Account.Name = 'Test Account Client'];               
        
        System.assertEquals(ctAfter.EF_Billing_Currency__c, null);
    }     
        
    @isTest static void EF_LocationCurrencyTrigger_UpdateLocationCurrency() {    
        Contract ct = [select Id, AccountId, Account.Name, EF_Billing_Currency__c from Contract where Account.Name = 'Test Account Client'];
        
        // Add a repeated location.
        EF_Location_Currency__c efl_1 = new EF_Location_Currency__c(
                EF_Billing_Currency__c = 'USD',
                Contract__c = ct.Id,
                Location_ID__c = [select Id, Name from EF_Related_Records__c where Name = 'Main' limit 1].Id
            );
        
        EF_Location_Currency__c efl_2 = new EF_Location_Currency__c(
                EF_Billing_Currency__c = 'EUR',
                Contract__c = ct.Id,
                Location_ID__c = [select Id, Name from EF_Related_Records__c where Name = 'Main_1' limit 1].Id
            );

        EF_Location_Currency__c efl_3 = new EF_Location_Currency__c(
                EF_Billing_Currency__c = 'GBP',
                Contract__c = ct.Id,
                Location_ID__c = [select Id, Name from EF_Related_Records__c where Name = 'Main_2' limit 1].Id
            );        

        Test.startTest();
            insert efl_1;
            insert efl_2;
            insert efl_3;
        
            efl_2.EF_Billing_Currency__c = 'GBP';
        
            update efl_2;
        Test.stopTest();
        
        Contract ctAfter = [select Id, AccountId, Account.Name, EF_Billing_Currency__c from Contract where Account.Name = 'Test Account Client'];               
        
        System.assertEquals(ctAfter.EF_Billing_Currency__c, 'USD;GBP');
    }       
}