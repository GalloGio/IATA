public class ANG_TrackingHistory {


	public static void trackHistory(Map<Id, SObject> newMap, Map<Id, SObject> oldMap, String trackedObjectApiName, String trackingObjectApiName){

		system.debug('ANG_TrackingHistory: Tracking sobject history: ' + trackedObjectApiName);

		List<SObject> recordsToInsert = new List<SObject>();

		Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

		Schema.SObjectType trackedSObjType = gd.get(trackedObjectApiName);
		Schema.SObjectType trackingSObjType = gd.get(trackingObjectApiName);

		Schema.DescribeSObjectResult sObjDesc = trackedSObjType.getDescribe();

		Map<String, Schema.SObjectField> mapFields = sObjDesc.fields.getMap();

		Boolean isCustomObject = sObjDesc.isCustom();
		//master detail field api name should be EQUAL to the object api name
		String masterDetailFieldName = isCustomObject ? trackedObjectApiName : trackedObjectApiName + '__c';

		Schema.FieldSet fieldSet = sObjDesc.FieldSets.getMap().get('TrackingHistory');

		//Iterate over changed records
		//check the if the fields that are being tracked changed
		if(fieldSet!= null && fieldSet.getFields().size()>0){
			for(Id sobjId: newMap.keySet()){
				
				for(Schema.FieldSetMember field_set_member: fieldSet.getFields()){
					//system.debug('ANG_TrackingHistory: Processing filedSet member: ' + field_set_member);
					Object newValue = newMap.get(sobjId).get(field_set_member.getFieldPath());
					Object oldValue = oldMap.get(sobjId).get(field_set_member.getFieldPath());

					if(newValue != oldValue)
					{
						SObject newHistRecord = trackingSObjType.newSObject();

						newHistRecord.put(masterDetailFieldName, newMap.get(sobjId).get('Id'));
						newHistRecord.put('New_Value__c', newValue != null ? String.valueOf(newValue) : '');
						newHistRecord.put('Old_Value__c', oldValue != null ? String.valueOf(oldValue) : '');
						newHistRecord.put('What__c', mapFields.get(field_set_member.getFieldPath()).getDescribe().getLabel());
						newHistRecord.put('ApiName__c', field_set_member.getFieldPath());

						recordsToInsert.add(newHistRecord);

					}
				}
			}

			if(recordsToInsert.size()>0)
				insert recordsToInsert;
		}

	}

}