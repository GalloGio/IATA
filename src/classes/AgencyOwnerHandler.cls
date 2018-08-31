public class AgencyOwnerHandler {
    	/**
		CODE AFTER INSERT
	**/
	public static void afterInsert( list<Agency_Owner__c> listNewsAgencyOwners) {
		totalOWnershipPercentage(listNewsAgencyOwners ,  new list<Agency_Owner__c>());
		
	}

	/**
		CODE AFTER UPDATE
	**/
	public static void afterUpdate( list<Agency_Owner__c> listNewsAgencyOwners, list<Agency_Owner__c> listOldsAgencyOwners ) {
		totalOWnershipPercentage( listNewsAgencyOwners, listOldsAgencyOwners );

	}

	/**
		CODE AFTER DELETE
	**/
	public static void afterDelete( list<Agency_Owner__c>  listOldsAgencyOwners) {
		totalOWnershipPercentage(  new list<Agency_Owner__c>() , listOldsAgencyOwners);

	}

	/**
		CODE AFTER UNDELETE
	**/
	public static void afterUndelete( list<Agency_Owner__c>  listNewsAgencyOwners) {
		totalOWnershipPercentage(listNewsAgencyOwners, new list<Agency_Owner__c>());
        
	}


	public static void totalOWnershipPercentage(list<Agency_Owner__c>  listNewsAgencyOwners, list<Agency_Owner__c>  listOldsAgencyOwners) {
		String msg;
		GDP_Products_Account_View__c gdpPrdAccView = new GDP_Products_Account_View__c();
		List<GDP_Products_Account_View__c> gdpList_toUpdate = new List<GDP_Products_Account_View__c>();
		List<AggregateResult> relatedGdpProdAccView = new List<AggregateResult>();

		if(Trigger.isDelete && Trigger.isAfter){
			Set<Id> gdpIdSet = new Set<Id>();
			for(Agency_Owner__c aOwner : listOldsAgencyOwners){
				gdpIdSet.add(aOwner.Related_GDP_Products_Account_View__c);
			}

			List<Agency_Owner__c> agencyOwnersAfterDelete = [SELECT Related_GDP_Products_Account_View__c FROM Agency_Owner__c WHERE Related_GDP_Products_Account_View__c IN :gdpIdSet];
			relatedGdpProdAccView= [SELECT Related_GDP_Products_Account_View__c FROM Agency_Owner__c WHERE id IN :agencyOwnersAfterDelete GROUP BY Related_GDP_Products_Account_View__c];
		}
		else {
			relatedGdpProdAccView= [SELECT Related_GDP_Products_Account_View__c FROM Agency_Owner__c WHERE id IN :listNewsAgencyOwners OR id IN :listOldsAgencyOwners GROUP BY Related_GDP_Products_Account_View__c];
		}

		for(AggregateResult aGdp : relatedGdpProdAccView){
			AggregateResult totalOwnersPercent = [SELECT SUM(Percent__c)TotalPercentage FROM Agency_Owner__C WHERE Percent__c != null AND Related_GDP_Products_Account_View__c  =: (Id)aGdp.get('Related_GDP_Products_Account_View__c')];
			gdpPrdAccView.Total_Ownership_Percentage__c = (Decimal)totalOwnersPercent.get('TotalPercentage');
			gdpPrdAccView.Id = (Id)aGdp.get('Related_GDP_Products_Account_View__c');
			gdpList_toUpdate.add(gdpPrdAccView);
		}

		System.debug('totalOWnershipPercentage in gdpList_toUpdate :::' + gdpList_toUpdate);
		
		try {
			if(!gdpList_toUpdate.isEmpty()){
				update gdpList_toUpdate;
			}
			else {
				msg = 'Empty list | ';
			}
		} catch(Exception e) {
			System.debug(msg + e.getMessage());
		}
	}


}