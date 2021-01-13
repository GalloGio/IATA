/**
 * This vfIECEBC class provided collection static methods related to eBroadcast feature
 *
 * Change log:
 *   20160826-sl: move ebcSetup out to IECEBC_Utility, add isSubscriptionRenewable
 *   20160923-sl: payment support: add queried fields from billingAccount, add rereadSubscription
 *   20160926-sl: change subscription getter to use ebcSubscriptionProductCharge and EBC_Setup
 *
 **/

public class vfIECEBC extends IECPageController {

	public static final String EBC_PRODUCT_RATE_PLAN_SUBSCRIPTION_TYPE_PAY_AS_YOU_GO = 'Pay-As-You-Go';
	public static final String EBC_PRODUCT_RATE_PLAN_SUBSCRIPTION_TYPE_PRE_PAID = 'Pre-Paid';


	public static User usr = [Select Id, ContactId, Contact.AccountId from User where id = :Userinfo.getUserid()];
	public static Zuora__CustomerAccount__c rereadBillingAccount()
	{
		billingAccount = null;
		return billingAccount;
	}

	// ========================================================================
	// current user's billingAccount
	public static Zuora__CustomerAccount__c billingAccount {
		get {
			if (billingAccount == null) {
			   billingAccount = [Select Id, Name
									, eBroadcast_Trusted_Sender__c
									, eBroadcast_Email_Balance__c
									, Zuora__Account__c
									, eBroadcast_Add_On_Access__c
									, eBroadcast_Add_On_Advanced_Reporting__c
									, eBroadcast_Storage__c
									, Zuora__DefaultPaymentMethod__c // text, e.g. Credit Card
									, Zuora__Default_Payment_Method__c // lookup
									, Zuora__Default_Payment_Method__r.Zuora__External_Id__c
									, Zuora__Default_Payment_Method__r.Zuora__CreditCardExpirationMonth__c
									, Zuora__Default_Payment_Method__r.Zuora__CreditCardExpirationYear__c
									, Zuora__Default_Payment_Method__r.Zuora__CreditCardHolderName__c
									, Zuora__Default_Payment_Method__r.Zuora__CreditCardMaskNumber__c
									, Zuora__Default_Payment_Method__r.Zuora__CreditCardType__c
									, Zuora__Default_Payment_Method__r.Zuora__Type__c
									, ICHCode__c
									, ClientType__c
									, Contact__c
									, Contact__r.Id
									, Contact__r.IATA_Code__c
									, Contact__r.Name
									, Contact__r.FirstName
									, Contact__r.LastName
									, Contact__r.Title
									, Contact__r.Phone
									, Contact__r.Email
									//, Zuora__BillToName__c
									//, Zuora__BillToAddress1__c
									//, Zuora__BillToAddress2__c
									//, Zuora__BillToState__c
									//, Zuora__BillToPostalCode__c
									//, Zuora__BillToCountry__c
									//, Zuora__BillToWorkPhone__c
									//, Zuora__BillToWorkEmail__c
									from Zuora__CustomerAccount__c
									where Contact__c = :usr.ContactId LIMIT 1];
			}

			return billingAccount;
		}
		private set;
	}

	// ========================================================================
	// user preference for eBroadcast
	public static EBC_Preference__c pref {
		get {
			if (pref == null) {
				System.debug(billingAccount);

				pref = [
					Select Id, Default_From_Name__c
							, Default_Google_Analytics_Tracker__c
							,Monthly_Account_Status__c
							, Notify_On_Send__c
							, PrimaryContact_Address__c
							, PrimaryContact_Company__c
							, PrimaryContact_Email__c
							, PrimaryContact_Job_Title__c
							, PrimaryContact_Name__c
							, PrimaryContact_Phone__c
					From EBC_Preference__c
					Where Billing_Account__c = :billingAccount.Id
					LIMIT 1
				];
			}
			return pref;
		}
		private set;
	}


	// ========================================================================
	// rereadSubscription will force the getters to reread the subscription record from the database
	// this is relevant in the case of new purchase related to EBC Subscription
	public static void rereadSubscription()
	{
		// nullify also subscription dependent properties, so getters will update them
		// start from the least dependent properties
		ebcSubscriptionProductCharge = null;
		subscription = null;
		productRatePlan = null;

	} // rereadSubscription


	// ========================================================================
	// EBC Subscription of the current user
	// this is the subscription related to the Pay As You Go or Prepaid Subscription Plan
	// that is currently active for this user.
	// new version: use SubcriptionProductCharge to search subscription related to EBC Product Rate Plan
	// with the new version, we can avoid using Subscription.Product_Rate_Plan_Information__r.Product_Rate_Plan__c
	// to get into the EBC Product Rate Plan.
	public static Zuora__Subscription__c subscription {
		get {
			if (subscription == null)
			{
				Zuora__SubscriptionProductCharge__c ebcSpc = ebcSubscriptionProductCharge;
				if (ebcSpc != null && ebcSpc.Zuora__Subscription__c != null)
				{
					subscription = ebcSpc.Zuora__Subscription__r;
				}
			}

			return subscription;
		}
		private set;
	} // end of subscription


	/*
	// OLD version: rely on the assumption that the Zuora__Subscription__r.Product_Rate_Plan_Information__c point to the correct EBC Product Rate Plan.

	private static Zuora__Subscription__c subscriptionOLD {
		get {
			if (subscriptionOLD == null) {
				List<Zuora__Subscription__c> subsList = [SELECT Id, Name
														 	 , Zuora__AutoRenew__c
															 , Zuora__NextRenewalDate__c
															 , Zuora__Status__c
															 , Zuora__SubscriptionEndDate__c
															 , Zuora__TermEndDate__c
															 , Product_Rate_Plan_Information__r.Product_Rate_Plan__c
															 , Product_Rate_Plan_Information__r.Product_Rate_Plan__r.Id
															 , Product_Rate_Plan_Information__r.Product_Rate_Plan__r.Name
															 , Product_Rate_Plan_Information__r.Product_Rate_Plan__r.zqu__Description__c
															 , Product_Rate_Plan_Information__r.Product_Rate_Plan__r.EBC_SubscriptionType__c
															 , Product_Rate_Plan_Information__r.Product_Rate_Plan__r.EBC_Cost_Per_Email__c
															 , Product_Rate_Plan_Information__r.Product_Rate_Plan__r.EBC_Currency_Cost_Per_Email__c
															 , Product_Rate_Plan_Information__r.Product_Rate_Plan__r.EBC_PrePaid_Emails__c
														 FROM Zuora__Subscription__c
														 WhERE (Zuora__CustomerAccount__c = :billingAccount.Id)
															 AND (
																 (Zuora__SubscriptionEndDate__c >=  TODAY)
																 OR (Zuora__SubscriptionEndDate__c = NULL)
																 OR (Product_Rate_Plan_Information__r.Product_Rate_Plan__r.EBC_SubscriptionType__c = : EBC_PRODUCT_RATE_PLAN_SUBSCRIPTION_TYPE_PAY_AS_YOU_GO)
															 )
															 AND (Zuora__SubscriptionStartDate__c <=  TODAY)
															 AND (Zuora__Status__c = 'Active')
															 AND (Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Name = :IECConstants.ProductCategory_SF_EBROADCAST)
														 ORDER BY Zuora__Status__c ASC
															 , Zuora__SubscriptionEndDate__c DESC NULLS FIRST
															 , Zuora__SubscriptionStartDate__c DESC
														 LIMIT 1
														];
				if (subsList.size() > 0) {
					subscriptionOLD = subsList[0];
				}
			}

			return subscriptionOLD;
		}
		private set;
	} // end of subscription
	*/


	// ========================================================================
	// current Zuora__SubscriptionProductCharge__c list related to the current EBC Subscription
	// retrieved based on the expected product rate plan for EBC Subscription
	// the process: search for the ebcPrepaidSubscription first, if there is none, then search for pay as you go.
	private static Zuora__SubscriptionProductCharge__c ebcSubscriptionProductCharge
	{
		get{
			if (ebcSubscriptionProductCharge == null)
			{
				Zuora__SubscriptionProductCharge__c ebcSpc = null;
				List<Zuora__SubscriptionProductCharge__c> spcList = ebcPrepaidSubscriptionProductChargeList;
				if (spcList.size() > 0) {
					ebcSpc = spcList[0];
				} else {
					spcList = ebcPayAsYouGoSubscriptionProductChargeList;
					if (spcList.size() > 0) {
						ebcSpc = spcList[0];
					}
				}
				ebcSubscriptionProductCharge = ebcSpc;
			}

			return ebcSubscriptionProductCharge;
		}
		private set;
	} // end of ebcSubscriptionProductCharge


	// prepaid subscription use the Subscription TermEndDate
	// note that Zuora__Subscription__r.Product_Rate_Plan_Information__r.Product_Rate_Plan__r fields are included to maintain compatibility with older code
	private static List<Zuora__SubscriptionProductCharge__c> ebcPrepaidSubscriptionProductChargeList
	{
		get{
			Set<Id> ebcProductRatePlanIdSet = new Set<Id>();
			ebcProductRatePlanIdSet.addAll(IECEBC_Utility.ebcNonMemberProductRatePlanIdList);
			ebcProductRatePlanIdSet.addAll(IECEBC_Utility.ebcMemberProductRatePlanIdList);
			ebcProductRatePlanIdSet.addAll(IECEBC_Utility.ebcECommerceProductRatePlanIdList);

			List<Zuora__SubscriptionProductCharge__c> subscriptionProductChargeList = [select Id
				, Zuora__Product__c, Zuora__Product__r.Name
				, Zuora__Price__c
				, Zuora__ProductDescription__c
				, Zuora__ProductName__c
				, Product_Rate_Plan_Charge__c
				, Product_Rate_Plan_Charge__r.Name
				, Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__c
				, Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.Id
				, Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.Name
				, Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.zqu__Description__c
				, Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.EBC_SubscriptionType__c
				, Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.EBC_Cost_Per_Email__c
				, Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.EBC_Currency_Cost_Per_Email__c
				, Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.EBC_PrePaid_Emails__c
				, Zuora__EffectiveEndDate__c

				, Zuora__Subscription__c
				, Zuora__Subscription__r.Id
				, Zuora__Subscription__r.Name
				, Zuora__Subscription__r.Zuora__AutoRenew__c
				, Zuora__Subscription__r.Zuora__NextRenewalDate__c
				, Zuora__Subscription__r.Zuora__Status__c
				, Zuora__Subscription__r.Zuora__SubscriptionEndDate__c
				, Zuora__Subscription__r.Zuora__TermEndDate__c
				, Zuora__Subscription__r.Zuora__Zuora_Id__c
				, Zuora__Subscription__r.Product_Rate_Plan_Information__r.Product_Rate_Plan__c
				, Zuora__Subscription__r.Product_Rate_Plan_Information__r.Product_Rate_Plan__r.Id
				, Zuora__Subscription__r.Product_Rate_Plan_Information__r.Product_Rate_Plan__r.Name
				, Zuora__Subscription__r.Product_Rate_Plan_Information__r.Product_Rate_Plan__r.zqu__Description__c
				, Zuora__Subscription__r.Product_Rate_Plan_Information__r.Product_Rate_Plan__r.EBC_SubscriptionType__c
				, Zuora__Subscription__r.Product_Rate_Plan_Information__r.Product_Rate_Plan__r.EBC_Cost_Per_Email__c
				, Zuora__Subscription__r.Product_Rate_Plan_Information__r.Product_Rate_Plan__r.EBC_Currency_Cost_Per_Email__c
				, Zuora__Subscription__r.Product_Rate_Plan_Information__r.Product_Rate_Plan__r.EBC_PrePaid_Emails__c

				from Zuora__SubscriptionProductCharge__c
				//where Zuora__Subscription__c = : subscription.Id
				//	and Product_Rate_Plan_Charge__c = : productRatePlan.Id];

				 Where ( Zuora__Subscription__r.Zuora__CustomerAccount__c = :billingAccount.Id)
					 AND (
						 (Zuora__Subscription__r.Zuora__TermEndDate__c >=  TODAY)
						 OR (Zuora__Subscription__r.Zuora__TermEndDate__c = NULL)

						 //OR (Product_Rate_Plan_Information__r.Product_Rate_Plan__r.EBC_SubscriptionType__c = : EBC_PRODUCT_RATE_PLAN_SUBSCRIPTION_TYPE_PAY_AS_YOU_GO)
					 )
					 AND (Zuora__Subscription__r.Zuora__SubscriptionStartDate__c <=  TODAY)
					 AND (Zuora__Subscription__r.Zuora__Status__c = 'Active')
					 //AND (Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Name = :IECConstants.ProductCategory_SF_EBROADCAST)

					 AND Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.Id in :  ebcProductRatePlanIdSet
				 ORDER BY Zuora__Subscription__r.Zuora__Status__c ASC
					 , Zuora__Subscription__r.Zuora__TermEndDate__c DESC NULLS FIRST
					 , Zuora__Subscription__r.Zuora__TermStartDate__c DESC
				 ];


			//subscriptionProductCharge = (subscriptionProductChargeList.size() == 0) ? null : subscriptionProductChargeList[0];
			return subscriptionProductChargeList;
		}
	} // end ebcPrepaidSubscriptionProductChargeList getter



	// the pay as you go subscription ignores the subscriptionTermEndDate
	// note that Zuora__Subscription__r.Product_Rate_Plan_Information__r.Product_Rate_Plan__r fields are included to maintain compatibility with older code
	private static List<Zuora__SubscriptionProductCharge__c> ebcPayAsYouGoSubscriptionProductChargeList
	{
		get{
			Set<Id> ebcProductRatePlanIdSet = new Set<Id>();
			ebcProductRatePlanIdSet.add(IECEBC_Utility.ebcSetup.Member_Pay_As_You_Go_Plan__c);
			ebcProductRatePlanIdSet.add(IECEBC_Utility.ebcSetup.Non_Member_Pay_As_You_Go_Plan__c);

			List<Zuora__SubscriptionProductCharge__c> subscriptionProductChargeList = [select Id
				, Zuora__Product__c, Zuora__Product__r.Name
				, Zuora__Price__c
				, Zuora__ProductDescription__c
				, Zuora__ProductName__c
				, Product_Rate_Plan_Charge__c
				, Product_Rate_Plan_Charge__r.Name
				, Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__c
				, Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.Id
				, Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.Name
				, Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.zqu__Description__c
				, Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.EBC_SubscriptionType__c
				, Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.EBC_Cost_Per_Email__c
				, Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.EBC_Currency_Cost_Per_Email__c
				, Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.EBC_PrePaid_Emails__c
				, Zuora__EffectiveEndDate__c

				, Zuora__Subscription__c
				, Zuora__Subscription__r.Id
				, Zuora__Subscription__r.Name
				, Zuora__Subscription__r.Zuora__AutoRenew__c
				, Zuora__Subscription__r.Zuora__NextRenewalDate__c
				, Zuora__Subscription__r.Zuora__Status__c
				, Zuora__Subscription__r.Zuora__SubscriptionEndDate__c
				, Zuora__Subscription__r.Zuora__TermEndDate__c
				, Zuora__Subscription__r.Zuora__Zuora_Id__c
				, Zuora__Subscription__r.Product_Rate_Plan_Information__r.Product_Rate_Plan__c
				, Zuora__Subscription__r.Product_Rate_Plan_Information__r.Product_Rate_Plan__r.Id
				, Zuora__Subscription__r.Product_Rate_Plan_Information__r.Product_Rate_Plan__r.Name
				, Zuora__Subscription__r.Product_Rate_Plan_Information__r.Product_Rate_Plan__r.zqu__Description__c
				, Zuora__Subscription__r.Product_Rate_Plan_Information__r.Product_Rate_Plan__r.EBC_SubscriptionType__c
				, Zuora__Subscription__r.Product_Rate_Plan_Information__r.Product_Rate_Plan__r.EBC_Cost_Per_Email__c
				, Zuora__Subscription__r.Product_Rate_Plan_Information__r.Product_Rate_Plan__r.EBC_Currency_Cost_Per_Email__c
				, Zuora__Subscription__r.Product_Rate_Plan_Information__r.Product_Rate_Plan__r.EBC_PrePaid_Emails__c

				from Zuora__SubscriptionProductCharge__c
				//where Zuora__Subscription__c = : subscription.Id
				//	and Product_Rate_Plan_Charge__c = : productRatePlan.Id];

				 Where ( Zuora__Subscription__r.Zuora__CustomerAccount__c = :billingAccount.Id)
					 AND (Zuora__Subscription__r.Zuora__SubscriptionStartDate__c <=  TODAY)
					 AND (Zuora__Subscription__r.Zuora__Status__c = 'Active')
					 //AND (Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Name = :IECConstants.ProductCategory_SF_EBROADCAST)

					 AND Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.Id in :  ebcProductRatePlanIdSet
				 ORDER BY Zuora__Subscription__r.Zuora__Status__c ASC
					 , Zuora__Subscription__r.Zuora__TermEndDate__c DESC NULLS FIRST
					 , Zuora__Subscription__r.Zuora__TermStartDate__c DESC
				 ];

			return subscriptionProductChargeList;
		}
	} // end ebcPayAsYouGoSubscriptionProductChargeList getter



	// ========================================================================
	// return true if the subscription can still be renewed
	// this is used to show the renewal link
	public static Boolean isSubscriptionRenewable
	{
		get{
			Integer renewalWindows = (IECEBC_Utility.ebcSetup.Renewal_Window__c == null) ? 0 : Integer.valueOf(IECEBC_Utility.ebcSetup.Renewal_Window__c);

			Boolean result = ( (subscription != null)
								&& (subscription.Zuora__Status__c == 'Active')
								&& (subscription.Product_Rate_Plan_Information__r.Product_Rate_Plan__r.EBC_SubscriptionType__c == EBC_PRODUCT_RATE_PLAN_SUBSCRIPTION_TYPE_PRE_PAID)
								&& (subscription.Zuora__NextRenewalDate__c >= Date.today())
								&& (subscription.Zuora__NextRenewalDate__c <= Date.today().addDays(renewalWindows))
								);
			return result;
		}
		//private set;
	} // end of isSubscriptionRenewable getter


	/*
	public static vfIECSubscriptionInfo subscriptionInfo {
		get {
			if (subscriptionInfo == null) {
				subscriptionInfo = new vfIECSubscriptionInfo();
				subscriptionInfo.loggedCustomer = IECCustomer.getCurrentIECCustomer();
				subscriptionInfo.sApplicationName = sProductCode;
			}

			return subscriptionInfo;
		}
		set;
	}
*/

	// ========================================================================
	// EBC Product Rate Plan, should we one of the EBC Subscription Rate Plans
	// (pay as you go, and those prepaids, as defined in the EBC_Setup)
	public static zqu__ProductRatePlan__c  productRatePlan {
		get {
			if (productRatePlan == null) {
				//System.debug(subscriptionInfo.oSubscription.Product_Rate_Plan_Information__r.Product_Rate_Plan__c);
				//productRatePlan = [Select Id, Name, EBC_SubscriptionType__c, EBC_Currency_Cost_Per_Email__c, EBC_PrePaid_Emails__c From zqu__ProductRatePlan__c  Where Id = :subscriptionInfo.oSubscription.Product_Rate_Plan_Information__r.Product_Rate_Plan__c];
				//productRatePlan = subscription.Product_Rate_Plan_Information__r.Product_Rate_Plan__r;
				System.debug(ebcSubscriptionProductCharge);
				System.debug(ebcSubscriptionProductCharge.Product_Rate_Plan_Charge__r);
				System.debug(ebcSubscriptionProductCharge.Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r);
				productRatePlan = ebcSubscriptionProductCharge.Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r;
			}

			return productRatePlan;
		}
		set;
	}
	/*
	public vfIECSubscriptionInfo ctrSubsInfo  {
		get {
			return subscriptionInfo;
		}
	}*/

	public static String sProductCode {
		get {
			return IECConstants.ProductCategory_SF_EBROADCAST;
		}
	}


	/*
	public Pagereference pageLoad() {
		if (String.isBlank(UserInfo.getSessionId())) {
			Pagereference prLogin = Page.IECLogin;
			prLogin.getParameters().put(IECConstants.PARAM_RETURN_URL, IECUtil.EncryptEncodeParameter(ApexPages.currentPage().getUrl()));
			prLogin.getParameters().put(IECConstants.PARAM_WARNING_MSG, IECUtil.EncryptEncodeParameter(Label.IEC_Warning_Must_Login));
			prLogin.setRedirect(true);
			return prLogin;
		} else {

		}
		throw new Controller_Exception('Session ID: ' + UserInfo.getSessionId());


		return null;
		// first check if the user is logged in
		try {
			if (IECUserManager.isUserLoggedIn() == false) {
				Pagereference prLogin = Page.IECLogin;
				prLogin.getParameters().put(IECConstants.PARAM_RETURN_URL, IECUtil.EncryptEncodeParameter(ApexPages.currentPage().getUrl()));
				prLogin.getParameters().put(IECConstants.PARAM_WARNING_MSG, IECUtil.EncryptEncodeParameter(Label.IEC_Warning_Must_Login));
				prLogin.setRedirect(true);
				return prLogin;
			} else {
				// Validate Logged in user profile and ensure profile is complete
				validUserProfile();

				// Make sure to validate user access to application subscription
				ctrSubsInfo.validateAccess(new Set<String>{IECConstants.ProductCategory_SF_EBROADCAST});
				System.debug(ctrSubsInfo.hasPageAccess);

				// if no access, redirect to the unauthorized page

				if (!ctrSubsInfo.hasPageAccess) return Page.IECUnauthorized;
			}
		}
		catch(Exception ex) {
			addErrorMessage(ex.getMessage() + '<br />' + ex.getStackTraceString());
		}

		return null;
	}
*/

}
