/*  
  * Controller for the IECEBC_AccountExtras page (eBroadcast Account Rate Plan Overview) 
  * Initial Author: Sonny Leman
  * 
  * Description:
  *  - For a given Billing Account (Zuora__CustomerAccount)/User display the selectable add ons
  *  - Personalized add on selection 
  *   
  * History: 
  *  - 20160729-sl: initial version
  */


public with sharing class vfIECEBC_AccountExtras extends vfIECEBC_Controller
{
	// ======================================================================== 
	// zqu_ProductRatePlanCharge__c.zqu__Type__c picklist options
	private static final String RATE_PLAN_CHARGE_TYPE_ONE_TIME = 'One-Time';
	private static final String RATE_PLAN_CHARGE_TYPE_RECURRING = 'Recurring';
	private static final String RATE_PLAN_CHARGE_TYPE_USAGE = 'Usage';
	
	// zqu__ProductRatePlan__c.zqu__ZProduct__c.ProductCategory__c accepted values
	private static final String EBC_ADD_ON_CATEGORY_ACCOUNT_LEVEL = 'Account-Level Add-On';
	private static final String EBC_ADD_ON_CATEGORY_SERVICE_LEVEL = 'Service-Level Add-On';
	private static final Set<String> ebcAddOnProductCategoryAllAvailableSet = new Set<String> {EBC_ADD_ON_CATEGORY_ACCOUNT_LEVEL, EBC_ADD_ON_CATEGORY_SERVICE_LEVEL};
	
	// ======================================================================== 
	// selectedProductRatePlanCharge & newSubscriptionProductCharge will be the result of user interaction
	//public zqu__ProductRatePlanCharge__c selectedProductRatePlanCharge {get;private set;}
	public zqu__ProductRatePlan__c selectedProductRatePlan {get;private set;}
	public Zuora__SubscriptionProductCharge__c newSubscriptionProductCharge {get;private set;}
	
	// use this to get subscription related info 
	// if there is more than one subscription, only show one of them, the last one
	// this is set as a side effect of ebcCurrentProductRatePlanList
	private map<Id, Zuora__Subscription__c> currentProductRatePlanIdToSubscription = new map<Id, Zuora__Subscription__c>();
	
	// ======================================================================== 
	// constructor
	public vfIECEBC_AccountExtras()
	{
		selectedProductRatePlan = null; // nothing is selected at the beginning 
		newSubscriptionProductCharge = new Zuora__SubscriptionProductCharge__c( Name ='--none--'
			, Zuora__EffectiveStartDate__c = Date.today()
			, Zuora__EffectiveEndDate__c = Date.today().addYears(1)
			, Zuora__Price__c = 0
			, Product_Rate_Plan_Charge__c = null
		);
		currentProductRatePlanIdToSubscription = new map<Id, Zuora__Subscription__c>(); // avoid null
		//newPurchasedRatePlanChargeList = new List<zqu__ProductRatePlanCharge__c>();
		updateNewPurchasedRatePlanChargeList(null); // reset newPurchaseRatePlanChargeList and totalNewPurchaseAmount
	} // vfIECEBC_AccountRatePlan constructor
	
	
	// ========================================================================
	// visualforce display flags below
	// =======================================================================-
	// showAddOnSelection flag is used to turn on/off the add on rate plan options 
	public Boolean showAddOnSelection{
		get {
			return (productRatePlanWrapperAddonOptionList.size() > 0);
		}
	}
	
	// =======================================================================-
	// showPaymentConfirmation flag is used to turn on/off the payment confirmation
	public Boolean showPaymentConfirmation{
		get {
			return (productRatePlanWrapperAddonOptionList.size() > 0);
		}
	}
	
	// =======================================================================-
	// showPurchasedSelection flag is used to turn on/off the payment confirmation message
	public Boolean showPurchasedSelectionMessage{
		get {
			return (selectedProductRatePlan == null);
		}
	}
	
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
	// Product Rate Plan Add On selection web interface
	public Integer selectedRatePlanIndex {get;set;} // used as parameter for calling selectRatePlanAddon
	
	// ========================================================================
	// selectRatePlanAddon updates the Rate Plan selection and flags, called from VfP
	// input parameter: selectedRatePlanIndex
	// output: selectedProductRatePlan, newPurchasedRatePlanChargeList, productRatePlanWrapperAddonOptionList
	public void selectRatePlanAddon()
	{
		List<zqu__ProductRatePlanCharge__c> prpcList = new List<zqu__ProductRatePlanCharge__c>();
		selectedProductRatePlan = null;
		updateNewPurchasedRatePlanChargeList(null); // reset newPurchaseRatePlanChargeList and totalNewPurchaseAmount
		for (ProductRatePlanWrapper prpw : productRatePlanWrapperAddonOptionList)
		{
			if ( prpw.index==selectedRatePlanIndex
				 && prpw.selected )
			{ // select that plan
				selectedProductRatePlan = prpw.productRatePlan;
				prpcList = selectedProductRatePlan.zqu__R00N40000001mFVKEA2__r;
				updateNewPurchasedRatePlanChargeList(prpcList);
			} else {
				// clear other rate plan options' flags
				prpw.selected = false;
			}
		}
	} // end of selectRatePlanAddon
	
	
	// ========================================================================
	// current Zuora__SubscriptionProductCharge__c 
	// input: current user (billing account)
	// assumption:
	//   - relationship between Subscription and SubscriptionProductCharge is 1:n 
	//   - selecting on EBC Add On category is based on ProductCategory__c from zqu__ZProduct not Zuora__Product.
	public List<Zuora__SubscriptionProductCharge__c> ebcSubscriptionProductChargeList
	{
		get{
			if ( ebcSubscriptionProductChargeList == null )
			{ 
				List<Zuora__SubscriptionProductCharge__c> subscriptionProductChargeList = [select Id
					, Zuora__Product__c, Zuora__Product__r.Name
					, Zuora__Price__c
					, Zuora__ProductDescription__c 
					, Zuora__ProductName__c
					, Zuora__Description__c
					, Zuora__EffectiveEndDate__c
					, Zuora__ExtendedAmount__c
					, Zuora__Subscription__c
					, Zuora__Subscription__r.Zuora__TermEndDate__c
					
					, Product_Rate_Plan_Charge__c, Product_Rate_Plan_Charge__r.Name
					, Product_Rate_Plan_Charge__r.Id
					//, Product_Rate_Plan_Charge__r.zqu__Type__c
					, Product_Rate_Plan_Charge__r.zqu__ListPrice__c
					, Product_Rate_Plan_Charge__r.zqu__Description__c
					, Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__c
					, Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.Id
					, Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.Name
					, Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.zqu__Description__c
					, Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.zqu__EffectiveEndDate__c
					
					from Zuora__SubscriptionProductCharge__c 
					where Zuora__Subscription__r.Zuora__CustomerAccount__c = : billingAccount.Id
						and Zuora__Subscription__r.Zuora__TermEndDate__c >= TODAY
						and ( Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.ProductCategory__c in : ebcAddOnProductCategoryAllAvailableSet )
					];
				ebcSubscriptionProductChargeList = subscriptionProductChargeList;
			}
			return ebcSubscriptionProductChargeList;
		}
		set;
	} // end of ebcSubscriptionProductChargeList getter/setter
	
	
	// =========================================================================
	// ebcCurrentProductRatePlanList return currently subscribed ProductRatePlan
	// in addition, it provides initialized currentProductRatePlanIdToSubscription
	// note that selecting on EBC Add On category is based on ProductCategory__c from zqu__ZProduct not Zuora__Product.
	public List<zqu__ProductRatePlan__c> ebcCurrentProductRatePlanList
	{
		get{
			if ( ebcCurrentProductRatePlanList == null )
			{ 
				List<Zuora__SubscriptionProductCharge__c> subscriptionProductChargeList = [select Id
					, Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__c
					, Zuora__Subscription__r.Zuora__TermEndDate__c
					from Zuora__SubscriptionProductCharge__c 
					where Zuora__Subscription__r.Zuora__CustomerAccount__c = : billingAccount.Id
						and Zuora__Subscription__r.Zuora__TermEndDate__c >= TODAY
						and ( Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.ProductCategory__c in : ebcAddOnProductCategoryAllAvailableSet )
					order by Zuora__Subscription__r.LastModifiedDate
				];
				
				Set<Id> purchasedProductRatePlanSet = new Set<Id>();
				currentProductRatePlanIdToSubscription = new map<Id, Zuora__Subscription__c>();
				for (Zuora__SubscriptionProductCharge__c  spc : subscriptionProductChargeList)
				{
					purchasedProductRatePlanSet.add(spc.Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__c);
					currentProductRatePlanIdToSubscription.put(spc.Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__c, spc.Zuora__Subscription__r);
				}
				
				// query ProductRatePlan independently in order to get the Product_Rate_Plan_Information__c.Long_Description__c
				List<zqu__ProductRatePlan__c> prodRatePlanList = [select Id, Name
					, zqu__Description__c
					, zqu__EffectiveEndDate__c
					, (select Id, Name, zqu__ProductRatePlan__c, zqu__ListPrice__c, zqu__Description__c, zqu__Type__c
						from zqu__R00N40000001mFVKEA2__r order by Id)
					, (select Id, Name, Product_Rate_Plan__c, Short_Description__c, Long_Description__c, Order__c
						from Product_Rate_Plan_Informations__r order by Order__c, Id)
					from zqu__ProductRatePlan__c 
						where  Id in : purchasedProductRatePlanSet
						order by Name, Id
						limit 100];
				
				ebcCurrentProductRatePlanList = prodRatePlanList;
			}
			return ebcCurrentProductRatePlanList;
		}
		set;
	} // end of ebcCurrentProductRatePlanList getter/setter
	
	
	// ========================================================================
	// return the list of all available eBroadcastProduct Rate Plan Add On
	private List<zqu__ProductRatePlan__c> productRatePlanAddonList {
		get{
			if (productRatePlanAddonList == null) 
			{
				List<zqu__ProductRatePlan__c> prodRatePlanList = [select Id, Name
					, zqu__Description__c
					, zqu__EffectiveEndDate__c
					, (select Id, Name, zqu__ProductRatePlan__c, zqu__ListPrice__c, zqu__Description__c, zqu__Type__c
						from zqu__R00N40000001mFVKEA2__r order by Id)
						//from zqu__ProductRatePlanCharge__r order by Id)
					, (select Id, Name, Product_Rate_Plan__c, Short_Description__c, Long_Description__c, Order__c
						from Product_Rate_Plan_Informations__r order by Order__c, Id)
					
					from zqu__ProductRatePlan__c 
  					where  zqu__ZProduct__r.ProductCategory__c in : ebcAddOnProductCategoryAllowedSet
							//and zqu__ZProduct__r.zqu__Active__c = true
							and zqu__EffectiveStartDate__c <= TODAY
							and zqu__EffectiveEndDate__c >= TODAY
					order by zqu__ZProduct__r.zqu__EffectiveEndDate__c ASC, Id DESC
					limit 100];
				
				productRatePlanAddonList = prodRatePlanList;
				
			}
			return productRatePlanAddonList;
		}
		set;
	} // end of productRatePlanAddonList getter/setter
	
	// ========================================================================
	// productRatePlanCurrentIdSet is collection of ProductRatePlan Id related to existing SubscriptionProductCharge
	private Set<Id> productRatePlanCurrentIdSet {
		get{
			if (productRatePlanCurrentIdSet==null) 
			{
				Set<Id> prpIdSet = new Set<id>();
				for (Zuora__SubscriptionProductCharge__c spc : ebcSubscriptionProductChargeList)
				{
					prpIdSet.add(spc.Product_rate_Plan_Charge__r.zqu__ProductRatePlan__c);
				}
				productRatePlanCurrentIdSet = prpIdSet;
			}
			return productRatePlanCurrentIdSet;
		}
		set;
		
	} // end of productRatePlanCurrentIdSet getter/setter
	
	
	
	
	// ========================================================================
	// productRatePlanWrapperAddonList is used to display and select the product rate plan
	// includes add from productRatePlanAddonList (all) minus subscribed add ons. 
	public List<ProductRatePlanWrapper> productRatePlanWrapperAddonOptionList {
		get{
			if (productRatePlanWrapperAddonOptionList == null) 
			{
				List<ProductRatePlanWrapper> prpWrapperList = new List<ProductRatePlanWrapper>();
				Set<Id> availableProductRatePlanIdSet = productRatePlanCurrentIdSet;
				for (zqu__ProductRatePlan__c prp : productRatePlanAddonList)
				{
					if ( !productRatePlanCurrentIdSet.contains(prp.Id) )
					{ // only shows those that are not on the currently subscribed list
						ProductRatePlanWrapper prpWrapper = new ProductRatePlanWrapper(prp);
						prpWrapper.selected = false;
						prpWrapper.index = prpWrapperList.size();
						prpWrapperList.add(prpWrapper);
					}
				} // end for prp
				productRatePlanWrapperAddonOptionList = prpWrapperList;
			}
			return productRatePlanWrapperAddonOptionList;
		}
		set;
	} // end of productRatePlanWrapperAddonOptionList getter/setter
	
	
	// ========================================================================
	// productRatePlanWrapperAddonPurchasedList is used to display currently subscribed product rate plan
	// ebcCurrentProductRatePlanList
	public List<ProductRatePlanWrapper> productRatePlanWrapperAddonCurrentList{
		get{
			if (productRatePlanWrapperAddonCurrentList == null) 
			{
				List<ProductRatePlanWrapper> prpWrapperList = new List<ProductRatePlanWrapper>();
				for (zqu__ProductRatePlan__c prp : ebcCurrentProductRatePlanList)
				{
					ProductRatePlanWrapper prpWrapper = new ProductRatePlanWrapper(prp);
					prpWrapper.selected = true;
					prpWrapper.index = prpWrapperList.size();
					
					prpWrapper.subscriptionEndDate = currentProductRatePlanIdToSubscription.get(prp.Id).Zuora__TermEndDate__c;
					prpWrapperList.add(prpWrapper);
 				}
				productRatePlanWrapperAddonCurrentList = prpWrapperList;
			}
			return productRatePlanWrapperAddonCurrentList;
		}
		set;
	} // end of productRatePlanWrapperAddonCurrentList getter/setter
	
	
	// ========================================================================
	// productRatePlanWrapperAddonNewPurchasedList is used to display and select the product rate plan charge
	public List<SelectedProductRatePlanWrapper> productRatePlanWrapperAddonNewPurchaseList {
		get{
			List<SelectedProductRatePlanWrapper> prpWrapperList = new List<SelectedProductRatePlanWrapper>();
			
			for (zqu__ProductRatePlanCharge__c prpc : newPurchasedRatePlanChargeList)
			{
				SelectedProductRatePlanWrapper prpWrapper = new SelectedProductRatePlanWrapper(prpc);
				prpWrapper.index = prpWrapperList.size();
				prpWrapperList.add(prpWrapper);
			}
			productRatePlanWrapperAddonNewPurchaseList = prpWrapperList;
			return productRatePlanWrapperAddonNewPurchaseList;
		}
		set;
	} // end of productRatePlanWrapperAddonNewPurchaseList getter/setter
	
	
	// ========================================================================
	// inner wrapper class definition below
	// ------------------------------------------------------------------------
	
	// ========================================================================
	// wrapper class for ProductRatePlan and related objects
	// needed checking the selected flag and index.
	public class ProductRatePlanWrapper{
		public Integer index {get;set;} // array index
		public zqu__ProductRatePlanCharge__c productRatePlanCharge {get;private set;}
		public Boolean selected {get;set;}
		public String name {get; private set;}
		public String description {get; private set;}
		public Decimal amount {get; set;} // amount
		public Decimal amountOneTime  {get;set;}
		public Decimal amountRecurring {get;set;}
		
		public Zuora__SubscriptionProductCharge__c subscriptionProductCharge {get; private set;}
		public zqu__ProductRatePlan__c productRatePlan {get; private set;}
		public Date subscriptionEndDate {get;set;}
		
		// this constructor is used for the rate plan selection to choose
		// in case there is more than one zqu__ProductRatePlanCharge__c, the amount will be the sum
		public ProductRatePlanWrapper(zqu__ProductRatePlan__c prp)
		{
			productRatePlan = prp;
			
			selected = false;
			name = prp.Name;
			//description = prp.zqu__Description__c;
			
			// set the price amount based on ProductRatePlanCharge
			amountOneTime = 0;
			amountRecurring = 0;
			//for (zqu__ProductRatePlanCharge__c prpc : prp.zqu__ProductRatePlanCharge__r)
			for (zqu__ProductRatePlanCharge__c prpc : prp.zqu__R00N40000001mFVKEA2__r)
			{
				if ( prpc.zqu__Type__c == RATE_PLAN_CHARGE_TYPE_ONE_TIME) {
					amountOneTime += prpc.zqu__ListPrice__c;
				} else if ( prpc.zqu__Type__c == RATE_PLAN_CHARGE_TYPE_RECURRING ) {
					amountRecurring += prpc.zqu__ListPrice__c; 
				} 
				//description += '(prpc: ' + prp.zqu__Description__c + ' )';
				productRatePlanCharge = prpc;
			}
			
			// collect the description from Product_Rate_Plan_Information__c
			description = '';
			for (Product_Rate_Plan_Information__c prpi : prp.Product_Rate_Plan_Informations__r)
			{
				if (prpi.Long_Description__c != null) { 
					description = prpi.Long_Description__c.replaceAll('<[^>]+>',' '); // remove html tagging
				}
			}
		} // ProductRatePlanWrapper
		
		
	} // end class ProductRatePlanWrapper
	
	
	// ========================================================================
	// wrapper class for Purchased ProductRatePlan/ProductRatePlanCharge 
	// this wrapper class was created for allowing to add more information
	// the information here will be displayed on the payment confirmation section
	// current model will display each product rate plan charge
	public class SelectedProductRatePlanWrapper{
		public Integer index {get;set;} // array index
		public zqu__ProductRatePlanCharge__c productRatePlanCharge {get;private set;}
		public String name {get; private set;}
		public String description {get; private set;}
		public Decimal amount {get; set;} // amount
		//public Decimal amountOneTime  {get;set;}
		//public Decimal amountRecurring {get;set;}
		
		//public Zuora__SubscriptionProductCharge__c subscriptionProductCharge {get; private set;}
		public zqu__ProductRatePlan__c productRatePlan {get; private set;}
		//public Date subscriptionEndDate {get;set;}
		
		// this constructor is used for the rate plan selection to choose
		// in case there is more than one zqu__ProductRatePlanCharge__c, the amount will be the sum
		public SelectedProductRatePlanWrapper(zqu__ProductRatePlanCharge__c prpc)
		{
			productRatePlanCharge = prpc;
			name = 'none';
			if (prpc != null)
			{
				name = prpc.Name;
				description = prpc.zqu__Description__c;
				amount = prpc.zqu__ListPrice__c;
			}
		} // end SelectedProductRatePlanWrapper constructor
	} // end class SelectedProductRatePlanWrapper
	
	
} // end of vfIECEBC_AccountExtras