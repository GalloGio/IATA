@isTest
private class EF_BillingAgreementTriggerTest {
	
	@testSetup 
    static void setup() {

    	// set test data
    	
    	// Create EF Related records with record type Location
    	List <EF_Related_Records__c> locationList = new List <EF_Related_Records__c> ();

    	EF_Related_Records__c locationMain = new EF_Related_Records__c (
    		name='Main',
    		recordTypeId = Schema.SObjectType.EF_Related_Records__c.getRecordTypeInfosByName().get('Location').getRecordTypeId() 
    		);

    	locationList.add(locationMain);

    	for(Integer i=1; i<5; i++){
    		EF_Related_Records__c location = new EF_Related_Records__c (
    		name=String.valueOf(i),
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
        	StartDate= Date.today(),
        	Type__c='Revenue'
        	);
        insert contract;

        //create location currencies
        EF_Location_Currency__c locCurrency = new EF_Location_Currency__c (
        	Contract__c = contract.Id,
        	Location_ID__c = [select Id, Name from EF_Related_Records__c where Name='Main' limit 1].Id,
        	EF_Billing_Currency__c='QAR'
        	);
        insert locCurrency;
               
    }
	
	@isTest static void EF_BillingAgreementTriggger_LocationInContract() {
		
		// query for test data
		
		Contract contract = [select Id, AccountId, Account.Name from Contract where Account.Name = 'Test Account Client'];
		Account customer = [select Id, Name from Account where Name = 'Test Account customer'];
		Account client = [select Id, Name from Account where Name = 'Test Account client'];
		
		// create billing agreement
		// location ID chosen exist in Location Currency in contract
		EF_Billing_Agreement__c rel = new EF_Billing_Agreement__c();
		rel.Billed_Account__c= client.Id;
		rel.Billing_Account__c = customer.Id;
		rel.Contract__c = contract.Id;
		rel.EF_Location_ID__c =  [select Id, Name from EF_Related_Records__c where Name='Main' limit 1].Id;

		Test.startTest();
		   insert rel;
		Test.stopTest();

		//check update of currency was made
		EF_Billing_Agreement__c baAfter =[ select id, Billing_Currency__c from EF_Billing_Agreement__c where id =: rel.Id limit 1];

		System.assertEquals(baAfter.Billing_Currency__c, 'QAR');
		
	}

	@isTest static void EF_BillingAgreementTrigger_LocationContractDuplicated() {
		
		// query for test data
		
		Contract contract = [select Id, AccountId, Account.Name from Contract where Account.Name = 'Test Account Client'];
		Account customer = [select Id, Name from Account where Name = 'Test Account customer'];
		Account client = [select Id, Name from Account where Name = 'Test Account client'];
		
		// create billing agreement
		// location ID chosen exist in Location Currency in contract
		EF_Billing_Agreement__c rel = new EF_Billing_Agreement__c();
		rel.Billed_Account__c= client.Id;
		rel.Billing_Account__c = customer.Id;
		rel.Contract__c = contract.Id;
		rel.EF_Location_ID__c =  [select Id, Name from EF_Related_Records__c where Name='Main' limit 1].Id;
		insert rel;

		EF_Billing_Agreement__c relDuplicated = new EF_Billing_Agreement__c();
		relDuplicated.Billed_Account__c= client.Id;
		relDuplicated.Billing_Account__c = customer.Id;
		relDuplicated.Contract__c = contract.Id;
		relDuplicated.EF_Location_ID__c =  [select Id, Name from EF_Related_Records__c where Name='Main' limit 1].Id;

		Test.startTest();
		  try{
		   	insert relDuplicated;
		    System.assert(false,'A test that should have resulted in an exception did not.');
		   }catch(Exception e){
		   	System.assert(e instanceof DMLException, 'The test ended in an exception other than DMLException' + e.getTypeName());
		  
		   }	
		Test.stopTest();

		
		
	}
	
	@isTest static void EF_BillingAgreementTrigger_LocationNOTInContract() {

		// query for test data
		
		Contract contract = [select Id, AccountId, Account.Name from Contract where Account.Name = 'Test Account Client'];
		Account customer = [select Id, Name from Account where Name = 'Test Account customer'];
		Account client = [select Id, Name from Account where Name = 'Test Account client'];
		
		// create billing agreement
		// location ID chosen exist in Location Currency in contract
		EF_Billing_Agreement__c rel = new EF_Billing_Agreement__c();
		rel.Billed_Account__c= client.Id;
		rel.Billing_Account__c = customer.Id;
		rel.Contract__c = contract.Id;
		rel.EF_Location_ID__c =  [select Id, Name from EF_Related_Records__c where Name='1' limit 1].Id;

		Test.startTest();
		   try{
		   	insert rel;
		    System.assert(false,'A test that should have resulted in an exception did not.');
		   }catch(Exception e){
		   	System.assert(e instanceof DMLException, 'The test ended in an exception other than DMLException' + e.getTypeName());
		  
		   }	
		Test.stopTest();

				
		
	}

	@isTest static void EF_BillingAgreementTrigger_ContractWithNoLocCurrencies() {

		// query for test data
		
		Account customer = [select Id, Name from Account where Name = 'Test Account customer'];
		Account client = [select Id, Name from Account where Name = 'Test Account client'];

		// create contract without location currencies
		Contract contract2 = new Contract (
        	accountId= client.Id,
        	CCF_Number__c= '2',
        	Budget_Section__c='aaaa',
        	CCF_Amount__c=250000,
        	ContractTerm=12,
        	StartDate= Date.today(),
        	Type__c='Revenue'
        	);
        insert contract2;
		
		// create billing agreement
		// location ID chosen exist in Location Currency in contract
		EF_Billing_Agreement__c rel = new EF_Billing_Agreement__c();
		rel.Billed_Account__c= client.Id;
		rel.Billing_Account__c = customer.Id;
		rel.Contract__c = contract2.Id;
		rel.EF_Location_ID__c =  [select Id, Name from EF_Related_Records__c where Name='2' limit 1].Id;

		Test.startTest();
		   try{
		   	insert rel;
		    System.assert(false,'A test that should have resulted in an exception did not.');
		   }catch(Exception e){
		   	System.assert(e instanceof DMLException, 'The test ended in an exception other than DMLException' + e.getTypeName());
		  
		   }	
		Test.stopTest();

				
		
	}

	@isTest static void checkCurrencyFromContractTest() {
		
		
	}
}