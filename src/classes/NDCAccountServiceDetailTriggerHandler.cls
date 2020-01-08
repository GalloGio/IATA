public class NDCAccountServiceDetailTriggerHandler {
	public static Boolean bypassTrigger = false;

	private final List<NDC_Account_Service_Detail__c> new_records;
	private final List<NDC_Account_Service_Detail__c> old_records;
	private final Map<Id, NDC_Account_Service_Detail__c> new_map;
	private final Map<Id, NDC_Account_Service_Detail__c> old_map;

	public NDCAccountServiceDetailTriggerHandler()  {
		this.new_records = Trigger.new;
		this.old_records = Trigger.old;
		this.new_map = (Map<Id, NDC_Account_Service_Detail__c>) Trigger.newMap;
		this.old_map = (Map<Id, NDC_Account_Service_Detail__c>) Trigger.oldMap;
	}

	public void handle() {
		if (bypassTrigger) { return; }
		if (Trigger.isBefore  && Trigger.isInsert) {
			beforeInsert();
		} else if (Trigger.isBefore  && Trigger.isUpdate) {
			beforeUpdate();
		} else if (Trigger.isAfter  && Trigger.isUpdate) {
			afterUpdate();
		}
	}

	private void beforeInsert() {
		NDCAccountServiceDetailHelper.ndcLogic(new_records);
	}

	private void beforeUpdate() {
		NDCAccountServiceDetailHelper.ndcLogic(new_records);
	}

	private void afterUpdate() {
		NDCAccountServiceDetailHelper.onAfterUpdate(old_Map, new_Map);
	}
}
