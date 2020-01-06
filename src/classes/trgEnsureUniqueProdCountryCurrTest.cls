/*
 *  @author: Constantin BUZDUGA, blue-infinity
 *  @description: This is a test class for the trgEnsureUniqueProductCountryCurrency trigger on the
 *  ICCS Product Currency object.
 *
 */

@isTest
private class trgEnsureUniqueProdCountryCurrTest {
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

		List<ICCS_Product_Country__c> lstProductCountries = [SELECT Id FROM ICCS_Product_Country__c];
		System.AssertEquals(1,lstProductCountries.size());

		// Create a new ICCS Product Country for the product with the same country as above, to test that
		// its insertion is blocked.
		try {
			pct = new ICCS_Product_Country__c(Product__c = p.Id, Country__c = country.Id);
			insert pct;
		} catch(Exception e) {}

		lstProductCountries = [SELECT Id FROM ICCS_Product_Country__c];
		System.AssertEquals(1,lstProductCountries.size()); // Check that the bank account was not inserted


	}
}
