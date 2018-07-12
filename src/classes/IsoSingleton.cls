public class IsoSingleton{
	
		private  static IsoSingleton instance = null;
		public  map<string,IATA_ISO_Country__c> IsoCountriesPerAcliCountryNames {get;private set;}
	
		private IsoSingleton(){
					IsoCountriesPerAcliCountryNames = new map<string,IATA_ISO_Country__c>();
					for(IATA_ISO_Country__c isoC : IATAIsoCountryDAO.getIsoCountries()){
							if(isoC.Acli_Country__c  <> null)							
							IsoCountriesPerAcliCountryNames.put(isoC.Acli_Country__c.trim(),isoC);
						
													}
						
			}
	
	  public static IsoSingleton getInstance(){
	  
	  	 if(instance == null) instance = new IsoSingleton();
	        return instance;
	  
	  }
	 
	
}