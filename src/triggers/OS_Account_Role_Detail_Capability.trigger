/**
 * @description		Trigger for Account_Role_Detail_Capability__c (One Source Capabilities Object)
 *
 * Edit Log:
 * @history			2021/07/20  |   Creation to manage the las modification date for some fields
 */
trigger OS_Account_Role_Detail_Capability on Account_Role_Detail_Capability__c(before insert, before update) {
	if (Trigger.isBefore && Trigger.isInsert) {
		OS_Account_Role_Detail_CapabilityHandler.handleBeforeInsert(Trigger.new);
	}
	if (Trigger.isBefore && Trigger.isUpdate) {
		OS_Account_Role_Detail_CapabilityHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
	}
}