/**
 * Component for the login of users
 */
public with sharing class VfIECLoginComponent {

	public String username                  { get; set; }
	public String sPrefillUsername          { get; set; }
	public String password                  { get; set; }
	public String retURL                    { get; set; }
	public Boolean bHideRegisterLink        { get; set; }
	public String componentIdToRerender     { get; set; }
	public Boolean resetPassword            { get; private set; }
	public String resetPasswordEmail        { get; set; }
	public boolean bDisplayPopUp            {get; set;}
	public Boolean isUserLoggedIn {
		get {
			return IECUserManager.isUserLoggedIn();
		}
		private set;
	}

	/**
	 * Constructor
	 */
	public VfIECLoginComponent() {
		try {

			bHideRegisterLink = false;

			String paramReturnURL = System.currentPageReference().getParameters().get(IECConstants.PARAM_RETURN_URL);
		  //  w new transformationException('  isUserLoggedIn ' +  isUserLoggedIn +  '   '   + paramReturnURL );
			String paramResetPassword = System.currentPageReference().getParameters().get(IECConstants.PARAM_RESETPASSWORD);

			if (paramReturnURL == null || paramReturnURL == '') {
				retURL = null;
			}
			else {
				//retURL = IECUtil.DecodeDecryptParameter(paramReturnURL);
				retURL = paramReturnURL;
			}


			if (paramResetPassword != null && paramResetPassword != '') {
				resetPassword = Boolean.valueOf(paramResetPassword);
			}

		}
		catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
		}
	}

	/**
	 * Handles the login
	 */
	public Pagereference login() {
		try {
		   // throw new transformationException('  isUserLoggedIn ' +  isUserLoggedIn +  '     retUrl  ' +  retURL + '     IECUserManager.login(username, password, retURL'+ IECUserManager.login(username, password, retURL)  );
			if ((username == null || username == '') && (sPrefillUsername == null || sPrefillUsername==''))
			   throw new IECApplicationException('The Username field is required.');
			if (password == null || password == '')
				throw new IECApplicationException('The Password field is required.');

			if (sPrefillUsername != null && sPrefillUsername != '') {
				username = sPrefillUsername;
				sPrefillUsername = '';
			}



			if (username != null && username != '') {

			   Pagereference pr  = IECUserManager.login(username, password, retURL);

				//throw new transformationException(''+pr   );
				return pr ;}


			return null;
		}
		catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
			return null;
		}
	}

	/**
	 * Redirects to the Registration page
	 */
	public Pagereference register() {
		try {
			//Pagereference pr = Page.IECUserRegistration;
			//MM: I have changed the target registration page to the ISS registration page and added a parameter to identify from which portal customer is coming from: "IEC".
			Pagereference pr = Page.ISSP_Registration;
		 	pr.getParameters().put('sRefererCommunity','iec');


			// add return URL as parameter if one was provided
			if (retURL != null && retURL != '') {
				pr.getParameters().put(IECConstants.PARAM_RETURN_URL, IECUtil.EncryptEncodeParameter(retURL));
			}
			pr.getParameters().put('CommunityName','IEC');
			pr.setRedirect(true);
			return pr;
		}
		catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
			return null;
		}
	}

	/**
	 * Refresh the component to display the reset password fields
	 */
	public Pagereference forgotPassword() {
		try {
			resetPassword = true;
			return null;
		}
		catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
			return null;
		}
	}

	/**
	 * Refresh the component to display the reset password fields
	 */
	public Pagereference forgotPasswordRedirect() {
		try {
			Pagereference pr = Page.IECLogin;

			// add return URL as parameter if one was provided
				pr.getParameters().put(IECConstants.PARAM_RESETPASSWORD, 'true');

			pr.setRedirect(true);
			return pr;
		}
		catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
			return null;
		}
	}


	/**
	 * Resets the password for a given username
	 */
	public Pagereference resetPassword() {
		try {
			bDisplayPopUp = false;

			if (resetPasswordEmail == null || resetPasswordEmail == '') {
				throw new IECApplicationException('The Username field is required.');
			}

			list<User> users =  Comm_User_Helper.getUserListByNameOrEmail(resetPasswordEmail );
			if(users  == null || users.size() == 0 )
				 throw new IECApplicationException('No eligible user found. Please check you typed the username correctly.');

			  if (users[0].contactid == null  ) {
				throw new IECApplicationException('Your password could not be reseted. Please contact support. No contact Found');
			}



			// reset password
		  //SALVATORE if (IECUserManager.resetPassword(resetPasswordEmail)) {
			if (Comm_User_Helper.resetPassword(resetPasswordEmail, 'iec', false) ){
				resetPassword = false;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'A new password has been sent to ' + resetPasswordEmail));
			}
			else
				throw new IECApplicationException('Your password could not be reseted. Please contact support.');

			return null;
		}
		catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
			return null;
		}
	}



	/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Close the confirmation frame used to confirm the autorenew value
	public void closePopup() {
		bDisplayPopUp = false;
	}

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Shows the confirmation frame before updating the autoRenew value
	public void showPopup() {
		bDisplayPopUp = true;
	}

}
