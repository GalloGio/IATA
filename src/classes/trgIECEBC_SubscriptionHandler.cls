/*
* Trigger Helper class for zuora__Subscription__c 
*  
*  Context: eBroadcast, new subscription. 
*  
*  This class updates  is done by using related Zuora__CustomerAccount__c
*  This class requires information from other classes 
*  
*  Assumption: 
*   - Only one currently active Zuora__Subscription for today
*  
*   - Early version: We are not reinserting the same Zuora__Subscription
*   - if we need to do it, we will need to store the recent unique id of the current 
*  
*  
*  Author: Sonny Leman
*  Change Log: 
*   - 20160622-sl: initial version
*
*/


public with sharing class trgIECEBC_SubscriptionHandler {
	
	public static boolean firstRun = true; // this is used to prevent processEbcSubscription executed twice on one execution
	
	// ========================================================================
	// processEbcSubscription will update related Zuora__CustomerAccount
	// to be run after Zuora__Subscription are inserted
	public static void processEbcSubscription( Map<Id,Zuora__Subscription__c> zuoraSubscriptionIdToObjectMap)
	{
		// first, ensure this method only works once in an execution
		if (firstRun) 
		{
			firstRun = false;
		} else {
			System.debug('trgIECEBC_SubscriptionHandler.processEbcSubscription has been executed previously, skip for now.');
			return;
		}
		
		List<Zuora__Subscription__c> zuoraSubscriptionList = zuoraSubscriptionIdToObjectMap.values();
		Set<Id> zuoraSubscriptionIdSet = zuoraSubscriptionIdToObjectMap.keySet();
		
		// collect relevant subscription & relevant billing account for ebroadcast
		// 
		Map<Id,Zuora__Subscription__c> relevantSubscriptionIdToObjMap = new Map<Id,Zuora__Subscription__c> ([
			select Id
				, Zuora__Status__c
				, Zuora__SubscriptionStartDate__c
				, Zuora__SubscriptionEndDate__c
				, Zuora__CustomerAccount__c, Zuora__CustomerAccount__r.Id
				, Zuora__CustomerAccount__r.Contact__c
				, Zuora__CustomerAccount__r.eBroadcast_Product_Access__c
				, Zuora__CustomerAccount__r.eBroadcast_Available_Email_Balance__c
				, Product_Rate_Plan_Information__c
				, Product_Rate_Plan_Information__r.Name
				, Product_Rate_Plan_Information__r.Product_Rate_Plan__c
				, Product_Rate_Plan_Information__r.Product_Rate_Plan__r.Name
				, Product_Rate_Plan_Information__r.Product_Rate_Plan__r.EBC_SubscriptionType__c
				, Product_Rate_Plan_Information__r.Product_Rate_Plan__r.EBC_Cost_Per_Email__c
				, Product_Rate_Plan_Information__r.Product_Rate_Plan__r.EBC_PrePaid_Emails__c
				, Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Name
			from Zuora__Subscription__c
			where  Product_Rate_Plan_Information__c != null
				and (Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Name = : IECConstants.ProductCategory_SF_EBROADCAST)
				and Id in : zuoraSubscriptionIdToObjectMap.keyset()
		]); 
		
		
		List<Zuora__CustomerAccount__c> updatedCustomerAccountList = new List<Zuora__CustomerAccount__c>();
		for (Zuora__Subscription__c subs : relevantSubscriptionIdToObjMap.values())
		{
			Integer emailBalance = 0;
			if ( (subs.Zuora__CustomerAccount__c != null)
				&& (subs.Zuora__Status__c == 'Active')
				&& (subs.Zuora__SubscriptionStartDate__c <= Date.today())
				&& (subs.Zuora__SubscriptionEndDate__c >= Date.today())
				)
			{ 
				emailBalance = ( subs.Zuora__CustomerAccount__r.eBroadcast_Available_Email_Balance__c == null) ? 0 : Integer.valueOf(subs.Zuora__CustomerAccount__r.eBroadcast_Available_Email_Balance__c);
				emailBalance += (subs.Product_Rate_Plan_Information__r.Product_Rate_Plan__r.EBC_PrePaid_Emails__c == null ) ? 0 : Integer.valueOf(subs.Product_Rate_Plan_Information__r.Product_Rate_Plan__r.EBC_PrePaid_Emails__c);
				Zuora__CustomerAccount__c billingAcct = new Zuora__CustomerAccount__c (Id = subs.Zuora__CustomerAccount__c
					, eBroadcast_Product_Access__c = true
					, eBroadcast_Available_Email_Balance__c = emailBalance
					);
				updatedCustomerAccountList.add(billingAcct);
			}
		}
		update updatedCustomerAccountList;
	} // processEbcSubscription
	
	
}