/*
 * @author: Constantin BUZDUGA, blue-infinity
 * @description: This trigger checks that the combination (Product, Country, Currency) is unique. If it's not,
 *     it raises an error and prevents the insertion or update of the ICCS Product Currency record.
 */

trigger trgEnsureUniqueProductCountryCurrency on ICCS_Product_Currency__c (before insert, before update) {
	// List of all ICCS_Product_Currency__c records
	List<ICCS_Product_Currency__c> lstProdCurrency = [SELECT Id, Country__c, Currency__c, Product__c FROM ICCS_Product_Currency__c];

	// Create a map, where the key is a string [Product]-[Country]-[Currency] and the value is the record
	Map<String, ICCS_Product_Currency__c> mapProdCurrencyObjPerRefKey = new Map<String,ICCS_Product_Currency__c>();
	for (ICCS_Product_Currency__c pc : lstProdCurrency) {
		mapProdCurrencyObjPerRefKey.put(pc.Product__c + '-' + pc.Country__c + '-' + pc.Currency__c, pc);
	}

	// Check for the new/updated records that the combination doesn't already exist
	for (ICCS_Product_Currency__c pc : Trigger.new) {
		String tmpKey = pc.Product__c + '-' + pc.Country__c + '-' + pc.Currency__c;
		ICCS_Product_Currency__c tmpPC = mapProdCurrencyObjPerRefKey.get(tmpKey);

		// If it exists and it's not the same record (like in the case of an update), raise an error
		if (tmpPC != null && tmpPC.Id != pc.Id) {
			pc.addError('This Currency already exists in the selected Country for the selected Product. Please select a different Currency.');
		}
	}
}
