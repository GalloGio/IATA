public class ANG_ISSP_PortalServiceHelper {

    private static final String IEP_PORTAL_SERVICES = 'IATA EasyPay (EDENRED),IATA EasyPay (MSTS),IATA EasyPay (WEX)';
    public static final String IATA_EASYPAY_EDENRED = 'IATA EasyPay (EDENRED)';
    public static final String IATA_EASYPAY_MSTS = 'IATA EasyPay (MSTS)';
    public static final String IATA_EASYPAY_WEX = 'IATA EasyPay (WEX)';
    private static set<String> IEP_PORTAL_SERVICES_SET;
    public static final String TRAVEL_AGENT = 'Travel Agent';
    public static final String CARGO_AGENT = 'Cargo Agent';
    public static final String STATUS_NO_IEP_ACCOUNT = 'No IEP Account';
    public static final String STATUS_OPEN = 'Open';
    public static final String STATUS_IN_PROGRESS = 'In Progress';
    
	/*
		Returns which countries are elegible for each portal service in the input set		
	*/
	public static Map<id, Set<String>> getElegibleCountries(Set<id> portalServiceIds) {
        Map<id, Set<String>> isoCountriesMap = new Map<id, Set<String>>();

        List<IATA_ISO_Country__c> isoCountriesList = [Select ISO_Code__c, ANG_Portal_Service__c from IATA_ISO_Country__c where ANG_Portal_Service__c in : portalServiceIds];  

        for (IATA_ISO_Country__c country : isoCountriesList) {
            if (isoCountriesMap.containsKey(country.ANG_Portal_Service__c)) {
                isoCountriesMap.get(country.ANG_Portal_Service__c).add(country.ISO_Code__c);
            } else {
                Set<String> isoCodes = new Set<String>();
                isoCodes.add(country.ISO_Code__c);
                isoCountriesMap.put(country.ANG_Portal_Service__c, isoCodes);
            }
        }
        
        return isoCountriesMap;
	}

    public static Map<id, Set<String>> getElegibleCountries(List<Portal_Applications__c> portals) {
        Set<id> ids = new Set<id>();
        for (Portal_Applications__c portal : portals) {
            ids.add(portal.id);
        }
        
        return getElegibleCountries(ids);
    }


    /*
        Checks if the service name is a IEP Portal Service
    */
    public static Boolean isIepPortalService(String serviceName) {
        if (IEP_PORTAL_SERVICES_SET == null) {
            List<String> l = IEP_PORTAL_SERVICES.split(',');
            IEP_PORTAL_SERVICES_SET = new Set<String>();
            IEP_PORTAL_SERVICES_SET.addAll(l);
        }

        return IEP_PORTAL_SERVICES_SET.contains(serviceName);
    }
}