/**
 * This vfIECEBC class provided collection static methods related to eBroadcast feature
 * 
 * Change log:
 *   20160809-sl: add ebcSetup
 *
 **/

public class vfIECEBC {
	
	public static final String EBC_PRODUCT_RATE_PLAN_SUBSCRIPTION_TYPE_PAY_AS_YOU_GO = 'Pay-As-You-Go';
	
	public static User usr = [Select ContactId, Contact.AccountId from User where id = :Userinfo.getUserid()];
	public static Zuora__CustomerAccount__c billingAccount {
		get {
			if (billingAccount == null) {
				billingAccount = [Select Id, eBroadcast_Trusted_Sender__c, eBroadcast_Email_Balance__c, Zuora__Account__c  
									, ClientType__c
									, Contact__r.IATA_Code__c
									from Zuora__CustomerAccount__c 
									where Contact__c = :usr.ContactId LIMIT 1];
			}
			
			return billingAccount;
		}
		private set;
	}
	public static EBC_Preference__c pref {
		get {
			if (pref == null) {
				System.debug(billingAccount);
				
				pref = [
					Select Id, Default_From_Name__c, Default_Google_Analytics_Tracker__c,
						Monthly_Account_Status__c, Notify_On_Send__c, PrimaryContact_Address__c,
						PrimaryContact_Company__c, PrimaryContact_Email__c,
						PrimaryContact_Job_Title__c, PrimaryContact_Name__c, PrimaryContact_Phone__c
					From EBC_Preference__c
					Where Billing_Account__c = :billingAccount.Id
					LIMIT 1
				];
			}
			return pref;
		}
		private set;
	}
	
	public static Zuora__Subscription__c subscription {
		get {
			if (subscription == null) {
				List<Zuora__Subscription__c> subsList = [SELECT Id, Name
														 	 , Zuora__AutoRenew__c
															 , Zuora__SubscriptionEndDate__c
															 , Zuora__NextRenewalDate__c
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
					subscription = subsList[0];
				}
			}
			
			return subscription;
		}
		private set;
	}
	
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
	public static zqu__ProductRatePlan__c  productRatePlan {
		get { 
			if (productRatePlan == null) { 
				//System.debug(subscriptionInfo.oSubscription.Product_Rate_Plan_Information__r.Product_Rate_Plan__c);
				//productRatePlan = [Select Id, Name, EBC_SubscriptionType__c, EBC_Currency_Cost_Per_Email__c, EBC_PrePaid_Emails__c From zqu__ProductRatePlan__c  Where Id = :subscriptionInfo.oSubscription.Product_Rate_Plan_Information__r.Product_Rate_Plan__c];
				productRatePlan = subscription.Product_Rate_Plan_Information__r.Product_Rate_Plan__r;
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
	
	// =======================================================================-
	// ebcSetup return the only EBC_Setup records in the system
	// in case there is none (should not be the case), it return a blank record.
	public static EBC_Setup__c ebcSetup {
		get {
			if (ebcSetup==null)
			{
				List<EBC_Setup__c> ebcSetupList = [select Id, Name
								, Member_Email_Block_Product__c
								, Member_Prepaid_Product_Rate_Plan_01__c
								, Member_Prepaid_Product_Rate_Plan_02__c
								, Member_Prepaid_Product_Rate_Plan_03__c
								, Member_Prepaid_Product_Rate_Plan_04__c

								, Non_Member_Email_Block_Product__c
								, Non_Member_Prepaid_Product_Rate_Plan_01__c
								, Non_Member_Prepaid_Product_Rate_Plan_02__c
								, Non_Member_Prepaid_Product_Rate_Plan_03__c
								, Non_Member_Prepaid_Product_Rate_Plan_04__c

							from EBC_Setup__c
							order by CreatedDate
							limit 1];
				ebcSetup = (ebcSetupList.size()==1) ? ebcSetupList[0] : new EBC_Setup__c (Name = 'Blank');
			}
			return ebcSetup;
		}
		set;
	} // end of ebcSetup getter/setter
	
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