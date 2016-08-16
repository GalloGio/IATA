/**
 * This class is used to extends any controller of the eBroadcast project.
 * 
 * It contains various usefull method and properties that can be reused such as
 * as the access to the rate plan, etc.
 *
 * Change log:
 *   20160809-sl: modify productRatePlanIdUpgradeList
 *   20160811-sl: add currentAddon
 *
 **/
public virtual class vfIECEBC_Controller {
	
	// contants for zqu__ProductRatePlan.EBC_SubscriptionType__c
	public static final String EBC_PRODUCT_RATE_PLAN_SUBSCRIPTION_TYPE_PAY_AS_YOU_GO = 'Pay-As-You-Go';
	public static final String EBC_PRODUCT_RATE_PLAN_SUBSCRIPTION_TYPE_PRE_PAID = 'Pre-Paid';
	
	// Zuora__CustomerAccount__c.ClientType__c picklist value
	private static final String BILLING_ACCOUNT_CLIENT_TYPE_MEMBER_AIRLINE = 'Member Airline'; 
	
	// Exception to be thrown by the controllers
	public class Controller_Exception extends Exception{}
	
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
		set;
	}
	
	// The zuora subscription associated with the current billing account
	public Zuora__Subscription__c subscription {
		get {
			if (subscription == null) subscription = vfIECEBC.subscription;
			return subscription;
		}
		set;
	}
	
	// The zuora rate plan associated with the current subscription
	public zqu__ProductRatePlan__c productRatePlan {
		get {
			if (productRatePlan == null) productRatePlan = vfIECEBC.productRatePlan;
			return productRatePlan;
		}
		set;
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
        System.debug( 'xxxx updateNewPurchasedRatePlanChargeList.prpcList:' + prpcList);
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
        System.debug( 'xxxx updateNewPurchasedRatePlanChargeList.totalNewPurchaseAmount:' + totalNewPurchaseAmount);
        System.debug( 'xxxx updateNewPurchasedRatePlanChargeList.newPurchasedRatePlanChargeList:' + newPurchasedRatePlanChargeList);
	} // end of updateNewPurchasedRatePlanChargeList
	
	
	
	// =======================================================================-
	// productRatePlanIdUpgradeSet return set of zqu__ProductRatePlan__.Id available as the upgrade destination from the current ProductRatePlan
	// i.e. to which the current Product Rate Plan can be directly upgraded
	// assumptions:
	//  - the relationship between ProductRatePlan and Product Rate Plan Information is 1:1 for eBroadcast 
	//  - the relationship between ProductRatePlan and Product Rate Plan Charge is 1:1 for eBroadcast
	//  THIS IS THE OLD MODEL of productRatePlanIdUpgradeSet using Swap_Configuration object.
	/*
	private Set<Id> productRatePlanIdUpgradeSet {
		get{
			if (productRatePlanIdUpgradeSet==null) 
			{
				List<Swap_Configuration__c> swapConfigList = [select Id
						//, Source_Product_Rate_Plan_Information__c
						//, Target_Product_Rate_Plan_Information__c
						//, Source_Product_Rate_Plan_Information__r.Product_Rate_Plan__c
						, Target_Product_Rate_Plan_Information__r.Product_Rate_Plan__c
					from Swap_Configuration__c
					where Source_Product_Rate_Plan_Information__r.Product_Rate_Plan__c = : productRatePlan.Id
						and Relationship_Type__c = 'Upgrade'
					order by Target_Product_Rate_Plan_Information__c
					];
				
				Set<Id> targetProductRatePlanIdSet = new Set<Id>();
				for (Swap_Configuration__c swapConf : swapConfigList)
				{
					targetProductRatePlanIdSet.add(swapConf.Target_Product_Rate_Plan_Information__r.Product_Rate_Plan__c);
				}
				productRatePlanIdUpgradeSet = targetProductRatePlanIdSet;
			} // end if
			
			return productRatePlanIdUpgradeSet;
		} // end getter
		private set;
	} // productRatePlanChargeUpgradeList getter/setter.
	*/
	
	
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
				List<Id> nonMemberRatePlanIdList = new List<Id>();
				List<Id> memberRatePlanIdList = new List<Id>();
				
				EBC_Setup__c ebcSetup = vfIECEBC.ebcSetup;
				if (ebcSetup.Member_Prepaid_Product_Rate_Plan_01__c != null)  memberRatePlanIdList.add(ebcSetup.Member_Prepaid_Product_Rate_Plan_01__c);
				if (ebcSetup.Member_Prepaid_Product_Rate_Plan_02__c != null)  memberRatePlanIdList.add(ebcSetup.Member_Prepaid_Product_Rate_Plan_02__c);
				if (ebcSetup.Member_Prepaid_Product_Rate_Plan_03__c != null)  memberRatePlanIdList.add(ebcSetup.Member_Prepaid_Product_Rate_Plan_03__c);
				if (ebcSetup.Member_Prepaid_Product_Rate_Plan_04__c != null)  memberRatePlanIdList.add(ebcSetup.Member_Prepaid_Product_Rate_Plan_04__c);
				
				if (ebcSetup.Non_Member_Prepaid_Product_Rate_Plan_01__c != null)  nonMemberRatePlanIdList.add(ebcSetup.Non_Member_Prepaid_Product_Rate_Plan_01__c);
				if (ebcSetup.Non_Member_Prepaid_Product_Rate_Plan_02__c != null)  nonMemberRatePlanIdList.add(ebcSetup.Non_Member_Prepaid_Product_Rate_Plan_02__c);
				if (ebcSetup.Non_Member_Prepaid_Product_Rate_Plan_03__c != null)  nonMemberRatePlanIdList.add(ebcSetup.Non_Member_Prepaid_Product_Rate_Plan_03__c);
				if (ebcSetup.Non_Member_Prepaid_Product_Rate_Plan_04__c != null)  nonMemberRatePlanIdList.add(ebcSetup.Non_Member_Prepaid_Product_Rate_Plan_04__c);
				
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
	
	
	/*
	// ========================================================================
	// potential additional requirements (these methods were needed before)
	// the following might be added to vfIECEBC_Controller:
	// Zuora__SubscriptionProductCharge__c.Product_Rate_Plan_Charge__c, Zuora__Subscription__c
	// Zuora__SubscriptionProductCharge__c: currently not needed unless we are updating the old record
	// productRatePlanInfo: current Product_Rate_Plan_Information__c
	
	
	// ========================================================================
	public Map<Id,zqu__ProductRatePlanCharge__c> productRatePlanChargeIdToObjectMap
	{
		
		get{
			if ( productRatePlanChargeIdToObjectMap == null) 
			{
				Map<Id,zqu__ProductRatePlanCharge__c> newMap = new Map<Id, zqu__ProductRatePlanCharge__c>();
				for (zqu__ProductRatePlanCharge__c prpc : productRatePlanChargeUpgradeList)
				{
					newMap.put(prpc.Id, prpc);
				}
				productRatePlanChargeIdToObjectMap = newMap;
			}
			return productRatePlanChargeIdToObjectMap;
		}
		private set;
	} // end of productRatePlanChargeIdToObjectMap getter/setter
	
	
	// ========================================================================
	// current Zuora__SubscriptionProductCharge__c 
	// retrieved based on the current subscription
	// assumption:
	//   relationship between Subscription and SubscriptionProductCharge is 1:1 
	public Zuora__SubscriptionProductCharge__c subscriptionProductCharge
	{
		get{
			if ( subscriptionProductCharge == null )
			{ 
				List<Zuora__SubscriptionProductCharge__c> subscriptionProductChargeList = [select Id
					, Zuora__Product__c, Zuora__Product__r.Name
					, Zuora__Price__c
					, Zuora__ProductDescription__c 
					, Zuora__ProductName__c
					, Product_Rate_Plan_Charge__c, Product_Rate_Plan_Charge__r.Name
					, Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__c
					, Zuora__Subscription__c
					, Zuora__EffectiveEndDate__c
					from Zuora__SubscriptionProductCharge__c 
					where Zuora__Subscription__c = : subscription.Id
						and Product_Rate_Plan_Charge__c = : productRatePlan.Id];
				subscriptionProductCharge = (subscriptionProductChargeList.size() == 0) ? null : subscriptionProductChargeList[0];
			}
			return subscriptionProductCharge;
		}
		set;
	}
*/

	
	
	
	// ========================================================================
	// Supporting methods for EBC AddOns
	// this will be used in the IECEBC Dashboard and IECEBC AccountExtras(?)
	// ------------------------------------------------------------------------
	
	// zqu__ProductRatePlan__c.zqu__ZProduct__c.ProductCategory__c accepted values
	public static final String EBC_ADD_ON_CATEGORY_ACCOUNT_LEVEL = 'Account-Level Add-On';
	public static final String EBC_ADD_ON_CATEGORY_SERVICE_LEVEL = 'Service-Level Add-On';
	private static final Set<String> ebcAddOnProductCategoryAllAvailableSet = new Set<String> {EBC_ADD_ON_CATEGORY_ACCOUNT_LEVEL, EBC_ADD_ON_CATEGORY_SERVICE_LEVEL};
	
	// ========================================================================
	// ebcAddOnProductCategoryAllowedSet list the Add On category allowed for 
	// the current user, based on the current eBroadcast Product Rate Plan.
	private Set<String> ebcAddOnProductCategoryAllowedSet {
		get{
			if (ebcAddOnProductCategoryAllowedSet == null)
			{
				Set<String> allowedSet = new Set<String>();
				if ( productRatePlan.EBC_SubscriptionType__c == EBC_PRODUCT_RATE_PLAN_SUBSCRIPTION_TYPE_PRE_PAID ) 
				{
					allowedSet = new Set<String> {EBC_ADD_ON_CATEGORY_ACCOUNT_LEVEL, EBC_ADD_ON_CATEGORY_SERVICE_LEVEL};
				} else {
					allowedSet = new Set<String> {EBC_ADD_ON_CATEGORY_ACCOUNT_LEVEL};
				}
				ebcAddOnProductCategoryAllowedSet = allowedSet;
			}
			return ebcAddOnProductCategoryAllowedSet;
		}
		private set;
	} // end ebcAddOnProductCategoryAllowedSet getter/setter
	
	
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
						from zqu__R00N40000001mFVKEA2__r 
						where zqu__Deleted__c != true
						order by Id)
						//from zqu__ProductRatePlanCharge__r order by Id)
					, (select Id, Name, Product_Rate_Plan__c, Short_Description__c, Long_Description__c, Order__c
						from Product_Rate_Plan_Informations__r order by Order__c, Id)
					
					from zqu__ProductRatePlan__c 
  					where  zqu__ZProduct__r.ProductCategory__c in : ebcAddOnProductCategoryAllowedSet
							//and zqu__ZProduct__r.zqu__Active__c = true
							and zqu__Deleted__c != true
							and zqu__EffectiveStartDate__c <= TODAY
							and zqu__EffectiveEndDate__c >= TODAY
					order by zqu__ZProduct__r.zqu__EffectiveEndDate__c ASC, Id DESC
					limit 100];
				
				allowableEbcAddOnProductRatePlanList = prodRatePlanList;
			}
			return allowableEbcAddOnProductRatePlanList;
		}
		private set;
	} // end of allowableEbcAddOnProductRatePlanList getter/setter
	
	// =========================================================================
	// collection of all ProductRatePlan Id that can be subscribed by this user
	// that also includes those that are already subscribed
	private Set<Id> allowableEbcAddOnProductRatePlanIdSet{
		get{
			if (allowableEbcAddOnProductRatePlanIdSet == null) {
				Set<Id> prpIdSet = new Set<Id>();
				List<zqu__ProductRatePlan__c> prpList = allowableEbcAddOnProductRatePlanList;
				for (zqu__ProductRatePlan__c prp: prpList) 
				{
					prpIdSet.add(prp.Id);
				}
				allowableEbcAddOnProductRatePlanIdSet = prpIdSet;
			}
			return allowableEbcAddOnProductRatePlanIdSet;
		}
		private set;
	} // end of allowableEbcAddOnProductRatePlanIdSet getter/setter
	
	// =========================================================================
	// showLinkToProductAddOn is true if all allowableEbcAddOnProductRatePlanIdSet already subscribed
	public Boolean showLinkToProductAddOn {
		get {
			Boolean hasNoMoreAvailableOptions = ! currentEbcAddOnProductRatePlanIdToSubscriptionMap.keyset().containsAll(allowableEbcAddOnProductRatePlanIdSet);
			return hasNoMoreAvailableOptions;
		}
		private set;
	}
	// =========================================================================
	// currentEbcAddOnProductRatePlanList return currently subscribed ProductRatePlan for EBC Add Ons
	// note that selecting on EBC Add On category is based on ProductCategory__c from zqu__ZProduct not Zuora__Product.
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
						and ( Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.ProductCategory__c in : ebcAddOnProductCategoryAllAvailableSet )
					order by Zuora__Subscription__r.Zuora__Status__c DESC, Zuora__Subscription__r.LastModifiedDate
				];
				currentEbcAddOnSubscriptionProductChargeList = subsProductChargeList;
			}
			return currentEbcAddOnSubscriptionProductChargeList;
		}
		private set;
	} // currentEbcAddOnSubscriptionProductChargeList getter/setter
	
}