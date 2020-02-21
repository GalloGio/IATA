public with sharing class vfIECUpdateContact  extends IECPageController {
	public Contact oContact { get; private set; }
	/* Commented by Samy (2016-03-02): Billing Address updates is not required as per scope of this page
	public IECAddress__c oBilling               {get; set;}*/

	public String sOldEmail                     {get; set;}
	public String sConfirmEmail                 {get; set;}
	public String sAccountName                  {get; set;}

	public boolean bEmailChanged                {get; set;}
	public boolean bShowEmailDomainMessage      {get; set;}
	public boolean bPasswordReset               {get; set;}

	public Integer iRegistrationStep            {get; set;}

	public Integer constCONTACTINFO             {get {return 1;}}
	public Integer constCHANGEEMAIL             {get {return 2;}}
	public Integer constUPDATECONFIRMATION      {get {return 3;}}

	public Boolean hasError{get{
		Boolean ret = false;
		List<ApexPages.Message> messages = ApexPages.getMessages();
		for(ApexPages.Message msg : ApexPages.getMessages())
		{
			if(msg.getSeverity() == ApexPages.Severity.ERROR || msg.getSeverity() == ApexPages.Severity.FATAL || msg.getSeverity() == ApexPages.Severity.WARNING){
				ret = true;
			}
		}
		return ret;
	}set;}


	public enum DomainValidation {
									NOTMATCHINGDOMAINS, //Used when email does NOT match any domain registered under the account nor parent account
									MATCHINGDOMAIN,     //Used when email does match one domain registered under the account or parent account
									NOREGISTEREDDOMAIN, //Used when no domain is registered under the account nor parent account
									ERROR               //Used when no domain is registered under the account nor parent account
								}

	/*********************************************************************************************************************/
	/* Constructor Methods
	/*********************************************************************************************************************/


	/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Controller class constructor
	public vfIECUpdateContact() {
		bEmailChanged = false;
		bShowEmailDomainMessage = false;
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
				//Pagereference prLogin = Page.IECLogin;
				Pagereference prLogin = Page.IEC_Login;
				//prLogin.getParameters().put(IECConstants.PARAM_RETURN_URL, IECUtil.EncryptEncodeParameter(ApexPages.currentPage().getUrl()));
				//prLogin.getParameters().put(IECConstants.PARAM_WARNING_MSG, IECUtil.EncryptEncodeParameter(Label.IEC_Warning_Must_Login));
				prLogin.getParameters().put(IECConstants.PARAM_RETURN_URL, ApexPages.currentPage().getUrl());
				//prLogin.getParameters().put(IECConstants.PARAM_WARNING_MSG, Label.IEC_Warning_Must_Login);
				prLogin.setRedirect(true);
				return prLogin;
			}
			else {
				oContact = loggedCustomer.RelatedContact;

				// Validate Logged in user profile and ensure profile is complete
				validUserProfile();

				//Ensure there is a customer registered
				IECCustomer currentCustomer = IECCustomer.getCurrentIECCustomer();
				if (currentCustomer == null) return null;

				sOldEmail = oContact.Email;

				//Get the accountAddress related to the user
				Account account = [ select Name, BillingStreet, BillingCity, BillingCountry, BillingState, BillingPostalCode
									from Account
									where Id =: oContact.AccountId];

				sAccountName = account.Name;

				/* Commented by Samy (2016-03-02): Billing Address updates is not required as per scope of this page
				//Get the addresses related to the contact
				List<IECAddress__c> addresses = [select Address_Type__c, State__c, Street__c, City__c, Country__c, ZipCode__c from IECAddress__c where contact__c =: oContact.Id order by LastModifiedDate desc ];

				//If the addresses exists, differentiate them by type: billing or shipping
				if (addresses != null && addresses.size() > 0) {
					for(IECAddress__c a : addresses) {

						if (a.Address_Type__c == IECConstants.IECAddress_AddressType_Billing && oBilling == null)
							oBilling = a.clone(true);
					}
				}

				//Create a new address object if no existing billing address
				if (oBilling == null)
					oBilling = newAddressFromAccount(account, IECConstants.IECAddress_AddressType_Billing);
				*/


				//Set first step in update flow
				iRegistrationStep = constCONTACTINFO;
			}
		}
		catch(Exception ex) { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() )); if (Test.isRunningTest()) throw ex; }

		return null;
	}

	/* Commented by Samy (2016-03-02): Billing Address updates is not required as per scope of this page
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Build a new IECAddress object based on the address registered for the given account
	private IECAddress__c newAddressFromAccount(Account account, String addressType) {

		IECAddress__c address  = new IECAddress__c(Contact__c = oContact.Id, Address_Type__c = addressType);

		if (addressType == IECConstants.IECAddress_AddressType_Billing) {
			address.Street__c = account.BillingStreet ;
			address.City__c = account.BillingCity;
			address.Country__c = account.BillingCountry;
			address.State__c = account.BillingState;
			address.ZipCode__c = account.BillingPostalCode;
		}

		return address;
	}*/

	/**
	 * Method that validates the contact and billing address fields.
	 * Adds error message to a collection for all invalid fields.
	 */
	private boolean isValidPage() {
		Boolean isValid = true;

		//Check for Contact information
		if (String.isBlank(oContact.FirstName)){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IEC_Error_Required_field + ' First Name' ));
			isValid = false;
		}

		if (String.isBlank(oContact.LastName)){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IEC_Error_Required_field + ' Last Name' ));
			isValid = false;
		}


		if (String.isBlank(oContact.Title)){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IEC_Error_Required_field + ' Job Title' ));
			isValid = false;
		}

		if (String.isBlank(oContact.Phone)){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IEC_Error_Required_field + ' Phone' ));
			isValid = false;
		}

		if (String.isBlank(oContact.Email)){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IEC_Error_Required_field + ' Email' ));
			isValid = false;
		}else if (!IECUtil.validateEmail(oContact.Email)){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IEC_Error_InvalidEmail));
			isValid = false;
		}

		return isValid;
	}

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Update the contact information
	public PageReference updateContact() {

		try {

			//Check for valid form fill
			if (!isValidPage())
				return null;

			bPasswordReset = (Test.isRunningTest()) ? true : false;

			//Check for changes on the email. This will force a confirmation since it also requires an update on the User's email and username fields

			//*************************
			// Temporary Disabled
			bEmailChanged = !oContact.Email.equals(sOldEmail);

			//Ask (if necessary) to validate the email entered. The change will affect the Username and the status for domain compliance
			if (iRegistrationStep == constCONTACTINFO && bEmailChanged) {

				//Shows the email confirmation/change on any email change
				iRegistrationStep = constCHANGEEMAIL;

				//Check for domain validation
				IECUtil.DomainValidation validation = IECUtil.validateContactEmailDomain(oContact.Email, oContact.AccountId);
				if (validation == IECUtil.DomainValidation.NOTMATCHINGDOMAINS)
					bShowEmailDomainMessage = true;

				//Do not process the update yet
				return null;
			}

			//From the confirmation/change email shows an error if user has entered a non matching confirmation email
			if (iRegistrationStep == constCHANGEEMAIL && sConfirmEmail != oContact.Email) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The email address confirmation does not match' ));
				return null;
			}


			//Revalidate Email domain and Update User if no other user exists with same Username
			if (iRegistrationStep == constCHANGEEMAIL) {

				//Check for domain validation
				IECUtil.DomainValidation validationNew = IECUtil.validateContactEmailDomain(oContact.Email, oContact.AccountId);
				IECUtil.DomainValidation validationOld = IECUtil.validateContactEmailDomain(sOldEmail, oContact.AccountId);

				if (validationNew == IECUtil.DomainValidation.MATCHINGDOMAIN) {

					//Hanldes the case of new email valid for account domain list
					if (validationOld == IECUtil.DomainValidation.MATCHINGDOMAIN) {
						//Old email was also valid for the account domain list: keep status to Privilege - Approved
						oContact.User_IECPortal_Status__c = IECConstants.APPROVED_CONTACT_STATUS;
					}
					else {
						//Old email was not valid for account domain list: reset Password and set status to Pending Login
						oContact.User_IECPortal_Status__c = IECConstants.PENDING_LOGIN_STATUS; bPasswordReset = true;
					}
				}
				else {
					//Handles new email domain not valid for account domain list: set status to pending approval
					oContact.User_IECPortal_Status__c = IECConstants.PENDING_APPROVAL_STATUS;
				}


				//Check for username already used
				List<User> newUser = [select id, Username from User where Username =: oContact.Email limit 1];
				if (newUser != null && newUser.size() != 0) {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The Username ' + oContact.Email + ' already exist. Please use another email address' ));
					return null;
				}

				//Proceed to update the user with the new username and email
				//updateUser(sOldEmail, oContact.Email, bPasswordReset);
			}


			 // End of Temporary Disable
			//******************************


			//Updates SF Contact and Address information

			IECUserManager.updateContactViaWebService(oContact);

			/* Commented by Samy (2016-03-02): Billing Address updates is not required as per scope of this page
			upsert oBilling;*/

			//update oContact;
			updateUserFirstAndLastName(oContact.FirstName, oContact.LastName, oContact.Id);

			//reset user pswd if needed
			 if (bPasswordReset)
			 {
					List<User> lstCurrentUser = [select id from User where ContactId =: oContact.Id limit 1];
					User currentUser = (lstCurrentUser != null && !lstCurrentUser.isEmpty() ? lstCurrentUser.get(0) : null);
					System.resetPassword(currentUser.Id,true);
			  }


			sOldEmail = oContact.Email;
			iRegistrationStep = constUPDATECONFIRMATION;
			bShowEmailDomainMessage = false;
		}
		catch (Exception ex) { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() )); }

		return null;
	}

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Goes back to Contact informaion form
	public void backToContactInfo() {
		iRegistrationStep = constCONTACTINFO;
	}

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Updates username and email information on User object.
	//It's executed in the future to avoid conflicts with DML updates for Contact and User on the same transaction
	/*TEMPORARY DISABLED

	@future
	static void updateUser(String currentEmail, String newEmail, boolean passwordReset) {
		try {
			List<User> lstCurrentUser = [select id, Name, Username, Email from User where Username =: currentEmail limit 1];
			User currentUser = (lstCurrentUser != null && !lstCurrentUser.isEmpty() ? lstCurrentUser.get(0) : null);

			if (currentUser != null) {
				currentUser.Username = newEmail;
				currentUser.Email = newEmail;
				update currentUser;

				if (passwordReset)
					System.resetPassword(currentUser.Id,true);
			}
		}
		catch (Exception ex) {
			system.debug('ERROR in vfIECUpdateContact.updateUser(): ' + ex.getMessage() + ' ' + ex.getStacktraceString());
		}
	}

	//END TEMPORARY DISABLED
	*/
	@future
	static void updateUserFirstAndLastName(String sFirstName, String sLastName, String sContactId) {
		try {
			List<User> lstCurrentUser = [select id, Name, Username, Email from User where ContactId =: sContactId limit 1];
			User currentUser = (lstCurrentUser != null && !lstCurrentUser.isEmpty() ? lstCurrentUser.get(0) : null);

			if (currentUser != null) {
				currentUser.FirstName = sFirstName;
				currentUser.LastName = sLastName;
				update currentUser;
			}
		}
		catch (Exception ex) {
			system.debug('ERROR in vfIECUpdateContact.updateUser(): ' + ex.getMessage() + ' ' + ex.getStacktraceString());
		}
	}
}
