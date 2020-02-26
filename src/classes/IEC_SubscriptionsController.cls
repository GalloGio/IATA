public class IEC_SubscriptionsController extends IECPageController {

	public boolean bRefreshEnabled				{get; set;}
	public String subsId 						{get; set;}
	public String subscriptionToUpgradeId		{get; set;}
	public String subscriptionToRenewId 		{get; set;}
	public Id idSelectedProdInfo 				{get; set;}
	public Id idSelectedRatePlanInfo 			{get; set;}

	public List<ZuoraSubscription_DTO> lstActiveSubscriptions 	{get;set;}

	Map<String,Zuora__Subscription__c> subscriptionMap = new Map<String,Zuora__Subscription__c>();

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Executes when the page is loaded
	public Pagereference pageLoad() {
		try {
			// first check if the user is logged in
			if (IECUserManager.isUserLoggedIn() == false) {
				Pagereference prLogin = Page.IEC_Login;
				prLogin.getParameters().put(IECConstants.PARAM_RETURN_URL, ApexPages.currentPage().getUrl());
				//prLogin.getParameters().put(IECConstants.PARAM_WARNING_MSG, IECUtil.EncryptEncodeParameter(Label.IEC_Warning_Must_Login));
				prLogin.setRedirect(true);
				return prLogin;
			}
			else {
				// Validate Logged in user profile and ensure profile is complete
				validUserProfile();
				lstActiveSubscriptions = new List<ZuoraSubscription_DTO>();

				String clientType = IECUserManager.getClientType();

				//Query for the active subscription list related to the current logged user
				List<Zuora__Subscription__c> lstListActiveSubscriptions = getActiveSubscriptionsList();

				set<String> subscriptionNumbers = new set<String>();
				set<String> prodRatePlanInfomationIds = new set<String>();
				set<Id> prodRatePlanInfoIds = new set<Id>();
				set<Id> orderItemIds = new set<Id>();

				if(lstListActiveSubscriptions == null || lstListActiveSubscriptions.isEmpty()) return null;

				for(Zuora__Subscription__c subscription : lstListActiveSubscriptions){
					subscriptionNumbers.add(subscription.Name);
					prodRatePlanInfomationIds.add(subscription.Product_Rate_Plan_Information__c);
					prodRatePlanInfoIds.add(subscription.Product_Rate_Plan_Information__c);
					orderItemIds.add(subscription.OrderItemId__c);
				}

				Map<String,List<IEC_Product_Access__c>> productAccessBySubscriptionNumbers = IECApplicationsManager.getProductAccessBySubscriptionNumbers(subscriptionNumbers);

				/**
				 * Retrieves subscription history and determines whether to display the New button
				 * and gets the selected rate plan according to the current user type
				 */
				Map<String,IEC_Subscription_History__c> subscriptionHistoryByName = IECSubscriptionManager.getSubscriptionHistoryByName(subscriptionNumbers);

				//Get Last Accpted Terms and Condition By Subscription Name
				Map<String,Terms_and_Conditions__c> getLastAcceptedTermsAndConditionBySubscriptionName = IECProductManager.getLastAcceptedTermsAndConditionBySubscriptionName(subscriptionNumbers);

				//Get subscriptions invoices
				Map<String,Invoice_Item__c> invoiceItemBySFSubscriptionName = IECSubscriptionManager.getInvoiceItemBySFSubscriptionName(subscriptionNumbers);
				set<Id> invoiceIds = new set<Id>();
				for(Invoice_Item__c ii : invoiceItemBySFSubscriptionName.values()){ invoiceIds.add(ii.Invoice__c); }

				//check if there are upgrades available for the subscription rate plan
				Map<Id,Product_Rate_Plan_Information__c> ratePlanInformationUpgradesBySourceRatePlan = IECProductManager.getRatePlanInformationUpgradesBySourceRatePlan(prodRatePlanInfomationIds, clientType);

				//Determines the availability of the product rate plan according to the specified user type
				Map<Id,Boolean> isRatePlanAvailable = IECProductManager.isRatePlanAvailable(prodRatePlanInfoIds, clientType);

				//Get the Invoice related to InvoiceItem
				Map<Id,Zuora__ZInvoice__c> invoiceById = IECSubscriptionManager.getInvoiceById(invoiceIds);

				//Set the order item Subscribe to Zuora check
				Map<Id,Boolean> orderItemZuoraSubscribeById = new OrderItem_Sel().getOrderItemZuoraSubscribeById(orderItemIds);

				for(Zuora__Subscription__c subscription : lstListActiveSubscriptions){

					//If the zuora subscription OrderItemId__c field in not null make sure that the related product to the item have the field IEC_Subscribe_to_Zuora__c set to true
					if(subscription.OrderItemId__c != null){
						Boolean subscribeToZuora = orderItemZuoraSubscribeById.get(subscription.OrderItemId__c);
						if(subscribeToZuora != null && !subscribeToZuora) continue;
					}

					//subscription.Zuora__AutoRenew__c = true;
					subscriptionMap.put(subscription.Id,subscription);

					ZuoraSubscription_DTO aSubscription = new ZuoraSubscription_DTO();
					//Set the remaining days calculated from today to subscriptionEndDate
					integer daysLeft = Date.today().daysBetween(subscription.Zuora__SubscriptionEndDate__c);
					if (daysLeft < 0) daysLeft = 0;

					//set the Subscription
					aSubscription.zSubscription = subscription;
					aSubscription.iSubscriptionDaysLeft = daysLeft;

					//
					List<IEC_Product_Access__c> productAccess = productAccessBySubscriptionNumbers.get(subscription.Name);
					if(productAccess != null && !productAccess.isEmpty()){
						aSubscription.bShowUsage = true;
						aSubscription.dUnitsPurchased = 0;
							aSubscription.dUnitsConsumed = 0;
						aSubscription.dUnitsLeft = 0;

						for (IEC_Product_Access__c access : productAccess) {
							aSubscription.dUnitsPurchased += ((access.Usage_Qty_Start__c != null) ? access.Usage_Qty_Start__c : 0);
							aSubscription.dUnitsConsumed += ((access.Usage_Qty_consumed__c != null) ? access.Usage_Qty_consumed__c : 0);

							// Only count units left if they are still valid
							if (access.Effective_Start_Date__c <= DateTime.now()
								&& access.Effective_End_Date__c >= DateTime.now()
								&& access.Active__c)
							aSubscription.dUnitsLeft += ((access.Usage_Qty_Left__c != null) ? access.Usage_Qty_Left__c : aSubscription.dUnitsPurchased);

											if(access.Usage_Unlimited__c)
											{
													aSubscription.dUnitsLeft = -999;
													aSubscription.dUnitsPurchased = -999;
											}
						}
					}else
						aSubscription.bShowUsage = false;

					bRefreshEnabled = false;

					IEC_Subscription_History__c oSubscriptionHistory = subscriptionHistoryByName.get(subscription.Name);
					if (oSubscriptionHistory != null) {
						// Load the last accepted T&C attachment Id
						Terms_and_Conditions__c oTnC = getLastAcceptedTermsAndConditionBySubscriptionName.get(oSubscriptionHistory.Subscription_Number__c);
						aSubscription.sAttachTermsId = (oTnC != null ? (String)oTnC.Attachments.get(0).Id : '');
						//dtLastAcceptedTnC = (oTnC != null ? oTnC.CreatedDate : null);
					}

					// Check if this rateplan and its audience type match the current user type
					if (IECProductManager.isProductAudienceAllowedForClientType(subscription.Product_Rate_Plan_Information__r.Related_Product_Information__r.Product_Audience__c, clientType)) {
						aSubscription.idSelectedRatePlanInfo = subscription.Product_Rate_Plan_Information__c;
						aSubscription.idSelectedProdInfo = subscription.Product_Rate_Plan_Information__r.Related_Product_Information__c;
					}

					Boolean isRatePlanAvail = false;
					if(aSubscription.idSelectedRatePlanInfo != null && isRatePlanAvailable.containsKey(aSubscription.idSelectedRatePlanInfo)) isRatePlanAvail =true;

					aSubscription.bDisplayRenewBtn = !subscription.Zuora__AutoRenew__c
							&& (oSubscriptionHistory == null || oSubscriptionHistory.Action__c != 'Trial')
							&& subscription.Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Renewal_Window__c != null
							&& subscription.Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Renewal_Window__c != '0'
							&& subscription.Zuora__SubscriptionEndDate__c.addDays((-1 * integer.valueOf(subscription.Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Renewal_Window__c))) <= Date.today()
							&& subscription.Zuora__SubscriptionEndDate__c >= Date.today()
							&& ((aSubscription.idSelectedRatePlanInfo != null) ? isRatePlanAvail : false);

					//Get InvoiceItem related to the subscription
					Invoice_Item__c invoiceItem = invoiceItemBySFSubscriptionName.get(subscription.Name);
					if (invoiceItem != null) {
						//Get the Invoice related to InvoiceItem
						//invoice = IECSubscriptionManager.getInvoiceById(invoiceItem.Invoice__c);
						aSubscription.invoice = invoiceById.get(invoiceItem.Invoice__c);

						if (aSubscription.invoice != null) {
							if (aSubscription.invoice.Zuora__Payments__r != null && aSubscription.invoice.Zuora__Payments__r.size() > 0) {
								//Get the Payment related to the Invoice
								aSubscription.payment = aSubscription.invoice.Zuora__Payments__r.get(0);
							}
							else {
								//No payment could mean "ICH" so, the invoice should be hidden
								// (Modification to show INVOICE even under ICH, 2014-07-11)
								//invoice = null;
								aSubscription.payment = null;
							}
						} // END if (invoice != null)
					} // END if (invoiceItemResult != null)

					//check if there are upgrades available for the subscription rate plan
					aSubscription.bDisplayUpgradeBtn = false;
					Product_Rate_Plan_Information__c ratePlanInfoUpgrades = ratePlanInformationUpgradesBySourceRatePlan.get(subscription.Product_Rate_Plan_Information__c);

					if(ratePlanInfoUpgrades != null){ aSubscription.bDisplayUpgradeBtn = true; }
					/*aSubscription.bDisplayUpgradeBtn = true;*/
					if(ratePlanInfoUpgrades != null && ratePlanInfoUpgrades.Related_Product_Information__c != null && ratePlanInfoUpgrades.Related_Product_Information__r.Related_Product_Category__r.Button_Type__c == IECConstants.ProductCategory_ButtonType_GetAQuote){
						aSubscription.bDisplayUpgradeBtn = false;
					}

					//Set the Product Name and Rate Plan Name
					for(Zuora__SubscriptionProductCharge__c spc : subscription.Zuora__Subscription_Product_Charges__r){
						if(!spc.Zuora__ProductName__c.contains('Tax') && !spc.Zuora__ProductName__c.contains('Shipping')){
							aSubscription.productName = spc.Zuora__ProductName__c;
							aSubscription.ratePlanName = spc.Zuora__RatePlanName__c;
							break;
						}
					}

					lstActiveSubscriptions.add(aSubscription);
				}

			}
		}
		catch(Exception ex) { addErrorMessage(ex.getMessage() + '<br />' + ex.getStackTraceString()); }

		return null;
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
		catch(Exception ex) { addErrorMessage(ex.getMessage()); }

		return null;
	}

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Handles the change of auto renew flag on subscription
	public Pagereference toggleAutoRenew() {
		try {

			Zuora__Subscription__c subscriptionObj = subscriptionMap.get(subsId);

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

				//Hides the confirmation popup and trigger the refres of the page
				//bDisplayPopUp = false;
				bRefreshEnabled = true; //The refresh is required to reflect the new data record synched from Zuora

				//Show feedback to the user telling the page will refresh in few seconds.
				addInfoMessage('The page should refresh in 10 seconds');

				//Add entry to user log
				addEntryToUserLog((String)loggedCustomer.RelatedUser.Id, subscriptionObj.Name, 'Changed Auto Renew flag', String.valueOf(!newAutoRenewValue), String.valueOf(newAutoRenewValue));

			}
		}
		catch(Exception ex) { addErrorMessage(ex.getMessage()); }

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

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Refreshes the page. Usualy it will be called after an update of Zuora records to refresh synched records in SF
	public Pagereference refreshPage() {

		Pagereference prActiveSubs = Page.IEC_DataStatisticsSubscriptions;
		//prActiveSubs.getParameters().put(IECConstants.PARAM_SUBSCRIPTION_NAME, IECUtil.EncryptEncodeParameter(subscriptionObj.Name));
		prActiveSubs.setRedirect(true);
		return prActiveSubs;
	}

	/**
	 * Sends the customer to the upgrade page
	 */
	public Pagereference upgrade() {

		Zuora__Subscription__c subscriptionObj = subscriptionMap.get(subscriptionToUpgradeId);
		try {
			if (subscriptionObj == null) throw new IECApplicationException(Label.IEC_Error_SubscriptionNotFound);

				Pagereference pgRef = Page.IECUpgrade;
				pgRef.getParameters().put(IECConstants.PARAM_SUBSCRIPTION_ID, IECUtil.EncryptEncodeParameter(subscriptionObj.Id));
				pgRef.setRedirect(true);
				return pgRef;
		}
		catch (Exception ex) { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage())); return null; }
	}

	/**
	 * Add into the shopping cart a new instance of the product rate plan already expired
	 */
	public Pagereference renewRatePlan() {
		try {
				Pagereference pgRef = Page.IECRenew;
				pgRef.getParameters().put(IECConstants.PARAM_SUBSCRIPTION_ID, IECUtil.EncryptEncodeParameter(subscriptionToRenewId));
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


}
