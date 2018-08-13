/**
  * Description: This class contains visualforce controller for the (IEC Renew) Page 
  * Author: Samy Saied
  * Version: 1.0
  * History: 
  */
public class vfIECRenew extends IECPageController {
    
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


    public String sParamSubscriptionId { get; set; }
    public String sParamProdInfoId { get; set; }
    public String sParamRatePlanInfoId { get; set; }
    public String sPurchaseOrder { get; set; }
    
    public boolean displayPopUp {get; set;}
    
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
    
    public Zuora__Subscription__c subscriptionObj {get; private set;}
    
    public Zuora__SubscriptionProductCharge__c subscriptionCharge {
        get {
            return (subscriptionObj.Zuora__Subscription_Product_Charges__r != null
                && subscriptionObj.Zuora__Subscription_Product_Charges__r.size() > 0)
                    ? subscriptionObj.Zuora__Subscription_Product_Charges__r.get(0)
                    : null;
        }
    }
    
    public Integer subscriptionChargeQuantity {
        get {
            return (subscriptionObj.Zuora__Subscription_Product_Charges__r != null)
                    ? subscriptionObj.Zuora__Subscription_Product_Charges__r.size()
                    : 0;
        }
    }
    
    public Date renewalEndDate {
        get {
            return (subscriptionObj != null)
                ? subscriptionObj.Zuora__SubscriptionEndDate__c.addMonths(Integer.valueOf(subscriptionObj.Zuora__RenewalTerm__c.replace(' Months', '')))
                : null; 
        }
    }
    
    public String sProductName {
        get {
            if (subscriptionObj != null) {
                List<Zuora__SubscriptionProductCharge__c> lstCharges = subscriptionObj.Zuora__Subscription_Product_Charges__r;
                return lstCharges.get(0).Zuora__ProductName__c + ' - ' + lstCharges.get(0).Zuora__RatePlanName__c;
            }
            return '';
        }
    }
    
    public Decimal renewTotalBeforeTax {get; private set;}
    public Decimal renewTax {get; private set;}
    public Decimal renewTotal {get; private set;}
    public List<UILineItemAutoRenew> lstLineItemAutoRenew { get; set; }
    public Boolean paymentSucessful { get; private set; }
    public String selectedPaymentMethodType { get; set; }
    public String selectedCreditCardPaymentId { get; set; }
    public Boolean hasICHCode { get; private set; }
    public String defaultPaymentMethodId { get; private set; }
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
    
    
    // properties for the integration of the T&C component
    public String[] listProductInformationIDs { get; private set; }
    public String TC_COMPONENT_KEY {
        get {
            return 'componentTnC';
        }
    } 
    public VfIECTermsAndConditionsComponent oTnCComponentController {
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
            
            if (lstLineItemAutoRenew == null || lstLineItemAutoRenew.isEmpty()) {
                bTemp = true;
            }
            else {
                Boolean bHasFlaggedAll = true;
                for (UILineItemAutoRenew cartItemAutoRenew : lstLineItemAutoRenew) {
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

    
    public Boolean isPaymentAvailableWithCreditCard { get; private set; }
    public Boolean isPaymentAvailableWithICH { get; private set; }
    public Boolean isPaymentAvailableWithBankTransfer { get; private set; }
    public String sErrorMsgFromHPM { get; set; }

    /**
     * Constructor
     */
    public vfIECRenew() {
        try {
            listProductInformationIDs = new String[]{};
            
            
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
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
    }
    
    /**
     * Action called after the page has loaded
     */
    public PageReference pageLoad() {
        try {
            paymentSucessful = null;
            lstLineItemAutoRenew = new List<UILineItemAutoRenew>();

            // first check if the user is logged in
            if (IECCustomer.getCurrentIECCustomer() == null) {
                Pagereference prLogin = Page.IECLogin;
                prLogin.getParameters().put(IECConstants.PARAM_RETURN_URL, IECUtil.EncryptEncodeParameter(ApexPages.currentPage().getUrl()));
                prLogin.getParameters().put(IECConstants.PARAM_WARNING_MSG, IECUtil.EncryptEncodeParameter(Label.IEC_Warning_Must_Login));
                prLogin.setRedirect(true);
                return prLogin;
            }
            else {
                // Validate Logged in user profile and ensure profile is complete
                validUserProfile();
                
                sParamSubscriptionId = ApexPages.currentPage().getParameters().get(IECConstants.PARAM_SUBSCRIPTION_ID);
                sParamProdInfoId = ApexPages.currentPage().getParameters().get(IECConstants.PARAM_PRODINFO_ID);
                sParamRatePlanInfoId = ApexPages.currentPage().getParameters().get(IECConstants.PARAM_RATEPLANINFO_ID);
            
                // Validate that there is parameter passed to the page
                if (String.isEmpty(sParamSubscriptionId)
                    || String.isEmpty(sParamProdInfoId)
                    || String.isEmpty(sParamRatePlanInfoId)) {
                    addErrorMessage(Label.IEC_Error_InvalidPageParameter);
                }
                else {
                    // Decrypt parameter before using it
                    sParamSubscriptionId = IECUtil.DecodeDecryptParameter(sParamSubscriptionId);
                    sParamProdInfoId = IECUtil.DecodeDecryptParameter(sParamProdInfoId);
                    sParamRatePlanInfoId = IECUtil.DecodeDecryptParameter(sParamRatePlanInfoId);
                    
                    // logic was changed for determining access to ICH
                    hasICHCode = loggedCustomer.canPayByICH();
                
                    if (loggedCustomer.AccountExistsInZuora)
                        defaultPaymentMethodId = (String)loggedCustomer.RelatedZuoraAccount.getValue('DefaultPaymentMethodId');
                    else
                        defaultPaymentMethodId = null;

                    subscriptionObj = IECSubscriptionManager.getSubscriptionById(sParamSubscriptionId);
                    // set the parameter to the T&C component
                    listProductInformationIDs = new String[]{ sParamProdInfoId };
                    
                    lstLineItemAutoRenew.add(new UILineItemAutoRenew(subscriptionCharge));

                    refreshRenewTotal();
                }
                
                    
                    
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
        }
        catch (Exception ex) {
            addErrorMessage(ex.getMessage());
        }
        return null;
    }
    
    /**
     * Navigate to the subscription page
     */
    public Pagereference onClickCancel() {
        try {
            Pagereference pgRef = Page.IEC_DataStatisticsSubscriptions;
            pgRef.getParameters().put(IECConstants.PARAM_SUBSCRIPTION_ID, IECUtil.EncryptEncodeParameter(sParamSubscriptionId));
            pgRef.setRedirect(true); 
            return pgRef;
        }
        catch (Exception ex) {
            addErrorMessage(ex.getMessage());
        }
        return null;
    }
    
    /**
     * Query zuora to determine the total for the current cart also to display the tax part
     */
    public void refreshRenewTotal() {
        try {
            // parse the selected payment method type
            IECConstants.PaymentType ePmType = IECConstants.parsePaymentMethodToEnum(selectedPaymentMethodType);
            
            Zuora.zApi.AmendResult result = IECSubscriptionManager.renewSubscription(loggedCustomer, subscriptionObj.Name, subscriptionObj.Zuora__Zuora_Id__c, Id.valueOf(sParamRatePlanInfoId), subscriptionChargeQuantity, subscriptionObj.Zuora__SubscriptionEndDate__c.addDays(1), lstLineItemAutoRenew.get(0).autoRenew, true, ePmType, null, null, sPurchaseOrder);

            if (result.Success) {
                Zuora.zObject invoice;
                if (result.InvoiceDatas != null) {
                    for (Zuora.zObject invData: result.InvoiceDatas) {
                        invoice = (Zuora.zObject) invData.getValue('Invoice');
                        break;
                    }
                    renewTotalBeforeTax = (Decimal) invoice.getValue('AmountWithoutTax');
                    renewTax = (Decimal) invoice.getValue('TaxAmount');
                    renewTotal = (Decimal) invoice.getValue('Amount');
                }
            }
            else
                addErrorMessage(Label.IEC_Error_CannotPreview + IECZuoraHelper.getErrorMessagesString(result.Errors, '<BR> - '));
            
            // display payment methods
            displayPaymentMethods();
            loadHPMIframe();
        }
        catch (Exception ex) {
            addErrorMessage(ex.getMessage());
        }
    }
        
    /**
     * Proceeds to renew the subscription
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
                throw new IECApplicationException(IECConstants.Error_AcceptTermAndCondition);
                
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
            
            // Renew Call
            Zuora.zApi.AmendResult result = IECSubscriptionManager.renewSubscription(loggedCustomer, subscriptionObj.Name, subscriptionObj.Zuora__Zuora_Id__c, Id.valueOf(sParamRatePlanInfoId), subscriptionChargeQuantity, subscriptionObj.Zuora__SubscriptionEndDate__c.addDays(1), lstLineItemAutoRenew.get(0).autoRenew, false, ePmType, oPaymentMethod, oTnCComponentController.listTermsAndConditions, sPurchaseOrder);

            if (result.Success) {
                String sSucessMsg = 'You successfully renewed your subscribed to ' + sProductName + '. <br />';
                String sAppURL = subscriptionObj.Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Application_URL__c;
                
                if (String.isNotBlank(sAppURL) && (ePmType == IECConstants.PaymentType.ICH || ePmType == IECConstants.PaymentType.CREDIT_CARD))
                    sSucessMsg += String.format('You can access the application here <a href=\"{0}\">{1}</a><br /><br />', new String[] {sAppURL, sAppURL});
                
                if (ePmType != IECConstants.PaymentType.ICH)
                    sSucessMsg += String.format('You can access the invoice <a href=\"{0}\">{1}</a><br /><br />', new String[] {URL.getSalesforceBaseUrl().toExternalForm() + URL.getCurrentRequestUrl().getPath().replace('iecrenew', 'iec_myinvoices'), 'here'});

                if (String.isNotBlank(result.PaymentTransactionNumber))
                    sSucessMsg += 'Transaction #: ' + result.PaymentTransactionNumber + '<br />';

                sSucessMsg += 'Subscription : ' + subscriptionObj.Name + '<br />' +
                    'Subscription Start Date: ' + subscriptionObj.Zuora__SubscriptionStartDate__c + '<br />' +
                    'Subscription End Date: ' + renewalEndDate + '<br />' +
                    'Auto-Renew: ' + ((lstLineItemAutoRenew.get(0).autoRenew) ? 'Yes' : 'No') + '<br />';
                
                addConfirmMessage(sSucessMsg);
                
                // payment is considered successful if renewal has succeeded
                paymentSucessful = true;
                
                // Send HTML email containing summary for the order
                String sHtmlEmailBody = '<table cellspacing="0" cellpadding="14" border="0" width="100%" style="border-top: 1px solid #d4d4d4; border-right: 1px solid #d4d4d4; border-left: 1px solid #d4d4d4; border-bottom: 1px solid #AAAAAA; -webkit-border-radius:5px;-moz-border-radius:5px; border-radius:5px; -moz-box-shadow: 0px 1px 1px #d4d4d4, inset 0px 0px 6px #d4d4d4; -webkit-box-shadow: 0px 1px 1px #d4d4d4, inset 0px 0px 6px #d4d4d4; box-shadow: 0px 1px 1px #d4d4d4, inset 0px 0px 6px #d4d4d4;" class="ap-contentbox">'
                    + ' <tr>'
                    + '     <td valign="top" align="left" style="font-family: Arial, Helvetica, Verdana, sans-serif; color:#969696; font-size: 15px; line-height:18px;">'
                    + '         <table cellspacing="0" cellpadding="0" width="100%" style="">'
                    + '             <tr>'
                    + '                 <td valign="top" width="59%" style="font-family: Arial, Helvetica, Verdana, sans-serif; color: #969696; font-size: 15px; line-height: 18px; text-transform:uppercase;padding: 20px 0 20px 20px;">'
                    + '                     <strong>Item(s) </strong>'
                    + '                 </td>'
                    + '                 <td valign="top" width="19%" style="font-family: Arial, Helvetica, Verdana, sans-serif; color: #969696; font-size: 15px; line-height: 18px; text-transform:uppercase;padding: 20px 0; text-align:center;">'
                    + '                     <strong>Quantity</strong>'
                    + '                 </td>'
                    + '                 <td valign="top" width="22%" style="font-family: Arial, Helvetica, Verdana, sans-serif; color: #969696; font-size: 15px; line-height: 18px; text-transform:uppercase;padding: 20px 20px 20px 0;" align="right">'
                    + '                     <strong>Price</strong>'
                    + '                 </td>'
                    + '             </tr>'
                    + '         </table>'
                    + '     </td>'
                    + ' </tr>'
                    + ' <tr>'
                    + '     <td valign="top" align="left" style="font-family: Arial, Helvetica, Verdana, sans-serif; color: #969696; font-size: 15px; line-height: 15px;padding:0;" width="100%">'
                    + '         <!-- start order list -->'
                    + '         <table cellspacing="5" cellpadding="5" border="0" class="app-order-row" width="104%" style="">'
                    + '             <!--start order item row -->'
                    + '             <tr>'
                    + '                 '
                    + '                 <td valign="top" align="right" style="">'
                    + '                 <table cellspacing="10" height="1" cellpadding="0" border="0" width="100%" class="ap-9pxspacer">'
                    + '                  <tr>'
                    +'                     <td valign="top" height="1" align="left" style="font-size:6px; line-height: 0;"><img src="http://interne.bang-marketing.com/iata/facture-logo/border-1-dcdcdc.jpg" width="100%" height="1" style="border:0; display:block;" /></td>'
                    +'                    </tr>'
                    +'                 </table>'
                    + '                     <table cellpadding="5" cellspacing="0" border="0" width="100%">'
                    + '                         <tr>'
                    + '                             <td align="left" width="470" valign="top" style="font-family: Arial, Helvetica, Verdana, sans-serif; color:#969696; font-size: 15px; line-height:18px; font-weight:normal;padding: 0;">'
                    + '                                 ' + sProductName + '<BR/>New Service End Date:&nbsp;' + DateTime.newInstance(renewalEndDate, Time.newInstance(1, 1, 1, 1)).format('MMM d yyyy')
                    + '                             </td>'
                    + '                             <td align="left" class="spacer-col" width="15" valign="top">&nbsp;</td>'
                    + '                             <td align="right" style="font-family: \'Lucida Grande\', \'Lucida Sans\', \'Lucida Sans Unicode\', Arial, Helvetica, Verdana, sans-serif; color:#000000; font-size: 12px; line-height:18px;" valign="top">'
                    + '                                 <div class="noWrapPrice"></div>'
                    + '                             </td>'
                    + '                             <td align="left" class="spacer-col" width="15" valign="top">&nbsp;</td>'
                    + '                             <td align="right" width="30" style="font-family: \'Lucida Grande\', \'Lucida Sans\', \'Lucida Sans Unicode\', Arial, Helvetica, Verdana, sans-serif; color:#000000; font-size: 12px; line-height:18px;" valign="top">'
                    + '                             </td>'
                    + '                             <td width="97" align="center" valign="middle" style="font-family: Arial, Helvetica, Verdana, sans-serif; color:#969696; font-size: 15px; font-weight:normal; line-height:18px; padding: 20px 0;">' + subscriptionChargeQuantity + '</td>'
                    + '                             <td width="136" align="right" valign="middle" style="font-family: Arial, Helvetica, Verdana, sans-serif; color:#969696; font-size: 15px; font-weight:normal; line-height:18px; padding: 20px 20px 20px 0;">'
                    + '                                 <div class="noWrapPrice">USD ' + IECUtil.DecimalToString(subscriptionCharge.Zuora__Price__c * subscriptionChargeQuantity) + '</div>'
                    + '                             </td>'
                    + '                         </tr>'
                    + '                     </table>'
                    + '                 </td>'
                    + '             </tr>'
                    + '         </table>'
                    + '         <!-- End order list -->'
                    + '     </td>'
                    + ' </tr>'
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
                            sPaymentMethod += pm.creditCardType + ' ' + pm.CreditCardMaskNumber ;  //+ '<BR>' + pm.creditCardExpirationMonth + '/' + pm.creditCardExpirationYear
                            break;
                        }
                    }                   
                }
                IECEmailUtility.sendEmail(loggedCustomer.RelatedContact.Name, loggedCustomer.RelatedContact.Email, IECConstants.Email_Template_Order, sHtmlEmailBody, 'Subsciption Renewed (' + subscriptionObj.Name + ')', result.PaymentTransactionNumber, sPaymentMethod,  renewTotalBeforeTax, renewTax, renewTotal);
            }
            else {
                // payment is considered successful if renewal has succeeded
                paymentSucessful = false;
                addErrorMessage(String.format(Label.IEC_Error_CannotRenew, new String[] {sProductName, IECZuoraHelper.getErrorMessagesString(result.Errors, '<BR> - ')}));
            }
        }
        catch (Exception ex) {
            addErrorMessage(ex.getMessage());
        }
    }
        
    /**
     * Specify extra HPM parameters that can be used to (1) Preload field values (2) Override default HPM properties.  Please see 
     * HPM Implementation Guide for a complete list of HPM parameters.
     */
    public Map<String, String> getExtraParameters() {
        return new Map<String, String> {
            'field_maxConsecutivePaymentFailures' => '1', 
            'field_maxConsecutivePaymentFailures' => '1', 
            'field_creditCardType' => 'Visa',
            'field_accountId' => (loggedCustomer.RelatedZuoraAccount == null) ? '' : (String)loggedCustomer.RelatedZuoraAccount.getValue('Id')
        }; 
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
            //isPaymentAvailableWithBankTransfer = IECSubscriptionManager.canPurchaseAmountWithPaymentMethod(IECConstants.PaymentThresholdType_BankTransfer, renewTotal);
            
            // if the user can pay by ICH, check amount
            if (hasICHCode) {
                isPaymentAvailableWithICH = IECSubscriptionManager.canPurchaseAmountWithPaymentMethod(IECConstants.PaymentThresholdType_ICH, renewTotal);
                lstThreshold = IECSubscriptionManager.getPaymentMethodThresholdByType(IECConstants.PaymentThresholdType_ICH);
                dICHMinAmount = lstThreshold.isEmpty() ? 0.0 : lstThreshold.get(0).Min_amount__c;
            }
            
            isPaymentAvailableWithCreditCard = IECSubscriptionManager.canPurchaseAmountWithPaymentMethod(IECConstants.PaymentThresholdType_CreditCard, renewTotal);
            lstThreshold = IECSubscriptionManager.getPaymentMethodThresholdByType(IECConstants.PaymentThresholdType_CreditCard);
            dCreditCardMaxAmount = lstThreshold.isEmpty() ? 0.0 : lstThreshold.get(0).Max_amount__c;
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
    public class UILineItemAutoRenew {
        
        public Zuora__SubscriptionProductCharge__c lineItem { get; private set; }
        public Boolean autoRenew {
            get {
                return (autoRenewFlag == 'true') ? true : false;
            }
        }
        public String autoRenewFlag { get; set; }
        
        /**
         * Constructor
         */
        public UILineItemAutoRenew(Zuora__SubscriptionProductCharge__c oLineItem) {
            lineItem = oLineItem;
            autoRenewFlag = null;
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
}