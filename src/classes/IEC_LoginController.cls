public without sharing class IEC_LoginController extends IEC_PageController {

    public String username                  { get; set; }
    public String password                  { get; set; }
    public String retURL                    { get; set; }
    public String resetPasswordEmail        { get; set; }

    String paramReturnURL;

    public String redirectUrl { get; set; }

    public IEC_LoginController(){}

    public Pagereference onLoadAction()
    {
        
        try {
            
            paramReturnURL = System.currentPageReference().getParameters().get(IECConstants.PARAM_RETURN_URL);
            String paramResetPassword = System.currentPageReference().getParameters().get(IECConstants.PARAM_RESETPASSWORD);
            
            retURL = (paramReturnURL == null || paramReturnURL == '') ? null : paramReturnURL;
            
            if(System.currentPageReference().getParameters().containsKey('doLogin'))
            {
                //Read username & password from post data
                username = ApexPages.currentPage().getParameters().get('username');
                password = ApexPages.currentPage().getParameters().get('password'); 
                hasError = true;
                hasConfirm = false;
                String retUrl = (System.currentPageReference().getParameters().containsKey('retUrl'))
                    ? System.currentPageReference().getParameters().get('retUrl')
                    : 'IEC_Home';
				
                if(retUrl.toLowerCase().contains('iec_forgotpassword') || retUrl.toLowerCase().contains('iec_login')){retUrl = 'iec_Home';}

                String tt = '?tt=';
                if(retUrl == 'null') {retUrl = 'iec_Home';}
                if(retUrl != null && retUrl.contains('?')) tt = '&tt=';

                // Ecommerce Enhancements - redirect using Javascript so that Cookies take effect
                Pagereference pr  = IECUserManager.login(username, password, '/'+retUrl + tt + DateTime.now().getTime()); 

                if (pr != null)
                    redirectUrl = pr.getUrl();

                // Ecommerce Enhancements - do not redirect via redirect, use JavaScript to allow cookies to store

                return null;
                //return pr ;
            }else{
                //Customer need to login in
                String resetPasswordEmail = ApexPages.currentPage().getParameters().get('resetPasswordEmail');
                if(resetPasswordEmail != null && resetPasswordEmail != ''){
                    addConfirmMessage('A new password has been sent to ' + resetPasswordEmail);
                }
            }

            return null;
        }
        catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));

            if (IEC_Trace.isDebugActive == true) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, ex.getStackTraceString()));
            }

            return null;
        }
    }


    /**
     * Handles the login
     */
    public Pagereference login() {
        try {
           // throw new transformationException('  isUserLoggedIn ' +  isUserLoggedIn +  '     retUrl  ' +  retURL + '     IECUserManager.login(username, password, retURL'+ IECUserManager.login(username, password, retURL)  );
            if (username == null || username == '')
               throw new IECApplicationException('The Username field is required.');
            if (password == null || password == '')
                throw new IECApplicationException('The Password field is required.');
              
            if (username != null && username != '') {

                if(retUrl == null){retUrl = 'iec_Home';}
                if(retUrl.toLowerCase().contains('iec_forgotpassword') || retUrl.toLowerCase().contains('iec_login')){retUrl = 'iec_Home';}

                String tt = '?tt=';
                if(retURL != null && retUrl.contains('?')) tt = '&tt=';

                Pagereference pr  = IECUserManager.login(username, password, retURL + tt + DateTime.now().getTime());
                
                 if(ApexPages.hasMessages(ApexPages.Severity.ERROR)) {
                    List<Apexpages.Message> msgs = ApexPages.getMessages();
                    for(Apexpages.Message msg:msgs){                 
                        system.debug('@@@msg detail: ' +msg.getDetail());
                        system.debug('@@@Label.ISSP_Frozen_User_Alert_Message: ' +Label.ISSP_Frozen_User_Alert_Message);
                        if (msg.getDetail().contains(Label.ISSP_Frozen_User_Alert_Message)) {
                            hasError = true;
                            //show90days = true;
                            //ApexPages.getMessages().clear();

                            return null;
                        }
                    }

                    hasError = true;
                }

                if(( ApexPages.currentPage().getUrl().contains('iecWebDownload'))){ //start RN-INC309648
                    String numb = System.currentPageReference().getParameters().get('itemNumber');
                    retUrl = '/iecWebDownload?itemNumber=' + numb;
                    pr  = IECUserManager.login(username, password, retURL);

                    return pr;
                }//end

                if(( ApexPages.currentPage().getUrl().contains('IEC_ViewQuotes'))){ //start SA-INC324413
                    retUrl = '/IEC_ViewQuotes';
                    pr  = IECUserManager.login(username, password, retURL);

                    return pr;
                }//end

                // Ecommerce Enhancements - do not redirect via redirect, use JavaScript to allow cookies to store
                if (pr != null) {
                    redirectUrl = pr.getUrl();
                }

                return null;
                //return pr ;
            }
                
            return null;
        
        }
        catch (Exception ex) {
            //addErrorMessage(ex.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            hasConfirm = false;
            hasError = true;

            return null;
        }
    }

    


    /**
     * Resets the password for a given username
     */
    public Pagereference resetPassword() {
        try {

            if (resetPasswordEmail == null || resetPasswordEmail == '') {
                throw new IECApplicationException('The Username field is required.');   
            }       
            
            //list<User> users =  Comm_User_Helper.getUserListByNameOrEmail(resetPasswordEmail );
            list<User> users =  Comm_User_Helper.getUserListByNameOrEmail2(resetPasswordEmail );
            if(users  == null || users.size() == 0 )
                 throw new IECApplicationException('No eligible user found. Please check you typed the username correctly.');

                    //EM: Need to reactivate the user 
            else if (users.size() == 1 && users[0].Portal_User_Frozen_Checkbox__c == true) {
                Pagereference pr = Page.IEC_Home;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_Frozen_User_Alert_Message)); 
                IECUserManager.reactivateUser(users[0].UserName);
                hasError = true;

                return null;
            }     
                 
            if (users[0].contactid == null  ) {
                throw new IECApplicationException('Your password could not be reseted. Please contact support. No contact Found');
            }       
            
            // reset password
          //SALVATORE if (IECUserManager.resetPassword(resetPasswordEmail)) {
            if (Comm_User_Helper.resetPassword(resetPasswordEmail, 'IEC', false) ){
                //resetPassword = false;
                /*ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'A new password has been sent to ' + resetPasswordEmail));
                resetPasswordEmail = '';*/
                //Redirect the Customer to the login page
                Pagereference pageRef = new Pagereference('/iec_Login?resetPasswordEmail=' + resetPasswordEmail);
                pageRef.setRedirect(true);

                return pageRef;
            }
            else {
                throw new IECApplicationException('Your password could not be reseted. Please contact support.');
            }
            
            return null;
        }
        catch (Exception ex) {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            addErrorMessage(ex.getMessage());

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
            /*Pagereference pr = Page.ISSP_Registration;
            pr.getParameters().put('sRefererCommunity','iec');*/

            String commingFromUrl = (paramReturnURL != null && paramReturnURL != '') ? 'IEC_Login?' + IECConstants.PARAM_RETURN_URL + '=' + paramReturnURL : 'IEC_Login';
            //Pagereference pr = Page.IECUserRegistration;
            //MM: I have changed the target registration page to the ISS registration page and added a parameter with the name of the initial call.
            Pagereference pr = Page.ISSP_Registration;
            pr.getParameters().put('sRefererCommunity', commingFromUrl);
            pr.getParameters().put('CommunityName','IEC');


            // add return URL as parameter if one was provided
            if (retURL != null && retURL != '') {
                pr.getParameters().put(IECConstants.PARAM_RETURN_URL, IECUtil.EncryptEncodeParameter(retURL));
            }
            
            pr.setRedirect(true);

            return pr;
        }
        catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));

            return null;
        }
    }
}