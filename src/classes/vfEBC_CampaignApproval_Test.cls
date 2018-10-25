@isTest
private class vfEBC_CampaignApproval_Test {
	
	@testSetup static void setup(){

		//Data preparation
		Account oAccount = IECTestUtil.createSampleAccount();
		insert oAccount;
		
		Zuora__CustomerAccount__c oBillingAccount = IECTestUtil.createSampleBillingAccount(oAccount);
		oBillingAccount.eBroadcast_Trusted_Sender__c = false;
		insert oBillingAccount;

		EBC_Campaign__c ebcCampaign = new EBC_Campaign__c();
		ebcCampaign.Name = 'Foo Bar';
        ebcCampaign.Subject__c = 'Foo Subject';
        ebcCampaign.From_Name__c = 'Foo From Name';
        ebcCampaign.Billing_Account__c = oBillingAccount.id;
		insert ebcCampaign;

		Approval.ProcessSubmitRequest psr = new Approval.ProcessSubmitRequest();
		psr.setObjectId(ebcCampaign.id);
		Approval.ProcessResult pr = Approval.process(psr); 
	}

	@isTest private static void testGetNoTemplateAttachment(){

		vfEBC_CampaignApproval clsInstance = new vfEBC_CampaignApproval(new ApexPages.StandardController(new EBC_Campaign__c()));
		//No attachments
		System.assertEquals(null, clsInstance.getTemplateAttachment());
	}


	@isTest private static void testControllerApprove(){
		
		EBC_Campaign__c ebcCampaign = [SELECT ID FROM EBC_Campaign__c WHERE Name = 'Foo Bar']; 

		Test.startTest();
		
		vfEBC_CampaignApproval clsInstance = new vfEBC_CampaignApproval(new ApexPages.StandardController(ebcCampaign));

		PageReference pageApprove = clsInstance.Approve();

		Test.stopTest();

		System.assert(pageApprove.getUrl().contains('/apex/EBC_CampaignApproval?id=' + ebcCampaign.id));

	}

	@isTest private static void testControllerReject(){
		EBC_Campaign__c ebcCampaign = [SELECT ID FROM EBC_Campaign__c WHERE Name = 'Foo Bar']; 

		Test.startTest();
		vfEBC_CampaignApproval clsInstance = new vfEBC_CampaignApproval(new ApexPages.StandardController(ebcCampaign));

		PageReference pageApprove = clsInstance.Reject();

		Test.stopTest();

		System.assert(pageApprove.getUrl().contains('/apex/EBC_CampaignApproval?id=' + ebcCampaign.id));

	}

}