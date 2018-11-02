global with sharing class ISSP_WS_SIS_NewUser {
    
    public static final Id SIS_ID_PORTAL_APP = ISSP_WS_SIS_Common.SIS_ID_PORTAL_APP;
    public static final map<String,String> MAP_USER_TYPES = ISSP_WS_SIS_Common.MAP_USER_TYPES;

    global class InputData {
        WebService String SISMemberID;
        WebService String FirstName;
        WebService String LastName;
        WebService String EmailAddress;
        WebService String UserType;
        WebService String TypeOfService;
        WebService String Description;
    }
    
    global class ResponseData {
        WebService Boolean IsSuccess;
        WebService String FederationID;
        WebService String ErrorCode;
        WebService String ErrorDescription;
    }
    
    /**
        Webservice call to create portal user
    **/
    WebService static ResponseData newUser(InputData inputData) {
        Savepoint sPointContact = Database.setSavepoint();
        try {
            validateInputData(inputData);
            User user = createSISUser(inputData);
            // Return a Success response
            return createResponseSuccess(inputData,user);

        } catch(ISSP_WS_SIS_Common.WSException e) {
            // rollback all database changes
            Database.rollback(sPointContact);
            //Return an Error Response
            return createResponseError(inputData,e);
        } catch(Exception e) {
            // rollback all database changes
            Database.rollback(sPointContact);
            //Return an Error Response
            System.debug(e.getStackTraceString());
            ISSP_WS_SIS_Common.WSException wsException = new ISSP_WS_SIS_Common.WSException('001','Exception not handled ' + e.getMessage());
            return createResponseError(inputData, wsException);
        }
    }
    
    /**
        check all fields in the incoming data, returns an exception if error found
    **/
    private static void validateInputData(InputData inputData) {
        if (String.isBlank(inputData.SISMemberID)) {
            throw new ISSP_WS_SIS_Common.WSException('018',''); //new error
        }
        if (String.isBlank(inputData.FirstName)) {
            throw new ISSP_WS_SIS_Common.WSException('019',''); //new error
        }
        if (String.isBlank(inputData.LastName)) {
            throw new ISSP_WS_SIS_Common.WSException('003','');
        }
        if (String.isBlank(inputData.EmailAddress)) {
            throw new ISSP_WS_SIS_Common.WSException('002','');
        }
        inputData.EmailAddress = inputData.EmailAddress.trim();
        if (!ISSP_WS_SIS_Common.isValidEmail(inputData.EmailAddress)) {
            throw new ISSP_WS_SIS_Common.WSException('006', '');
        }
        if (String.isBlank(inputData.UserType) || !MAP_USER_TYPES.containsKey(inputData.UserType)) {
            throw new ISSP_WS_SIS_Common.WSException('020',''); //new error
        }
        if (inputData.TypeOfService != 'SIS') {
            throw new ISSP_WS_SIS_Common.WSException('010','');
        }
        //if (inputData.Description == '' || inputData.Description == null) {
        //    throw new ISSP_WS_SIS_Common.WSException('','');
        //}
    }
    
    /**
        Main method to create a new user.
        1. First search for a user with the incoming email
        2. If not found search the contact with the incoming email and creates the portal user for it
        3. Finally grants access (if still don't have it) to the SIS application
        4. Return to SIS the Federation Id code of that user
    **/
    private static User createSISUser(InputData inputData) {
        Boolean isCNS = false;
        
        // Search for parent Account
        list<Account> listAccount = [SELECT Id, SIS_ID__c, Account.RecordType.DeveloperName FROM Account WHERE SIS_Id__c = :inputData.SISMemberID];
        if (listAccount.isEmpty()) {
            throw new ISSP_WS_SIS_Common.WSException('018', '');
        }
        Account theAccount = listAccount[0];
        
        // find the user based on the email
        List <User> listUser = [
            SELECT Id, ContactId, FederationIdentifier, FedContactId__c,
                Contact.Id,
                Contact.Status__c,
                Contact.User_Portal_Status__c,
                Contact.Email,
                Contact.FirstName,
                Contact.LastName,
                Contact.AccountId,
                Contact.Salutation,
                Contact.Preferred_Language__c,
                Contact.SIS_Contact_Type__c,
                Contact.SIS_ID__c,
                Contact.Community__c,
                Contact.Account.SIS_ID__c
            FROM User
            WHERE Email =: inputData.EmailAddress
            AND UserType = 'PowerPartner'
            LIMIT 1];
        
        Contact theContact;
        User theUser;
        
        // if user found then select the contact
        if (!listUser.isEmpty()){
            theUser = listUser[0];
            theContact = theUser.Contact;
            if (theContact == null) {
                throw new ISSP_WS_SIS_Common.WSException('013', '');
            }
        }
        
        // if no contact found try to find it using the email
        if (theContact == null) {
            List <Contact> listContact = [SELECT Id, Email, AccountId, Account.RecordType.DeveloperName,
                                            User_Portal_Status__c, Status__c, FirstName, LastName, Community__c,
                                            Preferred_Language__c, Salutation, SIS_Contact_Type__c, SIS_ID__c,
                                            Account.SIS_ID__c
                                        FROM Contact
                                        WHERE Email = :inputData.EmailAddress];
            
            if (listContact.isEmpty()){
                try {
                    theContact = createNewContact(inputData, theAccount, isCNS);
                } catch (Exception e) {
                    throw new ISSP_WS_SIS_Common.WSException('011', e.getMessage());
                }
            } else {
                theContact = listContact[0];
            }
        }
        
        ISSP_WS_SIS_UpdateUser.updateSISContact(theContact, inputData.SISMemberID, inputData.UserType);
        
        // Create the User if we still haven't found it
        if (theUser == null) {
            theUser = ISSP_WS_Utilities.createUser(inputData.FirstName, inputData.LastName, inputData.EmailAddress, theContact.Account.RecordType.DeveloperName, theContact.Id,isCNS);
            try{
                theUser.FederationIdentifier = String.valueOf(theContact.Id).substring(0, 15);
                insert theUser;
                ISSP_WS_Utilities.sendUserEmail(theUser, theContact);
            } catch (Exception e){
                throw new ISSP_WS_SIS_Common.WSException('001', 'User creation failed; ' + e.getMessage());
            }
        } else {
            if (theUser.FederationIdentifier == null){
                try{
                    theUser.FederationIdentifier = theUser.FedContactId__c;
                    update theUser;
                } catch (Exception e){
                    throw new ISSP_WS_SIS_Common.WSException('001', 'User update failed; ' + e.getMessage());
                }
            }
        }
        ISSP_WS_SIS_Common.grantAccessToSIS(theContact);
        return theUser;
    }
    
    /**
        Creates a new Contact based on input data 
    **/
    private static Contact createNewContact(InputData inputData, Account account, Boolean isCNS) {
        Contact contact = ISSP_WS_Utilities.createContact(inputData.FirstName, inputData.LastName, inputData.EmailAddress, account.Id, isCNS);
        contact.Status__c = 'Active';
        insert contact;
        contact.Account = account;
        return contact;
    }
    
    /**
        Creates the response object for NewUser WS when it is success
    **/
    private static ResponseData createResponseSuccess(InputData inputData, User user) {
        insertSuccessLog(inputData, user);
        ResponseData response = new ResponseData();
        response.IsSuccess = true;
        response.FederationID = user.FederationIdentifier;
        response.ErrorCode = '';
        response.ErrorDescription = '';
        return response;
    }
    
    /**
        Creates the response object for NewUser WS when it has an error
    **/
    private static ResponseData createResponseError(InputData inputData, ISSP_WS_SIS_Common.WSException wsException) {
        insertErrorLog(inputData, wsException);
        ResponseData response = new ResponseData();
        response.IsSuccess = false;
        response.FederationID = '';
        response.ErrorCode = wsException.errorCode;
        response.ErrorDescription = wsException.description;
        return response;
    }
    
    /**
        Creates and inserts a new log with a Success
    **/
    private static void insertSuccessLog(InputData inputData, User user) {
        ISSP_Web_Service_Log__c log = createLog(inputData);
        log.Success__c = true;
        log.Error_Code__c = '';
        log.Error_Message__c = '';
        log.User__c = user.Id;
        log.Contact__c = user.ContactId;
        insert log;
    }
    
    /**
        Creates and inserts a new log with an Error
    **/
    private static void insertErrorLog(InputData inputData, ISSP_WS_SIS_Common.WSException wsException) {
        ISSP_Web_Service_Log__c log = createLog(inputData);
        log.Success__c = false;
        log.Error_Code__c = wsException.errorCode;
        log.Error_Message__c = wsException.description;
        insert log;
    }
    
    /**
        create a basic log object
    **/
    private static ISSP_Web_Service_Log__c createLog(InputData inputData) {
        ISSP_Web_Service_Log__c log = new ISSP_Web_Service_Log__c();
        log.Web_Service__c = 'ISSP_WS_SIS_NewUser';
        log.Method__c = 'newUser';
        log.System__c = inputData.TypeOfService;
        log.Login_Ip__c = ISSP_WS_SIS_Common.getLoginIP();
        log.Input_Description__c = 'User Id: ' + UserInfo.getUsername() + '\n';
        log.Input_Description__c +='SISMemberID: ' + inputData.SISMemberID + '\n';
        log.Input_Description__c +='FirstName: ' + inputData.FirstName + '\n';
        log.Input_Description__c +='LastName: ' + inputData.LastName + '\n';
        log.Input_Description__c +='EmailAddress: ' + inputData.EmailAddress + '\n';
        log.Input_Description__c +='UserType: ' + inputData.UserType + '\n';
        log.Input_Description__c +='TypeOfService: ' + inputData.TypeOfService + '\n';
        log.Input_Description__c +='Description: ' + inputData.Description + '\n';
        log.Finished__c = system.now();
        return log;
    }

}