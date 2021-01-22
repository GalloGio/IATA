/**
 * Singleton class that contains BSP Attributes
 */
public class BSPAttributesSingleton {
	// private static variable referencing the class
	private static BSPAttributesSingleton instance = null;
	// variable that contains the list of Attributes for each BSP required
	private Map<id, Map<String, ANG_BSP_Attributes__c>> BSPAttributes;

	/**
	 * Private constructor
	 * @return
	 */
	private BSPAttributesSingleton(set<id> setBSPId, set<string> setRTNames){
		BSPAttributes = new map<id, Map<String, ANG_BSP_Attributes__c>>();

		string sQuery = 'select id, recordtype.DeveloperName, FS_Percentage__c, Amount_At_Risk_From_USD__c, Amount_At_Risk_Multiplier__c, Amount_At_Risk_To_USD__c' +
						'  , BSP__c, Class_Type__c, ISO_State__c, Limit_Cash_Condition__c, Max_FA_Points__c, Min_FA_Points__c, Operation__c, Remittance_Frequency__c' +
						'  , Remittances_Per_Year__c, RHC_Amnt_Calc_Type__c, Risk_Status__c, Tier__c, Tier_RHC_Formula__c, Tier_RHC_Formula_Deduct_USD__c, Tier_RHC_Formula_TopUp_USD__c, UniqueKey__c ' +
						'  , bsp__r.name	 ' +
						'  from ANG_BSP_Attributes__c';
						
		if(setBSPId!=null && setRTNames!=null)
			sQuery += ' where BSP__c IN :setBSPId and recordtype.developername IN :setRTNames';
		else{
			if(setBSPId!=null)
				sQuery += ' where BSP__c IN :setBSPId';
			if(setRTNames!=null)
				sQuery += ' where recordtype.developername IN :setRTNames';
		}

		for(ANG_BSP_Attributes__c attr : database.query(sQuery)){
			// checks if the BSP is already mapped
			if(!BSPAttributes.containsKey(attr.BSP__c)){
				// puts a new entry for the BSP and instantiates the map that will contain the corresponding attributes records
				BSPAttributes.put(attr.BSP__c, new Map<String, ANG_BSP_Attributes__c>());
			}
			// fills the maps of the attributes per BSP
			BSPAttributes.get(attr.BSP__c).put(attr.UniqueKey__c, attr);
		}
	}

	/**
	 * Method that returns the instance of BSPAttributesSingleton
	 * @param setBSPId is the set of BSP Ids for which is required to get the attributes
	 * @param setRecordtypes is the set of recordtypes (developername) of the attributed to retrieve
	 * @return instance of the singleton matching the BSP and Recordtypes received in input
	 */
	public static BSPAttributesSingleton getInstance(set<id> setBSPId, set<string> setRTNames){
		if(instance == null) instance = new BSPAttributesSingleton(setBSPId, setRTNames);
		return instance;
	}

	/**
	 * Method that returns the instance of BSPAttributesSingleton
	 * @return instance of the singleton with all BSP and all Recordtypes. Note that this can retrieve thousands of records
	 */
	public static BSPAttributesSingleton getInstance(){
		if(instance == null) instance = new BSPAttributesSingleton(null, null);
		return instance;
	}

	/**
	 * Method that returns the instance of BSPAttributesSingleton
	 * @param setBSPId is the set of BSP Ids for which is required to get the attributes
	 * @return instance of the singleton matching the BSPIds received. All Recordtypes are returned
	 */
	public static BSPAttributesSingleton getInstance(set<id> setBSPId){
		if(instance == null) instance = new BSPAttributesSingleton(setBSPId, null);
		return instance;
	}

	/**
	 * Method that returns the record type object
	 * @param BSPId the ID of the BSP
	 * @param AttrUniqueId 	  the unique ID of the attribute to get
	 * @return 		the full ANG_BSP_Attributes__c record
	 */
	public ANG_BSP_Attributes__c getSingleBSPAttributeByUniqueId(id BSPId, String AttrUniqueId){
		if(!BSPAttributes.containsKey(BSPId)) return null;

		return BSPAttributes.get(BSPId).get(AttrUniqueId);
	}

	/**
	 * Method that returns a list of attributes for a specified BSP
	 * @param  BSPId the ID of the BSP
	 * @return       the list of ANG_BSP_Attributes__c for the passed BSP
	 */
	public List<ANG_BSP_Attributes__c> getAllBSPAttributes(id BSPId){
		if(!BSPAttributes.containsKey(BSPId)) return new List<ANG_BSP_Attributes__c>();

		return BSPAttributes.get(BSPId).values();
	}

	/**
	 * Method that returns a list of attributes for a specified BSP matching a specific recortype requested
	 * @param  BSPId the ID of the BSP
	 * @param  RTNames the Names of the recordtype to retrieve
	 * @return       the list of ANG_BSP_Attributes__c for the passed BSP mathching the RTs received
	 */
	public List<ANG_BSP_Attributes__c> getAllBSPAttributesByRecordtype(id BSPId, set<string> RTNames){
		list<ANG_BSP_Attributes__c> lsToReturn = new list<ANG_BSP_Attributes__c>();
		if(!BSPAttributes.containsKey(BSPId)) return lsToReturn;

		for(ANG_BSP_Attributes__c attr:BSPAttributes.get(BSPId).values()){
			if(RTNames.contains(attr.recordtype.developername))
				lsToReturn.add(attr);
		}
		return lsToReturn;
	}

	/**
	 * Method that returns the map of attributes (where the index is the UniqueKey of the record)
	 * @param  BSPId the ID of the BSP
	 * @return       the map of attributes
	 */
	public map<string, ANG_BSP_Attributes__c> getFullBSPMap(id BSPId){
		if(BSPAttributes.containsKey(BSPId)) return BSPAttributes.get(BSPId);
		else return new map<string, ANG_BSP_Attributes__c>();
	}
}