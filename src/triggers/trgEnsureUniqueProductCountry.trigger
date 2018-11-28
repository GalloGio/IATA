/*
 * @author: Constantin BUZDUGA, blue-infinity
 * @description: This trigger checks that the pair (Product, Country) is unique. If it's not,
 *     it raises an error and prevents the insertion or update of the ICCS Product Country record.
 */
 
trigger trgEnsureUniqueProductCountry on ICCS_Product_Country__c (before insert, before update) {
    // List of all ICCS_Product_Country__c records
    List<ICCS_Product_Country__c> lstProdCountry = [SELECT Id, Country__r.Name, Product__r.Name FROM ICCS_Product_Country__c];
    
    // Create a map, where the key is a string [Product]-[Country] and the value is the record
    Map<String, ICCS_Product_Country__c> mapProdCountryObjPerRefKey = new Map<String,ICCS_Product_Country__c>();
    for (ICCS_Product_Country__c pc : lstProdCountry) {
        mapProdCountryObjPerRefKey.put(pc.Product__r.Name + '-' + pc.Country__r.Name, pc);
    }
    
    // Create a map of all ICCS Products
    Map<Id, Product2> mapProductsPerId = new Map<Id, Product2>([SELECT Id, Name FROM Product2 WHERE Family = 'ICCS']);
    
    // Create a map of all IATA ISO Countries
    Map<Id,IATA_ISO_Country__c> mapISOCountriesPerId = new Map<Id,IATA_ISO_Country__c>(IATAIsoCountryDAO.getIsoCountries()); 
    
    // Check for the new/updated records that the combination doesn't already exist
    for (ICCS_Product_Country__c pc : Trigger.new) {
    	String tmpKey;
    	
    	if (mapProductsPerId.get(pc.Product__c) != null && mapISOCountriesPerId.get(pc.Country__c) != null) {
    		tmpKey = mapProductsPerId.get(pc.Product__c).Name + '-' + mapISOCountriesPerId.get(pc.Country__c).Name;
    	} else {
    		pc.addError('ERROR: Id not found: mapProductsPerId.get(' + pc.Product__c + ') = ' + mapProductsPerId.get(pc.Product__c) + '; mapISOCountriesPerId.get(' + pc.Country__c + ') = ' + mapISOCountriesPerId.get(pc.Country__c));
    	}
    	
        ICCS_Product_Country__c tmpPC = mapProdCountryObjPerRefKey.get(tmpKey);
        
        if (tmpPC != null && tmpPC.Id != pc.Id) {
            pc.addError('This Product already exists in the selected Country. Please select a different Country or Product.');
        } else {
        	mapProdCountryObjPerRefKey.put(tmpKey, pc);
        }
    }
}