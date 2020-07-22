/**
 * @description		Handler of CW_IATA_ISO_City_Handler
 *
 * Edit Log:
 * @history			2020/03/06  |  Creation.
 */
public with sharing class CW_IATA_ISO_City_Handler {

	public static void handleAfterUpdate(Map<Id, IATA_ISO_City__c> newMap, Map<Id, IATA_ISO_City__c> oldMap) {
		CW_ICGAccountRoleDetail_Handler.checkFacilityFields(newMap, oldMap);
	}
}