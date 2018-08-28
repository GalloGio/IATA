public class AgencyOwnerHandler {
    	/**
		CODE AFTER INSERT
	**/
	public static void afterInsert( list<Agency_Owner__c> listNewsAgencyOwners) {
		totalOWnershipPercentage();
		
	}

	/**
		CODE AFTER UPDATE
	**/
	public static void afterUpdate( list<Agency_Owner__c> listNewsAgencyOwners, list<Agency_Owner__c> listOldsAgencyOwners ) {
		totalOWnershipPercentage();

	}

	/**
		CODE AFTER DELETE
	**/
	public static void afterDelete( list<Agency_Owner__c>  listOldsAgencyOwners) {
		totalOWnershipPercentage();

	}

	/**
		CODE AFTER UNDELETE
	**/
	public static void afterUndelete( list<Agency_Owner__c>  listNewsAgencyOwners) {
		totalOWnershipPercentage();
        
	}
	
	public static void totalOWnershipPercentage() {
		List<GDP_Products_Account_View__c> gdpProdAccViewList = [SELECT id, Total_Ownership_Percentage__c from GDP_Products_Account_View__c];
		List<GDP_Products_Account_View__c> gdpPAV_toUpdate = new List<GDP_Products_Account_View__c>();
		for(GDP_Products_Account_View__c gdpProdAccView : gdpProdAccViewList){
			AggregateResult totalOwnersPercent = [SELECT SUM(Percent__c)TotalPercentage FROM Agency_Owner__C WHERE Percent__c != null and Related_GDP_Products_Account_View__c =: gdpProdAccView.id];
			gdpProdAccView.Total_Ownership_Percentage__c = (Decimal)totalOwnersPercent.get('TotalPercentage');
			gdpPAV_toUpdate.add(gdpProdAccView);
		}
		System.debug('SUM of Agency Owners to update ::: ' + gdpPAV_toUpdate);
		update gdpPAV_toUpdate;
	}

}