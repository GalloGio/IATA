/*
* Trigger Helper class for zuora__Subscription__c 
*  
*  Context: eBroadcast, new subscription. 
*  
*  This class updates related Zuora__CustomerAccount__c and insert related EBC_Activity__c
*  
*  Design note: 
*  - This class requires information from related Product_Rate_Plan_Information to check Product Category: 
*  - Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Name.
*  - Given: during the insert process (as initiated from IECSubscriptionManager.subscribe()), the Product_Rate_Plan_Information is still null
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
*   - 20160705-sl: add EBC_Preference initialization
*	- 20160721-sl: change Activity_Date to Activity_Date_Time, initial type is Credit
*/


public with sharing class trgIECEBC_SubscriptionHandler {
	
	public static boolean firstRun = true; // this is used to prevent processEbcSubscription executed twice on one execution
	private static final String EBC_ACTIVITY_NAME_INITIAL = 'Initial E-mail Balance';
	
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
		
		// we need to cover the case that a customer buys multiple subscription at the same time in calculation
		// we should only update one BillingAccount(CustomerAccount) for the each user.
		Map<Id,Zuora__CustomerAccount__c> updatedCustomerAccountMap = new Map<Id,Zuora__CustomerAccount__c>(); // use map to ensure unique BillingAccount are updated
		List<EBC_Activity__c> newEbcActivityList = new List<EBC_Activity__c>();
		
		Set<Id> relatedBillingAccountIdSet = new Set<Id>(); // related billing account Id involved with these subscriptions, used for creating EBC_Preference
		for (Zuora__Subscription__c subs : relevantSubscriptionList)
		{
			relatedBillingAccountIdSet.add(subs.Zuora__CustomerAccount__c); // collect billing id to check related EBC_Preference
			if ( (subs.Zuora__CustomerAccount__c != null)
				&& (subs.Zuora__Status__c == 'Active')
				&& (subs.Zuora__SubscriptionStartDate__c <= Date.today())
				&& (subs.Zuora__SubscriptionEndDate__c >= Date.today())
				)
			{ 
                //is there a new to create an activity or is it handle by the
                //EBC_order__c object
                
                Integer numberemail= integer.valueOf(subs.Product_Rate_Plan_Information__r.Product_Rate_Plan__r.EBC_PrePaid_Emails__c);
                if (numberemail==null) numberemail=0;
                List<EBC_Order__c> orderlist=new List<EBC_Order__c>();
                orderlist=[Select id 
                            From EBC_Order__c
                            Where Billing_Account__c=:subs.Zuora__CustomerAccount__c
                               and Email_Credit__c =: numberemail
                               and eBroadcast_Payment_Target__c='rateplan'
                               and createddate=TODAY
                              Order By Name Desc
                            Limit 1];
                //add new EBC_Activity
                if (orderlist.size()==0){
				
			    //if (iecebc_process.isebcpaymentinprogress==false){
						EBC_Activity__c ebcAct = newEbcActivity( subs, billingAccountIdToEmailBalanceMap.get(subs.Zuora__CustomerAccount__c));
					newEbcActivityList.add(ebcAct);
					billingAccountIdToEmailBalanceMap.put( subs.Zuora__CustomerAccount__c, Integer.valueOf(ebcAct.New_Balance__c));
                }
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
		if (relatedBillingAccountIdSet.size()>0) {
			initializeRelatedEbcPreference(relatedBillingAccountIdSet);
		}
	} // processEbcSubscription
	
	
	// ========================================================================
	// insert a new EBC_Activity for this new subscription transaction
	// Each EBC subscription bought will add new EBC Activity record
	// subs parameter should have the following fields
	//   Name, Zuora__CustomerAccount__c,
	//   Product_Rate_Plan_Information__r.Product_Rate_Plan__r.EBC_PrePaid_Emails__c
	private static EBC_Activity__c newEbcActivity(Zuora__Subscription__c subs, Integer currentBalance)
	{
		Integer emailCredits = (subs.Product_Rate_Plan_Information__r.Product_Rate_Plan__r.EBC_PrePaid_Emails__c == null ) ? 0 : Integer.valueOf(subs.Product_Rate_Plan_Information__r.Product_Rate_Plan__r.EBC_PrePaid_Emails__c);
		Integer newBalance = currentBalance + emailCredits;
		
		String actName =  subs.Name + ' - ' + subs.Product_Rate_Plan_Information__r.Product_Rate_Plan__r.Name + ' - ' + EBC_ACTIVITY_NAME_INITIAL;
		actName = actName.substring(0, Math.min(actName.length(),80));
		EBC_Activity__c ebcAct = new EBC_Activity__c(
			Related_Billing_Account__c = subs.Zuora__CustomerAccount__c
			, Name = actName
			//,EBC_Campaign__c = null
			, Total_Count__c = emailCredits
			, New_Balance__c = newBalance
			, Activity_Type__c = 'Credit'
			, Activity_Date_Time__c  = Date.today()
			);
		
		return ebcAct; 
	} // addEbcActivity
	
	
	// ========================================================================
	// get existing EBC_Preference 
	// if it already exists, do nothing, otherwise insert with initialized values
	private static void initializeRelatedEbcPreference(Set<Id> billingAcctIdSet)
	{
		List<Zuora__CustomerAccount__c> billingAcctList =
			[select Id
				, Contact__r.Name
				, Zuora__BillToAddress1__c 
				, Zuora__Account__r.Name 
				, Contact__r.Email 
				, Contact__r.Title 
				, Zuora__BillToWorkPhone__c 
				, (select Id from eBroadcast_Preferences__r)  
			from Zuora__CustomerAccount__c
			where Id in : billingAcctIdSet];
		
		//System.assert( (billingAcctList.size() > 0), 'trgIECEBC_SubscriptionHandler:billingAccount should be available when calling initializeEbcPreference()'); 
		
		List<EBC_Preference__c> ebcPrefNewList = new List<EBC_Preference__c>();
		for (Zuora__CustomerAccount__c billingAcct : billingAcctList)
		{
			List<EBC_Preference__c> ebcPrefList = billingAcct.eBroadcast_Preferences__r;
			
			if (ebcPrefList.size() == 0) 
			{ // only insert and initialize for non existing ebc preference
				EBC_Preference__c ebcPref = new EBC_Preference__c( Billing_Account__c = billingAcct.Id
					, Default_From_Name__c = 'International Air Transport Association'// billingAcct.Contact__r.Name
					, Name = billingAcct.Contact__r.Name
					, PrimaryContact_Address__c = billingAcct.Zuora__BillToAddress1__c
					, PrimaryContact_Company__c = billingAcct.Zuora__Account__r.Name
					, PrimaryContact_Email__c = billingAcct.Contact__r.Email
					, PrimaryContact_Job_Title__c = billingAcct.Contact__r.Title
					, PrimaryContact_Name__c = billingAcct.Contact__r.Name
					, PrimaryContact_Phone__c = billingAcct.Zuora__BillToWorkPhone__c
				);
				ebcPrefNewList.add(ebcPref);
			} // end if
		} // end for billingActList
		
		insert ebcPrefNewList;
	} // initializeRelatedEbcPreference
	

} // trgIECEBC_SubscriptionHandler