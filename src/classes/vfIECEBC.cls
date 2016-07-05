public class vfIECEBC extends IECPageController {
    public static User usr = [Select ContactId, Contact.AccountId from User where id = :Userinfo.getUserid()];
    public static Zuora__CustomerAccount__c billingAccount {
        get {
            if (billingAccount == null) {
                System.debug(usr);
                System.debug(usr.Contact);
                System.debug(usr.Contact.AccountId);
                billingAccount = [Select Id, eBroadcast_Trusted_Sender__c, eBroadcast_Email_Balance__c from Zuora__CustomerAccount__c where Contact__c = :usr.ContactId LIMIT 1];
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
    public static zqu__ProductRatePlan__c  productRatePlan {
        get {
            if (productRatePlan == null) {
	        	productRatePlan = [Select Id, Name, EBC_SubscriptionType__c, EBC_Currency_Cost_Per_Email__c, EBC_PrePaid_Emails__c From zqu__ProductRatePlan__c  Where Id = :subscriptionInfo.oSubscription.Product_Rate_Plan_Information__r.Product_Rate_Plan__c];
            }
            
            return productRatePlan;
        }
        set;
    }
    
    public vfIECSubscriptionInfo ctrSubsInfo  {
    	get {
    		return subscriptionInfo;
    	}
    }

	public static String sProductCode {
		get {
			return IECConstants.ProductCategory_SF_EBROADCAST;
		}
	}

    public Pagereference pageLoad() {
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
                
                // if no access, redirect to the unauthorized page

		        if (!ctrSubsInfo.hasPageAccess) return Page.IECUnauthorized;
			}
        }
        catch(Exception ex) {
            addErrorMessage(ex.getMessage() + '<br />' + ex.getStackTraceString());
        }

        return null;
    }
}