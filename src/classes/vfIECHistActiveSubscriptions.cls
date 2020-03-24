public with sharing class vfIECHistActiveSubscriptions extends IECPageController {
	//Display variables
	public String sSubscriptionAutoRenew 		{get; set;}
	public String sSubscriptionAutoRenewButton 	{get; set;}
	public integer iSubscriptionDaysLeft 		{get; set;}
	public String sSubscriptionUsageStatus 		{get; set;} //Shows the number of clicks left
	public boolean bShouldDisplayAutoRenew		{get; set;}
		public boolean bDisplayPopUp 				{get; set;}
		public boolean bRefreshEnabled				{get; set;}
		public boolean bDisplayRenewBtn				{get; set;}
		public boolean bDisplayUpgradeBtn			{get; set;}
	public boolean bDisplaySimProdBtn			{get; set;}
	public boolean bDisplayBuyFromTrialBtn		{get; set;}
	public String sAttachTermsId				{get; set;}
	public Date dtLastAcceptedTnC				{get; set;}
	public Date dtNextBill						{get; set;}
	public boolean bShowUsage 					{get; set;}
	public decimal dUnitsPurchased				{get; set;}
	public decimal dUnitsConsumed				{get; set;}
	public decimal dUnitsLeft					{get; set;}

	//Selection handling variables
	public String sSelectedSubscriptionID		{get; set;}
	public String sSelectedSubscriptionName		{get; set;}
	public String sSelectedInvoiceID 			{get; set;}
	public String sSelectedPaymentID 			{get; set;}
	public ID idSelectedRatePlanInfo			{get; set;} // Initially set from Subscription History, but then swapped if applicable
	public ID idSelectedProdInfo				{get; set;} // Initially set from Subscription History, but then swapped if applicable


	//Object data variables
	public List<Zuora__Subscription__c> lstListActiveSubscriptions 	{get; private set;}
	public IEC_Subscription_History__c oSubscriptionHistory			{get; private set;}
	public Zuora__Subscription__c subscriptionObj					{get; private set;}
	public Zuora__ZInvoice__c invoice								{get; set;}
	public Zuora__Payment__c payment								{get; set;}

	public String sSortDirection { get; set; }
	public String sSortByColumn { get; set; }

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
	public vfIECHistActiveSubscriptions() {
		try {

			// check if an Subscription ID was passed as a parameter
			String sParamSubscriptionID = ApexPages.currentPage().getParameters().get(IECConstants.PARAM_SUBSCRIPTION_ID);
			if (sParamSubscriptionID!=null && !String.isEmpty(sParamSubscriptionID))
				sSelectedSubscriptionID = IECUtil.DecodeDecryptParameter(sParamSubscriptionID);
			else
				sSelectedSubscriptionID = null;

			// check if Subscription Name was passed as a parameter
			String sParamSubscriptionName = ApexPages.currentPage().getParameters().get(IECConstants.PARAM_SUBSCRIPTION_NAME);
			if (sParamSubscriptionName!=null && !String.isEmpty(sParamSubscriptionName))
				sSelectedSubscriptionName = IECUtil.DecodeDecryptParameter(sParamSubscriptionName);
			else
				sSelectedSubscriptionName = null;

		}
		catch (Exception ex) {
			addErrorMessage(ex.getMessage());
		}
	}

	/*********************************************************************************************************************/
	/* Cuostom methods
	/*********************************************************************************************************************/


	/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Update the calculated variables used in the page.
	private void updatUIVariables() {

		if (subscriptionObj != null) {


			//Set the remaining days calculated from today to subscriptionEndDate
			iSubscriptionDaysLeft = Date.today().daysBetween(subscriptionObj.Zuora__SubscriptionEndDate__c);
			if (iSubscriptionDaysLeft < 0) iSubscriptionDaysLeft = 0;

			//Set user friendly values for AutoRenew (regular is true/false)
			boolean autorenew = subscriptionObj.Zuora__AutoRenew__c;
			sSubscriptionAutoRenew = autorenew ? 'ON': 'OFF';
			sSubscriptionAutoRenewButton = autorenew ? 'OFF': 'ON';

			//Conditions to show Autorenew toggle button
			//- Auto Renew from ON to OFF not available if within the auto-renewal window of the subscription end date
			//- Auto-Renew from OFF to ON, available at all time for Active subscriptions
			Integer iAutoRenewalWindow;
			if (oSubscriptionHistory != null && subscriptionObj.Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Auto_Renewal_Window__c != null)
				iAutoRenewalWindow = Integer.valueOf(subscriptionObj.Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Auto_Renewal_Window__c);
			else
				iAutoRenewalWindow = 0;

			bShouldDisplayAutoRenew = (!autorenew || (autorenew && iSubscriptionDaysLeft > iAutoRenewalWindow))
									&& !subscriptionObj.Product_Rate_Plan_Information__r.Is_Triable__c;

			//Gets the usage status from wherever it is store (TBD)
			sSubscriptionUsageStatus = 'TBD';

			// Determines next bill cycle date for the subscription recurring charge
			// ASSUMPTION: The subscription will contain only ONE RECURRING CHARGES, OTHERWISE code must be revisited
			if (!subscriptionObj.Zuora__Subscription_Product_Charges__r.isEmpty()) {
				Zuora__SubscriptionProductCharge__c subCharge = subscriptionObj.Zuora__Subscription_Product_Charges__r.get(0);
				dtNextBill = IECSubscriptionManager.getNextBillDate(subCharge.Zuora__EffectiveStartDate__c, subCharge.Zuora__EffectiveEndDate__c, subscriptionObj.Zuora__AutoRenew__c, subCharge.Zuora__Type__c, subCharge.Zuora__BillingPeriod__c);
			}
		}
	}


	/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Refreshes the detail information, including the related references to invoice and payment
	private void refreshSubscriptionDetails() {
		if (subscriptionObj != null) {
			//Update UI variables
			updatUIVariables();

			//Get Usage data
			List<IEC_Product_Access__c> productAccess = IECApplicationsManager.getProductAccessBySubscriptionNumber(subscriptionObj.Name);

			if (productAccess != null && productAccess.size() > 0) {
				bShowUsage = true;
				dUnitsPurchased = 0;
					dUnitsConsumed = 0;
				dUnitsLeft = 0;

				for (IEC_Product_Access__c access : productAccess) {

					dUnitsPurchased += ((access.Usage_Qty_Start__c != null) ? access.Usage_Qty_Start__c : 0);
					dUnitsConsumed += ((access.Usage_Qty_consumed__c != null) ? access.Usage_Qty_consumed__c : 0);


					// Only count units left if they are still valid
					if (access.Effective_Start_Date__c <= DateTime.now()
						&& access.Effective_End_Date__c >= DateTime.now()
						&& access.Active__c)
					dUnitsLeft += ((access.Usage_Qty_Left__c != null) ? access.Usage_Qty_Left__c : dUnitsPurchased);

										if(access.Usage_Unlimited__c)
										{
												dUnitsLeft = -999;
												dUnitsPurchased = -999;
										}

				}
			}
			else
				bShowUsage = false;

			//Get InvoiceItem related to the subscription
			Invoice_Item__c invoiceItem = IECSubscriptionManager.getInvoiceItemBySFSubscriptionName(subscriptionObj.Name);

			if (invoiceItem != null) {
				//Get the Invoice related to InvoiceItem
				invoice = IECSubscriptionManager.getInvoiceById(invoiceItem.Invoice__c);

				if (invoice != null) {
					if (invoice.Zuora__Payments__r != null && invoice.Zuora__Payments__r.size() > 0) {
						//Get the Payment related to the Invoice
						payment = invoice.Zuora__Payments__r.get(0);
					}
					else {
						//No payment could mean "ICH" so, the invoice should be hidden
						// (Modification to show INVOICE even under ICH, 2014-07-11)
						//invoice = null;
						payment = null;
					}
				} // END if (invoice != null)
			} // END if (invoiceItemResult != null)
			else
				addWarningMessage('No InvoiceItem found');
		} // END if (subscriptionObj != null)
	}

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Close the confirmation frame used to confirm the autorenew value
	public void closePopup() {
				bDisplayPopUp = false;
		}

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Shows the confirmation frame before updating the autoRenew value
		public void showPopup() {
				bDisplayPopUp = true;
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
				lstListActiveSubscriptions = getActiveSubscriptionsList();

				// preselect subscription if one was specified in the parameters: subscriptionId
				if (lstListActiveSubscriptions != null && lstListActiveSubscriptions.size() > 0 && !String.isEmpty(sSelectedSubscriptionID) && sSelectedSubscriptionID != null) {
					selectSubscription();
				}

				// preselect subscription if one was specified in the parameters: zuoraSubscriptionId
				if (sSelectedSubscriptionName != null && !String.isEmpty(sSelectedSubscriptionName)) {
					selectSubscriptionByName();
				}

			}
		}
		catch(Exception ex) {
			addErrorMessage(ex.getMessage() + '<br />' + ex.getStackTraceString());
		}

		return null;
	}

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Handles the selection of one subscription (by subscription Name) and query for its details
	public Pagereference selectSubscriptionByName() {
		resetDetailParameters();

		try {
			if (sSelectedSubscriptionName!=null && !String.isEmpty(sSelectedSubscriptionName)) {
				//Query for subsrciption's detail
				subscriptionObj = IECSubscriptionManager.getSubscriptionByName(sSelectedSubscriptionName);

				loadSubscriptionHistory();
				refreshSubscriptionDetails();

				//Set selectedSubscritionId after the search performed by name
				sSelectedSubscriptionID = subscriptionObj.Id;
			}
		}
		catch(Exception ex) {
			addErrorMessage(ex.getMessage() + '<br />' + ex.getStackTraceString());
		}
		return null;
	}

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Handles the selection of one subscription (by subscriptionID) and query for its details
	public Pagereference selectSubscription() {
		resetDetailParameters();

		try {
			if (sSelectedSubscriptionID!=null && !String.isEmpty(sSelectedSubscriptionID)) {
				//Query for subsrciption's detail
				subscriptionObj = IECSubscriptionManager.getSubscriptionById(sSelectedSubscriptionID);

				loadSubscriptionHistory();
				refreshSubscriptionDetails();
			}
		}
		catch(Exception ex) {
			addErrorMessage(ex.getMessage() + '<br />' + ex.getStackTraceString());
		}
		return null;
	}

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Resets the Details section parameters on selecting subscription
	private void resetDetailParameters() {
		bShouldDisplayAutoRenew = false;
		bRefreshEnabled = false;
		idSelectedRatePlanInfo = null;
		idSelectedProdInfo = null;
		bDisplayRenewBtn = false;
		bDisplaySimProdBtn = false;
		bDisplayUpgradeBtn = false;
		bDisplayBuyFromTrialBtn = false;
		sAttachTermsId = '';
		dtNextBill = null;
		invoice = null;
		payment = null;
		subscriptionObj = null;
		oSubscriptionHistory = null;
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

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Refreshes the page. Usualy it will be called after an update of Zuora records to refresh synched records in SF
	public Pagereference refreshPage() {

		Pagereference prActiveSubs = Page.IECHistActiveSubscriptions;
		prActiveSubs.getParameters().put(IECConstants.PARAM_SUBSCRIPTION_NAME, IECUtil.EncryptEncodeParameter(subscriptionObj.Name));
		prActiveSubs.setRedirect(true);
		return prActiveSubs;
	}

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Handles the change of auto renew flag on subscription
	public Pagereference toggleAutoRenew() {
		try {
			if (subscriptionObj != null) {
				//Get the customer account
				//IECCustomer currentCustomer = IECCustomer.getCurrentIECCustomer();

				//Get the new valu to be pushed to Zuora
				boolean newAutoRenewValue = !subscriptionObj.Zuora__AutoRenew__c;

				//Push the information to Zuora
				Zuora.zApi.AmendResult zResult = IECZuoraHelper.updateZuoraAutoRenew(loggedCustomer, subscriptionObj.Zuora__Zuora_Id__c ,newAutoRenewValue);

				//Request a sync of data between Zuora and SF for the account related to the logged user
				Zuora.zObject zuoraAccountId = loggedCustomer.RelatedZuoraAccount;
				List<Zuora.SyncResult> syncResult = IECSubscriptionManager.OnDemandSyncAccounts(new Set<String> {(String)zuoraAccountId.getValue('Id')});

				/*
				if (syncResult != null && syncResult.size() > 0) {
					addInfoMessage('Success: ' + String.valueOf(syncResult.get(0).success));
					addInfoMessage('Status Message: ' + syncResult.get(0).statusMessage);
				}
				*/

				/*
				Error message requiring investigation:
				Context: after pushing an Autorenew flag change to Zuora, the request for Sync does not work returning the following message
				Success: false
				Status Message: An error occurred while sending on-demand sync request to ZBilling.
								The error details are :You have uncommitted work pending. Please commit or rollback before calling out
								The update of Auto Renew was successful. The page will refresh in 10 seconds
				*/

				//Hides the confirmation popup and trigger the refres of the page
				bDisplayPopUp = false;
				bRefreshEnabled = true; //The refresh is required to reflect the new data record synched from Zuora

				//Show feedback to the user telling the page will refresh in few seconds.
				addInfoMessage('The page should refresh in 10 seconds');

				//Add entry to user log
				addEntryToUserLog((String)loggedCustomer.RelatedUser.Id, subscriptionObj.Name, 'Changed Auto Renew flag', String.valueOf(!newAutoRenewValue), String.valueOf(newAutoRenewValue));

			}
		}
		catch(Exception ex) {
			addErrorMessage(ex.getMessage());
		}

		//Hides the confirmatino popup in case of an exception
		bDisplayPopUp = false;
		return null;
	}

	@future
	private static void addEntryToUserLog(String userId, String subscriptionNumber, String logEntry, String oldValue, String newValue) {
		try {
			IEC_User_Log__c oUserLog = new IEC_User_Log__c();

			oUserLog.User__c = /*currentUser.Id*/ userId;
			oUserLog.Log_Description__c = logEntry;
			oUserLog.Old_Value__c = oldValue;
			oUserLog.New_Value__c = newValue;
			oUserLog.Subscription_Number__c = subscriptionNumber;

			insert oUserLog;
		}
		catch(Exception ex) {
			system.debug('Cannot create IEC_User_Log__c in vfIECHistActiveSubscriptions.addEntryToUserLog(): ' + ex.getMessage());
		}
	}

	/**
	 * Navigate to the product category with similar product category
	 */
	public Pagereference onClickSimilarProducts() {
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
	public Pagereference renewRatePlan() {
		try {
				Pagereference pgRef = Page.IECRenew;
				pgRef.getParameters().put(IECConstants.PARAM_SUBSCRIPTION_ID, IECUtil.EncryptEncodeParameter(subscriptionObj.Id));
				pgRef.getParameters().put(IECConstants.PARAM_PRODINFO_ID, IECUtil.EncryptEncodeParameter(idSelectedProdInfo));
				pgRef.getParameters().put(IECConstants.PARAM_RATEPLANINFO_ID, IECUtil.EncryptEncodeParameter(idSelectedRatePlanInfo));
				pgRef.setRedirect(true);
				return pgRef;
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
					idSelectedProdInfo = subscriptionObj.Product_Rate_Plan_Information__r.Related_Product_Information__c;
				}

				bDisplaySimProdBtn = IECProductManager.isProductCategoryAvailable(subscriptionObj.Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__c);

				// check if there are upgrades available for the subscription rate plan
				List<Product_Rate_Plan_Information__c> lstRatePlanInfoUpgrades = IECProductManager.getRatePlanInformationUpgradesBySourceRatePlan(subscriptionObj.Product_Rate_Plan_Information__c, IECUserManager.getClientType());
				bDisplayUpgradeBtn = !lstRatePlanInfoUpgrades.isEmpty();

				// display the Buy button if the rate plan is a trial
				bDisplayBuyFromTrialBtn = subscriptionObj.Product_Rate_Plan_Information__r.Is_Triable__c;
			}

			if (oSubscriptionHistory != null) {
				// Load the last accepted T&C attachment Id
				Terms_and_Conditions__c oTnC = IECProductManager.getLastAcceptedTermsAndConditionBySubscriptionName(oSubscriptionHistory.Subscription_Number__c);
				sAttachTermsId = (oTnC != null ? (String)oTnC.Attachments.get(0).Id : '');
				//dtLastAcceptedTnC = (oTnC != null ? oTnC.CreatedDate : null);
			}

			bDisplayRenewBtn = !subscriptionObj.Zuora__AutoRenew__c
							&& (oSubscriptionHistory == null || oSubscriptionHistory.Action__c != 'Trial')
							&& subscriptionObj.Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Renewal_Window__c != null
							&& subscriptionObj.Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Renewal_Window__c != '0'
							&& subscriptionObj.Zuora__SubscriptionEndDate__c.addDays((-1 * integer.valueOf(subscriptionObj.Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Renewal_Window__c))) <= Date.today()
							&& subscriptionObj.Zuora__SubscriptionEndDate__c >= Date.today()
							&& ((idSelectedRatePlanInfo != null) ? IECProductManager.isRatePlanAvailable(idSelectedRatePlanInfo, IECUserManager.getClientType()) : false);
		}
		catch (Exception ex) {
			addErrorMessage(ex.getMessage());
		}
	}


	/*********************************************************************************************************************/
	/* SF Query Methods
	/*********************************************************************************************************************/
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Returns the active subscriptions for the current logged user
	public List<Zuora__Subscription__c> getActiveSubscriptionsList() {
		try {
			//No need to validate is user is logged in. Already done in the PageLoad

			//Find the billing account for logged user
			// *** IECCUstomer is based on the IECUserManager current logged user
			IECCustomer currentCustomer = IECCustomer.getCurrentIECCustomer();
			if (currentCustomer == null) return null;

			//Return the active subscriptions related to the billing account of logged user
			if (currentCustomer.RelatedBillingAccount != null)
				return IECSubscriptionManager.getActiveSubscriptionsByBillingAccount(currentCustomer.RelatedBillingAccount.Id);
		}
		catch(Exception ex) {
			addErrorMessage(ex.getMessage());
		}

		return null;
	}

	/**
	 * Sends the customer to the upgrade page
	 */
	public Pagereference upgrade() {
		try {
			if (subscriptionObj == null)
				throw new IECApplicationException(Label.IEC_Error_SubscriptionNotFound);

				Pagereference pgRef = Page.IECUpgrade;
				pgRef.getParameters().put(IECConstants.PARAM_SUBSCRIPTION_ID, IECUtil.EncryptEncodeParameter(subscriptionObj.Id));
				pgRef.setRedirect(true);
				return pgRef;
		}
		catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
			return null;
		}
	}

	/**
	 * Sends the customer to the product page to buy the trial
	 */
	public Pagereference buyFromTrial() {
		try {
			if (subscriptionObj == null)
				throw new IECApplicationException(Label.IEC_Error_SubscriptionNotFound);

				Pagereference productViewerPage = Page.IECProductViewer;
			productViewerPage.getParameters().put(IECConstants.PARAM_PRODUCT_CODE, IECUtil.EncryptEncodeParameter(subscriptionObj.Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Name));
				productViewerPage.setAnchor('pricing');
				productViewerPage.setRedirect(true);
				return productViewerPage;
		}
		catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
			return null;
		}
	}




	/**
	 * Action when a user sort by a column
	 */
	public Pagereference sortSubscriptions() {
		try {
			if (sSortDirection == '' || sSortByColumn == '')
				return null;
			IECCustomer currentCustomer = IECCustomer.getCurrentIECCustomer();
			lstListActiveSubscriptions = IECSubscriptionManager.getSortedSubscriptionsByBillingAccount((String)currentCustomer.RelatedBillingAccount.Id, sSortByColumn, sSortDirection);

			return null;
		}
		catch(Exception ex) {
			addErrorMessage(ex.getMessage());
			return null;
		}
	}

}
