/*
* Trigger Helper class for zuora__Subscription__c 
*  
*  Context: eBroadcast, new subscription. 
*  
*  This class updates related Zuora__CustomerAccount__c and insert related EBC_Activity__c
*  
*  Design note: 
*  - This class requires information from related Product_Rate_Plan_Information to check Product Category 
*  - Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Name.
*  - During the insert process (as initiated from IECSubscriptionManager.subscribe()), the Product_Rate_Plan_Information is still null
*  - Zuora__Subscription__c.Product_Rate_Plan_Information will be populated later by trgHndlrIECSubscriptionProductCharge.BuildProductLink
*  - Therefore, the update of Zuora__CustomerAccount__c EBC related flag is done on Subscription update.
* 
*  Assumption: 
*   - Only one currently active EBC Zuora__Subscription for today
*  
*   - Early version: We are not reinserting the same Zuora__Subscription
*   - if we need to do it, we will need to store the recent unique id of the current 
*  
*  
*  Author: Sonny Leman
*  Change Log: 
*   - 20160704-sl: initial version, with EBC_Activity Activity_Type = Initial E-mail Balance
*
*/


public with sharing class trgIECEBC_SubscriptionHandler {
	
	public static boolean firstRun = true; // this is used to prevent processEbcSubscription executed twice on one execution
	
	// ========================================================================
	// processEbcSubscription will update related Zuora__CustomerAccount and insert an EBC_Activity
	// newSubscriptionMap is trigger.NewMap ; oldSubscriptionMap trigger.OldMap
	// to be run after Zuora__Subscription are updated
	// current behaviour of the subscription process sets the oldSub.Product_Information_Rate_Plan on update, not insert.
	// see IECSubscriptionManager.subscribe()
	public static void processEbcSubscription( Map<Id,Zuora__Subscription__c> newSubscriptionMap, Map<Id,Zuora__Subscription__c> oldSubscriptionMap)
	{
		System.debug( '\n\n trgIECEBC_SubscriptionHandler firstRun:' + firstRun);
		// first, ensure this method only works once in an execution
		if (firstRun) 
		{
			firstRun = false;
		} else {
			System.debug('trgIECEBC_SubscriptionHandler.processEbcSubscription has been executed previously, skip for now.');
			return;
		}
		
		// get relevant subscription whose billing account will be updated
		Set<Id> zuoraSubscriptionIdSet = new Set<Id>(); 
		Zuora__Subscription__c oldSub; 
		for (Zuora__Subscription__c sub : newSubscriptionMap.values())
		{
			oldSub = oldSubscriptionMap.get(sub.Id);
			if ((sub.Product_Rate_Plan_Information__c != null) 
				&&( (oldSub == null)
					|| (oldSub.Product_Rate_Plan_Information__c == null) 
					)
				)
			{
				zuoraSubscriptionIdSet.add(sub.Id);
			} // end if
		} // end for
		
		System.debug( '\n\n trgIECEBC_SubscriptionHandler.zuoraSubscriptionIdSet:' + zuoraSubscriptionIdSet);
		// collect relevant subscription & relevant billing account for ebroadcast
		// order by the subscription id 
		List<Zuora__Subscription__c> relevantSubscriptionList = [
			select Id, Name
				, Zuora__Status__c
				, Zuora__SubscriptionStartDate__c
				, Zuora__SubscriptionEndDate__c
				, Zuora__CustomerAccount__c, Zuora__CustomerAccount__r.Id
				, Zuora__CustomerAccount__r.Contact__c
				//, Zuora__CustomerAccount__r.eBroadcast_Current_Subscription_Name__c // this is still in rough planning
				, Zuora__CustomerAccount__r.eBroadcast_Product_Access__c
				, Zuora__CustomerAccount__r.eBroadcast_Email_Balance__c
				, Product_Rate_Plan_Information__c
				, Product_Rate_Plan_Information__r.Name
				, Product_Rate_Plan_Information__r.Product_Rate_Plan__c
				, Product_Rate_Plan_Information__r.Product_Rate_Plan__r.Name
				, Product_Rate_Plan_Information__r.Product_Rate_Plan__r.EBC_SubscriptionType__c
				, Product_Rate_Plan_Information__r.Product_Rate_Plan__r.EBC_Cost_Per_Email__c
				, Product_Rate_Plan_Information__r.Product_Rate_Plan__r.EBC_PrePaid_Emails__c
				, Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Name
				
			from Zuora__Subscription__c
			where  Id in : zuoraSubscriptionIdSet 
				and Product_Rate_Plan_Information__c != null
				and (Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Name = : IECConstants.ProductCategory_SF_EBROADCAST)
			order by Id asc
			]; 
		
		//System.debug( '\n\ntrgIECEBC_SubscriptionHandler.relevantSubscriptionIdToObjMap:' + relevantSubscriptionIdToObjMap);
		Map<Id,Integer> billingAccountIdToEmailBalanceMap = new Map<Id,Integer>();
		
		// intialize  billingAccountIdToEmailBalanceMap
		for ( Zuora__Subscription__c subs : relevantSubscriptionList) 
		{
			billingAccountIdToEmailBalanceMap.put( subs.Zuora__CustomerAccount__c, Integer.valueOf(subs.Zuora__CustomerAccount__r.eBroadcast_Email_Balance__c));
		}
		
		// we need to cover the case that a customer buys multiple subscription at the same time
		// we should only update one BillingAccount(CustomerAccount) for the each user.
		Map<Id,Zuora__CustomerAccount__c> updatedCustomerAccountMap = new Map<Id,Zuora__CustomerAccount__c>(); // use map to ensure unique BillingAccount are updated
		List<EBC_Activity__c> newEbcActivityList = new List<EBC_Activity__c>();
		
		for (Zuora__Subscription__c subs : relevantSubscriptionList)
		{
			
			if ( (subs.Zuora__CustomerAccount__c != null)
				&& (subs.Zuora__Status__c == 'Active')
				&& (subs.Zuora__SubscriptionStartDate__c <= Date.today())
				&& (subs.Zuora__SubscriptionEndDate__c >= Date.today())
				//&& (subs.Zuora__External_Id__c != subs.Zuora__CustomerAccount__r.Current_EBC_Subscription_External_Id__c)
				//&& (subs.Name != subs.Zuora__CustomerAccount__r.eBroadcast_Current_Subscription_Name__c)
				)
			{ 
				// add new EBC_Activity
				EBC_Activity__c ebcAct = newEbcActivity( subs, billingAccountIdToEmailBalanceMap.get(subs.Zuora__CustomerAccount__c));
				newEbcActivityList.add(ebcAct);
				billingAccountIdToEmailBalanceMap.put( subs.Zuora__CustomerAccount__c, Integer.valueOf(ebcAct.New_Balance__c));
				
				// update Billing Account: set eBroadcast Product Access flag 
				Zuora__CustomerAccount__c billingAcct = new Zuora__CustomerAccount__c (Id = subs.Zuora__CustomerAccount__c
					, eBroadcast_Product_Access__c = true
					);
				updatedCustomerAccountMap.put(billingAcct.Id,billingAcct);
			} // end if 
		} // end for  Zuora__Subscription__c
		
		//System.debug( '\n\ntrgIECEBC_SubscriptionHandler.updatedCustomerAccountList:' + updatedCustomerAccountList);
		if ( updatedCustomerAccountMap.size() > 0) {
			update updatedCustomerAccountMap.values();
		}
		if ( newEbcActivityList.size() > 0) {
			insert newEbcActivityList;
		}
	} // processEbcSubscription
	
	
	// ========================================================================
	// insert a new EBC_Activity for this new subscription transaction
	// Each EBC subscription bought will add new EBC Activity record
	private static EBC_Activity__c newEbcActivity(Zuora__Subscription__c subs, Integer currentBalance)
	{
		Integer emailCredits = (subs.Product_Rate_Plan_Information__r.Product_Rate_Plan__r.EBC_PrePaid_Emails__c == null ) ? 0 : Integer.valueOf(subs.Product_Rate_Plan_Information__r.Product_Rate_Plan__r.EBC_PrePaid_Emails__c);
		Integer newBalance = currentBalance + emailCredits;
		
		String actName =  subs.Name + ' - ' + subs.Product_Rate_Plan_Information__r.Product_Rate_Plan__r.Name;
		actName = actName.substring(0, Math.min(actName.length(),80));
		
		EBC_Activity__c ebcAct = new EBC_Activity__c(
			Related_Billing_Account__c = subs.Zuora__CustomerAccount__c
			, Name = actName
			//EBC_Campaign__c = c.I;
			, Total_Count__c = emailCredits
			, New_Balance__c = newBalance
			, Activity_Type__c = 'Initial E-mail Balance'
			, Activity_Date__c  = Date.today()
			);
		
		return ebcAct; 
	} // addEbcActivity
	
} // trgIECEBC_SubscriptionHandler