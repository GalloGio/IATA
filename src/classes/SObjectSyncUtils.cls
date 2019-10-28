/**
 * Created by LBERB on 22/10/2019.
 */

public virtual with sharing class SObjectSyncUtils {

	public class SObjectSyncException extends Exception {}

	public final static String TYPE_INSERT = 'Insert';
	public final static String TYPE_UPDATE = 'Update';
	public final static String TYPE_DELETE = 'Delete';

	public Map<String, List<String>> fieldsToCheckOnUpdate;

	public SObjectSyncUtils() {
		this.fieldsToCheckOnUpdate = new Map<String, List<String>>();
	}

	/**
	 * Get the list of SObjects which are allowed to be synchronized from their fields updates
	 *
	 * @param oldSObjects
	 * @param newRecordsMap
	 *
	 * @return List of SObjects which are allowed to be synchronized
	 */
	public List<SObject> getSObjectsToSynchronizeOnUpdate(List<SObject> oldSObjects, Map<Id, SObject> newRecordsMap) {

		List<SObject> sObjectsToSynchronize = new List<SObject>();
		List<String> fieldListToCheck;

		SObject newSObject;
		for (SObject oldSObject : oldSObjects) {
			newSObject = newRecordsMap.get(oldSObject.Id);

			if(fieldListToCheck == null){
				fieldListToCheck = getFieldListToCheckOnUpdate(newSObject);
			}

			if (hasSufficientUpdatesToBeSync(fieldListToCheck, oldSObject, newSObject)) {
				sObjectsToSynchronize.add(newSObject);
			}
		}

		return sObjectsToSynchronize;
	}

	private List<String> getFieldListToCheckOnUpdate(SObject sobj) {
		String sObjectName = sobj.getSObjectType().getDescribe().getName();

		if(fieldsToCheckOnUpdate.containsKey(sObjectName)){
			return fieldsToCheckOnUpdate.get(sObjectName);
		} else {
			// TODO throw exception with Custom Label
			throw new SObjectSyncException(String.format('This process does not support the SObject {0}', new List<String>{sobj.getSObjectType().getDescribe().getName()}));
		}
	}

	private static Boolean hasSufficientUpdatesToBeSync(List<String> fieldListToCheck, SObject oldSObject, SObject newSObject) {

		for(String fieldName : fieldListToCheck){
			if(oldSObject.get(fieldName) != newSObject.get(fieldName)){
				return true;
			}
		}

		return false;
	}
}