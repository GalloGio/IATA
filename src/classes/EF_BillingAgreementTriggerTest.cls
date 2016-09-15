@isTest
private class EF_BillingAgreementTriggerTest {
	
	@testSetup 
    static void setup()
    {
    	EF_TestDataFactory.createBaseData();	
    }

	@isTest static void testDisallowBillingAgreementsThrowsAnError()
	{
		Contract contract = [select Id, AccountId, Account.Name from Contract where Account.Name = 'Test Account Client'];
		Account customer = [select Id, Name, EF_Allow_Billing_Agreements__c from Account where Name = 'Test Account customer'];
		Account client = [select Id, Name, EF_Allow_Billing_Agreements__c from Account where Name = 'Test Account client'];
		
		customer.EF_Allow_Billing_Agreements__c = 'Not Allowed';
		client.EF_Allow_Billing_Agreements__c = 'Not Allowed';
		update customer;
		update client;

		// Try to create a billing agreement, but expect that to fail
		EF_Billing_Agreement__c rel = new EF_Billing_Agreement__c();
		rel.Client__c = client.Id;
		rel.Airline__c = customer.Id;
		rel.Contract__c = contract.Id;
		rel.EF_Location_ID__c =  [select Id, Name from EF_Related_Records__c where Name='Main' limit 1].Id;

		List<EF_Billing_Agreement__c> baList = [select id from EF_Billing_Agreement__c];
		System.assertEquals(0, baList.size());
		Test.startTest();
		try
		{
		   insert rel;
		} catch(Exception e)
		{
			System.assert(e.getMessage().contains('The selected Client or Airline has E&F setting for "Allow Airline Billing Agreements" set to "Not Allowed". Please change this before creating a new Billing Agreement or select a different Account.'));
		}
		
		baList = [select id from EF_Billing_Agreement__c];
		System.assertEquals(0, baList.size());
		Test.stopTest();

	}

	@isTest static void EF_BillingAgreementTriggger_LocationInContract() {
		
		// query for test data
		
		Contract contract = [select Id, AccountId, Account.Name from Contract where Account.Name = 'Test Account Client'];
		Account customer = [select Id, Name from Account where Name = 'Test Account customer'];
		Account client = [select Id, Name from Account where Name = 'Test Account client'];
		
		// create billing agreement
		// location ID chosen exist in Location Currency in contract
		EF_Billing_Agreement__c rel = new EF_Billing_Agreement__c();
		rel.Client__c= client.Id;
		rel.Airline__c = customer.Id;
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
		rel.Client__c= client.Id;
		rel.Airline__c = customer.Id;
		rel.Contract__c = contract.Id;

		rel.EF_Location_ID__c =  [select Id, Name from EF_Related_Records__c where Name='Main' limit 1].Id;
		insert rel;

		EF_Billing_Agreement__c relDuplicated = new EF_Billing_Agreement__c();
		relDuplicated.Client__c= client.Id;
		relDuplicated.Airline__c = customer.Id;
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
		rel.Client__c= client.Id;
		rel.Airline__c = customer.Id;
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
		rel.Client__c= client.Id;
		rel.Airline__c = customer.Id;
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