public class CampaignProduct_Sel extends Selector {

	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
			Campaign_Product__c.Id,
			Campaign_Product__c.Campaign__c,
			Campaign_Product__c.Product__c,
			Campaign_Product__c.Product_Last_Version__c,
			Campaign_Product__c.Swapping_Product__c
		};
	}

	public Schema.SObjectType getSObjectType(){
		return Campaign_Product__c.sObjectType;
	}

	//get list of product id by campaign id
	public Map<Id,List<Id>> getProductIdsByCampaign(set<Id> campaignIds){

		Map<Id,List<Id>> campaignId_ProductIds = new Map<Id,List<Id>>();

		String query = String.format(
			'SELECT {0} ' +
			'FROM {1} ' +
			'WHERE Campaign__c in :campaignIds ' ,
			new List<String>{
				String.join(getDefaultFields(), ', '),
				getSObjectType().getDescribe().getName()
			}
		);

		List<Campaign_Product__c> lstCampaignProds = Database.query(query);
		if(lstCampaignProds != null && lstCampaignProds.size() > 0){
			for(Campaign_Product__c cp : lstCampaignProds){
				if(!campaignId_ProductIds.containsKey(cp.Campaign__c)){
					campaignId_ProductIds.put(cp.Campaign__c, new List<Id>());
				}
				campaignId_ProductIds.get(cp.Campaign__c).add(cp.Product__c);
			}
		}

		return campaignId_ProductIds;
	}

	//get the last version or swap product by old product id
	public Map<Id,Id> getLastVersionProductIdById(id campaignId){

		Map<Id,Id> campaignProductIdById = new Map<Id,Id>();

		String query = String.format(
			'SELECT {0} ' +
			'FROM {1} ' +
			'Where IsDeleted = false and Campaign__c = :campaignId' ,
			new List<String>{
				String.join(getDefaultFields(), ', '),
				getSObjectType().getDescribe().getName()
			}
		);

		List<Campaign_Product__c> lstCampaignProds = Database.query(query);

		for(Campaign_Product__c cp : lstCampaignProds){

			Id prdToAdd = (cp.Swapping_Product__c != null) ? cp.Swapping_Product__c : cp.Product_Last_Version__c;

			campaignProductIdById.put(cp.Product__c,prdToAdd);
		}
		return campaignProductIdById;
	}

}
