public class ANG_ISSP_PortalServiceHelper {
	/*
		Returns which countries are elegible for each portal service in the input set		
	*/
	public static Map<id, Set<String>> getElegibleCountries(Set<id> portalServiceIds) {
        Map<id, Set<String>> isoCountriesMap = new Map<id, Set<String>>();

        List<IATA_ISO_Country__c> isoCountriesList = [Select ISO_Code__c, ANG_Portal_Service__c from IATA_ISO_Country__c where ANG_Portal_Service__c in : portalServiceIds];  

        for(IATA_ISO_Country__c country : isoCountriesList) {
            if(isoCountriesMap.containsKey(country.ANG_Portal_Service__c)) {
                isoCountriesMap.get(country.ANG_Portal_Service__c).add(country.ISO_Code__c);
            } else {
                Set<String> isoCodes = new Set<String>();
                isoCodes.add(country.ISO_Code__c);
                isoCountriesMap.put(country.ANG_Portal_Service__c, isoCodes);
            }
        }
        
        return isoCountriesMap;
	}
}