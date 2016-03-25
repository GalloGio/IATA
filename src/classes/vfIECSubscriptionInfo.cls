public without sharing class vfIECSubscriptionInfo {
	
	public String sApplicationName	{get; set;}
		//IECConstants.ProductCategory_SF_GAD
		//IECConstants.ProductCategory_SF_CACPRO
		//IECConstants.ProductCategory_SF_CACFREE
	
	
	public Integer iUsageLeft				{get; set;}
	public Integer iDaysLeft				{get; set;}
	public Integer iUnitsConsumed			{get; set;}
	public Date dtAccessEndDate				{get; set;}
	
	public decimal dUnitsPurchased			{get; set;}
	public decimal dUnitsConsumed			{get; set;}

	public String sProdCACPro 				{get; set;}
	public Boolean hasPageAccess			{get; set;}
	
	public String sDenyReason				{get; set;}


	public IEC_Subscription_History__c oSubscriptionHistory	{get; private set;}
	public Zuora__Subscription__c oSubscription {get; private set;}
	public List<Product_Rate_Plan_Information__c> lstRatePlanInfoUpgrades { get; private set; }
	public Date dtRenewalAccessibleDate			{get; private set;}
	public boolean bDisplayRenewBtn				{get; set;} 
    public boolean bDisplayUpgradeBtn			{get; set;}
	public ID idSelectedRatePlanInfo			{get; set;} // Initially set from Subscription History, but then swapped if applicable
	public ID idSelectedProdInfo				{get; set;} // Initially set from Subscription History, but then swapped if applicable

	public IECCustomer loggedCustomer { get; set; }
	
	public String sSubscriptionName { 
		get { return oSubscription == null ? '' : oSubscription.Name;} }
		 
	
	public Date	dtSubscriptionEndDate {
		get {return oSubscription == null ? null : oSubscription.Zuora__SubscriptionEndDate__c;} }
		
	
    
    public Boolean validateAccess(Set<String> allowedApplicationName) {
        if (!allowedApplicationName.contains(sApplicationName)) {
            sDenyReason = Label.IEC_Error_No_Application_Access;
            hasPageAccess = false;
            
            return false;
        }
        
        return validateAccess();
    }
	public Boolean validateAccess() {
		
		sDenyReason = '';
		bDisplayRenewBtn = false;
		bDisplayUpgradeBtn = false;
		idSelectedRatePlanInfo = null;
		idSelectedProdInfo = null;
		dUnitsPurchased = 0;
		dUnitsConsumed = 0;
		
		oSubscription = IECSubscriptionManager.getSubscriptionByProductCategory(loggedCustomer.RelatedBillingAccount.Id, sApplicationName);
		Integer iValidation = IECApplicationsManager.ContactHasAccessToProductCategory(loggedCustomer.RelatedContact.Id, sApplicationName);
		iDaysLeft = IECApplicationsManager.getDaysLeftForAccessByProductCategory(loggedCustomer.RelatedContact.Id, sApplicationName);
		dtAccessEndDate = IECApplicationsManager.getLastEnddateOfProductAccess(loggedCustomer.RelatedContact.Id, sApplicationName);

		if (iValidation == -1) {
			sDenyReason = Label.IEC_Error_No_Application_Access;
			hasPageAccess = false;
		}
		else if (iValidation == 0) {
			sDenyReason = Label.IEC_Error_No_Usage;
			hasPageAccess = false;
		}
		else {
			hasPageAccess = true;
			iUsageLeft = iValidation;
		}		

		// if customer has a subscription for the application
		if (oSubscription != null) {
			
			loadSubscriptionHistory();
			
			//Get Usage data
			List<IEC_Product_Access__c> productAccess = IECApplicationsManager.getProductAccessByContact(loggedCustomer.RelatedContact.Id, sApplicationName);
			
			if (productAccess != null && productAccess.size() > 0) {
				for (IEC_Product_Access__c access : productAccess) {
					dUnitsPurchased += ((access.Usage_Qty_Start__c != null) ? access.Usage_Qty_Start__c : 0);
					dUnitsConsumed += (access.Usage_Qty_consumed__c != null ? access.Usage_Qty_consumed__c : 0);
				}
			}
		}		

		return hasPageAccess;
	}

	/**
	 * Retrieves subscription history and determines whether to display the New button
	 * and gets the selected rate plan according to the current user type
	 */
	public void loadSubscriptionHistory() {
		try {
			if (oSubscription != null) {
				oSubscriptionHistory = IECSubscriptionManager.getSubscriptionHistoryByName(oSubscription.Name);
				
				// Check if this rateplan and its audience type match the current user type
				if (IECProductManager.isProductAudienceAllowedForClientType(oSubscription.Product_Rate_Plan_Information__r.Related_Product_Information__r.Product_Audience__c, IECUserManager.getClientType())) {
					idSelectedRatePlanInfo = oSubscription.Product_Rate_Plan_Information__c;
					idSelectedProdInfo = oSubscription.Product_Rate_Plan_Information__r.Related_Product_Information__c;
				}

				// check if there are upgrades available for the subscription rate plan
				lstRatePlanInfoUpgrades = IECProductManager.getRatePlanInformationUpgradesBySourceRatePlan(oSubscription.Product_Rate_Plan_Information__c, IECUserManager.getClientType());
				bDisplayUpgradeBtn = !lstRatePlanInfoUpgrades.isEmpty();
			}
								
			dtRenewalAccessibleDate = oSubscription.Zuora__SubscriptionEndDate__c.addDays((-1 * integer.valueOf(oSubscription.Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Renewal_Window__c)));
								
			bDisplayRenewBtn = !oSubscription.Zuora__AutoRenew__c
				&& (oSubscriptionHistory == null || oSubscriptionHistory.Action__c != 'Trial')
				&& oSubscription.Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Renewal_Window__c != null
				&& oSubscription.Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Renewal_Window__c != '0'
				&& oSubscription.Zuora__SubscriptionEndDate__c >= Date.today()
				&& ((idSelectedRatePlanInfo != null) ? IECProductManager.isRatePlanAvailable(idSelectedRatePlanInfo, IECUserManager.getClientType()) : false);
		}
		catch (Exception ex) {
			//addErrorMessage(ex.getMessage() + '<br />' + ex.getStackTraceString());
			throw ex;
		}
	}

	/**
	 * Sends the customer to the Renew page
	 */
	public Pagereference renewRatePlan() {

		try {
  			Pagereference pgRef = Page.IECRenew;
  			pgRef.getParameters().put(IECConstants.PARAM_SUBSCRIPTION_ID, IECUtil.EncryptEncodeParameter(oSubscription.Id));
  			pgRef.getParameters().put(IECConstants.PARAM_PRODINFO_ID, IECUtil.EncryptEncodeParameter(idSelectedProdInfo));
  			pgRef.getParameters().put(IECConstants.PARAM_RATEPLANINFO_ID, IECUtil.EncryptEncodeParameter(idSelectedRatePlanInfo));
		    pgRef.setRedirect(true); 
		    return pgRef;
		}
		catch (Exception ex) {
			//addErrorMessage(ex.getMessage() + '<br />' + ex.getStackTraceString());
			return null;
		}

	}
	
	/**
	 * Sends the customer to the upgrade page
	 */
	public Pagereference upgrade() {

		try {
			if (oSubscription == null)
				throw new IECApplicationException(Label.IEC_Error_SubscriptionNotFound);
			
  			Pagereference pgRef = Page.IECUpgrade;
  			pgRef.getParameters().put(IECConstants.PARAM_SUBSCRIPTION_ID, IECUtil.EncryptEncodeParameter(oSubscription.Id));
		    pgRef.setRedirect(true); 
		    return pgRef;
		}
		catch (Exception ex) {
			//addErrorMessage(ex.getMessage() + '<br />' + ex.getStackTraceString());
			return null;
		}
	}

}