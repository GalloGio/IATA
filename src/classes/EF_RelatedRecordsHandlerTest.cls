@isTest
public with sharing class EF_RelatedRecordsHandlerTest {

	@isTest static void testLinkContactAndCaseToContract()
	{
		System.runAs(EF_TestDataFactory.getEfProfileAndRole(1, 2))
		{
			EF_TestDataFactory.createCustomSettings();
			EF_TestDataFactory.skipContractCreationValidationRule();
			EF_TestDataFactory.createBaseDataWithAllowedWithApproval();
			
			Contract contract = [select Id, AccountId, Account.Name, EF_History__c from Contract where Account.Name = 'Test Account Client'];
			System.assertEquals(null, contract.EF_History__c);
			Contact c = new Contact(AccountId = contract.AccountId, FirstName = 'FirstName', LastName = 'LastName', Email = 'cont@act.com');
	        insert c;
	        
	        Case cs = new Case(AccountId = c.AccountId, ContactId = c.Id, Subject = 'TEST Case');
			insert cs;   

			EF_Related_Records__c rr = new EF_Related_Records__c();
			rr.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('EF_Related_Records__c', 'Relationship');
			rr.Contract__c = contract.Id;
			rr.Contact__c = c.Id;
			rr.Case__c = cs.Id;
			insert rr;

			contract = [select Id, AccountId, Account.Name, EF_History__c from Contract where Account.Name = 'Test Account Client'];
			System.assert(contract.EF_History__c.contains('FirstName LastName'));
			System.assert(contract.EF_History__c.contains('TEST Case'));
		}
	}

}