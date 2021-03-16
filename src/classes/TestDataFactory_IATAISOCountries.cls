@IsTest
public class TestDataFactory_IATAISOCountries {
	public static final String DEFAULTCOUNTRYNAME = 'Switzerland';
	public static final String DEFAULTISOCODE = 'CH';

	public static List<IATA_ISO_Country__c> createDefaultIATAISOCountries(Integer numberOfRecords){
		List<IATA_ISO_Country__c> iataISOCountryList = new List<IATA_ISO_Country__c>();

		for(Integer x = 0; x < numberOfRecords; x++){
			IATA_ISO_Country__c iataISOCountry = new IATA_ISO_Country__c(Name = DEFAULTCOUNTRYNAME, ISO_Code__c = DEFAULTISOCODE);
			iataISOCountryList.add(iataISOCountry);
		}
		return iataISOCountryList;
	}
}