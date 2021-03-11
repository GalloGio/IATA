/**
 * @description		Trigger for ICG_Account_Role_Detail__c (facility object)
 *
 * Edit Log:
 * @history			2020/03/06  |   Creation to manage search engine fields avoiding special char issues.
 */
trigger ICG_Account_Role_Detail on ICG_Account_Role_Detail__c(after insert, after update,after delete) {

	if (Trigger.isAfter) {
		if (Trigger.isInsert) {
			CW_ICGAccountRoleDetail_Handler.handleAfterInsert(Trigger.newMap);
		} else if (Trigger.isUpdate) {
			CW_ICGAccountRoleDetail_Handler.handleAfterUpdate(Trigger.newMap, Trigger.oldMap);
		} else if (Trigger.isDelete){
			CW_ICGAccountRoleDetail_Handler.handleAfterDelete(Trigger.oldMap);
		}
	}
}