@isTest
private class EF_BaContractApprovalHelperTest
{

	@isTest static void testBillingAgreementCreation_StartsApprovalProcess()
	{
		System.runAs(EF_TestDataFactory.getEfProfileAndRole(0, 4)) {
			EF_TestDataFactory.createCustomSettings();
			EF_TestDataFactory.skipContractCreationValidationRule();
			EF_TestDataFactory.createBaseDataWithAllowedWithApproval();

			Contract contract = [select Id, AccountId, Account.Name, EF_Allow_Billing_Agreements__c from Contract where Account.Name = 'Test Account Client'];
			Account customer = [select Id, Name from Account where Name = 'Test Account customer'];
			Account client = [select Id, Name from Account where Name = 'Test Account client'];

			List<ProcessInstanceWorkItem> pwiList = [SELECT Id, ActorId, ProcessInstance.TargetObjectId	FROM ProcessInstanceWorkitem];
			// This is the Location Currency
			System.assertEquals(1, pwiList.size());

			// Create a billing agreement and expect approval processing to start
			EF_Billing_Agreement__c ba = new EF_Billing_Agreement__c();
			ba.Client__c = client.Id;
			ba.Airline__c = customer.Id;
			ba.Contract__c = contract.Id;
			ba.EF_Location_ID__c =  [select Id, Name from EF_Related_Records__c where Name='Main' limit 1].Id;
			ba.Skip_Approval__c = false;
			insert ba;

			pwiList = [SELECT Id, ActorId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem where ProcessInstance.TargetObjectId = :ba.Id];
			System.assertEquals(1, pwiList.size());
			System.assertEquals(ba.Id, pwiList.get(0).ProcessInstance.TargetObjectId);
		}
	}

	@isTest static void testBillingAgreementUpdateKeyField_StartsApprovalProcessCreateEFapprovalRecord()
	{
		System.runAs(EF_TestDataFactory.getEfProfileAndRole(1, 2)) {

			EF_TestDataFactory.createCustomSettings();
			EF_TestDataFactory.skipContractCreationValidationRule();
			EF_TestDataFactory.createBaseDataWithAllowedWithApproval();

			Contract contract = [select Id, AccountId, Account.Name, EF_Allow_Billing_Agreements__c from Contract where Account.Name = 'Test Account Client'];
			Account customer = [select Id, Name from Account where Name = 'Test Account customer'];
			Account client = [select Id, Name from Account where Name = 'Test Account client'];
			contract.EF_Allow_Billing_Agreements__c = 'Allowed with Approval';
			update contract;

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

			ba.Payment_Method__c = 'Bank Transfer';
			update ba;

			pwiList = [SELECT Id, ActorId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem];
			System.assertEquals(1, pwiList.size());
			System.assertEquals(ba.Id, pwiList.get(0).ProcessInstance.TargetObjectId);
			approvalList = [SELECT Id, EF_Billing_Agreement__c FROM EF_Approval__c];
			System.assertEquals(1, approvalList.size());
			System.assertEquals(ba.Id, approvalList.get(0).EF_Billing_Agreement__c);
		}
	}

	@isTest static void testBillingAgreementChangeApproval_updateBaDeleteRecord()
	{
		System.runAs(EF_TestDataFactory.getEfProfileAndRole(1, 2)) {
			EF_TestDataFactory.createCustomSettings();
			EF_TestDataFactory.skipContractCreationValidationRule();
			EF_TestDataFactory.createBaseDataWithAllowedWithApproval();

			Contract contract = [select Id, AccountId, Account.Name, EF_Allow_Billing_Agreements__c from Contract where Account.Name = 'Test Account Client'];
			Account customer = [select Id, Name from Account where Name = 'Test Account customer'];
			Account client = [select Id, Name from Account where Name = 'Test Account client'];

			contract.EF_Allow_Billing_Agreements__c = 'Allowed with Approval';
			update contract;

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
				System.assertEquals('Bank Transfer'.toLowerCase(), baList.get(0).Payment_Method__c.toLowerCase());


			Test.stopTest();
		}
	}

	@isTest static void testBillingAgreementChangeRejection_rollbackBA()
	{
		System.runAs(EF_TestDataFactory.getEfProfileAndRole(1, 2)) {

			EF_TestDataFactory.createCustomSettings();
			EF_TestDataFactory.skipContractCreationValidationRule();
			EF_TestDataFactory.createBaseDataWithAllowedWithApproval();

			Contract contract = [select Id, AccountId, Account.Name, EF_Allow_Billing_Agreements__c from Contract where Account.Name = 'Test Account Client'];
			Account customer = [select Id, Name from Account where Name = 'Test Account customer'];
			Account client = [select Id, Name from Account where Name = 'Test Account client'];
			contract.EF_Allow_Billing_Agreements__c = 'Allowed with Approval';
			update contract;

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

			ba.Payment_Method__c = 'Bank Transfer';
			ba.Require_Approval__c = true;
			update ba;
			List<EF_Billing_Agreement__c> baList = [select id, Payment_Method__c from EF_Billing_Agreement__c where id = :ba.Id];
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
}
