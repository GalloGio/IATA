global class OrderItem_Batch implements Database.Batchable<sObject>
{
	public String action;
	public String query;
	public Id campaignId;


	global OrderItem_Batch(String a)
	{
		action = a;
	}

	global Database.QueryLocator start(Database.BatchableContext BC)
	{
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope)
	{
		if(action == 'GenerateCampaignMembersAndProducts')
		{
			List<OrderItem> items = (List<OrderItem>) scope;

			//-- Generate Campaign Members
			List<CampaignMember> cmGenerated = CampaignMember_Svc.generateCampaignMembers(campaignId, items);

			//-- Generate CampaignMeber Products
			List<Campaign_Member_Product__c> cmpGenerated = CampaignMemberProduct_Svc.generateCampaignMemberProducts(campaignId, items);
		}
	}

	global void finish(Database.BatchableContext BC)
	{
		if(action == 'GenerateCampaignMembersAndProducts')
		{
			//-- Cleanup potential duplicates
			List<AggregateResult> duplicates = [SELECT COUNT(Id) nb, Key__c
				FROM Campaign_Member_Product__c
				WHERE Campaign__c = :campaignId
				GROUP BY Key__c
				HAVING (COUNT(Id) > 1)
			];
			Set<String> duplicateKeys = new Set<String>();
			for (AggregateResult ar : duplicates)
				duplicateKeys.add((String) ar.get('Key__c'));

			if(duplicateKeys.size() > 0) CampaignMemberProduct_Svc.removeDuplicates(duplicateKeys);

			//-- Update Campaign flag to notified the batch job is completed
			Campaign c = new Campaign(
				Id = campaignId,
				Generate_Members_Completed_On__c = Datetime.now()
			);
			update c;

			//-- Send notification email
			//if(!Test.isRunningTest())
			{
				Id templateId = (!Test.isRunningTest())? (Id) Utility.getTextSetting('TPL_GENERATE_CAMPAIGN_MEMBER_COMPLETED') : [SELECT Id FROM EmailTemplate  LIMIT 1].Id;

				Mail_DTO mail = new Mail_DTO();
					mail.whatId = campaignId;
					mail.templateId = templateId;
					mail.recipients = new List<String>{UserInfo.getUserEmail()};

				Utility.sendBulkEmails(new List<Mail_DTO>{mail});
			}
		}
	}
}
