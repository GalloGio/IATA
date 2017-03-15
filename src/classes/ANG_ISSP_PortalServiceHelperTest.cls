@isTest
private class ANG_ISSP_PortalServiceHelperTest {
	
	@testSetup
	static void setup() {		
		Portal_Applications__c easyPay1 = new Portal_Applications__c (
			Name = 'easyPay1'
		);

		insert easyPay1;

		Portal_Applications__c easyPay2 = new Portal_Applications__c (
			Name = 'easyPay2'
		);

		insert easyPay2;		

		IATA_ISO_Country__c portugal = new IATA_ISO_Country__c (
			Name = 'Portugal_test',
			ISO_Code__c = 'PT',
			ANG_Portal_Service__c = easyPay1.id
		);

		insert portugal;

		IATA_ISO_Country__c switzerland = new IATA_ISO_Country__c (
			Name = 'Switzerland_test',
			ISO_Code__c = 'CH',
			ANG_Portal_Service__c = easyPay1.id
		);

		insert switzerland;

		IATA_ISO_Country__c germany = new IATA_ISO_Country__c (
			Name = 'Germany_test',
			ISO_Code__c = 'DE',
			ANG_Portal_Service__c = easyPay2.id
		);
		
		insert germany;

	}

	@isTest 
	static void test_method_one() {
		List<Portal_Applications__c> portals = [Select id, name from Portal_Applications__c where name like 'easyPay%'];
		Set<id> ids = new Set<id>();
		for (Portal_Applications__c portal : portals) {
			ids.add(portal.id);
		}

		Map<id, Set<String>> isoCountriesMap = ANG_ISSP_PortalServiceHelper.getElegibleCountries(ids);

		for (Portal_Applications__c portal : portals) {
			Set<String> isoCodes = isoCountriesMap.get(portal.id);

			if(portal.name == 'easyPay1') {
				System.assert(isoCodes.contains('PT'));
				System.assert(isoCodes.contains('CH'));
				System.assert(!isoCodes.contains('DE'));
			} else {
				System.assert(isoCodes.contains('DE'));
				System.assert(!isoCodes.contains('PT'));
				System.assert(!isoCodes.contains('CH'));				
			}
		}
	}
		
}