@isTest
private class ANG_ISSP_PortalServiceHelperTest {
	
	@testSetup
	static void setup() {		
		Portal_Applications__c easyPay1 = new Portal_Applications__c (
			Name = 'easyPay1'
		);

		Portal_Applications__c easyPay2 = new Portal_Applications__c (
			Name = 'easyPay2'
		);

		insert new List<Portal_Applications__c>{easyPay1,easyPay2};

		IATA_ISO_Country__c portugal = new IATA_ISO_Country__c (
			Name = 'Portugal_test',
			ISO_Code__c = 'PT',
			ANG_Portal_Service__c = easyPay1.id
		);

		IATA_ISO_Country__c switzerland = new IATA_ISO_Country__c (
			Name = 'Switzerland_test',
			ISO_Code__c = 'CH',
			ANG_Portal_Service__c = easyPay1.id
		);

		IATA_ISO_Country__c germany = new IATA_ISO_Country__c (
			Name = 'Germany_test',
			ISO_Code__c = 'DE',
			ANG_Portal_Service__c = easyPay2.id
		);	

		insert new List<IATA_ISO_Country__c>{portugal,switzerland,germany};
	}

	@isTest 
	static void getElegibleCountriesTest() {
		List<Portal_Applications__c> portals = [Select id, name from Portal_Applications__c where name like 'easyPay%'];

		Map<id, Set<String>> isoCountriesMap = ANG_ISSP_PortalServiceHelper.getElegibleCountries(portals);

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

	@isTest 
	static void isIepPortalServiveTest() {
		System.assert(ANG_ISSP_PortalServiceHelper.isIepPortalService('IATA EasyPay (EDENRED)'));
		System.assert(ANG_ISSP_PortalServiceHelper.isIepPortalService('IATA EasyPay (MSTS)'));
		System.assert(ANG_ISSP_PortalServiceHelper.isIepPortalService('IATA EasyPay (WEX)'));
		System.assert(!ANG_ISSP_PortalServiceHelper.isIepPortalService('IATA EasyPay'));
	}		
}