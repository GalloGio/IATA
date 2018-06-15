/**
 * Singleton class that contains the record types
 */
public class RecordTypeSingleton {
	// private static variable referencing the class
    private static RecordTypeSingleton instance = null;
    // variable that contains the repord types by name per object type
	private Map<String, Map<String, RecordType>> recordTypesByName;

	/**
	 * Private constructor
	 * @return
	 */
	private RecordTypeSingleton(){
		recordTypesByName = new Map<String, Map<String, RecordType>>();

		for(RecordType rt : [SELECT Id, DeveloperName, SObjectType FROM RecordType]){
			// checks if the sObjectType is already mapped
			if(!recordTypesByName.containsKey(rt.SObjectType)){
				// puts a new entry for the object type and instantiates the map that will contain the corresponding record types mapped by Name
				recordTypesByName.put(rt.SObjectType, new Map<String, RecordType>());
			}
			// fills the maps of the record type per object type
			recordTypesByName.get(rt.SObjectType).put(rt.DeveloperName, rt);
		}

	}
	   
	/**
	 * Method that returns the instance of RecordTypeSingleton
	 * @return instance of the singleton
	 */
	public static RecordTypeSingleton getInstance(){
		if(instance == null){
			instance = new RecordTypeSingleton();
		} 
	    
	    return instance;
	}

	/**
	 * Method that returns the record type object
	 * @param objectName the name of the object
	 * @param devName the name of the record type (DeveloperName)
	 * @return record type object
	 */
	public RecordType getRecordType(String objectName, String devName){

		return recordTypesByName.get(objectName).get(devName);

	}


	/**
	 * Method that returns the Id of the record type
	 * @param objectName the name of the object
	 * @param devName the name of the record type (DeveloperName)
	 * @return id of the record type object
	 */
	public Id getRecordTypeId(String objectName, String devName){

		return recordTypesByName.get(objectName).get(devName).Id;

	}


	public Map<String, Map<String, Id>> RtIDsPerDeveloperNamePerObj;

}
