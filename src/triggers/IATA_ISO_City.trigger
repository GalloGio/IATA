/**
 * @description		Trigger for IATA_ISO_City__c 
 *
 * Edit Log:
 * @history			2020/03/06  |   Creation to manage search engine fields of ICG_Account_Role_Detail__c object avoiding special char issues.
 */
trigger IATA_ISO_City on IATA_ISO_City__c(after update) {

	if (Trigger.isAfter) {
		if (Trigger.isUpdate) {
			CW_IATA_ISO_City_Handler.handleAfterUpdate(Trigger.newMap, Trigger.oldMap);
		}
	}
}