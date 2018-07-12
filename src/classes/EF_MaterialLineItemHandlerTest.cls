@isTest
private class EF_MaterialLineItemHandlerTest {
		
    @isTest static void testAddingContractMaterial_expectApprovalToStart()
	{
		System.runAs(EF_TestDataFactory.getEfProfileAndRole(0, 4)) {
			EF_TestDataFactory.createCustomSettings();
			EF_TestDataFactory.skipContractCreationValidationRule();
			EF_TestDataFactory.createBaseDataWithAllowedWithApproval();

			Contract contract = [select Id, AccountId, Account.Name, EF_Allow_Billing_Agreements__c from Contract where Account.Name = 'Test Account Client'];
			Product2 prod = new Product2(Name='Test', Family='EF');
			insert prod;

			Id contractMaterialRtId = RecordTypeSingleton.getInstance().getRecordTypeId('EF_Material_Line_Item__c', 'Contract_Line_Item');

			List<ProcessInstanceWorkItem> pwiList = [SELECT Id, ActorId, ProcessInstance.TargetObjectId	FROM ProcessInstanceWorkitem];
			System.assertEquals(1, pwiList.size());

			EF_Material_Line_Item__c mat = new EF_Material_Line_Item__c(RecordTypeId=contractMaterialRtId, EF_Material__c=prod.Id, Contract__c=contract.Id, EF_Status__c='Active');
			insert mat;

			pwiList = [SELECT Id, ActorId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem];
			System.assertEquals(2, pwiList.size());
			System.assertEquals(mat.Id, pwiList.get(1).ProcessInstance.TargetObjectId);
		}
	}
	
	@isTest static void testAddingContractAndBaMaterial_noApprovals()
	{
		System.runAs(EF_TestDataFactory.getEfProfileAndRole(0, 2)) {
			EF_TestDataFactory.createBaseData();
			Contract contract = [select Id, AccountId, Account.Name, EF_Allow_Billing_Agreements__c from Contract where Account.Name = 'Test Account Client'];
			Account customer = [select Id, Name from Account where Name = 'Test Account customer'];
			Account client = [select Id, Name from Account where Name = 'Test Account client'];

			Product2 prod = new Product2(Name='Test', Family='EF');
			insert prod;

			Id contractMaterialRtId = RecordTypeSingleton.getInstance().getRecordTypeId('EF_Material_Line_Item__c', 'Contract_Line_Item');
			Id baMaterialRtId = RecordTypeSingleton.getInstance().getRecordTypeId('EF_Material_Line_Item__c', 'Relationship_Line_Item');

			List<ProcessInstanceWorkItem> pwiList = [SELECT Id, ActorId, ProcessInstance.TargetObjectId	FROM ProcessInstanceWorkitem];
			System.assertEquals(0, pwiList.size());

			EF_Material_Line_Item__c mat = new EF_Material_Line_Item__c(RecordTypeId=contractMaterialRtId, EF_Material__c=prod.Id, Contract__c=contract.Id, EF_Status__c='Active');
			insert mat;

			// Create a billing agreement 
			EF_Billing_Agreement__c ba = new EF_Billing_Agreement__c();
			ba.Client__c = client.Id;
			ba.Airline__c = customer.Id;
			ba.Contract__c = contract.Id;
			ba.EF_Location_ID__c =  [select Id, Name from EF_Related_Records__c where Name='Main' limit 1].Id;
			insert ba;

			EF_Material_Line_Item__c mat2 = new EF_Material_Line_Item__c(RecordTypeId=baMaterialRtId, EF_Material__c=prod.Id, EF_Relationship__c=ba.Id, EF_Status__c='Active');
			insert mat2;

			pwiList = [SELECT Id, ActorId, ProcessInstance.TargetObjectId	FROM ProcessInstanceWorkitem];
			System.assertEquals(0, pwiList.size());
		}
	}
	
	@isTest static void testAddingAndChangingMaterial()
	{
		System.runAs(EF_TestDataFactory.getEfProfileAndRole(0, 2)) {
			EF_TestDataFactory.createBaseData();
			Contract contract = [select Id, AccountId, Account.Name, EF_Allow_Billing_Agreements__c from Contract where Account.Name = 'Test Account Client'];
			Product2 prod = new Product2(Name='Test', Family='EF');
			insert prod;

			Product2 prod2 = new Product2(Name='Test2', Family='EF');
			insert prod2;

			Id contractMaterialRtId = RecordTypeSingleton.getInstance().getRecordTypeId('EF_Material_Line_Item__c', 'Contract_Line_Item');

			List<ProcessInstanceWorkItem> pwiList = [SELECT Id, ActorId, ProcessInstance.TargetObjectId	FROM ProcessInstanceWorkitem];
			System.assertEquals(0, pwiList.size());

			EF_Material_Line_Item__c mat = new EF_Material_Line_Item__c(RecordTypeId=contractMaterialRtId, EF_Material__c=prod.Id, Contract__c=contract.Id, EF_Status__c='Active');
			insert mat;

			mat.EF_Material__c = prod2.Id;
			update mat;
		}
	}
}