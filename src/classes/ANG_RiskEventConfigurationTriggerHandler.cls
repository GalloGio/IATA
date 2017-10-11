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
        Set<String> needValue = new Set<String>{'Equal to', 'Not equal to', '<', '>', '<=', '>='};

		for(ANG_Risk_Event_Configuration__c config : triggerNew){
			for(ANG_RiskEventConfigurationFields f : ANG_RiskEventConfigurationFields.getList()){
				if (config.get(f.fieldName) != null && (config.get(f.conditionField) == null || (needValue.contains((String)config.get(f.conditionField))  && config.get(f.valueField) == null))) {
					config.addError('Please inform Conditions and Values for '+config.getSObjectType().getDescribe().fields.getMap().get(f.fieldName).getDescribe().getLabel());
				}
			}
		}
	}
}