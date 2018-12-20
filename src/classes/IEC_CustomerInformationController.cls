/******************************************************************************************************************
 *  IEC_CustomerInformationController: IEC_CustomerInformation page Controller                                    *
 *  Author: David Daboué - CGI                                                                                    *        
 ******************************************************************************************************************/
global without sharing class IEC_CustomerInformationController extends IEC_PageController
{
	public String quoteNumberToConvert{get;set;}
	
	//TC map to know which countries don't have zip code
	public Map<String, Boolean> zipCodeApplicableMap {
		get{
            if(zipCodeApplicableMap == null){
                Map<String, Object> countries = ISO_Country_State_Helper.getCountriesOptionsMap();
                zipCodeApplicableMap = (Map<String, Boolean>) countries.get('zipCodeApplicable');
            }

			return zipCodeApplicableMap;
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
			return vfOrder != null && vfOrder.billToAddress != null && !String.isBlank(vfOrder.billToAddress.countryCode) && 
				zipCodeApplicableMap.get(vfOrder.billToAddress.countryCode) != null && zipCodeApplicableMap.get(vfOrder.billToAddress.countryCode);
		}
		set;
	}

	public List<SelectOption> billToAvailableStates{get;set;}

	public List<SelectOption> availableSalutations{get{
		if(availableSalutations == null){
			availableSalutations = Utility.getPicklistSelectOptions('Contact', 'Salutation', true);
		}
		return availableSalutations;
	}set;}

	public Order_DTO vfOrder{get;set;} // Current Order
	public Order_DTO initialOrder; // Used has clone to compare Changes in the Customer Information Page
	public Order sfOrder{get;set;}
	private String orderId;

	private Contact initialContact;

	public Map<String, String> errors{get;set;} //FIELD => ERROR MESSAGE

	public Boolean stopProcess { get; set; }

	//Used for google analytics
	public String productWrapper {
		get {
			Map<String,Object> ecommObj = new Map<String,Object>();
			Map<String,Object> checkoutObj = new Map<String,Object>();
			Map<String,Object> actionObj = new Map<String,Object>();
			Map<String,Object> prodObj = new Map<String,Object>();

			ecommObj.put('checkout', checkoutObj);
			actionObj.put('step',1);
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

	
	/**************************************************************************************************************
     *  IEC_CustomerInformationController: Class Constructor                                                      *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
	public IEC_CustomerInformationController()
	{
		
	}

	/**************************************************************************************************************
     *  onLoadAction: method calls when page loaded                                                               *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
	public PageReference onLoadAction()
	{
		//-- Ensure that customer is logged-in
		if(loggedCustomer == null)
		{
			PageReference ret = new PageReference('/IEC_Login?returl=/IEC_CustomerInformation');
			ret.setRedirect(true);
	        return ret;
		}

		//--Make sure Contact has BillTo Ship & SoldTo
		//*** check/initialize default locations -> stop if error on sold to partner
		stopProcess = false;
		List<String> lstError = Location_Svc.initializeDefaultLocations(new List<Id>{loggedCustomer.sfContact.Id});
		if (lstError[0] != null && lstError[0].startsWith('\nST'))
		{
			stopProcess = true;
			addErrorMessage(Label.IEC_SAP_Customer_Issue);
			return null;
		}
		Customer_DTO.setCustomerAddresses(loggedCustomer);
		initialContact = loggedCustomer.sfContact.clone(true,true,true,true);

		//If Quote Link 
		if(System.currentPageReference().getParameters().containsKey('id'))
		{
			quoteNumberToConvert = System.currentPageReference().getParameters().get('id');

            //-- Validate quoteNumberToConvert is a valid belongs to the current User 
            if(IECOrder_Svc.validateQuoteNumberToConvert(quoteNumberToConvert, loggedCustomer.sfUser.Id, loggedCustomer.sfContact.Id))
            {
            	List<Order> lstOrders = (List<Order>) new Order_Sel().selectSObjectByField('OrderNumber',new Set<String>{quoteNumberToConvert});
            	if(lstOrders.size() > 0)
           			IECOrder_Svc.changePenddingOrder(lstOrders[0]);
            }		
		}

		sfOrder = IECOrder_Svc.getPenddingOrder(true);

		vfOrder = new Order_DTO(sfOrder);
		initialOrder = new Order_DTO(sfOrder);

		//-- Validate cart is not empty 
		if(vfOrder.orderItems==null || vfOrder.orderItems.size() == 0)
		{
			addErrorMessage(Label.Warning_Empty_Cart);
		}

		//-- Validate compliance 
		validateCountryCompliance();

		//-- Default states list
		billToAvailableStates = ISO_Country_State_Helper.getStatesSelectOption(vfOrder.billToAddress.countryCode);
		
		//Page Validation errors 
		initPageErrors();

		return null;
	}

	public void initPageErrors()
	{
		errors = new Map<String, String>{
			'salutation' => 'false',
			'FirstName' => 'false',
			'LastName' => 'false',
			'phone' => 'false',
			'email' => 'false',
			'street1' => 'false',
			'postalCode' => 'false',
			'city' => 'false',
			'countryCode' => 'false',
			'stateCode' => 'false'
		};
	}

	/**************************************************************************************************************
     *  validateCountryCompliance: method to validate that all the products in customer's cart  				  *	
     *		are country compliant 																				  *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
	public void validateCountryCompliance()
	{
		List<Id> productIds = new List<Id>();
    	for (OrderItem_DTO oi : vfOrder.orderItems) productIds.add(oi.productId);

		Map<Id, Boolean> mapProduct2Id_Compliance = Product_Svc.IsProductAndCountryCompliant(productIds, new Set<String>{vfOrder.billToAddress.countryCode});
		
		Map<String, String> labels = Utility.buildMapFromString(Label.LabelsVF_Order + '\n' + Label.LabelsVF_Order2, '\n', ':');
		Boolean bAreProductsCompliant = true;
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
     *  refreshBillToProvinces: method calls when customer change his countryto retrieve available states 		  *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
     public String selectedStateCode{get;set;}
	public void refreshBillToProvinces()
	{
		//-- Update isRequiredField 
		List<IATA_ISO_Country__c> countries = ISO_Country_State_Helper.getIsoCountryByIsoCode(vfOrder.billToAddress.countryCode);
		

		vfOrder.billToAddress.stateCode = selectedStateCode;

		if(countries.size() > 0)
		{
			vfOrder.billToAddress.isPostalCodeRequired = countries[0].IEC_Zip_Postal_Code_required__c;
			vfOrder.billToAddress.countryLabel = countries[0].Name; 
		}

		billToAvailableStates = ISO_Country_State_Helper.getStatesSelectOption(vfOrder.billToAddress.countryCode);
		vfOrder.billToAddress.postalCode = '';
	}

	public void regionChanged()
	{
		
	}

	public Boolean validateCustomerInformation()
	{
		Boolean isValid = true; 
		initPageErrors();

		if(String.isBlank(loggedCustomer.sfContact.Salutation)) 
		{
			errors.put('salutation',Label.SelectRequiredMessage + ' ' + Label.Salutation);
			isValid = false;
		}

		if(String.isBlank(loggedCustomer.sfContact.FirstName))
		{
			errors.put('FirstName',Label.InputRequiredMessage + ' ' + Label.First_name);
			isValid = false; 
		}   
		
		if(String.isBlank(loggedCustomer.sfContact.LastName))
		{
			errors.put('LastName',Label.InputRequiredMessage + ' ' + Label.Last_name);
			isValid = false; 
		}    


		return isValid;
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
		initPageErrors();
		
		if(String.isBlank(vfOrder.billToAddress.phone)) 
		{
			errors.put('phone',Label.InputRequiredMessage + ' ' + Label.Phone);
			isValid = false;
		}

		if(String.isBlank(vfOrder.billToAddress.email)) 
		{
			errors.put('email',Label.InputRequiredMessage + ' ' + Label.Email_address);
			isValid = false;
		}
		else if(!isEmailValid(vfOrder.billToAddress.email))
		{
			errors.put('email',Label.IEC_Error_InvalidEmail);
			isValid = false;
		}


		if(String.isBlank(vfOrder.billToAddress.street1)) 
		{
			errors.put('street1',Label.InputRequiredMessage + ' ' + Label.Address_Line_1);
			isValid = false;
		} else if(isStreetAddressToLong(vfOrder.billToAddress.street1, 70)) {
			errors.put('street1',Label.IEC_BillingAddressLimit);
			isValid = false;
		}
	
		if(vfOrder.billToAddress.isPostalCodeRequired != null && vfOrder.billToAddress.isPostalCodeRequired && (vfOrder.billToAddress.postalCode == null || vfOrder.billToAddress.postalCode == '')) //String.isBlank(vfOrder.billToAddress.postalCode)
		{
			errors.put('postalCode',Label.InputRequiredMessage + ' ' + Label.Postal_code);
			isValid = false;
		}

		if(String.isBlank(vfOrder.billToAddress.city)) 
		{
			errors.put('city',Label.InputRequiredMessage + ' ' + Label.City);
			isValid = false;
		}

		if(String.isBlank(vfOrder.billToAddress.countryCode)) 
		{
			errors.put('countryCode',Label.InputRequiredMessage + ' ' + Label.Country);
			isValid = false;
		}

		if(billToAvailableStates.size() > 0 && String.isBlank(vfOrder.billToAddress.stateCode)) 
		{
			errors.put('stateCode',Label.SelectRequiredMessage + ' ' + Label.Region);
			isValid = false;
		}

		return isValid;
	}	
	
	/* TC 2017-05-17 */
	public Boolean isStreetAddressToLong(String street, Integer maxSize) {
		return !String.isBlank(street) && street.length() > maxSize;
	}
	/* end TC */

	/**************************************************************************************************************
     *  saveCustomerInformation: method calls when customer clicks on "Continue" button to save customer Info     * 
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
	public PageReference saveCustomerInformation()
	{
		//-- Validate Personal information
		if(!validateCustomerInformation() || !validateBillingInformation())
		{
			for(String field:errors.keySet())
				if(errors.get(field) != 'false')
					addErrorMessage(errors.get(field));

			return null;
		}
		
		//-- Validate compliance 
		validateCountryCompliance();

		//-- Validate VAT Number if provided 
		if(String.isNotBlank(vfOrder.billToAddress.vatNumber))
		{
			String validation = IECVATUtil.Validate_VAT(vfOrder.billToAddress.countryCode, vfOrder.billToAddress.vatNumber);

			if(String.isNotBlank(validation))
			{
				addErrorMessage(validation); return null;
			}			
		}

		//*** get all active bill/ship to locations attached to contact
		Map<Id, Location__c> mapLocationId_Location = Location_Sel.getLocationToSyncSAP(null, null, new List<Id>{loggedCustomer.sfContact.Id}, null, true);

		//*** get bill to location and address
		Location__c billingLocation, billingLocationOld = null;
		IECAddress__c billingAddress;
		if (mapLocationId_Location.containsKey(sfOrder.BillTo_Location__c))
		{
			billingLocation = mapLocationId_Location.get(sfOrder.BillTo_Location__c);
			billingAddress = billingLocation.Address__r;
		}
		else
			for (Location__c loc : mapLocationId_Location.values())
				if (loc.Type__c == IECConstants.BILLTO)
				{
					billingLocation = loc;
					billingAddress = billingLocation.Address__r;
					break;
				}

		//*** treatment for bill to
		if (IECAddress_Svc.isAddressChanged(vfOrder.billToAddress, initialOrder.billToAddress))
		{
			//*** find new address -> if found then take the first one otherwise create new
			List<IECAddress__c> addresses = new IECAddress_Sel().getAddress(vfOrder.billToAddress.street1,vfOrder.billToAddress.city,vfOrder.billToAddress.countryCode,vfOrder.billToAddress.stateCode,vfOrder.billToAddress.postalCode);
			if (addresses != null & addresses.size() > 0)
				billingAddress = addresses[0];
			else
				billingAddress = IECAddress_Svc.newAddressForSAPSync(vfOrder.billToAddress.street1, vfOrder.billToAddress.city, vfOrder.billToAddress.countryCode, vfOrder.billToAddress.stateCode, vfOrder.billToAddress.postalCode);
			
			//*** action to do on location
			if (vfOrder.billToAddress.countryCode != initialOrder.billToAddress.countryCode || vfOrder.billToAddress.stateCode != initialOrder.billToAddress.stateCode || String.isBlank(billingLocation.SAP_Id__c))
			{
				//*** country/state change -> deactivate old location and create a new one
					billingLocationOld = billingLocation; 
					billingLocationOld.Active__c = false; 

					//*** create new location -> cancel action on error
					billingLocation = getNewLocation(billingLocation, billingAddress, vfOrder.billToAddress.email, vfOrder.billToAddress.phone, vfOrder.billToAddress.vatNumber);
/*
					billingLocation = new Location__c(Active__c = true, Type__c = IECConstants.BILLTO, Address__c = billingAddress.Id, Address__r = billingAddress
					                                , Account__c = billingLocation.Account__c, Account__r = billingLocation.Account__r
					                                , Contact__c = billingLocation.Contact__c, Contact__r = billingLocation.Contact__r
					                                , Email__c = vfOrder.billToAddress.email, Phone__c = vfOrder.billToAddress.phone , VAT_Number__c = vfOrder.billToAddress.vatNumber);
*/
				List<IEC_Error_Log__c> lstSyncResult = IECAddress_Svc.syncCustomerWithSAP(new List<Location__c>{billingLocation}, null, false);
				if (lstSyncResult[0] != null)
				{
					addErrorMessage(Label.IEC_SAP_Customer_Address_Issue);
					return null;
				}
			}
			else
			{
				//*** update existing location since no change on country/state
				billingLocationOld = billingLocation; 
				billingLocation.Address__c = billingAddress.Id;
				billingLocation.Address__r = billingAddress;
				billingLocation.Email__c = vfOrder.billToAddress.email;
				billingLocation.Phone__c = vfOrder.billToAddress.phone;
				billingLocation.VAT_Number__c = vfOrder.billToAddress.vatNumber;
			}
		}
		else if (billingLocation.Email__c != vfOrder.billToAddress.email || billingLocation.Phone__c != vfOrder.billToAddress.phone || billingLocation.VAT_Number__c != vfOrder.billToAddress.vatNumber)
		{
			//*** update change on non-key field
			billingLocationOld = billingLocation; 
			billingLocation.Email__c = vfOrder.billToAddress.email;
			billingLocation.Phone__c = vfOrder.billToAddress.phone;
			billingLocation.VAT_Number__c = vfOrder.billToAddress.vatNumber;
		}
		//*** last check on SAP Id
		if (String.isBlank(billingLocation.SAP_Id__c))
		{
			addErrorMessage(Label.IEC_SAP_Customer_Issue);
			return null;
		}

		//*** treatment for ship to
		Location__c shippingLocation = null;
		if (vfOrder.shipToSameAsBilTo)
		{
			//*** get ship to location corresponding to billing address
			for (Location__c loc : mapLocationId_Location.values())
				if (loc.Type__c == IECConstants.SHIPTO && loc.Address__c == billingAddress.Id)
				{
					shippingLocation = loc;
					break;
				}
			
			//*** not found -> create new location
			if (shippingLocation == null)
			{
				shippingLocation = new Location__c(Active__c = true, Type__c = IECConstants.SHIPTO, Address__c = billingAddress.Id, Address__r = billingAddress, Address_Name__c = 'New'
				                                 , Account__c = billingLocation.Account__c, Account__r = billingLocation.Account__r
				                                 , Contact__c = billingLocation.Contact__c, Contact__r = billingLocation.Contact__r, Attention__c = billingLocation.Contact__r.Name
				                                 , Email__c = vfOrder.billToAddress.email, Phone__c = vfOrder.billToAddress.phone , VAT_Number__c = vfOrder.billToAddress.vatNumber);
				IECAddress_Svc.syncCustomerWithSAP(new List<Location__c>{shippingLocation}, null, false);   //*** ignore error
			}
		}

		//*** commit change
		Savepoint sp = Database.setSavepoint();
		try
		{
			if (billingAddress.Id == null)
				insert billingAddress;
			
			if (billingLocationOld != null)
			{
				if (billingLocationOld.Address__c == null)
					billingLocationOld.Address__c = billingLocationOld.Address__r.Id;
				update billingLocationOld;
			}
			if (billingLocation.Id == null)
			{
				billingLocation.Address__c = billingLocation.Address__r.Id;
				insert billingLocation;
			}
			
			if (shippingLocation != null && shippingLocation.Id == null)
			{
				shippingLocation.Address__c = shippingLocation.Address__r.Id;
				insert shippingLocation;
			}
			
			if (loggedCustomer.sfContact.BillTo_Location__c != billingLocation.Id)
				loggedCustomer.sfContact.BillTo_Location__c = billingLocation.Id;
			if (initialContact != loggedCustomer.sfContact)
				update loggedCustomer.sfContact;
			
			sfOrder.BillToContact_Salutation__c = loggedCustomer.sfContact.Salutation;
			sfOrder.BillToContact_First_Name__c = loggedCustomer.sfContact.FirstName;
			sfOrder.BillToContact_Last_Name__c  = loggedCustomer.sfContact.LastName;
			sfOrder.PoNumber                    = vfOrder.orderPONumber;
			sfOrder.Invoice_Text__c             = vfOrder.billToInvoiceText;
			sfOrder.BillingStreet               = vfOrder.billToAddress.street1;
			sfOrder.BillingCity                 = vfOrder.billToAddress.city;
			sfOrder.BillingPostalCode           = vfOrder.billToAddress.postalCode;
			sfOrder.BillingCountry              = billingLocation.Address__r.ISO_Country__r.Name;
			sfOrder.BillingCountryCode__c       = vfOrder.billToAddress.countryCode;
			sfOrder.BillingState                = billingLocation.Address__r.ISO_State__r.Name;
			sfOrder.BillingStateCode__c         = vfOrder.billToAddress.stateCode;
			sfOrder.BillToContact_Email__c      = vfOrder.billToAddress.email;
			sfOrder.BillToContact_Phone__c      = vfOrder.billToAddress.phone;
			sfOrder.BillToContact_VAT_Number__c = vfOrder.billToAddress.vatNumber;
			sfOrder.BillTo_Address__c           = billingLocation.Address__c;
			sfOrder.BillTo_Location__c          = billingLocation.Id;
			if (vfOrder.shipToSameAsBilTo)
			{
				sfOrder.ShippingStreet          = sfOrder.BillingStreet;
				sfOrder.ShippingCity            = sfOrder.BillingCity;
				sfOrder.ShippingPostalCode      = sfOrder.BillingPostalCode;
				sfOrder.ShippingCountry         = sfOrder.BillingCountry;
				sfOrder.ShippingCountryCode__c  = sfOrder.BillingCountryCode__c;
				sfOrder.ShippingState           = sfOrder.BillingState;
				sfOrder.ShippingStateCode__c    = sfOrder.BillingStateCode__c;
				sfOrder.ShipTo_Address__c       = sfOrder.BillTo_Address__c;
				sfOrder.ShipTo_Location__c      = shippingLocation.Id;
			}
			update sfOrder;
		}
		catch(Exception ex)
		{
			addErrorMessage(ex.getMessage());
			Database.rollback(sp);
			return null;
		}

		//-- Goto Payment & Shipping 
		PageReference ret = new PageReference('/IEC_Shipping');
		ret.setRedirect(true);
        return ret;
	}

	/**************************************************************************************************************
     *  findIECAddresses: RemoteAction method used for address Auto-Complete feature 							  *
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
			LIMIT 10
		];
	}

	@testVisible					
	private static Location__c getNewLocation(Location__c billingLocation, IECAddress__c billingAddress, String email, String phone, String vatNumber) {
		return new Location__c (
			Active__c = true,
			Type__c = IECConstants.BILLTO,
			Address__c = billingAddress.Id,
			Address__r = billingAddress,
			Account__c = billingLocation.Account__c,
			Account__r = billingLocation.Account__r,
			Contact__c = billingLocation.Contact__c,
			Contact__r = billingLocation.Contact__r,
			Email__c = email,
			Phone__c = phone,
			VAT_Number__c = vatNumber
		);
	}
}