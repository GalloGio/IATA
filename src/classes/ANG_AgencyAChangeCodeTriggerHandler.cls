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
		 new ANG_AgencyEventsGenerator(filterByIATACode(triggerNew),null,'ChangeCode','account__c').run();
	}

	public void onBeforeUpdate(){
	}
	
	public void onAfterUpdate() {
	}

	public void onBeforeDelete(){}
	public void onAfterDelete() {}

	public static List<Agency_Applied_Change_code__c> filterByIATACode(List<Agency_Applied_Change_code__c> changeCodes){

		List<Agency_Applied_Change_code__c> toReturn = new List<Agency_Applied_Change_code__c>();

		for(Agency_Applied_Change_code__c aacc : changeCodes)
			if(aacc.IATA_Code__c <> null)
				toReturn.add(aacc);

		return toReturn;
	}
}