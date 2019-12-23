global class CustomButtonsHelper {
	/*
	 * Webservice that receives the object name and a list of field names and returns a list of the labels of the requested fields.
	 */
	webservice static String[] getFieldLabels (String objectName, String[] fields) {
		for (Integer i = 0; i < fields.size(); i++) {
			map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
			Schema.SObjectType objectSchema = schemaMap.get(objectName);

			if (objectSchema != null) {
				map<String, Schema.SObjectField> fieldMap = objectSchema.getDescribe().fields.getMap();

				if (fieldMap.get(fields[i]) != null) {
					fields[i] = fieldMap.get(fields[i]).getDescribe().getLabel();
				}
			}
		}

		return fields;
	}
}
