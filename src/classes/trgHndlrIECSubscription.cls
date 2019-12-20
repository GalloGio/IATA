/**
	* Description: Trigger Handler for the Zuora Subscription object
	* Author: Alexandre McGraw
	* Version: 1.0
	* History:
	*		- added method assignUsage()
	*		- 20140922 (Samy): added support for updating existing usage for an updated subscription
	*/
public with sharing class trgHndlrIECSubscription {

	public static void OnAfterInsert(List<Zuora__Subscription__c> newRecords, Map<Id, Zuora__Subscription__c> newRecordsMap) {
		List<String> lstSubZIdResetPO = new List<String>();
		for (Zuora__Subscription__c subscription : newRecords) {
			if (String.isNotBlank(subscription.PurchaseOrder__c))
				lstSubZIdResetPO.add(subscription.Zuora__External_Id__c);
		}

		// Reset the PO to avoid being used again in the future subscription updates
		if (!lstSubZIdResetPO.isEmpty())
			IECZuoraHelper.UpdateSubscriptionPO(lstSubZIdResetPO, '');
	}

	public static void OnAfterUpdate(List<Zuora__Subscription__c> newRecords, Map<Id, Zuora__Subscription__c> newRecordsMap, List<Zuora__Subscription__c> oldRecords, Map<Id, Zuora__Subscription__c> oldRecordsMap) {
		assignUsage(newRecords);
	}

	/**
	 * Creates and assign Product Access for each new subscriptions
	 */
	private static void assignUsage(List<Zuora__Subscription__c> newRecords) {
		Set<String> setSubscriptionNumber = new Set<String>();

		// Get all orders related to the current subscription to determine whether
		// to give access to the product based on the Order.Is Paid status
		for (Zuora__Subscription__c subscription : newRecords) {
			setSubscriptionNumber.add(subscription.Name);
		}

		// Get all related order items and determine the Paid flag for the corresponding order
		Map<String, OrderItem> mapSubNum_OrderItem = new OrderItem_Sel().getOrderItemBySubscriptionNumber(setSubscriptionNumber);

		// for each updated subscription
		for (Zuora__Subscription__c subscription : newRecords) {

			// check if the rate plan info is linked
			if (subscription.Product_Rate_Plan_Information__c != null) {

				// check if usage has already been assigned
				List<IEC_Product_Access__c> lstProductAccess = IECApplicationsManager.getProductAccessBySubscriptionNumber(subscription.Name);

				// get the Billing Account associated to the subscription and get the Contact Id
				List<Zuora__CustomerAccount__c> lstBA = [Select Contact__c from Zuora__CustomerAccount__c where Id =: subscription.Zuora__CustomerAccount__c];
				Id contactId = lstBA.size() > 0 ? lstBA.get(0).Contact__c : null;

					system.debug( 'xxxxx before ' + subscription.Zuora__External_Id__c
														 + ' pacc:' + lstProductAccess.size()
														 + ' : ' + lstProductAccess) ;
						if (lstProductAccess.isEmpty()) {
					// Order is considered paid if the flag is set to true, or if the subscription was not found related to any order
					Boolean bOrderIsPaid = !mapSubNum_OrderItem.containsKey(subscription.Name) || mapSubNum_OrderItem.get(subscription.Name).Order.Is_Paid__c;

					IECApplicationsManager.createProductAccessOnNewSubscription(contactId, subscription, null, bOrderIsPaid);
				}
				else if (lstProductAccess.get(0).Zuora_Subscription_Id__c != subscription.Zuora__External_Id__c){
					IECApplicationsManager.adjustProductAccessOnSubscription(contactId, subscription, null, lstProductAccess.get(0));
								}
			}
		}
	}
}
