/*
 *  @author: Constantin BUZDUGA, blue-infinity
 *  @description: This is a test class for the trgEnsureUniqueProductCountryCombination trigger on the
 *  ICCS Product Country object.
 *
 */

@isTest
private class trgEnsureUniqueProductCountryTest {
	static testMethod void test() {
		// Create a new ISO Country
		IATA_ISO_Country__c country = new IATA_ISO_Country__c(Name = 'France', ISO_Code__c = 'FR');
		insert country;

		// Create a new Product
		Product2 p = new Product2(Name = 'Test prod', Family = 'ICCS');
		insert p;

		// Create a new ICCS Product Country for this product
		ICCS_Product_Country__c pct = new ICCS_Product_Country__c(Product__c = p.Id, Country__c = country.Id);
		insert pct;

		// Create a new ICCS Product Currency for this ICCS Product Country
		ICCS_Product_Currency__c pcr = new ICCS_Product_Currency__c(CurrencyIsoCode = 'USD', ICCS_Product_Country__c = pct.Id);
		insert pcr;

		List<ICCS_Product_Currency__c> lstProductCurrencies = [SELECT Id FROM ICCS_Product_Currency__c];
		System.AssertEquals(1,lstProductCurrencies.size());

		// Create a new ICCS Product Currency for the product with the same currency as above, to test that
		// its insertion is blocked.
		try {
			pcr = new ICCS_Product_Currency__c(CurrencyIsoCode = 'USD', ICCS_Product_Country__c = pct.Id);
			insert pcr;
		} catch(Exception e) {}

		lstProductCurrencies = [SELECT Id FROM ICCS_Product_Currency__c];
		System.AssertEquals(1,lstProductCurrencies.size()); // Check that the bank account was not inserted


	}
}
