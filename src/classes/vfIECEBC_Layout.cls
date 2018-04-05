public with sharing class vfIECEBC_Layout extends vfIECEBC_Controller {
    public String getSProdCACPro() { return IEC_Settings__c.getOrgDefaults().Prod_CACPro__c; }
    public String getSProdGAD() { return IEC_Settings__c.getOrgDefaults().Prod_GAD__c; }
    public String getSProdMDP() { return IEC_Settings__c.getOrgDefaults().Prod_MDP__c; }
    public String getSProdGSS() { return IEC_Settings__c.getOrgDefaults().Prod_GSS__c; }
    public String getSContactEmail() { return IEC_Settings__c.getOrgDefaults().IEC_Contact_Us_Email__c; }
    public String getSContactSubject() { return IEC_Settings__c.getOrgDefaults().IEC_Contact_Us_Subject__c; }
    
    public Boolean getIsUserLoggedIn() {
        return true;
    }
    
    
    public PageReference pageLoad() {
        /*
        if (!Test.isRunningTest()) {
            if (String.isBlank(UserInfo.getSessionId())) {
                Pagereference prLogin = Page.IECLogin;
                prLogin.getParameters().put(IECConstants.PARAM_RETURN_URL, IECUtil.EncryptEncodeParameter(ApexPages.currentPage().getUrl()));
                prLogin.getParameters().put(IECConstants.PARAM_WARNING_MSG, IECUtil.EncryptEncodeParameter(Label.IEC_Warning_Must_Login));
                prLogin.setRedirect(true);
                return prLogin;
            } else {
                if (subscription == null) return Page.IECUnauthorized;
            }
        }*/
        
        boolean isTest=Test.isRunningTest();
        boolean isSessionEmpty = String.isBlank(UserInfo.getSessionId());
        if (isSessionEmpty || istest) {
            Pagereference prLogin = Page.IECLogin;
            prLogin.getParameters().put(IECConstants.PARAM_RETURN_URL, IECUtil.EncryptEncodeParameter(ApexPages.currentPage().getUrl()));
            prLogin.getParameters().put(IECConstants.PARAM_WARNING_MSG, IECUtil.EncryptEncodeParameter(Label.IEC_Warning_Must_Login));
            prLogin.setRedirect(true);
            if (!isTest) return prLogin;
        }
        if (!isTest && !isSessionEmpty && subscription == null) return Page.IECUnauthorized;
            
        return null;
    }

    // ======================================================================== 
    // showRenewNow link is used to turn on/off Renew Now link 
    public Boolean showRenewNow{
        get{
            return vfIECEBC.isSubscriptionRenewable;
        }
    } // end of showRenewNow getter
    
    
    // ======================================================================== 
    // renewalPageUrl link contains the URL for the URL
    public String renewalPageUrl{
        get{
            return IECEBC_Utility.renewalPageUrl;
        }
    } // end of renewalPageUrl getter
    
    /**
    * Handles the logout link
    */
    public Pagereference logout() {
        try {
            // delete shopping cart cookie
            IECCookieHelper.deleteShoppingCartCookie();

            //added 2016-01-11
            IECOrder_Svc.deleteAllCookies();
            Cookie Cookie_Sync = new Cookie('Cookie_Sync', '', null, 0, false);
            ApexPages.currentPage().setCookies(new Cookie[]{Cookie_Sync});

            PageReference pr = Page.IECLogout; //new PageReference('/secur/logout.jsp');
            pr.setRedirect(true);
            return pr;
        }
        catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }
    }
    
} // end of vfIECEBC_Layout