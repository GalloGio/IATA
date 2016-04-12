public class vfIECEBC extends IECPageController {
    public vfIECSubscriptionInfo ctrSubsInfo  {
    	get {
    		if (ctrSubsInfo == null) {
		        ctrSubsInfo = new vfIECSubscriptionInfo(); 
		        ctrSubsInfo.loggedCustomer = loggedCustomer;
		        ctrSubsInfo.sApplicationName = sProductCode;
    		}

    		return ctrSubsInfo;
    	}
    	set;
    }

	public String sProductCode {
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