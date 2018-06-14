public class ANG_AgencyAChangeCodeTriggerHandler{
	public List<Agency_Applied_Change_code__c> triggerNew = (List<Agency_Applied_Change_code__c>) Trigger.new;
	public List<Agency_Applied_Change_code__c> triggerOld = (List<Agency_Applied_Change_code__c>) Trigger.old;

	public Map<Id, Agency_Applied_Change_code__c> newMap = (Map<Id,Agency_Applied_Change_code__c>) Trigger.newMap;
	public Map<Id, Agency_Applied_Change_code__c> oldMap = (Map<Id,Agency_Applied_Change_code__c>) Trigger.oldMap;

	// ************************************************************
	// ****************** distribution methods ********************
	// ************************************************************

	public void onBeforeInsert(){
	}
	public void onAfterInsert() {
		 new ANG_AgencyEventsGenerator(triggerNew,null,'ChangeCode','account__c').run();
	}

	public void onBeforeUpdate(){
	}
	
	public void onAfterUpdate() {
	}

	public void onBeforeDelete(){}
	public void onAfterDelete() {}
}