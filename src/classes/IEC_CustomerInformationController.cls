/******************************************************************************************************************
 *  IEC_CustomerInformationController: IEC_CustomerInformation page Controller                                    *
 *  Author: David Daboué - CGI                                                                                    *        
 ******************************************************************************************************************/
global class IEC_CustomerInformationController extends IEC_PageController
{
	public String quoteNumberToConvert{get;set;}

	public List<SelectOption> availableCountries{get{
		if(availableCountries == null){
			availableCountries = ISO_Country_State_Helper.getCountriesSelectOption();
		}
		return availableCountries;
	}set;}

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
		Boolean init = Location_Svc.InitializeContactLocations(loggedCustomer.sfContact.Id);
		Customer_DTO.setCustomerAddresses(loggedCustomer);
		initialContact = loggedCustomer.sfContact.clone(true,true,true,true);

		//If Quote Link 
		if(System.currentPageReference().getParameters().containsKey('id'))
		{
			quoteNumberToConvert = System.currentPageReference().getParameters().get('id');

            //-- Validate quoteNumberToConvert is a valid belongs to the current User 
            if(IECOrder_Svc.validateQuoteNumberToConvert(quoteNumberToConvert, loggedCustomer.sfUser.Id))
            {
            	List<Order> lstOrders = (List<Order>) new Order_Sel().selectSObjectByField('OrderNumber',new Set<String>{quoteNumberToConvert});
            	if(lstOrders.size() > 0)
           			IECOrder_Svc.changePenddingOrder(lstOrders[0]);
            }		
		}

		sfOrder = IECOrder_Svc.getPenddingOrder();
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



		//-- Save Contact Information if changed
		if(initialContact != loggedCustomer.sfContact)
		{
			try{update loggedCustomer.sfContact; }
			catch(Exception ex){addErrorMessage(ex.getMessage());return null;}
		}
			
		Location__c billingLocation;
		Boolean countryOrRegionChanged = false;
		
		//-- If Billing Address changed ... Link BillToLocation to the new IECAddress (created or existing)
		if(IECAddress_Svc.isAddressChanged(vfOrder.billToAddress, initialOrder.billToAddress) || initialContact.Phone != vfOrder.billToAddress.phone || initialContact.Email != vfOrder.billToAddress.email)
		{
			IECAddress_Sel adrSelector = new IECAddress_Sel();
			List<IECAddress__c> addresses = adrSelector.getAddress(vfOrder.billToAddress.street1,vfOrder.billToAddress.city,vfOrder.billToAddress.countryCode,vfOrder.billToAddress.stateCode,vfOrder.billToAddress.postalCode);

			//-- If address found 
			IECAddress__c billingAddress;
			if(addresses != null & addresses.size() > 0) billingAddress = addresses[0];
			else
			{
				//-- Create new IECAddress
				billingAddress = IECAddress_Svc.newAddress(vfOrder.billToAddress.street1,vfOrder.billToAddress.city,vfOrder.billToAddress.countryCode,vfOrder.billToAddress.stateCode,vfOrder.billToAddress.postalCode);				
			}
			countryOrRegionChanged=((vfOrder.billToAddress.countryCode!=initialOrder.billToAddress.countryCode)||(vfOrder.billToAddress.stateCode!=initialOrder.billToAddress.stateCode));
			
			//-- Check if Customer has BillToLocation 
			
			List<Location__c> billingLocations = Location_Sel.getLocationByContact(loggedCustomer.sfContact.Id, IECConstants.BILLTO);
			
			if(billingLocations != null && billingLocations.size() > 0)
			{
				if(countryOrRegionChanged)
				{
					//Deactivate older location and create a new one
					billingLocations[0].Active__c = false; 
					update billingLocations[0];

					//Create Bill To Location 
					billingLocation = Location_Svc.createLocation(billingAddress.Id, loggedCustomer.sfContact, vfOrder.billToAddress.vatNumber, IECConstants.BILLTO);

					//update Contact Default BillTo & Order BillTo
					if(billingLocation != null){
            			loggedCustomer.sfContact.BillTo_Location__c = billingLocation.Id;
            			update loggedCustomer.sfContact;

            			sfOrder.BillTo_Location__c = billingLocation.Id;
            			update sfOrder;            			
					}
				}
				else
				{
					//Update location 
					billingLocation = billingLocations[0];
					billingLocation.Address__c = billingAddress.Id;
					billingLocation.Email__c = vfOrder.billToAddress.email;
					billingLocation.Phone__c = vfOrder.billToAddress.phone;
					billingLocation.VAT_Number__c = vfOrder.billToAddress.vatNumber;
					
					update billingLocation;
				}				
			}
			else
			{
				//Create Bill To Location 
				billingLocation = Location_Svc.createLocation(billingAddress.Id,loggedCustomer.sfContact,vfOrder.billToAddress.vatNumber,IECConstants.BILLTO);
			}			
		}

		//-- Update Order Billing Address + PO NUmber + Invoice text +   VAT Number
		//get country & state names from code 
		String billingCountry; 
		String billingState; 

		List<IATA_ISO_Country__c> countries = ISO_Country_State_Helper.getIsoCountryByIsoCode(vfOrder.billToAddress.countryCode);
		if(countries != null && countries.size() > 0)
		{
			billingCountry = countries[0].Name;
			if(String.isNotBlank(vfOrder.billToAddress.stateCode))
			{
				List<IATA_ISO_State__c> states = ISO_Country_State_Helper.getIsoStateByIsoCode(vfOrder.billToAddress.countryCode,vfOrder.billToAddress.stateCode);
				
				if(states != null && states.size() > 0) billingState = states[0].Name;
			}
			
			//List<IATA_ISO_State__c> getIsoStateByIsoCode(String countryCode, String isoCode)
		}

		sfOrder.PoNumber				= 	vfOrder.orderPONumber;
		sfOrder.BillingStreet 			=	vfOrder.billToAddress.street1;
        sfOrder.BillingCity 			=	vfOrder.billToAddress.city;
        sfOrder.BillingPostalCode 		=	vfOrder.billToAddress.postalCode;
        sfOrder.BillingCountryCode__c 	=	vfOrder.billToAddress.countryCode;
        sfOrder.BillingState 			=	billingState;
        sfOrder.BillingStateCode__c 	=	vfOrder.billToAddress.stateCode;
        sfOrder.BillingCountry 			=	billingCountry;
        sfOrder.BillToContact_VAT_Number__c	= 	vfOrder.billToAddress.vatNumber;
        sfOrder.Invoice_Text__c 	 		= 	vfOrder.billToInvoiceText;
		
		sfOrder.BillToContact_Email__c 		= 	vfOrder.billToAddress.email;
		sfOrder.BillToContact_Phone__c 		=	vfOrder.billToAddress.phone;
		sfOrder.BillToContact_Salutation__c =	loggedCustomer.sfContact.Salutation;
		sfOrder.BillToContact_First_Name__c =	loggedCustomer.sfContact.FirstName;
		sfOrder.BillToContact_Last_Name__c 	=	loggedCustomer.sfContact.LastName;
		
        //-- Update Shipto Address  if shipToSameAsBilTo
        if(vfOrder.shipToSameAsBilTo)
        {
        	
        	//billingLocation
        	Location__c shipToLocation = new Location__c();
        	
        	if(billingLocation == null){
        		//sfOrder.ShipTo_Location__c,
	            Map<Id,Location__c> mapLocations = new Location_Sel().getLocationById(new Set<Id>{
	                sfOrder.BillTo_Location__c
	            });
	            
	            //billToLocation
	            billingLocation 	= 	mapLocations.get(sfOrder.BillTo_Location__c);
        	}
        	
        	//Verified if the shippTo location exist
        	List<Location__c> LstExistingHipToLocation = [SELECT id, Address__c 
        											from Location__c 
        										where Address__c = :billingLocation.Address__c and Type__c = :IECConstants.SHIPTO and Active__c = true 
        										and Contact__c = :loggedCustomer.sfContact.Id ];
        										
        	
        	//If the Address don't exist create a new ShipTo location
        	if(LstExistingHipToLocation == null || LstExistingHipToLocation.size() == 0){
        		
        		if(countryOrRegionChanged){
        			shipToLocation = Location_Svc.createLocation(billingLocation.Address__c, loggedCustomer.sfContact.Id, billingLocation.Email__c, billingLocation.Phone__c, vfOrder.billToAddress.vatNumber, IECConstants.SHIPTO);
	            }
	           
        	}else{
        		//Update the existing location
        		shipToLocation = LstExistingHipToLocation.get(0);
        	}
        	
            //if(sfOrder.ShipTo_Location__c == null) sfOrder.ShipTo_Location__c = vfOrder.shipToAddress.locationId;
            sfOrder.ShipTo_Location__c = shipToLocation.Id;
            
            
            //Create a new ShipTo if Country or Region changed
           
            
             
            
            
            //Location__c shipToLocation 	= 	mapLocations.get(sfOrder.ShipTo_Location__c);
            
            /*if(billToLocation != null && billToLocation.Address__c != null){
            	if(shipToLocation != null){
	            	shipToLocation.Address__c 	= 	billToLocation.Address__c; 
	            	update shipToLocation;
	            }
	            sfOrder.BillTo_Address__c = billToLocation.Address__c;
            }*/
            
            //Map the shipping fields
            sfOrder.ShippingCity 			= 	sfOrder.BillingCity;
            sfOrder.ShippingPostalCode 		= 	sfOrder.BillingPostalCode;
            sfOrder.ShippingState 			= 	sfOrder.BillingState;
            sfOrder.ShippingStateCode__c 	= 	sfOrder.BillingStateCode__c;
            sfOrder.ShippingStreet 			= 	sfOrder.BillingStreet;
            //if(shipToLocation != null && shipToLocation.Address__c != null)
           	sfOrder.ShipTo_Address__c 		= 	shipToLocation.Address__c;

            	
           
           
        }
        
		try{update sfOrder;}
		catch(Exception ex){addErrorMessage(ex.getMessage());return null;}

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
}