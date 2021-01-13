global class CampaignMembers_Batch implements Database.Batchable<sObject> {

	//List<CampaignMember> campaignMembers;
	String action;
	String campaigId;
	String campaignNumber;

	//get Campaign members to create Order and items for.
	global CampaignMembers_Batch(String action,String campaignId, String cNumber) {/*, List<CampaignMember> campaignMembers*/
		//this.campaignMembers = campaignMembers;
		this.action = action;
		campaigId = campaignId;
		campaignNumber = cNumber;
	}

	//Campaign members to generate renewal
	global Database.QueryLocator start(Database.BatchableContext BC){
		String query = 'SELECT Status, ContactId, Contact.FirstName, Contact.LastName, Contact.Account.Name, Contact.Title, Campaign.Campaign_AutoNumber__c, CampaignId FROM CampaignMember where CampaignId = \'' + campaigId + '\' ';
		System.debug('query::'+query);
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<CampaignMember> scope) {
		//Generate Renewal notice
		if(action == 'renewalNotice'){
			CampaignMember_Svc.generateRenewalOrder(scope[0].CampaignId,scope);
		}
	}

	global void finish(Database.BatchableContext BC) {

		//Calculate Taxes and Shipping
		IEC_CampaignMembers_SAPFreightTax_Batch freightTaxBatch = new IEC_CampaignMembers_SAPFreightTax_Batch(campaigId,campaignNumber);
		Database.ExecuteBatch(freightTaxBatch,1);

	}

}
