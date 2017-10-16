/**
 * Component for the login of users
 */
public with sharing class VfIECLoginComponent {

    // START OF CHANGE MINESH CHAUHAN 24/08/17: ADDED FOR SECURITY ENHANCEMENT
    //: added var for google recaptcha private key
    private static String privateKey = '6LcjAS0UAAAAAIxqdCZyHovHIaUfOxeyqrFhDl6K';
    //: added var + methods for google recaptcha public key
    public String publicKey {
        get { return '6LcjAS0UAAAAAPJPJK1aUFYVk9jZqvAPihA4jVNp'; }
    }
    // END OF CHANGE
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
            String paramResetPassword = System.currentPageReference().getParameters().get(IECConstants.PARAM_RESETPASSWORD);

            if (paramReturnURL == null || paramReturnURL == '') {
                retURL = null;
            }
            else {
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
            // START CHANGE MINESH CHAUHAN 25/08/17: ADDED FOR SECURITY ENHANCEMENT
            //: modified exception throw to re-use custom label for null email
            {
                throw new IECApplicationException(Label.ISSP_Null_Email_Error);
            //: add email format validation
            } else if(!Comm_User_Helper.validateEmail(username)){
                throw new IECApplicationException(Label.ISSP_Email_Format_Error);
            }
            // END CHANGE

            if (password == null || password == '')
                throw new IECApplicationException('The Password field is required.');

            if (sPrefillUsername != null && sPrefillUsername != '') {
                username = sPrefillUsername;
                sPrefillUsername = '';
            }

            if (username != null && username != '') {
               Pagereference pr  = IECUserManager.login(username, password, retURL);
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
                // START CHANGE MINESH CHAUHAN 25/08/17: ADDED FOR SECURITY ENHANCEMENT
                //: use custom label instead of hard coded error message text
                throw new IECApplicationException(Label.ISSP_Null_Email_Error);
                // END CHANGE
            }

            // reset password
            // START CHANGE MINESH CHAUHAN 25/08/17: ADDED FOR SECURITY ENHANCEMENT
            //: added an email pattern match check showing custom label error if invalid
            if (!Comm_User_Helper.validateEmail(resetPasswordEmail)) {
                throw new IECApplicationException(Label.ISSP_Email_Format_Error);
            }
            //: added call to email new password to user without checking if user exists or not
            Comm_User_Helper.resetPassword(resetPasswordEmail, 'iec', false);
            //: set resetPassword = false to prevent email input box from rendering
            resetPassword = false;
            //: added generic message using custom label and injecting provided username
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, String.format(Label.ISSP_Forgot_Password_Message, new List<String>{resetPasswordEmail})));
            // END OF CHANGE

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
