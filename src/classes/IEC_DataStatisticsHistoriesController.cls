public class IEC_DataStatisticsHistoriesController extends IECPageController {

	public List<ZuoraSubscription_DTO> lstInactiveSubscriptions 	{get; set;}
	public String idSelectedRatePlanInfo 							{get; set;}
	//public String similarProdSubscriptionId 						{get; set;}

	Map<String,Zuora__Subscription__c> subscriptionMap;

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Executes when the page is loaded
	public Pagereference pageLoad() {
		try {

			// first check if the user is logged in
			if (IECUserManager.isUserLoggedIn() == false) {
				Pagereference prLogin = Page.IEC_Login;
				prLogin.getParameters().put(IECConstants.PARAM_RETURN_URL, ApexPages.currentPage().getUrl());
				prLogin.setRedirect(true);
				return prLogin;
			}
			else {
				// Validate Logged in user profile and ensure profile is complete
				validUserProfile();

				String clientType = IECUserManager.getClientType();

				lstInactiveSubscriptions = new List<ZuoraSubscription_DTO>();
				subscriptionMap = new Map<String,Zuora__Subscription__c>();

				//Query for the active subscription list related to the current logged user
				List<Zuora__Subscription__c> lstListInactiveSubscriptions = getInactiveSubscriptionsList();

				set<String> subscriptionNumbers = new set<String>();
				set<String> prodRatePlanInfomationIds = new set<String>();
				set<Id> prodRatePlanInfoIds = new set<Id>();
				set<Id> orderItemIds = new set<Id>();
				set<Id> prodCategoryIds = new set<Id>();

				if(lstListInactiveSubscriptions != null && lstListInactiveSubscriptions.size() > 0)
					for(Zuora__Subscription__c subscription : lstListInactiveSubscriptions){
						subscriptionMap.put(subscription.Id,subscription);
						subscriptionNumbers.add(subscription.Name);
						prodRatePlanInfomationIds.add(subscription.Product_Rate_Plan_Information__c);
						prodRatePlanInfoIds.add(subscription.Product_Rate_Plan_Information__c);
						orderItemIds.add(subscription.OrderItemId__c);
						prodCategoryIds.add(subscription.Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__c);
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
				for(Invoice_Item__c ii : invoiceItemBySFSubscriptionName.values()){
					invoiceIds.add(ii.Invoice__c);
				}

				// Get SWAP if the client type doesn't match using the Swap Configuration (Source -> Target)
				Map<ID, Product_Rate_Plan_Information__c> targetRatePlans = IECSubscriptionManager.getTargetSwappedRatePlans(prodRatePlanInfoIds, clientType);

				// Get SWAP if the client type doesn't match using the Swap Configuration (Target -> Source)
				Map<ID, Product_Rate_Plan_Information__c> sourceRatePlans = IECSubscriptionManager.getSourceSwappedRatePlans(prodRatePlanInfoIds, clientType);

				//Determines the availability of the product rate plan according to the specified user type
				Map<Id,Boolean> isRatePlanAvailable = IECProductManager.isRatePlanAvailable(prodRatePlanInfoIds, clientType);

				//Get the Invoice related to InvoiceItem
				Map<Id,Zuora__ZInvoice__c> invoiceById = IECSubscriptionManager.getInvoiceById(invoiceIds);

				//Set the order item Subscribe to Zuora check
				Map<Id,Boolean> orderItemZuoraSubscribeById = new OrderItem_Sel().getOrderItemZuoraSubscribeById(orderItemIds);

				Map<Id, Boolean> isProductCategoryAvailable = IECProductManager.isProductCategoryAvailable(prodCategoryIds);

				if(lstListInactiveSubscriptions != null && lstListInactiveSubscriptions.size() > 0){
					for(Zuora__Subscription__c subscription : lstListInactiveSubscriptions){
						ZuoraSubscription_DTO aSubscription = new ZuoraSubscription_DTO();

						//If the zuora subscription OrderItemId__c field in not null make sure that the related product to the item have the field IEC_Subscribe_to_Zuora__c set to true
						if(subscription.OrderItemId__c != null){
							Boolean subscribeToZuora = orderItemZuoraSubscribeById.get(subscription.OrderItemId__c);
							if(subscribeToZuora != null && !subscribeToZuora) continue;
						}
						//set the Subscription
						aSubscription.zSubscription = subscription;

						//Set the remaining days calculated from today to subscriptionEndDate
						aSubscription.iSubscriptionDaysLeft = Date.today().daysBetween(subscription.Zuora__SubscriptionEndDate__c);
						if (aSubscription.iSubscriptionDaysLeft < 0) aSubscription.iSubscriptionDaysLeft = 0;

						//Get the list of Product Access by Subscription
						List<IEC_Product_Access__c> productAccess = productAccessBySubscriptionNumbers.get(subscription.Name);
						if (productAccess != null && productAccess.size() > 0) {
							aSubscription.bShowUsage = true;
							aSubscription.dUnitsPurchased =
								aSubscription.dUnitsConsumed =
								aSubscription.dUnitsLeft = 0;

							for (IEC_Product_Access__c access : productAccess) {
								aSubscription.dUnitsPurchased += ((access.Usage_Qty_Start__c != null) ? access.Usage_Qty_Start__c : 0);
								aSubscription.dUnitsConsumed += (((access.Usage_Qty_Start__c != null) ? access.Usage_Qty_Start__c : 0)
									- ((access.Usage_Qty_Left__c != null) ? access.Usage_Qty_Left__c : 0));

								// Only count units left if they are still valid
								if (access.Effective_Start_Date__c <= DateTime.now()
									&& access.Effective_End_Date__c >= DateTime.now()
									&& access.Active__c)
								aSubscription.dUnitsLeft += ((access.Usage_Qty_Left__c != null) ? access.Usage_Qty_Left__c : 0);				}
						}
						else
							aSubscription.bShowUsage = false;

						IEC_Subscription_History__c oSubscriptionHistory = subscriptionHistoryByName.get(subscription.Name);
						if (oSubscriptionHistory != null) {
							// Load the last accepted T&C attachment Id
							Terms_and_Conditions__c oTnC = getLastAcceptedTermsAndConditionBySubscriptionName.get(oSubscriptionHistory.Subscription_Number__c);
							aSubscription.sAttachTermsId = (oTnC != null ? (String)oTnC.Attachments.get(0).Id : '');
						}

						/**
						 * Retrieves subscription history and determines whether to display the New button
						 * and gets the selected rate plan according to the current user type
						*/
						// Check if this rateplan and its audience type match the current user type
						if (IECProductManager.isProductAudienceAllowedForClientType(subscription.Product_Rate_Plan_Information__r.Related_Product_Information__r.Product_Audience__c, clientType)) {
							aSubscription.idSelectedRatePlanInfo = subscription.Product_Rate_Plan_Information__c;
						}
						// Else get swapped rate plan
						else {
							if (targetRatePlans != null && !targetRatePlans.isEmpty()) {
								aSubscription.idSelectedRatePlanInfo = targetRatePlans.values().get(0).Id;
							}
							else {
								// if no swap rate plans is available, then no active rate plan is available
								aSubscription.idSelectedRatePlanInfo  = (sourceRatePlans != null && !sourceRatePlans.isEmpty()) ? sourceRatePlans.values().get(0).Id : null;
							}
						}

						aSubscription.bDisplaySimProdBtn = isProductCategoryAvailable.get(subscription.Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__c);
						Boolean ratePlanAvailable = false;
						if(isRatePlanAvailable.containsKey(subscription.Product_Rate_Plan_Information__c)) ratePlanAvailable = true;

						//Display add to Cart button
						aSubscription.bDisplayNewBtn = (aSubscription.idSelectedRatePlanInfo != null && (oSubscriptionHistory == null || oSubscriptionHistory.Action__c != 'Trial')) ? ratePlanAvailable : false;

						//Get InvoiceItem related to the subscription
						Invoice_Item__c oInvoiceItem = invoiceItemBySFSubscriptionName.get(subscription.Name);
						if (oInvoiceItem != null) {
							//Get the Invoice related to InvoiceItem
							aSubscription.invoice = IECSubscriptionManager.getInvoiceById(oInvoiceItem.Invoice__c);

							if (aSubscription.invoice != null) {
								if (aSubscription.invoice.Zuora__Payments__r != null && aSubscription.invoice.Zuora__Payments__r.size() > 0) {
									//Get the Payment related to the Invoice
									aSubscription.payment = aSubscription.invoice.Zuora__Payments__r.get(0);
								}
								else {
									//No payment could mean "ICH" so, the invoice should be hidden
									aSubscription.invoice = null;
									aSubscription.payment = null;
								}
							} // END if (invoice != null)
						} // END if (invoiceItemResult != null)


						lstInactiveSubscriptions.add(aSubscription);
					}
				}
			}
		}
		catch(Exception ex) {
			system.debug('ex ' + ex.getLineNumber() + ' ' + ex.getStackTraceString());
			addErrorMessage(ex.getMessage());
		} return null;
	}

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
		catch(Exception ex) { addErrorMessage(ex.getMessage());}

		return null;
	}

	/**
	 * Add into the shopping cart a new instance of the product rate plan already expired
	 */
	public Pagereference addToCart() {

		try{

			Product2 p = [
				SELECT Id, IEC_Parent_Product__c, SAP_Material_Number__c , IEC_Product_Rate_Plan_Information__c, Name, IEC_Parent_Product__r.Name
				FROM Product2
				WHERE IEC_Product_Rate_Plan_Information__c = :idSelectedRatePlanInfo
				LIMIT 1
			];

			list<Id> productsIds = new List<Id>();
			productsIds.add(p.Id);

			List<Product2> sibblingProducts = [
				SELECT SAP_Material_Number__c FROM Product2 WHERE IEC_Parent_Product__c = :p.IEC_Parent_Product__c AND Id != :p.Id
			];
			Set<String> sibblingProductNumbers = new Set<String>();
			for(Product2 prod : sibblingProducts){
				sibblingProductNumbers.add(prod.SAP_Material_Number__c);
			}

			String productNumber2Add = p.SAP_Material_Number__c;
			Map<String, Decimal> cookieContent = IECOrder_Svc.getItemsInCookie();

			//Validate another sub-product does not exist in the cart
			Boolean sibblingInCart = false;
			for(String item : cookieContent.keySet()){
				if(sibblingProductNumbers.contains(item)){
					sibblingInCart = true; break;
				}
			}

			if(!sibblingInCart){
				return IECOrder_Svc.addCartToCookie(p.SAP_Material_Number__c, 1);
			}else{
				//--- Sibbling already in Cart
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, String.format(Label.Item_already_in_your_cart, new List<String> {p.IEC_Parent_Product__r.Name}))); return null;
			}

		}
		catch (Exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + ' - ' +e.getStackTraceString())); return null;
		}

	}

	/**
	 * Navigate to the product category with similar product category
	 */
	//public Pagereference navigateSimilarProducts() {
	//	try {
	//		Zuora__Subscription__c subscriptionObj = subscriptionMap.get(similarProdSubscriptionId);
	//		Pagereference pgRef = Page.IECProductViewer;
 // 			pgRef.getParameters().put(IECConstants.PARAM_PRODUCT_CODE, IECUtil.EncryptEncodeParameter(subscriptionObj.Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Name));
	//	    pgRef.setRedirect(true);
	//	    return pgRef;
	//	}
	//	catch (Exception ex) {
	//		addErrorMessage(ex.getMessage());
	//	}
	//	return null;
	//}

}
