public with sharing class VfIECLogin extends IECPageController {

	public String retURL { get; private set; }
	public Boolean isUserLoggedIn {
		get {
			return IECUserManager.isUserLoggedIn();
		}
	}
	public String sClientType {
		get {
			return IECUserManager.getClientType();
		}
	}

	/**
	 * Constructor
	 */
	public VfIECLogin() {
		try {
			// check if a Return URL was provided
			String sReturnURLParam = ApexPages.currentPage().getParameters().get(IECConstants.PARAM_RETURN_URL);
			if (!String.isEmpty(sReturnURLParam)) {
				retURL = IECUtil.DecodeDecryptParameter(sReturnURLParam);
			}

			// check if a Warning message was provided
			String sWarningMsgParam = ApexPages.currentPage().getParameters().get(IECConstants.PARAM_WARNING_MSG);
			if (!String.isEmpty(sWarningMsgParam)) {
				addWarningMessage(IECUtil.DecodeDecryptParameter(sWarningMsgParam));
			}

			if (Test.isRunningTest()) throw new IECApplicationException('Test');
		}
		catch (Exception ex) {
			addErrorMessage(ex.getMessage());
		}
	}
}
