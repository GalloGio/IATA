public class ANG_TrackingHistory {

	//ACAMBAS - WMO-390 - Start
	
	public static Map<String, List<String>> trackedFieldsMap = new Map<String, List<String>>();

	public static List<String> getStandardTrackedFields(String objectName) {
		List<String> trackedFieldsNames = trackedFieldsMap.get(objectName);

		if(trackedFieldsNames == null) {
			trackedFieldsNames = new List<String>();

			List<FieldDefinition> trackedFields = [SELECT QualifiedApiName FROM FieldDefinition WHERE EntityDefinition.QualifiedApiName = :objectName AND IsFieldHistoryTracked = true];

			for(FieldDefinition field : trackedFields) {
				trackedFieldsNames.add(field.QualifiedApiName);
			}
			trackedFieldsMap.put(objectName, trackedFieldsNames);
		}

		return trackedFieldsNames;
	}
	//ACAMBAS - WMO-390 - End

	public static void trackHistory(Map<Id, SObject> newMap, Map<Id, SObject> oldMap, String trackedObjectApiName, String trackingObjectApiName){

		system.debug('ANG_TrackingHistory: Tracking sobject history: ' + trackedObjectApiName);

		List<SObject> recordsToInsert = new List<SObject>();

		Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

		Schema.SObjectType trackedSObjType = gd.get(trackedObjectApiName);
		Schema.SObjectType trackingSObjType = gd.get(trackingObjectApiName);

		Schema.DescribeSObjectResult sObjDesc = trackedSObjType.getDescribe();

		//Map<String, Schema.SObjectField> mapFields = sObjDesc.fields.getMap();

		Boolean isCustomObject = sObjDesc.isCustom();
		//master detail field api name should be EQUAL to the object api name
		String masterDetailFieldName = isCustomObject ? trackedObjectApiName : trackedObjectApiName + '__c';

		//ACAMBAS - WMO-390 - Start
		
		List<String> trackedStandardFields = getStandardTrackedFields(trackedObjectApiName);
		List<String> fieldsToIgnore = getFieldsToExcludeFromTracking(sObjDesc);
		
		Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		Map<String, Schema.SObjectField> fieldMap = SchemaMap.get(trackedObjectApiName).getDescribe().fields.getMap(); 

		for(Id sobjId: newMap.keySet()) {
			for(Schema.SObjectField sfield : fieldMap.Values()) {
				String fieldLabel = sfield.getDescribe().getLabel();
				String fieldAPIName = sfield.getDescribe().getName();
				Object newValue = newMap.get(sobjId).get(fieldAPIName);
				Object oldValue = oldMap.get(sobjId).get(fieldAPIName);

				if(newValue != oldValue && !trackedStandardFields.contains(fieldAPIName) && !fieldsToIgnore.contains(fieldAPIName)) {
					SObject newHistRecord = createHistoryRecord(sobjId, fieldLabel, fieldAPIName, newValue, oldValue, masterDetailFieldName, trackingSObjType);
					recordsToInsert.add(newHistRecord);	
				}
			}
		}
		//ACAMBAS - WMO-390 - End
		//
		system.debug('### recordsToInsert: ' + recordsToInsert);

		if(recordsToInsert.size() > 0)
			insert recordsToInsert;

	}


	//ACAMBAS - WMO-390 - Start
	
	private static List<String> getFieldsToExcludeFromTracking(Schema.DescribeSObjectResult sObjDesc) {
			List<String> fieldsToExclude = new List<String> {'LastModifiedDate', 'SystemModstamp'};
			Schema.FieldSet fieldSet = sObjDesc.FieldSets.getMap().get('FieldsExcludedFromTracking');

			if(fieldSet != null && fieldSet.getFields().size() > 0) {
				for(Schema.FieldSetMember field_set_member: fieldSet.getFields()) {
					fieldsToExclude.add(field_set_member.getFieldPath());
				}
			}

			return fieldsToExclude;
		}

	public static SObject createHistoryRecord(String objectId, String fieldLabel, String fieldAPIName, Object newValue, Object oldValue, String masterDetailFieldName, Schema.SObjectType trackingSObjType) {

		SObject newHistRecord = trackingSObjType.newSObject();

		newHistRecord.put(masterDetailFieldName, objectId);
		newHistRecord.put('New_Value__c', newValue != null ? String.valueOf(newValue) : '');
		newHistRecord.put('Old_Value__c', oldValue != null ? String.valueOf(oldValue) : '');
		newHistRecord.put('What__c', fieldLabel);
		newHistRecord.put('ApiName__c', fieldAPIName);

		return newHistRecord;
	}

	//ACAMBAS - WMO-390 - End

}