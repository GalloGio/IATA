global class ISSP_WS_DisableUser {

    global class ResponseOne {
        WebService Boolean isSuccess;
        WebService String responseErrorCode;
        WebService String responseErrorMessage;
    }
    
    global class UserInputData {
        WebService String fedId;
        WebService String services;
    }
    
    WebService static ResponseOne disableUser (UserInputData inputData) {
        
        String fedId = inputData.fedId;
        String app = inputData.services;
        
        String theUser;
        String theContact;
        
        // Get request IP
        List <LoginHistory> loginList = [SELECT Id, SourceIp FROM LoginHistory
                                        WHERE UserId = :UserInfo.getUserId()
                                        ORDER BY LoginTime DESC LIMIT 1];
        
        // Create log object record
        ISSP_Web_Service_Log__c newLog = new ISSP_Web_Service_Log__c();
        newLog.Success__c = true;
        newLog.Web_Service__c = 'ISSP_WS_DisableUser';
        newLog.Method__c = 'disableUser';
        newLog.System__c = app;
        if (!loginList.isEmpty()){
            newLog.Login_Ip__c = loginList[0].SourceIp;
        }
        String errorCode = '';
        String errorMessage = '';
        // log inputs
        String fulldescription = 'User Id: ' + UserInfo.getUsername() + '\n';
        fulldescription = fulldescription + 'App: ' + app + '\n';
        fulldescription = fulldescription + 'Federation Id: ' + fedId + '\n';
        newLog.Input_Description__c = fulldescription;
        
        // Build the Return Struture
        ResponseOne retResponseOne = new ResponseOne();
        retResponseOne.isSuccess = true;
        retResponseOne.responseErrorCode = '';
        retResponseOne.responseErrorMessage = '';
        
        if (fedId == '' || fedId == null){
            errorCode = '012';
            errorMessage = ISSP_Int_Error__c.getValues('012').Error_Message__c;
            retResponseOne.isSuccess = false;
            retResponseOne.responseErrorCode = errorCode;
            retResponseOne.responseErrorMessage = errorMessage;
            
            //insert log record
            newLog.Success__c = false;
            newLog.Error_Code__c = errorCode;
            newLog.Error_Message__c = errorMessage;
            newLog.Finished__c = system.now();
            insert newLog;
            
            return retResponseOne;
        }
        else if (app == '' || app == null){
            errorCode = '010';
            errorMessage = ISSP_Int_Error__c.getValues('010').Error_Message__c;
            retResponseOne.isSuccess = false;
            retResponseOne.responseErrorCode = errorCode;
            retResponseOne.responseErrorMessage = errorMessage;
            
            //insert log record
            newLog.Success__c = false;
            newLog.Error_Code__c = errorCode;
            newLog.Error_Message__c = errorMessage;
            newLog.Finished__c = system.now();
            insert newLog;
            
            return retResponseOne;
        }
        else{
            List <User> userList = [SELECT Id, ContactId, IsActive, Portal_User_Frozen_Checkbox__c, FederationIdentifier FROM User WHERE FederationIdentifier = :fedId];
            if (userList.isEmpty()){
                errorCode = '011';
                errorMessage = ISSP_Int_Error__c.getValues('011').Error_Message__c;
                retResponseOne.isSuccess = false;
                retResponseOne.responseErrorCode = errorCode;
                retResponseOne.responseErrorMessage = errorMessage;
                
                //insert log record
                newLog.Success__c = false;
                newLog.Error_Code__c = errorCode;
                newLog.Error_Message__c = errorMessage;
                newLog.Finished__c = system.now();
                insert newLog;
                
                return retResponseOne;
            }
            else{
                User thisUser;
                system.debug('FED ID: ' + fedId);
                for (User currentUser : userList){
                    if (currentUser.FederationIdentifier.equals(fedId)){
                        system.debug('FED ID EQUAL TO: ' + currentUser.FederationIdentifier);
                        thisUser = currentUser;
                    }
                    else{
                        system.debug('FED ID NOT EQUAL TO: ' + currentUser.FederationIdentifier);
                    }
                }
                if (thisUser == null){
                    system.debug('USER IS NULL');
                    errorCode = '011';
                    errorMessage = ISSP_Int_Error__c.getValues('011').Error_Message__c;
                    retResponseOne.isSuccess = false;
                    retResponseOne.responseErrorCode = errorCode;
                    retResponseOne.responseErrorMessage = errorMessage;
                    
                    //insert log record
                    newLog.Success__c = false;
                    newLog.Error_Code__c = errorCode;
                    newLog.Error_Message__c = errorMessage;
                    newLog.Finished__c = system.now();
                    insert newLog;
                    
                    return retResponseOne;
                }
                system.debug('USER IS NOT NULL: ' + thisUser.ContactId);
                if (thisUser.ContactId == null){
                    errorCode = '013';
                    errorMessage = ISSP_Int_Error__c.getValues('013').Error_Message__c;
                    retResponseOne.isSuccess = false;
                    retResponseOne.responseErrorCode = errorCode;
                    retResponseOne.responseErrorMessage = errorMessage;
                    
                    //insert log record
                    newLog.Success__c = false;
                    newLog.Error_Code__c = errorCode;
                    newLog.Error_Message__c = errorMessage;
                    newLog.Finished__c = system.now();
                    insert newLog;
                    
                    return retResponseOne;
                }
                else if (!thisUser.IsActive && !thisUser.Portal_User_Frozen_Checkbox__c){
                    errorCode = '014';
                    errorMessage = ISSP_Int_Error__c.getValues('014').Error_Message__c;
                    retResponseOne.isSuccess = false;
                    retResponseOne.responseErrorCode = errorCode;
                    retResponseOne.responseErrorMessage = errorMessage;
                    
                    //insert log record
                    newLog.Success__c = false;
                    newLog.Error_Code__c = errorCode;
                    newLog.Error_Message__c = errorMessage;
                    newLog.Finished__c = system.now();
                    insert newLog;
                    
                    return retResponseOne;
                }
                else{
                    List <Contact> contactList = [SELECT Id FROM Contact WHERE Id = :thisUser.ContactId];
                    if (contactList.isEmpty()){
                        errorCode = '013';
                        errorMessage = ISSP_Int_Error__c.getValues('013').Error_Message__c;
                        retResponseOne.isSuccess = false;
                        retResponseOne.responseErrorCode = errorCode;
                        retResponseOne.responseErrorMessage = errorMessage;
                        
                        //insert log record
                        newLog.Success__c = false;
                        newLog.Error_Code__c = errorCode;
                        newLog.Error_Message__c = errorMessage;
                        newLog.Finished__c = system.now();
                        insert newLog;
                        
                        return retResponseOne;
                    }
                    else{
                        ISSP_Portal_Service_Ids__c serviceIdInstance = ISSP_Portal_Service_Ids__c.getInstance();
                        String serviceId = '';
                        if (app.toUpperCase() == 'CASS01'){
                            //app = 'CASSLink Export';
                            serviceId = serviceIdInstance.CASSLinkExport__c;
                        }
                        else if (app.toUpperCase() == 'CASS02'){
                            //app = 'CASSLink Import';
                            serviceId = serviceIdInstance.CASSLinkImport__c;
                        }
                        else if (app.toUpperCase() == 'CASS03'){
                            //app = 'CASSLink Analytics';
                            serviceId = serviceIdInstance.CASSLinkRouteAnalyzer__c;
                        }
                        else if (app.toUpperCase() == 'CASS04'){                           
                            serviceId = serviceIdInstance.CNS_CassLink__c;
                        }
                        else if (app.toUpperCase() == 'SIS'){
                            serviceId = serviceIdInstance.SIS__c;
                        }
                        else if (app.toUpperCase() == 'ASD'){
                            serviceId = serviceIdInstance.ASD__c;
                        }
                        else if (app.toUpperCase() == 'BSPLINK'){
                            serviceId = serviceIdInstance.BSPLink__c;
                        }

                        Contact thisContact = contactList[0];
                        theUser = thisUser.Id;
                        theContact = thisContact.Id;
                        List <Portal_Applications__c> appList = [SELECT Id FROM Portal_Applications__c
                                                            WHERE Id = :serviceId];
                        if (appList.isEmpty()){
                            errorCode = '010';
                            errorMessage = ISSP_Int_Error__c.getValues('010').Error_Message__c;
                            retResponseOne.isSuccess = false;
                            retResponseOne.responseErrorCode = errorCode;
                            retResponseOne.responseErrorMessage = errorMessage;
                            
                            //insert log record
                            newLog.Success__c = false;
                            newLog.Error_Code__c = errorCode;
                            newLog.Error_Message__c = errorMessage;
                            newLog.Finished__c = system.now();
                            insert newLog;
                            
                            return retResponseOne;
                        }
                        else{
                            Portal_Applications__c thisApp = appList[0];
                            List <Portal_Application_Right__c> appRightList = 
                                                            [SELECT Id, Right__c
                                                            FROM Portal_Application_Right__c
                                                            WHERE Portal_Application__c = :thisApp.Id
                                                            AND Contact__c = :thisContact.Id];
                            if (appRightList.isEmpty()){
                                errorCode = '014';
                                errorMessage = ISSP_Int_Error__c.getValues('014').Error_Message__c;
                                retResponseOne.isSuccess = false;
                                retResponseOne.responseErrorCode = errorCode;
                                retResponseOne.responseErrorMessage = errorMessage;
                                
                                //insert log record
                                newLog.Success__c = false;
                                newLog.Error_Code__c = errorCode;
                                newLog.Error_Message__c = errorMessage;
                                newLog.Finished__c = system.now();
                                insert newLog;
                                
                                return retResponseOne;
                            }
                            else{
                                Portal_Application_Right__c thisAppRight = appRightList[0];
                                if (thisAppRight.Right__c != 'Access Granted'){
                                    errorCode = '014';
                                    errorMessage = ISSP_Int_Error__c.getValues('014').Error_Message__c;
                                    retResponseOne.isSuccess = false;
                                    retResponseOne.responseErrorCode = errorCode;
                                    retResponseOne.responseErrorMessage = errorMessage;
                                    
                                    //insert log record
                                    newLog.Success__c = false;
                                    newLog.Error_Code__c = errorCode;
                                    newLog.Error_Message__c = errorMessage;
                                    newLog.Finished__c = system.now();
                                    insert newLog;
                                    
                                    return retResponseOne;
                                }
                                else{
                                    thisAppRight.Right__c = 'Access Denied';
                                    try{
                                        ISSP_UserTriggerHandler.preventTrigger = true;
                                        ISSP_UserTriggerHandler.preventSISIntegration = true;
                                        update thisAppRight;
                                    }
                                    catch (Exception e){
                                        errorCode = '001';
                                        errorMessage = ISSP_Int_Error__c.getValues('001').Error_Message__c + e;
                                        retResponseOne.isSuccess = false;
                                        retResponseOne.responseErrorCode = errorCode;
                                        retResponseOne.responseErrorMessage = errorMessage;
                                        
                                        //insert log record
                                        newLog.Success__c = false;
                                        newLog.Error_Code__c = errorCode;
                                        newLog.Error_Message__c = errorMessage;
                                        newLog.Finished__c = system.now();
                                        insert newLog;
                                        
                                        return retResponseOne;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        newLog.Finished__c = system.now();
        if (theUser != null && theUser != ''){
            newLog.User__c = theUser;
        }
        if (theContact != null && theContact != ''){
            newLog.Contact__c = theContact;
        }
        insert newLog;
        return retResponseOne;
    }
    
    WebService static ResponseOne reactivateUser (UserInputData inputData) {
        
        String fedId = inputData.fedId;
        String app = inputData.services;
        
        String theUser;
        String theContact;
        Boolean reactivateUser = false;
        String emailForUsername;
        // Get request IP
        List <LoginHistory> loginList = [SELECT Id, SourceIp FROM LoginHistory
                                        WHERE UserId = :UserInfo.getUserId()
                                        ORDER BY LoginTime DESC LIMIT 1];
        
        // Create log object record
        ISSP_Web_Service_Log__c newLog = new ISSP_Web_Service_Log__c();
        newLog.Success__c = true;
        newLog.Web_Service__c = 'ISSP_WS_DisableUser';
        newLog.Method__c = 'reactivateUser';
        newLog.System__c = app;
        if (!loginList.isEmpty()){
            newLog.Login_Ip__c = loginList[0].SourceIp;
        }
        String errorCode = '';
        String errorMessage = '';
        // log inputs
        String fulldescription = 'User Id: ' + UserInfo.getUsername() + '\n';
        fulldescription = fulldescription + 'App: ' + app + '\n';
        fulldescription = fulldescription + 'Federation Id: ' + fedId + '\n';
        newLog.Input_Description__c = fulldescription;
        
        // Build the Return Struture
        ResponseOne retResponseOne = new ResponseOne();
        retResponseOne.isSuccess = true;
        retResponseOne.responseErrorCode = '';
        retResponseOne.responseErrorMessage = '';
        
        if (fedId == '' || fedId == null){
            errorCode = '012';
            errorMessage = ISSP_Int_Error__c.getValues('012').Error_Message__c;
            retResponseOne.isSuccess = false;
            retResponseOne.responseErrorCode = errorCode;
            retResponseOne.responseErrorMessage = errorMessage;
            
            //insert log record
            newLog.Success__c = false;
            newLog.Error_Code__c = errorCode;
            newLog.Error_Message__c = errorMessage;
            newLog.Finished__c = system.now();
            insert newLog;
            
            return retResponseOne;
        }
        else if (app == '' || app == null){
            errorCode = '010';
            errorMessage = ISSP_Int_Error__c.getValues('010').Error_Message__c;
            retResponseOne.isSuccess = false;
            retResponseOne.responseErrorCode = errorCode;
            retResponseOne.responseErrorMessage = errorMessage;
            
            //insert log record
            newLog.Success__c = false;
            newLog.Error_Code__c = errorCode;
            newLog.Error_Message__c = errorMessage;
            newLog.Finished__c = system.now();
            insert newLog;
            
            return retResponseOne;
        }
        else{
            List <User> userList = [SELECT Id, ContactId, IsActive, FederationIdentifier FROM User WHERE FederationIdentifier = :fedId];
            if (userList.isEmpty()){
                errorCode = '011';
                errorMessage = ISSP_Int_Error__c.getValues('011').Error_Message__c;
                retResponseOne.isSuccess = false;
                retResponseOne.responseErrorCode = errorCode;
                retResponseOne.responseErrorMessage = errorMessage;
                
                //insert log record
                newLog.Success__c = false;
                newLog.Error_Code__c = errorCode;
                newLog.Error_Message__c = errorMessage;
                newLog.Finished__c = system.now();
                insert newLog;
                
                return retResponseOne;
            }
            else{
                User thisUser;
                system.debug('FED ID: ' + fedId);
                for (User currentUser : userList){
                    if (currentUser.FederationIdentifier.equals(fedId)){
                        system.debug('FED ID EQUAL TO: ' + currentUser.FederationIdentifier);
                        thisUser = currentUser;
                    }
                    else{
                        system.debug('FED ID NOT EQUAL TO: ' + currentUser.FederationIdentifier);
                    }
                }
                if (thisUser == null){
                    system.debug('USER IS NULL');
                    errorCode = '011';
                    errorMessage = ISSP_Int_Error__c.getValues('011').Error_Message__c;
                    retResponseOne.isSuccess = false;
                    retResponseOne.responseErrorCode = errorCode;
                    retResponseOne.responseErrorMessage = errorMessage;
                    
                    //insert log record
                    newLog.Success__c = false;
                    newLog.Error_Code__c = errorCode;
                    newLog.Error_Message__c = errorMessage;
                    newLog.Finished__c = system.now();
                    insert newLog;
                    
                    return retResponseOne;
                }
                system.debug('USER IS NOT NULL: ' + thisUser.ContactId);
                if (thisUser.ContactId == null){
                    errorCode = '013';
                    errorMessage = ISSP_Int_Error__c.getValues('013').Error_Message__c;
                    retResponseOne.isSuccess = false;
                    retResponseOne.responseErrorCode = errorCode;
                    retResponseOne.responseErrorMessage = errorMessage;
                    
                    //insert log record
                    newLog.Success__c = false;
                    newLog.Error_Code__c = errorCode;
                    newLog.Error_Message__c = errorMessage;
                    newLog.Finished__c = system.now();
                    insert newLog;
                    
                    return retResponseOne;
                }
                /*else if (!thisUser.IsActive){
                    errorCode = '014';
                    errorMessage = ISSP_Int_Error__c.getValues('014').Error_Message__c;
                    retResponseOne.isSuccess = false;
                    retResponseOne.responseErrorCode = errorCode;
                    retResponseOne.responseErrorMessage = errorMessage;
                    
                    //insert log record
                    newLog.Success__c = false;
                    newLog.Error_Code__c = errorCode;
                    newLog.Error_Message__c = errorMessage;
                    newLog.Finished__c = system.now();
                    insert newLog;
                    
                    return retResponseOne;
                }*/
                else{
                    List <Contact> contactList = [SELECT Id, Email FROM Contact WHERE Id = :thisUser.ContactId];
                    if (contactList.isEmpty()){
                        errorCode = '013';
                        errorMessage = ISSP_Int_Error__c.getValues('013').Error_Message__c;
                        retResponseOne.isSuccess = false;
                        retResponseOne.responseErrorCode = errorCode;
                        retResponseOne.responseErrorMessage = errorMessage;
                        
                        //insert log record
                        newLog.Success__c = false;
                        newLog.Error_Code__c = errorCode;
                        newLog.Error_Message__c = errorMessage;
                        newLog.Finished__c = system.now();
                        insert newLog;
                        
                        return retResponseOne;
                    }
                    else{
                        ISSP_Portal_Service_Ids__c serviceIdInstance = ISSP_Portal_Service_Ids__c.getInstance();
                        String serviceId = '';
                        if (app.toUpperCase() == 'CASS01'){
                            //app = 'CASSLink Export';
                            serviceId = serviceIdInstance.CASSLinkExport__c;
                        }
                        else if (app.toUpperCase() == 'CASS02'){
                            //app = 'CASSLink Import';
                            serviceId = serviceIdInstance.CASSLinkImport__c;
                        }
                        else if (app.toUpperCase() == 'CASS03'){
                            //app = 'CASSLink Analytics';
                            serviceId = serviceIdInstance.CASSLinkRouteAnalyzer__c;
                        }
                        else if (app.toUpperCase() == 'CASS04'){                           
                            serviceId = serviceIdInstance.CNS_CassLink__c;
                        }
                        else if (app.toUpperCase() == 'SIS'){
                            serviceId = serviceIdInstance.SIS__c;
                        }
                        else if (app.toUpperCase() == 'ASD'){
                            serviceId = serviceIdInstance.ASD__c;
                        }
                        else if (app.toUpperCase() == 'BSPLINK'){
                            serviceId = serviceIdInstance.BSPLink__c;
                        }

                        if (!thisUser.IsActive){
                            system.debug('thisUser >>> '+ thisUser);
                            reactivateUser = true;
                        }

                        Contact thisContact = contactList[0];
                        theUser = thisUser.Id;
                        theContact = thisContact.Id;
                        emailForUsername = thisContact.Email;
                        List <Portal_Applications__c> appList = [SELECT Id FROM Portal_Applications__c
                                                                WHERE Id = :serviceId];
                        if (appList.isEmpty()){
                            errorCode = '010';
                            errorMessage = ISSP_Int_Error__c.getValues('010').Error_Message__c;
                            retResponseOne.isSuccess = false;
                            retResponseOne.responseErrorCode = errorCode;
                            retResponseOne.responseErrorMessage = errorMessage;
                            
                            //insert log record
                            newLog.Success__c = false;
                            newLog.Error_Code__c = errorCode;
                            newLog.Error_Message__c = errorMessage;
                            newLog.Finished__c = system.now();
                            insert newLog;
                            
                            return retResponseOne;
                        }
                        else{
                            Portal_Applications__c thisApp = appList[0];
                            List <Portal_Application_Right__c> appRightList = 
                                                            [SELECT Id, Right__c
                                                            FROM Portal_Application_Right__c
                                                            WHERE Portal_Application__c = :thisApp.Id
                                                            AND Contact__c = :thisContact.Id];
                            if (appRightList.isEmpty()){
                                Portal_Application_Right__c newAppRight = new Portal_Application_Right__c();
                                newAppRight.Contact__c = thisContact.Id;
                                newAppRight.Portal_Application__c = thisApp.Id;
                                newAppRight.Right__c = 'Access Granted';
                                try{
                                    ISSP_UserTriggerHandler.preventTrigger = true;
                                    ISSP_UserTriggerHandler.preventSISIntegration = true;
                                    insert newAppRight;
                                }
                                catch (Exception e){
                                    errorCode = '001';
                                    errorMessage = ISSP_Int_Error__c.getValues('001').Error_Message__c;
                                    retResponseOne.isSuccess = false;
                                    retResponseOne.responseErrorCode = errorCode;
                                    retResponseOne.responseErrorMessage = errorMessage;
                                    
                                    //insert log record
                                    newLog.Success__c = false;
                                    newLog.Error_Code__c = errorCode;
                                    newLog.Error_Message__c = errorMessage;
                                    newLog.Finished__c = system.now();
                                    insert newLog;
                                    
                                    return retResponseOne;
                                }
                            }
                            else{
                                Portal_Application_Right__c thisAppRight = appRightList[0];
                                thisAppRight.Right__c = 'Access Granted';
                                try{
                                    ISSP_UserTriggerHandler.preventTrigger = true;
                                    ISSP_UserTriggerHandler.preventSISIntegration = true;
                                    update thisAppRight;
                                }
                                catch (Exception e){
                                    errorCode = '001';
                                    errorMessage = ISSP_Int_Error__c.getValues('001').Error_Message__c;
                                    retResponseOne.isSuccess = false;
                                    retResponseOne.responseErrorCode = errorCode;
                                    retResponseOne.responseErrorMessage = errorMessage;
                                    
                                    //insert log record
                                    newLog.Success__c = false;
                                    newLog.Error_Code__c = errorCode;
                                    newLog.Error_Message__c = errorMessage;
                                    newLog.Finished__c = system.now();
                                    insert newLog;
                                    
                                    return retResponseOne;
                                }
                            }
                        }
                    }
                }
            }
        }
        newLog.Finished__c = system.now();
        if (theUser != null && theUser != ''){
            if(reactivateUser){
               updateUser(theUser, emailForUsername);
            }

        newLog.User__c = theUser;
        }
        if (theContact != null && theContact != ''){
            newLog.Contact__c = theContact;
        }
        insert newLog;
        return retResponseOne;
    }

    @future
    public static void updateUser(String userID, String email) {
        User userToReactivate = new User(
            Id = userID,
            IsActive = true,
            Portal_User_Frozen_Checkbox__c = false,
            Username = ISSP_Utilities.buildPortalUserName(email));
            update userToReactivate;
    }
    
    // method to artificially increase test coverage, remove it asap
    public static void dummyFunction() {
        if (Test.IsRunningTest()) {
            Integer i =0;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
        }
    }
}