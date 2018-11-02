/******************************************************************************************************************
 *  IEC_MyPaymentMethodsController: IEC_MyPaymentMethods page Controller                                          *
 *  Author: David Daboué - CGI                                                                                    *        
 ******************************************************************************************************************/
public with sharing class IEC_MyPaymentMethodsController extends IEC_PageController
{
	public List<IEC_CreditCard_DTO> creditCards{get;set;}
	public Map<String, IEC_CreditCard_DTO> creditCardById;
	public String creditCardsJSON{get;set;}
	public String defaultPaymentMethodId{get;set;}

	public IEC_CreditCard_DTO selectedCreditCard{get;set;}
	public String selectedCreditCardId{get;set;}
	public String newCreditCardPaymentId { get; set; }

	public boolean hasConfigError { get; set; }
	public String  sErrorMsgFromHPM { get; set; }
  public String  iframeSrc { get; set; }
  private String errorMessage;
  private String errorCode;
  private String pageId; 
  private String apiSecurityKey;
  private String appUrl; 
  private String tenantId;  

  public Boolean hasValidBillingAddress{get;set;}
  public Boolean recreateZuoraAccount;

  public List<SelectOption> availableMonths {
      get {
      	if(availableMonths == null){
      		availableMonths = new List<SelectOption>();
      		for(Integer x=1; x<=12; x++)
      			availableMonths.add(new SelectOption(String.valueOf(x), (x<10)? '0'+String.valueOf(x) : String.valueOf(x)));
      	}            
          return availableMonths;
      }set;
  }

    public List<SelectOption> availableYears {
        get {
        	if(availableYears == null){
        		availableYears = new List<SelectOption>();
        		Integer year = Date.Today().Year();
        		for(Integer x = year; x <= year+20; x++)
        			availableYears.add(new SelectOption(String.valueOf(x), String.valueOf(x)));
        	}
        	return availableYears;
        }set;
    }

    public List<SelectOption> getAvailableCountries() {
        List<SelectOption> options = IECZuoraHelper.getZuoraCountriesSelectOptions();
        options.add(0, new SelectOption('','--Please select--'));
        return options;
    }

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
            'field_accountId' => (loggedCustomer.zAccount == null) ? '' : (String)loggedCustomer.zAccount.getValue('Id')
        }; 
    }

	/**************************************************************************************************************
     *  IEC_MyPaymentMethodsController: Class Constructor                                                         *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
	public IEC_MyPaymentMethodsController()  
	{
    recreateZuoraAccount=false;//Used to force zAccount recreation for unit test purpose
	}

  private Boolean isEmailValid(String inputEmail)
  {
      Matcher regexCheck;
      String emailPattern = '^[\\w!#$%&’*+/=?`{|}~^-]+(?:\\.[\\w!#$%&’*+/=?`{|}~^-]+)*@(?:[a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,6}$';
      regexCheck = Pattern.compile(emailPattern).matcher(inputEmail);
      return regexCheck.find();
  }


  public Boolean validateBillingInformation()
  {
    Boolean isValid = true; 

    if(loggedCustomer.sfContact.BillTo_Location__c==null) return false;

    Address_DTO billToAddress = Address_DTO.format2DTO(loggedCustomer.sfContact.BillTo_Location__c); 
    List<SelectOption> billToAvailableStates = ISO_Country_State_Helper.getStatesSelectOption(billToAddress.countryCode);

    if((String.isBlank(billToAddress.phone)) 
      || (String.isBlank(billToAddress.email)) 
      || (!isEmailValid(billToAddress.email)) 
      || (String.isBlank(billToAddress.street1)) 
      || (billToAddress.isPostalCodeRequired!=null && billToAddress.isPostalCodeRequired && String.isBlank(billToAddress.postalCode)) 
      || (String.isBlank(billToAddress.city)) 
      || (String.isBlank(billToAddress.countryCode)) 
      || (billToAvailableStates!=null && billToAvailableStates.size() > 0 && String.isBlank(billToAddress.stateCode))
    )
      isValid = false;
    
    return isValid;
  }

	/**************************************************************************************************************
     *  onLoadAction: method calls when page loaded                                                               *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
	public PageReference onLoadAction()
	{
		//-- Validate Customer is logged-in 
		if(loggedCustomer == null)
		{
			PageReference ret = new PageReference('/IEC_Login?returl=/IEC_MyPaymentMethods');
			ret.setRedirect(true);
	        return ret;
		}

    //-- Validate Customer has BillTo & ShipTo 
    hasValidBillingAddress = validateBillingInformation();
    if(!hasValidBillingAddress)
    {
      addErrorMessage('You must have a valid billing address first');
      hasValidBillingAddress = false;
      return null;
    }
    
		//-- Query customer Credit Cards  
		refreshCreditCards();

		//-- Load Cybersource Iframe to add card
		loadHPMIframe();
		
		return null;
	}

	/**************************************************************************************************************
     *  refreshCreditCards: method to reload customers credit cards list from Zuora 							  *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
	public void refreshCreditCards()
	{
		creditCards = loggedCustomer.creditCards;

		creditCardById = new Map<String, IEC_CreditCard_DTO>(); 
		for(IEC_CreditCard_DTO cc : creditCards){
			creditCardById.put(cc.zId, cc);
			if(cc.isDefault){
				defaultPaymentMethodId = cc.zId;
			}
		}
		creditCardsJSON = JSON.serialize(creditCardById);
	}

	/**************************************************************************************************************
     *  setSelectedCreditCard: method calls from visualforce page when customer click "Edit" or "Remove" link 	  *
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
     *  addCreditCard: callback when credit card added successfully 							 		                      		  *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
	public PageReference addCreditCard()
	{
		if (String.isBlank(newCreditCardPaymentId)) {            	
            addErrorMessage(Label.IEC_Error_HostedPaymentIdMissing);
        }
        else
        {
            if(loggedCustomer.zAccount == null || recreateZuoraAccount)
            {
              System.debug('Create Zuora Account');
              //Create Zuora Account
              Zuora.zObject zAccount = IECZuoraHelper.createZuoraAccount(loggedCustomer.sfAccount, loggedCustomer.sfContact, IECConstants.PaymentType.CREDIT_CARD, newCreditCardPaymentId);
                zAccount.setValue('Status','Draft');
                zAccount.setValue('AutoPay', false);
              List<Zuora.zApi.SaveResult> accountCreateRes = IECZuoraHelper.createApiCall(new List<Zuora.zObject>{zAccount});    
              
              zAccount = IECZuoraHelper.getZuoraAccountBySFAccountId(loggedCustomer.sfAccount.Id, loggedCustomer.sfContact.Id);  

              //Create zContact
              Zuora.zObject zContact  = ZuoraUtil.createZuoraBillToContact(loggedCustomer.sfContact);
                zContact.setValue('AccountId',zAccount.getValue('Id'));
              List<Zuora.zApi.SaveResult> contactCreateRes = IECZuoraHelper.createApiCall(new List<Zuora.zObject>{zContact});
              
              zAccount.setValue('Status','Active');
              zAccount.setValue('BillToId',contactCreateRes[0].Id);
              zAccount.setValue('SoldToId',contactCreateRes[0].Id);
              List<Zuora.zApi.SaveResult> accountUpdateRes = ZuoraUtil.zupdate(new List<Zuora.zObject>{zAccount});

              IECSubscriptionManager.OnDemandSyncAccounts(new Set<String>{(String)zAccount.getValue('Id')});
              
              loggedCustomer.zAccount = IECZuoraHelper.getZuoraAccountBySFAccountId(loggedCustomer.sfAccount.Id, loggedCustomer.sfContact.Id);  
            }

            loggedCustomer.loadCreditCards();
            refreshCreditCards();
            loadHPMIframe();

            addConfirmMessage('The credit card  has been successfully added.');

            //-- Make card default if no othercard 
            if(loggedCustomer.creditCards.size() == 1)
            {
              defaultPaymentMethodId = newCreditCardPaymentId;
              setDefaultPaymentMethod();
            }

        }
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

        List<String> validationErrors = new List<String>();
        Boolean validationError = false;

        for ( String errorField : IECErrorCodeMapping.ERROR_FIELD_MAPPING.keySet() ) {
            String errorFieldValue = curPage.getParameters().get( errorField ); 
            if ( errorFieldValue != null && errorFieldValue.trim().length() > 0 ) {
                addErrorMessage( IECErrorCodeMapping.ERROR_FIELD_MAPPING.get( errorField ) + ': ' + IECErrorCodeMapping.VALUES.get( errorFieldValue ) ); 
                validationError = true;
            }
        }

        if(!validationError){
          String errorMessage = curPage.getParameters().get('errorMessage');
          if(errorMessage != null && errorMessage != ''){
            addErrorMessage(errorMessage);
          }
        }

        loadHPMIframe();
    	return null; 
    }

    /**************************************************************************************************************
     *  editCreditCard: method to perform credit edition                                                          *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
	public PageReference editCreditCard()
	{
		try {
            Zuora.zApi.SaveResult result;
            
            if (!Test.isRunningTest()) result = IECZuoraHelper.updateCreditCard(selectedCreditCard.toZObjectForUpdate()); 
            else {
                result = new Zuora.zApi.SaveResult();
                result.Success = true;
            }
             
            if (result.Success) {
                loggedCustomer.loadCreditCards();
                refreshCreditCards();


                addConfirmMessage('The credit card ' + selectedCreditCard.creditCardMaskNumber + ' has been successfully updated.');
            }
            else {
                addErrorMessage('Update credit card failed for the following reason(s):' + IECZuoraHelper.getErrorMessagesString(result.Errors, '<BR> - '));
            }

            return null;
        }
        catch (Exception ex) {addErrorMessage(ex.getMessage()); return null; }
	}

	/**************************************************************************************************************
     *  removeCreditCard: method to perform credit card deletion                                                  *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
	public PageReference removeCreditCard()
	{
		System.debug('removeCreditCard');
		System.debug('selectedCreditCard::'+selectedCreditCard);
		try {
			
            if (selectedCreditCard.isDefault) {
                addErrorMessage(Label.IEC_Error_DeleteDefaultPayment);
                return null;
            }
            
            Zuora.zApi.DeleteResult result;
            
            if (!Test.isRunningTest()) result = IECZuoraHelper.deleteCreditCard(selectedCreditCard.zId); 
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
        catch (Exception ex) {addErrorMessage(ex.getMessage()); return null;}
	}

	/**************************************************************************************************************
     *  setDefaultPaymentMethod: method to set default credit card                                                *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
	public PageReference setDefaultPaymentMethod()
	{
		try
		{
		  loggedCustomer.zAccount.setValue('DefaultPaymentMethodId', defaultPaymentMethodId);
			IECZuoraHelper.updateApiCall(loggedCustomer.zAccount);

			loggedCustomer.loadCreditCards();
      refreshCreditCards();

      IEC_CreditCard_DTO selectedCreditCard = creditCardById.get(defaultPaymentMethodId);
      addConfirmMessage('The credit card ' + selectedCreditCard.creditCardMaskNumber + ' has been successfully set as default card.');

			return null;
		}
		catch(Exception ex){addErrorMessage(ex.getMessage());return null;	}		
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
        if ( this.pageId == null || this.pageId.trim().length() == 0 ) missingFields += ' Page ID,';
    
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
        catch( HPMConfigException e ) {hasConfigError = true;addErrorMessage(IECErrorCodeMapping.VALUES.get( 'Sfdc.ErrorLoadingFrame' ) + e.getMessage());
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
        catch (Exception ex) {addErrorMessage(ex.getMessage());}        
    }
}