public with sharing class AddCampaignMemberController {

	public String CampaignId {get;set;}
	public String ProductCurrencyId {get;set;}

	public AddCampaignMemberController(ApexPages.StandardController stdc){
		try{
			ProductCurrencyId = stdc.getRecord().Id;
		}catch(Exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' No product currency has been selected'));
		}
	}


	public List<SelectOption> getCampaignPicklistValues(){
		List<SelectOption> values = new List<SelectOption>();
		values.add(new SelectOption('','-- None --'));
		for(Campaign c : [
				SELECT Id, Name
				FROM Campaign
				WHERE isActive=true
				AND CreatedBy.Profile.Name in ('FDS ICCS Administrator', 'FDS ICCS User')]){
			values.add(new SelectOption(c.Id,c.Name));
		}
		return values;
	}

	public void AddMembers(){
		List<CampaignMember> cms = new List<CampaignMember>();
		try{
			if(CampaignId == null || CampaignId == '' ){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' Please select a campaign.'));
				return;
			}


			for(Contact c : [SELECT Name FROM Contact
								WHERE AccountId IN (SELECT Account__c FROM Product_Assignment__c
													WHERE ICCS_Product_Currency__c = :ProductCurrencyId
													AND Status__c = 'Active')
								AND RecordType.Name = 'Standard'
								AND ICCS_Contact__c = true
								AND Id NOT IN (SELECT ContactId FROM CampaignMember
												WHERE CampaignId = :CampaignId)
								LIMIT 10000
							]){
				cms.add(new CampaignMember(CampaignId=CampaignId, ContactId=c.Id));
			}
			List<Database.Saveresult> res = database.insert(cms,false);
			integer allcounter = 0;
			integer successcounter = 0;
			for(Database.Saveresult sr : res){
				allcounter ++;
				if(sr.isSuccess())
					successcounter ++;
			}
			if(successcounter>0)
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,successcounter+' contacts inserted as a member of the selected campaign.'));
			else
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'There aren\'t new contacts to be inserted as a member of the selected campaign.'));
			if(allcounter==10000)
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Only a part of contacts have been inserted as a member of the selected campaign, please click the button again.'));
		}catch(Exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
		}

	}
}
