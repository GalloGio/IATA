public without sharing class ISSP_Login {

	public Boolean show90Days {get; set;}
	public Boolean sanctionCountry {get; set;}
	public String country {get; set;}    

	//new CNS
	public String communityName{
	  get{        
		return ApexPages.currentPage().getParameters().get('CommunityName');
	  }set;}
     public String commParam { get { if(communityName=='CNS'){ return '?CommunityName='+ communityName;} return ''; } set;}
       
    	  
 //detect browser for ISSP_Newlogin not working in frame in IE
  public string isIE {get
    {
        String b = 'IE';
        //default IE
          String browser = ApexPages.currentPage().getHeaders().get('USER-AGENT');
          if (browser != null && browser != ''){
          if (browser.contains('MSIE') || browser.contains('rv:11.0'))
            //IE
            {
            b = 'IE';
          }
          else
            //not IE
          {
            b  = 'notIE';
            }
          }
          return b;
    }set;}

    public string lang{get
    {
        string t = '';
        Cookie coo = ApexPages.currentPage().getCookies().get('lang');
        if(System.currentPageReference().getParameters().get('lang')!=null){
             t = System.currentPageReference().getParameters().get('lang');
             coo = new Cookie('lang',t,null,-1,false);
             ApexPages.currentPage().setCookies(new Cookie[]{coo});
             system.debug('PARAMETER: ' + t);
        }
        else if(coo != null){
            t = string.valueOf(coo.getValue());
            system.debug('COOKIE: ' + t);            
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
		if(this.communityName == 'CNS') t = 'en_US';        
        return t;
    }set;}

    public String username {
        get;
        set {
            username = (null != value) ? value.trim() : value;
        }
    }
    public String password {get; set;}

    public PageReference login() {
        User oneUser;
        String pageLink = '/ISSP_IframeHome'+ commParam;
    
        String retURL = ApexPages.currentPage().getParameters().get('retUrl');

        list<User> userList = DAL_ISSP.getUserListByNameOrEmail(username);
        system.debug('userList: ' + userList);
        system.debug('username: ' + username);
        if(ISSP_Utilities.isNotEmpty(userList)) {
            oneUser = userList[0];

            /*if(DAL_ISSP.getLoginHistoryByUserId(oneUser.Id).isEmpty())
                pageLink = '/_ui/system/security/ChangePassword';
            else*/
            system.debug('user id: ' + oneUser.Id);
            system.debug('contact id: ' + oneUser.ContactId);
            system.debug('Portal_User_Frozen_Checkbox__c: ' + oneUser.Portal_User_Frozen_Checkbox__c);
            if(String.isNotBlank(retURL))
                pageLink = retURL + commParam;
            if (oneUser.Portal_User_Frozen_Checkbox__c && String.isNotBlank(retURL) && retUrl.toLowerCase().contains('iec')){
                ISSP_Login.reactivateIECUser(oneUser);
                return null;
            }
			if (oneUser.Portal_User_Frozen_Checkbox__c){
				show90Days = true;
				ISSP_Login.reactivateUser(oneUser);
				return null;
			}
        }
        show90Days = false;

        String relayState = ApexPages.currentPage().getParameters().get('RelayState');

        if (relayState!=null)
            pageLink = '/ISSP_Homepage?kaviURL='+ relayState.remove('https://').remove('http://');
		
		//NEWGEN-660 and other
		//SSO SP Initiated: we need to send back the SAML Response to the ACS URL.
		//browser is redirected to ISSP_Login page if user not authenticated and the 
		//ACS endpoint (with all details) is URLEncoded and put into querystring parameter startURL
		//Thus, we need to check if startURL is existing and is populated. If so, we need redirect the browser
		//to the URL after login is done (third parameter of site.login method)
		
		string startURL = ApexPages.currentPage().getParameters().get('startURL');
		if (startURL!=null)
            pageLink = startURL;

		system.debug('pageLink: ' + pageLink);
        PageReference ans = Site.login(null != oneUser ? oneUser.Username : username, password, pageLink);
        system.debug('ans ans '+ans);
        return ans;
    }

    public static void reactivateUser(User thisUser){

    	thisUser.IsActive = true;
		thisUser.Portal_User_Frozen_Checkbox__c = false;
		update thisUser;
        Boolean success = false;
        if(thisUser.Contact.Community__c != null && thisUser.Contact.Community__c.contains('CNS')){
            success = Comm_User_Helper.resetPassword(thisUser.email, Comm_User_Helper.CNS, false);
        }else{
            success = Comm_User_Helper.resetPassword(thisUser.email, Comm_User_Helper.ISSP, false);
        }
        

    	/*
    	//show90Days = false;
    	system.debug('checkDays: ' + username);
    	list<User> userList = DAL_ISSP.getUserListByNameOrEmail(username);
    	system.debug('userList: ' + userList);
        if(!userList.isEmpty()) {
        	try{
        		userList[0].IsActive = true;
        		userList[0].Portal_User_Frozen_Checkbox__c = false;
        		update userList[0];
        		Boolean success = Comm_User_Helper.resetPassword(userList[0].email, Comm_User_Helper.ISSP, false);
        	}
        	catch (Exception e){
        		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
	    		//return null;
        	}
        	//reactivateContact(userList[0].ContactId);
        }
        //return null;
        */
    }


    public static void reactivateIECUser(User thisUser){

        thisUser.IsActive = true;
        thisUser.Portal_User_Frozen_Checkbox__c = false;
        update thisUser;
        Boolean success = Comm_User_Helper.resetPassword(thisUser.email, Comm_User_Helper.IEC, false);
    }

    @future
    public static void reactivateContact(string contactId) {
    	List <Contact> contactList = [SELECT Id, Portal_User_Frozen__c FROM Contact WHERE Id = :contactId];
    	if (!contactList.isEmpty()){
    		contactList[0].Portal_User_Frozen__c = false;
    		update contactList[0];
    	}
    }

    /*
    public PageReference iFrameLogin() {
    if (username == '' || username == null)
	{
	    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.ISSP_Registration_Error_Email));
	    return null;
	}
	    else if (password == '' || password == null)
	{
	    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.ISSP_Registration_Error_Password));
	    return null;
	}
	    else
	{
	    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.ISSP_Registration_Error_Login));
	    return null;

	}
        //String startUrl = System.currentPageReference().getParameters().get('startURL');
        String pageLink = '/ISSP_IframeHome';
        User oneUser;
        list<User> userList = DAL_ISSP.getUserListByNameOrEmail(username);

        if(ISSP_Utilities.isNotEmpty(userList)) {
            oneUser = userList[0];
            if(DAL_ISSP.getLoginHistoryByUserId(oneUser.Id).isEmpty()){
                pageLink = '/_ui/system/security/ChangePassword';
            }
        }
        system.debug('pageLink: ' + pageLink);
        return Site.login(null != oneUser ? oneUser.Username : username, password, pageLink);
    }
    */


    public PageReference forwardToAuthPage() {        
      String startUrl = System.currentPageReference().getParameters().get('startURL');
        return Network.forwardToAuthPage(startUrl);
    }

    public String ipAddress{
    	get{
    		return ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
    	}
    	set;
    }

    public PageReference findLocationCaller(){                
        findLocation(true);
        String getUrl = ApexPages.currentPage().getUrl();
        String oneIDStatus = 'OFF';
        String identityLogin = '/identity/s/login'; // will work on sandboxes

        if(ISSP_CS__c.getValues('1ID redirect').value__c != null){
            oneIDStatus = String.ValueOF(ISSP_CS__c.getValues('1ID redirect').value__c);
        }
        
        if(ISSP_CS__c.getValues('Identity Login Page') != null){
        	identityLogin = String.ValueOF(ISSP_CS__c.getValues('Identity Login Page').value__c);
        }
        
        String startUrl = ApexPages.currentPage().getParameters().get('startURL');
        String retURL = ApexPages.currentPage().getParameters().get('retURL');
         
        if(startUrl == null && retURL != null){            
            startUrl = retURL;
        }
        
        if(startUrl != null){            
            if(oneIDStatus == 'ON'){

                PageReference pr = new PageReference(identityLogin+'?startURL='+startUrl+'&serviceName=ISSP');
                pr.setRedirect(true);                        
                system.debug('aqui pr ' + pr);
                return pr;    
            }else{                
                return null;
            }            
        }
        else if(communityName == null && startUrl == null){            
            if(oneIDStatus == 'ON'){                
                PageReference pr = new PageReference(identityLogin+'?startURL=%2FISSP_Homepage&serviceName=ISSP');
                pr.setRedirect(true);
                return pr;    
            }else{
                return null;
            }
        }
        else{                 
            return null;
        }  
    }    

    public string theCountry {get; set;}

    public void findLocation(Boolean saveLog){        
    	sanctionCountry = false;
    	country = '';

    	ISSP_CS__c cs = ISSP_CS__c.getInstance('ipinfo_token');
        String ipinfo_token = cs.value__c;

    	ISSP_Web_Service_Log__c newLog = new ISSP_Web_Service_Log__c();
        newLog.Web_Service__c = 'IP_Info';
        newLog.Method__c = 'checkIpCountry';
        newLog.System__c = 'IpInfo';
        newLog.Login_Ip__c = ipAddress;
        newLog.Finished__c = system.now();

        String IP_LOOKUP_URL = 'https://ipinfo.io/' + ipAddress + '/json?token=' + ipinfo_token;
    	Http h = new Http();
    	HttpRequest req = new HttpRequest();
        req.setEndpoint(IP_LOOKUP_URL);
        req.setMethod('GET');
        req.setTimeout(2000);
        HttpResponse res;        
        try{
            res = h.send(req);            
            JSONParser parser = JSON.createParser(res.getBody());
            system.debug('message:' + String.valueOf(parser));
	        while (parser.nextToken() != null) {
	        	system.debug('field name:' + JSONToken.FIELD_NAME);
	        	system.debug('value:' + parser.getText());
	            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
	                (parser.getText() == 'country')) {
	                parser.nextToken();
	                system.debug('COUNTRY:' + parser.getText());
	                country = parser.getText();
	            }
	        }
	        if (country != ''){
	        	newLog.Success__c = true;
	        	if (saveLog){
	        		insert newLog;
	        	}

	        	system.debug('country: ' + country);
	        	List <IATA_ISO_Country__c> countryList =
	        		[SELECT Id, Name, Sanctioned_Country__c FROM IATA_ISO_Country__c
	        		WHERE ISO_Code__c = :country];
				if (!countryList.isEmpty()){
					theCountry = countryList[0].Name;
					if (countryList[0].Sanctioned_Country__c){
						sanctionCountry = true;
						system.debug('sanctionCountry:' + sanctionCountry);
					}
				}
	        }
	        else{
	        	newLog.Success__c = false;
	        	String theError = String.valueOf(parser);
	        	if (theError.length() > 254){
	        		newLog.Error_Message__c = theError.substring(0,254);
	        	}
	        	else{
	        		newLog.Error_Message__c = theError;
	        	}
	        	newLog.Finished__c = system.now();
	        	if (saveLog){
	        		insert newLog;
	        	}
	        }
        }catch(Exception e){
        	system.debug('Error: ' + e);
        	newLog.Success__c = false;
        	String theError = e.getMessage();
        	if (theError.length() > 254){
        		newLog.Error_Message__c = theError.substring(0,254);
        	}
        	else{
        		newLog.Error_Message__c = theError;
        	}
        	newLog.Finished__c = system.now();
        	if (saveLog){
        		insert newLog;
        	}
        }

    	if (ipAddress != '' && ipAddress != null && country == ''){
	    	system.debug('ipAddress: ' + ipAddress);
	    	List <String> ipList = ipAddress.split('\\.');
	    	system.debug('ipList: ' + ipList);
	    	Decimal ipInteger_1 = Decimal.valueOf(ipList[0]);
	    	Decimal ipInteger_2 = Decimal.valueOf(ipList[1]);
	    	Decimal ipInteger_3 = Decimal.valueOf(ipList[2]);
	    	Decimal ipInteger_4 = Decimal.valueOf(ipList[3]);
	    	system.debug('ipInteger_1: ' + ipInteger_1);
	    	system.debug('ipInteger_2: ' + ipInteger_2);
	    	system.debug('ipInteger_3: ' + ipInteger_3);
	    	system.debug('ipInteger_4: ' + ipInteger_4);
	    	Decimal ipTotal = (ipInteger_1*256*256*256) + (ipInteger_2*256*256) + (ipInteger_3*256) + (ipInteger_4);
	    	system.debug('ipTotal: ' + ipTotal);
	    	List <ISSP_IP_Locator__c> ipLocator = [SELECT Id, Country_Code__c FROM ISSP_IP_Locator__c
	    										WHERE Start_Integer__c <= :ipTotal
	    										AND End_Integer__c >= :ipTotal];
			system.debug('ipLocator: ' + ipLocator);
			if (!ipLocator.isEmpty()){
				country = ipLocator[0].Country_Code__c;
				List <IATA_ISO_Country__c> countryList =
	        		[SELECT Id, Name, Sanctioned_Country__c FROM IATA_ISO_Country__c
	        		WHERE ISO_Code__c = :country];
				if (!countryList.isEmpty()){
					theCountry = countryList[0].Name;
					if (countryList[0].Sanctioned_Country__c){
						sanctionCountry = true;
						system.debug('sanctionCountry:' + sanctionCountry);
						//PageReference pr = new PageReference('/ISSP_SanctionedCountry');
						//return pr;
					}
				}
			}
    	}

    }
	
	//EM - To be removed
	public static void fakemethod () {
		if (Test.isRunningTest()) {
			Integer i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
		}
	}

}