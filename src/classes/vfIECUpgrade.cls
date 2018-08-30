/**
 * Page controller for the upgrade page
 */
public with sharing class vfIECUpgrade extends IECPageController {

  public Boolean bHasAllTCs {get; set;}
  public Boolean bHasAllAutoRenew {get; set;}

  public Boolean bExpandedBilling {get; set;}
  public Boolean bExpandedTCs {get; set;}
  public Boolean bExpandedAutoRenewal {get; set;}
  public Boolean bExpandedPaymentMethod {get; set;}
    public Boolean needToFillContactInfo { get; set; }
    public Boolean inEditContactInfo { get; set; }
    public Boolean isCountryFilled { get; set; }
    public IECAddress__c oBillingAddress { get; set; }
    public IECAddress__c oOriginalBillingAddress { get; set; }
    public Location__c oBillingLocation { get; set; }
    public IECVATUtil.VATConfiguration vatConfig { get; set; }
  public Decimal dICHMinAmount {get; private set;}
    public Decimal dCreditCardMaxAmount {get; private set;}
    
    public boolean displayPopUp {get; set;} 

  private String sSubscriptionId;
    public String sPurchaseOrder { get; set; }
  private List<Product_Rate_Plan_Information__c> lstRatePlanInfoUpgradeTargets;
  
  public Zuora__Subscription__c oSubscription { get; private set; }
  
  public Zuora__SubscriptionProductCharge__c subscriptionCharge {
    get {
      return (oSubscription.Zuora__Subscription_Product_Charges__r != null
        && oSubscription.Zuora__Subscription_Product_Charges__r.size() > 0)
          ? oSubscription.Zuora__Subscription_Product_Charges__r.get(0)
          : null;
    }
  }
  
  public Integer subscriptionChargeQuantity {
    get {
      return (oSubscription.Zuora__Subscription_Product_Charges__r != null)
          ? oSubscription.Zuora__Subscription_Product_Charges__r.size()
          : 0;
    }
  }
  
  public String sOriginalProductName {
    get {
      if (oRatePlanInfoSourceUpgrade != null) {
        return oRatePlanInfoSourceUpgrade.Related_Product_Information__r.Related_Product_Category__r.Display_Name__c
                    + ' - ' + oRatePlanInfoSourceUpgrade.Product_Rate_Plan__r.Name;
      }
      return '';
    }
  }
  
  public String sUpgradeProductName {
    get {
      if (oRatePlanInfoTargetUpgrade != null) {
        return oRatePlanInfoTargetUpgrade.Related_Product_Information__r.Related_Product_Category__r.Display_Name__c
                    + ' - ' + oRatePlanInfoTargetUpgrade.Product_Rate_Plan__r.Name;
      }
      return '';
    }
  }
  
    public Contact oContact {
      get {
        return (loggedCustomer != null) ? loggedCustomer.RelatedContact : null;
      }
  }
  public Account oAccount {
      get {
        return (loggedCustomer != null) ? loggedCustomer.RelatedAccount : null;
      }
  }  
  
  public Boolean upgradeSuccessful { get; private set; }
  public Boolean upgradePreviewSuccessful { get; private set; }
  public Boolean needToAcceptTnC { get; private set; }
  public String selectedUpgradeRatePlanZuoraID { get; set; }
  public String selectedUpgradeProductInfoID { get; set; }
  public String selectedUpgradeRatePlanInfoID { get; set; }
  public String autoRenewSubscription { get; set; }
  public Product_Rate_Plan_Information__c oRatePlanInfoSourceUpgrade { get; private set; }
  public Product_Rate_Plan_Information__c oRatePlanInfoTargetUpgrade { get; private set; }
  public List<UIUpgradableRatePlan> lstUIRatePlanInfoUpgradeTargets { get; set; }
  public Decimal subTotal { get; private set; }
//  public Decimal taxes { get; private set; }
  public Decimal taxCharge { get; private set; }
  public Decimal shippingCharge { get; private set; }
  public Decimal total { get; private set; }
  public Boolean hasICHCode { get; private set; }
  public String paymentTransactionNumber { get; private set; }
  public String sAppURL { get; private set; }
  public String defaultPaymentMethodId { get; private set; }
  public String selectedPaymentMethodType { get; set; }
  public String selectedCreditCardPaymentId { get; set; }
    public Boolean defaultPaymentMethodIsICH {
      get {
        return defaultPaymentMethodId == IECConstants.PaymentMethod_ICH_ZuoraID;
      }
    }
    public Boolean defaultPaymentMethodIsBankTransfer {
      get {
        return defaultPaymentMethodId == IECConstants.PaymentMethod_BankTransfer_ZuoraID;
      }
    }
    // existing credit card
    public List<IECZuoraHelper.PaymentMethod> paymentMethods { get; private set; }
    public Boolean hasPaymentMethods {
        get {
            return (paymentMethods != null && paymentMethods.size() > 0);
        }
    }
    public Boolean isPaymentAvailableWithCreditCard { get; private set; }
  public Boolean isPaymentAvailableWithICH { get; private set; }
  public Boolean isPaymentAvailableWithBankTransfer { get; private set; }
  public String sErrorMsgFromHPM { get; set; }
  public List<IECZuoraHelper.SubscriptionResult> listSubscriptionResultToDisplay { get; private set; }
  public Boolean hasSubscriptionResult {
        get {
            return (listSubscriptionResultToDisplay != null && listSubscriptionResultToDisplay.size() > 0);
        }
    }
    
    List<ISO_Country_State_DTO> lstCountryState;

    public List<SelectOption> lstISOCountries {
      get {
            return ISO_Country_State_Helper.getPicklistISOCountry(lstCountryState);
      }
    }
    
    public List<SelectOption> lstStateProvince {
        get {
            return ISO_Country_State_Helper.getPicklistISOState(lstCountryState, oBillingAddress.ISO_Country__c);
        }
    }
    
    ///////////////////////////////////////////////////////
    // properties for HPM (Hosted Payment Method) of Zuora
    public String iframeSrc { get; set; }
    public boolean hasConfigError { get; set; }
    private String errorMessage;
    private String errorCode;
    private String pageId; 
    private String apiSecurityKey;
    private String appUrl; 
    private String tenantId; 
    public String getExtraParamString() {
      String extraParam = ''; 
      Map<String, String> extraParameters = getExtraParameters(); 
      for ( String param : extraParameters.keySet() ) {
        extraParam += '&' + param + '=' + extraParameters.get( param ); 
      }
      return extraParam;
    } 
    //////////////////////////////////////////////////////////

  public Boolean hasRatePlanUpgradeSource {
    get {
      return (oRatePlanInfoSourceUpgrade != null);
    }
  }
  public Boolean hasUpgradesAvailable {
    get {
      return (lstRatePlanInfoUpgradeTargets != null && lstRatePlanInfoUpgradeTargets.size() > 0);
    }
  }
  
  // properties for the integration of the T&C component
  public String[] listProductInformationIDs { get; private set; }
  public String TC_COMPONENT_KEY {
    get {
      return 'componentTnC';
    }
  } 
  public VfIECTermsAndConditionsComponent oTnCComponentController {
    set;
    get {
      try {
        //get the map, then the component controller using the appropriate key
        if (getComponentControllerMap() != null) {
          VfIECTermsAndConditionsComponent mcc;
          mcc = (VfIECTermsAndConditionsComponent)getComponentControllerMap().get(TC_COMPONENT_KEY);
          if (mcc != null)
            return mcc;
        }

        VfIECTermsAndConditionsComponent component = new VfIECTermsAndConditionsComponent();
        setComponentControllerMap(TC_COMPONENT_KEY, component);
        return component;
      }
      catch (Exception ex) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        return null;
      }
    }
  }
  public Boolean hasAcceptedAllTnCs {
    get {
      
      Boolean bTemp = oTnCComponentController.hasAcceptedAllTCs;
      
      if (bTemp != bHasAllTCs) {
        bHasAllTCs = bTemp;
        
        if (bHasAllTCs) {
          bExpandedAutoRenewal = true;
          bExpandedBilling = false;
          bExpandedTCs = false;
        }
      }
      
      return bTemp;
    }
    set {
      // can only set the value if a Test Class is running
      if (Test.isRunningTest())
        hasAcceptedAllTnCs = value;
    }    
  }
  
  public Boolean hasFilledAutoRenewFlag {
    get {
      
      Boolean bTemp = !(autoRenewSubscription == null || autoRenewSubscription == 'null' || autoRenewSubscription == '');

      if (bTemp != bHasAllAutoRenew) {
        bHasAllAutoRenew = bTemp;
        
        if (bHasAllAutoRenew) {
          bExpandedAutoRenewal = false;
          bExpandedBilling = false;
          bExpandedTCs = false;
          bExpandedPaymentMethod = true;
        }
      }
  
      return bTemp;

    }
    set;    
  }

  /**
   * Constructor
   */
  public vfIECUpgrade() {
    try {
      // retreive the Subscription id from the URL
      String sParamSubscriptionId = ApexPages.currentPage().getParameters().get(IECConstants.PARAM_SUBSCRIPTION_ID);
      if (String.isNotBlank(sParamSubscriptionId))
        sSubscriptionId = IECUtil.DecodeDecryptParameter(sParamSubscriptionId);
      else
        throw new IECApplicationException(Label.IEC_Error_InvalidPageParameter);
        
      upgradeSuccessful = false;
      upgradePreviewSuccessful = false;
      needToAcceptTnC = false;
      
      bHasAllTCs = false;
      bHasAllAutoRenew = false;

      bExpandedBilling = true;
      bExpandedTCs = true;
      bExpandedAutoRenewal = true;
      bExpandedPaymentMethod = true;
      
            // Preload list of Countries/States
            lstCountryState = ISO_Country_State_Helper.getCountry_State();
    }
    catch (Exception ex) {
      addErrorMessage(ex.getMessage());
    }
  }
  
  /**
   * Action called after the page has been loaded
   */
  public Pagereference pageLoad() {
    try {
      
      // first check if the user is logged in
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
        
        // check if user can pay by ICH (logic was changed for determining access to ICH)
        hasICHCode = loggedCustomer.canPayByICH();
        
        if (loggedCustomer.AccountExistsInZuora)
                  defaultPaymentMethodId = (String)loggedCustomer.RelatedZuoraAccount.getValue('DefaultPaymentMethodId');
              else
                  defaultPaymentMethodId = null;
                  
                  
                  
                  
              // check if the customer needs to fill his contact information
              if (IECUserManager.hasAddress(loggedCustomer.RelatedContact.Id, IECConstants.IECAddress_AddressType_Billing)) {
                	// Retrieve existing billing location for this contact
                	oBillingLocation = Location_Sel.getLocationByContact(loggedCustomer.RelatedContact.Id, IECConstants.IECAddress_AddressType_Billing)[0];
                    
            	    List<IECAddress__c> lstAddresses = IECUserManager.getAddressByContact(loggedCustomer.RelatedContact.Id, IECConstants.IECAddress_AddressType_Billing);
					if (lstAddresses.size() > 0) {
						oBillingAddress = lstAddresses.get(0);
						// Clone the record to check later whether it is changed when saving
                		oOriginalBillingAddress = lstAddresses.get(0).clone(false, true);
                        isCountryFilled = String.isNotBlank(oBillingAddress.ISO_Country_Name__c); // Changed by Samy (2016-02-29) from Country__c
                        vatConfig = IECVATUtil.GetVATConfiguration(oBillingAddress.ISO_Country_Name__c); // Changed by Samy (2016-02-29) from Country__c
					}

                needToFillContactInfo = !IECUserManager.isBillingAddressFilled(loggedCustomer.RelatedContact.Id)
                  || !IECUserManager.isContactMandatoryFieldsFilled(loggedCustomer.RelatedContact, vatConfig);
              }
              else {
                    // customer does not have a billing address, so create a new one, and also create a new Location
                    oBillingLocation = new Location__c(
                    	Active__c = true
                    	, Account__c = loggedCustomer.RelatedAccount.Id
                    	, Contact__c = loggedCustomer.RelatedContact.Id
                    	, Type__c = IECConstants.IECAddress_AddressType_Billing
                    );
                oBillingAddress = new IECAddress__c();
                needToFillContactInfo = true;
                isCountryFilled = false;
                vatConfig = null;
              }
              inEditContactInfo = needToFillContactInfo;                  
        
        // load the subscription object by its id (received from parameter)
        oSubscription = IECSubscriptionManager.getSubscriptionById(sSubscriptionId);
        if (oSubscription == null)
          throw new IECApplicationException(Label.IEC_Error_SubscriptionNotFound + ' (by id)');
          
        autoRenewSubscription = (oSubscription.Zuora__AutoRenew__c ? 'true' : 'null');
        
        // load the Product Rate Plan Information to upgrade from
        List <Product_Rate_Plan_Information__c> lstTemp = IECProductManager.getProductRatePlansInformationById((String)oSubscription.Product_Rate_Plan_Information__c);
        if (lstTemp == null || lstTemp.size() == 0)
          throw new IECApplicationException(Label.IEC_Error_InvalidRatePlanId);
        else
          oRatePlanInfoSourceUpgrade = lstTemp.get(0);
        
        // get the upgrade paths
        lstRatePlanInfoUpgradeTargets = IECProductManager.getRatePlanInformationUpgradesBySourceRatePlan(oRatePlanInfoSourceUpgrade.Id);

        lstUIRatePlanInfoUpgradeTargets = new List<UIUpgradableRatePlan>();
        for (Product_Rate_Plan_Information__c upgradeTarget : lstRatePlanInfoUpgradeTargets) {
          lstUIRatePlanInfoUpgradeTargets.add(new UIUpgradableRatePlan(upgradeTarget));
        }

        return null;
      }
    }
    catch(Exception ex) {
      addErrorMessage(ex.getMessage());
      return null;
    }
  }
  
  /**
   * Preview all upgrades availablre and display their prices
   */
  public void previewUpgrades() {
    try {
      // we need the Rate Plan Zuora ID of the current rate plan associated to the subscription
      String sUpgradeFromRatePlanZuoraID = IECSubscriptionManager.getRatePlanZIdFromProductRatePlanAndSubscription(oRatePlanInfoSourceUpgrade.Product_Rate_Plan__r.zqu__ZuoraId__c, oSubscription.Zuora__Zuora_Id__c);

      upgradePreviewSuccessful = true;

	  // Retrieve the SoldTo Location for the current contact
	  Location__c oLocSoldTo = new Location_Sel().getSoldToLocationByContactId(new Set<Id> {loggedCustomer.RelatedContact.Id}).get(loggedCustomer.RelatedContact.Id);
	  
      // for each of the available upgrades
      for (UIUpgradableRatePlan uiUpgradableRatePlan : lstUIRatePlanInfoUpgradeTargets) {
        
        // preview the amendment to have the upgrade price
        Zuora.zApi.AmendResult upgradePreviewResult = IECSubscriptionManager.upgradeSubscription(loggedCustomer, oSubscription.Name, oSubscription.Zuora__Zuora_Id__c, sUpgradeFromRatePlanZuoraID, uiUpgradableRatePlan.productRatePlanInfo.Product_Rate_Plan__r.zqu__ZuoraId__c, uiUpgradableRatePlan.productRatePlanInfo.Id, 1, Date.today(), oSubscription.Zuora__AutoRenew__c, true, IECConstants.PaymentType.ICH, null, null, sPurchaseOrder, null, null, null, null);
		
        // keep flag if all preview are successful
        upgradePreviewSuccessful &= upgradePreviewResult.success;
        
        if (upgradePreviewResult.success)
        {
        	if (upgradePreviewResult.InvoiceDatas != null) {
				uiUpgradableRatePlan.setInvoiceData( upgradePreviewResult.InvoiceDatas.get(0) );
            	
	            /**************************************************
	            *	2016-05-13: Samy: Add Tax calculation
	            **************************************************/
				// Initialize a fake OrderItem DTO for tax and shipping calculation
				OrderItem_DTO dtoOrderItem = new OrderItem_DTO();
				
				//Get Product Info
				Map<String, Product2> mapProductRatePlanZId_Product = Product_Sel.getProductsByProductRatePlan(new Set<String> {uiUpgradableRatePlan.productRatePlanInfo.Product_Rate_Plan__r.zqu__ZuoraId__c});
				
				if (mapProductRatePlanZId_Product == null || mapProductRatePlanZId_Product.isEmpty())
					throw new IECApplicationException('Unable to locate a Salesforce Product for the ProductRatePlan: ' + uiUpgradableRatePlan.productRatePlanInfo.Product_Rate_Plan__r.zqu__ZuoraId__c);
				else
				{
					Product2 oProduct = mapProductRatePlanZId_Product.get(uiUpgradableRatePlan.productRatePlanInfo.Product_Rate_Plan__r.zqu__ZuoraId__c);
					String sProductNumber = oProduct.SAP_Material_Number__c;
					// Get the Parent SAP Code as this is the one to be used with the TAX webservice
					String sParentProductNumber = oProduct.IEC_Parent_Product__r.SAP_Material_Number__c;
					
					String sCustomerType = User_Sel.getCustomerType(UserInfo.getUserId());
					// Retrieve the price for the upgrade product
					Map<String, PriceInfo_DTO> mapProductNumber_Price = new Product_Sel().getProductPriceInfo(new Set<String> {sProductNumber}, sCustomerType, null, null, true);
					
					dtoOrderItem.PriceInfo = mapProductNumber_Price.get(sProductNumber);
					dtoOrderItem.sapProductCode = sParentProductNumber;
					dtoOrderItem.quantity = 1;
					dtoOrderItem.chargeShipping = oProduct.Charge_Shipping__c;
					dtoOrderItem.isContractProduct = oProduct.Use_Contract_when_ordered__c;
					// Set any random ID since it is a fake item
					dtoOrderItem.orderItemId = 'RANDOM';
					
					Order_Svc.setPriceToOrderItemDTO(dtoOrderItem, sCustomerType);
	
					// Retrieve Tax & Shipping information for current Order Item/Subscription
					if (!Test.isRunningTest())
					{
						
						String result = Order_Svc.getSAP_Freight_Tax_for_DTO(Utility.getTextSetting('vfOrder-DefaultType')
							, Utility.getTextSetting('vfOrder-DefaultSource')
							, Utility.getTextSetting('vfOrder-DefaultChannel')
							, oLocSoldTo.SAP_Id__c
							, loggedCustomer.RelatedContact.BillTo_Location__r.SAP_Id__c
							, loggedCustomer.RelatedContact.ShipTo_Location__r.SAP_Id__c
							, new List<OrderItem_DTO> {dtoOrderItem});
						
			            if (result != null)
				   			throw new IECApplicationException('Error returned from Tax & Shipping webservice. ' + result);
					}
					else
					{
						dtoOrderItem.taxAmount = 10;
						dtoOrderItem.shippingAmount = 5;
					}
	            }
	            
				uiUpgradableRatePlan.taxCharge = dtoOrderItem.taxAmount;

				uiUpgradableRatePlan.shippingCharge = (dtoOrderItem.shippingAmount == null && dtoOrderItem.handlingCharges == null) ? null
					: ((dtoOrderItem.shippingAmount == null ? 0 : dtoOrderItem.shippingAmount)
						+ (dtoOrderItem.handlingCharges == null ? 0 : dtoOrderItem.handlingCharges));
	            /**************************************************
	            *	End Of: 2016-04-19: Samy: Add Tax calculation
	            **************************************************/
			}
			else
				throw new IECApplicationException(Label.IEC_Error_CannotUpgrade + '<br />InvoiceDatas is null');
        }
        else
        {
        	String sErrors = '';
        	for (Zuora.zObject error: upgradePreviewResult.errors)
            	sErrors += error.getValue('Message');
          	throw new IECApplicationException('(Preview) ' + Label.IEC_Error_CannotUpgrade + '<br />' + sErrors);
        }
      }
    }
    catch(Exception ex) {
      addErrorMessage(ex.getMessage());
    }
  }
  
  /**
   * Preview the amendment based on the selected upgrade.
   */
  public Pagereference selectUpgrade() {
    try {
      
      if (String.isBlank(selectedUpgradeRatePlanZuoraID) || String.isBlank(selectedUpgradeProductInfoID) || String.isBlank(selectedUpgradeRatePlanInfoID))
        throw new IECApplicationException(Label.IEC_Error_SelectRatePlan);

      // check the selected rate plan
      for (UIUpgradableRatePlan uiRatePlan : lstUIRatePlanInfoUpgradeTargets) {
        if (uiRatePlan.productRatePlanInfo.Id == selectedUpgradeRatePlanInfoID) {
          // set the pricing information
          subtotal = uiRatePlan.subTotal;
          //taxes = uiRatePlan.taxes;
          taxCharge = uiRatePlan.taxCharge;
          shippingCharge = uiRatePlan.shippingCharge;
          total = subtotal + (taxCharge == null ? 0 : taxCharge) + (shippingCharge == null ? 0 : shippingCharge);
        }
      }
      
      // check if there are new Terms & Conditions to accept (different version)
      Terms_and_Conditions__c oTnC = IECProductManager.getCurrentTermsAndConditionForProduct(selectedUpgradeProductInfoID);
      if (oTnC != null && (!IECProductManager.hasTnCBeenAcceptedByCustomer(oTnC.Id, loggedCustomer.RelatedContact.Id) || oRatePlanInfoSourceUpgrade.Is_Triable__c)) {
        needToAcceptTnC = true;
        bExpandedAutoRenewal = false;
        listProductInformationIDs = new List<String> { selectedUpgradeProductInfoID };
      }
  
      displayPaymentMethods();
      loadHPMIframe();

      
      return null;
    }
    catch(Exception ex) {
      addErrorMessage(ex.getMessage());
      upgradePreviewSuccessful = false;
      if (Test.isRunningTest())
        throw ex;
      return null;
    }
  }
  
  /**
   * Action called to perform the upgrade
   */
  public Pagereference proceedToUpgrade() {
    try {
      
      if (String.isBlank(selectedUpgradeRatePlanZuoraID) || String.isBlank(selectedUpgradeProductInfoID) || String.isBlank(selectedUpgradeRatePlanInfoID))
        throw new IECApplicationException(Label.IEC_Error_SelectRatePlan);
        
      // check if the Contact Info has not been filled
      if (needToFillContactInfo)
        throw new IECApplicationException(Label.IEC_Error_Fill_Contact_Info);
        
      // check if Contact Info is still in edit mode
      if (inEditContactInfo)
        throw new IECApplicationException(Label.IEC_Error_Confirm_Contact_Info);
      
      // check if Terms & Conditions were accepted
      if (needToAcceptTnC == true && hasAcceptedAllTnCs == false)
        throw new IECApplicationException(Label.IEC_Error_AcceptTermAndCondition);
        
      // check if the Auto-renew flag has been selected by the customer
      if (hasFilledAutoRenewFlag == false)
        throw new IECApplicationException(Label.IEC_Error_SelectAutoRenewFlags);
        
      // check if a payment method was selected
      if (String.isBlank(selectedPaymentMethodType))
        throw new IECApplicationException(Label.IEC_Error_PleaseSelectPaymentMethod);
      
      /* Commented on 7-7-2014: Luc has put this on hold till further notice (Spira #9408)
      // check if PO is not empty when choosing ICH payment method
      if (String.isBlank(sPurchaseOrder) && selectedPaymentMethodType == 'ICH')
        throw new IECApplicationException(Label.IEC_Error_PO_Required);
      */
      
      // parse the selected payment method type
      IECConstants.PaymentType ePmType = IECConstants.parsePaymentMethodToEnum(selectedPaymentMethodType);
      
      // interpret radio button value for auto-renew flag
      Boolean bAutoRenew = (autoRenewSubscription == 'true');
      
      // Register the default payment as the selected method to render properly in case failed zuora call
      // (since we don't support transactions to roll back setting the default PM)
      if(ePmType == IECConstants.PaymentType.BANK_TRANSFER) 
                defaultPaymentMethodId = IECConstants.PaymentMethod_BankTransfer_ZuoraID;
            else if(ePmType == IECConstants.PaymentType.ICH) 
                defaultPaymentMethodId = IECConstants.PaymentMethod_ICH_ZuoraID;
            else if (ePmType != null && selectedCreditCardPaymentId != '') 
                defaultPaymentMethodId = selectedCreditCardPaymentId;

            // get payment method object
      IECZuoraHelper.PaymentMethod oPaymentMethod = null;
      if (ePmType == IECConstants.PaymentType.CREDIT_CARD) {
        
        // get PaymentMethod object from the customer
        oPaymentMethod = IECZuoraHelper.GetPaymentMethodById(paymentMethods, selectedCreditCardPaymentId);

        // if not found, query zuora because it's a new credit card
        if (oPaymentMethod == null) {
          Zuora.zObject zPaymentMethod = IECZuoraHelper.getZuoraPaymentMethodById(selectedCreditCardPaymentId);
          oPaymentMethod = (zPaymentMethod == null ? null : new IECZuoraHelper.PaymentMethod(zPaymentMethod));
        }
      }
                
            List<Product_Rate_Plan_Information__c> lstRatePlanInfo = IECProductManager.getProductRatePlansInformationById(selectedUpgradeRatePlanInfoID);

      if (lstRatePlanInfo.size() > 0)
        oRatePlanInfoTargetUpgrade = lstRatePlanInfo.get(0);
        
      sAppURL = oRatePlanInfoTargetUpgrade.Related_Product_Information__r.Related_Product_Category__r.Application_URL__c;
      
      //////////////////////////////////////////////////////////////////////////
      // TRIAL - if the source rate plan is a Trial, create a new subscription
      
      if (oRatePlanInfoSourceUpgrade.Is_Triable__c) {

        // subscribe call      
        Zuora.zApi.SubscribeResult res = IECSubscriptionManager.upgradeTrial(selectedUpgradeRatePlanInfoID, selectedUpgradeRatePlanZuoraID, loggedCustomer, ePmType, oPaymentMethod, bAutoRenew, oTnCComponentController.listTermsAndConditions.size() > 0 ? oTnCComponentController.listTermsAndConditions.get(0) : null, sPurchaseOrder);
        
        listSubscriptionResultToDisplay = new List<IECZuoraHelper.SubscriptionResult>();
          
        String sProductName = oRatePlanInfoTargetUpgrade.Related_Product_Information__r.Related_Product_Category__r.Display_Name__c
                    + ' - ' + oRatePlanInfoTargetUpgrade.Product_Rate_Plan__r.Name;
        
        listSubscriptionResultToDisplay.add(new IECZuoraHelper.SubscriptionResult(res, sProductName, sAppURL));
        
        upgradeSuccessful = res.success;
        paymentTransactionNumber = (res.Success ? res.PaymentTransactionNumber : '');
      }
      
      ///////////////////////////////////////////////////////////////////////
      // REAL UPGRADE - if the rate plan is not a trial, create an amendment

      else {

        String sUpgradeFromRatePlanZuoraID = IECSubscriptionManager.getRatePlanZIdFromProductRatePlanAndSubscription(oRatePlanInfoSourceUpgrade.Product_Rate_Plan__r.zqu__ZuoraId__c, oSubscription.Zuora__Zuora_Id__c);
      
        Terms_and_Conditions__c oAcceptedTnC = (needToAcceptTnC ? oTnCComponentController.listTermsAndConditions.get(0) : null);
      
        // submit the amendment
        Zuora.zApi.AmendResult upgradeResult = IECSubscriptionManager.upgradeSubscription(loggedCustomer, oSubscription.Name, oSubscription.Zuora__Zuora_Id__c, sUpgradeFromRatePlanZuoraID, selectedUpgradeRatePlanZuoraID, selectedUpgradeRatePlanInfoID, 1, Date.today(), bAutoRenew, false, ePmType, oPaymentMethod, oAcceptedTnC, sPurchaseOrder, subTotal, 1, taxCharge, shippingCharge);
        
        if (upgradeResult.success) {
          upgradeSuccessful = true;
          paymentTransactionNumber = upgradeResult.PaymentTransactionNumber;
        }
        else {
          String sErrors = IECZuoraHelper.getErrorMessagesString(upgradeResult.errors, '<br />');
          //for (Zuora.zObject error: upgradeResult.errors)
          //  sErrors += error.getValue('Message');
          upgradeSuccessful = false;
          throw new IECApplicationException(Label.IEC_Error_CannotUpgrade + '<br />' + sErrors);
        }
      }
      
      if (upgradeSuccessful) {
        // Determine the unit price for the selected upgrade plan          
        Decimal upgradeUnitPrice = 0;
        for (UIUpgradableRatePlan upgradePlan : lstUIRatePlanInfoUpgradeTargets) {
          if (upgradePlan.productRatePlanInfo.Id == selectedUpgradeRatePlanInfoID) {
            //upgradeUnitPrice = upgradePlan.price;
            upgradeUnitPrice = upgradePlan.total;
            break;
          }
        }
        
        // Send HTML email containing summary for the order
        String sHtmlEmailBody = '<table cellspacing="0" cellpadding="12" border="0" width="100%" style="" class="ap-contentbox">'
          + '  <tr>'
          + '    <td valign="top" align="left" style="font-family: Arial, Helvetica, Verdana, sans-serif; color:#969696; font-size: 15px; line-height:18px;">'
          + '      <table cellspacing="0" cellpadding="0" width="100%">'
          + '        <tr>'
          + '          <td valign="top" width="59%" style="font-family: Arial, Helvetica, Verdana, sans-serif; color: #969696; font-size: 15px; line-height: 18px; text-transform:uppercase;padding: 20px 0 20px 20px;">'
          + '            <strong>Original Product Name </strong>'
          + '          </td>'
          + '          <td valign="top" width="19%" style="font-family: Arial, Helvetica, Verdana, sans-serif; color: #969696; font-size: 15px; line-height: 18px; text-transform:uppercase;padding: 20px 0; text-align:center;">'
          + '            <strong>Quantity</strong>'
          + '          </td>'
          + '          <td valign="top" width="22%" style="font-family: Arial, Helvetica, Verdana, sans-serif; color: #969696; font-size: 15px; line-height: 18px; text-transform:uppercase;padding: 20px 20px 20px 0;" align="right">'
          + '            <strong>Price</strong>'
          + '          </td>'
          + '        </tr>'
          + '      </table>'
          + '    </td>'
          + '  </tr>'
          + '  <tr>'
          + '    <td valign="top" align="left" style="font-family: \'Lucida Grande\', \'Lucida Sans\', \'Lucida Sans Unicode\', Arial, Helvetica, Verdana, sans-serif; color: #000000; font-size: 15px; line-height: 15px;">'
          + '      <!-- start order list -->'
          + '      <table cellspacing="0" cellpadding="0" border="0" class="app-order-row" width="100%">'
          + '        <!--start order item row -->'
          + '        <tr>'
          + '          <td align="left" class="spacer-col" width="15" valign="top">&nbsp;</td>'
          + '          <td valign="top" align="left">'
          + '            <table cellpadding="0" cellspacing="0" border="0" width="100%">'
          + '              <tr>'
          + '                <td align="left" width="294" valign="top" style="font-family: Arial, Helvetica, Verdana, sans-serif; color:#969696; font-size: 15px; line-height:18px; font-weight:normal;padding: 20px 0;">'
          + '                  ' + sOriginalProductName
          + '                </td>'
          + '                <td align="left" class="spacer-col" width="15" valign="top">&nbsp;</td>'
          + '                <td align="right" style="font-family: \'Lucida Grande\', \'Lucida Sans\', \'Lucida Sans Unicode\', Arial, Helvetica, Verdana, sans-serif; color:#000000; font-size: 12px; line-height:18px;" valign="top">'
          + '                  <div class="noWrapPrice"></div>'
          + '                </td>'
          + '                <td align="left" class="spacer-col" width="15" valign="top">&nbsp;</td>'
          + '                <td align="right" width="30" style="font-family: \'Lucida Grande\', \'Lucida Sans\', \'Lucida Sans Unicode\', Arial, Helvetica, Verdana, sans-serif; color:#000000; font-size: 12px; line-height:18px;" valign="top">'
          + '                </td>'
          + '                <td width="97" align="center" valign="middle" style="font-family: Arial, Helvetica, Verdana, sans-serif; color:#969696; font-size: 15px; font-weight:normal; line-height:18px; padding: 20px 0;">' + subscriptionChargeQuantity + '</td>'
          + '                <td width="136" align="right" valign="middle" style="font-family: Arial, Helvetica, Verdana, sans-serif; color:#969696; font-size: 15px; font-weight:normal; line-height:18px; padding: 20px 20px 20px 0;">'
          + '                  <div class="noWrapPrice">USD ' + IECUtil.DecimalToString(subscriptionCharge.Zuora__Price__c * subscriptionChargeQuantity) + '</div>'
          + '                </td>'
          + '              </tr>'
          + '            </table>'
          + '          </td>'
          + '        </tr>'
          + '      </table>'
          + '      <!-- End order list -->'
          + '    </td>'
          + '  </tr>'
          + '</table>'
          + '<table cellspacing="0" height="9" cellpadding="0" border="0" width="100%" class="ap-9pxspacer">'
          + '  <tr>'
          + '    <td valign="top" height="9" align="left" style="font-size:6px; line-height: 0;"><img src="https://iata--ecom--c.cs18.content.force.com/servlet/servlet.ImageServer?id=015110000000gxC&oid=00D110000005PWM" alt="" style="display:block; outline: none;" border="0" height="9" width="1"></td>'
          + '  </tr>'
          + '</table>'
          + '<table cellspacing="0" height="9" cellpadding="0" border="0" width="100%" class="ap-9pxspacer">'
          + '  <tr>'
          + '    <td valign="top" height="9" align="left" style="font-size:6px; line-height: 0;"><img src="https://iata--ecom--c.cs18.content.force.com/servlet/servlet.ImageServer?id=015110000000gxC&oid=00D110000005PWM" alt="" style="display:block; outline: none;" border="0" height="9" width="1"></td>'
          + '  </tr>'
          + '</table>'
          + '<table cellspacing="0" cellpadding="14" border="0" width="100%" style="border-top: 1px solid #d4d4d4; border-right: 1px solid #d4d4d4; border-left: 1px solid #d4d4d4; border-bottom: 1px solid #AAAAAA; -webkit-border-radius:5px;-moz-border-radius:5px; border-radius:5px; -moz-box-shadow: 0px 1px 1px #d4d4d4, inset 0px 0px 6px #d4d4d4; -webkit-box-shadow: 0px 1px 1px #d4d4d4, inset 0px 0px 6px #d4d4d4; box-shadow: 0px 1px 1px #d4d4d4, inset 0px 0px 6px #d4d4d4;" class="ap-contentbox">'
          + '  <tr>'
          + '    <td valign="top" align="left" bgcolor="e2e2e2" style="border-radius:5px 5px 0px 0px; font-family: \'Lucida Grande\',\'Lucida Sans\',\'Lucida Sans Unicode\', Arial, Helvetica, Verdana, sans-serif; color:#000000; font-size: 15px; line-height:18px;">'
          + '      <table cellspacing="0" cellpadding="0" width="100%">'
          + '        <tr>'
          + '          <td valign="top" width="59%" style="font-family: Arial, Helvetica, Verdana, sans-serif; color: #969696; font-size: 15px; line-height: 18px; text-transform:uppercase;padding: 20px 0 20px 20px;">'
          + '            <strong>Upgraded Product Name </strong>'
          + '          </td>'
          + '          <td valign="top" width="19%" style="font-family: Arial, Helvetica, Verdana, sans-serif; color: #969696; font-size: 15px; line-height: 18px; text-transform:uppercase;padding: 20px 0; text-align:center;">'
          + '            <strong>Quantity</strong>'
          + '          </td>'
          + '          <td valign="top" width="22%" style="font-family: Arial, Helvetica, Verdana, sans-serif; color: #969696; font-size: 15px; line-height: 18px; text-transform:uppercase;padding: 20px 20px 20px 0;" align="right">'
          + '            <strong>Price</strong>'
          + '          </td>'
          + '        </tr>'
          + '      </table>'
          + '    </td>'
          + '  </tr>'
          + '  <tr>' 
          + '    <td valign="top" align="left" style="font-family: \'Lucida Grande\', \'Lucida Sans\', \'Lucida Sans Unicode\', Arial, Helvetica, Verdana, sans-serif; color: #000000; font-size: 15px; line-height: 15px;">'
          + '      <!-- start order list -->'
          + '      <table cellspacing="0" cellpadding="0" border="0" class="app-order-row" width="100%">'
          + '        <!--start order item row -->'
          + '        <tr>'
          + '          <td align="left" class="spacer-col" width="15" valign="top">&nbsp;</td>'
          + '          <td valign="top" align="left">'
          + '            <table cellpadding="0" cellspacing="0" border="0" width="100%">'
          + '              <tr>'
          + '                <td align="left" width="294" valign="top" style="font-family: Arial, Helvetica, Verdana, sans-serif; color:#969696; font-size: 15px; line-height:18px; font-weight:normal;padding: 20px 0;">'
          + '                  ' + sUpgradeProductName
          + '                </td>'
          + '                <td align="left" class="spacer-col" width="15" valign="top">&nbsp;</td>'
          + '                <td align="right" style="font-family: \'Lucida Grande\', \'Lucida Sans\', \'Lucida Sans Unicode\', Arial, Helvetica, Verdana, sans-serif; color:#000000; font-size: 12px; line-height:18px;" valign="top">'
          + '                  <div class="noWrapPrice"></div>'
          + '                </td>'
          + '                <td align="left" class="spacer-col" width="15" valign="top">&nbsp;</td>'
          + '                <td align="right" width="30" style="font-family: \'Lucida Grande\', \'Lucida Sans\', \'Lucida Sans Unicode\', Arial, Helvetica, Verdana, sans-serif; color:#000000; font-size: 12px; line-height:18px;" valign="top">'
          + '                </td>'
          + '                <td width="97" align="center" valign="middle" style="font-family: Arial, Helvetica, Verdana, sans-serif; color:#969696; font-size: 15px; font-weight:normal; line-height:18px; padding: 20px 0;">' + subscriptionChargeQuantity + '</td>'
          + '                <td width="136" align="right" valign="middle" style="font-family: Arial, Helvetica, Verdana, sans-serif; color:#969696; font-size: 15px; font-weight:normal; line-height:18px; padding: 20px 20px 20px 0;">'
          + '                  <div class="noWrapPrice">USD ' + IECUtil.DecimalToString(upgradeUnitPrice * subscriptionChargeQuantity) + '</div>'
          + '                </td>'
          + '              </tr>'
          + '            </table>'
          + '          </td>'
          + '        </tr>'
          + '      </table>'
          + '      <!-- End order list -->'
          + '    </td>'
          + '  </tr>'
          + '</table>';

        String sPaymentMethod;
        
        // Compile payment method text for the email
        if (ePmType == IECConstants.PaymentType.ICH)
          sPaymentMethod = 'ICH';
        else if (ePmType == IECConstants.PaymentType.BANK_TRANSFER)
          sPaymentMethod = 'Bank Transfer';
        else if (ePmType == IECConstants.PaymentType.CREDIT_CARD) {
          sPaymentMethod = 'Credit Card<BR/>';
          for(IECZuoraHelper.PaymentMethod pm : paymentMethods) {
            if (pm.zId == selectedCreditCardPaymentId) {
              sPaymentMethod += pm.creditCardType + ' ' + pm.CreditCardMaskNumber ;//+ '<BR>' + pm.creditCardExpirationMonth + '/' + pm.creditCardExpirationYear;
              break;
            }
          }          
        }
        IECEmailUtility.sendEmail(loggedCustomer.RelatedContact.Name, loggedCustomer.RelatedContact.Email, IECConstants.Email_Template_Order, sHtmlEmailBody, 'Subsciption Upgraded (' + oSubscription.Name + ')', paymentTransactionNumber, sPaymentMethod,  subTotal, taxCharge, total);
      }
      
      return null;
    }
    catch(Exception ex) {
      addErrorMessage(ex.getMessage());
      if (Test.isRunningTest())
        throw ex;
      return null;
    }
  }
  
   /**
     * Displays the credit cards and check if the amount allows the different payment types
     */
    private void displayPaymentMethods() {
        try {
            paymentMethods = new List<IECZuoraHelper.PaymentMethod>();
            List<IEC_Payment_Threshold__c> lstThreshold = null;

            if (loggedCustomer.PaymentMethods != null && loggedCustomer.PaymentMethods.size() > 0) {
                paymentMethods = IECZuoraHelper.convertFromzObjectListToPaymentMethod(loggedCustomer.PaymentMethods);
            }
            
            // check all payment type for if they allow the total amount (with taxes)
            //isPaymentAvailableWithBankTransfer = IECSubscriptionManager.canPurchaseAmountWithPaymentMethod(IECConstants.PaymentThresholdType_BankTransfer, total);
            
            // if the user can pay by ICH, check amount
            if (hasICHCode) {
              isPaymentAvailableWithICH = IECSubscriptionManager.canPurchaseAmountWithPaymentMethod(IECConstants.PaymentThresholdType_ICH, total);
              lstThreshold = IECSubscriptionManager.getPaymentMethodThresholdByType(IECConstants.PaymentThresholdType_ICH);
              dICHMinAmount = lstThreshold.isEmpty() ? 0.0 : lstThreshold.get(0).Min_amount__c;
            }
            
            isPaymentAvailableWithCreditCard = IECSubscriptionManager.canPurchaseAmountWithPaymentMethod(IECConstants.PaymentThresholdType_CreditCard, total);
            lstThreshold = IECSubscriptionManager.getPaymentMethodThresholdByType(IECConstants.PaymentThresholdType_CreditCard);
      dCreditCardMaxAmount = lstThreshold.isEmpty() ? 0.0 : lstThreshold.get(0).Max_amount__c;
        }
        catch (Exception ex) {
            addErrorMessage(ex.getMessage());
        }
    }
    
    /**
   * Navigate to the subscription page
   */
  public Pagereference onClickCancel() {
    try {
      Pagereference pgRef = Page.IEC_DataStatisticsSubscriptions;
        pgRef.getParameters().put(IECConstants.PARAM_SUBSCRIPTION_ID, IECUtil.EncryptEncodeParameter(sSubscriptionId));
        pgRef.setRedirect(true); 
        return pgRef;
    }
    catch (Exception ex) {
      addErrorMessage(ex.getMessage());
    }
    return null;
  }
  
  /**
   * Change the UI to let the customer choose another upgrade
   */
  public Pagereference changeSelection() {
    try {      
      selectedUpgradeRatePlanZuoraID = '';
      selectedUpgradeProductInfoID = '';
      selectedUpgradeRatePlanInfoID = '';
      hasFilledAutoRenewFlag = false;
      selectedPaymentMethodType = '';
      
      return null;
    }
    catch (Exception ex) {
      addErrorMessage(ex.getMessage());
    }
    return null;
  }
    
    /**
     * Specify extra HPM parameters that can be used to (1) Preload field values (2) Override default HPM properties.  Please see 
     * HPM Implementation Guide for a complete list of HPM parameters.
     */
    public Map<String, String> getExtraParameters() {
        return new Map<String, String> {
            'field_maxConsecutivePaymentFailures' => '1', 
            'field_maxConsecutivePaymentFailures' => '1', 
            'field_creditCardType' => 'Visa'
        }; 
    }
    
    /**
   * Validate configuration before loading the HPM IFrame 
   */
    private void validateConfiguration(){
        this.hasConfigError = false;
        HPM_Setting__c hpmSetting = HPM_Setting__c.getInstance( 'Zuora HPM Setting' );
        if ( hpmSetting == null ) {
            throw new HPMConfigException( IECErrorCodeMapping.VALUES.get( 'Sfdc.NoConfiguration' ) ); 
        }
    
        String missingFields = ''; 
        this.pageId = hpmSetting.HPM_Page_Id__c; 
        if ( this.pageId == null || this.pageId.trim().length() == 0 ) {
            missingFields += ' Page ID,';
        }
    
        this.tenantId = hpmSetting.HPM_Tenant_Id__c; 
        if ( this.tenantId == null || this.tenantId.trim().length() == 0 ) {
            missingFields += ' Tenant ID,';
        }
    
        this.apiSecurityKey = hpmSetting.HPM_Security_Token__c; 
        if ( this.apiSecurityKey == null || this.apiSecurityKey.trim().length() == 0 ) {
            missingFields += ' Security Token,';
        }
    
        this.appUrl = hpmSetting.HPM_App_Url__c; 
        if ( this.appUrl == null || this.appUrl.trim().length() == 0 ) {
            missingFields += ' App URL,'; 
        }
    
        if ( missingFields.length() > 0 ) {
            missingFields = missingFields.substring( 0, missingFields.length() - 1 );
            throw new HPMConfigException( IECErrorCodeMapping.VALUES.get( 'Sfdc.InvalidConfiguration' ) + missingFields );
        }
    
        Map<String, String> paramMap = ApexPages.currentPage().getParameters(); 
        String errorCode = paramMap.get( 'errorCode' ); 
        if ( errorCode == 'Invalid_Security' || errorCode == 'InvalidCallbackSecurity' ) {
            this.hasConfigError = true; 
        }
    }
    
    // taken from HPMSampleController
    public void loadHPMIframe(){
        try {
            validateConfiguration(); 
        }
        catch( HPMConfigException e ) {
            hasConfigError = true;
          ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, IECErrorCodeMapping.VALUES.get( 'Sfdc.ErrorLoadingFrame' ) + e.getMessage() ) );
        }
        
        try {
          String token = EncodingUtil.convertToHex(Crypto.generateAesKey(128));
          String timestamp = String.valueOf(System.currentTimeMillis());
            
          String queryString = 'id=' + pageId + '&' +
              'tenantId=' + tenantId + '&' +
              'timestamp=' + timestamp + '&' +
              'token=' + token;
              
          String queryHashString = queryString + apiSecurityKey;
          String signature = EncodingUtil.base64Encode(Blob.valueOf(EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(queryHashString)))));
          
          iframeSrc = appUrl + '/PublicHostedPage.do?method=requestPage&id=' + pageId + '&tenantId=' + tenantId + '&timestamp=' +timestamp + '&token=' + token + '&signature=' + signature; 
                      
          Map<String, String> extraParameters = getExtraParameters(); 
          for ( String param : extraParameters.keySet() ) {
            iframeSrc += '&' + param + '=' + extraParameters.get( param ); 
          }
                        
          //addCallBackfailure();
        }
        catch (Exception ex) {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }        
    }
    
    /**
     * Display the error messages returned by the Hosted Payment Method of Zuora
     */
    public Pagereference displayCallBackfailure() {
      try {
        loadHPMIframe();
        
          errorMessage = '';
          errorCode = '';
          
          // create a dummy page reference just to parse the parameters returned by the HPM
          PageReference curPage = new Pagereference(URL.getSalesforceBaseUrl().toExternalForm() + Site.getPathPrefix() + sErrorMsgFromHPM);
          
          errorMessage = curPage.getParameters().get('errorMessage');
          errorCode = curPage.getParameters().get('errorCode');

          final String DefaultErrorPrefix = 'An error has occurred'; 
          String error = ''; 
          
          if ( errorCode != null && errorCode != '' ) {
              boolean unknownErrorCode = false; 
              error = IECErrorCodeMapping.VALUES.get( errorCode ); 
              if ( error == null ) { 
                  error = DefaultErrorPrefix; 
                  unknownErrorCode = true;
              }
            if ( errorMessage != null  && errorMessage != '' ) {
              error += ( ': ' + errorMessage );   
            }         
            else if ( unknownErrorCode ) {
              error += ( ': ' + errorCode ); 
            }
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, error ) );   
            iframeSrc += '&retainValues=true';        
            if ( errorCode == 'InvalidCallbackSecurity' ) {
              return null; 
            }
          }
          
          List<String> validationErrors = new List<String>();
          for ( String errorField : IECErrorCodeMapping.ERROR_FIELD_MAPPING.keySet() ) {
              String errorFieldValue = curPage.getParameters().get( errorField ); 
              if ( errorFieldValue != null && errorFieldValue.trim().length() > 0 ) {
                  validationErrors.add( IECErrorCodeMapping.ERROR_FIELD_MAPPING.get( errorField ) + ': ' + IECErrorCodeMapping.VALUES.get( errorFieldValue ) ); 
              }
          }
          if ( validationErrors.size() > 0 ) {
              validationErrors.sort(); 
              for ( String validationError : validationErrors ) {
                ApexPages.addMessage( New ApexPages.Message( ApexPages.Severity.ERROR, validationError ) );
              }
          }
          
          sErrorMsgFromHPM = '';
          return null;
      }
      catch (Exception ex) {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
          return null;
        } 
    }
    
    
    
    
    
  /**
   * Let the user modify the Contact Info
   */
  public void modifyContactInfo() {    
    inEditContactInfo = true;
  }
  
  /**
   * Called when the user changes the Billing Country
   */
  public void onChangeBillingCountry() {    
    // clear the state/province field
        oBillingAddress.ISO_State__c = null; // Changed by Samy (2016-03-01) from State__c

    if (vatConfig == null
            || vatConfig.CountryId != oBillingAddress.ISO_Country__c) { // Changed by Samy (2016-03-01) from Country__c
        
            vatConfig = IECVATUtil.GetVATConfiguration(oBillingAddress.ISO_Country__c); // Changed by Samy (2016-03-01) from Country__c
      oContact.Tax_1_ID__c = null;
      oContact.Tax_2_ID__c = null;
    }
  }
  
  /**
   * Updates the Contact Info of the customer
   */
  public void updateContactInfo() {    
		Savepoint sp = Database.setSavepoint();
    try {
      
      List<String> lstErrorMessages = new List<String>();
      
      // validate mandatory fields
      if (String.isBlank(oContact.FirstName))
        lstErrorMessages.add(Label.IEC_Error_Required_field + ' First Name');
      if (String.isBlank(oContact.LastName))
        lstErrorMessages.add(Label.IEC_Error_Required_field + ' Last Name');
      if (String.isBlank(oContact.Title))
        lstErrorMessages.add(Label.IEC_Error_Required_field + ' Job Title');
      if (String.isBlank(oContact.Email))
        lstErrorMessages.add(Label.IEC_Error_Required_field + ' Email');
      if (String.isBlank(oContact.Phone))
        lstErrorMessages.add(Label.IEC_Error_Required_field + ' Phone');

      if (String.isBlank(oBillingAddress.Street__c))
        lstErrorMessages.add(Label.IEC_Error_Required_field + ' Address');
      if (String.isBlank(oBillingAddress.City__c))
        lstErrorMessages.add(Label.IEC_Error_Required_field + ' City');

            if (String.isBlank(oBillingAddress.ISO_Country__c)) { // Changed by Samy (2016-03-01) from Country__c
        lstErrorMessages.add(Label.IEC_Error_Required_field + ' Country');
        vatConfig = null;
      }
      else {
                vatConfig = IECVATUtil.GetVATConfiguration(oBillingAddress.ISO_Country__c); // Changed by Samy (2016-03-01) from Country__c

        if (vatConfig != null && vatConfig.TaxIDMandatory) {
          if (vatConfig.ShowTax1) {
            if (String.isBlank(oContact.Tax_1_ID__c))
              lstErrorMessages.add(Label.IEC_Error_Required_field + ' ' + vatConfig.Tax1Label);
            else if (vatConfig.VATValidationRequired) {
              IECVATUtil.VATWebService ws = new IECVATUtil.VATWebService();
              try {
                IECVATUtil.VATResponse res = ws.ValidateVAT(vatConfig.CountryCode, oContact.Tax_1_ID__c);
                if (!res.valid) 
                  lstErrorMessages.add(Label.IEC_Error_Invalid_VAT + vatConfig.Tax1Label +   ' (1): ' + oContact.Tax_1_ID__c + ' / ' + vatConfig.CountryCode );
              }
              catch (System.CalloutException ex) {
                if (ex.getMessage().contains('SERVER_BUSY'))
                  lstErrorMessages.add(Label.IEC_Error_VATWSBusy);
                else
                  lstErrorMessages.add(ex.getMessage() + ' (2): ' + oContact.Tax_1_ID__c + ' / ' + vatConfig.CountryCode );                
              }
            }              
          }
          if (vatConfig.ShowTax2) {
            if (String.isBlank(oContact.Tax_2_ID__c))
              lstErrorMessages.add(Label.IEC_Error_Required_field + ' ' + vatConfig.Tax2Label);
            else if (vatConfig.VATValidationRequired) {
              IECVATUtil.VATWebService ws = new IECVATUtil.VATWebService();
              try {
                IECVATUtil.VATResponse res = ws.ValidateVAT(vatConfig.CountryCode, oContact.Tax_2_ID__c);
                if (!res.valid) 
                  lstErrorMessages.add(Label.IEC_Error_Invalid_VAT + vatConfig.Tax2Label);
              }
              catch (System.CalloutException ex) {
                if (ex.getMessage().contains('SERVER_BUSY'))
                  lstErrorMessages.add(Label.IEC_Error_VATWSBusy);
                else
                  lstErrorMessages.add(ex.getMessage());                
              }
            }
          }
        }

                if (lstStateProvince.size() > 1 && String.isBlank(oBillingAddress.ISO_State__c)) // Changed by Samy (2016-03-01) from State__c
                {
                    lstErrorMessages.add(Label.IEC_Error_Required_field + ' State/Province');
                }
                /*
                if (String.isBlank(oBillingAddress.ZipCode__c))
                    lstErrorMessages.add(Label.IEC_Error_Required_field + ' Zip/Postal code');
                */
      }
      
      if (lstErrorMessages.isEmpty()) {
        oContact.VAT_Country_Code__c = (vatConfig.VATValidationRequired) ? vatConfig.CountryCode : null;
        //update oContact;
        IECUserManager.updateContactViaWebService(oContact);

        // First check if the address has been changed before trying to save, otherwise just ignore
        if (IECAddress_Svc.isAddressChanged(oBillingAddress, oOriginalBillingAddress))
        {
            // First insert a new Billing Address
            // TODO: Provide autocomplete feature in the page to avoid having alot of orphaned Addresses
            oBillingAddress.Id = null; // Reset the ID to be able to insert a new IEC Address record
            insert oBillingAddress;
            
            // Then copy the ID into the location record
            oBillingLocation.Address__c = oBillingAddress.Id;
            upsert oBillingLocation;
            
            // re-query the Billing Address to refresh formula fields on the record
            List<IECAddress__c> lstAddresses = IECUserManager.getAddressByContact(loggedCustomer.RelatedContact.Id, IECConstants.IECAddress_AddressType_Billing);
            if (lstAddresses.size() > 0) {
                oBillingAddress = lstAddresses.get(0);
				// Clone the record to check later whether it is changed when saving
        		oOriginalBillingAddress = lstAddresses.get(0).clone(false, true);
            }
        }
                
        inEditContactInfo = false;
                isCountryFilled = String.isNotBlank(oBillingAddress.ISO_Country__c);
        
        // revalidate if the Billing Address is complete
        needToFillContactInfo = !IECUserManager.isBillingAddressFilled(loggedCustomer.RelatedContact.Id)
          || !IECUserManager.isContactMandatoryFieldsFilled(loggedCustomer.RelatedContact, vatConfig);
      }
      else
        addErrorMessages(lstErrorMessages);
    }
    catch (Exception ex) {
        	Database.rollback(sp);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
      }
  }
  
  /**
   * Cancel the modification of the Contact Info of the customer
   */
  public void cancelUpdateContactInfo() {
    try {    
      inEditContactInfo = false;
      
      loggedCustomer.refreshRelatedContact();
      
      // re-query the Billing Address since it is dirty
      List<IECAddress__c> lstAddresses = IECUserManager.getAddressByContact(loggedCustomer.RelatedContact.Id, IECConstants.IECAddress_AddressType_Billing);
      if (lstAddresses.size() > 0) {
        oBillingAddress = lstAddresses.get(0);
                isCountryFilled = String.isNotBlank(oBillingAddress.ISO_Country__c); // Changed by Samy (2016-03-01) from Country__c
                vatConfig = IECVATUtil.GetVATConfiguration(oBillingAddress.ISO_Country__c); // Changed by Samy (2016-03-01) from Country__c
      }
    }
    catch (Exception ex) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
    }
  }    
    

    public Pagereference closePopup() {
      displayPopUp = false;
      return null;
    }
    
    public Pagereference showPopUp() {
      displayPopUp = true;
      return null;
    }
    
   public PageReference toggleBilling() {
      bExpandedBilling = !bExpandedBilling;
      if (bExpandedBilling) {
        bExpandedTCs = false;
        bExpandedAutoRenewal = false;
        bExpandedPaymentMethod = false;
      }
      return null;
    }

   public PageReference toggleTCs() {
      bExpandedTCs = !bExpandedTCs;
      if (bExpandedTCs) {
        bExpandedBilling = false;
        bExpandedAutoRenewal = false;
        bExpandedPaymentMethod = false;
      }
      return null;
    }


   public PageReference toggleAutoRenew() {
      bExpandedAutoRenewal = !bExpandedAutoRenewal;
      if (bExpandedAutoRenewal) {
        bExpandedBilling = false;
        bExpandedTCs = false;
        bExpandedPaymentMethod = false;
      }
      return null;
    }

   public PageReference togglePaymentMethod() {
      bExpandedPaymentMethod = !bExpandedPaymentMethod;
      if (bExpandedPaymentMethod) {
        bExpandedBilling = false;
        bExpandedTCs = false;
        bExpandedAutoRenewal = false;
      }
      return null;
    }    
    
    
  
  /**
   * Inner class to display teh upgradable rate plans
   */
  public class UIUpgradableRatePlan {
    
    public Product_Rate_Plan_Information__c productRatePlanInfo { get; private set; }
    public Boolean selected { get; set; }
    public Decimal subTotal { get; private set; }
    //public Decimal taxes { get; private set; }
    public Decimal total { get {return (subtotal == null ? 0 : subtotal) + (taxCharge == null ? 0 : taxCharge) + (shippingCharge == null ? 0 : shippingCharge);} }
    public List<IECZuoraHelper.InvoiceItem> lstPreviewInvoiceItems { get; set; }
    
    // Phase 3 tax & shipping
    public Decimal taxCharge { get; private set; }
    public Decimal shippingCharge { get; private set; }
    
    /**
     * Constructor
     */
    public UIUpgradableRatePlan(Product_Rate_Plan_Information__c oRatePlanInfo) {
      productRatePlanInfo = oRatePlanInfo;
      selected = false;
    } 
    
    /**
     * Once the upgrade preview is done, set the data to be displayed
     */
    public void setInvoiceData(Zuora.zObject oInvData) {
      Zuora.zObject invoice = (Zuora.zObject)oInvData.getValue('Invoice');
      subTotal = (Decimal)invoice.getValue('AmountWithoutTax');
      //taxes = (Decimal)invoice.getValue('TaxAmount');
      //total = (Decimal)invoice.getValue('Amount');
      
      List<Object> invoiceItems = oInvData.getArrayValue('InvoiceItem');
      if(invoiceItems != null) {
        lstPreviewInvoiceItems = new List<IECZuoraHelper.InvoiceItem>();
        for(Object invoiceItem : invoiceItems) {
          Zuora.zObject zInvoiceItem = (Zuora.zObject)invoiceItem;
          lstPreviewInvoiceItems.add(new IECZuoraHelper.InvoiceItem(zInvoiceItem));
        }
      }
    }
  }
}