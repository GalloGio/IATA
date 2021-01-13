/**
 * Description: This class contains the controller for the Visualforce page (File Delivery)
 * Author: Samy Saied
 * Version: 1.0
 * History:
 */

public without sharing class vfIECGSS extends IECPageController {
	//Controller to handle the subscription information
	public vfIECSubscriptionInfo ctrSubsInfo { get; set; }
	public List<Zuora__Subscription__c> lstListActiveSubscriptions 	{get; private set;}

	public String sSelectedSubscriptionName {get; set;}
	public String sProductCode {get; set;}
	public String sApplicationTitle {
		get {
			if (sProductCode == IECConstants.ProductCategory_SF_GSS)
				return IECConstants.ProductCategory_Zuora_GSS;
			else if (sProductCode == IECConstants.ProductCategory_SF_MDP)
				return IECConstants.ProductCategory_Zuora_MDP;
			else if (sProductCode == IECConstants.ProductCategory_SF_CACWEB)
				return IECConstants.ProductCategory_Zuora_CACWEB;
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
	public vfIECGSS() {
		try {
			// Retrieve page parameters
			String sParamProductCode = ApexPages.currentPage().getParameters().get(IECConstants.PARAM_PRODUCT_CODE);
			sProductCode = IECUtil.DecodeDecryptParameter(sParamProductCode);

			//Initilize subscription component
			ctrSubsInfo = new vfIECSubscriptionInfo();
			ctrSubsInfo.loggedCustomer = loggedCustomer;
			ctrSubsInfo.sSelectedSubscriptionName = null;
			ctrSubsInfo.sApplicationName = sProductCode;

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
			} else {
				// Validate Logged in user profile and ensure profile is complete
				validUserProfile();

				// Make sure to validate user access to application subscription
				ctrSubsInfo.validateLandingAccess();

				// if no access, redirect to the unauthorized page
				if (!ctrSubsInfo.hasPageAccess) return Page.IECUnauthorized;
				//Query for the active subscription list related to the current logged user
				lstListActiveSubscriptions = getActiveSubscriptionsList();

				//If only one subscription is available, then pre-select it and navigate to the details page
				if (lstListActiveSubscriptions != null && lstListActiveSubscriptions.size() == 1) {
					sSelectedSubscriptionName = lstListActiveSubscriptions.get(0).Name;
					return selectSubscription();
				}
			}
		} catch (Exception ex) {
			addErrorMessage(ex.getMessage() + '<br />' + ex.getStackTraceString());
		}
		return null;
	}

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Returns the active subscriptions for the current logged user
	public List < Zuora__Subscription__c > getActiveSubscriptionsList() {
		try {
			//Find the billing account for logged user
			// *** IECCUstomer is based on the IECUserManager current logged user
			IECCustomer currentCustomer = IECCustomer.getCurrentIECCustomer();
			if (currentCustomer == null) return null;

			//Return the active subscriptions related to the billing account of logged user
			System.debug('getActiveSubscriptionsList - currentCustomer.RelatedBillingAccount ' + currentCustomer.RelatedBillingAccount);
			if (currentCustomer.RelatedBillingAccount != null) return IECSubscriptionManager.getActiveSubscriptionsByBillingAccountAndProductCategory(currentCustomer.RelatedBillingAccount.Id, sProductCode);
		} catch (Exception ex) {
			addErrorMessage(ex.getMessage());
		}

		return null;
	}

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Handles the selection of one subscription (by subscriptionID) and query for its details
	public Pagereference selectSubscription() {
		try {
			if (sSelectedSubscriptionName!=null && !String.isEmpty(sSelectedSubscriptionName)) {
				Pagereference pgRef;
				if (sProductCode == IECConstants.ProductCategory_SF_GSS)
					pgRef = Page.IECFDDetail;
				else if (sProductCode == IECConstants.ProductCategory_SF_MDP)
					pgRef = Page.IECFDDetail;
				else if (sProductCode == IECConstants.ProductCategory_SF_CACWEB)
					pgRef = Page.IEC_CACWDetail;

				pgRef.getParameters().put(IECConstants.PARAM_SUBSCRIPTION_NAME, IECUtil.EncryptEncodeParameter(sSelectedSubscriptionName));
				pgRef.getParameters().put(IECConstants.PARAM_PRODUCT_CODE, IECUtil.EncryptEncodeParameter(sProductCode));
				pgRef.setRedirect(true);
				return pgRef;
			}
		}
		catch(Exception ex) {
			addErrorMessage(ex.getMessage());
		}

		return null;
	}
}
