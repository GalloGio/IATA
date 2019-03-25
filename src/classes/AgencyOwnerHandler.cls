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
         
        Set<Id> updatedGDP = new Set<Id>();
		for(AggregateResult aGdp : relatedGdpProdAccView){
            gdpPrdAccView.Id = (Id)aGdp.get('Related_GDP_Products_Account_View__c');
            if (updatedGDP.contains(gdpPrdAccView.Id)) continue;
		    updatedGDP.add(gdpPrdAccView.Id);
			AggregateResult totalOwnersPercent = [SELECT SUM(Percent__c)TotalPercentage FROM Agency_Owner__C WHERE Percent__c != null AND Related_GDP_Products_Account_View__c  =: (Id)aGdp.get('Related_GDP_Products_Account_View__c')];
			gdpPrdAccView.Total_Ownership_Percentage__c = (Decimal)totalOwnersPercent.get('TotalPercentage');
			
         	gdpList_toUpdate.add(gdpPrdAccView);
            
		}

		System.debug('totalOWnershipPercentage in gdpList_toUpdate :::' + gdpList_toUpdate);
        //Abdellah: Old Code 
		/*
		try {
			if(!gdpList_toUpdate.isEmpty()){
				update gdpList_toUpdate;
			}
			else {
				msg = 'Empty list | ';
			}
		} catch(Exception e) {
			System.debug(msg + e.getMessage());
		} */
        if (gdpList_toUpdate.Size()==0) return; 
		//reuse the code of ams2gdp
        List<ams2gdp_Error> errors = new List<ams2gdp_Error>(); 
        try{
            Database.SaveResult[] saveresultlist = Database.update(gdpList_toUpdate,false);
            // Iterate through saveResultList based on isSuccess capture the failed records
            for (Database.SaveResult sr : saveresultlist) {
                if (sr.isSuccess()) continue;
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    errors.add(new ams2gdp_Error('Total Ownership',null, null, 'Error Code: '+err.getStatusCode() + ' Msg: ' + err.getMessage()));
                }
            }
        }Catch(Exception e) {
          errors.add(new ams2gdp_Error('Total Ownership',null, null, 'Error Code: N/A Msg: ' + e.getMessage()));
        }
        if (errors.isEmpty()) return;
        //Log the current Errors
        ams2gdp_Utils.logErrors(errors);
	}
}