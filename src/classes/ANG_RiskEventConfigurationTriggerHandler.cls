public class ANG_RiskEventConfigurationTriggerHandler {

	public List<ANG_Risk_Event_Configuration__c> triggerNew = (List<ANG_Risk_Event_Configuration__c>) Trigger.new;
    public List<ANG_Risk_Event_Configuration__c> triggerOld = (List<ANG_Risk_Event_Configuration__c>) Trigger.old;

    public Map<Id, ANG_Risk_Event_Configuration__c> newMap = (Map<Id,ANG_Risk_Event_Configuration__c>) Trigger.newMap;
    public Map<Id, ANG_Risk_Event_Configuration__c> oldMap = (Map<Id,ANG_Risk_Event_Configuration__c>) Trigger.oldMap;

    // ************************************************************
    // ****************** distribution methods ********************
    // ************************************************************

    public void onBeforeInsert(){
    	validateConditions();
    }

    public void onBeforeUpdate(){
    	validateConditions();
    }

    // ************************************************************
    // ********************* action methods ***********************
    // ************************************************************
	
	private void validateConditions() {
		Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.ANG_Risk_Event_Configuration__c.fields.getMap();
		String fieldPrefix = 'ANG_';
		String customSufix = '__c';
		for(ANG_Risk_Event_Configuration__c config : triggerNew){

			Boolean hasNext = true;
			Integer i = 0;
			while (hasNext) {
				i++;
				String fieldIdentifier = 'Field'+String.valueOf(i).leftPad(2, '0');

				String field = fieldPrefix+fieldIdentifier+customSufix;
				String conditionField = fieldPrefix+fieldIdentifier+'_Conditions'+customSufix;
				String valueField = fieldPrefix+fieldIdentifier+'_Values'+customSufix;

				System.debug(loggingLevel.Debug, '____ [trg ANG_RiskEventConfigurationTrigger - before] field - ' + field);
				System.debug(loggingLevel.Debug, '____ [trg ANG_RiskEventConfigurationTrigger - before] conditionField - ' + conditionField);
				System.debug(loggingLevel.Debug, '____ [trg ANG_RiskEventConfigurationTrigger - before] valueField - ' + valueField);

				if(!fieldMap.containsKey(field) || !fieldMap.containsKey(conditionField) || !fieldMap.containsKey(valueField)){
					hasNext = false; //we reached the end of the fields
				}else if (config.get(field) != null && (config.get(conditionField) == null || config.get(valueField) == null)) {
					config.addError('Please inform Conditions and Values for '+fieldIdentifier);
				}
			}
		}
	}
}