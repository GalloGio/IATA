public without sharing class Campaign_Sel extends Selector{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
			Campaign.Id,
			Campaign.Name,
			Campaign.Renewal_notice_generated__c,
			Campaign.Campaign_AutoNumber__c,
			Campaign.Generate_Members_Completed_On__c
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return Campaign.sObjectType;
	}
	/****************************************************************************************************
		Created by Samy 2016-01-19
			Return 1 campaign for CSV Visualforce page
	****************************************************************************************************/
	public static Campaign getCampaignById(String CampaignId){
		Campaign campaign = new Campaign();
		List<Campaign> lstCampaign = [SELECT Id, Name, Renewal_notice_generated__c, IsActive, Generate_Members_Completed_On__c,Campaign_AutoNumber__c
								FROM Campaign
								WHERE Id = :CampaignId limit 1];

		if(lstCampaign != null && lstCampaign.size() > 0){
			campaign = lstCampaign[0];
		}
		return campaign;

	} //*** end of "getCampaignForVF"

	/**
	 *  Author David D - 02/2016
	 *  return the list of active campaigns
	 */
	public List<Campaign> getActiveCampaigns(String strFilter)
	{

		 String query = String.format(
			'SELECT {0} ' +
			'FROM {1} ' +
			'WHERE (IsActive = true AND Renewal_notice_generated__c = null) ' + strFilter +
			' ORDER BY Name ' ,
			new List<String>{
				String.join(getDefaultFields(), ', '),
				getSObjectType().getDescribe().getName()
			}
		);

		return Database.query(query);
	}

	//return campaign by Id
	public map<Id,Campaign> getCampaignById(set<Id> campaignIds){

		String query = String.format(
			'SELECT {0} ' +
			'FROM {1} ' +
			'WHERE Id in :campaignIds ',
			new List<String>{
				String.join(getDefaultFields(), ', '),
				getSObjectType().getDescribe().getName()
			}
		);

		List<Campaign> campaigns = Database.query(query);

		return new map<Id,Campaign>(campaigns);

	}

}
