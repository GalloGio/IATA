public without sharing class OneIdLightningLoginFormController {
    
    public static Boolean show90Days {get; set;}
    public static string theCountry {get; set;}
    public static String country {get; set;}
    public static string ipAddress {get; set;}
    public static string siteCompleteUrl {get; set;}
    
    //@AuraEnabled
    public static Boolean sanctionCountry {get; set;}

    public OneIdLightningLoginFormController() {
        
    }
    

    /*******************************************************************************************************
    * @description handles user login
    *
    * @param {string} username - username or user email
    * @param {string} password - user password
    * @param {string} startUrl - start url: url to jump to after login
    *
    * @return {string} error message string in case of login error or null for the case of login with success.
    *
    * @example
    * changeLanguage('paulo.bastos@rightisservices.com','asdsawqe','home');
    */
    @AuraEnabled
    public static String login(String username, 
                               String password, 
                               String startUrl) {
        User oneUser;
        String pageLink='';
        
        //Clear spaces
        username = (null != username) ? username.trim() : username;
                                   
        try{
            System.debug('Controller.login.Begin');
            
            list<User> userList = DAL_ISSP.getUserListByNameOrEmail(username);
            system.debug('userList: ' + userList);
            system.debug('username: ' + username);

            //Errors validation
            if (username==''){
                return Label.OneId_Password_ErrorBlank;
            }
            else if (password==''){
                return Label.OneId_Password_ErrorBlank;
            }         
            
            if(ISSP_Utilities.isNotEmpty(userList)) {
                oneUser = userList[0];
//to developer Testing user frozen reactivate user reset password and send password email  - uncoment line below
//oneUser.Portal_User_Frozen_Checkbox__c=true;
                
                system.debug('user id: ' + oneUser.Id);
                system.debug('contact id: ' + oneUser.ContactId);
                system.debug('Portal_User_Frozen_Checkbox__c: ' + oneUser.Portal_User_Frozen_Checkbox__c);
                
                if(String.isNotBlank(startUrl)) 
                    pageLink = startUrl;
                
                if (oneUser.Portal_User_Frozen_Checkbox__c){
                    show90Days = true;
                    reactivateUser(oneUser);
                    return Label.ISSP_Frozen_User_Alert_Message;
                }
            }
            show90Days = false;
            
            //Code below was in the ISSP portal but were considered not necessary for onidentity so was commented
            /*
            String relayState = ApexPages.currentPage().getParameters().get('RelayState');
            if (relayState!=null)
                pageLink = '/ISSP_Homepage?kaviURL='+ relayState.remove('https://').remove('http://');
    		*/
            
                
            username=null != oneUser ? oneUser.Username : username;
            system.debug('pageLink: ' + pageLink);
            system.debug('Used Username: '+username);
            
            //login in site
            ApexPages.PageReference lgn = Site.login(username, password, pageLink);
            
            system.debug('page reference return from login: '+lgn);
            
            //redirect to startUrl or some other page returned from the login 
            //for different login cases scenarios
            aura.redirect(lgn);
            
            //return null in case of login success
            return null;
        }
        catch (Exception ex) {
            //return serror message string in case of any errors
            system.debug('ERROR ON LOGIN: '+ex.getMessage());
            return Label.OneId_LoginFail;
        }
    }

    public static void reactivateUser(User thisUser){
        thisUser.IsActive = true;
        thisUser.Portal_User_Frozen_Checkbox__c = false;
        update thisUser;
        Boolean success = Comm_User_Helper.resetPassword(thisUser.email, 
                                                         Comm_User_Helper.ONEIDENTITY, 
                                                         false);
    }

    public static void findLocationCaller(){
        findLocation(true);
    }
    
    public static void findLocation(Boolean saveLog){
  
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
  
		system.debug('APEX findLocation.ipAddress: '+ipAddress);
        
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
                    country = parser.getText();
                    system.debug('COUNTRY:' + country);
                }
            }
            if (country != ''){
                newLog.Success__c = true;
                system.debug('var -> saveLog: ' + saveLog);
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
                        system.debug('TRUE -> sanctionCountry:' + sanctionCountry);
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
/* sanctionCountry = true; */
    }
    
    /*
    @AuraEnabled
    public static Boolean getLoginInfo(String clientIpAddress) {
        loginInfo=new LoginModel();
        
        loginInfo.show90Days=show90Days;
        
        loginInfo.isUsernamePasswordEnabled=getIsUsernamePasswordEnabled();
        loginInfo.isSelfRegistrationEnabled=getIsSelfRegistrationEnabled();
        loginInfo.forgotPasswordUrl=getForgotPasswordUrl();
        
        loginInfo.sanctionCountry=getSanctionCountry(clientIpAddress);
        
        return loginInfo;
    }
    */
    
    @AuraEnabled
    public static String getSiteCompleteUrl() {
        siteCompleteUrl = OneIdUtils.getSiteCompleteUrl();
        return siteCompleteUrl;
    }
    
    @AuraEnabled
    public static Boolean getShow90Days() {
        //show90Days=true;
        return show90Days;
    }
    
    @AuraEnabled
    public static Boolean getSanctionCountry(String clientIpAddress) {
        //Set client ip address
        ipAddress=clientIpAddress; 

        findLocationCaller();
        
        //sanctionCountry=true;
        return sanctionCountry;
    }
    
    @AuraEnabled
    public static Boolean getIsUsernamePasswordEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getUsernamePasswordEnabled();
    }

    @AuraEnabled
    public static Boolean getIsSelfRegistrationEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getSelfRegistrationEnabled();
    }

    @AuraEnabled
    public static String getSelfRegistrationUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        if (authConfig.getSelfRegistrationEnabled()) {
            return authConfig.getSelfRegistrationUrl();
        }
        return null;
    }

    @AuraEnabled
    public static String getForgotPasswordUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getForgotPasswordUrl();
    }
    
    @TestVisible
    private static Auth.AuthConfiguration getAuthConfig(){
        Id networkId = Network.getNetworkId();
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(networkId,'');
        return authConfig;
    }
}