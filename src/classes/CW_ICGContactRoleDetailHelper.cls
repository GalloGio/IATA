public without sharing class CW_ICGContactRoleDetailHelper {
	/**
	 * @description		withouth sharing access from CW_LandingSearchBarController.getCompanyNamesList()
	 *					return a map of companyNames and how many times each companyName is storaged in salesforce
	 *					
	 * @param			String COMPANYSTR
	 * @return			Map<String, CW_LandingSearchBarController.RowInfo> mapUpdated
	 */
	public static Map<String, CW_LandingSearchBarController.RowInfo> helperGetCompanyNamesWithoutSharing(String COMPANYSTR, Boolean splitByCountry) {
		Map<String, CW_LandingSearchBarController.RowInfo> mapUpdated = new Map<String, CW_LandingSearchBarController.RowInfo> ();
		List<ICG_Account_Role_Detail__c> stations = [SELECT id, Name, Company_FOR__c, Search_By_Company__c, City_FOR__c, Country_FOR__c
		FROM ICG_Account_Role_Detail__c
		WHERE isApproved__c = true AND Company_FOR__c != null AND Country_FOR__c != null order by Company_FOR__c asc];
		for(ICG_Account_Role_Detail__c ard : stations) {
			
			String currentKey = ard.Company_FOR__c;
			String secondKey = ard.Company_FOR__c+'##'+ard.Country_FOR__c;
			if (mapUpdated.containsKey(currentKey)) {
				mapUpdated.get(currentKey).value += 1;
				mapUpdated.get(currentKey).stationsIds += '#'+ard.Id;		
				if(!mapUpdated.get(currentKey).description.containsIgnoreCase(ard.Country_FOR__c)){
					mapUpdated.get(currentKey).description = '(All Countries)';
				}
			} else {
				CW_LandingSearchBarController.RowInfo loc = new CW_LandingSearchBarController.RowInfo(ard.Search_By_Company__c,ard.Company_FOR__c,1,null,' (' + ard.Country_FOR__c + ')',COMPANYSTR,currentKey,null, ard.Id);
				mapUpdated.put(currentKey, loc);
			}

			if(splitByCountry == true){
				if (mapUpdated.containsKey(secondKey)) {
					mapUpdated.get(secondKey).value += 1;
					mapUpdated.get(secondKey).stationsIds += '#'+ard.Id;		
				} else {
					CW_LandingSearchBarController.RowInfo loc = new CW_LandingSearchBarController.RowInfo(ard.Search_By_Company__c+'#'+ard.Country_FOR__c,ard.Company_FOR__c,1,null,' (' + ard.Country_FOR__c + ')',COMPANYSTR,secondKey,null,ard.Id);
					mapUpdated.put(secondKey, loc);
				}
			}

			String dynamicKey = currentKey+'##'+ard.City_FOR__c+'##'+ard.Name;
			if (mapUpdated.containsKey(dynamicKey)) {
				mapUpdated.get(dynamicKey).value += 1;
				mapUpdated.get(dynamicKey).stationsIds += '#'+ard.Id;	
			} else {
				CW_LandingSearchBarController.RowInfo loc = new CW_LandingSearchBarController.RowInfo(ard.Search_By_Company__c+'#'+ard.City_FOR__c+'#'+ard.Name,ard.Name,1,null,' (' + ard.City_FOR__c +', '+ard.Country_FOR__c + ')',CW_LandingSearchBarController.STATIONSTR,dynamicKey,null,ard.Id);
				mapUpdated.put(dynamicKey, loc);
			}
			
		}
		if(splitByCountry == true){
			for(ICG_Account_Role_Detail__c ard : stations) {
				if(mapUpdated.get(ard.Company_FOR__c) != null && mapUpdated.get(ard.Company_FOR__c).description != '(All Countries)') mapUpdated.remove(ard.Company_FOR__c);
			}
		}
		return mapUpdated;
	}
	public static Map<String, CW_LandingSearchBarController.RowInfo> helperGetCompanyNamesWithoutSharing(String COMPANYSTR){
		return helperGetCompanyNamesWithoutSharing(COMPANYSTR,true);
	}
}