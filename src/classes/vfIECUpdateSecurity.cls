public without sharing class vfIECUpdateSecurity extends IECPageController {

    public list<String> errorMessage            {get; set;}
    
	public Contact oContact {
    	get {
    		return (loggedCustomer != null) ? loggedCustomer.RelatedContact : null;
    	}
	}
    
    public Integer iRegistrationStep            {get; set;}
    public String sAccountName					{get; set;}
    
    public Integer constCONTACTINFO             {get {return 1;}}
    public Integer constUPDATECONFIRMATION      {get {return 2;}}
    
    public static String sOldPassword			{get; set;}
    public static String sNewPassword1			{get; set;}
    public static String sNewPassword2			{get; set;}
    public Boolean bShowResetPopup				{get; set;}
    public Boolean bBothEqual					{get; set;}
    public String sPasswordMessage				{get; set;}
    public String sUsername						{get; set;}
    
    public static List<LoginHistoryInstance> lLoginHistory	{get; set;}
    
    
    /*********************************************************************************************************************/
    /* Constructor Methods
    /*********************************************************************************************************************/
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Controller class constructor
    public vfIECUpdateSecurity() {
    	bBothEqual = true;
        errorMessage = new list<string>();
        sUserName = Userinfo.getUserEmail();
        getLoginHistory();
        iRegistrationStep = constCONTACTINFO;
    }


    /*********************************************************************************************************************/
    /* Cuostom methods
    /*********************************************************************************************************************/
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Update the calculated variables used in the page.
    public PageReference pageLoad() {
        try {
            // first check if the user is logged in
            if (IECUserManager.isUserLoggedIn() == false) {
                //Pagereference prLogin = Page.IECLogin;
                //prLogin.getParameters().put(IECConstants.PARAM_RETURN_URL, IECUtil.EncryptEncodeParameter(ApexPages.currentPage().getUrl()));
                //prLogin.getParameters().put(IECConstants.PARAM_WARNING_MSG, IECUtil.EncryptEncodeParameter(Label.IEC_Warning_Must_Login));
                Pagereference prLogin = Page.IEC_Login;
                prLogin.getParameters().put(IECConstants.PARAM_RETURN_URL, ApexPages.currentPage().getUrl());
                //prLogin.getParameters().put(IECConstants.PARAM_WARNING_MSG, IECUtil.EncryptEncodeParameter(Label.IEC_Warning_Must_Login));
                prLogin.setRedirect(true);
                return prLogin;
            }
        }
        catch(Exception ex) {
            addErrorMessage('Error: ' + ex.getMessage());
            if (Test.isRunningTest())
                throw ex;
        }

        return null;
    }
    


	/********************************************************************************************
	* Magage Password Reset
	********************************************************************************************/
	public void getLoginHistory() {
		
		lLoginHistory = new List<LoginHistoryInstance>();
		
		List<LoginHistory> historyList = [Select Status, SourceIp, LoginTime, Id, Platform, Browser From LoginHistory Where UserId =: Userinfo.getUserId() order by LoginTime desc limit 50];
		
		for (LoginHistory lh : historyList) {
			LoginHistoryInstance newLH = new LoginHistoryInstance();
			
			newLH.Browser = lh.Browser;
			newLH.LoginTime = lh.LoginTime;
			newLH.Status = lh.Status;
			newLH.SourceIp = lh.SourceIp;
			newLH.Platform = lh.Platform;
			
			lLoginHistory.add(newLH);
		}
	}


	public Boolean getErrorsPresent(){
    	return ApexPages.hasMessages(ApexPages.Severity.ERROR);
	}


	/********************************************************************************************
	* Magage Password Reset
	********************************************************************************************/
	
    public Pagereference closeResetPopup() {
    	bShowResetPopup = false;
    	iRegistrationStep = constCONTACTINFO;
    	return null;
    }
    
    public Pagereference showResetPopUp() {
    	bShowResetPopup = true;
    	iRegistrationStep = constCONTACTINFO;
    	return null;
    }
    
     public PageReference applyNewPassword() {
     	
     	if (sOldPassword == null || sOldPassword == '') {
     		sPasswordMessage = 'Current Password cannot be empty';
     		iRegistrationStep = constCONTACTINFO;
     		return null;
     	}

     	 if (sNewPassword1.length() < 5) {
     		sPasswordMessage = 'New password is too short. A minimun of 5 characters are required';
     		iRegistrationStep = constCONTACTINFO;
     		return null;
     	}
     	
     	bBothEqual = (sNewPassword1 == sNewPassword2);
     	PageReference result;
     	sPasswordMessage = '';
     	if (bBothEqual) {
     	
     		//Change password code here
     		result = Site.changePassword(sNewPassword1, sNewPassword2, sOldPassword);
     		bShowResetPopup = false;
     		iRegistrationStep = constUPDATECONFIRMATION;
     	}
     	else {
     		sPasswordMessage = 'New Password and Confirm Password are not matching';
     		iRegistrationStep = constCONTACTINFO;
     	}

     	
     	return null;
     }
	


}