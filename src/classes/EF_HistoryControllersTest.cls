@isTest
private with sharing class EF_HistoryControllersTest
{
	@isTest static void testBaHistoryController()
	{
		System.runAs(EF_TestDataFactory.getEfProfileAndRole(1, 2))
		{
			EF_TestDataFactory.createCustomSettings();
			EF_TestDataFactory.skipContractCreationValidationRule();
			EF_TestDataFactory.createBaseDataWithAllowedWithApproval();

			Contract contract = [select Id, AccountId, Account.Name, EF_Allow_Billing_Agreements__c from Contract where Account.Name = 'Test Account Client'];
			Account customer = [select Id, Name from Account where Name = 'Test Account customer'];
			Account client = [select Id, Name from Account where Name = 'Test Account client'];

			EF_Billing_Agreement__c ba = new EF_Billing_Agreement__c();
			ba.Client__c = client.Id;
			ba.Airline__c = customer.Id;
			ba.Contract__c = contract.Id;
			ba.EF_Location_ID__c =  [select Id, Name from EF_Related_Records__c where Name='Main' limit 1].Id;
			insert ba;

			ApexPages.StandardController sc = new ApexPages.StandardController(ba);
			EF_BaHistoryController ctrl = new EF_BaHistoryController(sc);

					PageReference pageRef = Page.EF_BaHistoryPage;
					Test.setCurrentPage(pageRef);

				Test.startTest();
					ba.EF_Comments__c = 'Testing 123';
					update ba;
					EF_Billing_Agreement__c baUpdated = [select id, EF_History__c from EF_Billing_Agreement__c where Id = :ba.Id limit 1];
					System.assert(baUpdated.EF_History__c.contains('Testing 123'));
				Test.stopTest();
		}
	}

	@isTest static void testContractHistoryController()
	{
		System.runAs(EF_TestDataFactory.getEfProfileAndRole(0, 4))
		{
			EF_TestDataFactory.createCustomSettings();
			EF_TestDataFactory.skipContractCreationValidationRule();
			EF_TestDataFactory.createBaseDataWithAllowedWithApproval();

			Contract contract = [select Id, AccountId, Account.Name, EF_Allow_Billing_Agreements__c from Contract where Account.Name = 'Test Account Client'];
			Account customer = [select Id, Name from Account where Name = 'Test Account customer'];
			Account client = [select Id, Name from Account where Name = 'Test Account client'];

			ApexPages.StandardController sc = new ApexPages.StandardController(contract);
			EF_ContractHistoryController ctrl = new EF_contractHistoryController(sc);

				PageReference pageRef = Page.EF_ContractHistoryPage;
				Test.setCurrentPage(pageRef);

			Test.startTest();
				contract.EF_Comments__c = 'Testing 123';
				update contract;
				Contract cUpdated = [select id, EF_History__c from Contract where Id = :contract.Id limit 1];
				System.assert(cUpdated.EF_History__c.contains('Testing 123'));
			Test.stopTest();
		}
	}
}
