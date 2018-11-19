/**
 * Data Access Object of IATA_Iso_State__c 
 */
public class IATAIsoStateDAO {

	private static Map<ID, IATA_ISO_State__c> mapIataIsoState;

	private static Map<String, IATA_ISO_State__c> mapIataIsoStateByName;

	private static Map<String, IATA_ISO_State__c> mapIataIsoStateByIsoCode;

	/**
	 * Method that fetch the Map - mapIataIsoState
	 *
	 * @return IATA_ISO_Country Map 
	 */
	private static Map<ID, IATA_ISO_State__c> fetchMapIataIsoState(){

		return new Map<ID, IATA_ISO_State__c>([SELECT Id, Name, ISO_Code__c, IATA_ISO_Country__c,ISO_CODE_STANDARD__c,IEC_Valid_SAP__c,
											    	  IATA_ISO_Country__r.Id, IATA_ISO_Country__r.Name, IATA_ISO_Country__r.ISO_Code__c
											   FROM IATA_ISO_State__c
											   ORDER BY Name]);
	}

	/**
	 * Method that return the mapIataIsoCountry using as key an ID of IATA_ISO_Country__c
	 * 
	 * @return Map of Iata_Iso_Country 
	 */
	private static Map<ID, IATA_ISO_State__c> getMapIataIsoState() {

		if(IATAIsoStateDAO.mapIataIsoState == null) {
			IATAIsoStateDAO.mapIataIsoState = IATAIsoStateDAO.fetchMapIataIsoState();
		}
		return IATAIsoStateDAO.mapIataIsoState;
	}

	/**
	 * Method that return the mapIataIsoState using as key a state name of IATA_ISO_State__c
	 * 
	 * @return Map of IATA_ISO_State__c 
	 */
	private static Map<String, IATA_ISO_State__c> getMapIataIsoStateByName(){
		if(IATAIsoStateDAO.mapIataIsoStateByName == null) {

			IATAIsoStateDAO.mapIataIsoStateByName = new Map<String, IATA_ISO_State__c>();

			for(IATA_ISO_State__c state : IATAIsoStateDAO.getIsoStates()){
				IATAIsoStateDAO.mapIataIsoStateByName.put(state.Name, state);
			}	
		}
		return IATAIsoStateDAO.mapIataIsoStateByName;
	}

	/**
	 * Method that return the mapIataIsoState using as key a Iso Code of IATA_ISO_State__c
	 * 
	 * @return Map of IATA_ISO_State__c 
	 */
	private static Map<String, IATA_ISO_State__c> getMapIataIsoStateByIsoCode(){
		if(IATAIsoStateDAO.mapIataIsoStateByIsoCode == null) {

			IATAIsoStateDAO.mapIataIsoStateByIsoCode = new Map<String, IATA_ISO_State__c>();

			for(IATA_ISO_State__c state : IATAIsoStateDAO.getIsoStates()){
				IATAIsoStateDAO.mapIataIsoStateByIsoCode.put(state.ISO_Code__c, state);
			}	
		}
		return IATAIsoStateDAO.mapIataIsoStateByIsoCode;
	}

	/**
	 * Method that return IATA_ISO_Country list
	 * @return List of IATA_ISO_Country
	 */
	public static List<IATA_ISO_State__c> getIsoStates(){
		return IATAIsoStateDAO.getMapIataIsoState().values();
	}


	/**
	 * Method that return IATA_ISO_State list filtered by ids list
	 *
	 * @param List of Ids
	 * @return List of IATA_ISO_State
	 */
	public static List<IATA_ISO_State__c> getIsoStatesByIds(Set<ID> idList){

		List<IATA_ISO_State__c> isoStateList = new List<IATA_ISO_State__c>();
		
		for(Id isoStateId : idList){
			if(IATAIsoStateDAO.getMapIataIsoState().containsKey(isoStateId)){
				isoStateList.add(IATAIsoStateDAO.getMapIataIsoState().get(isoStateId));
			}
		}
		return isoStateList;
	}

	/**
	 * Method that return IATA_ISO_State list filtered by ids list
	 *
	 * @param List of Ids
	 * @return List of IATA_ISO_State
	 */
	public static List<IATA_ISO_State__c> getIsoStatesByIds(Set<String> idList){
		return IATAIsoStateDAO.getIsoStatesByIds(new Set<Id>((List<Id>) new List<String>(idList)));
	}


	/**
	 * Method that return IATA_ISO_State list filtered by Name
	 *
	 * @param Set of String - Countries
	 * @return List of IATA_ISO_Country
	 */
	public static List<IATA_ISO_State__c> getIsoStateByStateName(Set<String> isoStates){

		List<IATA_ISO_State__c> isoStateList = new List<IATA_ISO_State__c>();
		
		for(String state : isoStates){
			if(IATAIsoStateDAO.getMapIataIsoStateByName().containsKey(state)){
				isoStateList.add(IATAIsoStateDAO.getMapIataIsoStateByName().get(state));
			}
		}
		return isoStateList;
	}

	/**
	 * Method that return IATA_ISO_State list filtered by ISO_Code
	 *
	 * @param Set of String - Countries
	 * @return List of IATA_ISO_Country
	 */
	public static List<IATA_ISO_State__c> getIsoStateByIsoCodes(Set<String> isoCodes){

		List<IATA_ISO_State__c> isoStateList = new List<IATA_ISO_State__c>();
		
		for(String code : isoCodes){
			if(IATAIsoStateDAO.getMapIataIsoStateByIsoCode().containsKey(code)){
				isoStateList.add(IATAIsoStateDAO.getMapIataIsoStateByIsoCode().get(code));
			}
		}
		return isoStateList;
	}

	/**
	 * Sort the list of IATA_ISO_Country__c using as field a parameter
	 *
	 * @param List<IATA_ISO_Country__c> stateList
	 * @param String sortedField 
	 * @return List of IATA_ISO_Country__c
	 */
	public static List<IATA_ISO_State__c> sortIATAIsoStateList(List<IATA_ISO_State__c> stateList, String field){

		List<IATA_ISO_State__c> sortedIsoStateList = new List<IATA_ISO_State__c>();
		List<IATAIsoStateWrapper> sortedIsoStateWrapper = new List<IATAIsoStateWrapper>();
		
		for(IATA_ISO_State__c state : stateList){
			sortedIsoStateWrapper.add(new IATAIsoStateWrapper(state, field));
		}

		sortedIsoStateWrapper.sort();

		for(IATAIsoStateWrapper c : sortedIsoStateWrapper){
			sortedIsoStateList.add(c.state);
		}

		return sortedIsoStateList;
	}

	/**
	 * Generic class that implements sorted list for 
	 * IATA_ISO_State__c object
	 */ 
	public class IATAIsoStateWrapper implements Comparable {

	    private IATA_ISO_State__c state;
	    private String field;
	    
	    // Constructor 
	    public IATAIsoStateWrapper(IATA_ISO_State__c c, String field) {
	        this.state = c;
	        this.field = field;
	    }
	    
	    // Compare opportunities based on the opportunity amount.
	    public Integer compareTo(Object compareTo) {
	        // Cast argument to OpportunityWrapper
	        IATAIsoStateWrapper compareToContry = (IATAIsoStateWrapper)compareTo;
	        
	        // The return value of 0 indicates that both elements are equal.
	        Integer returnValue = 0;
	        if ((String)state.get(field) > (String)compareToContry.state.get(field)) {
	            // Set return value to a positive value.
	            returnValue = 1;
	        } else if ((String)state.get(field) < (String)compareToContry.state.get(field)) {
	            // Set return value to a negative value.
	            returnValue = -1;
	        }
	        
	        return returnValue;       
	    }
	}

}