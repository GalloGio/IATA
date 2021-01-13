/**
	* Description: Trigger Handler for the Swap Configuration object of the IEC project
	* Author: Samy Saied
	* Version: 1.0
	* History:
	*/
public with sharing class trgHndlrIECSwapConfiguration {
	public static void OnBeforeInsert(List<Swap_Configuration__c> newRecords, Map<Id, Swap_Configuration__c> newRecordsMap) {
		CheckIfPreviouslyExists(newRecords);
	}

	public static void OnBeforeUpdate(List<Swap_Configuration__c> newRecords, Map<Id, Swap_Configuration__c> newRecordsMap, List<Swap_Configuration__c> oldRecords, Map<Id, Swap_Configuration__c> oldRecordsMap) {
		CheckIfPreviouslyExists(newRecords);
	}

	private static void CheckIfPreviouslyExists(List<Swap_Configuration__c> newRecords) {
		for (Swap_Configuration__c cfg : newRecords) {
			List<Swap_Configuration__c> lstExisting =
				[SELECT Id
				FROM Swap_Configuration__c
				WHERE Relationship_Type__c = :cfg.Relationship_Type__c
					AND Source_Product_Rate_Plan_Information__c = :cfg.Source_Product_Rate_Plan_Information__c
					AND Target_Product_Rate_Plan_Information__c = :cfg.Target_Product_Rate_Plan_Information__c
					AND Id != :cfg.Id];

			if (lstExisting.size() > 0)
				cfg.addError(Label.IEC_Error_OnlyOneSwapConfiguration);
		}
	}
}
