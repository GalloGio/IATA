/**
* @description This is the common controller shared between all VF pages for CACWeb
*
*
**/
public class vfIEC_CACW extends IECPageController{

/**
* Constructor Method
**/
	public vfIEC_CACW() {
		try {
			lstErrorMessage = new list<string>();
			bViewMode = true;

			// Retrieve page parameters
			String sParamProductCode = ApexPages.currentPage().getParameters().get(IECConstants.PARAM_PRODUCT_CODE);
			sProductCode = IECUtil.DecodeDecryptParameter(sParamProductCode);

			//Initialize subscription component
			ctrSubsInfo = new vfIECSubscriptionInfo();
			ctrSubsInfo.loggedCustomer = loggedCustomer;
			ctrSubsInfo.sSelectedSubscriptionName = null;
			ctrSubsInfo.sApplicationName = sProductCode;

			// check if Subscription Name was passed as a parameter
			String sParamSubscriptionName = ApexPages.currentPage().getParameters().get(IECConstants.PARAM_SUBSCRIPTION_NAME);
			if (sParamSubscriptionName!=null && !String.isEmpty(sParamSubscriptionName))
				ctrSubsInfo.sSelectedSubscriptionName = IECUtil.DecodeDecryptParameter(sParamSubscriptionName);
			else
				ctrSubsInfo.sSelectedSubscriptionName = null;
		}
		catch (Exception ex) {
			addErrorMessage(ex.getMessage());
		}
	}

	public vfIECSubscriptionInfo ctrSubsInfo {get; set;}
	public list<String> lstErrorMessage   {get; set;}

	public Boolean bViewMode {get; set;}
	public String sProductCode {get; set;}

	public String sProductName {
		get {
			return (subscriptionObj != null) ? subscriptionObj.Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Display_Name__c : '';
		}
	}

	public String sApplicationTitle {
		get {
			if (sProductCode == IECConstants.ProductCategory_SF_GSS)			return IECConstants.ProductCategory_Zuora_GSS;
			else if (sProductCode == IECConstants.ProductCategory_SF_MDP)		return IECConstants.ProductCategory_Zuora_MDP;
			else if (sProductCode == IECConstants.ProductCategory_SF_CACWEB)	return IECConstants.ProductCategory_Zuora_CACWEB;
			else 																return '';
		}
	}
	public String sApplicationTitleUpperCase {
		get { return sApplicationTitle.toUpperCase();}
	}

	public Zuora__Subscription__c subscriptionObj {
		get {
			return ctrSubsInfo.oSubscription;
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
			}
			else {
				// Validate Logged in user profile and ensure profile is complete
				validUserProfile();

				// Make sure to validate user access to application subscription
				ctrSubsInfo.validateSubscriptionAccess();

				// if no access, redirect to the unauthorized page
				if (!ctrSubsInfo.hasPageAccess)
					return Page.IECUnauthorized;
			}
		}
		catch(Exception ex) {
			addErrorMessage(ex.getMessage() + '<br />' + ex.getStackTraceString());
		}
		return null;
	}
}
