/**
	* Description: This class contains logic methods called by triggers related to the ProductRatePlanInformation object
	* Author: Alexandre McGraw
	* Version: 1.0
	* History:
 */
public with sharing class trgIECProductRatePlanInformation {
	public static void OnBeforeInsert(List<Product_Rate_Plan_Information__c> newRecords, Map<Id, Product_Rate_Plan_Information__c> newRecordsMap) {
				for (Product_Rate_Plan_Information__c oNew: newRecords) {
			// if the new Rate Plan Info is active and a trial but that the related product information already has an active trial, prevent from saving
			if (oNew.Is_Triable__c
				&& oNew.Active__c
				&& IECProductManager.getTrialRatePlanForProduct((String)oNew.Related_Product_Information__c) != null) {

				oNew.addError('The related Production Information already has an active trial rate plan.');
			}
				}
	}

	public static void OnBeforeUpdate(List<Product_Rate_Plan_Information__c> newRecords, Map<Id, Product_Rate_Plan_Information__c> newRecordsMap, List<Product_Rate_Plan_Information__c> oldRecords, Map<Id, Product_Rate_Plan_Information__c> oldRecordsMap) {
		for (Product_Rate_Plan_Information__c oNew: newRecords) {
			Product_Rate_Plan_Information__c oOld = oldRecordsMap.get(oNew.Id);

			Product_Rate_Plan_Information__c oTrialRatePlan = IECProductManager.getTrialRatePlanForProduct((String)oNew.Related_Product_Information__c);

			// if the rate plan info to update creates a conflict with an existing active trial (is updated from non trial to trial or from inactive to active)
			// prevent from saving
			if ((oTrialRatePlan != null && oTrialRatePlan.Id <> oNew.Id)
				&& ((!oOld.Is_Triable__c && oNew.Is_Triable__c) || (oOld.Is_Triable__c && !oOld.Active__c && oNew.Active__c))) {
				oNew.addError('The related Production Information already has an active trial rate plan.');
			}

			// Check if there is no related upgrade plans before switching Unlimited to limited plan
			if ((oOld.Subscription_Usage_Qty__c == null
					|| oOld.Subscription_Usage_Qty__c == 0)
				&& oOld.Is_Triable__c == false
				&& ((oNew.Subscription_Usage_Qty__c != null	&& oNew.Subscription_Usage_Qty__c > 0)
					|| oNew.Is_Triable__c == true)) {

				// get the upgradable rate plans
				List<Swap_Configuration__c> lstSwapUpgrades =
		 			[SELECT Id
		 			FROM Swap_Configuration__c
					WHERE Target_Product_Rate_Plan_Information__c = :oNew.Id
						AND Relationship_Type__c = :IECConstants.SwappingType_Upgrade];

				if (!lstSwapUpgrades.isEmpty()) {
					oNew.addError(Label.IEC_Error_CannotSwitchToLimited);
				}
			}
		}
	}
}
