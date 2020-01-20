public without sharing class VfIECChangePassword extends IEC_PageController {

	public String currentPassword { get; set; }
	public String newPassword { get; set; }
	public String confirmNewPassword { get; set; }
	String paramReturnURL;

	/**
	 * Constructor
	 */
	public VfIECChangePassword() {
		hasError = false;
		paramReturnURL = System.currentPageReference().getParameters().get(IECConstants.PARAM_RETURN_URL);
	}

	/**
	 * Changes the user's password
	 */
	public Pagereference changePassword() {

		try {
			hasError = false;
			// validate fields
			List<String> errMsgs = new List<String>();

			if (currentPassword == null || currentPassword == '')
				errMsgs.add('The Current password field is mandatory.');
			if (newPassword == null || newPassword == '')
				errMsgs.add('The New password field is mandatory.');
			if (confirmNewPassword == null || confirmNewPassword == '')
				errMsgs.add('The Confirm new password field is mandatory.');

			if (errMsgs.size() > 0) {
				for (String errMsg : errMsgs)
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errMsg));

				hasError = true;
				return null;
			}
			else {

				if(!test.isRunningTest())Comm_User_Helper.updateUsersGUID(UserInfo.getUserId());
				PageReference pageRef = Site.changePassword(newPassword, confirmNewPassword, currentPassword);

				hasError = true;
				if(pageRef != null){
					if(paramReturnURL != null && !paramReturnURL.contains('null')){
						String redirectUrl = (paramReturnURL.startsWith('/')) ?  paramReturnURL : '/' + paramReturnURL;
						pageRef = new PageReference(redirectUrl);
					}
					hasError = false;
					pageRef.setRedirect(true);

					return pageRef;
				}

				return null;

			}
		}
		catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
			hasError = true;
			return null;
		}
	}


}
