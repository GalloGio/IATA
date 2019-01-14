public with sharing class ISSP_ForgotPasswordController {
	
	public string lang{get
    {
        string t = '';
        //CNS only in english
        if(communityName=='CNS'){
            t = 'en_US';
            system.debug('CNS comm LANG: ' + t);
          }
          else{
        Cookie coo = ApexPages.currentPage().getCookies().get('lang');
        if(coo != null){
            t = string.valueOf(coo.getValue());
            system.debug('COOKIE: ' + t);
        }
        else if(System.currentPageReference().getParameters().get('lang')!=null){
             t = System.currentPageReference().getParameters().get('lang');
             coo = new Cookie('lang',t,null,-1,false);
             ApexPages.currentPage().setCookies(new Cookie[]{coo});
             system.debug('PARAMETER: ' + t);
        }
        else{
        	String LANGUAGES_FROM_BROWSER_AS_STRING = ApexPages.currentPage().getHeaders().get('Accept-Language');
        	if (LANGUAGES_FROM_BROWSER_AS_STRING != null && LANGUAGES_FROM_BROWSER_AS_STRING != ''){
	    		list<String> langList = LANGUAGES_FROM_BROWSER_AS_STRING.split(',');
	    		if (!langList.isEmpty()){
	    			t = langList[0];
	    			system.debug('LANG LIST: ' + t);
	    		}
	    		else{
					t = 'en_US';
					system.debug('NO LANG LIST: ' + t);
	    		}
        	}
        	else{
				t = 'en_US';
				system.debug('NO BRWOSER LANG: ' + t);
        	}
        }
        }   
        return t;
    }set;}
	
	public String username {
		get; 
		set {
			username = (null != value) ? value.trim() : value;
		}
	}   
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
    	emailSent = false;
    	errorMessage = new list<string>();
    }
	
	/**
	 * Reset the password and send an email to the portal user
	 */
  	public void forgotPassword() {
  		
  		//AEF:
  		system.debug('username: ' + username);
  		list<User> users = DAL_ISSP.getUserListByNameOrEmail(username);
  		system.debug('users: ' + users);
  		//changed for new email process - TF
  		boolean success = true;
  		system.debug('users: ' + users);
  		if (!users.isEmpty()){
  			system.debug('ContactId: ' + users[0].ContactId);
  			system.debug('Email: ' + users[0].Email);
  			system.debug('Portal_User_Frozen_Checkbox__c: ' + users[0].Portal_User_Frozen_Checkbox__c);
  			
  			// TF - reactivate frozen user
  			ISSP_Login.reactivateUser(users[0]);
  			/*
  			if (users[0].Portal_User_Frozen_Checkbox__c){
  				if (!users[0].IsActive){
  					users[0].IsActive = true;
  					users[0].Portal_User_Frozen_Checkbox__c = false;
  					update users[0];
  				}
  				//ISSP_Login.reactivateContact(users[0].ContactId);
  			}
  			if (users[0].ContactId != null){
  				success = Comm_User_Helper.resetPassword(users[0].email, Comm_User_Helper.ISSP, false);
  			}
  			else{
  				success = false;
  			}
  			*/
  		}
  		else{
  			success = false;
  		}
  		
  		//commented for new email process - TF
  		//String oneUserName = ISSP_Utilities.isNotEmpty(users) ? users[0].Username : username;
  		//boolean success = Site.forgotPassword(oneUserName);

  		if (success) {  	
        	emailSent = true;
  		}
		else {
			 errorMessage.add(generalError);
        	//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Could not reset the password for username ' + username + '. Please contact IATA customer support.'));
        	//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, String.Format(Label.IFAP_Cannot_Reset_Password_1, new String[] {'<i>' + username + '</i>'}) +'. ' + Label.IFAP_Please_Contact_CS));
		}
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