public class ANG_RiskEventConfigurationFields {

	/*
		Returns a set with the api names to fetch configurations:
		Example:
		fieldName = 'ANG_Field06__c'
		conditionField = 'ANG_Field06_Conditions__c'
		valueField = 'ANG_Field06_Fields__c'
	*/

	public String fieldName;
	public String conditionField;
	public String valueField;

	public ANG_RiskEventConfigurationFields(String fieldName, String conditionField, String valueField){
		this.fieldName = fieldName;
		this.conditionField = conditionField;
		this.valueField = valueField;
	}

	private static List<ANG_RiskEventConfigurationFields> fieldList;
	public static List<ANG_RiskEventConfigurationFields> getList() {
		if(fieldList == null){
			fieldList = new List<ANG_RiskEventConfigurationFields>();

			Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.ANG_Risk_Event_Configuration__c.fields.getMap();
			String fieldPrefix = 'ANG_';
			String customSufix = '__c';

			Boolean hasNext = true;
			Integer i = 0;
			while (hasNext) {
				i++;
				String fieldIdentifier = 'Field'+String.valueOf(i).leftPad(2, '0');

				String field = fieldPrefix+fieldIdentifier+customSufix;
				String conditionField = fieldPrefix+fieldIdentifier+'_Conditions'+customSufix;
				String valueField = fieldPrefix+fieldIdentifier+'_Values'+customSufix;

				if(!fieldMap.containsKey(field) || !fieldMap.containsKey(conditionField) || !fieldMap.containsKey(valueField)){
					hasNext = false; //we reached the end of the fields
				}else {
					fieldList.add(new ANG_RiskEventConfigurationFields(field, conditionField, valueField));
				}
			}
		}
		return fieldList;
	}
}