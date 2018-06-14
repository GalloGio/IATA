public without sharing class IECUserManager {
    public static User CurrentUser {
        get {
            return ((Test.isRunningTest())
                ? ((CurrentUser == null)
                    ? (CurrentUser = IECTestUtil.createSampleGuestUserAndLogin())
                    : CurrentUser)
                : getUser(UserInfo.getUserId())
                );
        } set;
    }

    /**
     * Returns True if the user type is not Guest
     */
    public static Boolean isUserLoggedIn() {
        return (UserInfo.getUserType() == 'PowerPartner');
    }
    
    /**
     * Returns the ClientType of a customer based on his Account
     * @return A clientType (Member Airline) or null
     */
    public static String getClientType() {
        if (!isUserLoggedIn())
            return null;

        IECCustomer oCurrentCustomer = IECCustomer.getCurrentIECCustomer();
        if (oCurrentCustomer != null)
            return oCurrentCustomer.ClientType;
        else
            return null;
    }
    
    /**
     * Returns the Contact Id of the Active user
     */
    public static Id getContactId() {
        if (isUserLoggedIn()) {
            User curUser = getUser(UserInfo.getUserId());
            
            return curUser.ContactId;
        }
        else
            return null;
    }
    
    /**
     * Returns the Contact of the Active user
     */
    public static Contact getContact() {
        if (isUserLoggedIn()) {
            User curUser = getUser(UserInfo.getUserId());
            
            if (curUser.ContactId == null)
                return null;
                
            return getContactById(curUser.ContactId);
        }
        else
            return null;
    }
    
    /**
     * Logs in the user and return a pagereference to where the user should be heading
     */
    public static Pagereference login(String sUsername, String sPassword, String sReturnUrl) {

        System.debug('IECUserManager.login start');
        System.debug('sUsername: ' + sUsername + ', sReturnUrl: ' + sReturnUrl);

     try{   


      //list<User> userList = Comm_User_Helper.getUserListByNameOrEmail(sUsername);
      list<User> userList = Comm_User_Helper.getUserListByNameOrEmail2(sUsername);
       
       if(userList == null || userlist.size() == 0) {
        
        Pagereference pr = Page.IEC_Home;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Could not find any Contact with username ' + sUsername));

        System.debug('IECUserManager.login end');

        return null;
       }
        
        //EM: Need to reactivate the user 
        else if (userList.size() == 1 && userList[0].Portal_User_Frozen_Checkbox__c == true) {
                Pagereference pr = Page.IEC_Home;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_Frozen_User_Alert_Message)); 
                reactivateUser(userList[0].UserName);

                System.debug('IECUserManager.login end');

                return null;
       }

        boolean firstLogin = false;
          
        list<User> users = [Select Id, Username, LastLoginDate, uid__C from user where( username =:suserName or email =: suserName) and userType = 'PowerPartner' and LastLoginDate = null ];    
        IF( (users <> null && users.size()>0))
            firstLogin = true;
        //firstLogin = users[0].uid__C <> null ? true: false;
         
            //sReturnUrl = firstLogin ?  Site.getBaseUrl()+ '/IECChangePassword' :sReturnUrl ;
        sReturnUrl = firstLogin ?  '/IEC_ChangePassword?returl='+sReturnUrl :sReturnUrl ;

        sUsername = userList[0].username;
        Pagereference pr = Site.login(sUsername, sPassword, sReturnUrl);
        //Pagereference pr = Site.login(sUsername, sPassword, (firstLogin ? '/IECChangePassword': null));
           //throw new transformationException(' USERS ' + users);

        // check if SalesForce is redirecting the customer to the Change password page
      if(firstLogin ){
          System.debug('IECUserManager.login end');

              return pr;

        }  
        else if (pr != null) {
          return notFirstLogin(pr, sUsername, userList[0].ContactId);
        }
        else {
          System.debug('IECUserManager.login end');

            return null;
        }
        
     } catch (exception ex) {
       // String , String sPassword, String sReturnUrl

       transformationHelper.sendSFDevsAlertMessage('error ' ,   '   sReturnUrl' +    sReturnUrl+ '   sUsername' +    sUsername  +  '   ' +ex.getmessage() + '   '+ ex.getstackTraceString(),  new list<string>{'sfdcadmin@iata.org'});

            System.debug('IECUserManager.login end');

            return null;
        }
    }


    @testVisible
    private static PageReference notFirstLogin(PageReference pr, String sUsername, Id partnerContactId) {
      // get the contact that has just logged in
      Contact c = null;
      Id contactId = getContactIdFromUsername(sUsername);

        if (contactId == null) {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Could not find any Contact with username ' + sUsername));

            if (IEC_Functionality.getInstance().isActive('New Shopping Cart')) {
              System.debug('IECUserManager.login for New Shopping Cart');

              List<Contact> partnerContactList = [SELECT Id FROM Contact WHERE Email = :sUsername];

              if (partnerContactList.isEmpty() == false) {
                partnerContactId = partnerContactList[0].Id;
              }                  

              if (partnerContactId != null) {
                IEC_Cart storeCart = IEC_Cart.getInstance();
                List<IEC_Cart.CartItem> cartContent = storeCart.getCartContent();

                Customer_DTO.setLoginEvent(partnerContactId);
                
                storeCart.loginUserEvent();

              }

              System.debug('IECUserManager.login after login user event');
            }

            System.debug('IECUserManager.login end');

            return pr;
        }

        System.debug('additional cart stuff (original)');

        // check if user has an anonymous shopping cart (assigned with GUID)
        IEC_Shopping_Cart__c anonymousCart = IECShoppingCartHelper.getShoppingCartByGUID(IECCookieHelper.getCartGuid());
        if (anonymousCart != null)
            system.debug('ALEX - anonymousCart id: ' + anonymousCart.Id);

        // check if user previously had a shopping cart associated to its Contact
        IEC_Shopping_Cart__c contactCart = IECShoppingCartHelper.getShoppingCartsByContactID(/*c.Id*/(String)contactId);
        if (contactCart != null) 
            system.debug('ALEX - contactCart id: ' + contactCart.Id);
        
        // if contact has an anonymous cart
        if (anonymousCart != null) {
            
            // if contact didnt have a cart previously
            if (contactCart == null) {
                IECShoppingCartHelper.associateContactWithCart(anonymousCart, /*c.Id*/(String)contactId);
            }
            else {
                // merge carts !
                IECShoppingCartHelper.mergeCarts(contactCart, anonymousCart);
            }
            
            // delete the shopping cookie, since the user is logged in now
            IECCookieHelper.deleteShoppingCartCookie();
        }
        
        System.debug('IECUserManager.login end');

        return pr;
    }



     public static void reactivateUser(String username){
      //show90Days = false;
      system.debug('checkDays: ' + username);
      list<User> userList = Comm_User_Helper.getUserListByNameOrEmail2(username);
      system.debug('userList: ' + userList);
        if(!userList.isEmpty()) {
          try{
            userList[0].IsActive = true;
            userList[0].Portal_User_Frozen_Checkbox__c = false;
            update userList[0];
            Boolean success = Comm_User_Helper.resetPassword(userList[0].email, Comm_User_Helper.IEC, false);
          }
          catch (Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
          //return null;
          }
          //reactivateContact(userList[0].ContactId);
        }
        //return null;
    }

    @future 
    public static void reactivateContact(string contactId) {
      List <Contact> contactList = [SELECT Id, Portal_User_Frozen__c FROM Contact WHERE Id = :contactId];
      if (!contactList.isEmpty()){
        contactList[0].Portal_User_Frozen__c = false;
        update contactList[0];
      }
    }
    
  /**
     * Reset a user's password by its email
     */
    public static Boolean resetPassword(String email) {
        try {
            // first check if the provided email is valid (associated to a User)
          //  List<User> users = [Select u.Username, u.Id, u.Email, u.IsActive From User u where u.Email = :email and IsActive = : true];
            
            list<User> users = Comm_User_Helper.getUserListByNameOrEmail(email);
            
            
            
            if (users == null || users.size() == 0)
                throw new IECApplicationException(email + ' is not a valid email for existing users');
                
            // reset the password by the username found from the email
            User u = users.get(0);
            Comm_User_Helper.resetPassword( email,Comm_User_Helper.IEC);
           // Site.forgotPassword(u.Username);
            
            return true;
        }
        catch (Exception ex) {
             //   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
             //   return false;
           throw ex;
        }
    }
    
    /**
     * Checks if a User already exist by checkin its username
     */
    public static Boolean userAlreadyExists(String username) {
        
        List<User> users = [Select u.Username From User u where u.Email = :username];
        return (users != null && users.size() > 0);
    }
    
    
    /**
     * Returns the Account Record Type ID based on its name to use when creating accounts for the project IEC 
     */
    public static Id getAccountRecordTypeByName(String recordTypeName) {
        
        List<RecordType> recordTypes = [Select r.Name, r.Id, r.DeveloperName From RecordType r where r.DeveloperName  = :recordTypeName and SobjectType = 'Account'];
        if (recordTypes != null && recordTypes.size() > 0)
            return recordTypes.get(0).Id;
            
        return null;
    }
        
    /**
     * Returns the Account Record Type ID to use when creating accounts for the project IEC
     */
    public static Id getAccountRecordTypeForIEC() {
        return getAccountRecordTypeForIEC(IECConstants.Account_ClientType_ThirdParty);
    }
    public static Id getAccountRecordTypeForIEC(String sClientType) {
        
        String recordTypeName = null;
        
        if (sClientType == IECConstants.Account_ClientType_MemberAirline)
            recordTypeName = IECConstants.Account_RecordType_Airline;
        else if (sClientType == IECConstants.Account_ClientType_ThirdParty)
            recordTypeName = IECConstants.Account_RecordType_Standard;
        else 
            recordTypeName = IECConstants.Account_RecordType_Others;
        
        List<RecordType> recordTypes = [Select r.Name, r.Id, r.DeveloperName From RecordType r where r.DeveloperName = :recordTypeName and SobjectType = 'Account'];
        return recordTypes.get(0).Id;
    }
    
    /**
     * Returns the Contact Record Type ID to use when creating contacts for the project IEC
     */
    public static Id getContactRecordTypeForIEC() {
        
        // TODO: to change once the ISS portal/registration is done
        String recordTypeName = 'Standard'; //'GDP Contact'; //'IATA Standard Contact'
        List<RecordType> recordTypes = [Select r.Name, r.Id From RecordType r where r.Name = :recordTypeName and r.SobjectType = 'Contact'];
        return recordTypes.get(0).Id;
    }
    
    /**
     * Returns the OwnerId that must be associated to newly created Accounts
     * TODO: maybe this should be configured somewhere else
     */
    public static Id getIECAccountOwnerId() {
                       
        if (!Test.isRunningTest())
            return IEC_Settings__c.getOrgDefaults().Account_Owner_Id__c; //worst coding practices ever........
        else
            return '00520000002MSDBAA4'; //worst coding practices ever........
    }
    
    /**
     * Returns the OwnerId that must be associated to newly created Contacts
     * TODO: maybe this should be configured somewhere else
     */
    public static Id getIECContactOwnerId() {

        if (!Test.isRunningTest())//worst coding practices ever........
            return IEC_Settings__c.getOrgDefaults().Contact_Owner_Id__c; //worst coding practices ever........
        else
            return '00520000002MSDBAA4'; //worst coding practices ever........
    }
    
    /**
     * Returns the PermissionSet Id to assign to IEC Customer
     */
    public static Id getCustomerPermissionSetId() { //worst coding practices ever........

        if (!Test.isRunningTest())//worst coding practices ever........
            return IEC_Settings__c.getOrgDefaults().Customer_Permission_Set_Id__c; //worst coding practices ever........
        else
            return '0PSw00000004pLP'; //worst coding practices ever........
    }
    
    /**
     * Creates an alias from a user name
     */
    public static String createAliasFromName(String name) {
        if (name.length() <= 8)
            return name;
        else
            return name.substring(0, 7);
    }
    
    /**
     * Returns the Profile ID to use when creating new users for the project IEC
     */
    public static Id getProfileIdForIECUser() {
        
        // TODO: to change once the ISS portal/registration is done
        List<Profile> profiles = [Select p.Name, p.Id From Profile p where p.Name = 'ISS Portal (Partner)']; // salvatore 'IEC GDP Customer'];
        return profiles.get(0).Id;
    }
    
    /**
     * Returns the User object of the currently connected user
     */
    public static User getCurrentUser() {
        if (isUserLoggedIn()) {
            return getUser(UserInfo.getUserId());
        }
        else
            return null;
    }
    
    /**
     * Returns an Account object by Account Id
     */
    public static Account getAccountById(Id accountId) {
        if (accountId != null) {
            return [SELECT Legal_name__c, Name, Agent_Type_Code__c
                , IATA_Area__c, IATACode__c, Status__c, Profit_Center__c
                , CurrencyIsoCode, RecordType.DeveloperName, Industry, Membership_status__c, ParentId, ICH_Member__c
                , Customer_Type__c, Region__c, Services_Rendered_Country__c
                , BillingCountry, Default_Payment_Type__c
                FROM Account
                WHERE Id = :accountId];
        }
        else
            return null;
    }
    
    /**
     * Returns an Contact object by Contact Id
     */
    public static Contact getContactById(Id contactId) {
        if (contactId != null) {
            List<Contact> listContact =
                [Select c.Zuora_Billing_Acount_Id__c, c.Phone, c.MailingStreet, c.MailingState, c.MailingPostalCode, c.MailingCountry, c.MailingCity 
                    , c.LastName, c.Id, c.FirstName, c.Name, c.Salutation, c.Title, c.Membership_Function__c, c.Email, c.AccountId
                    , c.User_IECPortal_Status__c, c.Tax_1_ID__c, c.Tax_2_ID__c, c.VAT_Country_Code__c 
                    , c.Account.Name 
                    , c.Account.ShippingStreet, c.Account.ShippingCity, c.Account.ShippingPostalCode, c.Account.ShippingCountry,c.Account.ShippingState
                    , c.Account.BillingStreet, c.Account.BillingCity, c.Account.BillingPostalCode, c.Account.BillingCountry, c.Account.BillingState
                    , c.BillTo_Location__r.ISO_Country_Code__c, c.ShipTo_Location__r.ISO_Country_Code__c
                    , c.BillTo_Location__r.VAT_Number__c, c.BillTo_Location__r.SAP_Id__c,c.BillTo_Location__c, c.ShipTo_Location__c
                    ,  c.ShipTo_Location__r.SAP_Id__c 
                 From Contact c 
                 where c.ID = :contactId];
            if (listContact.isEmpty())
                return null;
            else
                return listContact.get(0);
        }
        else
            return null;
    }
    
    /**
     * Returns an User object by Contact Id
     */
    public static User getUserByContactId(Id contactId) {
        
        //*** 2015-11-09 Thai: add more fields to results in order to balance with method "getUser" allowing CSR performs things for customer
        //List<User> users = [Select u.Username, u.LastName, u.LanguageLocaleKey, u.FirstName, u.Email, u.ContactId From User u where u.ContactId = :contactId];
        List<User> users = [Select u.Username, u.LastName, u.LanguageLocaleKey, u.FirstName, u.Email, u.ContactId
                                 , u.UserType, u.IsActive, u.AccountId, u.CompanyName, u.Name, u.Id
                            From User u where u.ContactId = :contactId];
        
        if (users == null || users.size() == 0)
            throw new IECApplicationException('No User found for Contact ID ' + contactId);
            
        return users.get(0);
    }
    
    /**
     * Returns a list of IECAddress associated to a Contact
     * @param contactId The Id of the Contact to get the addresses
     * @return A list of IECAddress__c related to the contact
     */
     public static List<IECAddress__c> getAddressByContact(Id contactId) {
        return getAddressByContact(contactId, null);
    }
    
    /**
     * Returns a list of IECAddress associated to a Contact by the Address Type
     * @param contactId The Id of the Contact to get the addresses
     * @param sAddressType Picklist value of the field IECAddress__c.Address_Type__c (Billing or Shipping)
     * @return A list of IECAddress__c related to the contact
     *
     * Edited by Thai (2016-02-26)
     *    Move filter of contact and address to Location object and add ISO fields to returning fields
     */
    public static List<IECAddress__c> getAddressByContact(Id contactId, String sAddressType) {
        
        if (String.isBlank(sAddressType)) {
            return [select Name, Contact__c, Address_Type__c, State__c, Street__c, City__c, Country__c, ZipCode__c 
                         , ISO_Country__c, ISO_Country_Code__c, ISO_Country_Name__c, ISO_State__c, ISO_State_Code__c, ISO_State_Name__c, ISO_State_Code_SAP__c
                    from IECAddress__c 
                    where Id in (select Address__c
                                 from Location__c
                                 where Contact__c = :contactId and Active__c = true
                                   and Type__c in (:IECConstants.IECAddress_AddressType_Billing, :IECConstants.IECAddress_AddressType_Shipping))];
                    //where contact__c =: contactId];
        }
        else {system.debug('### address.....');
           return [select Name, Contact__c, Address_Type__c, State__c, Street__c, City__c, Country__c, ZipCode__c 
                         , ISO_Country__c, ISO_Country_Code__c, ISO_Country_Name__c, ISO_State__c, ISO_State_Code__c, ISO_State_Name__c, ISO_State_Code_SAP__c
                    from IECAddress__c 
                    where Id in (select Address__c
                                 from Location__c
                                 where Contact__c = :contactId and Active__c = true
                                   and Type__c = :sAddressType)];
                    //where contact__c =: contactId
                    //    and Address_Type__c = :sAddressType];
        }
    }
    
    /**
     * Returns true if the specified contact has an IECAddress of the specified type
     * @param contactId The Id of the Contact to get the addresses
     * @param sAddressType Picklist value of the field IECAddress__c.Address_Type__c (Billing or Shipping)
     * @return True if the Contact has one or more addresses
     */
    public static Boolean hasAddress(Id contactId, String sAddressType) {
        List<IECAddress__c> lstAddresses = getAddressByContact(contactId, sAddressType);
        return (lstAddresses != null && lstAddresses.size() > 0);
    }
    
    /**
     * Returns True if the Billing Addres of the specified contact is filled (checks mandatory fields)
     * @param contactId The Id of the Contact to get the addresses
     * @return  True if the Billing Addres of the specified contact is filled
     */
    public static Boolean isBillingAddressFilled(Id contactId) {
        List<IECAddress__c> lstAddresses = getAddressByContact(contactId, IECConstants.IECAddress_AddressType_Billing);
        IECAddress__c oBillingAddress = (lstAddresses.size() > 0 ? lstAddresses.get(0) : null);
        
        if (oBillingAddress != null) {
            
            // Street address, City and Country are mandatory
            Boolean baseInfoFilled = String.isNotBlank(oBillingAddress.Street__c)
                    && String.isNotBlank(oBillingAddress.City__c)
                    && String.isNotBlank(oBillingAddress.ISO_Country__c);  //*** changed by Thai (2016-03-01) from "Country__c"
            
            // State/Province and Zip Code are mandatory for Canada and USA
            if (oBillingAddress.ISO_Country_Code__c == 'CA' || oBillingAddress.ISO_Country_Code__c == 'US') {                      //*** changed by Samy (2016-03-01) from "Country__c"
                return baseInfoFilled
                        && String.isNotBlank(oBillingAddress.ISO_State__c) && String.isNotBlank(oBillingAddress.ZipCode__c);  //*** changed by Thai (2016-03-01) from "State__c"
            }
            else 
                return baseInfoFilled;
        }
        else
            return false;
    }
    
    /**
     * Returns True if the contact information is filled (checks mandatory fields)
     * @param oContact Contact object that will be validated
     * @return True if the Contact Information is filled
     */
    public static Boolean isContactMandatoryFieldsFilled(Contact oContact) {
        return isContactMandatoryFieldsFilled(oContact, null);
    }
    
    /**
     * Returns True if the contact information is filled (checks mandatory fields)
     * @param oContact Contact object that will be validated
     * @param vatConfig VAT Configuration to make sure that VAT info is not missing
     * @return True if the Contact Information is filled
     */
    public static Boolean isContactMandatoryFieldsFilled(Contact oContact, IECVATUtil.VATConfiguration vatConfig) {
        return (String.isNotBlank(oContact.FirstName)
            && String.isNotBlank(oContact.LastName)
            && String.isNotBlank(oContact.Title)
            && String.isNotBlank(oContact.Phone)
            && (vatConfig == null
                || !vatConfig.TaxIDMandatory
                || (vatConfig.TaxIDMandatory
                    && (!vatConfig.ShowTax1
                        || (vatConfig.ShowTax1 && String.isNotBlank(oContact.Tax_1_ID__c))
                        )
                    && (!vatConfig.ShowTax2
                        || (vatConfig.ShowTax2 && String.isNotBlank(oContact.Tax_2_ID__c))
                        )
                    )
                )
            );
    }
    
    /**
     * Returns the User object by User Id
     */
    public static User getUser(Id userId) {
        if (userId != null) {
           /* List<User> listUser = [SELECT UserType, Username, IsActive, AccountId, CompanyName, 
                                    ContactId, Email, FirstName, Name, LastName, Id, Portal_User_Frozen__c
                                    FROM User
                                    WHERE Id = :userId];*/
                                    
            return IECUSerSingleTon.getIECUser(userID);
        }
        else
            return null;
    }
    
    /**
     * Returns all Accounts having a specified IATA code
     * @param sIATACode The IATA code to look for
     * @return A list of Account having the same IATA code
     */
    public static List<Account> getAccountsByIATACode(String sIATACode) {
        return [SELECT Id, Legal_name__c, Name, Agent_Type_Code__c, IATA_Area__c, IATACode__c
                , Status__c, Profit_Center__c, RecordType.DeveloperName, Membership_status__c, ParentId 
                FROM Account
                WHERE IATACode__c = :sIATACode];
    }
    
    /**
     *
     */
    public static Boolean updateContactViaWebService(Contact oContactToUpdate) {
        try {
            
            if (!Test.isRunningTest()) {
            
                // login
                partnerSoapSforceCom.Soap spWs = new partnerSoapSforceCom.Soap();
                spWs.endpoint_x = IEC_Settings__c.getOrgDefaults().SF_Partner_Web_Service_endpoint__c;
                partnerSoapSforceCom.LoginResult loginResult = spWs.login(IEC_Settings__c.getOrgDefaults().IEC_Web_Service_Username__c, IEC_Settings__c.getOrgDefaults().IEC_Web_Service_Password__c);
                
                // call the web service to assign the quote to the opportunity
                soapSforceComSchemasClassIecWebser2.IEC_WebService ws = new soapSforceComSchemasClassIecWebser2.IEC_WebService();
                ws.endpoint_x = IEC_Settings__c.getOrgDefaults().IEC_Web_Service_Endpoint__c;
                ws.SessionHeader = new soapSforceComSchemasClassIecWebser2.SessionHeader_element();
                ws.SessionHeader.sessionId = loginResult.SessionID;
                  
                Boolean bResult = ws.updateContact(oContactToUpdate.Id, 
                                        oContactToUpdate.FirstName, 
                                        oContactToUpdate.LastName, 
                                        oContactToUpdate.Email,
                                        oContactToUpdate.Salutation, 
                                        oContactToUpdate.Title, 
                                        oContactToUpdate.Phone, 
                                        oContactToUpdate.Tax_1_ID__c, 
                                        oContactToUpdate.Tax_2_ID__c, 
                                        oContactToUpdate.VAT_Country_Code__c,            
                                        oContactToUpdate.User_IECPortal_Status__c);
                
                return bResult;
            }
            else {
                update oContactToUpdate;
                return true;
            }
        } 
        catch(Exception ex) {
            system.debug('** IEC USerManager - updateContactViaWebService() exception: ' + ex.getMessage());
            return false;
        }
    }
    
    ////////////////////////////////////////////////////////
    // Private methods

    /**
     * Returns the Contact Id of a User by its username
     */
    @testVisible
    private static Id getContactIdFromUsername(String username) {
            
        List<User> users = [Select u.ContactId From User u where u.Email = :username];
        
        if (users == null || users.isEmpty())
            return null;
            
        return users.get(0).ContactId;
    }

      
}