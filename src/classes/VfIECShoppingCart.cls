/**
 * VisualForce page controller for the shopping cart with checkout section.
 *
 * This page includes:
 * - content of the cart
 *   - check if items can be swapped
 *   - check if items can be cleaned up
 * - total $ of the cart
 * - if user is not logged in
 *   - display login component
 * - if user is logged in
 *   - display Terms & Conditions
 *   - display available payment methods
 *   - display Proceed to payment button
 */
public class VfIECShoppingCart extends IECPageController {
    
    public List<IEC_Cart_Item__c> listCartItemsToDisplay { get; set; }  
    public String selectedCartItemId { get; set; }
    public boolean isUserLoggedIn {get; set;}
    public Decimal shoppingCartTotalBeforeTax {get; set;}
    public Decimal shoppingCartTax {get; set;}
    public Decimal shoppingCartTotal {get; set;}
    public String couponCode { get; set; }
    public Map<ID, Set<zqu__ProductRatePlanCharge__c>> mapRatePlanCharges { get; private set; }
    public List<UICartItemAutoRenew> lstCartItemAutoRenew { get; set; }
    public Boolean hasOnlyTrials { get; private set; }
    public Boolean paymentSucessful { get; private set; }
    public String selectedPaymentMethodType { get; set; }
    public String selectedCreditCardPaymentId { get; set; }
    public String paymentTransactionNumber { get; set; }
    public Boolean autoRenewSubscription { get; set; }
    public Boolean hasICHCode { get; private set; }
    public Boolean needToFillContactInfo { get; private set; }
    public Boolean inEditContactInfo { get; private set; }
    public Boolean isCountryFilled { get; private set; }
    public IECAddress__c oBillingAddress { get; set; }
    public IECAddress__c oOriginalBillingAddress { get; set; }
    public Location__c oBillingLocation { get; set; }
    public IECVATUtil.VATConfiguration vatConfig { get; set; }
    public String sPurchaseOrder { get; set; }
    public Decimal dICHMinAmount {get; private set;}
    public Decimal dCreditCardMaxAmount {get; private set;}
    
    public Boolean bHasAllTCs {get; set;}
    public Boolean bHasAllAutoRenew {get; set;}
    
    public Boolean bExpandedBilling {get; set;}
    public Boolean bExpandedTCs {get; set;}
    public Boolean bExpandedAutoRenewal {get; set;}
    public Boolean bExpandedPaymentMethod {get; set;}
    public Boolean bshoppingCartUpdated {get; set;}
    
    
    
    //*************************************************************************************
    // BEGIN of Hack to solve the issue with error messages dissapearing on shopping cart total refresh 
    //*************************************************************************************
    
    private List<String> lKeepErrorList {get; set;}
    private List<String> lKeepWarningList {get; set;}

    //String variable used to keep error messages into the variable state acros pages refreshes
    public String sKeepErrorMessage {
        get {
            return convertListToString(lKeepErrorList);
        } 
    
        set {
            lKeepErrorList = convertStringToList(value);
        }
    }
    
    
    //String variable used to keep warning messages into the variable state acros pages refreshes
    public String sKeepWarningMessage {
        get {
            return convertListToString(lKeepWarningList);
        } 
    
        set {
            lKeepWarningList = convertStringToList(value);
        }
    }
    
    //Serilizes the list of messages into a single string to be stored in a hidden input field 
    private String convertListToString(List<String> listValues) {
    
        if (listValues != null && listValues.size() > 0) {
            String JSONString = JSON.serialize(listValues);
            return JSONString;
        }
        
        return '';
    } 
    
    
    //Deserilizes the string stored in a hidden input field into a List of messages 
    private List<String> convertStringToList(String stringValue) {
    
        if (!String.isEmpty(stringValue)) {
            List<String> result = (List<String>) JSON.deserialize(stringValue, List<String>.class);
            return result;
        }
        
        return new List<String>();
    }
    

    private void showAndKeepError(ApexPages.Severity severity, String message) {
        //Keeps in memory the error message to be displayed and pushes it to the page

        if (severity == ApexPages.Severity.ERROR) {
            if (lKeepErrorList == null) lKeepErrorList = new List<String>();
            lKeepErrorList.add(message);
            //sKeepErrorMessage = message;
        }
        
        else if (severity == ApexPages.Severity.WARNING) {
            if (lKeepWarningList == null) lKeepWarningList = new List<String>();
            lKeepWarningList.add(message);
            //sKeepWarningMessage = message;
        }
            
        showMessagesInMemory();
    }
    
    

    //pushes the messages to the page and keeps them in memory (both error and warning messages) 
    private void showAndKeepErrors(ApexPages.Severity severity, List<String> messages) {

        if (severity == ApexPages.Severity.ERROR) {
            if (lKeepErrorList == null) lKeepErrorList = new List<String>();
            if (messages != null && messages.size() > 0) {
                for (String message : messages)
                    lKeepErrorList.add(message);
            }
        }
        
        else if (severity == ApexPages.Severity.WARNING) {
            if (lKeepWarningList == null) lKeepWarningList = new List<String>();
            if (messages != null && messages.size() > 0) {
                for (String message : messages)
                    lKeepWarningList.add(message);
            }
        }
            
        showMessagesInMemory();
    }
    


    //Initialize back to nothing the error message to be displayed after a refres
    private void clearError() {
        
        sKeepErrorMessage = '';
        sKeepWarningMessage = '';
        
        lKeepErrorList.clear();
        lKeepWarningList.clear();
    }
    
    
    
    //This method recreated the error message to be displayed on the page after refresh
    private void showMessagesInMemory() {
        
        if (lKeepErrorList != null && lKeepErrorList.size() > 0) {
            for (String message : lKeepErrorList) {
                if (!String.IsEmpty(message))
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, message));
            }
        }
            
        if (lKeepWarningList != null && lKeepWarningList.size() > 0) {
            for (String message : lKeepWarningList) {
                if (!String.IsEmpty(message))
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.WARNING, message));
            }
        }
            
    }

    //***********************************************************************************************
    // End of Hack
    //***********************************************************************************************
    
    
    
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
    public String defaultPaymentMethodId { get; private set; }
    public Boolean defaultPaymentMethodIsICH {
        get {
            return defaultPaymentMethodId == IECConstants.PaymentMethod_ICH_ZuoraID;
        }
        private set;
    }
    public Boolean defaultPaymentMethodIsBankTransfer {
        get {
            return defaultPaymentMethodId == IECConstants.PaymentMethod_BankTransfer_ZuoraID;
        }
        private set;
    }
    // existing credit card
    public List<IECZuoraHelper.PaymentMethod> paymentMethods { get; private set; }
    public Boolean hasPaymentMethods {
        get {
            return (paymentMethods != null && paymentMethods.size() > 0);
        }
        private set;
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
    
    public Boolean bStateAvailable
	{
		get
		{
			return lstStateProvince.size() > 1;
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
    
    public Boolean cartIsEmpty {
        get {
            return (listCartItemsToDisplay == null || listCartItemsToDisplay.size() == 0);
        }
    }
    
    // properties for the integration of the T&C component
    public String[] listProductInformationIDs { get; private set; }
    public String TC_COMPONENT_KEY {
        get {
            return 'componentTnC';
        }
        private set;
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
    
    public Boolean hasFilledAutoRenewFlags {
        get {
            
            Boolean bTemp = false;
            
            if (lstCartItemAutoRenew.isEmpty()) {
                bTemp = true;
            }
            else {
                Boolean bHasFlaggedAll = true;
                for (UICartItemAutoRenew cartItemAutoRenew : lstCartItemAutoRenew) {
                    bHasFlaggedAll &= (cartItemAutoRenew.autoRenewFlag != null);
                }
                bTemp = bHasFlaggedAll;
            }

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
        private set;
    }
    
    public Boolean isPaymentAvailableWithCreditCard { get; set; }
    public Boolean isPaymentAvailableWithICH { get; set; }
    public Boolean isPaymentAvailableWithBankTransfer { get; set; }
    public String sErrorMsgFromHPM { get; set; }
    public List<IECZuoraHelper.SubscriptionResult> listSubscriptionResultToDisplay { get; private set; }
    public Boolean hasSubscriptionResult {
        get {
            return (listSubscriptionResultToDisplay != null && listSubscriptionResultToDisplay.size() > 0);
        }
        private set;
    }

    public List<SelectOption> lstCanadaProvinces {
        get {
            return IECConstants.getCanadaProvinces();
        }
    }

    public List<SelectOption> lstUSAStates {
        get {
            return IECConstants.getUSAStates();
        }
    }

    /**
     * Constructor
     */
    public VfIECShoppingCart() {
        try {

            bHasAllTCs = false;
            bHasAllAutoRenew = false;

            bExpandedBilling = true;
            bExpandedTCs = true;
            bExpandedAutoRenewal = true;
            bExpandedPaymentMethod = true;
            bshoppingCartUpdated = false;
            
            listProductInformationIDs = new String[]{};
            listSubscriptionResultToDisplay = new List<IECZuoraHelper.SubscriptionResult>();
            
            // Preload list of Countries/States
            lstCountryState = ISO_Country_State_Helper.getCountry_State();
        }
        catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
    }
    
    /**
     * Action called after the page has loaded
     */
    public void pageLoad() {
        try {
            paymentSucessful = null;
            isUserLoggedIn = IECUserManager.isUserLoggedIn();

            if (isUserLoggedIn) {
                // Validate Logged in user profile and ensure profile is complete
                validUserProfile();
                
                // logic was changed for determining access to ICH
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
            }
            listCartItemsToDisplay = new List<IEC_Cart_Item__c>();
            mapRatePlanCharges = new Map<ID, Set<zqu__ProductRatePlanCharge__c>>();
            lstCartItemAutoRenew = new List<UICartItemAutoRenew>();
        }
        catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() + '<br />' + ex.getStacktraceString()));
        }
    }
    
    /**
     * Check in cart if there are items to swap or cleanup (remove)
     * Is called by javascript at the end of the vf page. 
     */
    public Pagereference checkSwapAndCleanUp() {
        try {
            // get current shopping cart
            IEC_Shopping_Cart__c cart = IECShoppingCartHelper.getCurrentShoppingCart();

            // if cart does not exist, simply return
            if (cart != null) {
                // swap cart items if user is logged in
                if (isUserLoggedIn) {
                    IECShoppingCartHelper.swapCartItems(cart, IECUserManager.getClientType());
                }
                
                // check if cart items are still valid (active and accessible to user)
                List<String> listErrMsgs = new List<String>();
                List<String> listInfoMsgs = new List<String>();
                IECShoppingCartHelper.cleanUpCart(cart, IECUserManager.getClientType(), listErrMsgs, listInfoMsgs);
                
                // display messages if any
                if (!listErrMsgs.isEmpty()) {
                    showAndKeepErrors(ApexPages.Severity.ERROR, listErrMsgs);
                }
                
                
                if (!listInfoMsgs.isEmpty()) {
                    showAndKeepErrors(ApexPages.Severity.WARNING, listInfoMsgs);
                }
            }
            
            refreshShoppingCartItems();
            
            return null;
        }
        catch (Exception ex) {
            showAndKeepError(ApexPages.Severity.ERROR, ex.getMessage() + '<br />' + ex.getStacktraceString());
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }
    }
    
    /**
     * Refreshes the cart items, the cart total and the payment methods
     */
    public Pagereference refreshShoppingCartItems() {
        try {
            // get current shopping cart
            IEC_Shopping_Cart__c cart = IECShoppingCartHelper.getCurrentShoppingCart();

            // if cart does not exist, simply return
            if (cart == null) return null;
            
            // get items in cart
            listCartItemsToDisplay = IECShoppingCartHelper.getCartItems(cart);
            
            // loop through the cart items (if any)
            if (listCartItemsToDisplay != null && listCartItemsToDisplay.size() > 0) {
                
                hasOnlyTrials = true;
                mapRatePlanCharges.clear();
                lstCartItemAutoRenew.clear();
                listProductInformationIDs.clear();
                Set<String> setProductInformationIDs = new Set<String>();
                for (IEC_Cart_Item__c cartItem : listCartItemsToDisplay) {
                    
                    // load rate plan charges associated to the cart items
                    if (mapRatePlanCharges.containsKey(cartItem.Related_Rate_Plan_Information__r.Product_Rate_Plan__c) == false) {
                        List<zqu__ProductRatePlanCharge__c> listRatePlanCharges = IECProductManager.getZuoraRatePlanChargesByRatePlanID(cartItem.Related_Rate_Plan_Information__r.Product_Rate_Plan__c);
                        Set<zqu__ProductRatePlanCharge__c> setRatePlanCharges = new Set<zqu__ProductRatePlanCharge__c>();
                        setRatePlanCharges.addAll(listRatePlanCharges);
                        mapRatePlanCharges.put(cartItem.Related_Rate_Plan_Information__r.Product_Rate_Plan__c, setRatePlanCharges);
                    }
                    
                    // build a list of distinct ProductInformationID from the shopping cart
                    if (!setProductInformationIDs.contains(String.valueOf(cartItem.Related_Rate_Plan_Information__r.Related_Product_Information__r.Id)))
                        setProductInformationIDs.add(String.valueOf(cartItem.Related_Rate_Plan_Information__r.Related_Product_Information__r.Id));
                    
                    // check if only trials
                    hasOnlyTrials &= (cartItem.Related_Rate_Plan_Information__r.Product_Rate_Plan__r.IsTriable__c == IECConstants.ProductRatePlanIsTriable_YES);
                    
                    // build the list that will track the Auto-renew flag for each cart item
                    lstCartItemAutoRenew.add(new UICartItemAutoRenew(cartItem));
                }

                // set the parameter to the T&C component
                listProductInformationIDs = new List<String>(setProductInformationIDs);
            }
            else {
                hasOnlyTrials = false;
            }
            return null;
        }
        catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() + '<br />' + ex.getStacktraceString()));
            return null;
        }
    }
    
    /**
     * Query zuora to determine the total for the current cart also to display the tax part
     */
    public PageReference refreshShoppingCartTotal() {
        try {
            IEC_Shopping_Cart__c cart = IECShoppingCartHelper.getCurrentShoppingCart();
            List<IEC_Cart_Item__c> listCartItems = IECShoppingCartHelper.getCartItems(cart);
            
            // if cart is no empty
            if (listCartItems != null && listCartItems.size() > 0) {
                List<Zuora.zObject> listRatePlanDataObject = IECShoppingCartHelper.createRatePlanDataObjectFromCart(cart);
                Zuora.zObject invoice = IECSubscriptionManager.previewInvoice(listRatePlanDataObject, ((isUserLoggedIn) ? loggedCustomer.RelatedContact : null));

                shoppingCartTotalBeforeTax = (Decimal) invoice.getValue('AmountWithoutTax');
                shoppingCartTax = (Decimal) invoice.getValue('TaxAmount');
                shoppingCartTotal = (Decimal) invoice.getValue('Amount');
                
                // display payment methods
                if (isUserLoggedIn) {
                    displayPaymentMethods();
                }
            }

            showMessagesInMemory();

            return null;
        }
        catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() + '<br />' + ex.getStacktraceString()));
            system.debug('SOAP Request = ' + Zuora.zApi.currentLogger.request );
            system.debug('SOAP Response = ' + Zuora.zApi.currentLogger.response );
            return null;
        }
    }
    
    /**
     * Remove selected rate plan from the cart
     */
    public PageReference removeRatePlanFromCart() {
        try {
            IECShoppingCartHelper.removeCartItemById(selectedCartItemId);
            
            // refresh page
            PageReference cartPage = Page.IECShoppingCart;
            cartPage.setRedirect(true);
            
            bshoppingCartUpdated = true;
            return cartPage;
        }
        catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }
    }
    
    /**
     * Proceeds to create the subscription(s)
     */
    public void proceedToPayment() {        
        try {
            
            // check if the Contact Info has not been filled
            if (needToFillContactInfo)
                throw new IECApplicationException(Label.IEC_Error_Fill_Contact_Info);
                
            // check if Contact Info is still in edit mode
            if (inEditContactInfo)
                throw new IECApplicationException(Label.IEC_Error_Confirm_Contact_Info);
            
            // check if Terms & Conditions were accepted
            if (hasAcceptedAllTnCs == false)
                throw new IECApplicationException(Label.IEC_Error_AcceptTermAndCondition);
                
            // check if all Auto-renew flags have been selected by the customer
            if (hasFilledAutoRenewFlags == false)
                throw new IECApplicationException(Label.IEC_Error_SelectAutoRenewFlags);
                
            // check if a payment method was selected
            if (String.isBlank(selectedPaymentMethodType))
                throw new IECApplicationException(Label.IEC_Error_PleaseSelectPaymentMethod);
            
            /* Commented on 7-7-2014: Luc has put this on hold till further notice (Spira #9408)
            // check if PO is not empty when choosing ICH payment method
            if (String.isBlank(sPurchaseOrder) && selectedPaymentMethodType == 'ICH')
                throw new IECApplicationException(Label.IEC_Error_PO_Required);
            */
            
            Integer iNbrSubscriptionSucceeded = 0;
            Integer iNbrSubscriptionFailed = 0;
            IEC_Shopping_Cart__c cart = IECShoppingCartHelper.getCurrentShoppingCart();
            List<IEC_Cart_Item__c> listCartItems = IECShoppingCartHelper.getCartItems(cart);
            List<Boolean> lstAutoRenewFlags = new List<Boolean>();
            
            // build the list of AutoRenew flags
            for (UICartItemAutoRenew autoRenew : lstCartItemAutoRenew)
                lstAutoRenewFlags.add(autoRenew.autoRenewFlag == 'true');
            
            // parse the selected payment method type
            IECConstants.PaymentType ePmType = IECConstants.parsePaymentMethodToEnum(selectedPaymentMethodType);

            // Retrieve the contact record again to validate if ICH Code is still available
            if (ePmType == IECConstants.PaymentType.ICH) {
                if (!loggedCustomer.canPayByICH())
                    throw new IECApplicationException(IECConstants.Error_ICHCodeNotAvailable);
            }
            
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

            // subscribe call           
            List<Zuora.zApi.SubscribeResult> listResults = IECSubscriptionManager.subscribe(listCartItems, loggedCustomer, ePmType, oPaymentMethod, lstAutoRenewFlags, oTnCComponentController.listTermsAndConditions, sPurchaseOrder);
            
            // parse the SubscribeResults into a list of SubscriptionResult to better display them in the vf page
            Integer i = 0;
            listSubscriptionResultToDisplay = new List<IECZuoraHelper.SubscriptionResult>();
            String sEmailRows = '', sTransactionNumber = '';
                    
            for (Zuora.zApi.SubscribeResult res : listResults) {
                
                String sProductName = listCartItems.get(i).Related_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Display_Name__c
                                        + ' - ' + listCartItems.get(i).Related_Rate_Plan_Information__r.Product_Rate_Plan__r.Name;
                                        
                String sAppURL = listCartItems.get(i).Related_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Application_URL__c;
                
                listSubscriptionResultToDisplay.add(new IECZuoraHelper.SubscriptionResult(res, sProductName, sAppURL));
                
                if (res.Success) {
                    
                    // Build the HTML Row for the CartItem to be used in the email notification
                    Decimal chargeTotal = 0;
                    for (zqu__ProductRatePlanCharge__c charge : mapRatePlanCharges.get(listCartItems.get(i).Related_Rate_Plan_Information__r.Product_Rate_Plan__c)) {
                        chargeTotal += charge.zqu__ListPrice__c;
                    }
                    
                    if (!String.IsEmpty(res.PaymentTransactionNumber) && !sTransactionNumber.contains(res.PaymentTransactionNumber))
                        sTransactionNumber += (String.isEmpty(sTransactionNumber) ? '': ', ') + res.PaymentTransactionNumber;
                    
                    sEmailRows +=   '<tr>'
                        + ' <td align="left" width="470" valign="top" style="font-family: Arial, Helvetica, Verdana, sans-serif; color:#969696; font-size: 15px; line-height:18px; font-weight:normal;padding: 0;">'
                        + '     ' + listCartItems.get(i).Related_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Display_Name__c + '&nbsp;-&nbsp;' + listCartItems.get(i).Related_Rate_Plan_Information__r.Product_Rate_Plan__r.Name
                        + ' </td>'
                    
	                    + ' <td align="left" class="spacer-col" width="15" valign="top">&nbsp;</td>'
	                    + ' <td align="right" style="font-family: \'Lucida Grande\', \'Lucida Sans\', \'Lucida Sans Unicode\', Arial, Helvetica, Verdana, sans-serif; color:#000000; font-size: 12px; line-height:18px;" valign="top">'
	                    + '   <div class="noWrapPrice"></div>'
	                    + ' </td>'
	                    + ' <td align="left" class="spacer-col" width="15" valign="top">&nbsp;</td>'
	                    + ' <td align="right" width="30" style="font-family: \'Lucida Grande\', \'Lucida Sans\', \'Lucida Sans Unicode\', Arial, Helvetica, Verdana, sans-serif; color:#000000; font-size: 12px; line-height:18px;" valign="top">'
	                    + ' </td>'
                        
                        + ' <td width="97" class="paddingClass2" align="center" valign="middle" style="font-family: Arial, Helvetica, Verdana, sans-serif; color: #969696; font-size: 15px; font-weight: normal; line-height: 18px; padding: 20px 0;">' + listCartItems.get(i).Quantity__c + '</td>'
                        + ' <td width="136" class="paddingClass1" align="right" valign="middle" style="font-family: Arial, Helvetica, Verdana, sans-serif; color: #969696; font-size: 15px; font-weight: normal; line-height: 18px; padding: 20px 20px 20px 0;">'
                        + '     <div class="noWrapPrice">USD ' + IECUtil.DecimalToString(chargeTotal * listCartItems.get(i).Quantity__c) + '</div>'
                        + ' </td>'
                        + '</tr>';
                                                
                        
                    IECShoppingCartHelper.removeCartItemById(listCartItems.get(i).Id);
                    iNbrSubscriptionSucceeded++;
                }
                else {
                    iNbrSubscriptionFailed++;
                }
                
                i++;
            }
              
            if (!String.isEmpty(sEmailRows)) {
                String sHtmlEmailBody = String.format('<table cellspacing="0" cellpadding="14" border="0" width="100%" style="border-top: 1px solid #d4d4d4; border-right: 1px solid #d4d4d4; border-left: 1px solid #d4d4d4; border-bottom: 1px solid #AAAAAA; -webkit-border-radius:5px;-moz-border-radius:5px; border-radius:5px; -moz-box-shadow: 0px 1px 1px #d4d4d4, inset 0px 0px 6px #d4d4d4; -webkit-box-shadow: 0px 1px 1px #d4d4d4, inset 0px 0px 6px #d4d4d4; box-shadow: 0px 1px 1px #d4d4d4, inset 0px 0px 6px #d4d4d4;" class="ap-contentbox">'
                    + ' <tr>'
                    + '     <td valign="middle" align="left" style="font-family: Arial, Helvetica, Verdana, sans-serif; color:#969696; font-size: 15px; line-height:18px;">'
                    + '         <table cellspacing="0" cellpadding="0" width="100%" style="">'
                    + '             <tr>'
                    + '                 <td valign="middle" width="58%" style="font-family: Arial, Helvetica, Verdana, sans-serif; color: #969696; font-size: 15px; line-height: 18px; text-transform:uppercase;padding: 20px 0 20px 20px;">'
                    + '                     <strong>Product Name</strong>'
                    + '                 </td>'
                    + '                <td valign="middle" width="19%" style="font-family: Arial, Helvetica, Verdana, sans-serif; color: #969696; font-size: 15px; line-height: 18px; text-transform:uppercase;padding: 20px 0; text-align:center;">'
                    + '                     <strong>Quantity</strong>'
                    + '                 </td>'
                    + '                 <td valign="middle" width="22%" style="font-family: Arial, Helvetica, Verdana, sans-serif; color: #969696; font-size: 15px; line-height: 18px; text-transform:uppercase;padding: 20px 20px 20px 0;" align="right">'
                    + '                     <strong>Price</strong>'
                    + '                 </td>'
                    + '             </tr>'
                    + '         </table>'
                    + '     </td>'
                    + ' </tr>'
                    + ' <tr>'
                    + '     <td valign="top" align="left" style="font-family: Arial, Helvetica, Verdana, sans-serif; color: #969696; font-size: 15px; line-height: 15px;padding:0;" width="100%">'
                    + '         <!-- start order list -->'
                    + '         <table cellspacing="0" cellpadding="0" border="0" class="app-order-row" width="100%" style="">'
                    + '             <!--start order item row -->'
                    + '             <tr>'
                    + '                 '
                    + '                 <td valign="top" align="left">'
                    + '                    <table cellspacing="10" height="1" cellpadding="0" border="0" width="100%" class="ap-9pxspacer">'
                    + '                       <tr>'
                    +'                          <td valign="top" height="1" align="left" style="font-size:6px; line-height: 0;"><img src="http://interne.bang-marketing.com/iata/facture-logo/border-1-dcdcdc.jpg" width="100%" height="1" style="border:0; display:block;" /></td>'
                    +'                        </tr>'
                    +'                      </table>'                    
                    + '                     <table cellpadding="5" cellspacing="0" border="0" width="103%">'
                    + '                         {0}'
                    + '                     </table>'
                    + '                 </td>'
                    + '             </tr>'
                    + '         </table>'
                    + '         <!-- End order list -->'
                    + '     </td>'
                    + ' </tr>'
                    + '</table>', new String[] {sEmailRows});

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
                            sPaymentMethod += pm.creditCardType + ' ' + pm.CreditCardMaskNumber ;
                            break;
                        }
                    }                   
                }
                IECEmailUtility.sendEmail(loggedCustomer.RelatedContact.Name, loggedCustomer.RelatedContact.Email, IECConstants.Email_Template_Order, sHtmlEmailBody, 'Items Purchased', sTransactionNumber, sPaymentMethod, shoppingCartTotalBeforeTax, shoppingCartTax, shoppingCartTotal);
            }
            
            // payment is considered successful if all subscriptions have succeeded
            paymentSucessful = (iNbrSubscriptionSucceeded == listCartItems.size());
            
            // refresh cart items
            refreshShoppingCartItems();
            
            // refresh Terms & Conditions acceptance
            oTnCComponentController.listProductInformationIDs = listProductInformationIDs;
            oTnCComponentController.reset();

            displayPopUp = false;       
            
            return; 

            
        }
        catch (Exception ex) {
            addErrorMessage(ex.getMessage());
            if (Test.isRunningTest())
                throw ex;
            return;
        }
    }
    
    
    
    
    //******************************
    public PageReference setSuccessParam(){
        
            PageReference cartPage = Page.IECShoppingCart;
            cartPage.getParameters().put('success','true');
            cartPage.setRedirect(true);
            return cartPage;
            
    }
    //******************************
    
    
    
    
    
    /**
     * Empty cart from all available rate plans
     */
    public PageReference clearShoppingCart() {      
        try {
            IEC_Shopping_Cart__c cart = IECShoppingCartHelper.getCurrentShoppingCart();
            IECShoppingCartHelper.emptyCart(cart);
            
            // refresh page
            PageReference cartPage = Page.IECShoppingCart;
            cartPage.setRedirect(true);
            return cartPage;
        }
        catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }
    }
    
    /**
     * Update shopping cart after user has updated the quantities for available products
     */
    public PageReference updateShoppingCart() {     
        try {
            
            clearError();
            
            for (IEC_Cart_Item__c cartItem : listCartItemsToDisplay) {
                IECShoppingCartHelper.updateCartItem(cartItem);
            }

            return null;
        }
        catch (Exception ex) {
            
            showAndKeepError(ApexPages.Severity.ERROR, ex.getMessage());

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
                System.debug('____ [cls VfIECShoppingCart - updateContactInfo] UpdateContactINfo - VATCONFIG.VATValidationRequired: ' + vatConfig);

                if (vatConfig != null && vatConfig.TaxIDMandatory) {
                    if (vatConfig.ShowTax1) {
                        if (String.isBlank(oContact.Tax_1_ID__c))
                            lstErrorMessages.add(Label.IEC_Error_Required_field + ' ' + vatConfig.Tax1Label);
                        else if (vatConfig.VATValidationRequired) {
                            IECVATUtil.VATWebService ws = new IECVATUtil.VATWebService();
                            try {
                                IECVATUtil.VATResponse res = ws.ValidateVAT(vatConfig.CountryCode, oContact.Tax_1_ID__c);
                                if (!res.valid) 
                                    lstErrorMessages.add(Label.IEC_Error_Invalid_VAT + vatConfig.Tax1Label);
                            }
                            catch (System.CalloutException ex) {
                                if (ex.getMessage().contains('SERVER_BUSY'))
                                    lstErrorMessages.add(Label.IEC_Error_VATWSBusy);
                                else
                                    lstErrorMessages.add(ex.getMessage());                              
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

                if (bStateAvailable && String.isBlank(oBillingAddress.ISO_State__c)) // Changed by Samy (2016-03-01) from State__c
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

                update oContact;
                

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

    
    /**
     * Apply any coupon discount and validate whether the coupon is valid
     */
     /*
    public PageReference applyCoupon() {        
        try {
            // TODO
            return null;
        }
        catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }
    }
    */
    
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
     * Displays the credit cards and check if the amount allows the different payment types
     */
    public void displayPaymentMethods() {
        try {
            
            bshoppingCartUpdated = true;
            
            paymentMethods = new List<IECZuoraHelper.PaymentMethod>();
            List<IEC_Payment_Threshold__c> lstThreshold = null;

            if (loggedCustomer.PaymentMethods != null && loggedCustomer.PaymentMethods.size() > 0) {
                paymentMethods = IECZuoraHelper.convertFromzObjectListToPaymentMethod(loggedCustomer.PaymentMethods);
            }
            
            // check all payment type for if they allow the total amount (with taxes)
            // (Bank Transfer out for now)
            //isPaymentAvailableWithBankTransfer = IECSubscriptionManager.canPurchaseAmountWithPaymentMethod(IECConstants.PaymentThresholdType_BankTransfer, shoppingCartTotal);
            
            // if the user can pay by ICH, check amount
            if (hasICHCode) {
                isPaymentAvailableWithICH = IECSubscriptionManager.canPurchaseAmountWithPaymentMethod(IECConstants.PaymentThresholdType_ICH, shoppingCartTotal);
                lstThreshold = IECSubscriptionManager.getPaymentMethodThresholdByType(IECConstants.PaymentThresholdType_ICH);
                dICHMinAmount = lstThreshold.isEmpty() ? 0.0 : lstThreshold.get(0).Min_amount__c;
            }
            
            // check for credit card
            isPaymentAvailableWithCreditCard = IECSubscriptionManager.canPurchaseAmountWithPaymentMethod(IECConstants.PaymentThresholdType_CreditCard, shoppingCartTotal);
            lstThreshold = IECSubscriptionManager.getPaymentMethodThresholdByType(IECConstants.PaymentThresholdType_CreditCard);
            dCreditCardMaxAmount = lstThreshold.isEmpty() ? 0.0 : lstThreshold.get(0).Max_amount__c;

            if (isPaymentAvailableWithCreditCard)
                loadHPMIframe();
                
            showMessagesInMemory();
        }
        catch (Exception ex) {
            addErrorMessage(ex.getMessage());
        }
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
     * Inner class to display te auto renew section
     */
    public class UICartItemAutoRenew {
        
        public IEC_Cart_Item__c cartItem { get; private set; }
        //public Boolean autoRenew { get; set; }
        public String autoRenewFlag { get; set; }
        
        /**
         * Constructor
         */
        public UICartItemAutoRenew(IEC_Cart_Item__c oCartItem) {
            cartItem = oCartItem;
            autoRenewFlag = null;
        }
    }
    
    
    
    public boolean displayPopUp {get; set;}
    
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



}