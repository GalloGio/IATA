/**
 * Data Access Object of Code_Range__c 
 */
public class CodeRangeDAO {
	
	private static Map<ID, Code_Range__c> mapCodeRange;

	private static Map<String, Code_Range__c> mapCodeRangeByName;

	/**
	 * Method that fetch the Map - mapCodeRange
	 *
	 * @return Code_Range__c Map 
	 */
	private static Map<ID, Code_Range__c> fetchMapCodeRange(){

		return new Map<ID, Code_Range__c>([SELECT Id, Name,	IATA_ISO_State__r.Name, Area__c, Area_Code__c, Prefix__c,
                 								  IATA_ISO_Country__c, IATA_ISO_State__c, Max_Range__c, Min_Range__c, ProgramCode__c, Program__c 
										   FROM Code_Range__c]);
	}

	/**
	 * Method that return the mapCodeRange using as key an ID of Code_Range__c
	 * 
	 * @return Map of Code_Range__c 
	 */
	private static Map<ID, Code_Range__c> getMapCodeRange() {

		if(CodeRangeDAO.mapCodeRange == null) {
			CodeRangeDAO.mapCodeRange = CodeRangeDAO.fetchMapCodeRange();
		}
		return CodeRangeDAO.mapCodeRange;
	}

	/**
	 * Method that return the mapIataIsoCountry using as key a country name of IATA_ISO_Country__c
	 * 
	 * @return Map of Code_Range__c 
	 */
	private static Map<String, Code_Range__c> getMapCodeRangeByName(){
		if(CodeRangeDAO.mapCodeRangeByName == null) {
			CodeRangeDAO.mapCodeRangeByName = new Map<String, Code_Range__c>();

			for(Code_Range__c codeRange : CodeRangeDAO.getAllCodeRanges()){
				CodeRangeDAO.mapCodeRangeByName.put(codeRange.Name, codeRange);
			}	
		}
		return CodeRangeDAO.mapCodeRangeByName;
	}


	/**
	 * Method that return Code_Range__c list
	 * @return List of Code_Range__c
	 */
	public static List<Code_Range__c> getAllCodeRanges(){
		return CodeRangeDAO.getMapCodeRange().values();
	}


	/**
	 * Method that return Code_Range__c list filtered by Name
	 *
	 * @param Set of String - CodeRange
	 * @return List of Code_Range__c
	 */
	public static List<Code_Range__c> getCodeRangeByName(Set<String> codeRangeNames){

		List<Code_Range__c> codeRangeList = new List<Code_Range__c>();
		
		for(String codeRange : codeRangeNames){
			if(CodeRangeDAO.getMapCodeRangeByName().containsKey(codeRange)){
				codeRangeList.add(CodeRangeDAO.getMapCodeRangeByName().get(codeRange));
			}
		}
		return codeRangeList;
	}

}