/*  
  * Controller for the IECEBC_AccountRatePlan page (eBroadcast Account Rate Plan Overview) 
  * Initial Author: Sonny Leman
  * 
  * Description:
  *  - For a given Billing Account (Zuora__CustomerAccount)/User display the current EBroadcast Rate Plan options
  *  - Personalized upgrade suggestion
  *  - The user interaction will result in selectedProductRatePlan and newPurchasedRatePlanChargeList currently not saved
  *   
  * History: 
  *  - 20160729-sl: initial working version
  *  - 20160920-sl: add payment link and hide submit payment if no PrepaidRate Plan has been selected.
  *
  */


public with sharing class vfIECEBC_AccountRatePlan extends vfIECEBC_Controller
{
	// ======================================================================== 
	// zqu_ProductRatePlanCharge__c.zqu__Type__c picklist options
	private static final String RATE_PLAN_CHARGE_TYPE_ONE_TIME = 'One-Time';
	private static final String RATE_PLAN_CHARGE_TYPE_RECURRING = 'Recurring';
	private static final String RATE_PLAN_CHARGE_TYPE_USAGE = 'Usage';
		
	// ======================================================================== 
	// selectedProductRatePlan & newSubscriptionProductCharge will be the result of user interaction
	public zqu__ProductRatePlan__c selectedProductRatePlan {get;private set;}
	public productRatePlanWrapper selectedProductRatePlanWrapper {get;private set;}
	public Zuora__SubscriptionProductCharge__c newSubscriptionProductCharge {get;private set;}
	
	
	// ======================================================================== 
	// constructor
	public vfIECEBC_AccountRatePlan()
	{
		selectedProductRatePlan = null; // nothing is selected at the beginning 
		selectedProductRatePlanWrapper = null;
		updateNewPurchasedRatePlanChargeList(null); // reset newPurchaseRatePlanChargeList and totalNewPurchaseAmount
		newSubscriptionProductCharge = new Zuora__SubscriptionProductCharge__c( Name ='--none--'
			, Zuora__EffectiveStartDate__c = Date.today()
			, Zuora__EffectiveEndDate__c = Date.today().addYears(1)
			, Zuora__Price__c = 0
			, Product_Rate_Plan_Charge__c = null
		);
	} // vfIECEBC_AccountRatePlan constructor
	
	
	// ========================================================================
	// visualforce display flags below
	// =======================================================================-
	// showUpgradeOption flag is used to turn on/off the rate plan upgrade options 
	public Boolean showUpgradeOption{
		get {
			return (productRatePlanUpgradeList.size() > 0 );
		}
	}
	
	// =======================================================================-
	// allowSelectpgrade flag is used to turn on/off 
	public Boolean allowSelectUpgrade{
		get {
			// disable if Product Rate Plan Subscription Type is not Pay-as-you-go
			return ( productRatePlan.EBC_SubscriptionType__c == EBC_PRODUCT_RATE_PLAN_SUBSCRIPTION_TYPE_PAY_AS_YOU_GO ) ;
		}
	}
	
	// ======================================================================== 
	// showSubscriptionEnd flag is used to turn on/off the end of subscription info 
	public Boolean showSubscriptionEnd{
		get{
			return (productRatePlan.EBC_SubscriptionType__c != EBC_PRODUCT_RATE_PLAN_SUBSCRIPTION_TYPE_PAY_AS_YOU_GO);
		}
	}
	// =======================================================================-
	// showPaymentConfirmation flag is used to turn on/off the payment confirmation
	public Boolean showPaymentConfirmation{
		get {
			return (newSubscriptionProductCharge.Product_Rate_Plan_Charge__c != null) ;
		}
	}
	
	// =======================================================================-
	// showPurchasedSelection flag is used to turn on/off the payment selection messages
	public Boolean showPurchasedSelectionMessage{
		get {
			return (selectedProductRatePlan == null);
		}
	}
	
	
	// ========================================================================
	// updateRatePlanChargeSelection is done by calling selectRatePlanCharge from VfP
	//public Integer selectedRatePlanChargeIndex {get;set;} // used as parameter for calling selectRatePlanCharge
	public Integer selectedRatePlanIndex {get;set;} // used as parameter for calling selectRatePlan
	// selectRatePlan updates the RatePlanCharge selection and flags, called from VfP
	// input parameter: selectedRatePlanIndex
	// initial model: work by toggling the selected flag pointed by the selectedRatePlanhargeIndex
	public void selectRatePlan()
	{
		List<zqu__ProductRatePlanCharge__c> prpcList = new List<zqu__ProductRatePlanCharge__c>();
		updateNewPurchasedRatePlanChargeList(null); // reset newPurchaseRatePlanChargeList and totalNewPurchaseAmount
		selectedProductRatePlan = null; // reset the selection
		selectedProductRatePlanWrapper = null;
		newSubscriptionProductCharge.Zuora__Price__c = 0;
		newSubscriptionProductCharge.Product_Rate_Plan_Charge__c = null;
		
		for (ProductRatePlanWrapper prpw : productRatePlanWrapperUpgradeList)
		{
			if ( prpw.index==selectedRatePlanIndex
				 && prpw.selected )
			{ // select that plan
				selectedProductRatePlan = prpw.productRatePlan;
				selectedProductRatePlanWrapper = prpw;
				newSubscriptionProductCharge.Zuora__Price__c = prpw.amountOneTime + prpw.amountRecurring;
				
				prpcList = prpw.firstTimeProductRatePlanChargeList;
				
				if ( prpcList != null & prpcList.size()>0)
				{
					newSubscriptionProductCharge.Product_Rate_Plan_Charge__c = prpcList[0].Id; // get the first product rate plan charge ???
				}
				updateNewPurchasedRatePlanChargeList(prpcList);
			} else {
				// clear other rate plan options' flags
				prpw.selected = false;
			}
		} // end for prpw
	} // end of selectRatePlan
	
	
	// ========================================================================
	// productRatePlanWrapperUpgradeList is used to display and select the product rate plan 
	public List<ProductRatePlanWrapper> productRatePlanWrapperUpgradeList {
		get{
			if (productRatePlanWrapperUpgradeList == null) 
			{
				List<ProductRatePlanWrapper> prpWrapperList = new List<ProductRatePlanWrapper>();
				for (zqu__ProductRatePlan__c prp : productRatePlanUpgradeList)
				{ // this is assumed to be disjoint with the current one
					ProductRatePlanWrapper prpWrapper = new ProductRatePlanWrapper(prp);
					prpWrapper.selected = false;
					prpWrapper.index = prpWrapperList.size();
					prpWrapperList.add(prpWrapper);
				}
				productRatePlanWrapperUpgradeList = prpWrapperList;
			}
			return productRatePlanWrapperUpgradeList;
		}
		set;
	} // end of productRatePlanWrapperUpgradeList getter/setter
	
	
	// ========================================================================
	// currentProductRatePlanWrapper is used to display current product rate plan 
	public ProductRatePlanWrapper currentProductRatePlanWrapper {
		get{
			if (currentProductRatePlanWrapper == null) 
			{
				// prp is taken from displayedProductRatePlanIdToObjectMap to provide more details on related list
				zqu__ProductRatePlan__c prp = displayedProductRatePlanIdToObjectMap.get(productRatePlan.Id);
				ProductRatePlanWrapper prpWrapper = new ProductRatePlanWrapper(prp);
				
				currentProductRatePlanWrapper = prpWrapper;
			}
			return currentProductRatePlanWrapper;
		}
		set;
	} // end of currentProductRatePlanWrapper getter/setter
	
	
	// ========================================================================
	// productRatePlanUpgradeList returns the sorted list of zqu__ProductRatePlan
	// that are included in productRatePlanIdUpgradeSet and has Product_Rate_Plan_Information
	private List<zqu__ProductRatePlan__c> productRatePlanUpgradeList {
		get{
			if (productRatePlanUpgradeList == null) 
			{
				Map<Id,zqu__ProductRatePlan__c> prodRatePlanIdMap = displayedProductRatePlanIdToObjectMap;
				/*
				// OLD VERSION, using Proudct_Rate_Plan_Information__c.Order as the ordering element
				// this is for ordering the product rate plan based on Product_Rate_Plan_Information__c.order
				List<Product_Rate_Plan_Information__c> orderedProdRatePlanInfoList = [select Id
					, Product_Rate_Plan__c
					from Product_Rate_Plan_Information__c 
					where Product_Rate_Plan__c in : productRatePlanIdUpgradeSet
					order  by Order__c, Id];
				List<zqu__ProductRatePlan__c> sortedProductRatePlanList = new List<zqu__ProductRatePlan__c>();
				Set<Id> includedPrpIdSet = new Set<Id>(); // this to prevent listing Product Rate Plan multiple times
				for (Product_Rate_Plan_Information__c prpi : orderedProdRatePlanInfoList)
				{
					zqu__ProductRatePlan__c prp = prodRatePlanIdMap.get(prpi.Product_Rate_Plan__c);
					if (prp!=null && !includedPrpIdSet.contains(prp.Id)) 
					{
						sortedProductRatePlanList.add(prp);
						includedPrpIdSet.add(prp.Id);
					}
				}
				*/
				
				List<zqu__ProductRatePlan__c> sortedProductRatePlanList = new List<zqu__ProductRatePlan__c>();
				Set<Id> includedPrpIdSet = new Set<Id>(); // this to prevent listing Product Rate Plan multiple times
				for (Id prpId : productRatePlanIdUpgradeList)
				{
					zqu__ProductRatePlan__c prp = prodRatePlanIdMap.get(prpId);
					if (prp!=null && !includedPrpIdSet.contains(prpId)) 
					{
						sortedProductRatePlanList.add(prp);
						includedPrpIdSet.add(prp.Id);
					}
				}
				
				productRatePlanUpgradeList =  sortedProductRatePlanList;
			} // end if null
			return productRatePlanUpgradeList;
		}
		set;
	} // end of productRatePlanUpgradeList getter/setter
	
	
	// ========================================================================
	// productRatePlan records to be displayed, along with related lists
	// this includes the current product rate plan and the upgrade selections
	private Map<Id,zqu__ProductRatePlan__c> displayedProductRatePlanIdToObjectMap
	{
		get{
			if (displayedProductRatePlanIdToObjectMap == null)
			{
				Set<Id> relevantProductRatePlanIdSet = new Set<Id>();
				//System.debug( 'xxxxx productRatePlanIdUpgradeList'+ productRatePlanIdUpgradeList);
				relevantProductRatePlanIdSet.addAll(productRatePlanIdUpgradeList);
				relevantProductRatePlanIdSet.add(productRatePlan.Id); // include the current one as well.
		
				Map<Id,zqu__ProductRatePlan__c> prodRatePlanIdMap = new Map<Id,zqu__ProductRatePlan__c>([select Id, Name
					, zqu__Description__c
					, zqu__EffectiveEndDate__c
					, EBC_Currency_Cost_Per_Email__c
					, EBC_PrePaid_Emails__c
					, (select Id, Name, zqu__ProductRatePlan__c, zqu__ListPrice__c, zqu__Description__c, zqu__Type__c
							, zqu__RecurringPeriod__c
						from zqu__R00N40000001mFVKEA2__r order by Id)
						//from zqu__ProductRatePlanCharge__r order by Id)
					, (select Id, Name, Product_Rate_Plan__c, Long_Description__c
							//, Short_Description__c, Order__c
						from Product_Rate_Plan_Informations__r order by Order__c, Id)
					
					from zqu__ProductRatePlan__c 
					where  Id in : relevantProductRatePlanIdSet
					order by zqu__Product__r.zqu__EffectiveEndDate__c ASC, Id DESC
					limit 100]);
			
				displayedProductRatePlanIdToObjectMap = prodRatePlanIdMap;
			}
				
			return displayedProductRatePlanIdToObjectMap;
		}
		private set;
	} // end of displayedProductRatePlanIdToObjectMap
	
	
	// ========================================================================
	// go to the payment page, the information is passed on the billingAccount record
	// use paymentToken as Url Parameter to ensure the communication integrity between pages.
	// the detail on the product rate plan charge will be recalculated and reselected
	// this ensure the data integrity and simplify the caller
	public PageReference goToPaymentPage()
	{
		PageReference paymentPage = goToPaymentPageBase( Page.IECEBC_Payment, EBC_PAYMENT_TARGET_ACCOUNT_RATE_PLAN, EBC_PAYMENT_CAMPAIGN_NONE
							, null // subscription.Id
							, selectedProductRatePlanWrapper.productRatePlan.Id // productRatePlanId
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
	// needed for checking the selected flag and index, and also the descriptions
	public class ProductRatePlanWrapper{
		public Integer index {get;set;} // array index
		public zqu__ProductRatePlanCharge__c productRatePlanCharge {get;private set;}
		public Boolean selected {get;set;}
		public String name {get; private set;}
		// public String description {get; private set;}
		public List<String> descriptions {get; private set;}
		public String billingPeriod {get;set;} // based on ProductRatePlanCharge recurring period (zqu__RecurringPeriod__c)
		
		public List<zqu__ProductRatePlanCharge__c> firstTimeProductRatePlanChargeList; // the productRatePlanCharge list that is relevant for the first time purchase
		public Decimal amount {get; set;} // amount
		public Decimal amountOneTime  {get;set;}
		public Decimal amountRecurring {get;set;}
				
		public Zuora__SubscriptionProductCharge__c subscriptionProductCharge {get; private set;}
		public zqu__ProductRatePlan__c productRatePlan {get; private set;}
		
		// this constructor is used for the rate plan selection to choose
		// in case there is more than one zqu__ProductRatePlanCharge__c, the amount will be the sum
		public ProductRatePlanWrapper(zqu__ProductRatePlan__c prp)
		{
			productRatePlan = prp;
			
			selected = false;
			name = prp.Name;
			billingPeriod = ''; // this will be overwritten
			// set the price amount based on ProductRatePlanCharge
			amountOneTime = 0;
			amountRecurring = 0;
			//for (zqu__ProductRatePlanCharge__c prpc : prp.zqu__ProductRatePlanCharge__r)
			firstTimeProductRatePlanChargeList = new  List<zqu__ProductRatePlanCharge__c>();
			
			for (zqu__ProductRatePlanCharge__c prpc : prp.zqu__R00N40000001mFVKEA2__r)
			{
				if ( prpc.zqu__Type__c == RATE_PLAN_CHARGE_TYPE_ONE_TIME) {
					amountOneTime += prpc.zqu__ListPrice__c;
					firstTimeProductRatePlanChargeList.add(prpc);
				} else if ( prpc.zqu__Type__c == RATE_PLAN_CHARGE_TYPE_RECURRING ) {
					amountRecurring += prpc.zqu__ListPrice__c; 
					firstTimeProductRatePlanChargeList.add(prpc);
					if (prpc.zqu__RecurringPeriod__c != null) {
						billingPeriod = prpc.zqu__RecurringPeriod__c;
					}
				} 
				//description += '(prpc: ' + prp.zqu__Description__c + ' )';
				productRatePlanCharge = prpc;
			}
			amount = amountOneTime + amountRecurring;
			
			// collect the description from Product_Rate_Plan_Information__c
			descriptions = new List<String>();
			for (Product_Rate_Plan_Information__c prpi : prp.Product_Rate_Plan_Informations__r)
			{
				if (prpi.Long_Description__c != null) { 
					List<String> descList = prpi.Long_Description__c.split( '<br>');
					for (String descr : descList)
					{
						String cleanDesc = descr.replaceAll('<[^>]+>',' ').trim(); // remove html tagging
						if (cleanDesc.length() >0) {
							descriptions.add(cleanDesc);
						}
					} // end for descr
				}
			} // end for prpi
		} // ProductRatePlanWrapper
		
		
	} // end class ProductRatePlanWrapper
	
} // end of class vfIECEBC_AccountRatePlan