@isTest
private class EF_BaContractApprovalHelperTest
{
	@isTest static void testBillingAgreementCreation_StartsApprovalProcess()
	{
		EF_TestDataFactory.createBaseData();
		Contract contract = [select Id, AccountId, Account.Name from Contract where Account.Name = 'Test Account Client'];
		Account customer = [select Id, Name, EF_Allow_Billing_Agreements__c from Account where Name = 'Test Account customer'];
		Account client = [select Id, Name, EF_Allow_Billing_Agreements__c from Account where Name = 'Test Account client'];
		
		customer.EF_Allow_Billing_Agreements__c = 'Allowed with Approval';
		client.EF_Allow_Billing_Agreements__c = 'Allowed with Approval';
		update customer;
		update client;

		List<ProcessInstanceWorkItem> pwiList = [SELECT Id, ActorId, ProcessInstance.TargetObjectId	FROM ProcessInstanceWorkitem];
		System.assertEquals(0, pwiList.size());

		// Create a billing agreement 
		EF_Billing_Agreement__c ba = new EF_Billing_Agreement__c();
		ba.Client__c = client.Id;
		ba.Airline__c = customer.Id;
		ba.Contract__c = contract.Id;
		ba.EF_Location_ID__c =  [select Id, Name from EF_Related_Records__c where Name='Main' limit 1].Id;
		insert ba;

		pwiList = [SELECT Id, ActorId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem];
		System.assertEquals(1, pwiList.size());
		System.assertEquals(ba.Id, pwiList.get(0).ProcessInstance.TargetObjectId);
	}

	@isTest static void testBillingAgreementUpdateKeyField_StartsApprovalProcessCreateEFapprovalRecord()
	{
		EF_TestDataFactory.createBaseData();
		Contract contract = [select Id, AccountId, Account.Name from Contract where Account.Name = 'Test Account Client'];
		Account customer = [select Id, Name, EF_Allow_Billing_Agreements__c from Account where Name = 'Test Account customer'];
		Account client = [select Id, Name, EF_Allow_Billing_Agreements__c from Account where Name = 'Test Account client'];
		
		List<ProcessInstanceWorkItem> pwiList = [SELECT Id, ActorId, ProcessInstance.TargetObjectId	FROM ProcessInstanceWorkitem];
		System.assertEquals(0, pwiList.size());
		List<EF_Approval__c> approvalList = [select id from EF_Approval__c];
		System.assertEquals(0, approvalList.size());

		// Create a billing agreement 
		EF_Billing_Agreement__c ba = new EF_Billing_Agreement__c();
		ba.Client__c = client.Id;
		ba.Airline__c = customer.Id;
		ba.Contract__c = contract.Id;
		ba.Payment_Method__c = 'Credit Card';
		ba.EF_Location_ID__c =  [select Id, Name from EF_Related_Records__c where Name='Main' limit 1].Id;
		insert ba;

		customer.EF_Allow_Billing_Agreements__c = 'Allowed with Approval';
		client.EF_Allow_Billing_Agreements__c = 'Allowed with Approval';
		update customer;
		update client;

		ba.Payment_Method__c = 'Bank Transfer';
		update ba;

		pwiList = [SELECT Id, ActorId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem];
		System.assertEquals(1, pwiList.size());
		System.assertEquals(ba.Id, pwiList.get(0).ProcessInstance.TargetObjectId);
		approvalList = [SELECT Id, EF_Billing_Agreement__c FROM EF_Approval__c];
		System.assertEquals(1, approvalList.size());
		System.assertEquals(ba.Id, approvalList.get(0).EF_Billing_Agreement__c);
	}

	@isTest static void testBillingAgreementChangeApproval_updateBaDeleteRecord()
	{
		EF_TestDataFactory.createBaseData();
		Contract contract = [select Id, AccountId, Account.Name from Contract where Account.Name = 'Test Account Client'];
		Account customer = [select Id, Name, EF_Allow_Billing_Agreements__c from Account where Name = 'Test Account customer'];
		Account client = [select Id, Name, EF_Allow_Billing_Agreements__c from Account where Name = 'Test Account client'];
		
		List<ProcessInstanceWorkItem> pwiList = [SELECT Id, ActorId, ProcessInstance.TargetObjectId	FROM ProcessInstanceWorkitem];
		System.assertEquals(0, pwiList.size());
		List<EF_Approval__c> approvalList = [select id from EF_Approval__c];
		System.assertEquals(0, approvalList.size());

		// Create a billing agreement 
		EF_Billing_Agreement__c ba = new EF_Billing_Agreement__c();
		ba.Client__c = client.Id;
		ba.Airline__c = customer.Id;
		ba.Contract__c = contract.Id;
		ba.Payment_Method__c = 'Credit Card';
		ba.EF_Location_ID__c =  [select Id, Name from EF_Related_Records__c where Name='Main' limit 1].Id;
		insert ba;

		customer.EF_Allow_Billing_Agreements__c = 'Allowed with Approval';
		client.EF_Allow_Billing_Agreements__c = 'Allowed with Approval';
		update customer;
		update client;

		ba.Payment_Method__c = 'Bank Transfer';
		update ba;
		List<EF_Billing_Agreement__c> baList = [select id, Payment_Method__c from EF_Billing_Agreement__c];
		System.assertEquals('Credit Card', baList.get(0).Payment_Method__c);

		Test.startTest();
			pwiList = [SELECT Id, ActorId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem];
			System.assertEquals(1, pwiList.size());
			System.assertEquals(ba.Id, pwiList.get(0).ProcessInstance.TargetObjectId);

			Approval.ProcessWorkitemRequest pwir = new Approval.ProcessWorkitemRequest();
			pwir.setAction('Approve');
			pwir.setWorkItemId(pwiList.get(0).Id);
			Approval.process(pwir);

			approvalList = [SELECT Id, EF_Billing_Agreement__c FROM EF_Approval__c];
			System.assertEquals(0, approvalList.size());
			baList = [select id, Payment_Method__c from EF_Billing_Agreement__c];
			System.assertEquals('Bank Transfer', baList.get(0).Payment_Method__c);
			

		Test.stopTest();		
	}

	@isTest static void testBillingAgreementChangeRejection_rollbackBA()
	{
		EF_TestDataFactory.createBaseData();
		Contract contract = [select Id, AccountId, Account.Name from Contract where Account.Name = 'Test Account Client'];
		Account customer = [select Id, Name, EF_Allow_Billing_Agreements__c from Account where Name = 'Test Account customer'];
		Account client = [select Id, Name, EF_Allow_Billing_Agreements__c from Account where Name = 'Test Account client'];
		
		List<ProcessInstanceWorkItem> pwiList = [SELECT Id, ActorId, ProcessInstance.TargetObjectId	FROM ProcessInstanceWorkitem];
		System.assertEquals(0, pwiList.size());
		List<EF_Approval__c> approvalList = [select id from EF_Approval__c];
		System.assertEquals(0, approvalList.size());

		// Create a billing agreement 
		EF_Billing_Agreement__c ba = new EF_Billing_Agreement__c();
		ba.Client__c = client.Id;
		ba.Airline__c = customer.Id;
		ba.Contract__c = contract.Id;
		ba.Payment_Method__c = 'Credit Card';
		ba.EF_Location_ID__c =  [select Id, Name from EF_Related_Records__c where Name='Main' limit 1].Id;
		insert ba;

		customer.EF_Allow_Billing_Agreements__c = 'Allowed with Approval';
		client.EF_Allow_Billing_Agreements__c = 'Allowed with Approval';
		update customer;
		update client;

		ba.Payment_Method__c = 'Bank Transfer';
		update ba;
		List<EF_Billing_Agreement__c> baList = [select id, Payment_Method__c from EF_Billing_Agreement__c];
		System.assertEquals('Credit Card', baList.get(0).Payment_Method__c);

		Test.startTest();
			pwiList = [SELECT Id, ActorId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem];
			System.assertEquals(1, pwiList.size());
			System.assertEquals(ba.Id, pwiList.get(0).ProcessInstance.TargetObjectId);

			Approval.ProcessWorkitemRequest pwir = new Approval.ProcessWorkitemRequest();
			pwir.setAction('Reject');
			pwir.setWorkItemId(pwiList.get(0).Id);
			Approval.process(pwir);

			approvalList = [SELECT Id, EF_Billing_Agreement__c FROM EF_Approval__c];
			System.assertEquals(0, approvalList.size());
			baList = [select id, Payment_Method__c from EF_Billing_Agreement__c];
			System.assertEquals('Credit Card', baList.get(0).Payment_Method__c);
			

		Test.stopTest();		
	}
}