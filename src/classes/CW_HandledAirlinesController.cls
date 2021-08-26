public without sharing class CW_HandledAirlinesController {
	@AuraEnabled
	public static string getAllAirlines() {
		List<CW_SearchEngine.HandledElement> handledItems = new List<CW_SearchEngine.HandledElement>();
		for (Account currentItem : [SELECT  Id, Name, Airline_designator__c FROM Account  WHERE Recordtype.DeveloperName IN ('IATA_Airline', 'Operator') AND Airline_designator__c != 'XB' AND Airline_designator__c != 'XB*' ORDER BY Name ASC NULLS LAST]) {
			CW_SearchEngine.HandledElement handleItemToAdd = new CW_SearchEngine.HandledElement();
			handleItemToAdd.selected = false;
			handleItemToAdd.value = currentItem.Id;
			handleItemToAdd.label = 
				currentItem.Name + 
				(String.isNotBlank(currentItem.Airline_designator__c) ? ' [' + currentItem.Airline_designator__c + ']' : '');
			handledItems.add(handleItemToAdd);
		}
		return JSON.serialize(handledItems);
	}

	@AuraEnabled(cacheable = true)
	public static string getAirlinesByRT(String rt) {
		String rtId = RecordTypeSingleton.getInstance().getMapRecordTypesBySObject('ICG_Account_Role_Detail__c').get(rt);
		return (JSON.serialize([SELECT Id, Name, RecordTypeId FROM ICG_Account_Role_Detail__c WHERE RecordtypeId = :rtId and isApproved__c = true ORDER BY Name ASC NULLS LAST])); //and Membership_Status__c = 'IATA member'
	}
	/****************************************************************************
	* @Method			: getRelatedAirlinesByRT
	* @Created			: 08/01/2020
	* @Description		: get all airlines by rt related to the facility
	* @param			: String facilityId - id of the facility
	* @param			: String rtName - name of the Record Type
	* @Returns			: String relatedAirlines - json containing all the related airlines by rt
	****************************************************************************/
	@AuraEnabled
	public static void saveAirlinesHandled(String addList, String deleteList, String facilityId ) {
		ICG_Account_Role_Detail__c fac = [Select Id,Name,Account_Role__r.Account__r.ICAO_designator__c,Account_Role__r.Account__r.IATACode__c,
		Account_Role__r.Account__r.Airline_designator__c, Account_Role__r.Account__r.Name from ICG_Account_Role_Detail__c Where Id =:facilityId];
		List<Account> airlines = [Select Id from Account where (ICAO_designator__c != null AND ICAO_designator__c =:fac.Account_Role__r.Account__r.ICAO_designator__c) OR
		(IATACode__c != null AND IATACode__c =:fac.Account_Role__r.Account__r.IATACode__c) OR (Airline_designator__c != null AND Airline_designator__c =:fac.Account_Role__r.Account__r.Airline_designator__c)
		OR Name LIKE :fac.account_Role__r.Account__r.Name];

		if(addList != null) {
			Set<id> addListParsed = (Set<id>)JSON.deserialize(addList, Set<id>.class);
			List<ICG_Account_Role_Detail_Relationship__c> acrrlist = new List<ICG_Account_Role_Detail_Relationship__c>();
			for (Id accid : addListParsed) {
				if(accid != null && accId.getSobjectType() == Schema.Account.SObjectType) {
					acrrlist.add(new ICG_Account_Role_Detail_Relationship__c(Handled_Airline__c = accid, ICG_Account_Role_Detail__c = facilityId));
				}else if(accid != null && accId.getSobjectType() == Schema.ICG_Account_Role_Detail__c.SObjectType && !airlines.isEmpty()) {
					acrrlist.add(new ICG_Account_Role_Detail_Relationship__c(Handled_Airline__c = airlines[0].Id, ICG_Account_Role_Detail__c = accid));
				}
			}
			if(!acrrlist.isEmpty()) {
				insert acrrlist;
			} 
		}
		if(deleteList != null) {
			Set<String> deleteListParsed = (Set<String>)JSON.deserialize(deleteList, Set<String>.class);
			Set<String> airlineDeleted = new Set<String>();
			set<String> stationsDeleted = new Set<String>();
			for (Id accid : deleteListParsed) {
				if(accid != null && accId.getSobjectType() == Schema.Account.SObjectType) {
					airlineDeleted.add(accId);
					stationsDeleted.add(facilityId);
				}else if(accid != null && accId.getSobjectType() == Schema.ICG_Account_Role_Detail__c.SObjectType && !airlines.isEmpty()) {
					airlineDeleted.add(airlines[0].Id);
					stationsDeleted.add(accid);
				}
			}
			List<ICG_Account_Role_Detail_Relationship__c> acrrlist = [Select id from ICG_Account_Role_Detail_Relationship__c where (ICG_Account_Role_Detail__c IN :stationsDeleted and (Handled_Airline__c IN:airlineDeleted))];
			if(!acrrlist.isEmpty()) {
				delete acrrlist;
			}
		}
	}

	@AuraEnabled
	public static Boolean saveHiddenOperatingStations(String hiddenOperatingStations, Id facilityId){
		String hiddenOperatingStationType;
		if (String.isNotBlank(hiddenOperatingStations) && String.isNotBlank(facilityId)) {
			hiddenOperatingStationType = hiddenOperatingStations.substringBefore(':');
			if (hiddenOperatingStationType != 'OperatingCargo' && hiddenOperatingStationType != 'OperatingRamp') {
				hiddenOperatingStationType = null;
			}
		}

		if (String.isBlank(hiddenOperatingStationType)) {
			return false;
		}

		ICG_Account_Role_Detail__c stationProfile;
		for (ICG_Account_Role_Detail__c currentRow : [SELECT Id, Hidden_Operating_Stations__c FROM ICG_Account_Role_Detail__c WHERE Id = :facilityId FOR UPDATE]) {
			if (stationProfile == null) {
				stationProfile = currentRow;
			}
		}

		if (stationProfile == null) {
			return false;
		}

		if (String.isBlank(stationProfile.Hidden_Operating_Stations__c)) {
			stationProfile.Hidden_Operating_Stations__c = hiddenOperatingStations;
		} else {
			List<String> newTypeAndValues = new List<String>();
			Boolean added = false;

			for (String currentTypeAndValues : stationProfile.Hidden_Operating_Stations__c.split('\\|')){
				if (currentTypeAndValues.startsWith(hiddenOperatingStationType)) {
					newTypeAndValues.add(hiddenOperatingStations);
					added = true;
				} else if (String.isNotBlank(currentTypeAndValues)){
					newTypeAndValues.add(currentTypeAndValues);
				}
			}
			if (!added) {
				newTypeAndValues.add(hiddenOperatingStations);
			}
			stationProfile.Hidden_Operating_Stations__c = String.join(newTypeAndValues, '|');
		}
		update stationProfile;
		return true;
	}
}