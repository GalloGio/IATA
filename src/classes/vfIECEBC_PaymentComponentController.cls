/*  
  * Controller for the IECEBC_Payment.component
  * Initial Author: Sonny Leman
  * 
  * Description:
  *  - allow user to select and process the payment for eBroadcast
  *  - input: paymentToken (as the component attribute)
  *  - there are 3 major parts in the component: BillingDetail (Contact/Address), Payment Method, Payment Confirmation
  *  - 
  *   
  * History: 
  *  - 20160918-sl: initial dev version
  *  
  */


public class vfIECEBC_PaymentComponentController extends vfIECEBC_Controller {
	// ======================================================================== 
	// zqu_ProductRatePlanCharge__c.zqu__Type__c picklist options
	private static final String RATE_PLAN_CHARGE_TYPE_ONE_TIME = 'One-Time';
	private static final String RATE_PLAN_CHARGE_TYPE_RECURRING = 'Recurring';
	private static final String RATE_PLAN_CHARGE_TYPE_USAGE = 'Usage';
	private static String EBC_PAYMENT_MESSAGE_TOKEN_INVALID_ERROR = 'This eBroadcast Payment is accessed with invalid token. Please redo from the previous page.';
	

	// ======================================================================== 
	// incoming component parameters are set directly by the caller
	public String paymentToken {get;set;}
	
	// input passed from the caller using billingAccount fields
	private String paymentTarget {get;set;}
	private String campaignPaymentOption {get;set;}
	private String selectedRatePlanId {get;set;}
	private Integer emailCreditPurchased {get;set;}
	private Id ebcCampaignId {get;set;} // EBCEBC_Campaign__c.Id, used only for IECEBC_CampaignPayment.page
	
	// ======================================================================== 
	// common 
	private VfIECShoppingCart shoppingCartController;
	public Boolean editMode {get; private set;}
	public EBC_Preference__c ebcPreference {get;set;}
	
	// used only for IECEBC_CampaignPayment
	public EBC_Campaign__c ebcCampaign {get;set;}
	
	
	// ========================================================================
	// constructor 
	public vfIECEBC_PaymentComponentController()
	{
		initialization();
	} // vfIECEBC_PaymentComponentController constructor
	
	// ========================================================================
	// post constructor init, check if the token is good
	// need to be defined in the first line of the component
	// this need to be called to ensure init() is run after attribute is read
	public Boolean init {
		get{
			init();
			return false;
		}
	}
	public void init()
	{
		// verify the token
		if ( billingAccount.eBroadcast_Payment_Token__c != paymentToken) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, EBC_PAYMENT_MESSAGE_TOKEN_INVALID_ERROR));
		}
	} // end of init
	
	// ========================================================================
	private void initialization()
	{
		//shoppingCartController = VfIECShoppingCart();
		editMode = false;
		ebcPreference = vfIECEBC.pref;
		
		rereadBillingAccount(); // refetch BillingAccount, to get updated eBroadcast_Payment related fields
		getAddressDetail(); // get oBillingLocation, oBillingAddress, oOriginalBillingAddress 
		
		paymentTarget = billingAccount.eBroadcast_Payment_Target__c;
		campaignPaymentOption = billingAccount.eBroadcast_Payment_Campaign_Option__c;
		selectedRatePlanId = billingAccount.eBroadcast_Payment_Product_Rate_Plan_Id__c;
		emailCreditPurchased = Integer.valueOf(billingAccount.eBroadcast_Payment_Email_Credit_Amount__c);
		ebcCampaignId = billingAccount.eBroadcast_Payment_Campaign__c;
	} // end of initialization
	
	// isPaymentTokenValid flag is used to show/hide the content of payment pages
	public Boolean isPaymentTokenValid{
		get {
			return (billingAccount.eBroadcast_Payment_Token__c == paymentToken);
			//return true;
		}
		//set;
	}
	
	// ========================================================================
	// Billing Detail section
	// -----------------------------------------------------------------------
	
	// oBillingLocation, oBillingAddress, oOriginalBillingAddress are read/updated using getAddressDetail and updateAddressDetail 
	private Location__c oBillingLocation { get; set; } 
	public IECAddress__c oBillingAddress {get;set;} // the billingAddress that will be displayed and updated
	private IECAddress__c oOriginalBillingAddress{get;set;}
	private IECVATUtil.VATConfiguration vatConfig { get; set; } // ? this might be used to calculate tax
	
	
	// loggedCustomer is IECCustomer, as also used in IECPageController
	public IECCustomer loggedCustomer {
		get{
			return  IECCustomer.getCurrentIECCustomer();
		}
	}
	
	public Contact oPaymentBillingContact{
		get{
			if (oPaymentBillingContact == null)
			{
				oPaymentBillingContact = billingAccount.Contact__r;
			}
			return oPaymentBillingContact;
		}
		set;
	}
	
	
	// picklist options for address: ISO_Country__c
	public List<SelectOption> lstISOCountries {
		get {
			return ISO_Country_State_Helper.getPicklistISOCountry(lstCountryState);
		}
	}
	
	// picklist options for address: ISO_State__c
	public List<SelectOption> lstStateProvince {
		get {
			return ISO_Country_State_Helper.getPicklistISOState(lstCountryState, oBillingAddress.ISO_Country__c);
		}
	}
	
	// country and state list, the source for Country and State picklists
	private List<ISO_Country_State_DTO> lstCountryState {
		get{
			if (lstCountryState == null) {
				lstCountryState = ISO_Country_State_Helper.getCountry_State();
			}
			return lstCountryState;
		}
		private set;
	}
	
	public Boolean bStateAvailable
	{
		get
		{
			return lstStateProvince.size() > 1;
		}
	}
	
	
	
	// ========================================================================
	// Billing details methods
	
	public void clickEditButton()
	{
		editMode = true;
	} // clickEditButton
	
	// ========================================================================
	// save billing detail: contact and address
	public void clickSaveBillingDetailButton()
	{
		update oPaymentBillingContact;
		updateAddressDetail(); // update oBillingAddress, oOriginalBillingAddress, oBillingLocation
		
		// this is to reset the source, and make it reread
		rereadBillingAccount();  
		oPaymentBillingContact = null;
		//oBillingAddress = null;
		
		editMode = false;
	} // clickUpdateBillingContactButton
	
	
	// changing billingCountry will change the picklist lstStateProvince
	// it is done as the form posted oBillingAddress.ISO_Country__c, and rerender display of lstStateProvince
	public void onChangeBillingCountry()
	{
		// do nothing
	}
	
	// ========================================================================
	// get the values of billingLocation, oBillingAddress, oOriginalBillingAddress
	// see vfIECShoppingCart.pageLoad() for reference.
	private void getAddressDetail()
	{
		// check if the customer needs to fill his contact information
		if (IECUserManager.hasAddress(loggedCustomer.RelatedContact.Id, IECConstants.IECAddress_AddressType_Billing)) {
			// Retrieve existing billing location for this contact
			oBillingLocation = Location_Sel.getLocationByContact(loggedCustomer.RelatedContact.Id, IECConstants.IECAddress_AddressType_Billing)[0];
			
			List<IECAddress__c> lstAddresses = IECUserManager.getAddressByContact(loggedCustomer.RelatedContact.Id, IECConstants.IECAddress_AddressType_Billing);
			if (lstAddresses.size() > 0) {
				oBillingAddress = lstAddresses.get(0);
				oOriginalBillingAddress = oBillingAddress.clone(false, true); // used this to check if it changes on saving
				//isCountryFilled = String.isNotBlank(oBillingAddress.ISO_Country_Name__c);
				//vatConfig = IECVATUtil.GetVATConfiguration(oBillingAddress.ISO_Country_Name__c); 
			}
			
			//needToFillContactInfo = !IECUserManager.isBillingAddressFilled(loggedCustomer.RelatedContact.Id)
			//	|| !IECUserManager.isContactMandatoryFieldsFilled(loggedCustomer.RelatedContact, vatConfig);
		}
		else {
			// customer does not have a billing address, so create a new one, and also create a new Location
			oBillingLocation = new Location__c(
				Active__c = true
				, Account__c = loggedCustomer.RelatedAccount.Id
				, Contact__c = loggedCustomer.RelatedContact.Id
				, Type__c = IECConstants.IECAddress_AddressType_Billing
			);
			oBillingAddress = new IECAddress__c();
			//needToFillContactInfo = true;
			//isCountryFilled = false;
			//vatConfig = null;
		}
		
	} // end of getAddressDetail()
	
	
	// ========================================================================
	// check if need to create a new billing 
	// updating the address has some complexity based on the Ecom3A, and phases 1 and 2 design
	// this is based on the model on VfIECShoppingCart.updateContactInfo()
	// note that this model, will keep adding garbage records of previous BillingAddress 
	private void updateAddressDetail()
	{
		// First check if the address has been changed before trying to save, otherwise just ignore
		if (IECAddress_Svc.isAddressChanged(oBillingAddress, oOriginalBillingAddress))
		{
			// insert as a new Billing Address
			oBillingAddress.Id = null; // Reset the ID to be able to insert a new IEC Address record
			insert oBillingAddress;
			
			// Then copy the ID into the location record
			oBillingLocation.Address__c = oBillingAddress.Id;
			upsert oBillingLocation;
			
			// re-query the Billing Address to refresh formula fields on the record
			List<IECAddress__c> lstAddresses = IECUserManager.getAddressByContact(loggedCustomer.RelatedContact.Id, IECConstants.IECAddress_AddressType_Billing);
			if (lstAddresses.size() > 0) {
				oBillingAddress = lstAddresses.get(0);
				// Clone the record to check later whether it is changed when saving
				oOriginalBillingAddress = lstAddresses.get(0).clone(false, true);
			}
		}
	} // end of updateAddressDetail
	
	
	
	// ========================================================================
	// Payment Method / Credit Card section
	// ------------------------------------------------------------------------
	
	public String selectedPaymentMethodType { get; set; }
	public String selectedCreditCardPaymentId { get; set; }
	
	public String defaultPaymentExternalId {
		get{
			return billingAccount.Zuora__Default_Payment_Method__r.Zuora__External_Id__c;
		}
	}
	
	// there is limit of payment that can be done using credit card
	public Boolean isPayableWithCreditCard {
		get{
			return IECSubscriptionManager.canPurchaseAmountWithPaymentMethod(IECConstants.PaymentThresholdType_CreditCard, totalAmountDue);
		}
		//private set;
	} 
	
	// only some customer can pay with ICH, and there is a limit on the payment
	public Boolean isPayableWithICH {
		get{
			Boolean result = loggedCustomer.canPayByICH()
				&& IECSubscriptionManager.canPurchaseAmountWithPaymentMethod(IECConstants.PaymentThresholdType_ICH, totalAmountDue);
			return result;
		}
	} 
	
	// bank transfer payment is only for non pay as you go
	public Boolean isPayableWithBankTransfer {
		get{
			Boolean result = (paidProductRatePlan.EBC_SubscriptionType__c != EBC_PRODUCT_RATE_PLAN_SUBSCRIPTION_TYPE_PAY_AS_YOU_GO);
			return result;
		}
	} 
	
	
	// existing credit card list
	// for other example, see IECSubscriptionManager.getPaymentMethodsFromZuora
	public List<IECZuoraHelper.PaymentMethod> paymentMethods { 
		get{
			if (paymentMethods == null)
			{
				paymentMethods = new List<IECZuoraHelper.PaymentMethod>();
				List<IEC_Payment_Threshold__c> lstThreshold = null;

				if (loggedCustomer.PaymentMethods != null && loggedCustomer.PaymentMethods.size() > 0) {
					paymentMethods = IECZuoraHelper.convertFromzObjectListToPaymentMethod(loggedCustomer.PaymentMethods);
				}
			}
			return paymentMethods;
			
		}
		private set; 
	}
	
	/*
	public Boolean hasPaymentMethods {
		get {
			return (paymentMethods != null && paymentMethods.size() > 0);
		}
		private set;
	}
	*/
	
	
	// =======================================================================
	// Payment Confirmation section
	// -----------------------------------------------------------------------
	 
	// =======================================================================
	// flags for what to be displayed in Payment Confirmation
	// this flags also affect the payment action

	// Payment can only be done if the address update is already saved
	public Boolean showPaymentButtons
	{
		get{
			Boolean result = (! editMode 
								&& !(String.isBlank(oPaymentBillingContact.FirstName))
								&& !(String.isBlank(oPaymentBillingContact.LastName))
								&& !(String.isBlank(oPaymentBillingContact.Title))
								&& !(String.isBlank(oPaymentBillingContact.Email))
								&& !(String.isBlank(oPaymentBillingContact.Phone))
								&& !(String.isBlank(oBillingAddress.Street__c))
								&& !(String.isBlank(oBillingAddress.ISO_Country__c))
							);
			return true;
		}
	} // end of showPaymentButtons getter
	
	// for the case of payExactAmount does not show the RatePlan.Name and RatePlanCharge.Name
	public Boolean payExactAmount{
		get{
			Boolean result = ( paymentTarget == EBC_PAYMENT_TARGET_CAMPAIGN
							&& campaignPaymentOption == EBC_PAYMENT_CAMPAIGN_EXACT);
			return result;
		}
	}
	
	public Boolean payEmailCredit{
		get{
			Boolean result = ( (paymentTarget == EBC_PAYMENT_TARGET_ACCOUNT_EMAIL_PACKAGE) 
								||( paymentTarget == EBC_PAYMENT_TARGET_CAMPAIGN
									&& campaignPaymentOption == EBC_PAYMENT_CAMPAIGN_EMAIL_PACKAGE));
			return result;
		}
	}
		
	public Boolean payNewRatePlan{
		get{
			Boolean result = ( (paymentTarget == EBC_PAYMENT_TARGET_ACCOUNT_RATE_PLAN) 
								|| (paymentTarget == EBC_PAYMENT_TARGET_CAMPAIGN 
									&& campaignPaymentOption == EBC_PAYMENT_CAMPAIGN_RATE_PLAN));
			return result;
		}
	}
		
	public Boolean payAddOn{
		get{
			Boolean result = (paymentTarget == EBC_PAYMENT_TARGET_ACCOUNT_ADD_ON);
			return result;
		}
	}
		
	private Boolean isRenewal{
		get{
			return false;
		}
	}
	
	
	// ========================================================================
	// ProductRatePlan and relevant ProductRatePlanCharge for what to be displayed in Payment Confirmation 
	public zqu__ProductRatePlan__c paidProductRatePlan
	{
		get{
			if (paidProductRatePlan == null){
				if (selectedRatePlanId != null) {
					List<zqu__ProductRatePlan__c> prpList = [select Id, Name 
															, EBC_SubscriptionType__c
															, (select Id, Name, zqu__ProductRatePlan__c, zqu__ListPrice__c, zqu__Description__c, zqu__Type__c
																	from zqu__R00N40000001mFVKEA2__r order by Id)
															from zqu__ProductRatePlan__c
															where Id = : selectedRatePlanId 
															];
					paidProductRatePlan = (prpList.size() == 1) ? prpList[0] : new zqu__ProductRatePlan__c(Name = 'Incorrect incoming plan:' + selectedRatePlanId);
				}
			}
			return paidProductRatePlan;
		}
		private set;
	}
	
	// ========================================================================	
	// selectedProductRatePlanChargeWrapperList contains the items to pay
	public List<ProductRatePlanChargeWrapper> selectedProductRatePlanChargeWrapperList
	{
		get{
			if (selectedProductRatePlanChargeWrapperList == null) {
				
				Set<String> prpcTypeSet = new Set<String>();
				if (payExactAmount) prpcTypeSet.add(RATE_PLAN_CHARGE_TYPE_USAGE);
				if (payEmailCredit) prpcTypeSet.add(RATE_PLAN_CHARGE_TYPE_ONE_TIME);
				if (payNewRatePlan) prpcTypeSet.add(RATE_PLAN_CHARGE_TYPE_ONE_TIME);
				if (payNewRatePlan) prpcTypeSet.add(RATE_PLAN_CHARGE_TYPE_RECURRING);
				if (payAddOn) prpcTypeSet.add(RATE_PLAN_CHARGE_TYPE_ONE_TIME);
				if (payAddOn) prpcTypeSet.add(RATE_PLAN_CHARGE_TYPE_RECURRING);
				if (paymentTarget == EBC_PAYMENT_TARGET_RENEWAL) prpcTypeSet.add(RATE_PLAN_CHARGE_TYPE_RECURRING);
				
				List<ProductRatePlanChargeWrapper> prpcwList = new List<ProductRatePlanChargeWrapper>();
				// copy releveant PRP from those listed in product rate plan
				for (zqu__ProductRatePlanCharge__c prpc : paidProductRatePlan.zqu__R00N40000001mFVKEA2__r)
				{
					if ( prpcTypeSet.contains(prpc.zqu__Type__c)) // selected type
					{
						prpcwList.add(new ProductRatePlanChargeWrapper(prpc,emailCreditPurchased));
					}
				}
				// 
				selectedProductRatePlanChargeWrapperList = prpcwList;
			}
			
			return selectedProductRatePlanChargeWrapperList;
		}
		set;
	}
	
	// ========================================================================
	// the total taxAmount which will be provided from Zuora
	public Decimal taxAmount{
		get{
			if (taxAmount == null) taxAmount = 0;
			return taxAmount;
		}
		set;
	}
	
	// ========================================================================
	// subTotalAmount is the toal amount of charge prior to the tax
	// automatically calculated as the total of itemized charge
	public Decimal subTotalAmount{
		get{
			Decimal sumOfListPrice = 0;
			for (ProductRatePlanChargeWrapper prpcw : selectedProductRatePlanChargeWrapperList)
			{
				sumOfListPrice += prpcw.chargeAmount;
			}
			return sumOfListPrice;
		}
		//private set;
	}
	
	// ========================================================================
	// totalAmountDue is automatically calculated
	public Decimal totalAmountDue {
		get{
			return (subTotalAmount + taxAmount);
		}
		//private set;
	}
	
	
	// ========================================================================
	// supporting class: ProductRatePlanChargeWrapper
	// ------------------------------------------------------------------------
	public class ProductRatePlanChargeWrapper{
		public String name {get; private set;}
		public Decimal chargeAmount {get; private set;}
		public Decimal unitPrice {get; private set;}
		public Integer numberOfEmails {get; private set;}
		public Id prpcId {get;private set;}
		
		public ProductRatePlanChargeWrapper( zqu__ProductRatePlanCharge__c prpc, Integer numOfUnits)
		{
			name = prpc.Name;
			unitPrice = (prpc.zqu__ListPrice__c == null) ? 0 : prpc.zqu__ListPrice__c;
			chargeAmount = (prpc.zqu__Type__c == RATE_PLAN_CHARGE_TYPE_USAGE) 
							? unitPrice * numOfUnits
							: unitPrice;
			numberOfEmails = numOfUnits;
			prpcId = prpc.Id;
		}
		
	} // end class  ProductRatePlanChargeWrapper
	
} // end of class vfIECEBC_PaymentComponentController