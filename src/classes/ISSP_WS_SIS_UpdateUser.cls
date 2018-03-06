global with sharing class ISSP_WS_SIS_UpdateUser {

    public static final map<String,String> MAP_USER_TYPES = ISSP_WS_SIS_Common.MAP_USER_TYPES;
    public static final set<String> VALID_REQUEST_TYPES = ISSP_WS_SIS_Common.VALID_REQUEST_TYPES;
    
    global class InputData {
        WebService String FederationID;
        WebService String SISMemberID;
        WebService String UserType;
        WebService String TypeOfService;
        WebService String RequestType;
    }

    global class ResponseData {
        WebService Boolean IsSuccess;
        WebService String FederationID;
        WebService String ErrorCode;
        WebService String ErrorDescription;
    }

    /**
        Webservice call to update a portal user
    **/
    WebService static ResponseData UpdateUser(InputData inputData) {
        Savepoint sPointContact = Database.setSavepoint();
        try {
            validateInputData(inputData);
            User user = updateSISUser(inputData);
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
            System.debug(e.getStackTraceString());
            //Return an Error Response
            ISSP_WS_SIS_Common.WSException wsException = new ISSP_WS_SIS_Common.WSException('001','Exception not handled');
            return createResponseError(inputData, wsException);
        }
    }
    
    private static void validateInputData(InputData inputData) {
        if (String.isBlank(inputData.FederationID)) {
            throw new ISSP_WS_SIS_Common.WSException('021',''); //new error
        }
        if (String.isBlank(inputData.SISMemberID)) {
            throw new ISSP_WS_SIS_Common.WSException('018',''); //new error
        }
        if (!MAP_USER_TYPES.containsKey(inputData.UserType)) {
            throw new ISSP_WS_SIS_Common.WSException('020',''); //new error
        }
        if (inputData.TypeOfService != 'SIS') {
            throw new ISSP_WS_SIS_Common.WSException('010','');
        }
        if (!VALID_REQUEST_TYPES.contains(inputData.RequestType)) {
            throw new ISSP_WS_SIS_Common.WSException('022',''); // new error, invalid Request Type
        }
    }
    
    /**
        Main method to udpate a user
        1. First search for a User with the incoming FederationId
        2. if found check the related contact to that user and grant access to SIS application
        3. Return a success response
    **/
    private static User updateSISUser(InputData inputData) {
        list<User> listUser = [
            SELECT Id, FederationIdentifier,
                Contact.Id ,
                Contact.User_Portal_Status__c,
                Contact.Status__c,
                Contact.SIS_Contact_Type__c,
                Contact.Account.SIS_ID__c,
                Contact.Community__c
            FROM User
            WHERE FederationIdentifier = :inputData.FederationID ];
        if (listUser.isEmpty()) {
            throw new ISSP_WS_SIS_Common.WSException('011','');
        }
        User theUser = listUser[0];
        Contact theContact = theUser.Contact;
        if (theContact == null) {
            throw new ISSP_WS_SIS_Common.WSException('013', '');
        }
        
        updateSISContact(theContact, inputData.SISMemberID, inputData.UserType);
        ISSP_WS_SIS_Common.grantAccessToSIS(theContact);
        
        return theUser;
    }
    
    public static void updateSISContact(Contact contact, String SISMemberID, String UserType) {
        Boolean updateContact = false;
        // Check SIS_ID__c = SISmemberId
        if (SISMemberID != contact.Account.SIS_ID__c) { // or contact SIS ID
            throw new ISSP_WS_SIS_Common.WSException('024',''); // new error
        }
        //check if contact is active
        if (contact.User_Portal_Status__c == 'Rejected'
            || contact.User_Portal_Status__c == 'Inactive'
            || contact.Status__c != 'Active') {
            throw new ISSP_WS_SIS_Common.WSException('015', '');
        }
        // set the contact as an approved user 
        if (contact.User_Portal_Status__c == ISSP_Constant.NEW_CONTACT_STATUS){
            contact.User_Portal_Status__c = ISSP_Constant.APPROVED_CONTACT_STATUS;
            updateContact = true;
        }
        // set the Contact type i
        String contactType = MAP_USER_TYPES.get(UserType);
        if (contact.SIS_Contact_Type__c != contactType) {
            contact.SIS_Contact_Type__c = contactType;
            updateContact = true;
        }
        if (contact.Community__c!='ISS Customer Portal') {
            contact.Community__c = 'ISS Customer Portal';
            updateContact = true;
        }
        // update contact if required
        if (updateContact) {
            try{
                ISSP_UserTriggerHandler.preventSISIntegration = true;
                update contact;
            } catch (Exception e){
                throw new ISSP_WS_SIS_Common.WSException('001', 'Contact update failed; ' + e.getMessage());
            }
        }
    }
    
    /**
        Creates the response object for UpdateUser WS when it is success
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
        Creates the response object for UpdateUser WS when it has an error
    **/
    private static ResponseData createResponseError(InputData inputData, ISSP_WS_SIS_Common.WSException wsException) {
        insertErrorLog(inputData, wsException);
        ResponseData response = new ResponseData();
        response.IsSuccess = false;
        response.FederationID = ''; // add this info here?
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
        log.Web_Service__c = 'ISSP_WS_SIS_UpdateUser';
        log.Method__c = 'updateSISUser';
        log.System__c = inputData.TypeOfService;
        log.Login_Ip__c = ISSP_WS_SIS_Common.getLoginIP();
        log.Input_Description__c = 'User Id: ' + UserInfo.getUsername() + '\n';
        log.Input_Description__c +='FederationID' + inputData.FederationID + '\n';
        log.Input_Description__c +='SISMemberID' + inputData.SISMemberID + '\n';
        log.Input_Description__c +='UserType' + inputData.UserType + '\n';
        log.Input_Description__c +='TypeOfService' + inputData.TypeOfService + '\n';
        log.Input_Description__c +='RequestType' + inputData.RequestType + '\n';
        log.Finished__c = system.now();
        return log;
    }
}