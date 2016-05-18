public without sharing class vfIECUpdateAddress   extends IECPageController {

    public list<String> errorMessage            {get; set;}
    
	public Contact oContact {
    	get {
    		return (loggedCustomer != null) ? loggedCustomer.RelatedContact : null;
    	}
	}
    public IECAddress__c oBilling               {get; set;}
    public IECVATUtil.VATConfiguration vatConfig { get; set; }
    
    public Integer iRegistrationStep            {get; set;}
    public String sAccountName					{get; set;}
    
    public Integer constCONTACTINFO             {get {return 1;}}
    public Integer constUPDATECONFIRMATION      {get {return 2;}}
    
    
    /*********************************************************************************************************************/
    /* Constructor Methods
    /*********************************************************************************************************************/
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Controller class constructor
    public vfIECUpdateAddress() {
        errorMessage = new list<string>();
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
                Pagereference prLogin = Page.IECLogin;
                prLogin.getParameters().put(IECConstants.PARAM_RETURN_URL, IECUtil.EncryptEncodeParameter(ApexPages.currentPage().getUrl()));
                prLogin.getParameters().put(IECConstants.PARAM_WARNING_MSG, IECUtil.EncryptEncodeParameter(Label.IEC_Warning_Must_Login));
                prLogin.setRedirect(true);
                return prLogin;
            }
            else {
                // Validate Logged in user profile and ensure profile is complete
                validUserProfile();
                
                //Ensure there is a customer registered
                IECCustomer currentCustomer = IECCustomer.getCurrentIECCustomer();
                if (currentCustomer == null) return null;
                
                //Get the accountAddress related to the user
                Account account = [ select Name, BillingStreet, BillingCity, BillingCountry, BillingState, BillingPostalCode,  IATA_ISO_Country__r.Name
                                    from Account 
                                    where Id =: oContact.AccountId];

                sAccountName = account.Name;
                
                //Get the addresses related to the contact
                List<IECAddress__c> addresses = [select Address_Type__c, State__c, Street__c, City__c, Country__c, ZipCode__c from IECAddress__c where contact__c =: oContact.Id order by LastModifiedDate desc ];
                
                //If the addresses exists, differentiate them by type: billing
                if (addresses != null && addresses.size() > 0) {
                    for(IECAddress__c a : addresses) {
                        if (a.Address_Type__c == IECConstants.IECAddress_AddressType_Billing && oBilling == null) {  
                            oBilling = a.clone(true);
                            vatConfig = IECVATUtil.GetVATConfiguration(oBilling.Country__c);
                        }
                    }
                }
                
                //Create a new address object if no existing billing address
                if (oBilling == null) {
                    oBilling = newAddressFromAccount(account, IECConstants.IECAddress_AddressType_Billing);
                    vatConfig = IECVATUtil.GetVATConfiguration(oBilling.Country__c);
                }
             
                //Set first step in update flow
                iRegistrationStep = constCONTACTINFO;
            }
        }
        catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() ));
            if (Test.isRunningTest())
                throw ex;
        }

        return null;
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Build a new IECAddress object based on the address registered for the given account
    private IECAddress__c newAddressFromAccount(Account account, String addressType) {
        
        IECAddress__c address  = new IECAddress__c(Contact__c = oContact.Id, Address_Type__c = addressType);
        
        if (addressType == IECConstants.IECAddress_AddressType_Billing) {
            address.Street__c = account.BillingStreet ;
            address.City__c = account.BillingCity;
            address.Country__c = (account.IATA_ISO_Country__r.Name == null) ? account.BillingCountry : account.IATA_ISO_Country__r.Name;
            address.State__c = account.BillingState;
            address.ZipCode__c = account.BillingPostalCode;
        }
        
        return address;
    }
    
    /**
     * Method that validates the contact and billing address fields.
     * Adds error message to a collection for all invalid fields.
     */
    private boolean isValidPage() {
        
        //Check for contact Address
        if (String.isBlank(oBilling.Street__c)) {
            errorMessage.add(Label.IEC_Error_Required_field + ' Street');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IEC_Error_Required_field + ' Street' ));
			return false;
        }
            
        if (String.isBlank(oBilling.City__c)) {
            errorMessage.add(Label.IEC_Error_Required_field + ' City');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IEC_Error_Required_field + ' City' ));
			return false;
        }
            
        if (String.isBlank(oBilling.Country__c)){
            errorMessage.add(Label.IEC_Error_Required_field + ' Country');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IEC_Error_Required_field + ' Country' ));
			return false;
        }
        else if (oBilling.Country__c == 'Canada') {
            if (String.isBlank(oBilling.State__c)) {
                errorMessage.add(Label.IEC_Error_Required_field + ' Province');
	            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IEC_Error_Required_field + ' Province' ));
				return false;
            }
            if (String.isBlank(oBilling.ZipCode__c)) {
                errorMessage.add(Label.IEC_Error_Required_field + ' Postal code');
 	            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IEC_Error_Required_field + ' Postal code' ));
				return false;
            }
        }
        else if (oBilling.Country__c == 'United States') {
            if (String.isBlank(oBilling.State__c)) {
                errorMessage.add(Label.IEC_Error_Required_field + ' State');
	            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IEC_Error_Required_field + ' State' ));
				return false;
            }
            if (String.isBlank(oBilling.ZipCode__c)) {
                errorMessage.add(Label.IEC_Error_Required_field + ' Zip code');
	            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IEC_Error_Required_field + ' Zip code' ));
				return false;
            }
        }

        //Check for Tax information
		if (vatConfig != null && vatConfig.TaxIDMandatory) {
			if (vatConfig.ShowTax1) {
				if (String.isBlank(oContact.Tax_1_ID__c)) {
		            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IEC_Error_Required_field + ' ' + vatConfig.Tax1Label ));
					return false;
				}
				else if (vatConfig.VATValidationRequired) {
					IECVATUtil.VATWebService ws = new IECVATUtil.VATWebService();
					try {
						IECVATUtil.VATResponse res = ws.ValidateVAT(vatConfig.CountryCode, oContact.Tax_1_ID__c);
						if (!res.valid)  {
				            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IEC_Error_Invalid_VAT + vatConfig.Tax1Label ));
							return false;
						}
					}
					catch (System.CalloutException ex) {
						if (ex.getMessage().contains('SERVER_BUSY')) {
				            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IEC_Error_VATWSBusy ));
							return false;
						}
						else {
				            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() ));
							return false;
						}							
					}
				}							
			}
			if (vatConfig.ShowTax2) {
				if (String.isBlank(oContact.Tax_2_ID__c)) {
		            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IEC_Error_Required_field + ' ' + vatConfig.Tax2Label ));
					return false;
				}
				else if (vatConfig.VATValidationRequired) {
					IECVATUtil.VATWebService ws = new IECVATUtil.VATWebService();
					try {
						IECVATUtil.VATResponse res = ws.ValidateVAT(vatConfig.CountryCode, oContact.Tax_2_ID__c);
						if (!res.valid)  {
				            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IEC_Error_Invalid_VAT + vatConfig.Tax2Label ));
							return false;
						}
					}
					catch (System.CalloutException ex) {
						if (ex.getMessage().contains('SERVER_BUSY')) {
				            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IEC_Error_VATWSBusy ));
							return false;
						}
						else {
				            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() ));
							return false;
						}							
					}
				}
			}
		}
        return true;
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Update the contact information
    public PageReference updateContact() {
        try {
            //Check for valid form fill
            if (!isValidPage())
                return null;
            
            //Updates SF Address information 
            
            vatConfig = IECVATUtil.GetVATConfiguration(oBilling.Country__c);
            oContact.VAT_Country_Code__c = (vatConfig.VATValidationRequired) ? vatConfig.CountryCode : null;
            
            //update oContact;
            IECUserManager.updateContactViaWebService(oContact);
            
            upsert oBilling;
            
            iRegistrationStep = constUPDATECONFIRMATION;
        }
        catch (Exception ex) {
            errorMessage.add(ex.getMessage());
            addErrorMessage(ex);
        }

        return null;
    }    
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Handles the change of Billing optino change
    public PageReference BillingCountryChanged() {
        oBilling.State__c = '';

		if (vatConfig != null
			&& vatConfig.Country != oBilling.Country__c) {
				
			vatConfig = IECVATUtil.GetVATConfiguration(oBilling.Country__c);
			oContact.Tax_1_ID__c = null;
			oContact.Tax_2_ID__c = null;
		}

        return null;
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Returns the list of countries pairs: nama-name
    public List<SelectOption> getCountries() {
        return IECUtil.getCountries_NameName();
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Returns the list of provinces of Canada
    public List<SelectOption> getCanadaProvinces() {
        return IECConstants.getCanadaProvinces();
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Returns the list of states in US
    public List<SelectOption> getUSAStates() {
        return IECConstants.getUSAStates();
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Goes back to Contact informaion form 
    public void backToContactInfo() {
        iRegistrationStep = constCONTACTINFO;
    }
}