global without sharing class IEC_ShippingController extends IEC_PageController 
{
    public Order sfOrder{get;set;}
    public Order_DTO vfOrder{get;set;} 

    public Boolean bAreProductsCompliant; //validate all products in the cart are country compliant 

    public String updateItemId{get;set;}
    //public OrderItem_DTO updateItem{get;set;}

    public List<SelectOption> shippingAddresses{get{
        return fetchShippingAddresses();
    }set;}

    public Address_DTO newShipToAddress{get;set;}

    public Map<Id, Boolean> mapProduct2Id_Compliance;
    
    //TC map to know which countries don't have zip code
    public Map<String, Boolean> zipCodeApplicableMap {
        get{
            return zipCodeApplicableMap != null ? zipCodeApplicableMap : new Map<String, Boolean>();
        }
        set;
    }

    public List<SelectOption> availableCountries{get{
        if(availableCountries == null){
            //TC get options and fill map zipCodeApplicable
            Map<String, Object> countries = ISO_Country_State_Helper.getCountriesOptionsMap();
            availableCountries = (List<SelectOption>) countries.get('options');
            zipCodeApplicableMap = (Map<String, Boolean>) countries.get('zipCodeApplicable');
        }
        return availableCountries;
    }set;}

    //TC 
    public Boolean unlockZipCode {
        get{
            return newShipToAddress != null && !String.isBlank(newShipToAddress.countryCode) && 
                zipCodeApplicableMap.get(newShipToAddress.countryCode) != null && zipCodeApplicableMap.get(newShipToAddress.countryCode);
        }
        set;
    }

    public List<SelectOption> newAddressAvailableStates{get;set;}

    //Generate Quote 
    public String quoteGeneratedMsg{get;set;}
    public Boolean quoteGenerated{get;set;}
    public Order quote{get;set;}


    public List<String> paymentMethods{get;set;}
    public List<IEC_CreditCard_DTO> creditcards{get;set;}
    public Map<String, IEC_CreditCard_DTO> creditCardById;
    public IEC_CreditCard_DTO selectedCreditCard{get;set;}
    public String selectedCreditCardId{get;set;}
    public String newCreditCardPaymentId { get; set; }
    public String defaultPaymentMethodId{get;set;}
    public String orderPaymentType{get;set;}
    public String orderCreditCardId{get;set;}
    public Boolean recreateZuoraAccount;

    public boolean hasConfigError { get; set; }
    public String  sErrorMsgFromHPM { get; set; }
    public String  iframeSrc { get; set; }
    private String errorMessage;
    private String errorCode;
    private String pageId; 
    private String apiSecurityKey;
    private String appUrl; 
    private String tenantId; 

    //public String newPaymentMethodZid{get;set;}
    //public String successMessage{get;set;}
    
    Id currentShipToLocationId;
    String currentShipToPartner;
    //Boolean forceShipToCustomerToSAP;   //*** indicate customer needs to be sent to SAP immediately
    public Boolean recalculateFreightTax;

    public Boolean taxFreightCalculateWithError {get;set;}

    public Boolean stopProcess { get; set; }
    public Boolean isShipToError { get; set; }
    public Boolean showNewAddress { get; set; }

    public String getExtraParamString(){
        String extraParam = ''; 
        Map<String, String> extraParameters = getExtraParameters(); 
        for ( String param : extraParameters.keySet() ) 
        {
            extraParam += '&' + param + '=' + extraParameters.get( param ); 
        }
        return extraParam;
    } 

    public Map<String, String> getExtraParameters(){
        return new Map<String, String> {
            'field_maxConsecutivePaymentFailures' => '1', 
            'field_maxConsecutivePaymentFailures' => '1', 
            'field_creditCardType' => 'Visa',
            'field_accountId' => (loggedCustomer.zAccount == null) ? '' : (String) loggedCustomer.zAccount.getValue('Id')
        }; 
    }


    public Map<String, String> labels { get; set; }
    public Map<String,String> discountLabels{get;set;}


    //Used for google analytics
    public String productWrapper {
        get {
            Map<String,Object> ecommObj = new Map<String,Object>();
            Map<String,Object> checkoutObj = new Map<String,Object>();
            Map<String,Object> actionObj = new Map<String,Object>();
            Map<String,Object> prodObj = new Map<String,Object>();

            ecommObj.put('checkout', checkoutObj);
            actionObj.put('step',2);
            checkoutObj.put('actionField', actionObj);
            checkoutObj.put('products', new List<Object> {prodObj});

            List<OrderItem_DTO> lstOrderItemsAux = storeCart.getOrderItems();
            if(lstOrderItemsAux != null && !lstOrderItemsAux.isEmpty()){
                List<Object> lstOrderItems = new List<Object>();
                for(OrderItem_DTO orderItemDtoAux : lstOrderItemsAux){
                    Map<String,Object> orderItemsObjMap = new Map<String,Object>();

                    orderItemsObjMap.put('id', orderItemDtoAux.productNumber);
                    orderItemsObjMap.put('name', orderItemDtoAux.productName);
                    orderItemsObjMap.put('category', orderItemDtoAux.productCategory);
                    orderItemsObjMap.put('price', orderItemDtoAux.unitPrice == null ? 0.00 : orderItemDtoAux.unitPrice);
                    orderItemsObjMap.put('brand', orderItemDtoAux.productBrand);
                    orderItemsObjMap.put('quantity', orderItemDtoAux.quantity);
                    orderItemsObjMap.put('dimension1', orderItemDtoAux.productEdition);
                    orderItemsObjMap.put('dimension2', orderItemDtoAux.productLanguage);
                    orderItemsObjMap.put('dimension3', orderItemDtoAux.productInventoryStatus);
                    orderItemsObjMap.put('dimension4', orderItemDtoAux.productAvailabilityDate);
                    orderItemsObjMap.put('dimension5', orderItemDtoAux.productMedia);
                    orderItemsObjMap.put('dimension6', orderItemDtoAux.productEffectiveTo);

                    lstOrderItems.add(orderItemsObjMap);
                }
            
                checkoutObj.put('products', lstOrderItems);
            }

            return JSON.serialize(ecommObj);
        }
        set;
    }

    public String cartProducts {
        get {

            cartProducts = '';
            if(vfOrder.orderItems != null && !vfOrder.orderItems.isEmpty()){
                List<String> lstProductNames = new List<String>();
                for(OrderItem_DTO orderItemAux : vfOrder.orderItems){
                    lstProductNames.add(orderItemAux.productName);
                }
                cartProducts = String.join( lstProductNames,' - ');
            }

            cartProducts = JSON.serialize(cartProducts);

            return cartProducts;

        }
        set;
    }


    public IEC_ShippingController() 
    {
        taxFreightCalculateWithError = false;
        labels = Utility.buildMapFromString(Label.LabelsVF_Order + '\n' + Label.LabelsVF_Order2 + '\n' + Label.LabelsVF_Order3, '\n', ':');
        discountLabels = Utility.buildMapFromString(Label.Labels_IECDiscountType, '\n', ':');
        recreateZuoraAccount=false;//Used to force zAccount recreation for unit test purpose
    }

    public void initializeOrder()
    {
        sfOrder = IECOrder_Svc.getPenddingOrder(true);
        orderPaymentType = sfOrder.Payment_Type__c;

        //*** check if sold to and bill to partner are valid
        isShipToError = false;
        if (String.isBlank(sfOrder.SoldToAccount_Partner_Number__c) || String.isBlank(sfOrder.BillToContact_Partner_Number__c))
        {
            stopProcess = true;
            addErrorMessage(Label.IEC_SAP_Customer_Issue);
            return;
        }
        else if (String.isBlank(sfOrder.ShipToContact_Partner_Number__c))
        {
            isShipToError = true;
            addErrorMessage(Label.IEC_SAP_Customer_Shipping_Address_Issue);
        }

        OrderItem_Sel oiSelector = new OrderItem_Sel();
        List<OrderItem> pendingOrderItems = oiSelector.getOrderItems(sfOrder.Id);
        
        // Ecommerce Enhancements R2 - dont re-add to cart because it's already serialized and user might cancel or
        //                             click elsewhere (IATA logo) and return to homepage with cart item re-added.
        //refreshCookieContent(pendingOrderItems, false);//@todo: revalidate
        IECOrder_Svc.deleteAllCookies();

        if (!isShipToError)
        {
            String tx = Order_Svc.getSAP_Freight_Tax(sfOrder.Id);
            //system.debug('tx ' + tx);
            
            if(tx != null && tx.startsWith('Error')){
                addErrorMessage('Error found in Freight & Taxes calculation ' + tx);
                taxFreightCalculateWithError = true;
            }
        }
        
        sfOrder = IECOrder_Svc.getPenddingOrder(sfOrder.Id);
        
        vfOrder = new Order_DTO(sfOrder);
        
        if(sfOrder.ShipTo_Location__c != null){
            currentShipToLocationId = sfOrder.ShipTo_Location__c;
            Location_Sel selector = new Location_Sel();
            Map<Id,Location__c> mapShippingLocation = selector.getLocationById(new Set<Id>{sfOrder.ShipTo_Location__c});
            Location__c shippingLocation = mapShippingLocation.get(sfOrder.ShipTo_Location__c);
            currentShipToPartner = shippingLocation.SAP_Id__c;
        }         
    }

    /**************************************************************************************************************
     *  onLoadAction: method calls when page loaded                                                               *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
    public PageReference onLoadAction()
    {
        if(loggedCustomer == null)
        {
            //-- redfirect to login 
            PageReference pgRef = new PageReference('/IEC_Login?returl=/IEC_Shipping');
            pgRef.setRedirect(true);
        
            return pgRef;
        }

        //*** initialize default locations for first time customer
        stopProcess = false;
        showNewAddress = false;
        List<String> lstError = Location_Svc.initializeDefaultLocations(new List<Id>{loggedCustomer.sfContact.Id});
        if (lstError[0] != null && (lstError[0].startsWith('\nST') || lstError[0].startsWith('\nBT')))
        {
            stopProcess = true;
            addErrorMessage(Label.IEC_SAP_Customer_Issue);
            return null;
        }
        if (loggedCustomer.billTo == null || loggedCustomer.shipTos == null || loggedCustomer.shipTos.size() == 0)
        {
            loggedCustomer = Customer_DTO.getCustomerByUser(UserInfo.getUserId());
            Customer_DTO.setCustomerAddresses(loggedCustomer);
        }

        if(cartContent.isEmpty()){addErrorMessage(Label.Warning_Empty_Cart);return null;}

        //-- Load Cybersource Iframe to add card
        loadHPMIframe();

        loadCreditCards();

        initializeOrder();
        if (stopProcess == true)
            return null;
     
        //-- Validate cart is not empty 
        if(vfOrder.orderItems==null || vfOrder.orderItems.size() == 0){addErrorMessage(Label.Warning_Empty_Cart);return null;}
        
        //-- Validate compliance 
        validateCountryCompliance(); 

        //-- Initialize default attributes
        newShipToAddress = new Address_DTO();
        newShipToAddress.attention = loggedCustomer.sfContact.Name;
        newShipToAddress.phone = loggedCustomer.sfContact.Phone;
        newShipToAddress.email = loggedCustomer.sfContact.Email;
        newAddressAvailableStates = new List<SelectOption>();

        fetchCustomerPaymentMethods();      

        return null;
    }

    /**************************************************************************************************************
     *  generateQuote: method calls when clicks "Generate Quote" button                                           *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
    public PageReference generateQuote()
    {
        if (!bAreProductsCompliant) 
        {
            addErrorMessage(labels.get('msgErrorCartNotCompliant'));return null;
        }
    
        sfOrder.Type = 'Quote';
        sfOrder.EffectiveDate = System.today();
        sfOrder.EndDate = sfOrder.EffectiveDate.addDays(Utility.getIntegerSetting('Quote Nb Days Valid'));
        update sfOrder;

        quoteGeneratedMsg = 'Your Quote was successfully registered. <br /> Quote number : ' + sfOrder.OrderNumber + '<br /> You will receive an email with a PDF copy of your Quote. <br /> Please follow the instructions contained in the e-mail to confirm and pay for your Quote.';
        
        quote = sfOrder;//new Order_Sel().getQuoteDetails(sfOrder.Id);

        labels = Utility.buildMapFromString(Label.LabelsVF_IECQuoteList, '\n', ':');
        
        quoteGenerated = true;

        addConfirmMessage(quoteGeneratedMsg);

        IECOrder_Svc.deleteAllCookies();
        return null;
    }


    /**************************************************************************************************************
     *  refreshCookieContent: method calls to refresh the cookie containing the cart data with database data    *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
    public void refreshCookieContent(List<OrderItem> orderItems, Boolean overideCookieContent)
    {
        String cookie_Sync = IECOrder_Svc.readCookie('Cookie_Sync');
        
        if(overideCookieContent)
        {
            //-- Replace cookie content with OrderItems
            IECOrder_Svc.deleteAllCookies();

            for(OrderItem oi : orderItems)
                IECOrder_Svc.addProductToCookie(oi.Product_Number__c, oi.Quantity, true);
        }
        else if(cookie_Sync != 'true')
        {
            //-- Add OrderItems to Cookie if not synched yet 
            Map<String, Decimal> cookieContent =  IECOrder_Svc.getItemsInCookie();

            for(OrderItem oi : orderItems)
            {
                //-- Product already in cookie 
                if(cookieContent.containsKey(oi.Product_Number__c)) IECOrder_Svc.modifiedProductToCookie(oi.Product_Number__c, /*oi.Quantity + */cookieContent.get(oi.Product_Number__c));
                    
                //-- New product     
                else IECOrder_Svc.addProductToCookie(oi.Product_Number__c, oi.Quantity, true);
            }

            //-- Create Cookie_Sync entry
            Cookie c = new Cookie('Cookie_Sync','true', null, Utility.getIntegerSetting('IEC Order Cookie maxAge'), false);
            ApexPages.currentPage().setCookies(new Cookie[]{c});
        }   
    }

    /**************************************************************************************************************
     *  refreshCreditCards: method to reload customers credit cards list from Zuora                               *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
    public void refreshCreditCards()
    {
        creditCards = loggedCustomer.creditCards;
    
        creditCardById = new Map<String, IEC_CreditCard_DTO>(); 
        for(IEC_CreditCard_DTO cc : creditCards){
            creditCardById.put(cc.zId, cc);
            if(cc.isDefault) defaultPaymentMethodId = cc.zId;
        }
    }

    /**************************************************************************************************************
     *  setSelectedCreditCard: method calls from visualforce page when customer click "Edit" or "Remove" link     *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
    public void setSelectedCreditCard()
    {
        String zId = ApexPages.currentPage().getParameters().get('zId');
        for(IEC_CreditCard_DTO cc : creditCards)
        {
            if(cc.zId == zId)
            {
                selectedCreditCard = cc;
                break;
            }
        }
    }

    /**************************************************************************************************************
     *  addCreditCard: callback when credit card added successfully                                               *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
    public PageReference addCreditCard()
    {
        if (String.isBlank(newCreditCardPaymentId)) addErrorMessage(Label.IEC_Error_HostedPaymentIdMissing);
        else
        {
          if(loggedCustomer.zAccount == null || recreateZuoraAccount)
          {
            //Create Zuora Account
            Zuora.zObject zAccount = IECZuoraHelper.createZuoraAccount(loggedCustomer.sfAccount, loggedCustomer.sfContact, IECConstants.PaymentType.CREDIT_CARD, newCreditCardPaymentId);
              zAccount.setValue('Status','Draft');
              zAccount.setValue('AutoPay', false);
            List<Zuora.zApi.SaveResult> accountCreateRes = ZuoraUtil.zcreate(new List<Zuora.zObject>{zAccount}, false);    
            
            zAccount = ZuoraUtil.getZuoraAccountBySFAccountId(loggedCustomer.sfAccount.Id, loggedCustomer.sfContact.Id);  

            //Create zContact
            Zuora.zObject zContact  = ZuoraUtil.createZuoraBillToContact(loggedCustomer.sfContact);
              zContact.setValue('AccountId',zAccount.getValue('Id'));
            List<Zuora.zApi.SaveResult> contactCreateRes = ZuoraUtil.zcreate(new List<Zuora.zObject>{zContact}, false);
            
            zAccount.setValue('Status','Active');
            zAccount.setValue('BillToId',contactCreateRes[0].Id);
            zAccount.setValue('SoldToId',contactCreateRes[0].Id);
            List<Zuora.zApi.SaveResult> accountUpdateRes = ZuoraUtil.zupdate(new List<Zuora.zObject>{zAccount});

            IECSubscriptionManager.OnDemandSyncAccounts(new Set<String>{(String)zAccount.getValue('Id')});
            
            loggedCustomer.zAccount = ZuoraUtil.getZuoraAccountBySFAccountId(loggedCustomer.sfAccount.Id, loggedCustomer.sfContact.Id);  
          }

            loggedCustomer.loadCreditCards();
            refreshCreditCards();
            
            //if Customer have only one credit card set it as default
            if(creditCards.size() == 1 && creditCards[0].isDefault == false){
                Zuora.zObject zAccount = new Zuora.zObject('Account');
                zAccount.setValue('Id', loggedCustomer.zAccount.getValue('Id'));
                zAccount.setValue('AutoPay', true);
                zAccount.setValue('DefaultPaymentMethodId', newCreditCardPaymentId);
                List<Zuora.zApi.SaveResult> accountUpdateRes = ZuoraUtil.zupdate(new List<Zuora.zObject>{zAccount});
            }

            //set the Account default payment method
            loggedCustomer.zAccount = ZuoraUtil.getZuoraAccountBySFAccountId(loggedCustomer.sfAccount.Id, loggedCustomer.sfContact.Id);
            refreshCreditCards();

            for(IEC_CreditCard_DTO iecCreditCard : creditCards){
                if(loggedCustomer.zAccount.getValue('DefaultPaymentMethodId') == iecCreditCard.zId){
                    iecCreditCard.isDefault = true;
                    orderCreditCardId = (String)loggedCustomer.zAccount.getValue('DefaultPaymentMethodId');
                }
            }

            orderPaymentType = IECConstants.PaymentThresholdType_CreditCard;
            

            loadHPMIframe();

            addConfirmMessage('The credit card  has been successfully added.');
        }

        hasError = false;

        return null;
    }

    /**************************************************************************************************************
     *  displayCallBackfailure: callback when credit card added unsuccessfully                                    *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
    public Pagereference displayCallBackfailure() 
    {
        String errMsg = ApexPages.currentPage().getParameters().get('errMsg');
        
        PageReference curPage = new Pagereference(URL.getSalesforceBaseUrl().toExternalForm() + Site.getPathPrefix() + errMsg);
        
        system.debug('curPage ' + curPage.getParameters());
        
        Boolean validationError = false;
        
        List<String> validationErrors = new List<String>();
        for ( String errorField : IECErrorCodeMapping.ERROR_FIELD_MAPPING.keySet() ) {
            
            system.debug('errorField ' + errorField);
            String errorFieldValue = curPage.getParameters().get( errorField ); 
            
            system.debug('errorFieldValue ' + errorFieldValue);
            
            if ( errorFieldValue != null && errorFieldValue.trim().length() > 0 ) {
                addErrorMessage( IECErrorCodeMapping.ERROR_FIELD_MAPPING.get( errorField ) + ': ' + IECErrorCodeMapping.VALUES.get( errorFieldValue ) ); 
                validationError = true;
            }
        }
        
        //if No validation Error verified if they are some Transactions errors
        if(!validationError){
            String errorMessage = curPage.getParameters().get('errorMessage');
            if(errorMessage != null && errorMessage != ''){
                addErrorMessage(errorMessage);
            }
        }
        
        loadHPMIframe();
        //addErrorMessage();
        return null; 
    }

    /**************************************************************************************************************
     *  removeCreditCard: method to perform credit card deletion                                                  *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
    public PageReference removeCreditCard()
    {
        try {
            
            if (selectedCreditCard.isDefault) {
                addErrorMessage(Label.IEC_Error_DeleteDefaultPayment);return null;
            }
            
            Zuora.zApi.DeleteResult result;
            
            if (!Test.isRunningTest())  result = IECZuoraHelper.deleteCreditCard(selectedCreditCard.zId); 
            else {
                result = new Zuora.zApi.DeleteResult();
                result.Success = true;
            }
             
            if (result.Success) {
                loggedCustomer.loadCreditCards();
                refreshCreditCards();

                addConfirmMessage('The credit card ' + selectedCreditCard.creditCardMaskNumber + ' has been successfully deleted.');
            }
            else addErrorMessage('Delete credit card failed for the following reason(s):' + IECZuoraHelper.getErrorMessagesString(result.Errors, '<BR> - '));
            
            return null;
        }
        catch (Exception ex) {addErrorMessage(ex.getMessage());return null;}
    }

    /**************************************************************************************************************
     *  validateConfiguration: Validate configuration before loading the HPM IFrame                               *
     *  Author: Samy Saied                                                                                        *  
     **************************************************************************************************************/
    private void validateConfiguration()
    {

        HPM_Setting__c hpmSetting;
        String url = System.URL.getCurrentRequestUrl().toExternalForm();
        system.debug('### url ' + url);
        
        url = url.replace('/apex','' );
        system.debug('### new url ' + url);

        for(HPM_Setting__c hpmS : [SELECT Id, Name, Base_URL__c,HPM_Page_Id__c,HPM_Tenant_Id__c,HPM_Security_Token__c,HPM_App_Url__c FROM HPM_Setting__c]){
            if(hpmS.Base_URL__c == null || hpmS.Base_URL__c == ''){ 
                continue;
            }
            system.debug('### hpmS.Base_URL__c ' + hpmS.Base_URL__c);            
            if(url.startsWithIgnoreCase(hpmS.Base_URL__c)){                
                hpmSetting = hpmS;                
                break;
            }
        }        

        this.hasConfigError = false;
        
        if(hpmSetting == null){
            hpmSetting = HPM_Setting__c.getInstance( 'Zuora HPM Setting' );
        }
    
        if ( hpmSetting == null ) throw new HPMConfigException( IECErrorCodeMapping.VALUES.get( 'Sfdc.NoConfiguration' ) ); 
    
        String missingFields = ''; 
        this.pageId = hpmSetting.HPM_Page_Id__c; 
        if ( this.pageId == null || this.pageId.trim().length() == 0 )  missingFields += ' Page ID,';
    
        this.tenantId = hpmSetting.HPM_Tenant_Id__c; 
        if ( this.tenantId == null || this.tenantId.trim().length() == 0 ) missingFields += ' Tenant ID,';
    
        this.apiSecurityKey = hpmSetting.HPM_Security_Token__c; 
        if ( this.apiSecurityKey == null || this.apiSecurityKey.trim().length() == 0 ) missingFields += ' Security Token,';
    
        this.appUrl = hpmSetting.HPM_App_Url__c; 
        if ( this.appUrl == null || this.appUrl.trim().length() == 0 ) missingFields += ' App URL,'; 
    
        if ( missingFields.length() > 0 ) {
            missingFields = missingFields.substring( 0, missingFields.length() - 1 );
            throw new HPMConfigException( IECErrorCodeMapping.VALUES.get( 'Sfdc.InvalidConfiguration' ) + missingFields );
        }
    
        Map<String, String> paramMap = ApexPages.currentPage().getParameters(); 
        String errorCode = paramMap.get( 'errorCode' ); 
        if ( errorCode == 'Invalid_Security' || errorCode == 'InvalidCallbackSecurity' ) this.hasConfigError = true; 
    }

    /**************************************************************************************************************
     *  loadHPMIframe: taken from HPMSampleController                                                             *
     *  Author: Samy Saied                                                                                        *  
     **************************************************************************************************************/
    public void loadHPMIframe()
    {
        try {
            validateConfiguration(); 
        }
        catch( HPMConfigException e ) {hasConfigError = true;addErrorMessage(IECErrorCodeMapping.VALUES.get( 'Sfdc.ErrorLoadingFrame' ) + e.getMessage());}
        
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
        }
        catch (Exception ex) {addErrorMessage(ex.getMessage());}        
    }

    public void loadCreditCards()
    {
      //-- Load credit cards 
      try { loggedCustomer.loadActiveCreditCards(); } catch (Exception e) { loggedCustomer.creditcards = new List<IEC_CreditCard_DTO>(); }
      creditcards = loggedCustomer.creditcards;
    }

    public void fetchCustomerPaymentMethods()
    {
        Map<String,String> uiToPaymentMethodMap = new Map<String,String> {
            'Bank Transfer'         => IECConstants.PaymentThresholdType_BankTransfer,
            'Credit Card'           => IECConstants.PaymentThresholdType_CreditCard,
            'IATA Clearing House'   => IECConstants.PaymentThresholdType_ICH
        };
        List<String> orderAcceptedPaymentMethods = new List<String>();
        Set<String> acceptedPaymentMethodSet = new Set<String>();

        Set<String> setPaymentMethods = new Set<String>(Utility.getTextSettingToArray('Order Payment Types allowed for CUS',','));

        //Check if Bank transfer is allowed
        if(!IECSubscriptionManager.canPurchaseAmountWithPaymentMethod(IECConstants.PaymentThresholdType_BankTransfer, sfOrder.Total_Amount__c)) setPaymentMethods.remove(IECConstants.PaymentThresholdType_BankTransfer);

        //Check if Check is allowed
        if(!IECSubscriptionManager.canPurchaseAmountWithPaymentMethod(IECConstants.ORDER_STATUS_CHECK, sfOrder.Total_Amount__c)) setPaymentMethods.remove(IECConstants.ORDER_STATUS_CHECK);

        //Check if Credit card is allowed   
        if(!IECSubscriptionManager.canPurchaseAmountWithPaymentMethod(IECConstants.PaymentThresholdType_CreditCard, sfOrder.Total_Amount__c)) setPaymentMethods.remove(IECConstants.PaymentThresholdType_CreditCard);

        //Check if ICH is allowed
        if((!loggedCustomer.canPayByICH()) || (!IECSubscriptionManager.canPurchaseAmountWithPaymentMethod(IECConstants.PaymentThresholdType_ICH, sfOrder.Total_Amount__c))) setPaymentMethods.remove(IECConstants.PaymentThresholdType_ICH);

    
        // Ecommerce Enhancements R2
        if (sfOrder.Accepted_Payment_Methods__c != null) {
            orderAcceptedPaymentMethods = sfOrder.Accepted_Payment_Methods__c.split(';');

            for (String accepted : orderAcceptedPaymentMethods) {
                String pm = uiToPaymentMethodMap.get(accepted);

                if (pm != null) {
                    acceptedPaymentMethodSet.add(pm);
                }
            }

            if (acceptedPaymentMethodSet.isEmpty() == false) {
                setPaymentMethods.retainAll(acceptedPaymentMethodSet);
            } else {
                setPaymentMethods.clear();
            }
        } else {
            setPaymentMethods.clear();
        }


        if(setPaymentMethods.size() > 0) paymentMethods = new List<String>(setPaymentMethods);
        else addErrorMessage('NO PAYMENT METHOD FOR THIS ORDER');
    }
    
    public Boolean isNotOneTimeAddress(Location__c loc)
    {
        return (String.isNotBlank(loc.Street__c)
            && String.isNotBlank(loc.ISO_Country_Code__c)
        );
    }

    /**************************************************************************************************************
     *  fetchShippingAddresses: method to fetch logged customer shipping addresses                                * 
     *      are country compliant                                                                                 *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
    public List<SelectOption> fetchShippingAddresses()
    {
        List<SelectOption> addresses = new List<SelectOption>();
        addresses.add(new SelectOption('', '-Select an address-'));
        Map<Id,Location__c> contactLocations = new Location_Sel().getContactsLocations(new Set<Id>{loggedCustomer.sfContact.Id});

        for (Id locationId : contactLocations.keySet())
        {
            Location__c location = contactLocations.get(locationId);
            if (location.Type__c == IECConstants.SHIPTO && location.Active__c && isNotOneTimeAddress(location))
            {
                String label = (String.isNotBlank(location.Address_Name__c))? location.Address_Name__c + ' - ' +location.Full_Address__c : location.Full_Address__c;
                addresses.add(new SelectOption(locationId, label));
            }
        }
        return addresses;
    }


    /**************************************************************************************************************
     *  validateCountryCompliance: method to validate that all the products in customer's cart                    * 
     *      are country compliant                                                                                 *
     *  Author: Samy Saied                                                                                        *  
     **************************************************************************************************************/
    public void validateCountryCompliance()
    {
        List<Id> productIds = new List<Id>();
        for (OrderItem_DTO oi : vfOrder.orderItems) productIds.add(oi.productId);

        mapProduct2Id_Compliance = Product_Svc.IsProductAndCountryCompliant(productIds, new Set<String>{vfOrder.billToAddress.countryCode});
        
        
        bAreProductsCompliant = true;
        if (!mapProduct2Id_Compliance.isEmpty()) {
            for (Id idProduct : mapProduct2Id_Compliance.keySet()) {
                // display error message with product name/number
                for (OrderItem_DTO oi : vfOrder.orderItems) {
                    if (idProduct == oi.productId) {
                        if (!mapProduct2Id_Compliance.get(idProduct)) {
                            bAreProductsCompliant = false;
                            addErrorMessage(String.format(labels.get('msgWarnProductNotCompliant'), new String[]{oi.productName, oi.productCode}));
                        }
                        break;
                    }
                }
            }
        }
    }

    /**************************************************************************************************************
     *  refreshShipToProvinces: method calls when customer change his countryto retrieve available states         *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
    public void refreshShipToProvinces()
    {
        String countryCode = ApexPages.currentPage().getParameters().get('countryCode');
        if(String.isNotBlank(countryCode)) 
            newShipToAddress.countryCode = countryCode;

        //-- Update isRequiredField 
        List<IATA_ISO_Country__c> countries = ISO_Country_State_Helper.getIsoCountryByIsoCode(newShipToAddress.countryCode);
        if(countries.size() > 0)
        {
            newShipToAddress.isPostalCodeRequired = countries[0].IEC_Zip_Postal_Code_required__c;
            newShipToAddress.countryLabel = countries[0].Name; 
        }

        newAddressAvailableStates = ISO_Country_State_Helper.getStatesSelectOption(newShipToAddress.countryCode);

        hasError = false;
    }

    private Boolean isEmailValid(String inputEmail)
    {
        Matcher regexCheck;
        String emailPattern = '^[\\w!#$%&’*+/=?`{|}~^-]+(?:\\.[\\w!#$%&’*+/=?`{|}~^-]+)*@(?:[a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,6}$';
        regexCheck = Pattern.compile(emailPattern).matcher(inputEmail);
        return regexCheck.find();
    }

    public Boolean validateAddress(Address_DTO address)
    {
        Boolean isValid = true; 

        if(address.isPostalCodeRequired == null) { address.isPostalCodeRequired = false; }

        if((String.isBlank(address.addressName)) 
            || (String.isNotBlank(address.email) && !isEmailValid(address.email)) 
            || (String.isBlank(address.email)) || (String.isBlank(address.phone)) 
            || (String.isBlank(address.street1)) 
            || (address.isPostalCodeRequired && String.isBlank(address.postalCode)) 
            || (String.isBlank(address.city)) 
            || (String.isBlank(address.countryCode)) 
            || (newAddressAvailableStates.size() > 0 && String.isBlank(address.stateCode))
        )
            isValid = false;
    
        return isValid;
  }



    /**************************************************************************************************************
     *  saveNewAddress: method calls when customer create a new Shipping address                                  *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
    public PageReference saveNewAddress()
    {
        showNewAddress = true;
        Boolean hError = false;
        //-- Validate Address
        if(!validateAddress(newShipToAddress)) {
            addErrorMessage('You must specify all the required fields for the new address');
            hError = true;
           // return null;
        }
        
        //TC 2017-05-16
        if(!String.isBlank(newShipToAddress.street1) && newShipToAddress.street1.length() > 70) {
            addErrorMessage(Label.IEC_ShippingAddressLimit);
            hError = true;
            //return null;  
        }      
        
        if(newShipToAddress != null && !String.isBlank(newShipToAddress.street1) && IECUtil.isPostOfficeBox(newShipToAddress.street1)) {
            addErrorMessage(Label.IEC_PO_BOX_ERROR);
            hError = true;
            //return null;
        }
        
        if(hError) {            
            return null;    
        }
        

        try {
            //-- Validate inputs 
            if(String.isBlank(newShipToAddress.attention)) newShipToAddress.attention = loggedCustomer.sfContact.Name;

            if(String.isNotBlank(newShipToAddress.vatNumber))
            {
                String validation = IECVATUtil.Validate_VAT(newShipToAddress.countryCode, newShipToAddress.vatNumber);

                if(String.isNotBlank(validation))
                {
                    addErrorMessage(validation);return null;
                }           
            }

            //-- Find IECAddress if exist or create new IECAddress
            IECAddress_Sel adrSelector = new IECAddress_Sel();
            List<IECAddress__c> addresses = adrSelector.getAddress(newShipToAddress.street1,newShipToAddress.city,newShipToAddress.countryCode,newShipToAddress.stateCode,newShipToAddress.postalCode);
            IECAddress__c adr = (addresses != null & addresses.size() > 0) ? addresses[0] : IECAddress_Svc.newAddressForSAPSync(newShipToAddress.street1,newShipToAddress.city,newShipToAddress.countryCode,newShipToAddress.stateCode,newShipToAddress.postalCode);

            //-- Validate if location exist (same IECAddress And Contct)
            List<Location__c> shippingLocations = Location_Sel.getLocationToSyncSAP(null, null, new List<Id>{loggedCustomer.sfContact.Id}, IECConstants.SHIPTO, true).values();
            Location__c shippingLocation;
            for(Location__c loc : shippingLocations)
            {
                if(loc.Address__c == adr.Id)
                {
                    addErrorMessage(labels.get('msgAddrExist'));
                    return null;
                    //shippingLocation = loc;
                    //break;
                }
            }

            //-- Create new ShipTo Location if not exist
            //if(shippingLocation!=null)
            //{
            //    if(String.isNotBlank(newShipToAddress.addressName)) shippingLocation.Address_Name__c = newShipToAddress.addressName;
            //    if(String.isNotBlank(newShipToAddress.email))       shippingLocation.Email__c = newShipToAddress.email;
            //    if(String.isNotBlank(newShipToAddress.phone))       shippingLocation.Phone__c = newShipToAddress.phone;
            //    if(String.isNotBlank(newShipToAddress.vatNumber))   shippingLocation.VAT_Number__c = newShipToAddress.vatNumber;
            //}
            //else
                shippingLocation = new Location__c(Active__c = true, Type__c = IECConstants.SHIPTO, Address__c = adr.Id, Address__r = adr, Address_Name__c = newShipToAddress.addressName
                                                 , Account__c = shippingLocations[0].Account__c, Account__r = shippingLocations[0].Account__r
                                                 , Contact__c = shippingLocations[0].Contact__c, Contact__r = shippingLocations[0].Contact__r, Attention__c = shippingLocations[0].Contact__r.Name
                                                 , Email__c = newShipToAddress.email, Phone__c = newShipToAddress.phone, VAT_Number__c = newShipToAddress.vatNumber);
            
            //*** send to SAP
            List<IEC_Error_Log__c> lstSyncResult = IECAddress_Svc.syncCustomerWithSAP(new List<Location__c>{shippingLocation}, null, false);
            if (lstSyncResult[0] != null)
            {
                addErrorMessage(Label.IEC_SAP_Customer_Address_Issue);
                return null;
            }
            
            //*** commit change
            Savepoint sp = Database.setSavepoint();
            try
            {
                if (adr.Id == null)
                    insert adr;
                
                if (shippingLocation.Address__c == null)
                    shippingLocation.Address__c = shippingLocation.Address__r.Id;
                upsert shippingLocation;
                
                //-- Select new created address
                sfOrder.ShipTo_Location__c      = shippingLocation.Id;
                sfOrder.ShipToAccount_Name__c   = vfOrder.shipToContact.accountName;
                sfOrder.ShipToContact_Name__c   = shippingLocation.Attention__c;
                sfOrder.ShipToContact_Phone__c  = shippingLocation.Phone__c;
                sfOrder.ShipToContact_Email__c  = shippingLocation.Email__c;
                sfOrder.ShipTo_Address__c       = shippingLocation.Address__c;
                sfOrder.ShippingStreet          = shippingLocation.Address__r.Street__c;
                sfOrder.ShippingCity            = shippingLocation.Address__r.City__c;
                sfOrder.ShippingPostalCode      = shippingLocation.Address__r.ZipCode__c;
                sfOrder.ShippingCountry         = shippingLocation.Address__r.ISO_Country__r.Name;
                sfOrder.ShippingCountryCode__c  = shippingLocation.Address__r.ISO_Country__r.ISO_Code__c;
                sfOrder.ShippingState           = shippingLocation.Address__r.ISO_State__r.Name;
                sfOrder.ShippingStateCode__c    = shippingLocation.Address__r.ISO_State__r.ISO_Code__c;
                sfOrder.Shipping_Instruction__c = vfOrder.shipToInstructions;
                sfOrder.ShipToContact_VAT_Number__c = shippingLocation.VAT_Number__c;
                update sfOrder;
                vfOrder.shipToContact.contactName = sfOrder.ShipToContact_Name__c;
                vfOrder.shipToContact.phone = sfOrder.ShipToContact_Phone__c;
                vfOrder.shipToContact.email = sfOrder.ShipToContact_Email__c;
            }
            catch(Exception ex)
            {
                addErrorMessage(ex.getMessage());
                Database.rollback(sp);
                return null;
            }

            //-- Reset new Adrress object
            newShipToAddress = new Address_DTO();
            shippingAddresses = fetchShippingAddresses();

            //*** set control variables
            currentShipToLocationId = shippingLocation.Id;
            currentShipToPartner = shippingLocation.SAP_Id__c;
            recalculateFreightTax = true;

            hasError = false;
            isShipToError = false;
            showNewAddress = false;

            return null;
        }catch(Exception ex){
            addErrorMessage(ex.getMessage());return null;
        }
    }

    public void regionChanged()
    {       
    }

    public void applyCoupon()
    {
        for (OrderItem_DTO item : vfOrder.orderItems)
        {
            if (item.orderItemId == updateItemId)
            {
                item.message = null;

                if(String.isNotBlank(item.couponCode))
                {
                    item.couponCode = item.couponCode.trim();

                    
                    if (!Order_Svc.isCouponValid(item.productId, item.couponCode, item.PriceInfo.couponPrice, sfOrder.ShipToContactId))
                    {
                        item.message = 'Coupon "' + item.couponCode + '" is invalid.';
                        item.couponCode = null;
                        addErrorMessage(item.message);
                    }
                    else
                    {
                        //Apply the Coupon Code to the Order Item 
                        Order_Svc.setPriceToOrderItemDTO(item);

                        //Update tax and shipping 
                        String taxShi = Order_Svc.getSAP_Freight_Tax_for_DTO(sfOrder.Type, sfOrder.Source__c, sfOrder.Order_Channel__c, sfOrder.SoldToAccount_Partner_Number__c, 
                            sfOrder.BillToContact_Partner_Number__c, sfOrder.ShipToContact_Partner_Number__c, vfOrder.orderItems);
                        
                        taxFreightCalculateWithError = false;
                        if(taxShi != null)
                        {
                            addErrorMessage(labels.get('errTax') + taxShi);  
                            taxFreightCalculateWithError = true;
                        }

                        //Save in SFDC
                        List<OrderItem> orderItemToUpdate = new List<OrderItem>();
                        Map<Id,OrderItem> orderItemId_OrderItem = new OrderItem_Sel().getOrderItemById(new Set<Id>{updateItemId});
                        OrderItem sfdcOrderItem = orderItemId_OrderItem.get(updateItemId);
                        Map<String, PriceInfo_DTO> mapProductNumber_Price = new Map<String, PriceInfo_DTO>();

                        if(sfdcOrderItem != null)
                        {
                            mapProductNumber_Price.put(item.productCode, item.PriceInfo);
                            sfdcOrderItem.Quantity = item.quantity;
                            sfdcOrderItem.Freight_Charge__c = item.shippingAmount;
                            sfdcOrderItem.Tax__c = item.taxAmount;
                            sfdcOrderItem.Coupon__c = item.couponCode;
                            orderItemToUpdate.add(sfdcOrderItem); 
                            
                            Order_Svc.setPriceToOrderItem(orderItemToUpdate, mapProductNumber_Price, sfOrder.ShipToContactId, false);
                        }

                        //Get the broken down discount
                        if(orderItemId_OrderItem.size() > 0)
                        {
                            Map<Id, List<Order_Item_Charge__c>> orderItemChargeByOi = new OrderItemCharge_Sel().getChargesByOrerItem(orderItemId_OrderItem.keySet());
                            for(OrderItem_DTO oid : vfOrder.orderItems){
                                if(orderItemChargeByOi != null && orderItemChargeByOi.size() > 0){
                                    List<Order_Item_Charge__c> orderItemCharges = orderItemChargeByOi.get(oid.orderItemId);
                                    if(orderItemCharges != null && orderItemCharges.size() > 0){
                                        List<OrderItemCharge_DTO> oicDto = OrderItemCharge_DTO.format2DTO(orderItemCharges);
                                        oid.charges = oicDto;
                                    }
                                }else{
                                    oid.charges = new List<OrderItemCharge_DTO>();
                                }
                            }
                        }

                        //Refresh Order
                        sfOrder = IECOrder_Svc.getPenddingOrder(true);
                        vfOrder = new Order_DTO(sfOrder);
                    }
                }
            }
        }



        //return null;
    } //*** end of "applyCoupon"

    public void removeCoupon()
    {
        if (vfOrder.orderItems != null && vfOrder.orderItems.size() > 0)
        {
            for (OrderItem_DTO item : vfOrder.orderItems)
            {
                if (item.orderItemId == updateItemId)
                {
                    item.message = null;
                    item.couponCode = null;

                    if(item.PriceInfo.couponPrice != null && item.PriceInfo.couponPrice.get(0).isFreeShipping)
                        item.chargeShipping = true;
                    item.PriceInfo.couponPrice = null;
                    
                    //Apply the Coupon Code to the Order Item 
                    Order_Svc.setPriceToOrderItemDTO(item);
                    
                    //Update tax and shipping 
                    String taxShi = Order_Svc.getSAP_Freight_Tax_for_DTO(sfOrder.Type, sfOrder.Source__c, sfOrder.Order_Channel__c, sfOrder.SoldToAccount_Partner_Number__c, 
                        sfOrder.BillToContact_Partner_Number__c, sfOrder.ShipToContact_Partner_Number__c, vfOrder.orderItems);

                    taxFreightCalculateWithError = false;
                    if(taxShi != null)
                    {
                        addErrorMessage(labels.get('errTax') + taxShi);  
                        taxFreightCalculateWithError = true;
                    }

                    //Save in SFDC
                    List<OrderItem> orderItemToUpdate = new List<OrderItem>();
                    Map<Id,OrderItem> orderItemId_OrderItem = new OrderItem_Sel().getOrderItemById(new Set<Id>{updateItemId});
                    OrderItem sfdcOrderItem = orderItemId_OrderItem.get(updateItemId);
                    Map<String, PriceInfo_DTO> mapProductNumber_Price = new Map<String, PriceInfo_DTO>();

                    if(sfdcOrderItem != null)
                    {
                        mapProductNumber_Price.put(item.productCode, item.PriceInfo);
                        sfdcOrderItem.Quantity = item.quantity;
                        sfdcOrderItem.Freight_Charge__c = item.shippingAmount;
                        sfdcOrderItem.Tax__c = item.taxAmount;
                        sfdcOrderItem.Coupon__c = item.couponCode;
                        orderItemToUpdate.add(sfdcOrderItem); 
                        
                        Order_Svc.setPriceToOrderItem(orderItemToUpdate, mapProductNumber_Price, sfOrder.ShipToContactId, false);
                    }

                    //Get the broken down discount
                    if(orderItemId_OrderItem.size() > 0)
                    {
                        Map<Id, List<Order_Item_Charge__c>> orderItemChargeByOi = new OrderItemCharge_Sel().getChargesByOrerItem(orderItemId_OrderItem.keySet());
                        for(OrderItem_DTO oid : vfOrder.orderItems){
                            if(orderItemChargeByOi != null && orderItemChargeByOi.size() > 0){
                                List<Order_Item_Charge__c> orderItemCharges = orderItemChargeByOi.get(oid.orderItemId);
                                if(orderItemCharges != null && orderItemCharges.size() > 0){
                                    List<OrderItemCharge_DTO> oicDto = OrderItemCharge_DTO.format2DTO(orderItemCharges);
                                    oid.charges = oicDto;
                                }
                            }else{
                                oid.charges = new List<OrderItemCharge_DTO>();
                            }
                        }
                    }

                    //Refresh Order
                    sfOrder = IECOrder_Svc.getPenddingOrder(true);
                    vfOrder = new Order_DTO(sfOrder);

                    break;
                }
            }
        }
    } //*** end of "removeCoupon"


    public Boolean isTermsAccepted()
    {
        Boolean allChecked = true;

        //Validate all TnC are accepted 
        for(OrderItem_DTO item : vfOrder.orderItems)
        {
            if(item.acceptedTnC != null && item.acceptedTnC.accepted != true)
            {
                addErrorMessage('You must accept Terms and Conditions for '+item.productName);
                allChecked = false;            
            }
        }

        return allChecked;
    }

    public Boolean isShipToValid()
    {
        //Location_Sel selector = new Location_Sel();
        //Map<Id, Location__c> mapId_Location = selector.getContactsLocations(new Set<Id>{sfOrder.ShipToContactId});  //*** only active locations
        //Location__c locationBillTo, locationShipTo, location;

        //forceShipToCustomerToSAP = false;

        //if(vfOrder.shipToSameAsBilTo)
        //{
        //  //*** get Bill To location
        //  locationBillTo = mapId_Location.get(sfOrder.BillTo_Location__c);
        //  
        //  //*** get Ship To location having same address than Bill To
        //  for (Id idLocation : mapId_Location.keySet())
        //  {
        //      location = mapId_Location.get(idLocation);
        //      if (location.Type__c == IECConstants.SHIPTO && location.Address__c == locationBillTo.Address__c)
        //      {
        //          locationShipTo = location;
        //          break;
        //      }
        //  }

            //*** create Ship To location if not found
        //  if (locationShipTo == null)
        //  {
        //      locationShipTo = Location_Svc.createLocation(locationBillTo.Address__c, sfOrder.ShipToContactId, locationBillTo.Email__c, locationBillTo.Phone__c, locationBillTo.VAT_Number__c, IECConstants.SHIPTO, loggedCustomer.sfContact.Name, null);
        //      forceShipToCustomerToSAP = true;
        //  }
        //  else 
        //  {
        //      if (locationShipTo.SAP_Id__c == null)
        //          forceShipToCustomerToSAP = true;

        //      if (!locationShipTo.Active__c || locationShipTo.VAT_Number__c != locationBillTo.VAT_Number__c)
        //      {
        //          locationShipTo = selector.getLocations(new Set<Id>{locationShipTo.Id})[0];
        //          locationShipTo.Active__c = true;
        //          locationShipTo.VAT_Number__c = locationBillTo.VAT_Number__c;
        //          update locationShipTo;
        //          forceShipToCustomerToSAP = true;
        //      }
        //      
        //  }

            //*** copy address information to order
        //  sfOrder.ShipTo_Location__c     = locationShipTo.Id;
        //  sfOrder.ShipToContact_Name__c  = locationShipTo.Attention__c;
        //  sfOrder.ShipToContact_Email__c = locationShipTo.Email__c;
        //  sfOrder.ShipToContact_Phone__c = locationShipTo.Phone__c;
        //  sfOrder.ShippingStreet         = sfOrder.BillingStreet;
        //  sfOrder.ShippingCity           = sfOrder.BillingCity;
        //  sfOrder.ShippingPostalCode     = sfOrder.BillingPostalCode;
        //  sfOrder.ShippingCountry        = sfOrder.BillingCountry;
        //  sfOrder.ShippingCountryCode__c = sfOrder.ShippingCountryCode__c;
        //  sfOrder.ShippingState          = sfOrder.BillingState;
        //  sfOrder.ShippingStateCode__c   = sfOrder.ShippingStateCode__c;
        //  sfOrder.ShipToContact_VAT_Number__c = locationShipTo.VAT_Number__c;
        //} 

        //sfOrder.IEC_Shipping_Instruction_attention__c = vfOrder.shipToInstructionAttention;
        //sfOrder.IEC_Shipping_Instruction_phone__c = vfOrder.shipToInstructionPhone;
        //sfOrder.IEC_Shipping_Instruction_email__c = vfOrder.shipToInstructionEmail;
        sfOrder.ShipToAccount_Name__c = vfOrder.shipToContact.accountName;
        sfOrder.ShipToContact_Name__c = vfOrder.shipToContact.contactName;
        sfOrder.ShipToContact_Phone__c = vfOrder.shipToContact.phone;
        sfOrder.ShipToContact_Email__c = vfOrder.shipToContact.email;
        sfOrder.Shipping_Instruction__c = vfOrder.shipToInstructions;   
        //sfOrder.ShipTo_same_BillTo__c = vfOrder.shipToSameAsBilTo;


        if(String.isNotBlank(sfOrder.ShipTo_Location__c))
        {
            return true; 
        }
        else
        {
            addErrorMessage('Please Select a Shipping Address');
            return false;
        }   
    }


    public void activeButton(){
        hasError = false;
    }

    public PageReference processPayment()
    {       
        if(String.isBlank(orderPaymentType))
        { 
          addErrorMessage('You must select a Payment method');
          return null;
        }

        //Verified that the shipping instruction mandatory field are filled in
        Boolean shipInstructionMandatoryField = true;
        if(String.isBlank(vfOrder.shipToContact.accountName) || String.isBlank(vfOrder.shipToContact.contactName) || 
            String.isBlank(vfOrder.shipToContact.phone) || String.isBlank(vfOrder.shipToContact.email)){
            shipInstructionMandatoryField = false;
        }
        if(!shipInstructionMandatoryField){
            addErrorMessage('Make sure all shipping instruction mandatory fields are filled in');
            return null;
        }
        //Verified if the shipToContact email is a valid email.
        if(!isEmailValid(vfOrder.shipToContact.email)){
            addErrorMessage('Please enter a valid email address');
            return null;
        }
        //-- Update sfOrder(SFDC) from vfOrder(DTO)
        sfOrder.Payment_Type__c = orderPaymentType;

        if(sfOrder.Payment_Type__c == IECConstants.PaymentThresholdType_CreditCard)
            sfOrder.Zuora_Credit_Card_Id__c = orderCreditCardId;

        //-- update OrderItems
        OrderItem_Sel oiSelector        = new OrderItem_Sel();
        List<OrderItem> orderItems      = oiSelector.getOrderItems(sfOrder.Id);
        Map<String, OrderItem_DTO> vfOrderItemById = new Map<String, OrderItem_DTO>();
        for(OrderItem_DTO oi : vfOrder.orderItems)
        {
            vfOrderItemById.put(oi.orderItemId, oi);
        }

        for(OrderItem oi : orderItems)
        {
            OrderItem_DTO item = vfOrderItemById.get(oi.Id);
            oi.Auto_Renew__c = item.isAutoRenew;
        }

        //Validate Country COmplaince for Products in the cart
        validateCountryCompliance();
        if(!bAreProductsCompliant) return null;

        //Validate Shipping Informations 
        if(!isShipToValid()) return null;
        
        //TC 2017-05-10 check if shipping adddess is a post office box
        
        if(sfOrder != null && !String.isBlank(sfOrder.ShippingStreet) && IECUtil.isPostOfficeBox(sfOrder.ShippingStreet)) {
            addErrorMessage(Label.IEC_PO_BOX_ERROR);
            return null;
        }       
        
        //Validate T&C
        if(!isTermsAccepted()) return null;

        //Validate payment method

        //Validation for the Total amount allowed for Credit card 
        Map<String,IEC_Payment_Threshold__c> paymentMethodThresholdByType = Order_Sel.getPaymentMethodThresholdByType();
        IEC_Payment_Threshold__c thresholdForCC = paymentMethodThresholdByType.get(IECConstants.PaymentThresholdType_CreditCard);
        if(sfOrder.Payment_Type__c == IECConstants.PaymentThresholdType_CreditCard && vfOrder != null && thresholdForCC != null && vfOrder.orderTotalAmount > thresholdForCC.Max_amount__c)
        {
            addErrorMessage(String.format(Label.Order_Total_Amount_validation_message, new String[]{IECConstants.PaymentThresholdType_CreditCard}));
            return null;
        }

        //Valide that customer have at lease on card selected if the payment method is credit card
        if(sfOrder.Payment_Type__c == IECConstants.PaymentThresholdType_CreditCard && (orderCreditCardId == null || orderCreditCardId == '')){
            addErrorMessage(Label.Credit_card_validation);
            return null;
        }
        
        //Validation for the minimun amount allowed for ICH
        IEC_Payment_Threshold__c thresholdForIch = paymentMethodThresholdByType.get(IECConstants.PaymentThresholdType_ICH);
        if(sfOrder.Payment_Type__c == IECConstants.PaymentThresholdType_ICH && vfOrder.orderTotalAmount < thresholdForIch.Min_amount__c)
        {
            addErrorMessage(String.format(Label.Order_Total_Amount_validation_message, new String[]{IECConstants.PaymentThresholdType_ICH}));
            return null;
        }

        //Validation for the minimun amount allowed for Bank Transfert
        IEC_Payment_Threshold__c thresholdForbank = paymentMethodThresholdByType.get(IECConstants.PaymentThresholdType_BankTransfer);
        if(sfOrder.Payment_Type__c == IECConstants.PaymentThresholdType_BankTransfer && vfOrder.orderTotalAmount < thresholdForbank.Min_amount__c)
        {
            addErrorMessage(String.format(Label.Order_Total_Amount_validation_message, new String[]{IECConstants.PaymentThresholdType_BankTransfer}));
            return null;
        }

    if(sfOrder.Payment_Type__c == IECConstants.PaymentThresholdType_BankTransfer)
    {
      Boolean isAutorenewable = false;
        for(OrderItem oi : orderItems)
        {
          if(oi.Auto_Renew__c)
          {
            isAutorenewable = true;
            break;
          }  
        }
        if(isAutorenewable)
        {
          addErrorMessage(Label.Bank_transfer_validation_for_auto_renew);
          return null;
        }
    }  



        //-- Update Order and goto Confirm page
        update orderItems;
        update sfOrder;

    //--Recalculate Taxes 
    //Order_Svc.getSAP_Freight_Tax(sfOrder.Id);  //*** re-calculate shipping and tax

    //addConfirmMessage('Payment Method=' + sfOrder.Payment_Type__c);
    //addConfirmMessage('Credit Card Id=' + sfOrder.Zuora_Credit_Card_Id__c);
    //return null;

        PageReference pgRef = new PageReference('/IEC_ConfirmOrder');
            pgRef.setRedirect(true);
        return pgRef;
    }    


    /**************************************************************************************************************
     *  findIECAddresses: RemoteAction method used for address Auto-Complete feature                              *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
    @remoteAction
    global static List<IECAddress__c> findIECAddresses(string str)
    {
        str = str + '%';
        return [Select Id, City__c, Contact__c, Country__c, Full_Address__c,
                ISO_Country__c, ISO_Country_Code__c, ISO_Country_Name__c,
                ISO_State__c, ISO_State_Code__c, ISO_State_Name__c,
                State__c, Street__c, ZipCode__c 
            FROM IECAddress__c 
            WHERE Full_Address__c LIKE :str 
            LIMIT 25
        ];
    }


    /****************************************************************************************************
        Created by CGI, Thai 2016-05-19
            Action when select an address from picklist
    ****************************************************************************************************/
    public void changeShipToAddress()
    {
        Location__c locationShipTo;
        List<IEC_Error_Log__c> lstSyncResult;

        hasError = false;
        showNewAddress = false;
        isShipToError = false;
        
        if (!String.isBlank(String.valueOf(sfOrder.ShipTo_Location__c)))
        {
            //*** one address selected
            locationShipTo = Location_Sel.getLocationToSyncSAP(new List<Id>{sfOrder.ShipTo_Location__c}, null, null, null, null).values()[0];
            
            //*** try to get SAP Id if necessary
            if (String.isBlank(locationShipTo.SAP_Id__c))
            {
                lstSyncResult = IECAddress_Svc.syncCustomerWithSAP(new List<Location__c>{locationShipTo}, null, false);
                isShipToError = (lstSyncResult[0] != null);
            }
            if (isShipToError)
                addErrorMessage(Label.IEC_SAP_Customer_Shipping_Address_Issue);
            else
            {
                //*** recalculate shipping & taxes
                recalculateFreightTax = true;
                currentShipToPartner = locationShipTo.SAP_Id__c;
                calculateFreightTaxDTO();
            }
            
            //*** update location if sent to SAP
            if (lstSyncResult != null && !isShipToError)
                update locationShipTo;
            
            //*** copy address information to order
            sfOrder.ShipToAccount_Name__c   = vfOrder.shipToContact.accountName;
            sfOrder.ShipToContact_Name__c   = locationShipTo.Attention__c;
            sfOrder.ShipToContact_Phone__c  = locationShipTo.Phone__c;
            sfOrder.ShipToContact_Email__c  = locationShipTo.Email__c;
            sfOrder.ShipTo_Address__c       = locationShipTo.Address__c;
            sfOrder.ShippingStreet          = locationShipTo.Address__r.Street__c;
            sfOrder.ShippingCity            = locationShipTo.Address__r.City__c;
            sfOrder.ShippingPostalCode      = locationShipTo.Address__r.ZipCode__c;
            sfOrder.ShippingCountry         = locationShipTo.Address__r.ISO_Country__r.Name;
            sfOrder.ShippingCountryCode__c  = locationShipTo.Address__r.ISO_Country__r.ISO_Code__c;
            sfOrder.ShippingState           = locationShipTo.Address__r.ISO_State__r.Name;
            sfOrder.ShippingStateCode__c    = locationShipTo.Address__r.ISO_State__r.ISO_Code__c;
            sfOrder.Shipping_Instruction__c = vfOrder.shipToInstructions;
            sfOrder.ShipToContact_VAT_Number__c = locationShipTo.VAT_Number__c;
            update sfOrder;
            //vfOrder.shipToContact.accountName = sfOrder.ShipToAccount_Name__c;
            vfOrder.shipToContact.contactName = sfOrder.ShipToContact_Name__c;
            vfOrder.shipToContact.phone = sfOrder.ShipToContact_Phone__c;
            vfOrder.shipToContact.email = sfOrder.ShipToContact_Email__c;
            
            //*** set control variables
            currentShipToLocationId = sfOrder.ShipTo_Location__c;
        }
        else
        {
            //*** no address selected -> return to original address -> don't need to recalculate tax because address didn't change
            sfOrder.ShipTo_Location__c = currentShipToLocationId;
        }
    } //*** end of "changeShipToAddress"


    /****************************************************************************************************
        Created by CGI, Thai 2016-05-19
            Action when changing shipping address option
    ****************************************************************************************************/
    public void changeShipToAddressOption()
    {
        Location_Sel selector = new Location_Sel();
        Map<Id, Location__c> mapId_Location = Location_Sel.getLocationToSyncSAP(null, null, new List<Id>{sfOrder.ShipToContactId}, null, true);  //*** only active locations
        Location__c locationBillTo, locationShipTo, location;
        List<IEC_Error_Log__c> lstSyncResult;

        hasError = false;
        showNewAddress = false;
        isShipToError = false;

        if (vfOrder.shipToSameAsBilTo == true)
        {
            //*** get Bill To location
            locationBillTo = mapId_Location.get(sfOrder.BillTo_Location__c);
            
            //*** get Ship To location having same address than Bill To
            for (Id idLocation : mapId_Location.keySet())
            {
                location = mapId_Location.get(idLocation);
                if (location.Type__c == IECConstants.SHIPTO && location.Address__c == locationBillTo.Address__c)
                {
                    locationShipTo = location;
                    break;
                }
            }
            
            //*** create Ship To location if not found
            if (locationShipTo == null)
                locationShipTo = new Location__c(Active__c = true, Type__c = IECConstants.SHIPTO, Address__c = locationBillTo.Address__c, Address__r = locationBillTo.Address__r
                                               , Account__c = locationBillTo.Account__c, Account__r = locationBillTo.Account__r
                                               , Contact__c = locationBillTo.Contact__c, Contact__r = locationBillTo.Contact__r, Attention__c = locationBillTo.Contact__r.Name, Address_Name__c = 'New'
                                               , Email__c = locationBillTo.Email__c, Phone__c = locationBillTo.Phone__c , VAT_Number__c = locationBillTo.VAT_Number__c);
            
            //*** send to SAP if no SAP Id
            if (String.isBlank(locationShipTo.SAP_Id__c))
            {
                lstSyncResult = IECAddress_Svc.syncCustomerWithSAP(new List<Location__c>{locationShipTo}, null, false);
                if (lstSyncResult[0] != null)
                {
                    addErrorMessage(Label.IEC_SAP_Customer_Address_Issue);
                    return;
                }
            }
            
            //*** update information if necessary 
            if (locationShipTo.Id == null || lstSyncResult != null || locationShipTo.VAT_Number__c != locationBillTo.VAT_Number__c)
            {
                locationShipTo.VAT_Number__c = locationBillTo.VAT_Number__c;
                upsert locationShipTo;
            }
            
            //*** copy address information to order
            sfOrder.ShipTo_same_BillTo__c   = true;
            sfOrder.ShipTo_Location__c      = locationShipTo.Id;
            sfOrder.ShipToAccount_Name__c   = vfOrder.shipToContact.accountName;
            sfOrder.ShipToContact_Name__c   = locationShipTo.Attention__c;
            sfOrder.ShipToContact_Phone__c  = locationShipTo.Phone__c;
            sfOrder.ShipToContact_Email__c  = locationShipTo.Email__c;
            sfOrder.ShipTo_Address__c       = locationShipTo.Address__c;
            sfOrder.ShippingStreet          = sfOrder.BillingStreet;
            sfOrder.ShippingCity            = sfOrder.BillingCity;
            sfOrder.ShippingPostalCode      = sfOrder.BillingPostalCode;
            sfOrder.ShippingCountry         = sfOrder.BillingCountry;
            sfOrder.ShippingCountryCode__c  = sfOrder.BillingCountryCode__c;
            sfOrder.ShippingState           = sfOrder.BillingState;
            sfOrder.ShippingStateCode__c    = sfOrder.BillingStateCode__c;
            sfOrder.Shipping_Instruction__c = vfOrder.shipToInstructions;
            sfOrder.ShipToContact_VAT_Number__c = locationShipTo.VAT_Number__c;
            update sfOrder;
            vfOrder.shipToContact.contactName = sfOrder.ShipToContact_Name__c;
            vfOrder.shipToContact.phone       = sfOrder.ShipToContact_Phone__c;
            vfOrder.shipToContact.email       = sfOrder.ShipToContact_Email__c;
            
            //*** set control variables
            currentShipToLocationId = sfOrder.ShipTo_Location__c;
            currentShipToPartner = locationShipTo.SAP_Id__c;
            recalculateFreightTax = true;
        }
        else
        {
            //*** customer has to select an address -> don't need to recalculate tax because address didn't change
            sfOrder.ShipTo_same_BillTo__c   = false;
            sfOrder.ShipTo_Location__c      = currentShipToLocationId;  //*** must restore from working variable because may be set to another value by the addresses picklist in UI
            sfOrder.ShipToAccount_Name__c   = vfOrder.shipToContact.accountName;
            sfOrder.ShipToContact_Name__c   = vfOrder.shipToContact.contactName;
            sfOrder.ShipToContact_Phone__c  = vfOrder.shipToContact.phone;
            sfOrder.ShipToContact_Email__c  = vfOrder.shipToContact.email;
            sfOrder.Shipping_Instruction__c = vfOrder.shipToInstructions;
            update sfOrder;

            Location__c shipLocation = mapId_Location.get(sfOrder.ShipTo_Location__c);
            if(shipLocation != null)
                currentShipToPartner = shipLocation.SAP_Id__c;
        }
    } //*** end of "changeShipToAddressOption"


    /****************************************************************************************************
        Created by CGI, Thai 2016-05-19
            Immediately send customer to SAP -> to be called from VF to force a separate context
    ****************************************************************************************************/
    //public void sendShipToCustomerToSAP()
    //{
    //    if (forceShipToCustomerToSAP != true)
    //        return;
        
    //    Location_Sel selector = new Location_Sel();
    //    List<Location__c> lstLocation = selector.getLocations(new Set<Id>{sfOrder.ShipTo_Location__c});
    //    IECAddress_Svc.syncCustomerMasterWithSAP(lstLocation);
    //    lstLocation = selector.getLocations(new Set<Id>{sfOrder.ShipTo_Location__c});
    //    currentShipToPartner = lstLocation[0].SAP_Id__c;
    //    forceShipToCustomerToSAP = false;
    //} //*** end of "sendShipToCustomerToSAP"


    /****************************************************************************************************
        Created by CGI, Thai 2016-05-19
            Recalculate freight charges and taxes
    ****************************************************************************************************/
    public void calculateFreightTaxDTO()
    {
        if (recalculateFreightTax != true)
            return;
        //*** update tax and shipping 
        String returnMsg = Order_Svc.getSAP_Freight_Tax_for_DTO(sfOrder.Type, sfOrder.Source__c, sfOrder.Order_Channel__c, sfOrder.SoldToAccount_Partner_Number__c, sfOrder.BillToContact_Partner_Number__c
                                                              , (String.isBlank(currentShipToPartner) ? sfOrder.ShipToContact_Partner_Number__c : currentShipToPartner) , vfOrder.orderItems);
        taxFreightCalculateWithError = false;
        if(returnMsg != null){
            addErrorMessage(labels.get('errTax') + returnMsg);
            taxFreightCalculateWithError = true;
        }

        //*** save to database
        List<OrderItem> orderItemToUpdate = new List<OrderItem>();
        Decimal totalFreight = 0, totalHandling = 0, totalTaxes = 0, totalAmount = 0;
        for (OrderItem_DTO oi : vfOrder.orderItems)
        {
            orderItemToUpdate.add(new OrderItem(Id=oi.orderItemId, Freight_Charge__c=oi.shippingAmount, Handling_charges__c=oi.handlingCharges, Tax__c=oi.taxAmount));
            
            //*** prepare for totals displayed
            totalFreight += ((oi.shippingAmount == null) ? 0 : oi.shippingAmount);
            totalHandling += ((oi.handlingCharges == null) ? 0 : oi.handlingCharges);
            totalTaxes += ((oi.taxAmount == null) ? 0 : oi.taxAmount);
            totalAmount += oi.totalAmount;
        }
        if (orderItemToUpdate.size() > 0)
            update orderItemToUpdate;
        
        //*** refresh totals
        vfOrder.totalFreightCharge   = totalFreight;
        vfOrder.totalHandlingCharges = totalHandling;
        vfOrder.taxes                = totalTaxes;
        vfOrder.orderTotalAmount     = totalAmount;
    } //*** end of "calculateFreightTaxDTO"
    
}