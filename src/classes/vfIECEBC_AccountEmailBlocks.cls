/*  
  * Controller for the IECEBC_AccountEmailBlocks page (eBroadcast Account Email Blocks) 
  * Initial Author: Sonny Leman
  * 
  * Description:
  *  - Each user can purchase a block of email credits, which are defined in the ProductRatePlan based on Zuora__Product defined in EBC_Setup
  *  - During one interaction, a user can only purchase of of the options, not combination of them.
  *  - The user interaction will result in selectedProductRatePlan and selectedProductRatePlanWrapper currently not saved
  *  - This class needs to be global for the ProductratePlanWrapper to be sortable.
  *  - Displayed productRatePlanWrapperOptionList is sorted based on currentEmailCredits  
  *  - Note that we do not use zqu__ZProduct__r.ProductCategory__c as the base for selecting the Product Rate Plan here.
  *  
  * History: 
  *  - 20160809-sl: initial workable version.
  *  - 20160815-sl: change wrapper to have disable flag
  */

global virtual with sharing class vfIECEBC_AccountEmailBlocks extends vfIECEBC_Controller 
{
	// ======================================================================== 
	// selectedProductRatePlan will be the result of user interaction
	public zqu__ProductRatePlan__c selectedProductRatePlan {get;private set;}
	public productRatePlanWrapper selectedProductRatePlanWrapper {get;private set;}
	//public Zuora__SubscriptionProductCharge__c newSubscriptionProductCharge {get;private set;}
	
	// ======================================================================== 
	// constructor
	public vfIECEBC_AccountEmailBlocks()
	{
		selectedProductRatePlan = null; // nothing is selected at the beginning 
		productRatePlanWrapperOptionList = null; // initializing
		
	} // vfIECEBC_AccountEmailBlocks constructor
	
	
	// =======================================================================-
	// promoLabel is used for the banner text on the promotional item
	// if desired we can make it customable for all.
	public String promoLabel{
		get{
			return 'promo';
		}
	}
	
	// =======================================================================-
	// zqu__ZProduct__c.Id related for the Email Block Product Rate Plan
	// this is based on what defined in EBC_Setup and whether the user is a member
	private Id emailBlockProductId {
		get{
			Id prodId = (isMember) ? vfIECEBC.ebcSetup.Member_Email_Block_Product__c : vfIECEBC.ebcSetup.Non_Member_Email_Block_Product__c;
			return prodId;
		}
	}
	
    // minimumEmailBlockPurchaseSize is used to define whether a rate plan is disabled or not
    public Integer minimumEmailBlockPurchaseSize{
        get {
            if (minimumEmailBlockPurchaseSize==null) {
                return 0;
            }
            return minimumEmailBlockPurchaseSize;
        }
        set;
    }
    
	// ========================================================================
	// visualforce display flags below
	// ------------------------------------------------------------------------
	// =======================================================================-
	// showPurchasedSelection flag is used to turn on/off the payment selection messages
	public Boolean showPurchasedSelectionMessage{
		get {
			return (selectedProductRatePlan == null);
		}
	}
	
	
	// ========================================================================
	// Product Rate Plan Add On selection web interface
	public Integer selectedRatePlanIndex {get;set;} // used as parameter for calling selectRatePlanAddon
	
	// ========================================================================
	// selectRatePlanAddon updates the Rate Plan selection and flags, called from VfP
	// input parameter: selectedRatePlanIndex
	// output: selectedProductRatePlan, newPurchasedRatePlanChargeList, productRatePlanWrapperAddonOptionList
	public void selectRatePlanEmailBlock()
	{
		List<zqu__ProductRatePlanCharge__c> prpcList = new List<zqu__ProductRatePlanCharge__c>();
		selectedProductRatePlan = null;
		selectedProductRatePlanWrapper = null;
		updateNewPurchasedRatePlanChargeList(null); // reset newPurchaseRatePlanChargeList and totalNewPurchaseAmount
		for (ProductRatePlanWrapper prpw : productRatePlanWrapperOptionList)
		{
			if ( prpw.index==selectedRatePlanIndex
				 && prpw.selected )
			{ // select that plan
				selectedProductRatePlan = prpw.productRatePlan;
				selectedProductRatePlanWrapper = prpw;
				prpcList = selectedProductRatePlan.zqu__R00N40000001mFVKEA2__r;
				updateNewPurchasedRatePlanChargeList(prpcList);
			} else {
				// clear other rate plan options' flags
				prpw.selected = false;
			}
		}
	} // end of selectRatePlanEmailBlock
	
	
	// ========================================================================
	// return the list of all available EBC Product Rate Plan for Email Blocks
	// the ordering for display will be performed only in productRatePlanWrapperOptionList 
	public List<zqu__ProductRatePlan__c> productRatePlanOptionList {
		get{
			if (productRatePlanOptionList == null) 
			{
				Map<Id, zqu__ProductRatePlan__c> prodRatePlanMap = new Map<Id,zqu__ProductRatePlan__c> ([select Id, Name
					, EBC_Currency_Cost_Per_Email__c
					, EBC_Email_Credit_Standard__c
					, EBC_Email_Credit_Current_Offering__c
					//, EBC_PrePaid_Emails__c // irrelevant, we use EBC_Email_Credit
					//, EBC_SubscriptionType__c
					, zqu__Description__c
					, zqu__EffectiveEndDate__c
					, (select Id, Name, zqu__ProductRatePlan__c, zqu__ListPrice__c, zqu__Description__c, zqu__Type__c
						from zqu__R00N40000001mFVKEA2__r order by Id)
						//from zqu__ProductRatePlanCharge__r order by Id)
					, (select Id, Name, Product_Rate_Plan__c, Short_Description__c, Long_Description__c, Order__c
						from Product_Rate_Plan_Informations__r order by Order__c, Id)
					
					from zqu__ProductRatePlan__c 
					where zqu__ZProduct__r.Id = : emailBlockProductId
							and zqu__Deleted__c != true
							and zqu__EffectiveStartDate__c <= TODAY
							and zqu__EffectiveEndDate__c >= TODAY
					order by zqu__ZProduct__r.zqu__EffectiveEndDate__c ASC, Id DESC
					limit 100]);
					
				productRatePlanOptionList = prodRatePlanMap.values();
			}
			return productRatePlanOptionList;
		}
		private set;
	} // end of productRatePlanAddonList getter/setter
	
	
	// ========================================================================
	// productRatePlanWrapperAddonList is used to display and select the product rate plan
	// includes add from productRatePlanAddonList (all) minus subscribed add ons. 
	public List<ProductRatePlanWrapper> productRatePlanWrapperOptionList {
		get{
			if (productRatePlanWrapperOptionList == null) 
			{
				List<ProductRatePlanWrapper> prpWrapperList = new List<ProductRatePlanWrapper>();
				List<zqu__ProductRatePlan__c> availableProductRatePlanOptionList = productRatePlanOptionList;
				for (zqu__ProductRatePlan__c prp : availableProductRatePlanOptionList)
				{
					ProductRatePlanWrapper prpWrapper = new ProductRatePlanWrapper(prp, minimumEmailBlockPurchaseSize);
					prpWrapper.selected = false;
					prpWrapper.index = prpWrapperList.size();
					prpWrapperList.add(prpWrapper);
				} // end for prp
				
				prpWrapperList.sort();
				productRatePlanWrapperOptionList = prpWrapperList;
			}
			return productRatePlanWrapperOptionList;
		}
		set;
	} // end of productRatePlanWrapperEmailBlockOptionList getter/setter
	
	
	// ========================================================================
	// inner wrapper class definition below
	// ------------------------------------------------------------------------
	
	// ========================================================================
	// wrapper class for ProductRatePlan and related objects
	// needed for checking the selected flag and index, and also the descriptions
	// also used to sort the Product Rate Plan
	global class ProductRatePlanWrapper implements Comparable{
		public Integer index {get;set;} // array index
		//public zqu__ProductRatePlanCharge__c productRatePlanCharge {get;private set;}
		public Boolean selected {get;set;}
		public String name {get; private set;}
		public String description {get; private set;}
		
		public Integer standardEmailCredits {get; private set;}
		public Integer currentEmailCredits {get; private set;}
		
		public Decimal amount {get; set;} // price amount
		
         // this tooltipDescription will be used for disabled option
		public String tooltipDescription {
            get{
                String returnValue = (isDisabled) ? 'You can only select email packages above the balance owing.' : '';
                return returnValue;
            }
            set;
        }
        
		// --------------------------------------------------------------------
		// this isPromo and classStringPromoflag are set based on EBC_Email_Credit_Current_Offering__c and EBC_Email_Credit_Standard__c 
		// values from zqu__ProductRatePlan__c   
		public Boolean isPromo {
			get {
				return (standardEmailCredits != currentEmailCredits);
			}
		}
		public String classStringPromo {
			get {
				String hasPromo = (isPromo) ? 'has-promotion': ' ';
				return hasPromo;
			}
		}
		
		// --------------------------------------------------------------------
		// this isDisabled and classStringDisabledflag will be set by setOptionEnable/setOptionDisable 
		// those might be used for campaign check out, but not in ManageAccount functionality 
		public Boolean isDisabled {get;private set;}
		public String classStringDisabled {get;private set;} // string for the html tag class
		public void setOptionDisable()
		{
			classStringDisabled = 'disabled';
			isDisabled = true;
		} 
			
		public void setOptionEnable()
		{
			classStringDisabled = '';
			isDisabled = false;
		} 
		
		//public Zuora__SubscriptionProductCharge__c subscriptionProductCharge {get; private set;}
		public zqu__ProductRatePlan__c productRatePlan {get; private set;}
		
		// --------------------------------------------------------------------
		// this constructor is used for the rate plan selection to choose
		// in case there is more than one zqu__ProductRatePlanCharge__c, the amount will be the sum
		public ProductRatePlanWrapper(zqu__ProductRatePlan__c prp)
        {
            initializeProductRatePlanWrapper(prp, 0);
        }
        
		public ProductRatePlanWrapper(zqu__ProductRatePlan__c prp, Integer minimumEmailBlockSize)
        {
            initializeProductRatePlanWrapper(prp, minimumEmailBlockSize);
        }
        
        private void initializeProductRatePlanWrapper(zqu__ProductRatePlan__c prp, Integer minEmailBlockSize)
		{
			productRatePlan = prp;
			selected = false;
			name = prp.Name;
			
			String standardCreditStr = (prp.EBC_Email_Credit_Standard__c == null) ? '0' : prp.EBC_Email_Credit_Standard__c;
			standardEmailCredits = Integer.valueOf(standardCreditStr);
			standardEmailCredits = (standardEmailCredits == null) ? 0 : standardEmailCredits;
			
			String currentCreditStr = (prp.EBC_Email_Credit_Current_Offering__c == null) ? '0' : prp.EBC_Email_Credit_Current_Offering__c;
			currentEmailCredits = Integer.valueOf(currentCreditStr);
			currentEmailCredits = (currentEmailCredits == null) ? 0 : currentEmailCredits;
			
			// set the price amount based on ProductRatePlanCharge
			amount = 0;
            if (currentEmailCredits >= minEmailBlockSize)
            {
				setOptionEnable();
            } else {
                setOptionDisable();
            }
			//for (zqu__ProductRatePlanCharge__c prpc : prp.zqu__ProductRatePlanCharge__r)
			for (zqu__ProductRatePlanCharge__c prpc : prp.zqu__R00N40000001mFVKEA2__r)
			{
				amount += prpc.zqu__ListPrice__c;
			}
			
			// collect the description from Product_Rate_Plan_Information__c
			//description = '';
			for (Product_Rate_Plan_Information__c prpi : prp.Product_Rate_Plan_Informations__r)
			{
				if (prpi.Long_Description__c != null) { 
					description += prpi.Long_Description__c.replaceAll('<[^>]+>',' '); // remove html tagging
				}
			} // end for prpi
		} // ProductRatePlanWrapper
		
		
		// --------------------------------------------------------------------
		// overriding virtual method, used for sorting.
		global integer compareTo(Object compareToObject)
		{
			ProductRatePlanWrapper compareToPrpw = (ProductRatePlanWrapper) compareToObject;
			
			
			// The return value of 0 indicates that both elements are equal.
			Integer returnValue = 0;
			
			if (currentEmailCredits > compareToPrpw.currentEmailCredits) {
				// Set return value to a positive value.
				returnValue = 1;
			} else if (currentEmailCredits < compareToPrpw.currentEmailCredits) {
				// Set return value to a negative value.
				returnValue = -1;
			}
		
			return returnValue;	   
		} // compareTo 
	} // end class ProductRatePlanWrapper
	
} // end of vfIECEBC_AccountEmailBlocks class