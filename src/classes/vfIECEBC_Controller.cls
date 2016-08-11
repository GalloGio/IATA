/**
 * This class is used to extends any controller of the eBroadcast project.
 * 
 * It contains various usefull method and properties that can be reused such as
 * as the access to the rate plan, etc.
 *
 * Change log:
 *   20160809-sl: modify productRatePlanIdUpgradeList
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

	
	
/*
	// ========================================================================
	// EBC ProductRatePlanInfo of this BillingAccount.
	// this is used to get the upgrade options
	// assumptions: 
	//  - Relationship between Product_Rate_Plan_Information__c and ProductRatePlan is 1 to 1
	public Product_Rate_Plan_Information__c productRatePlanInfo {
		get{
			if (productRatePlanInfo == null)
			{
				List<Product_Rate_Plan_Information__c> productRatePlanInfoList = [select Id
						 
					from Product_Rate_Plan_Information__c 
					where Related_Product_Information__r.Related_Product_Category__r.Name = : IECConstants.ProductCategory_SF_EBROADCAST
					order by Id];
					productRatePlanInfo = productRatePlanInfoList[0];
			}
			return productRatePlanInfo;
		}
		set;
		
	}
*/	
	
	
	
}