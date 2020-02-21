/**
  * Description: This class contains the controller for the Visualforce page (Trial Request)
  * Author: Samy Saied
  * Version: 1.0
  * History:
  */
public without sharing  class vfIECTrialRequest extends IECPageController {
	public Boolean needToFillContactInfo { get; set; }
	public Boolean inEditContactInfo { get; set; }
	public Boolean isCountryFilled { get; private set; }
	public IECAddress__c oBillingAddress { get; set; }
	public Location__c oBillingLocation { get; set; }
	public IECAddress__c oOriginalBillingAddress { get; set; }
	public IECVATUtil.VATConfiguration vatConfig { get; set; }
	public static  boolean ISSP_ContactAfterInsertIECBLOCK = false;

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

	public Boolean hasAcceptedAllTnCs {
		get {
			return oTnCComponentController.hasAcceptedAllTCs;
		}
	}

	public boolean isCriticalError {get; set;}
	public boolean isUserLoggedIn {get; set;}

	// Parameters passed to the page
	public string sEncryptedParamRatePlanId {get; private set;}
	public string sParamRatePlanId {get; private set;}
	public string PARAM_RATEPLAN_ID {get {return IECConstants.PARAM_RATEPLAN_ID;}}

	// properties for the rate plan information to be displayed to the customer for confirmation
	public String sProductName { get; private set; }
	public String sShortDesc { get; private set; }
	public String sLongDesc { get; private set; }

	// Properties for communication with Zuora APIs
	public Boolean requestSucessful { get; private set; }
	public String zidProductRatePlan { get; private set; }

	// properties for the integration of the T&C component
	public String[] listProductInformationIDs { get; private set; }
	public String TC_COMPONENT_KEY {
		get {
			return 'componentTnC';
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

	public VfIECTermsAndConditionsComponent oTnCComponentController {
		set;
		get {
			try {
				//get the map, then the component controller using the appropriate key
				if (getComponentControllerMap() != null) {
					VfIECTermsAndConditionsComponent mcc;
					mcc = (VfIECTermsAndConditionsComponent)getComponentControllerMap().get(TC_COMPONENT_KEY);
					if (mcc != null) {
						return mcc;
					}
				}

				VfIECTermsAndConditionsComponent component = new VfIECTermsAndConditionsComponent();
				setComponentControllerMap(TC_COMPONENT_KEY, component);
				return component;
			}
			catch (Exception ex) {
				addErrorMessage(ex.getMessage());
				return null;
			}
		}
	}

	/**
	 * Constructor
	 */
	public vfIECTrialRequest() {
		try {
			listProductInformationIDs = new String[]{};

			// Preload list of Countries/States
			lstCountryState = ISO_Country_State_Helper.getCountry_State();
		}
		catch (Exception ex) {
			addErrorMessage(ex.getMessage());
  		}
	}

	/**
	 * Action called after the page has loaded
	 */
	public void pageLoad() {
		try {
			// Validate Logged in user profile and ensure profile is complete
			validUserProfile();

			isCriticalError = false;
			isUserLoggedIn = IECUserManager.isUserLoggedIn();
			sEncryptedParamRatePlanId = ApexPages.currentPage().getParameters().get(PARAM_RATEPLAN_ID);

			if (!isUserLoggedIn)
				addErrorMessage(IECConstants.Error_MustLogin);

			// Validate that there is parameter passed to the page
			if (String.isEmpty(sEncryptedParamRatePlanId)) {
				addErrorMessage(IECConstants.Error_InvalidPageParameter);
				isCriticalError = true;
			}
			else {
				// Decrypt parameter before using it
				sParamRatePlanId = IECUtil.DecodeDecryptParameter(sEncryptedParamRatePlanId);

				// Encode it once more to overcome the bug when not logged in, and redirect to the Site.login() function which decode before it returns the URL
				sEncryptedParamRatePlanId = EncodingUtil.urlEncode(sEncryptedParamRatePlanId, 'UTF-8');

				// Swap the rate plan if necessary
				Map<ID, Product_Rate_Plan_Information__c> targetRatePlans = IECSubscriptionManager.getTargetSwappedRatePlans(new Set<Id> {sParamRatePlanId}, IECUserManager.getClientType());

				if (targetRatePlans != null && !targetRatePlans.isEmpty()) {
					sParamRatePlanId = targetRatePlans.values().get(0).Id;
				}

				List<Product_Rate_Plan_Information__c> lstPRP = IECProductManager.getProductRatePlansInformationById(sParamRatePlanId);

				// Make sure Rate Plan is found
				if (lstPRP.isEmpty()) {
					addErrorMessage(IECConstants.Error_InvalidRatePlanId);
					isCriticalError = true;
				}
				else {
					// Populate trial plan properties to the UI
					sProductName = lstPRP[0].Product_Rate_Plan__r.Name;
					sShortDesc = lstPRP[0].Short_Description__c;
					sLongDesc = lstPRP[0].Long_Description__c;
					zidProductRatePlan = lstPRP[0].Product_Rate_Plan__r.zqu__ZuoraId__c;
					listProductInformationIDs.clear();
					listProductInformationIDs.add(lstPRP[0].Related_Product_Information__c);
				}



				// check if the customer needs to fill his contact information
				if (isUserLoggedIn) {
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
		}
		catch (Exception ex) {
			addErrorMessage(ex.getMessage());
			isCriticalError = true;
  		}
	}

	/**
	 * Action function to validate client for the requested trial
	 */
	public void activateTrial() {
		try {
			isCriticalError = false;

			// check if the Contact Info has not been filled
			if (needToFillContactInfo)
				throw new IECApplicationException(Label.IEC_Error_Fill_Contact_Info);

			// check if Contact Info is still in edit mode
			if (inEditContactInfo)
				throw new IECApplicationException(Label.IEC_Error_Confirm_Contact_Info);

			// Make sure all T&Cs have been accepted
			if (hasAcceptedAllTnCs == false)
				addErrorMessage(IECConstants.Error_AcceptTermAndCondition);

			// Make sure trial is applicable for this client
			else if (!canContactPurchaseTrialPlan(loggedCustomer.RelatedContact.Id, sParamRatePlanId))
				addErrorMessage(IECConstants.Error_TrialConsumed);

			else {
				// Submit Trial subscription to Zuora
				List<Zuora.zApi.SubscribeResult> lstSubscribeResult = IECSubscriptionManager.subscribeTrial(loggedCustomer, zidProductRatePlan, oTnCComponentController.listTermsAndConditions);

				// If call is successful
				if (lstSubscribeResult[0].Success) {
					requestSucessful = true;

					// Record the trial to prevent future request for the same trial plan
					addTrialSubscription(loggedCustomer.RelatedContact.Id, sParamRatePlanId);
					addConfirmMessage(IECConstants.Trial_RequestSucceed);
				}
				else {
					requestSucessful = false;
					addErrorMessage(IECConstants.Trial_RequestFail);
					System.Debug('Trial Request failed for the following reasons: ' + lstSubscribeResult[0].Errors);
				}
			}


		/*	throw new transformationException(' hasAcceptedAllTnCs ' + hasAcceptedAllTnCs
			 + '    IECSubscriptionManager.canContactPurchaseTrialPlan(loggedCustomer.RelatedContact.Id, sParamRatePlanId)   ' +
			 IECSubscriptionManager.canContactPurchaseTrialPlan(loggedCustomer.RelatedContact.Id, sParamRatePlanId));
			// If all is good then submit request and record the result if successful*/
		}
		catch (Exception ex) {
			//throw new transformationException('  ' + ex.getMessage() + '\r\n' + ex.getStackTraceString());
  			addErrorMessage(ex.getMessage() + '\r\n' + ex.getStackTraceString());
  			isCriticalError = true;
  		}
	}

   private static boolean canContactPurchaseTrialPlan(Id idContact, Id idRatePlanInformation) {
		List<Trial__c> lstTrials =
			[SELECT Product_Rate_Plan_Information__c
			FROM Trial__c
		   WHERE
		   Contact__c = :idContact
				AND
				 Product_Rate_Plan_Information__c = :idRatePlanInformation
		   //  //   //AND Trial_Date__c = LAST_N_DAYS:180
				AND Ignore__c = false
			   ];
//throw new transformationException('' + lstTrials + '	Id idContact    ' +  idContact +'		Id idRatePlanInformation' + idRatePlanInformation);
		return lstTrials.isEmpty();
	}



   private static void addTrialSubscription(Id idContact, Id idRatePlanInformation) {

		Trial__c trl = new Trial__c(
			Product_Rate_Plan_Information__c = idRatePlanInformation
			, Contact__c = idContact
			, Trial_Date__c = Date.today()
			, Ignore__c = false
		);
		insert trl;
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
			ISSP_ContactAfterInsertIECBLOCK = true;
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


		ISSP_ContactAfterInsertIECBLOCK = false;

		}
		catch (Exception ex) {
			Database.rollback(sp);
  			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
  					ISSP_ContactAfterInsertIECBLOCK = false;

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


}
