@isTest
public class IATAIsoCountryDAO_Test {


	@testSetup static void setup() {

		List<IATA_ISO_Country__c> countryList = new List<IATA_ISO_Country__c>();

		countryList.add(new IATA_ISO_Country__c(Name='Canada', ISO_Code__c = 'CA', Case_BSP_Country__c = 'Canada', AIMS_Area_Name__c = 'CANADA', Region__C = 'Americas'));
		countryList.add(new IATA_ISO_Country__c(Name='Chile', ISO_Code__c = 'CL', Case_BSP_Country__c = 'Chile', AIMS_Area_Name__c = 'CHILE', Region__C = 'Americas', VAT_Validation_Required__c = true));
        countryList.add(new IATA_ISO_Country__c(Name='Mexico', ISO_Code__c = 'MX', Case_BSP_Country__c = '', AIMS_Area_Name__c = 'MEXICO', Region__C = 'Americas'));
        countryList.add(new IATA_ISO_Country__c(Name='United States', ISO_Code__c = 'US', AIMS_Area_Name__c = 'UNITED STATES', Region__C = 'Americas', VAT_Validation_Required__c = true));
        countryList.add(new IATA_ISO_Country__c(Name='Portugal', ISO_Code__c = 'PT', AIMS_Area_Name__c = 'PORTUGAL', Region__C = 'Europe', IEC_Zip_Postal_Code_required__c = true));

		insert countryList; 
	}
	
	/**
	 * Test the method that return a list of the IATA_ISO_Country__c.
	 */
	@isTest static void testGetIsoCountries(){

		Test.startTest();
		List<IATA_ISO_Country__c> isoCountryList = IATAIsoCountryDAO.getIsoCountries();
		System.assertEquals(isoCountryList.get(0).Name, 'Canada');
		System.assertEquals(isoCountryList.get(0).ISO_Code__c, 'CA');
		System.assertEquals(isoCountryList.size(), 5);
		Test.stopTest();
	} 

	/**
	 * Test the method that return a list of the IATA_ISO_Country__c filtered by IDs
	 */
	@isTest static void testGetIsoCountriesByIds(){

		Test.startTest();

		IATA_ISO_Country__c country = new IATA_ISO_Country__c(Name='Spain', ISO_Code__c='SP');
		insert country;
		IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(Name='China', ISO_Code__c='CH');
		insert country2;
		List<IATA_ISO_Country__c> isoCountryList = IATAIsoCountryDAO.getIsoCountriesByIds(new Set<ID>{country.ID});
		List<IATA_ISO_Country__c> isoCountryList2 = IATAIsoCountryDAO.getIsoCountriesByIds(new Set<String>{country2.ID});

		System.assertEquals(isoCountryList.size(), 1);
		System.assertEquals(isoCountryList.get(0).Name, 'Spain');
		System.assertEquals(isoCountryList.get(0).ISO_Code__c, 'SP');

		System.assertEquals(isoCountryList2.size(), 1);
		System.assertEquals(isoCountryList2.get(0).Name, 'China');
		System.assertEquals(isoCountryList2.get(0).ISO_Code__c, 'CH');

		Test.stopTest();
	} 

	/**
	 * Test the method that return a list of the IATA_ISO_Country__c 
	 * filtered by Contries Name
	 */
	@isTest static void testGetIsoCountryByCountriesName(){

		Test.startTest();

		Set<String> countrySet = new Set<String>{'Canada', 'Portugal'};
		List<IATA_ISO_Country__c> isoCountryList = IATAIsoCountryDAO.getIsoCountryByCountriesName(countrySet);

		System.assertEquals(isoCountryList.size(), 2);
		System.assertEquals(isoCountryList.get(0).Name, 'Canada');
		System.assertEquals(isoCountryList.get(1).Name, 'Portugal');

		Test.stopTest();
	} 

	/**
	 * Test the method that return a list of the IATA_ISO_Country__c 
	 * filtered by Iso Code
	 */
	@isTest static void testGetIsoCountryByIsoCode(){

		Test.startTest();

		Set<String> isoCodeSet = new Set<String>{'MX', 'PT'};
		List<IATA_ISO_Country__c> isoCountryList = IATAIsoCountryDAO.getIsoCountryByIsoCodes(isoCodeSet);

		System.assertEquals(isoCountryList.size(), 2);
		System.assertEquals(isoCountryList.get(0).Name, 'Mexico');
		System.assertEquals(isoCountryList.get(1).Name, 'Portugal');

		Test.stopTest();
	} 


	/**
	 * Test Method that return a list of IATA_ISO_Country__c 
	 * filtered by Region__C field
	 */
	@isTest static void testGetIsoCountriesByRegion(){

		Test.startTest();

		Set<String> regionSet = new Set<String>{'Europe'};
		List<IATA_ISO_Country__c> isoCountryList = IATAIsoCountryDAO.getIsoCountriesByRegion(regionSet);

		System.assertEquals(isoCountryList.size(), 1);
		System.assertEquals(isoCountryList.get(0).Name, 'Portugal');

		Test.stopTest();
	} 


	/**
	 * Test Method return a list of IATA_ISO_Country__c that have the flag
	 * IEC_Zip_Postal_Code_required__c == true
	 */
	@isTest static void testGetIsoCountriesByZipCodeRequired(){

		Test.startTest();

		List<IATA_ISO_Country__c> isoCountryList = IATAIsoCountryDAO.getIsoCountriesByZipCoderequired(true);

		System.assertEquals(isoCountryList.size(), 1);
		System.assertEquals(isoCountryList.get(0).Name, 'Portugal');

		Test.stopTest();
	}


	/**
	 * Test Method return a list of IATA_ISO_Country__c that have the flag
	 * VAT_Validation_Required__c == false
	 */
	@isTest static void testGetIsoCountriesByVatValidationRequired(){

		Test.startTest();

		List<IATA_ISO_Country__c> isoCountryList = IATAIsoCountryDAO.getIsoCountriesByVatValidationRequired(true);

		System.assertEquals(isoCountryList.size(), 2);
		System.assertEquals(isoCountryList.get(0).Name, 'Chile');
		System.assertEquals(isoCountryList.get(1).Name, 'United States');
		Test.stopTest();
	}


	/**
	 * Test Method return a list of IATA_ISO_Country__c that have field
	 * Case_BSP_Country__c != null Or Case_BSP_Country__c != '' 
	 */
	@isTest static void testGetIsoCountriesByCaseBSPCountryNotNull(){

		Test.startTest();

		List<IATA_ISO_Country__c> isoCountryList = IATAIsoCountryDAO.getIsoCountriesByCaseBSPCountryNotNull();

		System.assertEquals(isoCountryList.size(), 2);
		System.assertEquals(isoCountryList.get(0).Name, 'Canada');
		System.assertEquals(isoCountryList.get(1).Name, 'Chile');
		Test.stopTest();
	}

	/**
	 * Test Method return a list of IATA_ISO_Country__c filtered by 
	 * the Set passed by parameter
	 */
	@isTest static void testGetIsoCountriesByCaseBSPCountries(){

		Test.startTest();

		List<IATA_ISO_Country__c> isoCountryList = IATAIsoCountryDAO.getIsoCountriesByCaseBSPCountries(new Set<String>{'Canada'});

		System.assertEquals(isoCountryList.size(), 1);
		System.assertEquals(isoCountryList.get(0).Name, 'Canada');
		Test.stopTest();
	}


	/**
	 * Test Method return all IATA_ISO_Country__c that have the
	 * IEC_Zip_Postal_Code_required__c == true
	 */
	@isTest static void testGetIsoCountriesByAIMSAreaName(){

		Test.startTest();

		List<IATA_ISO_Country__c> isoCountryList = IATAIsoCountryDAO.getIsoCountriesByAIMSAreaName(new Set<String>{'CANADA', 'PORTUGAL'});

		System.assertEquals(isoCountryList.size(), 2);
		System.assertEquals(isoCountryList.get(0).Name, 'Canada');
		System.assertEquals(isoCountryList.get(1).Name, 'Portugal');

		List<IATA_ISO_Country__c> countrylist = IATAIsoCountryDAO.getIsoCountriesByAIMSAreaName('UNITED STATES');

		System.assertEquals(countrylist.size(), 1);
		System.assertEquals(countrylist.get(0).Name, 'United States');

		Test.stopTest();
	}


	/**
	 * Test Method that orders a list of IATA_ISO_Country__c by the datafield passed by parameter.
	 * 
	 */
	@isTest static void testSortIATAIsoCountryList(){

		Test.startTest();

		List<IATA_ISO_Country__c> isoCountryList = IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountries(), 'AIMS_Area_Name__c');

		System.assertEquals(isoCountryList.size(), 5);
		System.assertEquals(isoCountryList.get(0).AIMS_Area_Name__c, 'CANADA');
		System.assertEquals(isoCountryList.get(1).AIMS_Area_Name__c, 'CHILE');
		System.assertEquals(isoCountryList.get(2).AIMS_Area_Name__c, 'MEXICO');
		System.assertEquals(isoCountryList.get(3).AIMS_Area_Name__c, 'PORTUGAL');
		System.assertEquals(isoCountryList.get(4).AIMS_Area_Name__c, 'UNITED STATES');

		Test.stopTest();	

	}
}