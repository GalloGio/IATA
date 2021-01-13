public without sharing class vfIECGSSFileRecipientDetail extends IECPageController {

	//Controller to handle the subscription information
	public vfIECSubscriptionInfo ctrSubsInfo { get; set; }
	public list <String> lstErrorMessage { get; set; }
	public Boolean bViewMode { get; set; }
	public string sFileRecipientFirstName {get;set;}
	public string sFileRecipientLastName {get;set;}
	public string sFileRecipientEmail {get;set;}
	public string sFileRecipientJobTitle {get;set;}
	public string sFileRecipientSalutation {get;set;}
	public string sFileRecipientPhone {get;set;}


	//Display variables


	public string sFileRecipientiiNet {
		get {
			return ctrSubsInfo.oFileSubscriptionDetail.Zuora_Subscription__r.Zuora__CustomerAccount__r.IINETUserID__c;
		}
	}

	public Zuora__Subscription__c subscriptionObj {
		get {
			return ctrSubsInfo.oSubscription;
		}
	}

	public String sProductCode { get; set; }
	public String sApplicationTitle {
		get {
			if (sProductCode == IECConstants.ProductCategory_SF_GSS)
				return IECConstants.ProductCategory_Zuora_GSS;
			else if (sProductCode == IECConstants.ProductCategory_SF_MDP)
				return IECConstants.ProductCategory_Zuora_MDP;
			else
				return '';
		}
	}

	public String sApplicationTitleUpperCase {
		get {
			return sApplicationTitle.toUpperCase();
		}
	}

	/**
	 * Constructor Method
	 **/
	public vfIECGSSFileRecipientDetail() {
		try {
			lstErrorMessage = new list < string > ();
			bViewMode = true;

			// Retrieve page parameters
			String sParamProductCode = ApexPages.currentPage().getParameters().get(IECConstants.PARAM_PRODUCT_CODE);
			sProductCode = IECUtil.DecodeDecryptParameter(sParamProductCode);

			//Initilize subscription component
			ctrSubsInfo = new vfIECSubscriptionInfo();
			ctrSubsInfo.loggedCustomer = loggedCustomer;
			ctrSubsInfo.sSelectedSubscriptionName = null;
			ctrSubsInfo.sApplicationName = sProductCode;
			LoadData();

			// check if Subscription Name was passed as a parameter
			String sParamSubscriptionName = ApexPages.currentPage().getParameters().get(IECConstants.PARAM_SUBSCRIPTION_NAME);
			if (sParamSubscriptionName != null && !String.isEmpty(sParamSubscriptionName))
				ctrSubsInfo.sSelectedSubscriptionName = IECUtil.DecodeDecryptParameter(sParamSubscriptionName);
			else
				ctrSubsInfo.sSelectedSubscriptionName = null;


		} catch (Exception ex) {
			addErrorMessage(ex.getMessage());
		}
	} // end of constructor


	private void LoadData()
	{
		sFileRecipientFirstName = ctrSubsInfo.oFileSubscriptionDetail.FileRecipientFirstName__c;
		sFileRecipientLastName  = ctrSubsInfo.oFileSubscriptionDetail.FileRecipientLastName__c;
		sFileRecipientEmail	 = ctrSubsInfo.oFileSubscriptionDetail.FileRecipientEmail__c;
		sFileRecipientJobTitle  = ctrSubsInfo.oFileSubscriptionDetail.FileRecipientJobTitle__c;
		sFileRecipientPhone	 = ctrSubsInfo.oFileSubscriptionDetail.FileRecipientPhone__c;
		sFileRecipientSalutation= ctrSubsInfo.oFileSubscriptionDetail.FileRecipientSalutation__c;
	} // end of LoadData

	public Pagereference pageLoad() {
		// first check if the user is logged in
		try {
			if (IECUserManager.isUserLoggedIn() == false) {
				Pagereference prLogin = Page.IECLogin;
				prLogin.getParameters().put(IECConstants.PARAM_RETURN_URL, IECUtil.EncryptEncodeParameter(ApexPages.currentPage().getUrl()));
				prLogin.getParameters().put(IECConstants.PARAM_WARNING_MSG, IECUtil.EncryptEncodeParameter(Label.IEC_Warning_Must_Login));
				prLogin.setRedirect(true);
				return prLogin;
			} else {
				// Validate Logged in user profile and ensure profile is complete
				validUserProfile();

				// Make sure to validate user access to application subscription
				ctrSubsInfo.validateSubscriptionAccess();

				// if no access, redirect to the unauthorized page
				if (!ctrSubsInfo.hasPageAccess) return Page.IECUnauthorized;
			}
		} catch (Exception ex) {
			addErrorMessage(ex.getMessage() + '<br />' + ex.getStackTraceString());
		}
		LoadData();
		return null;
	} // end of pageLoad

	public void onClickEdit() {
		bViewMode = false;
	}
	public void onClickCancel() {
		LoadData();
		bViewMode = true;
	}
	/*
	public PageReference onClickCancel() {
		bViewMode = true;
		return null;
		Pagereference pgRef = Page.IECFDFileRecipientDetail;
		pgRef.getParameters().put(IECConstants.PARAM_SUBSCRIPTION_NAME, IECUtil.EncryptEncodeParameter(ctrSubsInfo.oSubscription.Name));
		pgRef.getParameters().put(IECConstants.PARAM_PRODUCT_CODE, IECUtil.EncryptEncodeParameter(sProductCode));
		pgRef.setRedirect(true);
		return pgRef;
	}
	*/
	public void onClickSave() {
		try {
			// Reset showing the result sections
			lstErrorMessage.clear();

			if (String.isBlank(sFileRecipientSalutation))
				lstErrorMessage.add(Label.IEC_Error_Required_field + ' Salutation');
			if (String.isBlank(sFileRecipientFirstName))
				lstErrorMessage.add(Label.IEC_Error_Required_field + ' First Name');
			if (String.isBlank(sFileRecipientLastName))
				lstErrorMessage.add(Label.IEC_Error_Required_field + ' Last Name');
			if (String.isBlank(sFileRecipientEmail))
				lstErrorMessage.add(Label.IEC_Error_Required_field + ' Email');
			if (String.isBlank(sFileRecipientJobTitle))
				lstErrorMessage.add(Label.IEC_Error_Required_field + ' Job Title');
			if (String.isBlank(sFileRecipientPhone))
				lstErrorMessage.add(Label.IEC_Error_Required_field + ' Phone');

			if (lstErrorMessage.isEmpty()) {
				ctrSubsInfo.oFileSubscriptionDetail.FileRecipientFirstName__c = sFileRecipientFirstName;
				ctrSubsInfo.oFileSubscriptionDetail.FileRecipientLastName__c = sFileRecipientLastName;
				ctrSubsInfo.oFileSubscriptionDetail.FileRecipientEmail__c = sFileRecipientEmail;
				ctrSubsInfo.oFileSubscriptionDetail.FileRecipientJobTitle__c = sFileRecipientJobTitle;
				ctrSubsInfo.oFileSubscriptionDetail.FileRecipientPhone__c=sFileRecipientPhone ;
				ctrSubsInfo.oFileSubscriptionDetail.FileRecipientSalutation__c=sFileRecipientSalutation;

				ctrSubsInfo.saveFileSubscriptionDetails();

				addConfirmMessage(Label.IEC_Confirm_SaveSuccessful);
				bViewMode = true;
			}
			else
				addErrorMessages(lstErrorMessage);
		} catch (Exception ex) {
			addErrorMessage(ex.getMessage() + '<br />' + ex.getStackTraceString());
		}
	} // end of onClickSave
}
