/**
 * Description:
 *
 * History:
 *   - 20160531-sl: EBC: ProductCategory_SF_EBROADCAST category does not use IEC_Product_Access record
 */


public without sharing class vfIECSubscriptionInfo {

	public String sApplicationName  {get; set;}
		//IECConstants.ProductCategory_SF_GAD
		//IECConstants.ProductCategory_SF_CACPRO
		//IECConstants.ProductCategory_SF_CACFREE


	public Integer iUsageLeft               {get; set;}
	public Integer iDaysLeft                {get; set;}
	public Integer iUnitsConsumed           {get; set;}
	public Date dtAccessEndDate             {get; set;}

	public decimal dUnitsPurchased          {get; set;}
	public decimal dUnitsConsumed           {get; set;}

	public String sProdCACPro               {get; set;}
	public Boolean hasPageAccess            {get; set;}

	public String sDenyReason               {get; set;}

	// Used when working with a product that has multiple subscription and have to select one before managing subscription
	public String sSelectedSubscriptionName {get; set;}
	public GSS_Subscription_Detail__c oFileSubscriptionDetail {
		get {
			return (lstFileSubscriptionDetail != null && lstFileSubscriptionDetail.size() > 0)
				? lstFileSubscriptionDetail.get(0) : null;
		}
	}
	public List<GSS_Subscription_Detail__c> lstFileSubscriptionDetail {get; private set;}

	public IEC_Subscription_History__c oSubscriptionHistory {get; private set;}
	public Zuora__Subscription__c oSubscription {get; private set;}
	public List<Product_Rate_Plan_Information__c> lstRatePlanInfoUpgrades { get; private set; }
	public Date dtRenewalAccessibleDate         {get; private set;}
	public boolean bDisplayRenewBtn             {get; set;}
	public boolean bDisplayUpgradeBtn           {get; set;}
	public ID idSelectedRatePlanInfo            {get; set;} // Initially set from Subscription History, but then swapped if applicable
	public ID idSelectedProdInfo                {get; set;} // Initially set from Subscription History, but then swapped if applicable

	public IECCustomer loggedCustomer { get; set; }

	public String sSubscriptionName {
		get { return oSubscription == null ? '' : oSubscription.Name;} }


	public Date	dtSubscriptionEndDate {
		get {return oSubscription == null ? null : oSubscription.Zuora__SubscriptionEndDate__c;} }

	// used to define how to display subscription end date line in the pull down menu
	public Boolean isNotEvergreen {
		get {
			Boolean result = true;
			//result = (oSubscription.Zuora__SubscriptionEndDate__c != null);
			result = (oSubscription.Zuora__TermSettingType__c != 'EVERGREEN');
			return result;
		}
	} // isNotEvergreen


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

		if ( sApplicationName == IECConstants.ProductCategory_SF_EBROADCAST )
		{ // EBROADCAST/EBC is a special case, set in the Zuora__ConsumerAccount instead of IEC_Product_Access
			hasPageAccess = IECApplicationsManager.isEbcAccessGrantedForContact(loggedCustomer.RelatedContact.Id);
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

			dtRenewalAccessibleDate = null;
			if ( oSubscription.Zuora__SubscriptionEndDate__c != null) {
				dtRenewalAccessibleDate = oSubscription.Zuora__SubscriptionEndDate__c.addDays((-1 * integer.valueOf(oSubscription.Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Renewal_Window__c)));
			}
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

	// Only used for products with multiple subscriptions possible and a choice need to be made before loading the full details
	public Boolean validateLandingAccess() {
		sDenyReason = '';
		bDisplayRenewBtn = false;
		bDisplayUpgradeBtn = false;
		idSelectedRatePlanInfo = null;
		idSelectedProdInfo = null;
		dUnitsPurchased = 0;
		dUnitsConsumed = 0;
		Integer iValidation = IECApplicationsManager.ContactHasAccessToProductCategory(loggedCustomer.RelatedContact.Id, sApplicationName);

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

		return hasPageAccess;
	}

	// Only used for products with multiple subscriptions, and after selecting a specific subscription
	public Boolean validateSubscriptionAccess() {
		sDenyReason = '';
		bDisplayRenewBtn = false;
		bDisplayUpgradeBtn = false;
		idSelectedRatePlanInfo = null;
		idSelectedProdInfo = null;
		dUnitsPurchased = 0;
		dUnitsConsumed = 0;

		// Deny access if there is no subscription selected
		if (String.IsBlank(sSelectedSubscriptionName)) {
			sDenyReason = Label.IEC_Error_Must_Select_Subscription;
			hasPageAccess = false;
			return hasPageAccess;
		}

		oSubscription = IECSubscriptionManager.getSubscriptionByName(sSelectedSubscriptionName);
		Integer iValidation = IECApplicationsManager.ContactHasAccessToSubscriptionName(loggedCustomer.RelatedContact.Id, sSelectedSubscriptionName);
		iDaysLeft = IECApplicationsManager.getDaysLeftForAccessBySubscriptionName(sSelectedSubscriptionName);
		dtAccessEndDate = IECApplicationsManager.getEnddateOfSubscriptionName(sSelectedSubscriptionName);

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
			List<IEC_Product_Access__c> productAccess = IECApplicationsManager.getProductAccessBySubscriptionNumber(sSelectedSubscriptionName);

			if (productAccess != null && productAccess.size() > 0) {
				for (IEC_Product_Access__c access : productAccess) {
					dUnitsPurchased += ((access.Usage_Qty_Start__c != null) ? access.Usage_Qty_Start__c : 0);
					dUnitsConsumed += (access.Usage_Qty_consumed__c != null ? access.Usage_Qty_consumed__c : 0);
				}
			}

			// if GSS or MDP Application load File Subscription Detail
			if (sApplicationName == IECConstants.ProductCategory_SF_GSS || sApplicationName == IECConstants.ProductCategory_SF_MDP) {
				loadFileSubscriptionDetails();
			}
		}

		return hasPageAccess;
	}

	/**
	 * Retrieves file subscription details
	 */
	public void loadFileSubscriptionDetails() {
		try {
			if (oSubscription != null) {
				lstFileSubscriptionDetail = IECSubscriptionManager.getFileSubscriptionDetailByName(oSubscription.Name, sApplicationName);
			}
		}
		catch (Exception ex) {
			throw ex;
		}
	}

	/**
	 * Save back file subscription details
	 */
	public void saveFileSubscriptionDetails() {
		try {
			if (lstFileSubscriptionDetail != null && lstFileSubscriptionDetail.size() > 0) {
				// Copy settings to other instances of the object
				if (lstFileSubscriptionDetail.size() > 1) {
					for (integer i = 1; i < lstFileSubscriptionDetail.size(); i++) {
						lstFileSubscriptionDetail.get(i).Calendar_Semi_Monthly_First_Option__c = oFileSubscriptionDetail.Calendar_Semi_Monthly_First_Option__c;
						lstFileSubscriptionDetail.get(i).Calendar_Semi_Monthly_Second_Option__c = oFileSubscriptionDetail.Calendar_Semi_Monthly_Second_Option__c;
						lstFileSubscriptionDetail.get(i).Calendar_Monthly_Option__c = oFileSubscriptionDetail.Calendar_Monthly_Option__c;
						lstFileSubscriptionDetail.get(i).Calendar_New_Submission_Effective_Date__c = oFileSubscriptionDetail.Calendar_New_Submission_Effective_Date__c;
						lstFileSubscriptionDetail.get(i).Calendar_Next_Submission_Date__c = oFileSubscriptionDetail.Calendar_Next_Submission_Date__c;
						lstFileSubscriptionDetail.get(i).Calendar_Weekly_Option__c = oFileSubscriptionDetail.Calendar_Weekly_Option__c;
						lstFileSubscriptionDetail.get(i).File_Name_Applies_on__c = oFileSubscriptionDetail.File_Name_Applies_on__c;
						lstFileSubscriptionDetail.get(i).File_Name_Custom_Prefix__c = oFileSubscriptionDetail.File_Name_Custom_Prefix__c;
						lstFileSubscriptionDetail.get(i).File_Name_Custom_Suffix__c = oFileSubscriptionDetail.File_Name_Custom_Suffix__c;
						lstFileSubscriptionDetail.get(i).File_Name_Prefix_Option__c = oFileSubscriptionDetail.File_Name_Prefix_Option__c;
						lstFileSubscriptionDetail.get(i).File_Name_Suffix_Option__c = oFileSubscriptionDetail.File_Name_Suffix_Option__c;
						lstFileSubscriptionDetail.get(i).FileRecipientEmail__c = oFileSubscriptionDetail.FileRecipientEmail__c;
						lstFileSubscriptionDetail.get(i).FileRecipientFirstName__c = oFileSubscriptionDetail.FileRecipientFirstName__c;
						lstFileSubscriptionDetail.get(i).FileRecipientLastName__c = oFileSubscriptionDetail.FileRecipientLastName__c;
						lstFileSubscriptionDetail.get(i).Trigger_File_Name__c = oFileSubscriptionDetail.Trigger_File_Name__c;
						lstFileSubscriptionDetail.get(i).FileRecipientSalutation__c = oFileSubscriptionDetail.FileRecipientSalutation__c;
						lstFileSubscriptionDetail.get(i).FileRecipientPhone__c = oFileSubscriptionDetail.FileRecipientPhone__c;
						lstFileSubscriptionDetail.get(i).FileRecipientJobTitle__c = oFileSubscriptionDetail.FileRecipientJobTitle__c;

					}
				}
				update lstFileSubscriptionDetail;
			}
		}
		catch (Exception ex) {
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
