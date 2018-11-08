/**
 * VisualForce page controller for the quote submit page
 *
 * This page includes:
 * - content of the quote
 * 	 - price
 *   - comments textarea
 * - Billing address info
 * - Auto-renew flag selection
 * - submit quote button 
 */
public class vfIECQuote extends IECPageController {
	
	public string sProductRatePlanInfoId { get; private set; }
	public Product_Rate_Plan_Information__c oQuoteRatePlanInfo { get; private set; }
	public List<zqu__ProductRatePlanCharge__c> lstQuoteRatePlanCharges { get; private set; }
	public Integer iQuantity { get; set; }
	public boolean isUserLoggedIn {get; set;}
	public boolean bShowPrice {get; set;}
	public Decimal shoppingCartTotalBeforeTax {get; set;}
	public Decimal shoppingCartTax {get; set;}
	public Decimal shoppingCartShipping {get; set;}
	public Decimal shoppingCartTotal {get; set;}
	
	//New Tax and shipping fields
	public Decimal dTax {get; set;}
	public Decimal dShipping {get; set;}
	
    public Boolean bQuoteSubmitSucessful { get; private set; }
    public zqu__Quote__c oQuote { get; private set; }
    public String sComments { get; set; }

    public String autoRenewFlag { get; set; }
    
    public Boolean needToFillContactInfo { get; private set; }
    public Boolean inEditContactInfo { get; private set; }
    public Boolean isCountryFilled { get; private set; }
    public IECAddress__c oBillingAddress { get; set; }
    public IECAddress__c oOriginalBillingAddress { get; set; }
    public Location__c oBillingLocation { get; set; }
    public IECVATUtil.VATConfiguration vatConfig { get; set; }
    
	public Boolean bHasAllAutoRenew {get; set;}
	
	public Boolean bExpandedBilling {get; set;}
	public Boolean bExpandedAutoRenewal {get; set;}
	
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

	public Boolean cartIsEmpty {
		get {
			return (oQuoteRatePlanInfo == null);
		}
	}
	
	
	public Boolean hasFilledAutoRenewFlags {
		get {
			return String.isNotBlank(autoRenewFlag);
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
	public vfIECQuote() {
		try {

			oQuoteRatePlanInfo = null;
			bQuoteSubmitSucessful = false;
			bHasAllAutoRenew = false;

			bExpandedBilling = true;
			bExpandedAutoRenewal = true;
			
			iQuantity = 1;
			autoRenewFlag = '';

			// Preload list of Countries/States
			lstCountryState = ISO_Country_State_Helper.getCountry_State();

			// check if the rate plan info id was passed as a parameter
			String sParamProductRatePlanInfoID = ApexPages.currentPage().getParameters().get(IECConstants.PARAM_RATEPLANINFO_ID);
			
			// if the parameter was found
			if (String.isNotBlank(sParamProductRatePlanInfoID)) {
				sProductRatePlanInfoId = IECUtil.DecodeDecryptParameter(sParamProductRatePlanInfoID);
			}
			else if (String.isNotBlank(IECCookieHelper.getQuoteRatePlanInfo())) {
				// else, check in the cookie
				sProductRatePlanInfoId = IECCookieHelper.getQuoteRatePlanInfo();
			}
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
			isUserLoggedIn = IECUserManager.isUserLoggedIn();
			
			if (String.isBlank(sProductRatePlanInfoId))
				throw new IECApplicationException('The page parameter is invalid');

			oQuoteRatePlanInfo = IECProductManager.getProductRatePlansInformationById(sProductRatePlanInfoId).get(0);
			
			if (oQuoteRatePlanInfo == null)
				throw new IECApplicationException('The product was not found');

			if (isUserLoggedIn) {
				
				// Validate Logged in user profile and ensure profile is complete
				validUserProfile();
				
				// if a product rate plan info id was provided for the quote
				if (String.isNotBlank(sProductRatePlanInfoId)) {
					
					// Get SWAP if the client type doesn't match using the Swap Configuration (Source -> Target) 
					Map<ID, Product_Rate_Plan_Information__c> targetRatePlans = IECSubscriptionManager.getTargetSwappedRatePlans(new Set<Id> {sProductRatePlanInfoId}, IECUserManager.getClientType());
						
					// if a configured swap has been found, switch rate plan
					if (targetRatePlans != null && !targetRatePlans.isEmpty()) {
						sProductRatePlanInfoId = targetRatePlans.values().get(0).Id;
						oQuoteRatePlanInfo = IECProductManager.getProductRatePlansInformationById(sProductRatePlanInfoId).get(0);
						
						// update url parameter
						ApexPages.currentPage().getParameters().put(IECConstants.PARAM_RATEPLANINFO_ID, IECUTil.EncryptEncodeParameter(sProductRatePlanInfoId));	
					}
				}
				
				bShowPrice = (oQuoteRatePlanInfo.Related_Product_Information__r.Related_Product_Category__r.Show_price_on_eCommerce__c == null
					|| oQuoteRatePlanInfo.Related_Product_Information__r.Related_Product_Category__r.Show_price_on_eCommerce__c == 'Yes');

	            // check if the customer needs to fill his contact information
	            if (IECUserManager.hasAddress(loggedCustomer.RelatedContact.Id, IECConstants.IECAddress_AddressType_Billing)) {
	            	needToFillContactInfo = !IECUserManager.isBillingAddressFilled(loggedCustomer.RelatedContact.Id)
	            		|| !IECUserManager.isContactMandatoryFieldsFilled(loggedCustomer.RelatedContact);
		            
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
	            }
	            else {
	            	// customer does not have a billing address, so create a new one
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
			// if not logged in
			else {
				// store rate plan info id in cookie for after login
				IECCookieHelper.storeQuoteRatePlanInfo(oQuoteRatePlanInfo.Id);
			}
			
			// get the rate plan charges associated to the rate plan
			if (oQuoteRatePlanInfo != null)
				lstQuoteRatePlanCharges = IECProductManager.getZuoraRatePlanChargesByRatePlanID(oQuoteRatePlanInfo.Product_Rate_Plan__c);
		}
		catch (Exception ex) {
			if (Test.isRunningTest()) throw ex;
			else ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
  		}
	}
	
	/**
	 * Query zuora to determine the total for the current cart also to display the tax part
	 */
	public PageReference refreshShoppingCartTotal() {
		try {
			// if cart is no empty
			if (!cartIsEmpty && oQuoteRatePlanInfo != null && bShowPrice) {
				List<Zuora.zObject> listRatePlanDataObject = IECShoppingCartHelper.createRatePlanDataListObject(oQuoteRatePlanInfo.Product_Rate_Plan__r.zqu__ZuoraId__c, iQuantity);
				Zuora.zObject invoice = IECSubscriptionManager.previewInvoice(listRatePlanDataObject, ((isUserLoggedIn) ? loggedCustomer.RelatedContact : null));
				
				/**************************************************
	            *	2016-05-19: Samy: Add Tax calculation
	            **************************************************/
				// Retrieve the SoldTo Location for the current contact
				Location__c oLocSoldTo = new Location_Sel().getSoldToLocationByContactId(new Set<Id> {loggedCustomer.RelatedContact.Id}).get(loggedCustomer.RelatedContact.Id);
	  
	  			// Initialize a fake OrderItem DTO for tax and shipping calculation
				OrderItem_DTO dtoOrderItem = new OrderItem_DTO();
				
				//Get Product Info
				Map<String, Product2> mapProductRatePlanZId_Product = Product_Sel.getProductsByProductRatePlan(new Set<String> {oQuoteRatePlanInfo.Product_Rate_Plan__r.zqu__ZuoraId__c});
				
				if (mapProductRatePlanZId_Product == null || mapProductRatePlanZId_Product.isEmpty())
					throw new IECApplicationException('Unable to locate a Salesforce Product for the ProductRatePlan: ' + oQuoteRatePlanInfo.Product_Rate_Plan__r.zqu__ZuoraId__c);
				else
				{
					Product2 oProduct = mapProductRatePlanZId_Product.get(oQuoteRatePlanInfo.Product_Rate_Plan__r.zqu__ZuoraId__c);
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

	            /**************************************************
	            *	End Of: 2016-05-19: Samy: Add Tax calculation
	            **************************************************/
				
				shoppingCartTotalBeforeTax = (Decimal) invoice.getValue('AmountWithoutTax');
				shoppingCartTax = dtoOrderItem.taxAmount;
				shoppingCartShipping = (dtoOrderItem.shippingAmount == null && dtoOrderItem.handlingCharges == null) ? null
					: ((dtoOrderItem.shippingAmount == null ? 0 : dtoOrderItem.shippingAmount)
						+ (dtoOrderItem.handlingCharges == null ? 0 : dtoOrderItem.handlingCharges));
				shoppingCartTotal = shoppingCartTotalBeforeTax + (shoppingCartTax == null ? 0 : shoppingCartTax) + (shoppingCartShipping == null ? 0 : shoppingCartShipping);
			}

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
	public Pagereference modifyContactInfo() {
		try {		
			inEditContactInfo = true;
			return null;
		}
		catch (Exception ex) {
  			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
  			return null;
  		}
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
			if (String.isBlank(oContact.FirstName))			lstErrorMessages.add(Label.IEC_Error_Required_field + ' First Name');
			if (String.isBlank(oContact.LastName))			lstErrorMessages.add(Label.IEC_Error_Required_field + ' Last Name');
			if (String.isBlank(oContact.Title))				lstErrorMessages.add(Label.IEC_Error_Required_field + ' Job Title');
			if (String.isBlank(oContact.Email))				lstErrorMessages.add(Label.IEC_Error_Required_field + ' Email');
			if (String.isBlank(oContact.Phone))				lstErrorMessages.add(Label.IEC_Error_Required_field + ' Phone');

			if (String.isBlank(oBillingAddress.Street__c))	lstErrorMessages.add(Label.IEC_Error_Required_field + ' Address');
			if (String.isBlank(oBillingAddress.City__c))	lstErrorMessages.add(Label.IEC_Error_Required_field + ' City');

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
			}
			
			if (lstErrorMessages.isEmpty()) {
				oContact.VAT_Country_Code__c = (vatConfig.VATValidationRequired) ? vatConfig.CountryCode : null;
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
					|| !IECUserManager.isContactMandatoryFieldsFilled(loggedCustomer.RelatedContact);
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

	/**
	 * Generates the quote
	 */
    public void generateQuote() {
    	try {
    		oQuote = IECQuoteManager.submitQuote(loggedCustomer, oQuoteRatePlanInfo, (autoRenewFlag == 'true'), shoppingCartTotal, sComments, shoppingCartTax, shoppingCartShipping);
    		bQuoteSubmitSucessful = (oQuote != null);
    		
    		// reselect quote to have the generated number
    		oQuote = IECQuoteManager.getQuoteById(oQuote.Id);
    		
    		// if quote submit is successfull and the quote cookie existed, delete the cookie
    		if (bQuoteSubmitSucessful && String.isNotBlank(IECCookieHelper.getQuoteRatePlanInfo()))
    			IECCookieHelper.deleteQuoteCookie();
    	}
    	catch (Exception ex) {
    		bQuoteSubmitSucessful = false;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
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
    		bExpandedAutoRenewal = false;
    	}
    	return null;
    }

	 public PageReference toggleAutoRenew() {
    	bExpandedAutoRenewal = !bExpandedAutoRenewal;
    	if (bExpandedAutoRenewal) {
    		bExpandedBilling = false;
    	}
    	return null;
    }

	public PageReference cancelQuote() {
	            
	    PageReference newocp = Page.IECBrowseProducts;
        newocp.setRedirect(true);
        return newocp;
    }
}