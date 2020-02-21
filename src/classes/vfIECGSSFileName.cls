/**
	* Description: This class contains the controller for the Visualforce page (File Delivery - File Naming Convention)
	* Author: Samy Saied
	* Version: 1.0
	* History:
	*/

public without sharing class vfIECGSSFileName extends IECPageController {

	//Controller to handle the subscription information
	public vfIECSubscriptionInfo ctrSubsInfo {get; set;}

	//Display variables
	public list<String> lstErrorMessage   {get; set;}
	public Boolean bViewMode {get; set;}
	public String sApplyOption {
		get {
			return ctrSubsInfo.oFileSubscriptionDetail.File_Name_Applies_on__c;
		}
		set {
			ctrSubsInfo.oFileSubscriptionDetail.File_Name_Applies_on__c = value;
		}
	}
	public String sNamePrefixOption {
		get {
			return ctrSubsInfo.oFileSubscriptionDetail.File_Name_Prefix_Option__c;
		}
		set {
			ctrSubsInfo.oFileSubscriptionDetail.File_Name_Prefix_Option__c = value;
		}
	}
	public String sNameSuffixOption {
		get {
			return ctrSubsInfo.oFileSubscriptionDetail.File_Name_Suffix_Option__c;
		}
		set {
			ctrSubsInfo.oFileSubscriptionDetail.File_Name_Suffix_Option__c = value;
		}
	}

	public String sNamePrefix {
		get {
			return ctrSubsInfo.oFileSubscriptionDetail.File_Name_Custom_Prefix__c;
		}
		set {
			ctrSubsInfo.oFileSubscriptionDetail.File_Name_Custom_Prefix__c = value;
		}
	}
	public String sNameSuffix {
		get {
			return ctrSubsInfo.oFileSubscriptionDetail.File_Name_Custom_Suffix__c;
		}
		set {
			ctrSubsInfo.oFileSubscriptionDetail.File_Name_Custom_Suffix__c = value;
		}
	}

	public String sDate {get { return DateTime.now().format('yyyyMMdd'); }}

	public String sProductCode {get; set;}
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
	public vfIECGSSFileName() {
		try {
			lstErrorMessage = new list<string>();
			bViewMode = true;

			// Retrieve page parameters
			String sParamProductCode = ApexPages.currentPage().getParameters().get(IECConstants.PARAM_PRODUCT_CODE);
			sProductCode = IECUtil.DecodeDecryptParameter(sParamProductCode);

			//Initilize subscription component
			ctrSubsInfo = new vfIECSubscriptionInfo();
			ctrSubsInfo.loggedCustomer = loggedCustomer;
			ctrSubsInfo.sSelectedSubscriptionName = null;
			ctrSubsInfo.sApplicationName = sProductCode;

			// check if Subscription Name was passed as a parameter
			String sParamSubscriptionName = ApexPages.currentPage().getParameters().get(IECConstants.PARAM_SUBSCRIPTION_NAME);
			if (sParamSubscriptionName!=null && !String.isEmpty(sParamSubscriptionName))
				ctrSubsInfo.sSelectedSubscriptionName = IECUtil.DecodeDecryptParameter(sParamSubscriptionName);
			else
				ctrSubsInfo.sSelectedSubscriptionName = null;
		}
		catch (Exception ex) {
			addErrorMessage(ex.getMessage());
		}
	}

	public Pagereference pageLoad() {
		// first check if the user is logged in
		try {
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

				// Make sure to validate user access to application subscription
				ctrSubsInfo.validateSubscriptionAccess();

				// if no access, redirect to the unauthorized page
				if (!ctrSubsInfo.hasPageAccess)
					return Page.IECUnauthorized;
			}
		}
		catch(Exception ex) {
			addErrorMessage(ex.getMessage() + '<br />' + ex.getStackTraceString());
		}
		return null;
	}

	public void onClickEdit() {
		bViewMode = false;
	}

	public PageReference onClickCancel() {
		Pagereference pgRef = Page.IECFDFileName;
		pgRef.getParameters().put(IECConstants.PARAM_SUBSCRIPTION_NAME, IECUtil.EncryptEncodeParameter(ctrSubsInfo.oSubscription.Name));
		pgRef.getParameters().put(IECConstants.PARAM_PRODUCT_CODE, IECUtil.EncryptEncodeParameter(sProductCode));
		pgRef.setRedirect(true);
		return pgRef;
	}

	public void onClickSave() {
		try {
			// Reset showing the result sections
			lstErrorMessage.clear();

			if (String.isBlank(sApplyOption))
				lstErrorMessage.add(Label.IEC_Error_Required_field + ' Name Applies On');

			if (sNamePrefixOption == 'Custom' && String.isBlank(sNamePrefix))
				lstErrorMessage.add(Label.IEC_Error_Required_field + ' Custom Prefix');
			else if ((sNamePrefixOption == 'Date') || (sNamePrefix ==null))
				sNamePrefix = '';

	 		if (sNameSuffixOption == 'Custom' && String.isBlank(sNameSuffix))
				lstErrorMessage.add(Label.IEC_Error_Required_field + ' Custom Suffix');
			else if ((sNameSuffixOption == 'Date') || (sNameSuffix ==null))
				sNameSuffix = '';

			//Validate numerica values only
			Pattern isAlphanumericPlusDot = Pattern.Compile('^[a-zA-Z0-9.]*$');
			Matcher matchPrefix = isAlphanumericPlusDot.matcher(sNamePrefix);
			Matcher matchSuffix = isAlphanumericPlusDot.matcher(sNameSuffix);

			if(!matchPrefix.Matches())
				lstErrorMessage.add(Label.IEC_Error_InvalidFileNameFormat.replace('{0}', 'Custom Prefix'));

			if(!matchSuffix.Matches())
				lstErrorMessage.add(Label.IEC_Error_InvalidFileNameFormat.replace('{0}', 'Custom Suffix'));

			if (lstErrorMessage.isEmpty()) {
				ctrSubsInfo.saveFileSubscriptionDetails();

				addConfirmMessage(Label.IEC_Confirm_SaveSuccessful);
				bViewMode = true;
			}
			else
				addErrorMessages(lstErrorMessage);
		}
		catch (Exception ex) {
			addErrorMessage(ex.getMessage() + '<br />' + ex.getStackTraceString());
		}
	}

	// ========================================================================
	// onClickReset
	//  - reset the File Naming convention, no prefix, no suffix, no date stamp
	public void onClickReset() {
		try {
			ctrSubsInfo.oFileSubscriptionDetail.File_Name_Custom_Prefix__c = null;
			ctrSubsInfo.oFileSubscriptionDetail.File_Name_Custom_Suffix__c = null;
			ctrSubsInfo.oFileSubscriptionDetail.File_Name_Prefix_Option__c = null;
			ctrSubsInfo.oFileSubscriptionDetail.File_Name_Suffix_Option__c = null;
			ctrSubsInfo.oFileSubscriptionDetail.File_Name_Applies_on__c = null;
		} catch (Exception ex) {
			addErrorMessage(ex.getMessage() + '<br />' + ex.getStackTraceString());
		}
	} // end of onClickReset
}
