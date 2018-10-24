global without sharing class Comm_User_Helper {

   //public static boolean userCreation = false;
  public static final string ISSP ='ISSP';
  public static final string IEC = 'IEC';
  public static final string CNS = 'CNS';
  public static final String ONEIDENTITY = 'IDENTITY';
  public static final string SEPARATOR = '@#@#@#';
  public static final string KEYTODECODE = 'Kg0m2vAj4VmBBviGAUehrw==';
  public static final string plusReplacer = '@@##';

  public static String EncryptString( String str) {
        Blob dataToEncrypt = Blob.valueOf(str);
        Blob encryptedData = Crypto.encryptWithManagedIV('AES128', EncodingUtil.base64Decode(KEYTODECODE), dataToEncrypt);
        return EncodingUtil.base64Encode(encryptedData);
    }
    
    /**
     * Decrypts a string
     * @param key The key to use to decrypt
     * @param str The encrypted string
     * @return The decrypted string
     */
    public static String DecryptString( String str) {
      try{ 
           // throw new transformationException('key  '  +key + ' str  '  + str );

        Blob encryptedData = Encodingutil.base64Decode(str);
        Blob decryptedData = Crypto.decryptWithManagedIV('AES128', EncodingUtil.base64Decode(KEYTODECODE), encryptedData);
        return decryptedData.toString();
        
        }catch(Exception e){
        
            throw new transformationException(''+  e.getMessage() +   '  ' + e.getStackTraceString());
        }
    }
    

    //public static void sendSFDevsAlertMessage(String title, String message, List<String> receivers){
    public static String generateRandomString(Integer len) {
    
            final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
            String randStr = '';
            while (randStr.length() < len) {
               Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), 62);
               randStr += chars.substring(idx, idx+1);
            }
            return randStr; 
    }
    


        /*
     * Create new User
     */
    
    public static Id createNewUser(Contact con, string selectedCustomerType, string community){
        return createNewUser(con, selectedCustomerType, community, null);
    }
    
    public static Id createNewUser(Contact con, string selectedCustomerType, string community, string lang){
        return createNewUser(con, selectedCustomerType, community, lang, false, false);
    }
    
    public static Id createNewUser(Contact con, string selectedCustomerType, string community, string lang, Boolean newAgency, Boolean newAirline){
      try { 
        
          map<string, string> custmPortalPerIec = new map<string, string>{
                                                                      'Airline' =>'Airline',
                                                                      'Non Airline Supplier' =>'OtherCompany',
                                                                      'IATA Agency' =>'Agency',
                                                                      'Non IATA Agency' => 'OtherCompany',
                                                                      'GAS' =>'GloballSalesAgent',
                                                                      'Partner' =>'OtherCompany',
                                                                      'Other' =>'OtherCompany'
                                  };

        String userId;
        String accountId = '';
        string log;
        // prepare new User
        string UID = NewGuid();
        string userName = ISSP_Utilities.buildPortalUserName(con.email);
        User u = new User();
        //u.Username = con.email;
        u.Community__c = community;
        u.UID__c = UID;
        u.Username =  userName;//AEF
        u.Email = con.email;
        u.FirstName = con.firstName;
        u.LastName = con.lastName;
        u.Date_ToU_accepted__c = system.Now();//TF - Accept Terms
        u.ToU_accepted__c = true;//TF - Accept Terms
        String thisNickname;
        if (con.lastName.length() > 3)
            thisNickname = con.lastName.substring(0,3)+Datetime.now().formatLong();
        else
            thisNickname = con.lastName+Datetime.now().formatLong();
        system.debug('NICKNAME 1: ' + thisNickname);
        system.debug('NICKNAME 1 length: ' + thisNickname.length());
        if (thisNickname.length() > 40){
            system.debug('more than 40');
            thisNickname = thisNickname.left(40);
        }
        else{
            system.debug('not more than 40');
            thisNickname = thisNickname;
        }
        system.debug('NICKNAME 2: ' + thisNickname);
        system.debug('NICKNAME 2 length: ' + thisNickname.length());
        u.CommunityNickname = thisNickname;
        system.debug('selectedCustomerType: ' + selectedCustomerType);
        string profileName = '';
          
        /*string profileName = community == ISSP ? ISSP_Constant.profilNameByUserTypeMap.get('User').get(selectedCustomerType) : 
                              custmPortalPerIec.get(selectedCustomerType) <> null ?  ISSP_Constant.profilNameByUserTypeMap.get('User').get(custmPortalPerIec.get(selectedCustomerType)) : 
                              ISSP_Constant.profilNameByUserTypeMap.get('User').get('OtherCompany');
        */
        if (!con.ID_Cards__r.isEmpty()){
            if (ISSP_Constant.userTypeByAccountRtDeveloperNameMap.containsKey(con.Account.RecordType.DeveloperName)){
                profileName = ISSP_Constant.profilNameByUserTypeMap.get('User').get(ISSP_Constant.userTypeByAccountRtDeveloperNameMap.get(con.Account.RecordType.DeveloperName));
            }
            else{
                profileName = ISSP_Constant.profilNameByUserTypeMap.get('User').get('OtherCompany');
            }
        }
        else{
            profileName = ISSP_Constant.profilNameByUserTypeMap.get('User').get('OtherCompany');
        }
        
        //TF-SP08 - for first agency user, give standard Agency profile
        if (newAgency){
            profileName = ISSP_Constant.profilNameByUserTypeMap.get('User').get('Agency');
        }
        else if (newAirline){
          profileName = ISSP_Constant.profilNameByUserTypeMap.get('User').get('Airline');
        }
        
        if(con.account.Sector__c == TIP_Utils.ACCOUNT_SECTOR_FINANCIAL_INSTITUTION && con.account.Category__c == TIP_Utils.ACCOUNT_CATEGORY_PAYMENT_PROVIDER){
            profileName = ISSP_Constant.profilNameByUserTypeMap.get('Admin').get('Other');
        }
        
        system.debug('profileName: ' + profileName);
        u.ProfileId = ISSP_Constant.profileIdByProfileNameMap.get(profileName);
        system.debug('u.ProfileId: ' + u.ProfileId);
        
        //throw new transformationException('u.ProfileId: ' + u.ProfileId);

        string password;
        
 
        if(con.accountId!=null)
            accountId = con.accountId;
        password = generateRandomString(6) + '1a';
       
        system.debug('u: ' + u);
        system.debug('password: ' + password);
        system.debug('accountId: ' + accountId);
        String link ;
        String cleanUsername = u.userName.replace('+', plusReplacer);

        if(community == ISSP || community == CNS || community == ONEIDENTITY){
            
            if (lang != null && lang != ''){
                system.debug('LANG IN CREATE USER: ' + lang);
                if (!ISSP_Constant.languageMap.containsKey(lang)){
                    lang = 'en_US';
                    system.debug('LANG IN CREATE USER DEFAULT: ' + lang);
                }
                u.languagelocalekey = lang;
            }
    
            userId = Site.createPortalUser(u, accountId, password, false);
            system.debug('USERID: ' + userId);
            if (userId != null) {
            
                String encodedPart = 'c='+EncodingUtil.urlEncode(EncryptString(cleanUsername+SEPARATOR+password+SEPARATOR+UID), 'UTF-8');

                String template ='';
                Map<String,String> emailWrap = new Map<String,String>();

                if(community == ISSP || community == ONEIDENTITY){
                    link = OneIdUtils.getSiteCompleteUrl(OneIdUtils.Mode.IDENTITY) + '/IdentityFirstLogin?' + encodedPart;

                    if(community == ISSP){
                        link += '&serviceName=ISSP';
                        template = 'Identity_Portal_ISSP_New_User';
                    }else{
                      template = 'Identity_Portal_New_User';
                    }

                    emailWrap = Comm_User_Helper.ISSP_PassWordBuilMessageWrapper( con ,  password ,  link,Comm_User_Helper.ONEIDENTITY, community); 

                }else if(community == 'CNS'){
                    link = Site.getBaseUrl()+ '/ISSP_First_Login?communityName=CNS&'+encodedPart;
                    template = 'ISSP_New_Member_Welcome_Email_2_CNS'; 
                    emailWrap = Comm_User_Helper.ISSP_PassWordBuilMessageWrapper( con ,  password ,  link, 'CNS');                   
                }
                Comm_User_Helper.sendEmail( template ,emailWrap, con, community);
                permissionASS(new list<Id>{userId});
            }
        
        }else if(community == IEC){
        
            system.debug('userId: ' + userId);
            userId = Site.createPortalUser(u, accountId,password, false);

            if(test.isRunningTest()){   //insert con;
                                        u.contactid = con.id;
                                        u.emailencodingkey = 'UTF-8';
                                        u.localesidkey = 'en_US';
                                        u.timezonesidkey = 'America/Los_Angeles';
                                        u.languagelocalekey = 'en_US'; 
                                        u.alias = 'cspu';
                                        insert u;
                                        userID =  u.id;}


            string encodedPart ='c='+EncodingUtil.urlEncode(EncryptString(cleanUsername+SEPARATOR+password+SEPARATOR+UID), 'UTF-8');

             link = Site.getBaseUrl()+ '/IECFirstLogin?'+encodedPart;
            
            //TO ask Tiago why not for the ISSP? 
            if (userId != null) {
                permissionASS(new list<Id>{userId});
                Comm_User_Helper.sendEmail( 'IEC_Portal_New_User_Login_Information_English_Text' , Comm_User_Helper.IEC_builMessageWrapper( con ,  password ,  link),  con, community);
            }

        }
        

        return userId;
        
        
         } catch (exception ex) {
             system.debug('kerensen - Site.createPortalUser(u, accountId,null, true):');
       
       transformationHelper.sendSFDevsAlertMessage('error ' ,  '   con  ' +    con +  '   ' +ex.getmessage() + '   '+ ex.getstackTraceString(),  new list<string>{'sfdcadmin@iata.org'});

            return null;
        }
    
    
    }
    





    public static  Map<String, String> IEC_builMessageWrapper(contact con , string password , string link){
        Map<String, String> mapBodyParamsIssp = new map<String,String>{

           '{!Contact.FirstName}' =>con.Firstname,
            '{!Community_URL}' => link,
            '{!Contact.Password}' => password,
            '{!Contact.Email}' => con.Email


        };

        return mapBodyParamsIssp;
  
                

    }


    // OneIdEnh CSP-ID002: entry point for older methods without service name
    public static  Map<String, String> ISSP_PassWordBuilMessageWrapper(contact con , string password , string link, String commName) {
        return ISSP_PassWordBuilMessageWrapper(con, password, link, commName, '');
    }
    
    public static  Map<String, String> ISSP_PassWordBuilMessageWrapper(contact con , string password , string link, String commName, string serviceName){
      String portalName = 'IATA';
      if(commName =='CNS'){portalName='CNS';}

        // OneIdEnh CSP-ID002: set OneId/ISSP specific values
        String imageURL = Label.OneId_Email_Header_Identity;   // OneId default header image URL
        String communityName = commName;
        if(commName == ONEIDENTITY) {
            // Get header image based on the service name
            String headerImgName = 'OneIdentity_Email_Header' + ((serviceName == '')? '': ('_' + serviceName));
            list<Document> doc = [Select id, Name, SystemModStamp From Document Where DeveloperName = :headerImgName];
            if(doc.size() > 0)
                // Build the header image URL from the document information
              imageURL = URL.getSalesforceBaseUrl().getProtocol()+'://'+System.URL.getSalesforceBaseUrl().getHost().remove('-api' )+'/servlet/servlet.ImageServer?id='+doc[0].id+'&oid='+userinfo.getorganizationid();            
            // If there is a service name, that should determine the community name
            if(!String.isBlank(serviceName)) commName = serviceName;
            else communityName = 'Identity';
        }
        if(commName != ONEIDENTITY) communityName = portalName + ' Customer Portal';

        Map<String, String> mapBodyParamsIssp = new map<String,String>{

            '{!Contact.Salutation}' => con.Salutation,
            '{!Contact.Password}' => password,
            '{!Receiving_User.FirstName}' =>con.Firstname,
            '{!Receiving_User.LastName}' => con.LastName,
            '{!Receiving_User.Email}' => con.Email,
            '{!Community_Name}' => communityName,
            '{!Community_Url}' => link, 
            '{!Community_Header}' => imageURL,
            '{!$Label.ISSP_Email_Here}' => 'here',
            '{!$Label.ISSP_Email_do_not_reply}' => Label.ISSP_Email_do_not_reply,
            '{!$Label.OneId_IATA_represent_lead_and_serve_the_airline_industry}' => Label.OneId_IATA_represent_lead_and_serve_the_airline_industry
        };
            
        return mapBodyParamsIssp;
    }
    
    public static void sendEmail( string emailTemplateDeveloperName , Map<String, String> mapBodyParamsIssp, Contact con, String commName){
       try{ 
        sendEmail( emailTemplateDeveloperName , mapBodyParamsIssp, con, false, commName);
        
        
               } catch (exception ex) {
       
       transformationHelper.sendSFDevsAlertMessage('error ' ,  '   con  ' +    con +  '   ' +ex.getmessage() + '   '+ ex.getstackTraceString(),  new list<string>{'sfdcadmin@iata.org'});

        }
    }

    public static void sendEmail( string emailTemplateDeveloperName , Map<String, String> mapBodyParamsIssp, Contact con, Boolean bccCS, String commName){
        try{

        EmailMessageWrapper ew;
        String noreplyemail= 'noreply@iata.org';
        if(commName == null) commName='';
        if(commName.contains('CNS') ){ noreplyemail ='cns_noreply@cnsc.us'; }

        if (bccCS){
            String bccEmail = UserInfo.getUserEmail();
            system.debug('bccEmail: ' + bccEmail);
            ew = new EmailMessageWrapper( noreplyemail,
                                            con.Email,
                                            null,
                                            bccEmail,
                                            null,
                                            new map<string,string>(),
                                            null,
                                            mapBodyParamsIssp
                                            );
        }
        else{
            
            ew = new EmailMessageWrapper( noreplyemail,
                                            con.Email,
                                            null,
                                            null,
                                            null,
                                            new map<string,string>(),
                                            null,
                                            mapBodyParamsIssp
                                            );
        }
        
        List <User> userList = [SELECT Id FROM User WHERE ContactId = :con.Id AND UserType = 'PowerPartner'];
        if (!userList.isEmpty()){
          system.debug('SENDING MAIL TO USER');
          EmailMessageWrapper.sendEmail(new List<EmailMessageWrapper>{ew},emailTemplateDeveloperName, userList[0].Id, commName);
        }
        else{
          system.debug('SENDING MAIL TO ADDRESS');
          EmailMessageWrapper.sendEmail(new List<EmailMessageWrapper>{ew},emailTemplateDeveloperName, commName);
        }
        
    } catch (exception ex) {
       
       transformationHelper.sendSFDevsAlertMessage('error ' ,  '   con  ' +    con +  '   ' +ex.getmessage() + '   '+ ex.getstackTraceString(),  new list<string>{'sfdcadmin@iata.org'});

        }
            
    }
    
    //ISS_Portal
    //ISS_Portal_Airline_User
    @Future 
    public static void permissionASS(list<Id> USersID){
    
      permissionASSNotFuture(USersID);
    }


   //ISS_Portal
    //ISS_Portal_Airline_User
   
    public static void permissionASSNotFuture(list<Id> USersID){
    
    try { 
    
     for(Id userID :USersID)
     if (userId != null) {
                // assign Permission Set to provide access to objects
                Id permissionSetId = IECUserManager.getCustomerPermissionSetId();
                if (permissionSetId != null) {
                    PermissionSetAssignment oPermissionSetAssignment = new PermissionSetAssignment();
                    oPermissionSetAssignment.AssigneeId = userId;
                    oPermissionSetAssignment.PermissionSetId = permissionSetId;
                    insert oPermissionSetAssignment;
                }
        }
        
         } catch (exception ex) {
             system.debug('kerensen - Site.createPortalUser(u, accountId,null, true):');
       
           //TransformationHelper.sendSFDevsAlertMessage('USersID   ' +USersID  + '     ' + ex.getMessage(),'' +' ' + ex.getMessage() + '   ' + ex.getStackTraceString() , new list<string>{'sfdcadmin@iata.org'});
        }
    
    }




    
    
    public static list<User> getUserListByNameOrEmail(String nameOrEmail) {
       try{ return
            [SELECT Id, Username ,Email,IsActive, contactid, contact.email, userType
               FROM User 
              WHERE (Username=: nameOrEmail 
                 OR email =: nameOrEmail)
                 AND IsActive = true and usertype = 'PowerPartner'
                 limit 1];
                 
         } catch (exception ex) {
       
       transformationHelper.sendSFDevsAlertMessage('error ' ,  '   nameOrEmail' +    nameOrEmail+  '   ' +ex.getmessage() + '   '+ ex.getstackTraceString(),  new list<string>{'sfdcadmin@iata.org'});
        throw new transformationException(ex );
        }         
                 
    }
    
   public static list<User> getUserListByNameOrEmail2(String nameOrEmail) {
       try{ return
        [SELECT Id, Username ,Email,IsActive, contactid, contact.email, userType, Portal_User_Frozen_Checkbox__c
           FROM User 
          WHERE (Username=: nameOrEmail 
           OR email =: nameOrEmail)
           AND (IsActive = true OR Portal_User_Frozen_Checkbox__c = true) and usertype = 'PowerPartner'
           limit 1];
           
       } catch (exception ex) {
       
       transformationHelper.sendSFDevsAlertMessage('error ' ,  '   nameOrEmail' +    nameOrEmail+  '   ' +ex.getmessage() + '   '+ ex.getstackTraceString(),  new list<string>{'sfdcadmin@iata.org'});
      throw new transformationException(ex );
      }         
           
    }




   webService static boolean resetPasswordComm(Id contactId, string Community, Boolean bccCS) {
          
        try {
            system.debug('resetPasswordComm bccCS: ' + bccCS);
            string email = [SELECT ID,EMAIL FROM User WHERE contactid =: contactId][0].email;
            // throw new TransformationException(' ' + email);
            return (Comm_User_Helper.resetPassword( email, Community, bccCS));

        }
        catch (Exception ex) {
                
            system.debug(' ' + +ex.getmessage() + '   '+ ex.getstackTraceString());
             transformationHelper.sendSFDevsAlertMessage('error', '   contactId  ' +  contactID    +ex.getmessage() + '   ' + ex.getstackTraceString(),  new list<string>{'sfdcadmin@iata.org'});
            return false;
        } 
    }
   
   webService static boolean resetPasswordISSPContact(Id contactId) {
          
        try {
                  string email = [SELECT ID,EMAIL FROM User WHERE contactid =: contactId][0].email;
                 // throw new TransformationException(' ' + email);
                  return (Comm_User_Helper.resetPassword( email,  ISSP));

           }catch (Exception ex) {
                system.debug(' ' + +ex.getmessage() + '   '+ ex.getstackTraceString());
                      
              transformationHelper.sendSFDevsAlertMessage('error', '  contactId ' +   contactId   +'   '   +ex.getmessage() + '   '+ ex.getstackTraceString(),  new list<string>{'sfdcadmin@iata.org'});
              return false;
                    
                
            } 
    }
   /**
     * Reset a user's password by its email
     */
    public static boolean resetPassword(String email, string Community) {
       try {  return resetPassword(email, Community, false);
          }catch (Exception ex) {
      //throw new TransformationException(' ' + +ex.getmessage() + '   '+ ex.getstackTraceString());
              
       transformationHelper.sendSFDevsAlertMessage('error', '   ' +ex.getmessage() + '   '+ ex.getstackTraceString(),  new list<string>{'sfdcadmin@iata.org'});
      return false;
            
        }
    }
    
    
    // OneIdEnh CSP-ID002: entry point for older methods without service name
    public static boolean resetPassword(String email, string Community, Boolean bccCS) {
        return resetPassword(email, Community, bccCs, '');
    }
     
    // OneIdEnh CSP-ID002: new entry point with service name
    public static boolean resetPassword(String email, string Community, Boolean bccCS, string serviceName) {
        //site.
        try {   
            String template;
            String link;
            Map<String,String> emailWrap = new Map<String,String>();
            // first check if the provided email is valid (associated to a User)
            system.debug('resetPassword email: ' + email);
            List<User> users = [Select u.Username,u.firstName, u.Id, u.Email, u.IsActive , u.ContactID, U.UID__c
                                    From User u 
                                    where (u.Email = :email )
                                    and (IsActive = true OR Portal_User_Frozen_Checkbox__c = true)
                                    and ContactID != ''];
      system.debug('resetPassword users: ' + users);
            if (users == null || users.size() == 0)
                throw new IECApplicationException(email + ' is not a valid email for existing users');
                
            // reset the password by the username found from the email
            User u = users.get(0);
            string UID = NewGuid();
            u.uid__c = UID;
            string password = generateRandomString(6)+'1a';
            system.setPassword(u.ID, password); 

            update u;
           // updateUsersGUID (u.id);
            contact con = [SELECT Id,Email, firstName, LastName,Salutation FROM Contact WHERE ID =: u.contactid limit 1];

            //string separator = '@#@#@#';
            String cleanUsername = u.userName.replace('+', plusReplacer);
            string encodedPart ='c='+EncodingUtil.urlEncode(EncryptString(cleanUsername+SEPARATOR+password+SEPARATOR+UID), 'UTF-8');
      

            if(Community == IEC){

                 template = 'IEC_Portal_Reset_Password_in_Customer_Portal_English_Text' ;
           
                
                  string prefix = Site.getBaseUrl() == null || Site.getBaseUrl() == '' ? 'https://' + String.ValueOF(ISSP_CS__c.getValues('HostIEC').value__c)+'/iec' : Site.getBaseUrl();
                  link = prefix + '/IECFirstLogin?'+encodedPart;
                            

                 emailWrap = Comm_User_Helper.IEC_builMessageWrapper( con ,  password ,  link);

              }else if(Community == ISSP){
                  string prefix = OneIdUtils.getSiteCompleteUrl(OneIdUtils.Mode.IDENTITY);
                  link = prefix + '/IdentityFirstLogin?serviceName=ISSP&'+encodedPart;
                  template = 'Communities_Forgot_Password_Email3';
                  emailWrap = Comm_User_Helper.ISSP_PassWordBuilMessageWrapper( con ,  password ,  link, 'ISSP');
              }else if(Community.contains('CNS')){
                  string prefix = Site.getBaseUrl() == null || Site.getBaseUrl() == '' ? 'https://' + String.ValueOF(ISSP_CS__c.getValues('Host').value__c) : Site.getBaseUrl();
                  link = prefix + '/ISSP_First_Login?CommunityName=CNS&'+encodedPart;
                  template = 'Communities_Forgot_Password_Email3_CNS';
                  emailWrap = Comm_User_Helper.ISSP_PassWordBuilMessageWrapper( con ,  password ,  link, 'CNS');
              }
              else if(Community == ONEIDENTITY) {
                  system.debug('prepare email body for: ' + ONEIDENTITY);
                  string prefix = OneIdUtils.getSiteCompleteUrl(OneIdUtils.Mode.IDENTITY);
                  String serviceNameParam = String.isNotEmpty(serviceName) ? '&serviceName='+serviceName : '';
                  link = prefix + '/IdentityFirstLogin?'+encodedPart+serviceNameParam;
                  if(serviceName == ISSP){
                    template = 'Identity_Changed_ISSP_Password_Email_Custom';
                  }else{
                    template = 'Identity_Changed_Password_Email_Custom';
                  }
                
                  // OneIdEnh CSP-ID002: Added service name to method call
                  emailWrap = Comm_User_Helper.ISSP_PassWordBuilMessageWrapper( con ,  password ,  link, ONEIDENTITY, ServiceName);
              }

              system.debug('template used in email: '+template);
                Comm_User_Helper.sendEmail( template ,emailWrap, con, bccCS, Community);

           
            return true;
        }catch (Exception ex) {
      //throw new TransformationException(' ' + +ex.getmessage() + '   '+ ex.getstackTraceString());
              
       transformationHelper.sendSFDevsAlertMessage('error', '   String email, string Community, Boolean bccCS ' + '   '+ email+ '   '+ Community+ '   '+ bccCS +ex.getmessage() + '   '+ ex.getstackTraceString(),  new list<string>{'sfdcadmin@iata.org'});
      return false;
            
        }
    } 


      @future
      public static void updateUsersGUID(id UsersID){
         try{  
            user us = [Select Id, Username, LastLoginDate,UID__c from user where id =:UsersID  ];     
            us.uid__c ='';
            update us;  
            
                           } catch (exception ex) {
       
       transformationHelper.sendSFDevsAlertMessage('error ' ,  '   UsersID ' +    UsersID   +  '   ' +ex.getmessage() + '   '+ ex.getstackTraceString(),  new list<string>{'sfdcadmin@iata.org'});

        }
      }

    /**
     * Generates a new GUID
     * @return A new GUID as a string
     */
    public static String NewGuid() {

        String kHexChars = '0123456789abcdef';
        String returnValue = '';
        Integer nextByte = 0;

        for (Integer i=0; i<16; i++) {

            if (i==4 || i==6 || i==8 || i==10) 
                returnValue += '-';

            nextByte = (Math.round(Math.random() * 255)-128) & 255;

            if (i==6) {
                nextByte = nextByte & 15;
                nextByte = nextByte | (4 << 4);
            }

            if (i==8) {
                nextByte = nextByte & 63;
                nextByte = nextByte | 128;
            }

            returnValue += getCharAtIndex(kHexChars, nextByte >> 4);
            returnValue += getCharAtIndex(kHexChars, nextByte & 15);
        }

        return returnValue;
    }


  private static String getCharAtIndex(String str, Integer index){
        if (str == null) 
            return null;

        if (str.length() <= 0) 
            return str;    

        if (index == str.length()) 
            return null;    

        return str.substring(index, index+1);
    }    
}