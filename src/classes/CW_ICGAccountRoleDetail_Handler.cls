/**
 * @description		Handler of ICG_Account_Role_Detail (facility) trigger
 *
 * Edit Log:
 * @history			2020/03/06  |  Creation.
 */
public with sharing class CW_ICGAccountRoleDetail_Handler {
	/*Constant SPLITTER*/
	private static final String SPLITTER = ';';
	/**
	 * @description		handler After Insert
	 * @param			Map<Id, ICG_Account_Role_Detail__c> newMap
	 */
	public static void handleAfterInsert(Map<Id, ICG_Account_Role_Detail__c> newMap) {
		futureUpdateARDs(newMap.keySet(), false);
		CW_OneSourceGxaProvision.provisionOrDeprovisionStations(newMap.values(), null);
	}
	/**
	 * @description		handler After Update
	 * @param			Map<Id, ICG_Account_Role_Detail__c> newMap
	 */
	public static void handleAfterUpdate(Map<Id, ICG_Account_Role_Detail__c> newMap,Map<Id, ICG_Account_Role_Detail__c> oldMap) {
		futureUpdateARDs(newMap.keySet(), false);
		if(newMap.size() == 1) {
			CW_Utilities.sendApproveOrRejectMails(newMap.values()[0], oldMap.values()[0]);
		}
		CW_OneSourceGxaProvision.provisionOrDeprovisionStations(newMap.values(), oldMap);

	}
	/**
	 * @description		handler After Update
	 * @param			Map<Id, ICG_Account_Role_Detail__c> newMap
	 */
	public static void handleAfterDelete(Map<Id, ICG_Account_Role_Detail__c> oldMap) {
		CW_OneSourceGxaProvision.provisionOrDeprovisionStations(null, oldMap);
	}
	/**
	 * @description		method to update search facilities´s fields based on formula fields
	 * 
	 * @param			String inputText to be modified
	 */
	public static void futureUpdateARDs(Set<Id> lstFacilities, Boolean callQueueable) {
		if(callQueueable) {
			System.enqueueJob(new CW_ICG_Facility_Queuable(lstFacilities));
		} else {
			updateSearchByFormulaValues(lstFacilities);
		}
	}
	
	/**
	 * @description		@future method to update search facilities´s fields based on formula fields
	 * 
	 * @param			List<Id> lstFacilities
	 */
	private static void updateSearchByFormulaValues(Set<Id> lstFacilities) {
		List<ICG_Account_Role_Detail__c> ardFinal = new List<ICG_Account_Role_Detail__c>();
		List<ICG_Account_Role_Detail__c> ardToUpdate = [SELECT Id, Company_FOR__c, City_FOR__c, Country_FOR__c,
														search_city__c, search_company__c, search_country__c
														FROM ICG_Account_Role_Detail__c
														WHERE Id IN :lstFacilities];
		System.debug(LoggingLevel.FINE, 'updateSearchByFormulaValues.lstARDtoUpdate: ' + ardToUpdate);
		for(ICG_Account_Role_Detail__c facility : ardToUpdate) {
			Boolean toUpdate = false;
			
			if(facility.City_FOR__c != null) {
				String citySimple = translationText(facility.City_FOR__c);
				String cityUmlaute = translationUmlaute(facility.City_FOR__c);
				if(facility.search_city__c == null
						|| citySimple != facility.search_city__c.split(SPLITTER)[0].toLowerCase()
						|| (facility.search_city__c.split(SPLITTER).size() > 2 
							&& cityUmlaute != facility.search_city__c.split(SPLITTER)[2].toLowerCase()) ) {
					facility.search_city__c = citySimple 
											+ SPLITTER + facility.City_FOR__c 
											+ SPLITTER + cityUmlaute;
					toUpdate = true;
				}
			}
			if(facility.Company_FOR__c != null) {
				String companySimple = translationText(facility.Company_FOR__c);
				String companyUmlaute = translationUmlaute(facility.Company_FOR__c);

				if(facility.search_company__c == null 
						|| facility.search_company__c == ''
						|| companySimple != facility.search_company__c.split(SPLITTER)[0].toLowerCase()
						|| (facility.search_company__c.split(SPLITTER).size() > 2 
							&& companyUmlaute != facility.search_company__c.split(SPLITTER)[2].toLowerCase()) ) {
					facility.search_company__c = companySimple 
												+ SPLITTER + facility.Company_FOR__c
												+ SPLITTER + companyUmlaute;
					toUpdate = true;
				}   
			}
			if(facility.Country_FOR__c != null) {
				String countrySimple = translationText(facility.Country_FOR__c);
				String countryUmlaute = translationUmlaute(facility.Country_FOR__c);

				if(facility.search_country__c == null
						|| countrySimple != facility.search_country__c.split(SPLITTER)[0].toLowerCase()
						|| ( facility.search_country__c.split(SPLITTER).size() > 2 
							&& countryUmlaute != facility.search_country__c.split(SPLITTER)[2].toLowerCase()) ) {
					facility.search_country__c = countrySimple 
												+ SPLITTER + facility.Country_FOR__c
												+ SPLITTER + countryUmlaute;
					toUpdate = true;
				}
			}

			if(toUpdate) {
				ardFinal.add(facility);
			}
		}
		if (!ardFinal.isEmpty()) {
			Database.SaveResult [] updateResult = Database.update(ardFinal, false);
			System.debug(LoggingLevel.FINE, 'updateResult : ' + JSON.serialize(updateResult));
		}
	}
	/**
	 * @description		check formula values after update account row
	 * 
	 * @param			List<Account> lstFacilities
	 */
	public static void checkFacilityFields(Map<Id, Account> mapNews, Map<Id, Account> mapOlds) {
		Set<Id> lstAccIds = new Set<Id>();
		for(Account acc : mapNews.values()) {
			if(mapNews.get(acc.Id).Name != mapOlds.get(acc.Id).Name) {
				lstAccIds.add(acc.Id);
			}
		}
		if(!lstAccIds.isEmpty()) {
			Map<Id,ICG_Account_Role_Detail__c> results = new Map<Id,ICG_Account_Role_Detail__c>([SELECT Id FROM ICG_Account_Role_Detail__c WHERE Account_Role__r.Account__c IN :lstAccIds]);
			Set<Id> resultIds = results.keySet();
			System.debug(LoggingLevel.FINE, 'resultIds : ' + JSON.serialize(resultIds));
			futureUpdateARDs(resultIds, true);
		}
	}
	/**
	 * @description		check formula values after update account row
	 * 
	 * @param			List<Account> lstFacilities
	 */
	public static void checkFacilityFields(Map<Id, IATA_ISO_City__c> mapNews, Map<Id, IATA_ISO_City__c> mapOlds) {
		Set<Id> lstCityIds = new Set<Id>();
		for(IATA_ISO_City__c city : mapNews.values()) {
			if(mapNews.get(city.Id).Name != mapOlds.get(city.Id).Name) {
				lstCityIds.add(city.Id);
			}
		}
		if(!lstCityIds.isEmpty()) {
			Map<Id,ICG_Account_Role_Detail__c> results = new Map<Id,ICG_Account_Role_Detail__c>([SELECT Id FROM ICG_Account_Role_Detail__c WHERE Account_Role__r.Account__r.Business_City__c IN :lstCityIds]);
			Set<Id> resultIds = results.keySet();
			System.debug(LoggingLevel.FINE, 'resultIds : ' + JSON.serialize(resultIds));
			futureUpdateARDs(resultIds, false);
		}
	}
	/**
	 * @description		check formula values after update account row
	 * 
	 * @param			List<Account> lstFacilities
	 */
	public static void checkFacilityFields(Map<Id, IATA_ISO_Country__c> mapNews, Map<Id, IATA_ISO_Country__c> mapOlds) {
		Set<Id> lstCountryIds = new Set<Id>();
		for(IATA_ISO_Country__c country : mapNews.values()) {
			if(mapNews.get(country.Id).Name != mapOlds.get(country.Id).Name) {
				lstCountryIds.add(country.Id);
			}
		}
		System.debug(LoggingLevel.FINE, 'lstCountryIds : ' + JSON.serialize(lstCountryIds));
		if(!lstCountryIds.isEmpty()) {
			Map<Id,ICG_Account_Role_Detail__c> results = new Map<Id,ICG_Account_Role_Detail__c>([SELECT Id FROM ICG_Account_Role_Detail__c WHERE Account_Role__r.Account__r.Business_City__c IN :lstCountryIds]);
			Set<Id> resultIds = results.keySet();
			System.debug(LoggingLevel.FINE, 'resultIds : ' + JSON.serialize(resultIds));
			futureUpdateARDs(resultIds, false);
		}
	}
	/**
	 * @description		replace special chars:
	 *                  çÇáéíóúýÁÉÍÓÚÝàèìòùÀÈÌÒÙãõñäëïöüÿÄËÏÖÜÃÕÑâêîôûÂÊÎÔÛ
	 * 
	 * @param			String inputText to be modified
	 * @return          String outputText with the search translation
	 */
	public static String translationText(String inputText) {
		String outputText = inputText;

		if(outputText != null) {
			outputText = outputText.replaceAll('[áÁàÀãÄäâÂ]', 'a');
			outputText = outputText.replaceAll('[éÉèÈëËêÊ]', 'e');
			outputText = outputText.replaceAll('[íÍìÌïÏîÎ]', 'i');
			outputText = outputText.replaceAll('[óÓòÒõöÖÕôÔ]', 'o');
			outputText = outputText.replaceAll('[úÚùÙüûÛÜ]', 'u');
			outputText = outputText.replaceAll('[çÇ]', 'c');
			outputText = outputText.replaceAll('[ýÝÿ]', 'y');
			outputText = outputText.replaceAll('[ñÑ]', 'n');

			outputText = outputText.toLowerCase();
		}
		
		return outputText;
	}
	/**
	 * @description		replace umlaute special chars:
	 *                  äöüßÄÖÜ
	 * 
	 * @param			String inputText to be modified
	 * @return          String outputText with the search translation
	 */
	public static String translationUmlaute(String inputText) {
		String outputText = inputText;

		if(outputText != null) {
			outputText = outputText.replaceAll('[äÄ]', 'ae');
			outputText = outputText.replaceAll('[öÖ]', 'oe');
			outputText = outputText.replaceAll('[üÜ]', 'ue');
			outputText = outputText.replaceAll('[ß]', 'ss');

			outputText = outputText.toLowerCase();
		}
		
		return outputText;
	}

}