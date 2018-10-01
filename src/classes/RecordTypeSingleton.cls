/**
 * Singleton class that contains the record types
 */
public class RecordTypeSingleton {
	// private static variable referencing the class
    private static RecordTypeSingleton instance = null;
    // variable that contains the repord types by name per object type
	private Map<String, Map<String, RecordType>> recordTypesByName;

	// variable that contains the repord types by id per object type
	private Map<String, Map<Id, RecordType>> recordTypesById;

	/**
	 * Private constructor
	 * @return
	 */
	private RecordTypeSingleton(){
		recordTypesByName = new Map<String, Map<String, RecordType>>();
		recordTypesById = new Map<String, Map<Id, RecordType>>();

		for(RecordType rt : [SELECT Id, Name, DeveloperName, SObjectType FROM RecordType]){
			// checks if the sObjectType is already mapped
			if(!recordTypesByName.containsKey(rt.SObjectType)){
				// puts a new entry for the object type and instantiates the map that will contain the corresponding record types mapped by Name
				recordTypesByName.put(rt.SObjectType, new Map<String, RecordType>());
			}
			// fills the maps of the record type per object type
			recordTypesByName.get(rt.SObjectType).put(rt.DeveloperName, rt);


			// checks if the sObjectType is already mapped
			if(!recordTypesById.containsKey(rt.SObjectType)){
				// puts a new entry for the object type and instantiates the map that will contain the corresponding record types mapped by Name
				recordTypesById.put(rt.SObjectType, new Map<Id, RecordType>());
			}
			// fills the maps of the record type per object type
			recordTypesById.get(rt.SObjectType).put(rt.Id, rt);
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
	 * @param objectName  the name of the object
	 * @param devName 	  the name of the record type (DeveloperName)
	 * @return 			  record type object
	 */
	public RecordType getRecordType(String objectName, String devName){

		return recordTypesByName.get(objectName).get(devName);

	}


	/**
	 * Method that returns the Id of the record type
	 * @param objectName the name of the object
	 * @param devName 	 the name of the record type (DeveloperName)
	 * @return 			 id of the record type object
	 */
	public Id getRecordTypeId(String objectName, String devName){

		return recordTypesByName.get(objectName).get(devName).Id;

	}


	/**
	 * Method that returns a list of record types for a specified object name
	 * @param  objectName the name of the object
	 * @return            the list of record types for the passed object name
	 */
	public List<RecordType> getRecordTypesBySObject(String objectName){

		return recordTypesByName.get(objectName).values();

	}

	/**
	 * Method that returns a map of record types for a specified object name
	 * @param  objectName the name of the object
	 * @return            the map of record types for the passed object name
	 */
	public Map<String, String> getMapRecordTypesBySObject(String objectName){

		Map<String, String> mapRecordType = new Map<String, String>();

		for(RecordType rt : recordTypesByName.get(objectName).values()){
			mapRecordType.put(rt.name, rt.Id);
		}
		return mapRecordType;

	}


	/**
	 * Method that returns a list of record types Ids for a specified object and a list of developer names
	 * @param  objectName  the name of the object
	 * @param  devNameList List of the name of the record type (DeveloperName)
	 * @return             List of record type Ids for the passed object name and list of record type names
	 */
	public List<Id> getRecordTypeObjIdListForSpecfifiedNames(String objectName, List<String> devNameList){

		List<Id> returnRecTypeObjIdList = new List<Id>();

		for(String devName : devNameList){

			returnRecTypeObjIdList.add(getRecordTypeId(objectName, devName));
		}

		return returnRecTypeObjIdList;

	}


	/**
	 * Method that returns a list of record types Ids for a specified object and that are not on the list of developer names
	 * @param  objectName        the name of the object
	 * @param  exceptDevNameList List of the name of the record type (DeveloperName) to exclude
	 * @return                   List of record type Ids for the passed object name and that is not present on the list of record type names
	 */
	public List<Id> getRecordTypeObjIdListExceptPassedNames(String objectName, List<String> exceptDevNameList){

		List<Id> returnRecTypeObjIdList = new List<Id>();

		for(RecordType recType : recordTypesByName.get(objectName).values()){

			if(!exceptDevNameList.contains(recType.DeveloperName)){

				returnRecTypeObjIdList.add(recType.Id);
			}
		}

		return returnRecTypeObjIdList;
	}


	/**
	 * Method that returns the Developer Name of the record type
	 * @param objectName the name of the object
	 * @param rtId 	 	 the id of the record type
	 * @return 			 Record type object
	 */
	public RecordType getRecordTypeById(String objectName, Id rtId){

		return recordTypesById.get(objectName).get(rtId);

	}

}
