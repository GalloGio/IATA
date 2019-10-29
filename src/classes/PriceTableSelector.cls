public class PriceTableSelector {

	// private static variable referencing the class
	private static PriceTableSelector instance = null;
	// variable that contains the list of Price Table per Country
	private Map<Id, List<Price_Table__c>> priceTableByCountry;

	/**
	 * Private constructor
	 * @return
	 */
	public PriceTableSelector() {
		priceTableByCountry = new Map<Id, List<Price_Table__c>>();

		for(Price_Table__c pt : [SELECT Id, ISO_Country__c ,Type_Class_of_Agent__c FROM Price_Table__c]){

			if(!priceTableByCountry.containsKey(pt.ISO_Country__c)){
				// puts a new entry for the iso country and instantiates the map that will contain the corresponding price tables mapped by id
				priceTableByCountry.put(pt.ISO_Country__c, new List<Price_Table__c>());
			}
			// fills the maps of the price table per iso country
			priceTableByCountry.get(pt.ISO_Country__c).add(pt);
		}
	}

	/**
	 * Method that returns the instance of PriceTableSelector
	 * @return instance of the singleton
	 */
	public static PriceTableSelector getInstance(){
		if(instance == null){
			instance = new PriceTableSelector();
		} 
	    
	    return instance;
	}

	/**
	 * Method that returns the List of Price Tables for the respective ISO Country
	 * @param countryId the id of the ISO Country
	 * @return 			list of the price table object
	 */
	public List<Price_Table__c> getPriceTablesByISOCountry(Id countryId){

		if(!priceTableByCountry.containsKey(countryId)) return new List<Price_Table__c>();

		return priceTableByCountry.get(countryId);

	}
}