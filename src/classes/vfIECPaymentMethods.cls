/**  
  * Description: This class contains the controller for the Visualforce page (Payment Methods) 
  * Author: Samy Saied
  * Version: 1.0
  * History: 
  */
public class vfIECPaymentMethods extends IECPageController {
   
    ///////////////////////////////////////////////////////
    // properties for HPM (Hosted Payment Method) of Zuora
    public String sErrorMsgFromHPM { get; set; }
    public String iframeSrc { get; set; }
    public boolean hasConfigError { get; set; }
    public String sDefaultCreditCardId {get; set;}
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

    public boolean isAddNew { get; set; }    
    public boolean isICHCustomer { get{return  IECCustomer.getCurrentIECCustomer().canPayByICH();} set; }
    public string ICHID {get {return IECConstants.PaymentMethod_ICH_ZuoraID; } set;}
    public String creditCardToEdit { get; set; }
    public String creditCardToDelete { get; set; }
    public String newCreditCardPaymentId { get; set; }
    public String customerDefaultPaymentMethodId { get; set; }
    public String customerDefaultPaymentType { get; set; }
    public List<IECZuoraHelper.CreditCard> creditCards {
        get {
                if (creditCards == null)
                    creditCards = convertFromzObjectList(loggedCustomer.CreditCards);
                
                //*********************************************************/
                // Move the default credit card to the first spot on thelist                    
                Integer index = 0;
                Integer defaultIndex = -1;
                
                if (creditCards == null)
                    return null;
                    
                //Find the current spot of default credit card payment
                for (IECZuoraHelper.CreditCard card : creditCards) {
                    
                    if (card.zId == customerDefaultPaymentMethodId)
                    {
                        defaultIndex = index;
                        break;
                    }
                    
                    index++;
                }
                
                //Only move the credit card if its current index is bigger than 0
                if (defaultIndex > 0) {
                    
                    //Remove the card from its current spot
                    IECZuoraHelper.CreditCard defaultCard = creditCards.remove(defaultIndex);
                    
                    //Re add the card in the top position (index 0)
                    creditCards.add(0, defaultCard);
                }
                
                return creditCards;
        }
        private set {
            creditCards = value;
        }
    }
    public Boolean hasCreditCards {
        get {
            return (creditCards != null && creditCards.size() > 0);
        }
    }
    public Boolean hasZuoraAccount {
        get {
            return (loggedCustomer.RelatedZuoraAccount != null);
        }
    }
    
    public List<SelectOption> MonthsSelectOptionItems {
        get {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('1','01'));
            options.add(new SelectOption('2','02'));
            options.add(new SelectOption('3','03'));
            options.add(new SelectOption('4','04'));
            options.add(new SelectOption('5','05'));
            options.add(new SelectOption('6','06'));
            options.add(new SelectOption('7','07'));
            options.add(new SelectOption('8','08'));
            options.add(new SelectOption('9','09'));
            options.add(new SelectOption('10','10'));
            options.add(new SelectOption('11','11'));
            options.add(new SelectOption('12','12'));
            return options;
        }
    }
    public List<SelectOption> YearsSelectOptionItems {
        get {
            List<SelectOption> options = new List<SelectOption>();
            
            Integer maxYear = 2042;
            for (Integer year = 2010; year < maxYear; year++) {
                options.add(new SelectOption(String.valueOf(year),String.valueOf(year)));
            }
            return options;
        }
    }
    
    public List<SelectOption> DefaultPaymentMethodsItems {
        get {
            List<SelectOption> options = IECZuoraHelper.getDefaultPaymentMethods();
            if (loggedCustomer.PaymentMethods != null && loggedCustomer.PaymentMethods.size() > 0) {
                for (Zuora.zObject cc : loggedCustomer.PaymentMethods) {
                    options.add(new SelectOption((String)cc.getValue('Id')
                        ,   (String)cc.getValue('CreditCardType')
                            + ' '
                            + (String)cc.getValue('CreditCardMaskNumber')
                            + ' ('
                            + String.valueOf(cc.getValue('CreditCardExpirationMonth'))
                            + '/'
                            + String.valueOf(cc.getValue('CreditCardExpirationYear'))
                            + ')'
                    ));
                }
            }
            if (options.size() == 0)
                options.add(new SelectOption('','--none--'));
            else
                options.add(0, new SelectOption('','--none--'));
            return options;
        }
    }
    
    public List<SelectOption> getCountriesItems() {
        List<SelectOption> options = IECZuoraHelper.getZuoraCountriesSelectOptions();
        options.add(0, new SelectOption('','--Please select--'));
        return options;
    }

    public vfIECPaymentMethods() {
        isAddNew = false;
    }

    public Pagereference pageLoad() {
        try {
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
                
                //creditCards = convertFromzObjectList(loggedCustomer.CreditCards);

                if (hasZuoraAccount)
                    customerDefaultPaymentMethodId = (String)loggedCustomer.RelatedZuoraAccount.getValue('DefaultPaymentMethodId');
                else
                    customerDefaultPaymentMethodId = '';

                // Load the default payment type from the account level
                customerDefaultPaymentType = (loggedCustomer.RelatedAccount != null) ? loggedCustomer.RelatedAccount.Default_Payment_Type__c : '';
                
                loadHPMIframe();
            }
        }
        catch (Exception ex) {
            addErrorMessage(ex.getMessage() + '<br/>' + ex.getStackTraceString());
        }
        return null;
    }
    
    public Pagereference deleteCard() {
        try {
            if (creditCardToDelete == customerDefaultPaymentMethodId) {
                addErrorMessage(Label.IEC_Error_DeleteDefaultPayment);
                return null;
            }
            IECZuoraHelper.CreditCard selectedCreditCard = getCreditCardById(creditCardToDelete);
            
            Zuora.zApi.DeleteResult result;
            
            if (!Test.isRunningTest()) {
                result = IECZuoraHelper.deleteCreditCard(creditCardToDelete);
            } 
            else {
                result = new Zuora.zApi.DeleteResult();
                result.Success = true;
            }
             
            if (result.Success) {
                loggedCustomer.refreshZuoraPaymentMethods();
                // force reload of credit cards
                creditCards = null;
                addConfirmMessage('The credit card ' + selectedCreditCard.CreditCardMaskNumber + ' has been successfully deleted.');
            }
            else {
                addErrorMessage('Delete credit card failed for the following reason(s):' + IECZuoraHelper.getErrorMessagesString(result.Errors, '<BR> - '));
            }
            creditCardToDelete = '';
            
            return null;
        }
        catch (Exception ex) {
            addErrorMessage(ex.getMessage());
            return null;
        }
    }
    
    // Save card after modifiying parameters
    public Pagereference saveCard() {
        try {
            IECZuoraHelper.CreditCard selectedCreditCard = getCreditCardById(creditCardToEdit);
            
            Zuora.zApi.SaveResult result;
            
            if (!Test.isRunningTest()) {
                result = IECZuoraHelper.updateCreditCard(selectedCreditCard.toZObjectForUpdate());
            } 
            else {
                result = new Zuora.zApi.SaveResult();
                result.Success = true;
            }
             
            if (result.Success) {
                loggedCustomer.refreshZuoraPaymentMethods();
                creditCards = null;
                creditCardToEdit = '';
                addConfirmMessage('The credit card ' + selectedCreditCard.CreditCardMaskNumber + ' has been successfully updated.');
            }
            else {
                addErrorMessage('Update credit card failed for the following reason(s):' + IECZuoraHelper.getErrorMessagesString(result.Errors, '<BR> - '));
            }

            return null;
        }
        catch (Exception ex) {
            addErrorMessage(ex.getMessage());
            return null;
        }
    }
    
    // Add new card to user profile
    public Pagereference addCard() {
        try {
            if (String.isEmpty(newCreditCardPaymentId)) {
                addErrorMessage(Label.IEC_Error_HostedPaymentIdMissing);
            }
            else {
                if (!Test.isRunningTest()) 
                    loggedCustomer.refreshZuoraPaymentMethods();

                // force reload of credit cards
                creditCards = null;
                
                // Make sure that the new card has been added and retrieved from Zuora
                Boolean isFound = false;
                for (IECZuoraHelper.CreditCard card : creditCards) {
                    if (card.zId == newCreditCardPaymentId) {
                        isFound = true;
                        break;
                    }
                }
                
                if (isFound) {
                    addConfirmMessage(Label.IEC_Confirm_AddNewCard);
                }
                else
                    addErrorMessage(Label.IEC_Error_AddNewCardFailed);
            }
            isAddNew = false;
            return null;
        }
        catch (Exception ex) {
            addErrorMessage(ex.getMessage());
            return null;
        }
    }
    
    public PageReference makeThisDefaltCreditCard() {
        customerDefaultPaymentMethodId = sDefaultCreditCardId;
        return updateDefaultPaymentMethod();
    }
    
    public Pagereference updateDefaultPaymentMethod() {
        try {
        	/* Commented by Samy (2016-03-04) Replaced with new code to save the default payment type instead of method on the SF Account level
            if (String.isBlank(customerDefaultPaymentMethodId)) {
                addErrorMessage(Label.IEC_Error_DefaultPaymentEmpty);
                customerDefaultPaymentMethodId = (String)loggedCustomer.RelatedZuoraAccount.getValue('DefaultPaymentMethodId');
                return null;
            }
            
            if (customerDefaultPaymentMethodId != IECConstants.PaymentMethod_ICH_ZuoraID
                && customerDefaultPaymentMethodId != IECConstants.PaymentMethod_BankTransfer_ZuoraID) {
                IECZuoraHelper.CreditCard selectedCreditCard = getCreditCardById(customerDefaultPaymentMethodId);
                // Calculate expiry date by last day in the month
                Date expDate = Date.newInstance(selectedCreditCard.ExpirationYear, selectedCreditCard.ExpirationMonth, 1).addMonths(1).addDays(-1);

                // Compare against system date
                if (Date.today().daysBetween(expDate) < 0) {
                    addErrorMessage(Label.IEC_Error_DefaultPaymentExpired);
                    return null;
                }
            }

            Zuora.zApi.SaveResult result;
            // not in test method
            if (!Test.isRunningTest()) {
                result = IECZuoraHelper.updateDefaultPaymentMethod((String)loggedCustomer.RelatedZuoraAccount.getValue('Id'), customerDefaultPaymentMethodId);
            } 
            // in test method so we fake the call
            else {
                result = new Zuora.zApi.SaveResult();
                result.Success = true;
            }

            if (result.Success) {
                addConfirmMessage(Label.IEC_Confirm_DefaultPaymentUpdate);
                loggedCustomer.refreshZuoraAccount();
                customerDefaultPaymentMethodId = (String)loggedCustomer.RelatedZuoraAccount.getValue('DefaultPaymentMethodId');
            }
            else
                addErrorMessage('Update default payment failed for the following reason(s): ' + IECZuoraHelper.getErrorMessagesString(result.Errors, '<BR> - '));
            */
            
            if (String.isBlank(customerDefaultPaymentType)) {
                addErrorMessage(Label.IEC_Error_DefaultPaymentEmpty);
                customerDefaultPaymentType = loggedCustomer.RelatedAccount.Default_Payment_Type__c;
                return null;
            }
            
            loggedCustomer.RelatedAccount.Default_Payment_Type__c = customerDefaultPaymentType;
            update loggedCustomer.RelatedAccount; 
            addConfirmMessage(Label.IEC_Confirm_DefaultPaymentUpdate);
            
            return null;
        }
        catch (Exception ex) {
            addErrorMessage(ex.getMessage());
            return null;
        }
    }
    
    // Flips the UI to allow user to add new card
    public Pagereference addButton() {
        isAddNew = true;
        return null;
    }
    
    // Flips the UI to allow user to edit existing card
    public Pagereference editButton() {
        return null;
    }
    
    // Flips the UI to reset to original view
    public Pagereference cancelButton() {
        creditCardToEdit = '';
        // force reload of credit cards
        creditCards = null;
        isAddNew = false;
        return null;
    }
    
    private List<IECZuoraHelper.CreditCard> convertFromzObjectList(List<Zuora.zObject> listzObject) {
        if (listzObject == null || listzObject.size() == 0)
            return null;
            
        List<IECZuoraHelper.CreditCard> creditCards = new List<IECZuoraHelper.CreditCard>();
        for (Zuora.zObject zObj : listzObject) {
            if (Limits.getCallouts() == 9)
                break;
            creditCards.add(new IECZuoraHelper.CreditCard(zObj));
        }
        return creditCards;
    }
    
    private IECZuoraHelper.CreditCard getCreditCardById(String creditCardZId) {
        if (creditCards == null || creditCards.size() == 0)
            return null;
            
        for (IECZuoraHelper.CreditCard cc : creditCards) {
            if (cc.zId == creditCardZId)
                return cc;
        }
        
        return null;
    }
    
    //////////// HPM Related functions
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
            
            errorMessage = Test.isRunningTest() ? 'General system error(s) have occurred' : curPage.getParameters().get('errorMessage');
            errorCode = Test.isRunningTest() ? 'GeneralSystemError' : curPage.getParameters().get('errorCode');

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
                addErrorMessages(validationErrors);
            }
            
            sErrorMsgFromHPM = '';
            return null;
        }
        catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        } 
    }
}