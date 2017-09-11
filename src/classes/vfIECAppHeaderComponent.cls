public with sharing class vfIECAppHeaderComponent {
	public String sApplicationTitle 					{get; set;}
	public vfIECSubscriptionInfo subscriptionInfoCtr 	{get; set;}
	public vfIECSavedFilters savedFiltersCtr			{get; set;} 
	public Boolean bShowSubscriptioninfo				{get; set;}
	public Boolean bShowSearchOptions					{get; set;}
	public Boolean bShowSavedFilters					{get; set;}
	private static DateTime dtLastUpdate				{get; set;}
	
    public String sProductCode {
        get { 
            if (sProductCode == null) {
                Cookie storedIECProductCode = ApexPages.currentPage().getCookies().get('IECProductCode');
                if (ApexPages.currentPage().getParameters().containsKey(IECConstants.PARAM_PRODUCT_CODE)) {
        			sProductCode = IECUtil.DecodeDecryptParameter(ApexPages.currentPage().getParameters().get(IECConstants.PARAM_PRODUCT_CODE));
                    storedIECProductCode = new Cookie('IECProductCode',sProductCode,null,-1,false);
                } else if (storedIECProductCode != null) {
                    sProductCode = (String)storedIECProductCode.getValue();
                }
                
                ApexPages.currentPage().setCookies(new Cookie[]{storedIECProductCode});
            }
            return sProductCode;
        }
        private set;
    }
    
	public DateTime dtDBLastUpdate {
		get {

			if (dtLastUpdate == null) {
				List<AMS_GDP_Batch__c> lstBtch = [SELECT Id, Batch_Name__c, Last_Sync_End_Date__c
				FROM AMS_GDP_Batch__c WHERE Batch_Name__c = 'Job 1: GDP Products - Account View'];

				return (lstBtch.size() > 0)
				? lstBtch.get(0).Last_Sync_End_Date__c
				: DateTime.newInstance(1999, 1, 1);
			}
			return dtDBLastUpdate;
		}
	}
	
	
	public vfIECAppHeaderComponent() {
		bShowSubscriptioninfo = true;
		bShowSearchOptions = false;
		bShowSavedFilters = false;
	}

	public void switchToSubscriptionInfo() {
		bShowSubscriptioninfo = true;
		bShowSearchOptions = false;
		bShowSavedFilters = false;
	}
	
	public void switchToSearchOptions() {
		bShowSubscriptioninfo = false;
		bShowSearchOptions = true;
		bShowSavedFilters = false;
	}
	
	public void switchToSavedFilters() {
		bShowSubscriptioninfo = false;
		bShowSearchOptions = false;
		bShowSavedFilters = true;
	}
	
	public Boolean isUserLoggedIn {
		get {
			return IECUserManager.isUserLoggedIn();
		}
		private set;
	}
	
	/**
	 * Handles the logout link
	 */
	public Pagereference logout() {
		try {
			// delete shopping cart cookie
			IECCookieHelper.deleteShoppingCartCookie();

			PageReference pr = Page.IECLogout; //new PageReference('/secur/logout.jsp');
			pr.setRedirect(true);
			return pr;
		}
		catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
			return null;
		}
	}
}