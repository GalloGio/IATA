public without sharing class vfIECUpdateAddress   extends IECPageController {

    public list<String> errorMessage            {get; set;}
    
	public Contact oContact {
    	get {
    		return (loggedCustomer != null) ? loggedCustomer.RelatedContact : null;
    	}set;
	}

    public IECAddress__c oBillingAddress			{get; set;}
    public IECAddress__c oOriginalBillingAddress { get; set; }
    public Location__c oBillingLocation				{get; set;}
    public IECVATUtil.VATConfiguration vatConfig	{ get; set; }
    public Boolean billingUpdateConfirmation   {get;set;}


    public IECAddress__c oShippingAddress       {get;set;}
    public IECAddress__c oOriginalShippingAddress { get; set; }
    public Location__c oShippingLocation             {get; set;}
    public IECVATUtil.VATConfiguration vatConfigShipping    { get; set; }
    public Boolean shippingUpdateConfirmation   {get;set;}
    
    public Integer iRegistrationStep            {get; set;}
    public String sAccountName					{get; set;}
    
    public Integer constCONTACTINFO             {get {return 1;}}
    public Integer constUPDATECONFIRMATION      {get {return 2;}}
    List<ISO_Country_State_DTO> lstCountryState;
    public Boolean bStateAvailable
	{
		get
		{
			return getStateProvince().size() > 1;
		}
	}

    public Boolean sStateAvailable
    {
        get
        {
            return getShippingStateProvince().size() > 1;
        }
    }
	
    public Set<Id> setCountryRequireZipCode		{get; set;}
    public Boolean bCountryRequireZipCode
    {
		get
		{
			return setCountryRequireZipCode.contains(oBillingAddress.ISO_Country__c);
		}
	}
    public Boolean sCountryRequireZipCode
    {
        get
        {   if(oShippingAddress != null)
                return setCountryRequireZipCode.contains(oShippingAddress.ISO_Country__c);
            return false;
        }
    }

    //set the Shipping address pickList
    public List<SelectOption> shippingAddresses{get;set;}
    map<Id,IECAddress__c> iecAddressesMap = new map<Id,IECAddress__c>();
    public String shippingVATNumber{get;set;}
    Map<Id,Location__c> addressId_shippingLocation = new Map<Id,Location__c>();

    
    /*********************************************************************************************************************/
    /* Constructor Methods
    /*********************************************************************************************************************/
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Controller class constructor
    public vfIECUpdateAddress() {
        errorMessage = new list<string>();
        setCountryRequireZipCode = new Set<Id>();
        
        // Preload list of Countries/States
        lstCountryState = ISO_Country_State_Helper.getCountry_State();
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

                // customer does not have a billing or shipping address,
                if(oContact.BillTo_Location__c == null || oContact.ShipTo_Location__c == null){
                    Boolean locationInit = (Location_Svc.initializeDefaultLocations(new List<Id>{oContact.Id})[0] == null);
                    if(!locationInit){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, label.Address_edition_error ));
                        return null;
                    }
                    oContact = IECUserManager.getContactById(oContact.Id);
                    
                }
                
                //Get the addresses related to the contact
                Account account = [ select Name, BillingStreet, BillingCity, BillingCountry, BillingState, BillingPostalCode,  IATA_ISO_Country__r.Name
                                    from Account 
                                    where Id =: oContact.AccountId];

                sAccountName = account.Name;
                
                // Retrieve Country ID for USA and Canada to be used for validation on the page
                for (IATA_ISO_Country__c country : IATAIsoCountryDAO.getIsoCountryByIsoCodes(new Set<String>{'US', 'CA'}))
                {
                	setCountryRequireZipCode.add(country.Id);
                }

                // check if the customer needs to fill his contact information
                if (IECUserManager.hasAddress(oContact.Id, IECConstants.IECAddress_AddressType_Billing)) {
                	// Retrieve existing billing location for this contact
                	oBillingLocation = Location_Sel.getLocationByContact(loggedCustomer.RelatedContact.Id, IECConstants.IECAddress_AddressType_Billing)[0];
                    
                    List<IECAddress__c> lstAddresses = IECUserManager.getAddressByContact(loggedCustomer.RelatedContact.Id, IECConstants.IECAddress_AddressType_Billing);
                    if (lstAddresses.size() > 0) {
                        oBillingAddress = lstAddresses.get(0);
                        // Clone the record to check later whether it is changed when saving
                    	oOriginalBillingAddress = lstAddresses.get(0).clone(false, true);
                        vatConfig = IECVATUtil.GetVATConfiguration(oBillingAddress.ISO_Country_Name__c); // Changed by Samy (2016-02-29) from Country__c
                    }
                }
                /*else {
                    // customer does not have a billing address, so create a new one, and also create a new Location
                    oBillingLocation = new Location__c(
                    	Active__c = true
                    	, Account__c = loggedCustomer.RelatedAccount.Id
                    	, Contact__c = loggedCustomer.RelatedContact.Id
                    	, Type__c = IECConstants.IECAddress_AddressType_Billing
                    );
                    oBillingAddress = newAddressFromAccount(account, IECConstants.IECAddress_AddressType_Billing);
                    vatConfig = IECVATUtil.GetVATConfiguration(oBillingAddress.Country__c);
                }*/

                //set the Contact Shipping information
                shippingVATNumber = '';
                if(IECUserManager.hasAddress(oContact.Id, IECConstants.IECAddress_AddressType_Shipping)){
                    List<Location__c> lstShippingLocation = Location_Sel.getLocationByContact(loggedCustomer.RelatedContact.Id, IECConstants.IECAddress_AddressType_Shipping);

                    //set the shipping location with the contact default location
                    if(lstShippingLocation.size() > 0){
                        for(Location__c location : lstShippingLocation){
                            if(oContact.ShipTo_Location__c == null){
                                oShippingLocation = lstShippingLocation.get(0);
                            }
                            else if(location.Id == oContact.ShipTo_Location__c){
                                oShippingLocation = location;
                            }
                            addressId_shippingLocation.put(location.Address__c,location);
                        }
                    }

                    shippingVATNumber = oShippingLocation.VAT_Number__c;
                    
                    //List<IECAddress__c> lstAddresses = IECUserManager.getAddressByContact(loggedCustomer.RelatedContact.Id, IECConstants.IECAddress_AddressType_Shipping);
                    List<IECAddress__c> lstAddresses = new IECAddress_Sel().getAddresses(addressId_shippingLocation.keySet()); 
                    //set the Shipping addresses pickList values
                    shippingAddresses = new List<SelectOption>();

                    //Set the default shipping address
                    if(lstAddresses != null && lstAddresses.size() > 0){
                        
                        iecAddressesMap = new map<Id,IECAddress__c>(lstAddresses);

                        shippingAddresses.add(new SelectOption('',''));
                        for(IECAddress__c address : lstAddresses){
                            String selectAddressValue = address.Street__c + ' ' + address.City__c;
                            selectAddressValue += (address.ZipCode__c != null) ? address.ZipCode__c : '';
                            shippingAddresses.add(new SelectOption(address.Id, selectAddressValue));
                            if(address.Id == oShippingLocation.Address__c){
                                oShippingAddress = address;
                            }
                        }
                        
                        oOriginalShippingAddress = oShippingAddress.clone(false,true);
                        vatConfigShipping = IECVATUtil.GetVATConfiguration(oShippingAddress.ISO_Country_Name__c);
                    }
                }
                
                /* Commented by Samy (2016-03-02) Changing the Address structure to use the Location object
                //Get the addresses related to the contact
                List<IECAddress__c> addresses = [select Address_Type__c, State__c, Street__c, City__c, Country__c, ZipCode__c from IECAddress__c where contact__c =: oContact.Id order by LastModifiedDate desc ];
                
                //If the addresses exists, differentiate them by type: billing
                if (addresses != null && addresses.size() > 0) {
                    for(IECAddress__c a : addresses) {
                        if (a.Address_Type__c == IECConstants.IECAddress_AddressType_Billing && oBillingAddress == null) {  
                            oBillingAddress = a.clone(true);
                            vatConfig = IECVATUtil.GetVATConfiguration(oBillingAddress.Country__c);
                        }
                    }
                }
                
                //Create a new address object if no existing billing address
                if (oBillingAddress == null) {
                    oBillingAddress = newAddressFromAccount(account, IECConstants.IECAddress_AddressType_Billing);
                    vatConfig = IECVATUtil.GetVATConfiguration(oBillingAddress.Country__c);
                }*/
             
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
    /*private IECAddress__c newAddressFromAccount(Account account, String addressType) {
        
        IECAddress__c address  = new IECAddress__c(Contact__c = oContact.Id, Address_Type__c = addressType);
        
        if (addressType == IECConstants.IECAddress_AddressType_Billing) {
            address.Street__c = account.BillingStreet ;
            address.City__c = account.BillingCity;
            address.Country__c = (account.IATA_ISO_Country__r.Name == null) ? account.BillingCountry : account.IATA_ISO_Country__r.Name;
            address.State__c = account.BillingState;
            address.ZipCode__c = account.BillingPostalCode;
        }
        
        return address;
    }*/
    
    /**
     * Method that validates the contact and billing address fields.
     * Adds error message to a collection for all invalid fields.
     */
    private boolean isValidPage(IECAddress__c address, Boolean countryRequireZipCode, Boolean stateAvailable, 
                                IECVATUtil.VATConfiguration vatConfiguration, String shippingVAT) {
        
        //Check for contact Address
        if (String.isBlank(address.Street__c)) {
            errorMessage.add(Label.IEC_Error_Required_field + ' Street');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IEC_Error_Required_field + ' Street' ));
			return false;
        }
            
        if (String.isBlank(address.City__c)) {
            errorMessage.add(Label.IEC_Error_Required_field + ' City');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IEC_Error_Required_field + ' City' ));
			return false;
        }
            
        if (String.isBlank(address.ISO_Country__c)){
            errorMessage.add(Label.IEC_Error_Required_field + ' Country');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IEC_Error_Required_field + ' Country' ));
			return false;
        }
        
        if (stateAvailable && String.isBlank(address.ISO_State__c)) // Changed by Samy (2016-03-01) from State__c
        {
            errorMessage.add(Label.IEC_Error_Required_field + ' State/Province');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IEC_Error_Required_field + ' State/Province' ));
        }

        if (countryRequireZipCode) {
            if (String.isBlank(address.ZipCode__c)) {
                errorMessage.add(Label.IEC_Error_Required_field + ' Zip/Postal code');
 	            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IEC_Error_Required_field + ' Zip/Postal code' ));
				return false;
            }
        }

        //
        if(shippingVAT != null && shippingVAT != '' && vatConfiguration.VATValidationRequired){
            IECVATUtil.VATWebService ws = new IECVATUtil.VATWebService();
            try {
                IECVATUtil.VATResponse res = ws.ValidateVAT(vatConfiguration.CountryCode, shippingVAT);
                if (!res.valid)  {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IEC_Error_Invalid_VAT + ' VAT number' ));
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

        //Check for Tax information
		if (vatConfiguration != null && vatConfiguration.TaxIDMandatory) {
			if (vatConfiguration.ShowTax1) {
				if (String.isBlank(oContact.Tax_1_ID__c)) {
		            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IEC_Error_Required_field + ' ' + vatConfiguration.Tax1Label ));
					return false;
				}
				else if (vatConfiguration.VATValidationRequired) {
					IECVATUtil.VATWebService ws = new IECVATUtil.VATWebService();
					try {
						IECVATUtil.VATResponse res = ws.ValidateVAT(vatConfiguration.CountryCode, oContact.Tax_1_ID__c);
						if (!res.valid)  {
				            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IEC_Error_Invalid_VAT + vatConfiguration.Tax1Label ));
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
			if (vatConfiguration.ShowTax2) {
				if (String.isBlank(oContact.Tax_2_ID__c)) {
		            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IEC_Error_Required_field + ' ' + vatConfiguration.Tax2Label ));
					return false;
				}
				else if (vatConfiguration.VATValidationRequired) {
					IECVATUtil.VATWebService ws = new IECVATUtil.VATWebService();
					try {
						IECVATUtil.VATResponse res = ws.ValidateVAT(vatConfiguration.CountryCode, oContact.Tax_2_ID__c);
						if (!res.valid)  {
				            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IEC_Error_Invalid_VAT + vatConfiguration.Tax2Label ));
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
            if (!isValidPage(oBillingAddress, bCountryRequireZipCode, bStateAvailable,vatConfig,null))
                return null;
            
            //Updates SF Address information 
            
            vatConfig = IECVATUtil.GetVATConfiguration(oBillingAddress.ISO_Country__c);
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

                //get the Shipping country iso code         
                String billingIsoCountry = '';
                List<IATA_ISO_Country__c> lstIsoCountries = ISO_Country_State_Helper.getIsoCountryById(oBillingAddress.ISO_Country__c);
                if(lstIsoCountries != null && lstIsoCountries.size() > 0)
                    billingIsoCountry = lstIsoCountries.get(0).ISO_Code__c;

                //get the Shipping State code
                String billingStateIsoState = '';
                List<IATA_ISO_State__c> lstStates = ISO_Country_State_Helper.getIsoStateById(oBillingAddress.ISO_State__c);
                if(lstStates != null && lstStates.size() > 0)
                    billingStateIsoState = lstStates.get(0).ISO_Code__c;

                // First query the address table to make sure that the address doesn't already exist
                List<IECAddress__c> lstAddress = new IECAddress_Sel().getAddress(oBillingAddress.Street__c, oBillingAddress.City__c, 
                                                                                billingIsoCountry, billingStateIsoState, oBillingAddress.ZipCode__c);
                
                //Get the correct address id for the location
                Id billingNewAddress;
                if(lstAddress != null && lstAddress.size() > 0){
                    billingNewAddress = lstAddress.get(0).Id;
                }else{
                    insert oBillingAddress;
                    billingNewAddress = oBillingAddress.Id;
                }
	            
	            // Then copy the ID into the location record
	            oBillingLocation.Address__c = billingNewAddress;
                oBillingLocation.VAT_Number__c = oContact.Tax_1_ID__c;
	            update oBillingLocation;
            }
            
            iRegistrationStep = constUPDATECONFIRMATION;
            billingUpdateConfirmation = true;
        }
        catch (Exception ex) {
            errorMessage.add(ex.getMessage());
            addErrorMessage(ex);
        }

        return null;
    }    

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Update the contact information
    public PageReference updateShippingContact() {
        try {
            //Check for valid form fill
            if (!isValidPage(oShippingAddress, sCountryRequireZipCode, sStateAvailable,vatConfigShipping,shippingVATNumber))
                return null;
            
            //Updates SF Address information 
            vatConfigShipping = IECVATUtil.GetVATConfiguration(oShippingAddress.ISO_Country__c);
            oContact.VAT_Country_Code__c = (vatConfigShipping.VATValidationRequired) ? vatConfigShipping.CountryCode : null;
            
            //update oContact;
            IECUserManager.updateContactViaWebService(oContact);
            
            // First check if the address has been changed before trying to save, otherwise just ignore
            if (IECAddress_Svc.isAddressChanged(oShippingAddress, oOriginalShippingAddress) || shippingVATNumber != oShippingLocation.VAT_Number__c)
            {
                    
                //get the Shipping country iso code         
                String shippingIsoCountry = '';
                List<IATA_ISO_Country__c> lstIsoCountries = ISO_Country_State_Helper.getIsoCountryById(oShippingAddress.ISO_Country__c);
                if(lstIsoCountries != null && lstIsoCountries.size() > 0)
                    shippingIsoCountry = lstIsoCountries.get(0).ISO_Code__c;

                //get the Shipping State code
                String shippingStateIsoState = '';
                List<IATA_ISO_State__c> lstStates = ISO_Country_State_Helper.getIsoStateById(oShippingAddress.ISO_State__c);
                if(lstStates != null && lstStates.size() > 0)
                    shippingStateIsoState = lstStates.get(0).ISO_Code__c;

                // First query the address table to make sure that the address doesn't already exist
                List<IECAddress__c> lstAddress = new IECAddress_Sel().getAddress(oShippingAddress.Street__c, oShippingAddress.City__c, 
                                                                                shippingIsoCountry, shippingStateIsoState, oShippingAddress.ZipCode__c);
                
                //Get the correct address id for the location
                Id shippingNewAddress;
                if(lstAddress != null && lstAddress.size() > 0){
                    shippingNewAddress = lstAddress.get(0).Id;
                }else{
                    oShippingAddress.Id = null;
                    insert oShippingAddress;
                    shippingNewAddress = oShippingAddress.Id;
                }

                // Then copy the ID into the location record
                oShippingLocation.Address__c = shippingNewAddress;
                oShippingLocation.VAT_Number__c = shippingVATNumber;
                
                try{
                    update oShippingLocation;
                    shippingUpdateConfirmation = true;
                    billingUpdateConfirmation = false;
                }catch(Exception ex){
                    errorMessage.add(ex.getMessage());
                    //addErrorMessage(ex);
                }
                
            }
            
            //iRegistrationStep = constUPDATECONFIRMATION;
            
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
        oBillingAddress.ISO_State__c = null;

		if (vatConfig != null
			&& vatConfig.CountryId != oBillingAddress.ISO_Country__c) {
				
			vatConfig = IECVATUtil.GetVATConfiguration(oBillingAddress.ISO_Country__c);
			oContact.Tax_1_ID__c = null;
			oContact.Tax_2_ID__c = null;
		}

        return null;
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Handles the change of Shipping option change
    public PageReference ShippingCountryChanged() {
        oShippingAddress.ISO_State__c = null;

        if (vatConfigShipping != null
            && vatConfigShipping.CountryId != oShippingAddress.ISO_Country__c) {
                
            vatConfigShipping = IECVATUtil.GetVATConfiguration(oShippingAddress.ISO_Country__c);
            /*oContact.Tax_1_ID__c = null;
            oContact.Tax_2_ID__c = null;*/
        }

        return null;
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Handles the change of Shipping address option change
    public PageReference ShippingAddressChanged(){
        if(iecAddressesMap != null && oShippingAddress != null){
            
            oShippingAddress = iecAddressesMap.get(oShippingAddress.Id);
            if(oShippingAddress != null){
                vatConfigShipping = IECVATUtil.GetVATConfiguration(oShippingAddress.ISO_Country_Name__c);

                Location__c location = addressId_shippingLocation.get(oShippingAddress.Id);
                
                shippingVATNumber = '';
                if(location != null){
                    shippingVATNumber = location.VAT_Number__c;
                }
            
            }

            //System.debug('oShippingAddress.Id ' + oShippingAddress.Id);
            
            
            
        }
        return null;
    }
    
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Returns the list of countries pairs: id-name
    public List<SelectOption> getCountries() {
        return ISO_Country_State_Helper.getPicklistISOCountry(lstCountryState);
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Returns the list of state/province
    public List<SelectOption> getStateProvince() {
        return ISO_Country_State_Helper.getPicklistISOState(lstCountryState, oBillingAddress.ISO_Country__c);
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Returns the list of state/province
    public List<SelectOption> getShippingStateProvince() {
        if(oShippingAddress != null)
            return ISO_Country_State_Helper.getPicklistISOState(lstCountryState, oShippingAddress.ISO_Country__c);
        return new List<SelectOption>();
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Goes back to Contact informaion form 
    public void backToContactInfo() {
        iRegistrationStep = constCONTACTINFO;
    }
}