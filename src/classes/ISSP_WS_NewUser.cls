global class ISSP_WS_NewUser {

    global class SimpleResponse {
        WebService String responseMessage;
        WebService String responseEcho;
    }

    global class SimpleInput {
        WebService String inputMessage;
    }

    WebService static SimpleResponse simpleMethod1 (SimpleInput inputMessage) {

        // Get request IP
        List <LoginHistory> loginList = [SELECT Id, SourceIp FROM LoginHistory
                                        WHERE UserId = :UserInfo.getUserId()
                                        ORDER BY LoginTime DESC LIMIT 1];

        // Create log object record
        ISSP_Web_Service_Log__c newLog = new ISSP_Web_Service_Log__c();
        newLog.Success__c = true;
        newLog.Web_Service__c = 'ISSP_WS_NewUser';
        newLog.Method__c = 'simpleMethod1';
        newLog.Error_Message__c = '';
        if (!loginList.isEmpty()){
            newLog.Login_Ip__c = loginList[0].SourceIp;
        }
        insert newLog;

        SimpleResponse retResponseO = new SimpleResponse();
        retResponseO.responseMessage = 'Hello World';
        retResponseO.responseEcho = inputMessage.inputMessage;
        return retResponseO;
    }

    global class ResponseOne {
        WebService Boolean isSuccess;
        WebService String responseErrorCode;
        WebService String responseErrorMessage;
        WebService String federationId;
    }

    global class UserInputData {
        WebService String firstName;
        WebService String lastName;
        WebService String salutation;
        WebService String email;
        //WebService String accountIATAcode;
        WebService String sisAccountId;
        WebService String accountCountry;
        WebService String phone;
        WebService String services;
        WebService String sisMemberId;
        WebService String description;
    }

    WebService static ResponseOne createUser (UserInputData inputData) {

        Savepoint sPointContact = Database.setSavepoint();

        String userFirstName = inputData.firstName;
        String userLastName = inputData.lastName;
        String userSalutation = inputData.salutation;
        String userEmail = inputData.email;
        String sisAccountId = inputData.sisAccountId;
        String userIataCountry = inputData.accountCountry;
        String userPhone = inputData.phone;
        String app = inputData.services;
        String sisMemberId = inputData.sisMemberId;
        String description = inputData.description;

        String theUser;
        String theContact;

        // Get request IP
        List <LoginHistory> loginList = [SELECT Id, SourceIp FROM LoginHistory
                                        WHERE UserId = :UserInfo.getUserId()
                                        ORDER BY LoginTime DESC LIMIT 1];

        // Create log object record
        ISSP_Web_Service_Log__c newLog = new ISSP_Web_Service_Log__c();
        newLog.Success__c = true;
        newLog.Web_Service__c = 'ISSP_WS_NewUser';
        newLog.Method__c = 'createUser';
        newLog.System__c = app;
        if (!loginList.isEmpty()){
            newLog.Login_Ip__c = loginList[0].SourceIp;
        }
        String errorCode = '';
        String errorMessage = '';
        // log inputs
        String fulldescription = 'User Id: ' + UserInfo.getUsername() + '\n';
        fulldescription = fulldescription + 'App: ' + app + '\n';
        fulldescription = fulldescription + 'Email: ' + userEmail + '\n';
        fulldescription = fulldescription + 'First Name: ' + userFirstName + '\n';
        fulldescription = fulldescription + 'Last Name: ' + userLastName + '\n';
        fulldescription = fulldescription + 'Salutation: ' + userSalutation + '\n';
        fulldescription = fulldescription + 'Phone: ' + userPhone + '\n';
        fulldescription = fulldescription + 'SIS Account Id: ' + sisAccountId + '\n';
        fulldescription = fulldescription + 'Country Code: ' + userIataCountry + '\n';
        fulldescription = fulldescription + 'SIS Member Id: ' + sisMemberId + '\n';
        fulldescription = fulldescription + 'Description: ' + description + '\n';
        newLog.Input_Description__c = fulldescription;

        String appId = '';

        Boolean isCNS = false;

        // Build the Return Struture
        ResponseOne retResponseOne = new ResponseOne();
        retResponseOne.isSuccess = true;
        retResponseOne.responseErrorCode = '';
        retResponseOne.responseErrorMessage = '';
        retResponseOne.federationId = '';

        if (sisMemberId == '' || sisMemberId == null){
            return createErrorResponse( newLog, retResponseOne, '018');
        }
        if (sisAccountId == '' || sisAccountId == null){
            return createErrorResponse( newLog, retResponseOne, '019');
        }
        if (userEmail == '' || userEmail == null){
            return createErrorResponse( newLog, retResponseOne, '002');
        }
        if (userLastName == '' || userLastName == null){
            return createErrorResponse( newLog, retResponseOne, '003');
        }
        if (app == '' || app == null){
            return createErrorResponse( newLog, retResponseOne, '010');
        }
        else{
            userEmail = userEmail.trim();
            String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,8}$';
            Pattern MyPattern = Pattern.compile(emailRegex);
            Matcher MyMatcher = MyPattern.matcher(userEmail);
            if (!MyMatcher.matches()){
                //invalid email
                return createErrorResponse( newLog, retResponseOne, '006');
            }
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
                isCNS = true;
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
            List <Portal_Applications__c> appList = [SELECT Id FROM Portal_Applications__c
                                                    WHERE Id = :serviceId];
            if (appList.isEmpty()){
                //invalid app
                return createErrorResponse( newLog, retResponseOne, '010');
            }
            appId = appList[0].Id;
            List <User> userList = [SELECT Id, ContactId, FederationIdentifier, FedContactId__c FROM User WHERE Email =: userEmail AND UserType = 'PowerPartner'];
            if (!userList.isEmpty()){
                //found user
                theUser = userList[0].Id;
                theContact = userList[0].ContactId;
                User thisUser = userList[0];
                if (thisUser.ContactId == null){
                    //user with empty ContactId
                    return createErrorResponse( newLog, retResponseOne, '008');
                }
                else{
                    List <Contact> contactList = [SELECT Id, Status__c, User_Portal_Status__c, Email,
                                                FirstName, LastName, AccountId, Salutation,
                                                Preferred_Language__c, SIS_ID__c, Account.SIS_ID__c, Community__c
                                                FROM Contact WHERE Id = :thisUser.ContactId];
                    if (contactList.isEmpty()){
                        //contact not found
                        return createErrorResponse( newLog, retResponseOne, '008');
                    }
                    else{
                        theContact = contactList[0].Id;
                        // check if the contact has the same SIS ID as in the input
                        checkContactSIS_ID(contactList[0], inputData, newLog);

                        //inactive contact
                        if(contactList[0].User_Portal_Status__c == 'Rejected'
                            || contactList[0].User_Portal_Status__c == 'Inactive'
                            || contactList[0].Status__c != 'Active'
                        ){
                            return createErrorResponse( newLog, retResponseOne, '015');
                        }
                        else{
                            //found contact
                            Contact thisContact = contactList[0];
                            if (thisContact.User_Portal_Status__c == 'Pending Approval'){
                                thisContact.User_Portal_Status__c = 'Approved User';
                                        if(thisContact.Community__c == ''){
                                            if(isCNS){
                                                thisContact.Community__c = 'CNS Customer Portal';                                      
                                            }else{
                                                thisContact.Community__c = 'ISS Customer Portal';
                                            }
                                         }
                                update thisContact;
                            }
                            List <Portal_Application_Right__c> appRightList = [SELECT Id, Right__c FROM
                                                            Portal_Application_Right__c
                                                            WHERE Contact__c = :thisContact.Id
                                                            AND Portal_Application__c = :appId];
                            if (appRightList.isEmpty()){
                                //create new app right
                                Portal_Application_Right__c appRight = ISSP_WS_Utilities.createApp(appId, thisContact.Id);
                                try{
                                    insert appRight;
                                }
                                catch (Exception e){
                                    Database.rollback(sPointContact);
                                    return createErrorResponse( newLog, retResponseOne, '001', e);
                                }
                                retResponseOne.federationId = thisUser.FedContactId__c;
                            }
                            else{
                                Portal_Application_Right__c thisAppRight = appRightList[0];
                                if (thisAppRight.Right__c == 'Access Granted'){
                                    //access already granted
                                    /*
                                    errorCode = '007';
                                    errorMessage = ISSP_Int_Error__c.getValues('007').Error_Message__c;
                                    retResponseOne.isSuccess = false;
                                    retResponseOne.responseErrorCode = errorCode;
                                    retResponseOne.responseErrorMessage = errorMessage;
                                    */

                                    //insert log record
                                    newLog.Success__c = true;
                                    newLog.Error_Code__c = errorCode;
                                    newLog.Error_Message__c += errorMessage;
                                    newLog.Finished__c = system.now();
                                    if (theUser != null && theUser != ''){
                                        newLog.User__c = theUser;
                                    }
                                    if (theContact != null && theContact != ''){
                                        newLog.Contact__c = theContact;
                                    }
                                    insert newLog;

                                    retResponseOne.federationId = thisUser.FedContactId__c;

                                    return retResponseOne;
                                }
                                else{
                                    //grant access to already existing app right
                                    thisAppRight.Right__c = 'Access Granted';
                                    try{
                                        update thisAppRight;
                                    }
                                    catch (Exception e){
                                        Database.rollback(sPointContact);
                                        return createErrorResponse( newLog, retResponseOne, '001', e);
                                    }
                                    retResponseOne.federationId = thisUser.FedContactId__c;
                                }
                            }
                            if (thisUser.FederationIdentifier == null){
                                thisUser.FederationIdentifier = thisUser.FedContactId__c;
                                try{
                                    update thisUser;
                                }
                                catch (Exception e){
                                    Database.rollback(sPointContact);
                                    return createErrorResponse( newLog, retResponseOne, '001', e);
                                }
                            }
                        }
                    }
                }
            }
            else{
                //user with that email doesn't exist
                List <Contact> contactList = [SELECT Id, Email, AccountId, Account.RecordType.DeveloperName,
                                            User_Portal_Status__c, Status__c, FirstName, LastName,
                                            Preferred_Language__c, Salutation, SIS_ID__c, Account.SIS_ID__c, Community__c
                                            FROM Contact WHERE Email = :userEmail];
                if (!contactList.isEmpty()){
                    theContact = contactList[0].Id;
                    // check if the contact has the same SIS ID as in the input
                    checkContactSIS_ID(contactList[0], inputData, newLog);
                    
                    //inactive contact
                    if(contactList[0].User_Portal_Status__c == 'Rejected'
                        || contactList[0].User_Portal_Status__c == 'Inactive'
                        || contactList[0].Status__c != 'Active'
                    ){
                        return createErrorResponse( newLog, retResponseOne, '015');
                    }
                    else{
                        //found contact with same email
                        //create user and app access
                        Contact con = contactList[0];
                        con.User_Portal_Status__c = ISSP_Constant.APPROVED_CONTACT_STATUS;
                                if(con.Community__c == '' || con.Community__c == null){
                                    if(isCNS){
                                        con.Community__c = 'CNS Customer Portal';                                      
                                    }else{
                                        con.Community__c = 'ISS Customer Portal';
                                    }
                                }
                        update con;
                        String conId15 = con.Id;
                        conId15 = conId15.substring(0,15);
                        User u = ISSP_WS_Utilities.createUser(userFirstName, userLastName, userEmail, con.Account.RecordType.DeveloperName, con.Id, isCNS);
                        List <Portal_Application_Right__c> appRightList = [SELECT Id, Right__c FROM
                                                            Portal_Application_Right__c
                                                            WHERE Contact__c = :con.Id
                                                            AND Portal_Application__c = :appId];
                        if (appRightList.isEmpty()){
                            //create new app right
                            Portal_Application_Right__c appRight = ISSP_WS_Utilities.createApp(appId, con.Id);
                            try{
                                //String userId = Site.createPortalUser(u, userAccount, null, true);
                                u.FederationIdentifier = conId15;
                                insert u;
                                theUser = u.Id;
                                ISSP_WS_Utilities.sendUserEmail(u, con);
                                insert appRight;
                            }
                            catch (Exception e){
                                Database.rollback(sPointContact);
                                return createErrorResponse( newLog, retResponseOne, '001', e);
                            }
                            retResponseOne.federationId = conId15;
                        }
                        else{
                            Portal_Application_Right__c thisAppRight = appRightList[0];
                            if (thisAppRight.Right__c == 'Access Granted'){
                                //access already granted

                                //insert log record
                                newLog.Success__c = true;
                                newLog.Error_Code__c = errorCode;
                                newLog.Error_Message__c += errorMessage;
                                newLog.Finished__c = system.now();
                                if (theUser != null && theUser != ''){
                                    newLog.User__c = theUser;
                                }
                                if (theContact != null && theContact != ''){
                                    newLog.Contact__c = theContact;
                                }
                                insert newLog;

                                retResponseOne.federationId = conId15;

                                return retResponseOne;
                            }
                            else{
                                //grant access to already existing app right
                                thisAppRight.Right__c = 'Access Granted';
                                try{
                                    //String userId = Site.createPortalUser(u, userAccount, null, true);
                                    u.FederationIdentifier = conId15;
                                    insert u;
                                    ISSP_WS_Utilities.sendUserEmail(u, con);
                                    update thisAppRight;
                                }
                                catch (Exception e){
                                    Database.rollback(sPointContact);
                                    return createErrorResponse( newLog, retResponseOne, '001', e);
                                }
                            }
                            retResponseOne.federationId = conId15;
                        }
                    }
                }
                else{
                    //user with that email doesn't exist
                    //create contact, user and app access
                    List <Account> accountList = [SELECT Id, RecordType.DeveloperName, IATA_ISO_Country__r.ISO_Code__c
                            FROM Account
                            WHERE SIS_ID__c = :sisAccountId
                            LIMIT 1];
                    if (accountList.isEmpty()){
                        //invalid account
                        return createErrorResponse( newLog, retResponseOne, '005');
                    }
                    Account userAccount = accountList[0];

                    Contact con = ISSP_WS_Utilities.createContact(userFirstName, userLastName, userEmail, userAccount.Id, isCNS);
                    con.SIS_ID__c = sisMemberId;
                    String conId15 = '';
                    try{
                        insert con;
                        conId15 = con.Id;
                        conId15 = conId15.substring(0,15);
                        theContact = con.Id;
                    }
                    catch (Exception e){
                        Database.rollback(sPointContact);
                        return createErrorResponse( newLog, retResponseOne, '001', e);
                    }
                    String userAccountType = userAccount.RecordType.DeveloperName;
                    User u = ISSP_WS_Utilities.createUser(userFirstName, userLastName, userEmail, userAccountType, con.Id, isCNS);
                    Portal_Application_Right__c appRight = ISSP_WS_Utilities.createApp(appId, con.Id);
                    try{
                        //String userId = Site.createPortalUser(u, userAccount, null, true);
                        u.FederationIdentifier = conId15;
                        insert u;
                        theUser = u.Id;
                        ISSP_WS_Utilities.sendUserEmail(u, con);
                        insert appRight;
                    }
                    catch (Exception e){
                        Database.rollback(sPointContact);
                        return createErrorResponse( newLog, retResponseOne, '001', e);
                    }
                    retResponseOne.federationId = conId15;
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
    
    private static void checkContactSIS_ID(Contact contact, UserInputData inputData, ISSP_Web_Service_Log__c log) {
        if (inputData.sisMemberId != contact.SIS_ID__c) {
            log.Error_Message__c = 'WARNING: the Contact SIS ID is different than provided by SIS service.\n';
        }
        if (inputData.sisAccountId != contact.Account.SIS_ID__c) {
            log.Error_Message__c = 'WARNING: the Account SIS ID is different than provided by SIS service.\n';
        }
    }
    
    private static ResponseOne createErrorResponse(ISSP_Web_Service_Log__c newLog, ResponseOne retResponseOne, String errorCode) {
        return createErrorResponse(newLog, retResponseOne, errorCode, null);
    }

    private static ResponseOne createErrorResponse(ISSP_Web_Service_Log__c newLog, ResponseOne retResponseOne, String errorCode, Exception e) {
        String errorMessage = ISSP_Int_Error__c.getValues(errorCode).Error_Message__c;
        if (e!=null) {
            errorMessage += e;
        }

        retResponseOne.isSuccess = false;
        retResponseOne.responseErrorCode = errorCode;
        retResponseOne.responseErrorMessage = errorMessage;

        //insert log record
        newLog.Success__c = false;
        newLog.Error_Code__c = errorCode;
        newLog.Error_Message__c += errorMessage;
        newLog.Finished__c = system.now();
        insert newLog;

        return retResponseOne;
    }

}
