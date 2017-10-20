public with sharing class ISSP_ForgotPasswordController {

	public String username {
		get;
		set {
			username = (null != value) ? value.trim() : value;
		}
	}

	// START CHANGE MINESH CHAUHAN 24/08/17: ADDED FOR SECURITY ENHANCEMENT
	//: added var to trigger registration message to be shown and hide submit button
  public boolean submitted {
    get;
    set;
  }
	// END CHANGE

	public Boolean emailSent {get; set;}
	public list<String> errorMessage {get; set;}
	string generalError =  Label.ISSP_Registration_generalError;
  //new CNS
  public String communityName{
    get{
      return ApexPages.currentPage().getParameters().get('CommunityName');
    }set;}

    /**
     * Constructor
     */
    public ISSP_ForgotPasswordController() {
			// START CHANGE MINESH CHAUHAN 24/08/17: ADDED FOR SECURITY ENHANCEMENT
			//: initialised submitted var
     submitted = false;
		 // END CHANGE
    }

	/**
	 * Reset the password and send an email to the portal user
	 */
	 // START CHANGE MINESH CHAUHAN 24/08/17: ADDED FOR SECURITY ENHANCEMENT
	 //: changed to return PageReference to return to page if validation errors were found
	 public PageReference forgotPassword() {
		 //: added check for empty email field
		 if(String.isEmpty(username)){
			 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.ISSP_Null_Email_Error));
			 return null;
		 }
		 //: added email format check
		 else if(!Comm_User_Helper.validateEmail(username)){
			 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.ISSP_Email_Format_Error));
			 return null;
		 }
		 // END CHANGE

		 list<User> users = DAL_ISSP.getUserListByNameOrEmail(username);

  		//changed for new email process - TF
  		boolean success = true;
  		if (!users.isEmpty()){
  			ISSP_Login.reactivateUser(users[0]);
  		}
			// START CHANGE MINESH CHAUHAN 24/08/17: ADDED FOR SECURITY ENHANCEMENT
			//: added setting of var to trigger registration message to be shown and hide form components
    	submitted = true;
			//: added return null to stay on page and render error message in pageMessages
    	return null;
			// END CHANGE
  	}

  	public PageReference isLogined(){
  		if(!Userinfo.getUserType().contains('Guest')){
  			PageReference pr = new PageReference('/secur/logout.jsp');
        	return pr;
  		}
  		else{
  			return null;
  		}
  	}
}
