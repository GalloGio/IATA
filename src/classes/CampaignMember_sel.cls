Public class CampaignMember_sel extends Selector{

	public List<Schema.SObjectField> getSObjectFieldList(){
		return new List<Schema.SObjectField>
		{
			CampaignMember.Id,
			CampaignMember.Order__c,
			CampaignMember.ContactId,
			CampaignMember.Key__c,
			CampaignMember.CampaignId
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return CampaignMember.sObjectType;
	}

	public map<Id,CampaignMember> getCampaignMembers(Id campaignId, set<Id> contactIds){

		map<Id,CampaignMember> contactId_campaignMember = new map<Id,CampaignMember>();

		 String query = String.format(
			'SELECT {0} ' +
			'FROM {1} ' +
			'WHERE ContactId in :contactIds and CampaignId = :campaignId ' ,
			new List<String>{
				String.join(getDefaultFields(), ', '),
				getSObjectType().getDescribe().getName()
			}
		);

		List<CampaignMember> CampaignMembers = Database.query(query);
		if(CampaignMembers != null && CampaignMembers.size() > 0){
			for(CampaignMember cm : CampaignMembers){
				contactId_campaignMember.put(cm.ContactId,cm);
			}
		}

		return contactId_campaignMember;
	}

	/**
	 *  Author David D - 01/2016
	 *  return a Map<String, CampaignMember> of List of Campaign Member  by Key field.
	 */
	public Map<String,CampaignMember> getExistingCampaignMemberByKey(Set<String> keys)
	{
		//-- Map to return
		Map<String,CampaignMember> ret = new Map<String,CampaignMember>();

		//-- Query records having the given key
		String query = String.format(
			'SELECT {0} ' +
			'FROM {1} ' +
			'WHERE IsDeleted = false and Key__c IN :keys ' ,
			new List<String>{
				String.join(getDefaultFields(), ', '),
				getSObjectType().getDescribe().getName()
			}
		);

		List<CampaignMember> members = Database.query(query);


		//-- Group records in a Map
		for(CampaignMember cm : members)
		{
			ret.put(cm.Key__c, cm);
		}

		return ret;
	}

}
