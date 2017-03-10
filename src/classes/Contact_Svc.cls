public class Contact_Svc {

	//Sync contact location to SAP when some fields changed
	public static void contactLocationToSynWithSap(Map<Id, Contact> newMap, Map<Id, Contact> oldMap){

		// Retrieve list of fields that are allowed to be synced to SAP
		List<String> lstContFieldsToSAP = Utility.getSeqTextSetting('Contact fields to sync to SAP', ',').split(',');

		Set<Id> setContactIdsToSync = new Set<Id>();

		//Check if at less one field value changed
		if(!lstContFieldsToSAP.isEmpty()){
			for(Contact contact : newMap.values()){

				if(lstContFieldsToSAP != null ){
					for(String field : lstContFieldsToSAP){
						if(!String.isEmpty(field) && newMap.get(contact.Id).get(field) != oldMap.get(contact.Id).get(field) ){
							setContactIdsToSync.add(contact.Id);
							break;
						}
					}
				}

			}
		}

		Set<Id> contactIds = new set<Id>();
		map<Id,Location__c> locationMap;
		Map<Id, Location__c> soldToLocations;
		set<Id> locationIds = new set<Id>();
		List<Location__c> toCreateSoldToLocation = new List<Location__c>();
		set<Id> soldToLocationIds2CreateFirst = new set<Id>();

		if(setContactIdsToSync.size() > 0){
			

			locationMap = new Location_Sel().getContactsLocations(setContactIdsToSync);

			if(!locationMap.isEmpty()){
				for(Location__c location : locationMap.values()){
					contactIds.add(location.Contact__c);
				}
			}

			if(contactIds.size() > 0){
				soldToLocations = new Location_Sel().getSoldToLocationByContactId(contactIds);
			}

			if(locationMap != null && locationMap.size() > 0){
				for(Location__c location : locationMap.values()){
					locationIds.add(location.Id);
					Location__c soldToLocation = soldToLocations.get(location.Contact__c);
					if(soldToLocation != null){
						if(soldToLocation != null && soldToLocation.Active__c){
							if(soldToLocation.SAP_Id__c == null){
								soldToLocationIds2CreateFirst.add(location.Id);
							}
						}else{
							//BillTo or ShipTo location to Create
							if(soldToLocation == null)
								toCreateSoldToLocation.add(location);
						}
					}else{
						toCreateSoldToLocation.add(location);
					}
				}
			}

			if(toCreateSoldToLocation.size() > 0){
				List<Location__c> lstLocation = Location_Svc.locationToCreate(toCreateSoldToLocation);
				if(lstLocation != null && lstLocation.size() > 0){
		    		for(Location__c location : lstLocation)
		    			soldToLocationIds2CreateFirst.add(location.Id);
		    	}
			}
			
			//Call SAP to sync the Customer information
			if(soldToLocationIds2CreateFirst.size() > 0){
				IECAddress_Svc.syncCustomerMasterWithSAP(locationIds,soldToLocationIds2CreateFirst);
			} else if (locationIds.size() > 0) {
				IECAddress_Svc.syncCustomerMasterWithSAP(locationIds);
			}
		}
	}
	
}