public class AccountRolesTriggerHandler {
public static Boolean bypassTrigger = false;

	private final List<Account_Roles__c> new_records;
	private final List<Account_Roles__c> old_records;
	private final Map<Id, Account_Roles__c> new_map;
	private final Map<Id, Account_Roles__c> old_map;

	public AccountRolesTriggerHandler()  {
		this.new_records = Trigger.new;
		this.old_records = Trigger.old;
		this.new_map = (Map<Id, Account_Roles__c>) Trigger.newMap;
		this.old_map = (Map<Id, Account_Roles__c>) Trigger.oldMap;
	}

	public void handle() {
		if (bypassTrigger) { return; }
		if (Trigger.isBefore  && Trigger.isInsert) {
			beforeInsert();
		} else if (Trigger.isBefore  && Trigger.isUpdate) {
			beforeUpdate();
		}
	}

	private void beforeInsert() {
		AccountRolesHelper.updateName(new_records);
	}

	private void beforeUpdate() {
		AccountRolesHelper.updateName(new_records);
	}
}
