/**
 * This class is used to extends any controller of the eBroadcast project.
 * 
 * It contains various usefull method and properties that can be reused such as
 * as the access to the rate plan, etc.
 * 
 * Getter Dependencies
 *   billingAccount: vfIECEBC.billingAccount. 
 *   preference: vfIECEBC.preference.
 *   subscription: vfIECEBC.preferenc.
 *   productRatePlan: subscription
 *   isMember: billingAccount, no setter.
 *   isEbcPrepaid: productRatePlan, no setter.
 *   productRatePlanCharge: productRatePlan.
 *   productRatePlanIdUpgradeSet: productRatePlanIdUpgradeList
 *   productRatePlanIdUpgradeList: productRatePlan, IECEBC_Utility.ebcNonMemberProductRatePlanIdList, ebcMemberProductRatePlanIdList.
 *   
 *   allowableEbcAddOnProductRatePlanList: IECEBC_Utility.ebcSetup, allowableEbcAddOnProductRatePlanIdSet.
 *   allowableEbcAddOnProductRatePlanIdSet: IECEBC_Utility.ebcSetup, productRatePlan.
 *
 *   currentEbcAddOnProductRatePlanList: currentEbcAddOnProductRatePlanIdToSubscriptionMap
 *   currentEbcAddOnProductRatePlanIdToSubscriptionMap: currentEbcAddOnSubscriptionProductChargeList
 *   currentEbcAddOnSubscriptionProductChargeList: IECEBC_Utility.ebcAddOnProductRatePlanAllIdSet
 *
 *   hasValidAddOnEnhancedReporting: subscription, no setter.
 *   
 *   
 * Supporting methods  
 *   rereadBillignAccount()
 *   goToPaymentPageBase()
 *   rereadSubscription()
 *   
 * Change log:
 *   20160704-mb: initial version
 *   20160809-sl: modify productRatePlanIdUpgradeList
 *   20160811-sl: add currentAddon
 *   20160824-sl: modify the query for EbcAddOn rate plans to comply with technical design: select based on EBC_Setup instead of zqu__ZProduct.ProductCategory__c 
 *   20160915-sl: add payment related constants and rereadBillingAccount method 
 *
 **/

public virtual class vfIECEBC_Controller {
	
	// contants for zqu__ProductRatePlan.EBC_SubscriptionType__c
	public static final String EBC_PRODUCT_RATE_PLAN_SUBSCRIPTION_TYPE_PAY_AS_YOU_GO = 'Pay-As-You-Go';
	public static final String EBC_PRODUCT_RATE_PLAN_SUBSCRIPTION_TYPE_PRE_PAID = 'Pre-Paid';
	
	// ===================================================================================
	// this is used as url parameter for the EBC Payment pages 
	public static final String EBC_PAYMENT_PARAM_PAYMENT_TOKEN = 'paymentToken';
	public static final String EBC_PAYMENT_PARAM_CAMPAIGN_OPTION = 'campaignPaymentOption';
	public static final String EBC_PAYMENT_PARAM_PAYMENT_TARGET = 'target';
	public static final String EBC_PAYMENT_PARAM_RATE_PLAN_ID = 'ratePlanId';
	public static final String EBC_PAYMENT_PARAM_EMAIL_CREDIT_PURCHASED = 'emailCreditAmount';
	
	// values for URL parameter campaignPaymentOption / eBroadcast_Payment_Campaign_Option__c
	public static final String EBC_PAYMENT_CAMPAIGN_NONE = '';//'None'; 
	public static final String EBC_PAYMENT_CAMPAIGN_EXACT = 'Exact Amount'; 
	public static final String EBC_PAYMENT_CAMPAIGN_EMAIL_PACKAGE = 'Email Package'; 
	public static final String EBC_PAYMENT_CAMPAIGN_RATE_PLAN = 'Prepaid Rate Plan';
	
	// values for URL parameter target / eBroadcast_Payment_Target__c
	public static final String EBC_PAYMENT_TARGET_CAMPAIGN = 'campaign';
	public static final String EBC_PAYMENT_TARGET_ACCOUNT_RATE_PLAN = 'rateplan';
	public static final String EBC_PAYMENT_TARGET_ACCOUNT_EMAIL_PACKAGE = 'email';
	public static final String EBC_PAYMENT_TARGET_ACCOUNT_ADD_ON_REPORTING = 'addon reporting';
	public static final String EBC_PAYMENT_TARGET_ACCOUNT_ADD_ON_STORAGE = 'addon storage';
	public static final String EBC_PAYMENT_TARGET_RENEWAL = 'renewal';
	
	
	// Zuora__CustomerAccount__c.ClientType__c picklist value, this was used to determine if a billing account is of a member
	//private static final String BILLING_ACCOUNT_CLIENT_TYPE_MEMBER_AIRLINE = 'Member Airline'; 
	
	// Exception to be thrown by the controllers
	public class Controller_Exception extends Exception{}
	
	// ========================================================================
	// constructor
	public vfIECEBC_Controller()
	{
	}
	
	// ========================================================================
	// verify and update if needed the value of billingAccount.eBroadcast_Add_On_Advanced_Reporting__c.
	// this can be called from any controller that might need this.
	public void verifyAddOnEnhancedReportingFlagValidity()
	{
		if (billingAccount.eBroadcast_Add_On_Advanced_Reporting__c != hasValidAddOnEnhancedReporting)  
		{ // billingAccount needs update
			Zuora__CustomerAccount__c updatedBillingAccount = new Zuora__CustomerAccount__c(
					Id = billingAccount.Id
					,  eBroadcast_Add_On_Advanced_Reporting__c = hasValidAddOnEnhancedReporting
				); 
			update updatedBillingAccount;
			rereadBillingAccount();
		}
	} // end of verifyAddOnEnhancedReportingFlagValidity
	
	// The current user
	public User usr {
		get {
			if (usr == null) usr = vfIECEBC.usr;
			return usr;
		}
		set;
	}
	
	// The billing account associated with the current user
	public Zuora__CustomerAccount__c billingAccount {
		get {
			if (billingAccount == null) billingAccount = vfIECEBC.billingAccount;
			return billingAccount;
		}
		private set;
	}
	// Reread billing account associated with the current user
	public Zuora__CustomerAccount__c rereadBillingAccount()
	{
		billingAccount = null;
		vfIECEBC.rereadBillingAccount(); 
		return billingAccount;
	}
	
	// ========================================================================
	// rereadSubscription will force the getters to reread the subscription record from the database
	// this is relevant in the case of new EBC Subscription Prepaid rate plan purchase, renewal, or 
	// enhanced reporting add on purchase (which link to the EBC Subscription)
	public void rereadSubscription()
	{
		vfIECEBC.rereadSubscription(); // this will reset vfIECEBC.subscription and vfIECEBC.productRatePlan
		
		// nullify the following values, so getters will update them
		// start from the least dependent properties
		subscription = null;
		productRatePlan = null;
		productRatePlanCharge = null;
		productRatePlanIdUpgradeSet = null;
		productRatePlanIdUpgradeList = null;
		
		allowableEbcAddOnProductRatePlanIdSet = null;
		allowableEbcAddOnProductRatePlanList = null;
		
		currentEbcAddOnSubscriptionProductChargeList = null;
		currentEbcAddOnProductRatePlanIdToSubscriptionMap = null;
		currentEbcAddOnProductRatePlanList = null;
		
	} // rereadSubscription
	
	
	// ========================================================================
	// The zuora EBC subscription associated with the current billing account
	public Zuora__Subscription__c subscription {
		get {
			if (subscription == null) subscription = vfIECEBC.subscription;
			return subscription;
		}
		private set;
	}
	
	// The zuora rate plan associated with the current subscription
	public zqu__ProductRatePlan__c productRatePlan {
		get {
			if (productRatePlan == null) productRatePlan = vfIECEBC.productRatePlan;
			return productRatePlan;
		}
		private set;
	}
	
	// The zuora rate plan associated with the current subscription
	public EBC_Preference__c preferences {
		get {
			if (preferences == null) preferences = vfIECEBC.pref;
			return preferences;
		}
		set;
	}
	
	// Used by visualforce pages to rerender block without reloading entire page
	public PageReference doNothing() {
		return null;
	}
	
	// return true if this community user is a member 
	public Boolean isMember {
		get{
			// return ( billingAccount.ClientType__c == BILLING_ACCOUNT_CLIENT_TYPE_MEMBER_AIRLINE );
			return (billingAccount.Contact__c != null & billingAccount.Contact__r.IATA_Code__c != null);
		}
	}
	
	// ======================================================================== 
	// isEbcPrepaid flag is true is the EBC is Prepaid
	public Boolean isEbcPrepaid{
		get{
			return (productRatePlan.EBC_SubscriptionType__c == EBC_PRODUCT_RATE_PLAN_SUBSCRIPTION_TYPE_PRE_PAID);
		}
	}
	
	// =======================================================================-
	// current Product Rate Plan Charge based on given ProductRatePlan
	// assumptions:
	//  - the relationship between ProductRatePlan and Product Rate Plan Charge is 1:1 for eBroadcast
	//  
	public zqu__ProductRatePlanCharge__c productRatePlanCharge
	{
		get{
			if ( productRatePlanCharge == null )
			{ 
				List<zqu__ProductRatePlanCharge__c> prodRatePlanChargeList = [select Id
					, zqu__ProductRatePlan__c 
					, zqu__ListPrice__c
					, zqu__Description__c
					from zqu__ProductRatePlanCharge__c 
					where 
						zqu__ProductRatePlan__c = : productRatePlan.Id];
				productRatePlanCharge = (prodRatePlanChargeList.size() == 0) ? null : prodRatePlanChargeList[0];
			}
			return productRatePlanCharge;
		}
		set;
	} // end of productRatePlanCharge getter/setter
	
	
	// ========================================================================
	// supporting variables for the Payment Confirmation sections in Manage Account
	// Used in Rate Plan and Add On tabs
	// ========================================================================
	public Decimal totalNewPurchaseAmount {get;set;}
	public List<zqu__ProductRatePlanCharge__c> newPurchasedRatePlanChargeList {get;set;}
	// recalc newPurchasedRatePlanChargeList and totalNewPurchaseAmount
	public void updateNewPurchasedRatePlanChargeList( List<zqu__ProductRatePlanCharge__c> prpcList )
	{
		newPurchasedRatePlanChargeList = new List<zqu__ProductRatePlanCharge__c>();
		totalNewPurchaseAmount = 0;
		if (prpcList != null)
		{
			for (zqu__ProductRatePlanCharge__c prpc : prpcList )
			{
				newPurchasedRatePlanChargeList.add(prpc);
				totalNewPurchaseAmount += prpc.zqu__ListPrice__c;
			}
		}
		
		// this is a workaround to display the 'please select rate plan', in case there is no selected rate plan, put a dummy one for the message
		if (newPurchasedRatePlanChargeList.size() == 0) {
			zqu__ProductRatePlanCharge__c dummyRatePlan = new zqu__ProductRatePlanCharge__c( Id=null, Name='Please select a plan', zqu__ListPrice__c=0);
			newPurchasedRatePlanChargeList.add(dummyRatePlan);
		}
		//System.debug( 'updateNewPurchasedRatePlanChargeList.totalNewPurchaseAmount:' + totalNewPurchaseAmount);
		//System.debug( 'updateNewPurchasedRatePlanChargeList.newPurchasedRatePlanChargeList:' + newPurchasedRatePlanChargeList);
	} // end of updateNewPurchasedRatePlanChargeList
	
	
	
	// =======================================================================-
	// productRatePlanIdUpgradeSet return set of zqu__ProductRatePlan__.Id available as the upgrade destination from the current ProductRatePlan
	// new version as defined in the architecture design: use EBC_Setting record fields defining available ProductRatePlan 
	// should we need to add more EBC Rate Plan, we might need to change the code and add more field in EBC_Setting
	// this is used by AccountManage and AccountRatePlan classes
	public Set<Id> productRatePlanIdUpgradeSet {
		get{
			if (productRatePlanIdUpgradeSet==null) 
			{
				Set<Id> targetProductRatePlanIdSet = new Set<Id>();
				targetProductRatePlanIdSet.addAll(productRatePlanIdUpgradeList);
				productRatePlanIdUpgradeSet = targetProductRatePlanIdSet;
			}
			return productRatePlanIdUpgradeSet;
		}
		set;
	}
	
	// =======================================================================-
	// productRatePlanIdUpgradeList return set of zqu__ProductRatePlan__.Id available as the listed destination from the current ProductRatePlan
	// this list is also used in providing a sorted list of upgrade product rate plan
	public List<Id> productRatePlanIdUpgradeList {
		get{
			if (productRatePlanIdUpgradeList==null) 
			{
				List<Id> nonMemberRatePlanIdList = IECEBC_Utility.ebcNonMemberProductRatePlanIdList;
				List<Id> memberRatePlanIdList = IECEBC_Utility.ebcMemberProductRatePlanIdList;
				
				// check if the upgrade options are in rate plan for member
				// scan the list based on membership
				// baseRatePlanList is the applicable ebc rate plan options based on the user membership type
				List<Id> baseRatePlanList =  (isMember) ? memberRatePlanIdList : nonMemberRatePlanIdList;
				List<Id> targetProductRatePlanIdList = new List<Id>();
				
				Integer idx = baseRatePlanList.size()-1;
				while ( idx >= 0
					   && ( baseRatePlanList[idx] != productRatePlan.Id ))
				{ 
					List<Id> updatedList = new List<ID> {baseRatePlanList[idx]};
					updatedList.addAll(targetProductRatePlanIdList); // note that we need also to maintain the list ordering
					targetProductRatePlanIdList = updatedList;
					idx--;
				}
				//Integer currentRatePlanIndex = (idx < baseRatePlanList.size()) ? idx : null;
				
				productRatePlanIdUpgradeList = targetProductRatePlanIdList;
			} // end if
			
			return productRatePlanIdUpgradeList;
		} // end getter
		private set;
	} // productRatePlanUpgradeList getter/setter.	
	
	// ========================================================================
	// Supporting methods for EBC AddOns
	// this will be used in the IECEBC Dashboard and IECEBC AccountExtras
	// ------------------------------------------------------------------------
	
	
	// ========================================================================
	// return the list of all available eBroadcastProduct Rate Plan Add On
	// was productRatePlanAddonList
	public List<zqu__ProductRatePlan__c> allowableEbcAddOnProductRatePlanList {
		get{
			if (allowableEbcAddOnProductRatePlanList == null) 
			{
				List<zqu__ProductRatePlan__c> prodRatePlanList = [select Id, Name
					, zqu__Description__c
					, zqu__EffectiveEndDate__c
					, (select Id, Name, zqu__ProductRatePlan__c, zqu__ListPrice__c, zqu__Description__c, zqu__Type__c
							, zqu__RecurringPeriod__c
						from zqu__R00N40000001mFVKEA2__r // zqu__ProductRatePlanCharge__r child list
						where zqu__Deleted__c != true
						order by Id)
					, (select Id, Name, Product_Rate_Plan__c, Short_Description__c, Long_Description__c, Order__c
						from Product_Rate_Plan_Informations__r order by Order__c, Id)
					
					from zqu__ProductRatePlan__c 
					where  Id in : allowableEbcAddOnProductRatePlanIdSet
							and zqu__Deleted__c != true
					order by Name ASC, Id DESC
					limit 100];
				
				allowableEbcAddOnProductRatePlanList = prodRatePlanList;
			} // end if
			return allowableEbcAddOnProductRatePlanList;
		} // end get
		private set;
	} // end of allowableEbcAddOnProductRatePlanList getter/setter
	
	// =========================================================================
	// collection of all ProductRatePlan Id that can be subscribed by this user
	// that also includes those that are already subscribed
	private Set<Id> allowableEbcAddOnProductRatePlanIdSet{
		get{
			Set<Id> allowedSet = new Set<Id>();
			if ( productRatePlan.EBC_SubscriptionType__c == EBC_PRODUCT_RATE_PLAN_SUBSCRIPTION_TYPE_PRE_PAID ) 
			{
				if (IECEBC_Utility.ebcSetup.Enhanced_Reporting_Product_Rate_Plan__c != null) {
					allowedSet.add(IECEBC_Utility.ebcSetup.Enhanced_Reporting_Product_Rate_Plan__c);
				}
				if (IECEBC_Utility.ebcSetup.Storage_Product_Rate_Plan__c != null) {
					allowedSet.add(IECEBC_Utility.ebcSetup.Storage_Product_Rate_Plan__c);
				}
			} else {
				if (IECEBC_Utility.ebcSetup.Storage_Product_Rate_Plan__c != null) {
					allowedSet.add(IECEBC_Utility.ebcSetup.Storage_Product_Rate_Plan__c);
				}
			} // end if
			return allowedSet;
		}
		private set;
	} // end of allowableEbcAddOnProductRatePlanIdSet getter/setter
	
	// =========================================================================
	// showLinkToProductAddOn is false if all allowableEbcAddOnProductRatePlanIdSet already subscribed
	public Boolean showLinkToProductAddOn {
		get {
			Boolean hasNoMoreAvailableOptions = ! currentEbcAddOnProductRatePlanIdToSubscriptionMap.keyset().containsAll(allowableEbcAddOnProductRatePlanIdSet);
			return hasNoMoreAvailableOptions;
		}
		//private set;
	}
	// =========================================================================
	// currentEbcAddOnProductRatePlanList return currently subscribed ProductRatePlan for EBC Add Ons
	public List<zqu__ProductRatePlan__c> currentEbcAddOnProductRatePlanList
	{
		get{
			if ( currentEbcAddOnProductRatePlanList == null )
			{ 
				Set<Id> purchasedProductRatePlanSet = currentEbcAddOnProductRatePlanIdToSubscriptionMap.keySet();
				
				// query ProductRatePlan independently in order to get the Product_Rate_Plan_Information__c.Long_Description__c
				List<zqu__ProductRatePlan__c> prodRatePlanList = [select Id, Name
					, zqu__Description__c
					, zqu__EffectiveEndDate__c
					, (select Id, Name, zqu__ProductRatePlan__c, zqu__ListPrice__c, zqu__Description__c, zqu__Type__c
							, zqu__RecurringPeriod__c
						from zqu__R00N40000001mFVKEA2__r 
						where zqu__Deleted__c != true
						order by Id)
					, (select Id, Name, Product_Rate_Plan__c, Short_Description__c, Long_Description__c, Order__c
						from Product_Rate_Plan_Informations__r order by Order__c, Id)
					from zqu__ProductRatePlan__c 
						where  Id in : purchasedProductRatePlanSet
						order by Name, Id
						limit 100];
				
				currentEbcAddOnProductRatePlanList = prodRatePlanList;
			}
			return currentEbcAddOnProductRatePlanList;
		}
		private set;
	} // end of currentEbcAddOnProductRatePlanList getter/setter
	
	// =========================================================================
	// currentEbcAddOnProductRatePlanIdToSubscriptionMap is used to get the Subscription details
	// and also to get unique set of productRatePlanId
	public Map<Id, Zuora__Subscription__c> currentEbcAddOnProductRatePlanIdToSubscriptionMap{
		get{
			if (currentEbcAddOnProductRatePlanIdToSubscriptionMap==null)
			{
				Map<Id, Zuora__Subscription__c> prpIdToSubMap = new Map<Id, Zuora__Subscription__c>();
				for (Zuora__SubscriptionProductCharge__c  spc : currentEbcAddOnSubscriptionProductChargeList)
				{
					prpIdToSubMap.put(spc.Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__c, spc.Zuora__Subscription__r);
				}
				currentEbcAddOnProductRatePlanIdToSubscriptionMap = prpIdToSubMap;
			}
			return currentEbcAddOnProductRatePlanIdToSubscriptionMap;
		}
		private set;
	} // currentEbcAddOnProductRatePlanIdToSubscriptionMap getter/setter
	 
	
	// ========================================================================
	// currentEbcAddOnSubscriptionProductChargeList return currently subscribed ProductRatePlan for Add On
	// input: current user (billing account)
	// assumption:
	//   - relationship between Subscription and SubscriptionProductCharge is 1:n 
	//   - selecting on EBC Add On category is based on ProductCategory__c from zqu__ZProduct not Zuora__Product.
	// 
	private List<Zuora__SubscriptionProductCharge__c> currentEbcAddOnSubscriptionProductChargeList{
		get{
			if (currentEbcAddOnSubscriptionProductChargeList==null)
			{
				List<Zuora__SubscriptionProductCharge__c> subsProductChargeList = [select Id
						, Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__c
						, Zuora__Subscription__r.Zuora__TermEndDate__c
					from Zuora__SubscriptionProductCharge__c 
					where Zuora__Subscription__r.Zuora__CustomerAccount__c = : billingAccount.Id
						and Zuora__Subscription__r.Zuora__TermEndDate__c >= TODAY
						and ( Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.Id in : IECEBC_Utility.ebcAddOnProductRatePlanAllIdSet )
					order by Zuora__Subscription__r.Zuora__Status__c DESC, Zuora__Subscription__r.LastModifiedDate
				];
				currentEbcAddOnSubscriptionProductChargeList = subsProductChargeList;
			}
			return currentEbcAddOnSubscriptionProductChargeList;
		}
		private set;
	} // currentEbcAddOnSubscriptionProductChargeList getter/setter
	
	
	// ========================================================================
	// hasValidAddOnEnhancedReporting will check the list of current rate plan on the currently active EBC Subscription
	// it will return true if it include the rate plan of the Enhanced Reporting Add On.
	// the rate plan of the Enhanced Reporting Add On is based on what we set in EBC_Setup.
	public Boolean hasValidAddOnEnhancedReporting
	{
		get{
			return currentEbcAddOnProductRatePlanIdToSubscriptionMap.keySet().contains(IECEBC_Utility.ebcSetup.Enhanced_Reporting_Product_Rate_Plan__c);
		}
	}
	
	
	// ========================================================================
	// this is the core of goToPaymentPage
	// pass the eBroadcast_Payment_* fields from the page calling the payment to the payment page.
	//  - paymentPageBase: Page.IECEBC_Payment or Page.IECECBC_CampaignPayment
	//  - ebcPaymentTarget : Zuora__CustomerAccount__c.eBroadcast_Payment_Target__c ( EBC_PAYMENT_TARGET_* )
	//  - ebcPaymentCampaignOption : Zuora__CustomerAccount__c.eBroadcast_Payment_Campaign_Option__c (EBC_PAYMENT_CAMPAIGN_*)
	//  - token will be calculated
	// the amount detail on the product rate plan charge will be recalculated and reselected
	// this ensure the data integrity and simplify the caller
	// 
	public PageReference goToPaymentPageBase( PageReference paymentPageBase 
					, String ebcPaymentTarget
					, String ebcPaymentCampaignOption
					, Id subscriptionId
					, Id productRatePlanId
					, Id campaignId 
					, Integer creditAmount
                    
 		)
	{	system.debug('campaignId :: ' + campaignId);
		system.debug('paymentPageBase :: ' + paymentPageBase);
		system.debug('ebcPaymentTarget :: ' + ebcPaymentTarget);
		system.debug('ebcPaymentCampaignOption :: ' + ebcPaymentCampaignOption);
		system.debug('subscriptionId :: ' + subscriptionId);
		system.debug('productRatePlanId :: ' + productRatePlanId);
		system.debug('creditAmount :: ' + creditAmount);
		String objectId = (subscriptionId == null) ? '' : subscriptionId;
		objectId += (productRatePlanId == null) ? '' : productRatePlanId;
		objectId += (ebcPaymentCampaignOption == null) ? '' : ('-' + ebcPaymentCampaignOption); 
		
		String theToken = IECEBC_Utility.generatePaymentToken( objectId + ebcPaymentTarget);
        
        EBC_Order__c paymentBillingAccount;
        
        List<EBC_Order__c> BillingAccountOrders =new List<EBC_Order__c>();
        
        BillingAccountOrders = [Select Id
                               	,eBroadcast_Payment_Token__c
                                , eBroadcast_Payment_Target__c
                                , eBroadcast_Payment_Subscription__c
                                , eBroadcast_Payment_Product_Rate_Plan__c
                                , eBroadcast_Payment_Campaign__c
                                , eBroadcast_Payment_Campaign_Option__c
                                , eBroadcast_Payment_Email_Credit_Amount__c
                                , Email_Credit__c
                               From EBC_Order__c
                               Where billing_Account__c=: billingAccount.Id
                               and Status__c='Pending'
                               Limit 1];
        if (BillingAccountOrders.Size()>0) paymentBillingAccount =BillingAccountOrders[0];		
		if (BillingAccountOrders.Size()==0) paymentBillingAccount = new EBC_Order__c(billing_Account__c= billingAccount.Id); 
        
		paymentBillingAccount.eBroadcast_Payment_Token__c = theToken;
		paymentBillingAccount.eBroadcast_Payment_Target__c = ebcPaymentTarget;
		paymentBillingAccount.eBroadcast_Payment_Subscription__c = subscriptionId;
        paymentBillingAccount.eBroadcast_Payment_Product_Rate_Plan__c = productRatePlanId;
        paymentBillingAccount.eBroadcast_Payment_Campaign__c = campaignId; //null 
        paymentBillingAccount.eBroadcast_Payment_Campaign_Option__c = ebcPaymentCampaignOption; // EBC_PAYMENT_CAMPAIGN_NONE
        paymentBillingAccount.eBroadcast_Payment_Email_Credit_Amount__c = creditAmount;
        paymentBillingAccount.Email_Credit__c=0;
        paymentBillingAccount.Email_Debit__c=0;
        paymentBillingAccount.Status__c='Pending';
														
		upsert paymentBillingAccount;

		system.debug('eBroadcast_Payment_Campaign__c :: ' + paymentBillingAccount.eBroadcast_Payment_Campaign__c);

		List<EBC_Campaign__c> campaignList = new List<EBC_Campaign__c>();
        EBC_Campaign__c campaign;
        
        campaignList = [SELECT Is_Payment_Step__c FROM EBC_Campaign__c WHERE Id =: campaignId Limit 1];
        system.debug('campaign size is : '+campaignList.Size());
        if (campaignList.Size()>0) {
	        campaign = campaignList[0];
	        system.debug('#### campaign ID : ' + campaign.ID);
	        campaign.Is_Payment_Step__c = true;
	        system.debug('#### campaign.Is_Payment_Step__c : ' + campaign.Is_Payment_Step__c);
	        update campaign;
    	}
		system.debug('campaign :: ' + campaign);
		PageReference paymentPage = paymentPageBase;  
		paymentPage.getParameters().put( EBC_PAYMENT_PARAM_PAYMENT_TOKEN, theToken);
		paymentPage.getParameters().put( 'id', paymentBillingAccount.eBroadcast_Payment_Campaign__c);
		
		return paymentPage;
	} // end of goToRenewalPaymentPage
	
    public Double timezoneOffset {
        get {
            if (timezoneOffset == null) {
                TimeZone tz = UserInfo.getTimeZone();
                //Milliseconds to Day
                timezoneOffset = tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
            }
            return timezoneOffset;
        }
        set;
    }

} // end of vfIECEBC_Controller