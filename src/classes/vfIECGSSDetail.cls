/**
	* Description: This class contains the controller for the Visualforce page (File Delivery - Subscrption Detail)
	* Author: Samy Saied
	* Version: 1.0
	* History:
	*   20160106-sl: added dynamic height for the wrapping box surrounding Service Details block
	*/

public without sharing class vfIECGSSDetail extends IECPageController {
	final Integer SINGLE_ROW_HEIGHT = 20; // used for serviceDetailBoxHeight
	final Integer EMPTY_BOX_HEIGHT = 450; // used for serviceDetailBoxHeight

	//Controller to handle the subscription information
	public vfIECSubscriptionInfo ctrSubsInfo {get; set;}
	public integer iSubscriptionDaysLeft {
		get {
			if (subscriptionObj != null) {
				integer days = Date.today().daysBetween(subscriptionObj.Zuora__SubscriptionEndDate__c);
				return (days < 0) ? 0 : days;
			}
			return -1;
		}
	}


	//Display variables

	// serviceDetailBoxHeight is used for calculating the height of the box surrounding Service Detail in IECFDDetail.page
	public integer serviceDetailBoxHeight
	{ // this is to make the height of wrapping box dynamic.
		get{
			Integer numOfRecs = (ctrSubsInfo == null || ctrSubsInfo.lstFileSubscriptionDetail == null)
								? 1 : ctrSubsInfo.lstFileSubscriptionDetail.size();
			return EMPTY_BOX_HEIGHT + (numOfRecs * SINGLE_ROW_HEIGHT);
		}
		private set;
	}

	public Zuora__Subscription__c subscriptionObj {
		get {
			return ctrSubsInfo.oSubscription;
		}
	}

	public GSS_Subscription_Detail__c oGSSDetail {
		get {
			return ctrSubsInfo.oFileSubscriptionDetail;
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

	public String sProductCode {get; set;}
	public String sApplicationTitle {
		get {
			if (sProductCode == IECConstants.ProductCategory_SF_GSS)
				return IECConstants.ProductCategory_Zuora_GSS;
			else if (sProductCode == IECConstants.ProductCategory_SF_MDP)
				return IECConstants.ProductCategory_Zuora_MDP;
			else
				return '';
		}
	}

	public String sApplicationTitleUpperCase {
		get {
			return sApplicationTitle.toUpperCase();
		}
	}

	/**
	 * Constructor Method
	 **/
	public vfIECGSSDetail() {
		try {
			// Retrieve page parameters
			String sParamProductCode = ApexPages.currentPage().getParameters().get(IECConstants.PARAM_PRODUCT_CODE);
			sProductCode = IECUtil.DecodeDecryptParameter(sParamProductCode);

			//Initilize subscription component
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
