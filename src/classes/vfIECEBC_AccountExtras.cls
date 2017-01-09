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
  *  - 20160811-sl: move some methods and properties to vfIECEBC_Controller
  *  - 20160926-sl: add payment link and hide submit payment if no Add On has been selected, split Zuora__CustomerAccount__c.eBroadcast_Payment_Target for addon
  */


public with sharing class vfIECEBC_AccountExtras extends vfIECEBC_Controller
{
	// ======================================================================== 
	// zqu_ProductRatePlanCharge__c.zqu__Type__c picklist options
	private static final String RATE_PLAN_CHARGE_TYPE_ONE_TIME = 'One-Time';
	private static final String RATE_PLAN_CHARGE_TYPE_RECURRING = 'Recurring';
	private static final String RATE_PLAN_CHARGE_TYPE_USAGE = 'Usage';
	
	// ======================================================================== 
	// selectedProductRatePlanCharge & newSubscriptionProductCharge will be the result of user interaction
	//public zqu__ProductRatePlanCharge__c selectedProductRatePlanCharge {get;private set;}
	public zqu__ProductRatePlan__c selectedProductRatePlan {get;private set;}
	public Zuora__SubscriptionProductCharge__c newSubscriptionProductCharge {get;private set;}
	
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
			//return (selectedProductRatePlan == null);
			return (newPurchasedRatePlanChargeList.size() == 0);
		}
	}

	//
	//
    public boolean getisAllAddonSold() {
        if (productRatePlanWrapperAddonCurrentList.size()>0 &&
            productRatePlanWrapperAddonOptionList.size()==0) return true;
        return false;
    }
    public boolean getisOneAddonLeftToBeSold(){
        if (productRatePlanWrapperAddonOptionList.size()>0) return true;
        return false;
    }
    public boolean getisNoneAddonSold(){
        if (productRatePlanWrapperAddonCurrentList.size()==0 &&
            productRatePlanWrapperAddonOptionList.size()>0) return true;
        return false;
    }
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
	// productRatePlanWrapperAddonList is used to display and select the product rate plan
	// includes add from productRatePlanAddonList (all) minus subscribed add ons. 
	public List<ProductRatePlanWrapper> productRatePlanWrapperAddonOptionList {
		get{
			if (productRatePlanWrapperAddonOptionList == null) 
			{
				List<ProductRatePlanWrapper> prpWrapperList = new List<ProductRatePlanWrapper>();
				Set<Id> currentProductRatePlanIdSet = currentEbcAddOnProductRatePlanIdToSubscriptionMap.keyset();
				for (zqu__ProductRatePlan__c prp : allowableEbcAddOnProductRatePlanList)
				{
					if ( !currentProductRatePlanIdSet.contains(prp.Id) )
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
		private set;
	} // end of productRatePlanWrapperAddonOptionList getter/setter
	
	
	// ========================================================================
	// productRatePlanWrapperAddonPurchasedList is used to display currently subscribed product rate plan
	// ebcCurrentProductRatePlanList
	public List<ProductRatePlanWrapper> productRatePlanWrapperAddonCurrentList{
		get{
			if (productRatePlanWrapperAddonCurrentList == null) 
			{
				List<ProductRatePlanWrapper> prpWrapperList = new List<ProductRatePlanWrapper>();
				for (zqu__ProductRatePlan__c prp : currentEbcAddOnProductRatePlanList)
				{
					ProductRatePlanWrapper prpWrapper = new ProductRatePlanWrapper(prp);
					prpWrapper.selected = true;
					prpWrapper.index = prpWrapperList.size();
					
					prpWrapper.subscriptionEndDate = currentEbcAddOnProductRatePlanIdToSubscriptionMap.get(prp.Id).Zuora__TermEndDate__c;
					prpWrapperList.add(prpWrapper);
 				}
				productRatePlanWrapperAddonCurrentList = prpWrapperList;
			}
			return productRatePlanWrapperAddonCurrentList;
		}
		private set;
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
		private set;
	} // end of productRatePlanWrapperAddonNewPurchaseList getter/setter
	
	
	// ========================================================================
	// go to the payment page, the information is passed on the billingAccount record
	// use paymentToken as Url Parameter to ensure the communication integrity between pages.
	// the detail on the product rate plan charge will be recalculated and reselected
	// this ensure the data integrity and simplify the caller
	public PageReference goToPaymentPage()
	{
		String payAddOnType = ( selectedProductRatePlan.Id == IECEBC_Utility.ebcSetup.Enhanced_Reporting_Product_Rate_Plan__c)
							? EBC_PAYMENT_TARGET_ACCOUNT_ADD_ON_REPORTING
							: EBC_PAYMENT_TARGET_ACCOUNT_ADD_ON_STORAGE;
		Id subscriptionId = ( selectedProductRatePlan.Id == IECEBC_Utility.ebcSetup.Storage_Product_Rate_Plan__c)
							? subscription.Id
							: null;
		PageReference paymentPage = goToPaymentPageBase( Page.IECEBC_Payment, payAddOnType
							, EBC_PAYMENT_CAMPAIGN_NONE
							, subscriptionId
							, selectedProductRatePlan.Id // productRatePlanId
							, null // campaignId
							, 0 // emailCreditAmount
							);
		
		return paymentPage;
	} // end of goToPaymentPage
	
	
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
        public String billingPeriod {get;set;} // based on ProductRatePlanCharge recurring period (zqu__RecurringPeriod__c)
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
			billingPeriod = ''; // this will be overwritten
			//description = prp.zqu__Description__c;
			
			// set the price amount based on ProductRatePlanCharge
			amountOneTime = 0;
			amountRecurring = 0;
			//for (zqu__ProductRatePlanCharge__c prpc : prp.zqu__ProductRatePlanCharge__r)
			for (zqu__ProductRatePlanCharge__c prpc : prp.zqu__R00N40000001mFVKEA2__r)
			{
				if (prpc.zqu__Type__c!=null) billingPeriod = prpc.zqu__Type__c;
				if ( prpc.zqu__Type__c == RATE_PLAN_CHARGE_TYPE_ONE_TIME) {
					amountOneTime += prpc.zqu__ListPrice__c;    
				} else if ( prpc.zqu__Type__c == RATE_PLAN_CHARGE_TYPE_RECURRING ) {
					amountRecurring += prpc.zqu__ListPrice__c; 
                    //if (prpc.zqu__RecurringPeriod__c != null) billingPeriod = prpc.zqu__RecurringPeriod__c;
				} 
				//description += '(prpc: ' + prp.zqu__Description__c + ' )';
				productRatePlanCharge = prpc;
			}
			
			// collect the description from Product_Rate_Plan_Information__c
			description = '';
			for (Product_Rate_Plan_Information__c prpi : prp.Product_Rate_Plan_Informations__r)
			{
				if (prpi.Long_Description__c != null) description = prpi.Long_Description__c.replaceAll('<[^>]+>',' '); // remove html tagging
				if (prpi.Short_Description__c !=null) name=prpi.Short_Description__c;
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