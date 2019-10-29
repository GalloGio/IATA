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

		System.debug('____ [ANG_TrackingHistory - trackHistory] trackedObjectApiName - ' + trackedObjectApiName);

		List<SObject> recordsToInsert = new List<SObject>();

		Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

		Schema.SObjectType trackedSObjType = gd.get(trackedObjectApiName);
		Schema.SObjectType trackingSObjType = gd.get(trackingObjectApiName);

		Schema.DescribeSObjectResult sObjDesc = trackedSObjType.getDescribe();

		Boolean isCustomObject = sObjDesc.isCustom();
		//master detail field api name should be EQUAL to the object api name
		String masterDetailFieldName = isCustomObject ? trackedObjectApiName : trackedObjectApiName + '__c';

		//ACAMBAS - WMO-390 - Start
		
		List<String> trackedStandardFields = getStandardTrackedFields(trackedObjectApiName);
		List<String> fieldsToIgnore = getFieldsToExcludeFromTracking(sObjDesc);
		
		Map<String, Schema.SObjectField> fieldMap = sObjDesc.fields.getMap();

		List<Schema.SObjectField> filteredFieldMap = new List<Schema.SObjectField>();

		for(Schema.SObjectField sfield : fieldMap.Values()) {
        	if(!fieldsToIgnore.contains('' + sField) && !trackedStandardFields.contains('' + sField)){
        		filteredFieldMap.add(sField);
        	}
		}

		for(Schema.SObjectField sfield : filteredFieldMap) {
        	Schema.DescribeFieldResult sfieldDescribe = sfield.getDescribe();
        	if(!sfieldDescribe.isCalculated()){
        		String fieldLabel = sfieldDescribe.getLabel();
        		String fieldAPIName = sfieldDescribe.getName();
				for(Id sobjId: newMap.keySet()) {
	                Object newValue = newMap.get(sobjId).get(fieldAPIName);
	                Object oldValue = oldMap.get(sobjId).get(fieldAPIName);

	                if(newValue != oldValue) {
	                    SObject newHistRecord = createHistoryRecord(sobjId, fieldLabel, fieldAPIName, newValue, oldValue, masterDetailFieldName, trackingSObjType);
	                    recordsToInsert.add(newHistRecord); 
	                }
	            }
	        }          
        }



		//ACAMBAS - WMO-390 - End
		System.debug('____ [ANG_TrackingHistory - trackHistory] recordsToInsert - ' + recordsToInsert);

		if(recordsToInsert.size() > 0)
			insert recordsToInsert;

	}


	//ACAMBAS - WMO-390 - Start
	
	private static List<String> getFieldsToExcludeFromTracking(Schema.DescribeSObjectResult sObjDesc) {
		List<String> fieldsToExclude = new List<String> {'LastModifiedDate', 'SystemModstamp'};
		Schema.FieldSet fieldSet = sObjDesc.FieldSets.getMap().get('FieldsExcludedFromTracking');

		if(fieldSet != null) {
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