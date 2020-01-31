public class CampaignMemberProduct_Sel extends Selector{

	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField> {
			Campaign_Member_Product__c.Id,
			Campaign_Member_Product__c.Campaign__c,
			Campaign_Member_Product__c.Contact__c,
			Campaign_Member_Product__c.Product__c,
			Campaign_Member_Product__c.Quantity__c,
			Campaign_Member_Product__c.Key__c,
			Campaign_Member_Product__c.Invoice_Date__c
		};
	}

	public Schema.SObjectType getSObjectType(){
		return Campaign_Member_Product__c.sObjectType;
	}

	//generate list of campaign member product base on the contact
	public map<Id,List<Campaign_Member_Product__c>> getCampaignMemberPrdByContactId(Id campaignId, set<Id> contactIds){

		Map<Id, List<Campaign_Member_Product__c>> contactId_cmProducts = new Map<Id, List<Campaign_Member_Product__c>>();

		String query = String.format(
			'SELECT {0}, Product__r.SAP_Material_Number__c  ' +
			'FROM {1} ' +
			'WHERE IsDeleted = false and Campaign__c = :campaignId AND Contact__c IN :contactIds' ,
			new List<String>{
				String.join(getDefaultFields(), ', '),
				getSObjectType().getDescribe().getName()
			}
		);

		List<Campaign_Member_Product__c> campaignMemberPrds = Database.query(query);
		for(Campaign_Member_Product__c cmp : campaignMemberPrds){
			if(!contactId_cmProducts.containsKey(cmp.Contact__c)){
				contactId_cmProducts.put(cmp.Contact__c,new List<Campaign_Member_Product__c>());
			}
			contactId_cmProducts.get(cmp.Contact__c).add(cmp);
		}
		return contactId_cmProducts;
	}

	/**
	 * 	Author David D - 02/2016
	 * 	return a Map<String, Campaign_Member_Product__c> of Campaign Member and Product by Key field.
	 */
	public Map<String, Campaign_Member_Product__c> getCampaignMemberProductByKey(Set<String> keys)
	{
		//-- Return Map
		Map<String, Campaign_Member_Product__c> ret = new Map<String, Campaign_Member_Product__c>();

		//-- Query records having the given key
		String query = String.format(
			'SELECT {0}  ' +
			'FROM {1} ' +
			'WHERE IsDeleted = false and Key__c IN :keys' ,
			new List<String>{
				String.join(getDefaultFields(), ', '),
				getSObjectType().getDescribe().getName()
			}
		);

		List<Campaign_Member_Product__c> campaignMemberPrds = Database.query(query);

		//-- Group records in a Map
		for(Campaign_Member_Product__c cmp : campaignMemberPrds)
			ret.put(cmp.Key__c, cmp);

		return ret;
	}

	/**
	 * 	Author David D - 02/2016
	 * 	return a Map<String, List<Campaign_Member_Product__c>> of List of Campaign Member and Product by Key field.
	 */
	public Map<String, List<Campaign_Member_Product__c>> getCampaignMemberProductsByKey(Set<String> keys)
	{
		//-- Return Map
		Map<String, List<Campaign_Member_Product__c>> ret = new Map<String, List<Campaign_Member_Product__c>>();

		//-- Query records having the given key
		String query = String.format(
			'SELECT {0}  ' +
			'FROM {1} ' +
			'WHERE Key__c IN :keys' ,
			new List<String>{
				String.join(getDefaultFields(), ', '),
				getSObjectType().getDescribe().getName()
			}
		);

		List<Campaign_Member_Product__c> campaignMemberPrds = Database.query(query);

		//-- Group records in a Map
		for(Campaign_Member_Product__c cmp : campaignMemberPrds)
		{
			List<Campaign_Member_Product__c> tmp = (ret.containsKey(cmp.Key__c)) ? ret.get(cmp.Key__c) : new List<Campaign_Member_Product__c>();
			tmp.add(cmp);

			ret.put(cmp.Key__c, tmp);
		}

		return ret;
	}

}
