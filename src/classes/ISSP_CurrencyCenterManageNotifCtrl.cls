public with sharing class ISSP_CurrencyCenterManageNotifCtrl {
	public list<CountryProfileWrapper> lstCountryProfiles {get; set;}
	public list<CountryProfileWrapper> lstCountryProfilesBF {get; set;}
	public list<CountryProfileWrapper> lstCountryProfilesWL {get; set;}
	public Boolean isSaved {get; set;}
	public Boolean isError {get; set;}

	public List<String> regionList {get;set;}

	public ISSP_CurrencyCenterManageNotifCtrl() {
		RefreshCountryProfileList();
		isSaved = false;
		isError = false;
	}

	private void RefreshCountryProfileList() {
		if (regionList == null) {
			regionList = new List<String>();
		}
		Schema.DescribeFieldResult fieldResult = IATA_ISO_Country__c.Region__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple){
           regionList.add(f.getLabel());
        }

		/*
		if (lstCountryProfiles == null) {
			lstCountryProfiles = new list<CountryProfileWrapper>();
		}
		*/
		if (lstCountryProfilesBF == null) {
			lstCountryProfilesBF = new list<CountryProfileWrapper>();
		}
		if (lstCountryProfilesWL == null) {
			lstCountryProfilesWL = new list<CountryProfileWrapper>();
		}

		map<Id, Country_Profile__c> mapCountryProfilesPerId = new map<Id, Country_Profile__c>([Select Id, Name, Listed_In__c, Region__c FROM Country_Profile__c ORDER BY Name]); 
		system.debug('@@@mapCountryProfilesPerId: '+mapCountryProfilesPerId);
		map<Id, EntitySubscription> mapSubscriptionsPerCountryId = new map<Id, EntitySubscription>();

		for (EntitySubscription es : [SELECT Id, ParentId FROM EntitySubscription WHERE SubscriberId = :UserInfo.getUserId() AND NetworkId = :Network.getNetworkId() AND ParentId IN :mapCountryProfilesPerId.keyset() AND ParentId <> null LIMIT 300]) {
			mapSubscriptionsPerCountryId.put(es.ParentId, es);
		}

		for (Country_Profile__c cp : mapCountryProfilesPerId.values()) {
			//lstCountryProfiles.add(new CountryProfileWrapper(cp.Id, cp.Name, mapSubscriptionsPerCountryId.get(cp.Id) != null));
			if(cp.Listed_In__c == 'Blocked Funds'){
				lstCountryProfilesBF.add(new CountryProfileWrapper(cp.Id, cp.Name, mapSubscriptionsPerCountryId.get(cp.Id) != null, cp.Region__c));
			}
			if(cp.Listed_In__c == 'Watch List'){
				lstCountryProfilesWL.add(new CountryProfileWrapper(cp.Id, cp.Name, mapSubscriptionsPerCountryId.get(cp.Id) != null, cp.Region__c));
			}
		}

		system.debug(lstCountryProfilesBF);
	}


	public void SaveSubscriptions() {
		try {
			list<Id> lstSubscriptionsToDelete = new list<Id>();
			list<EntitySubscription> lstSubscriptionsToUpsert = new list<EntitySubscription>();

			lstCountryProfiles = new list<CountryProfileWrapper>();
			lstCountryProfiles.addAll(lstCountryProfilesBF);
			lstCountryProfiles.addAll(lstCountryProfilesWL);

			for (CountryProfileWrapper cpw : lstCountryProfiles) {
				if (cpw.isChecked) {
					lstSubscriptionsToUpsert.add( new EntitySubscription(SubscriberId = UserInfo.getUserId(), ParentId = cpw.CountryProfileId, NetworkId = Network.getNetworkId()) );
				} else {
					lstSubscriptionsToDelete.add(cpw.CountryProfileId);
				}
			}

			// Delete removed subscriptions
			list<EntitySubscription> lstDel = [SELECT Id FROM  EntitySubscription WHERE SubscriberId = :UserInfo.getUserId() AND NetworkId = :Network.getNetworkId() AND ParentId IN :lstSubscriptionsToDelete LIMIT 300];
			delete lstDel;

			// Upsert the new subscriptions
			// duplicate values will throw errors, so use Database insert to just ignore those errors 
			Database.insert(lstSubscriptionsToUpsert, false);

			isSaved = true;
			isError = false;
		} catch (Exception e) {
			isError = true;
			isSaved = false;
		}
	}


    public class CountryProfileWrapper{
        public String CountryProfileId {get;set;}
        public String CountryName {get;set;}
        public Boolean isChecked {get;set;}
        public String region {get;set;}

        public CountryProfileWrapper(String CountryProfileId, String CountryName, Boolean isChecked, String region){
            this.CountryProfileId = CountryProfileId;
            this.CountryName = CountryName;
            this.isChecked = isChecked;
            this.region = region;
        }
    }
}