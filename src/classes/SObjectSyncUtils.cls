public virtual with sharing class SObjectSyncUtils {

	public class SObjectSyncException extends Exception {}

	public enum Context {
		Customer,
		Contact
	}

	public Map<String, List<String>> fieldsToCheckOnUpdate;

	public SObjectSyncUtils() {
		this.fieldsToCheckOnUpdate = new Map<String, List<String>>();
	}

	public void getFieldsToCheckOnUpdate(Context cxt){
		this.fieldsToCheckOnUpdate = new Map<String, List<String>>();

		for(Context_Sync_Settings__mdt contextSyncSettings : [
				SELECT Context__c, Object__c, Fields_To_Check_On_Update__c
				FROM Context_Sync_Settings__mdt
				WHERE Context__c = :cxt.name()
		]){
			if(!String.isBlank(contextSyncSettings.Fields_To_Check_On_Update__c)){
				this.fieldsToCheckOnUpdate.put(contextSyncSettings.Object__c, contextSyncSettings.Fields_To_Check_On_Update__c.split(','));
			}
		}
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
				fieldListToCheck = getSObjectFieldsToCheckOnUpdate(newSObject);
			}

			if (hasSufficientUpdatesToBeSync(fieldListToCheck, oldSObject, newSObject)) {
				sObjectsToSynchronize.add(newSObject);
			}
		}

		return sObjectsToSynchronize;
	}

	private List<String> getSObjectFieldsToCheckOnUpdate(SObject sobj) {
		String sObjectName = sobj.getSObjectType().getDescribe().getName();

		if(fieldsToCheckOnUpdate.containsKey(sObjectName)){
			return fieldsToCheckOnUpdate.get(sObjectName);
		} else {
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