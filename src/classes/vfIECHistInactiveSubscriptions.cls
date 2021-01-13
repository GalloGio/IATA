public with sharing class vfIECHistInactiveSubscriptions extends IECPageController {
	//Display variables
	public integer iSubscriptionDaysLeft	{get; set;}
	public String sSubscriptionUsageStatus	{get; set;} //Shows the number of clicks left
	public boolean bDisplayNewBtn			{get; set;}
	public boolean bDisplaySimProdBtn		{get; set;}
	public String sAttachTermsId			{get; set;}
	public boolean bShowUsage 				{get; set;}
	public decimal dUnitsPurchased			{get; set;}
	public decimal dUnitsConsumed			{get; set;}
	public decimal dUnitsLeft				{get; set;}

	//Selection handling variables
	public String sSelectedSubscriptionID	{get; set;}
	public ID idSelectedRatePlanInfo		{get; set;} // Initially set from Subscription History, but then swapped if applicable
	public String sSelectedInvoiceID		{get; set;}
	public String sSelectedPaymentID		{get; set;}

	//Object data variables
	public List<Zuora__Subscription__c> lstListInactiveSubscriptions	{get; private set;}
	public IEC_Subscription_History__c oSubscriptionHistory				{get; private set;}
	public Zuora__Subscription__c subscriptionObj						{get; private set;}
	public Zuora__ZInvoice__c invoice									{get; set;}
	public Zuora__Payment__c payment									{get; set;}

	public String sPaymentMethod {
		get {
			return (oSubscriptionHistory != null) ? oSubscriptionHistory.Selected_Payment_Method__c
				 + ((oSubscriptionHistory.Selected_Payment_Method__c == 'Credit Card') ? '<BR/>' + oSubscriptionHistory.Credit_Card__c : '') : '';
		}
	}

	public String sProductName {
		get {
			return (subscriptionObj != null) ? subscriptionObj.Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Display_Name__c : '';
		}
	}

	public String sOptionName {
		get {
			return (subscriptionObj != null) ? subscriptionObj.Product_Rate_Plan_Information__r.Product_Rate_Plan__r.Name : '';
		}
	}

	/*********************************************************************************************************************/
	/* Constructor Methods
	/*********************************************************************************************************************/


	/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Controller class constructor
	public vfIECHistInactiveSubscriptions() {
		try {
			// check if an Subscription ID was passed as a parameter
			String sParamSubscriptionID = ApexPages.currentPage().getParameters().get(IECConstants.PARAM_SUBSCRIPTION_ID);
			if (sParamSubscriptionID!=null && !String.isEmpty(sParamSubscriptionID))
				sSelectedSubscriptionID = IECUtil.DecodeDecryptParameter(sParamSubscriptionID);
			else
				sSelectedSubscriptionID = null;
		}
		catch (Exception ex) {
			addErrorMessage(ex.getMessage());
		}
	}

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Update the calculated variables used in the page.
	private void updatUIVariables() {

		if (subscriptionObj != null) {

			//Set the remaining days calculated from today to subscriptionEndDate
			iSubscriptionDaysLeft = Date.today().daysBetween(subscriptionObj.Zuora__SubscriptionEndDate__c);
			if (iSubscriptionDaysLeft < 0) iSubscriptionDaysLeft = 0;

			//Gets the usage status from wherever it is store (TBD)
			sSubscriptionUsageStatus = 'TBD';
		}
	}


	/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Refreshes the detail information, including the related references to invoice and payment
	private void refresSubscriptionDetails() {
		if (subscriptionObj != null) {

			//Update UI variables
			updatUIVariables();

			//Get Usage data
			List<IEC_Product_Access__c> productAccess = IECApplicationsManager.getProductAccessBySubscriptionNumber(subscriptionObj.Name);

			if (productAccess != null && productAccess.size() > 0) {
				bShowUsage = true;
				dUnitsPurchased =
					dUnitsConsumed =
					dUnitsLeft = 0;

				for (IEC_Product_Access__c access : productAccess) {
					dUnitsPurchased += ((access.Usage_Qty_Start__c != null) ? access.Usage_Qty_Start__c : 0);
					dUnitsConsumed += (((access.Usage_Qty_Start__c != null) ? access.Usage_Qty_Start__c : 0)
						- ((access.Usage_Qty_Left__c != null) ? access.Usage_Qty_Left__c : 0));

					// Only count units left if they are still valid
					if (access.Effective_Start_Date__c <= DateTime.now()
						&& access.Effective_End_Date__c >= DateTime.now()
						&& access.Active__c)
					dUnitsLeft += ((access.Usage_Qty_Left__c != null) ? access.Usage_Qty_Left__c : 0);				}
			}
			else
				bShowUsage = false;

			//Get InvoiceItem related to the subscription
			Invoice_Item__c oInvoiceItem = IECSubscriptionManager.getInvoiceItemBySFSubscriptionName(subscriptionObj.Name);

			if (oInvoiceItem != null) {
				//Get the Invoice related to InvoiceItem
				invoice = IECSubscriptionManager.getInvoiceById(oInvoiceItem.Invoice__c);

				if (invoice != null) {
					if (invoice.Zuora__Payments__r != null && invoice.Zuora__Payments__r.size() > 0) {
						//Get the Payment related to the Invoice
						payment = invoice.Zuora__Payments__r.get(0);
					}
					else {
						//No payment could mean "ICH" so, the invoice should be hidden
						invoice = null;
						payment = null;
					}
				} // END if (invoice != null)
			} // END if (invoiceItemResult != null)
		} // END if (subscriptionObj != null)
	}


	/*********************************************************************************************************************/
	/* Pagereference Methods
	/*********************************************************************************************************************/

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Executes when the page is loaded
	public Pagereference pageLoad() {
		try {

			// first check if the user is logged in
			if (IECUserManager.isUserLoggedIn() == false) {
				Pagereference prLogin = Page.IECLogin;
				prLogin.getParameters().put(IECConstants.PARAM_RETURN_URL, IECUtil.EncryptEncodeParameter(ApexPages.currentPage().getUrl()));
				prLogin.getParameters().put(IECConstants.PARAM_WARNING_MSG, IECUtil.EncryptEncodeParameter(Label.IEC_Warning_Must_Login));
				prLogin.setRedirect(true);
				return prLogin;
			}
			else {
				// Validate Logged in user profile and ensure profile is complete
				validUserProfile();

				//Query for the active subscription list related to the current logged user
				lstListInactiveSubscriptions = getInactiveSubscriptionsList();

				// preselect subscription if one was specified in the parameters: subscriptionId
				if (lstListInactiveSubscriptions != null && lstListInactiveSubscriptions.size() > 0 && !String.isEmpty(sSelectedSubscriptionID) && sSelectedSubscriptionID != null) {
					selectSubscription();
				}

			}
		}
		catch(Exception ex) {
			addErrorMessage(ex.getMessage());
		}

		return null;
	}

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Handles the selection of one subscription and query for its details
	public Pagereference selectSubscription() {
		idSelectedRatePlanInfo = null;
		bDisplayNewBtn = false;
		bDisplaySimProdBtn = false;
		sAttachTermsId = '';

		try {
			if (sSelectedSubscriptionID != null && !String.isEmpty(sSelectedSubscriptionID)) {

				//Query for subsrciption's detail
				subscriptionObj = IECSubscriptionManager.getSubscriptionById(sSelectedSubscriptionID);

				loadSubscriptionHistory();
				refresSubscriptionDetails();
			}
		}
		catch(Exception ex) {
			addErrorMessage(ex.getMessage());
		}

		return null;
	}


	/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Handles the selection of payment and redirects to Payments page
	public Pagereference selectPayment() {
		try {
			if (sSelectedPaymentID!=null && !String.isEmpty(sSelectedPaymentID)) {

				Pagereference prPayment = Page.IECHistPayments;
				prPayment.getParameters().put(IECConstants.PARAM_PAYMENT_ID, IECUtil.EncryptEncodeParameter(sSelectedPaymentID));
				prPayment.setRedirect(true);
				return prPayment;
			}
		}
		catch(Exception ex) {
			addErrorMessage(ex.getMessage());
		}

		return null;
	}


	/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Handles the selection of invoice and redirects to Invoice page
	public Pagereference selectInvoice() {
		try {
			if (sSelectedInvoiceID!=null && !String.isEmpty(sSelectedInvoiceID)) {
				Pagereference prInvoice = Page.IECHistInvoices;
				prInvoice.getParameters().put(IECConstants.PARAM_INVOICE_ID, IECUtil.EncryptEncodeParameter(sSelectedInvoiceID));
				prInvoice.setRedirect(true);
				return prInvoice;
			}
		}
		catch(Exception ex) {
			addErrorMessage(ex.getMessage());
		}
		return null;
	}

	/**
	 * Navigate to the product category with similar product category
	 */
	public Pagereference navigateSimilarProducts() {
		try {
			Pagereference pgRef = Page.IECProductViewer;
  			pgRef.getParameters().put(IECConstants.PARAM_PRODUCT_CODE, IECUtil.EncryptEncodeParameter(subscriptionObj.Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Name));
			pgRef.setRedirect(true);
			return pgRef;
		}
		catch (Exception ex) {
			addErrorMessage(ex.getMessage());
		}
		return null;
	}

	/**
	 * Add into the shopping cart a new instance of the product rate plan already expired
	 */
	public Pagereference addToCart() {
		try {
			IEC_Shopping_Cart__c cart = IECShoppingCartHelper.getCurrentShoppingCart();

			// create shopping cart if not existing
			if (cart == null) {
				// create new shopping cart and save guid in cookie
				cart = IECShoppingCartHelper.createNewShoppingCart(IECUserManager.getContactId(), !IECUserManager.isUserLoggedIn());
			}

			// by default, quantity is 1 unless subscription history has different quantity
			IECShoppingCartHelper.addCartItem(cart, idSelectedRatePlanInfo, (oSubscriptionHistory == null) ? 1 : (integer) oSubscriptionHistory.Rate_Plan_Quantity__c);
  			Pagereference prShoppingCart = Page.IECShoppingCart;
			prShoppingCart.setRedirect(true);
			return prShoppingCart;
		}
		catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
			return null;
		}
	}

	/**
	 * Retrieves subscription history and determines whether to display the New button
	 * and gets the selected rate plan according to the current user type
	 */
	public void loadSubscriptionHistory() {
		try {
			if (subscriptionObj != null) {
				oSubscriptionHistory = IECSubscriptionManager.getSubscriptionHistoryByName(subscriptionObj.Name);

				// Check if this rateplan and its audience type match the current user type
				if (IECProductManager.isProductAudienceAllowedForClientType(subscriptionObj.Product_Rate_Plan_Information__r.Related_Product_Information__r.Product_Audience__c, IECUserManager.getClientType())) {
					idSelectedRatePlanInfo = subscriptionObj.Product_Rate_Plan_Information__c;
				}
				// Else get swapped rate plan
				else {
					// Get SWAP if the client type doesn't match using the Swap Configuration (Source -> Target)
					Map<ID, Product_Rate_Plan_Information__c> targetRatePlans = IECSubscriptionManager.getTargetSwappedRatePlans(new Set<Id> {subscriptionObj.Product_Rate_Plan_Information__c}, IECUserManager.getClientType());

					if (targetRatePlans != null && !targetRatePlans.isEmpty()) {
						idSelectedRatePlanInfo = targetRatePlans.values().get(0).Id;
					}
					else {
						// Get SWAP if the client type doesn't match using the Swap Configuration (Target -> Source)
						Map<ID, Product_Rate_Plan_Information__c> sourceRatePlans = IECSubscriptionManager.getSourceSwappedRatePlans(new Set<Id> {subscriptionObj.Product_Rate_Plan_Information__c}, IECUserManager.getClientType());

						// if no swap rate plans is available, then no active rate plan is available
						idSelectedRatePlanInfo  = (sourceRatePlans != null && !sourceRatePlans.isEmpty()) ? sourceRatePlans.values().get(0).Id : null;
					}
				}

				bDisplaySimProdBtn = IECProductManager.isProductCategoryAvailable(subscriptionObj.Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__c);
			}

			if (oSubscriptionHistory != null) {
				// Load the last accepted T&C attachment Id
				Terms_and_Conditions__c oTnC = IECProductManager.getLastAcceptedTermsAndConditionBySubscriptionName(oSubscriptionHistory.Subscription_Number__c);
				sAttachTermsId = (oTnC != null ? (String)oTnC.Attachments.get(0).Id : '');
			}

			bDisplayNewBtn = (idSelectedRatePlanInfo != null
								&& (oSubscriptionHistory == null || oSubscriptionHistory.Action__c != 'Trial'))
								? IECProductManager.isRatePlanAvailable(idSelectedRatePlanInfo, IECUserManager.getClientType())
								: false;
		}
		catch (Exception ex) {
			addErrorMessage(ex.getMessage());
		}
	}


	/*********************************************************************************************************************/
	/* Query Methods
	/*********************************************************************************************************************/

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Returns the active subscriptions for the current logged user
	public List<Zuora__Subscription__c> getInactiveSubscriptionsList() {
		try {
			//No need to validate is user is logged in. Already done in the PageLoad

			//Find the billing account for logged user
			// *** IECCUstomer is based on the IECUserManager current logged user
			IECCustomer currentCustomer = IECCustomer.getCurrentIECCustomer();
			if (currentCustomer == null) return null;

			//Query the active subscriptions related to the billing account of logged user
			if (currentCustomer.RelatedBillingAccount != null)
				return IECSubscriptionManager.getInactiveSubscriptionsByBillingAccount(currentCustomer.RelatedBillingAccount.Id);
		}
		catch(Exception ex) {
			addErrorMessage(ex.getMessage());
		}
		return null;
	}
}
