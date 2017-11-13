global with sharing class ISSP_WS_SIS_ActivateUser {

    public static final Id SIS_ID_PORTAL_APP = ISSP_WS_SIS_Common.SIS_ID_PORTAL_APP;
    
    global class InputData {
        WebService String FederationID;
        WebService String TypeOfService;
    }

    global class ResponseData {
        WebService Boolean IsSuccess;
        WebService String ErrorCode;
        WebService String ErrorDescription;
    }
    
    /**
        Webservice call to grant access to SIS appplication for a portal user
    **/
    WebService static ResponseData ActivateUser(InputData inputData) {
        return changeUserAccess(inputData,true);
    }
    
    /**
        Webservice call to remove access to SIS appplication for a portal user
    **/
    WebService static ResponseData DeactivateUser(InputData inputData) {
        return changeUserAccess(inputData,false);
    }

    /**
        Generic method for grant/remove access used to capture exceptions
    **/
    private static ResponseData changeUserAccess(InputData inputData, Boolean grantAccess) {
        Savepoint sPointContact = Database.setSavepoint();
        try {
            validateInputData(inputData);
            User user = changeAccessSISUser(inputData, grantAccess);
            // Return a Success response
            return createResponseSuccess(inputData,user,grantAccess);

        } catch(ISSP_WS_SIS_Common.WSException e) {
            // rollback all database changes
            Database.rollback(sPointContact);
            //Return an Error Response
            return createResponseError(inputData,e,grantAccess);
        } catch(Exception e) {
            // rollback all database changes
            Database.rollback(sPointContact);
            //Return an Error Response
            ISSP_WS_SIS_Common.WSException wsException = new ISSP_WS_SIS_Common.WSException('001','Exception not handled');
            return createResponseError(inputData, wsException,grantAccess);
        }
    }
    
    /**
        check all fields in the incoming data, returns an exception if error found
    **/
    private static void validateInputData(InputData inputData) {
        if (String.isBlank(inputData.FederationID)) {
            throw new ISSP_WS_SIS_Common.WSException('021',''); //new error
        }
        if (inputData.TypeOfService != 'SIS') {
            throw new ISSP_WS_SIS_Common.WSException('010','');
        }
    }
    
    /**
        Generic method for grant/remove access used to find user to change its access
    **/
    private static User changeAccessSISUser(InputData inputData,Boolean grantAccess) {
        list<User> listUser = [
            SELECT Id, Contact.Id
            FROM User
            WHERE FederationIdentifier = :inputData.FederationID
            AND UserType = 'PowerPartner'];
        
        if (listUser.isEmpty()) {
            throw new ISSP_WS_SIS_Common.WSException('011','');
        }
        User theUser = listUser[0];
        if (theUser.Contact == null) {
            throw new ISSP_WS_SIS_Common.WSException('013','');
        }
        Contact theContact = theUser.Contact;
        
        if (grantAccess) {
            grantAccessToSIS(theContact);
        } else {
            removeAccessToSIS(theContact);
        }
        return theUser;
    }
    
    /**
        Grant access to SIS application to given contact
    **/
    public static void grantAccessToSIS(Contact contact) {
        List <Portal_Application_Right__c> appRightList = [
            SELECT Id, Right__c
            FROM Portal_Application_Right__c
            WHERE Contact__c = :contact.Id
            AND Portal_Application__c = :SIS_ID_PORTAL_APP];

        if (appRightList.isEmpty()){
            //create new app right
            try {
                Portal_Application_Right__c appRight = ISSP_WS_Utilities.createApp(SIS_ID_PORTAL_APP, contact.Id);
                insert appRight;
            } catch (Exception e) {
                throw new ISSP_WS_SIS_Common.WSException('001', 'Application right creation failed ' + e.getMessage());
            }
        } else {
            //grant access to already existing app right
            Portal_Application_Right__c appRight = appRightList[0];
            if (appRight.Right__c != 'Access Granted'){
                try{
                    appRight.Right__c = 'Access Granted';
                    update appRight;
                } catch (Exception e){
                    throw new ISSP_WS_SIS_Common.WSException('001', 'Application right update failed ' + e.getMessage());
                }
            }
        }
    }
    
    /**
        Remove access to SIS application to given contact
    **/
    private static void removeAccessToSIS(Contact contact) {
        List <Portal_Application_Right__c> appRightList = [
            SELECT Id, Right__c
            FROM Portal_Application_Right__c
            WHERE Contact__c = :contact.Id
            AND Portal_Application__c = :SIS_ID_PORTAL_APP];

        if (!appRightList.isEmpty()){
            //remove access to already existing app right
            Portal_Application_Right__c appRight = appRightList[0];
            if (appRight.Right__c != 'Access Denied'){
                try{
                    appRight.Right__c = 'Access Denied';
                    update appRight;
                } catch (Exception e){
                    throw new ISSP_WS_SIS_Common.WSException('001', 'Application right update failed ' + e.getMessage());
                }
            }
        }
    }
    
    /**
        Creates the response object for Activate/Deactivate User WS when it is success
    **/
    private static ResponseData createResponseSuccess(InputData inputData, User user, Boolean grantAccess) {
        insertSuccessLog(inputData, user, grantAccess);
        ResponseData response = new ResponseData();
        response.IsSuccess = true;
        response.ErrorCode = '';
        response.ErrorDescription = '';
        return response;
    }
    
    /**
        Creates the response object for Activate/Deactivate User WS when it has an error
    **/
    private static ResponseData createResponseError(InputData inputData, ISSP_WS_SIS_Common.WSException wsException, Boolean grantAccess) {
        insertErrorLog(inputData, wsException, grantAccess);
        ResponseData response = new ResponseData();
        response.IsSuccess = false;
        response.ErrorCode = wsException.errorCode;
        response.ErrorDescription = wsException.description;
        return response;
    }
    
    /**
        Creates and inserts a new log with a Success
    **/
    private static void insertSuccessLog(InputData inputData, User user, Boolean grantAccess) {
        ISSP_Web_Service_Log__c log = createLog(inputData, grantAccess);
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
    private static void insertErrorLog(InputData inputData, ISSP_WS_SIS_Common.WSException wsException, Boolean grantAccess) {
        ISSP_Web_Service_Log__c log = createLog(inputData, grantAccess);
        log.Success__c = false;
        log.Error_Code__c = wsException.errorCode;
        log.Error_Message__c = wsException.description;
        insert log;
    }
    
    /**
        create a basic log object
    **/
    private static ISSP_Web_Service_Log__c createLog(InputData inputData, Boolean grantAccess) {
        ISSP_Web_Service_Log__c log = new ISSP_Web_Service_Log__c();
        log.Web_Service__c = 'ISSP_WS_SIS_ActivateUser';
        log.Method__c = grantAccess? 'ActivateUser': 'DeactivateUser';
        log.System__c = inputData.TypeOfService;
        log.Login_Ip__c = ISSP_WS_SIS_Common.getLoginIP();
        log.Input_Description__c = 'User Id: ' + UserInfo.getUsername() + '\n';
        log.Input_Description__c +='FederationID: ' + inputData.FederationID + '\n';
        log.Input_Description__c +='TypeOfService: ' + inputData.TypeOfService + '\n';
        log.Finished__c = system.now();
        return log;
    }

}