@isTest
private with sharing class EF_MassUpdateMatLiControllerTest
{
	@isTest static void addAndMassUpdateMaterialLineItems()
	{
		System.runAs(EF_TestDataFactory.getEfProfileAndRole(1, 2))
		{
			EF_TestDataFactory.createCustomSettings();
			EF_TestDataFactory.skipContractCreationValidationRule();
			EF_TestDataFactory.createBaseDataWithAllowedWithApproval();
			
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

			EF_Billing_Agreement__c ba = new EF_Billing_Agreement__c();
			ba.Client__c = client.Id;
			ba.Airline__c = customer.Id;
			ba.Contract__c = contract.Id;
			ba.EF_Location_ID__c =  [select Id, Name from EF_Related_Records__c where Name='Main' limit 1].Id;
			insert ba;

			EF_Material_Line_Item__c mat2 = new EF_Material_Line_Item__c(RecordTypeId=baMaterialRtId, EF_Material__c=prod.Id, EF_Relationship__c=ba.Id, EF_Status__c='Active', 	EF_Submitter_Email__c='test@testing.com');
			insert mat2;


			ApexPages.StandardController sc = new ApexPages.StandardController(contract);
			EF_MassUpdateMatLiController ctrl = new EF_MassUpdateMatLiController(sc);
	        
	        PageReference pageRef = Page.EF_MassUpdateMatLI;
	        Test.setCurrentPage(pageRef);

	      Test.startTest();
	      	List<EF_MaterialWrapper> wrapper = ctrl.getMaterials();
	      	System.assertEquals(1, wrapper.size());
	      	
	      	ctrl.listMatWrapper.get(0).mmli.EF_Submitter_Email__c = 'abc@test.com';
	      	ctrl.save();

	      	List<EF_Material_Line_Item__c> mat2Updated = [select Id, EF_Submitter_Email__c from EF_Material_Line_Item__c where id = :mat2.id];
	      	System.assertEquals('abc@test.com', mat2Updated.get(0).EF_Submitter_Email__c);

	      	// Values are automatically selected, so Clear All is the default header
	      	System.assertEquals('Clear All', ctrl.checkHeader);
	      	ctrl.selectAll();
	      	System.assertEquals('Select All', ctrl.checkHeader);
	      	System.assertEquals(wrapper.size(), 1);
	      	ctrl.selectAll();
	      	
	      	EF_MassUpdateMatLiController ctrl2 = new EF_MassUpdateMatLiController();
	      	ctrl2.sampleMaterial = mat2;
	      	ctrl2.materials = new List<EF_Material_Line_Item__c>();
	      	Contract c = ctrl.getContract();
	      	System.assertEquals(c.Id, contract.Id);
	      Test.stopTest();

		}
	}
}