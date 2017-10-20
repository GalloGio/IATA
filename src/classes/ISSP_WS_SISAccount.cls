global class ISSP_WS_SISAccount {

    global class AccountInputDataResponse {
        WebService Boolean isSuccess;
        WebService String responseErrorCode;
        WebService String responseErrorMessage;
    }

    global class AccountInputData {
        WebService String sisAccountId;
        WebService String sis3DigitCode;
        WebService String sis2LetterCode;
        WebService String sisVerified;
        WebService String sisStatus;
        WebService String sisSubStatus;
    }
    
    global class WSException extends Exception{
        public String errorCode;
        public String description;

        public WSException(String errorCode, String description) {
            this.errorCode = errorCode;
            this.description = description;
        }
        
        public AccountInputDataResponse getResponse() {
            AccountInputDataResponse response = new AccountInputDataResponse();
            response.isSuccess = false;
            response.responseErrorCode = this.errorCode;
            response.responseErrorMessage = ISSP_Int_Error__c.getValues(this.errorCode).Error_Message__c + '\n' + description;
            return response;
        }
    }

    /**
        Webservice to find a SIS Account, it is found using the input SIS ID
        this method created the response and a new log record to track the call
    **/
    WebService static AccountInputDataResponse updateAccount(AccountInputData inputData) {
        try {
            if (String.isBlank(inputData.sisAccountId)) {
                throw new WSException('001','sisAccountId required');
            }
            updateSISAccount(inputData);

        } catch(WSException e) {
            //Return an Error Response
            createErrorLog(inputData, e);
            return e.getResponse();
        }
        // Return a Success response
        createSuccessLog(inputData);
        AccountInputDataResponse response = new AccountInputDataResponse();
        response.isSuccess = true;
        response.responseErrorCode = '';
        response.responseErrorMessage = '';
        return response;
    }

    /**
        Find and update the account based in the SIS Id provided in the AccountInputData object
    **/
    private static void updateSISAccount(AccountInputData inputData){
        list<Account> listAccount = [
            SELECT Id, SIS_ID__c, EF_SIS_Code__c, EF_SIS_Designator__c, EF_SIS_Code_Verified__c, SIS_Status__c, SIS_Sub_Status__c
            FROM Account
            WHERE SIS_ID__c = :inputData.sisAccountId
            LIMIT 1];
        if (listAccount.isEmpty()) {
            throw new WSException('005',''); // Account not found
        }
        try {
            Account account = listAccount[0];
            if (!String.isBlank(inputData.sis3DigitCode)) {
                account.EF_SIS_Code__c = inputData.sis3DigitCode;
            }
            if (!String.isBlank(inputData.sis2LetterCode)) {
                account.EF_SIS_Designator__c = inputData.sis2LetterCode;
            }
            if (!String.isBlank(inputData.sisVerified)) {
                account.EF_SIS_Code_Verified__c = Boolean.ValueOf(inputData.sisVerified);
            }
            if (!String.isBlank(inputData.sisStatus)) {
                account.SIS_Status__c = inputData.sisStatus;
            }
            if (!String.isBlank(inputData.sisSubStatus)) {
                account.SIS_Sub_Status__c = inputData.sisSubStatus;
            }
            update account;
            
        } catch (Exception e) {
            throw new WSException('001',e.getMessage());
        }
    }

    /**
        Get last IP acces for current User
    **/
    private static String getLoginIP() {
        list<LoginHistory> listHistory = [
            SELECT Id, SourceIp
            FROM LoginHistory
            WHERE UserId = :UserInfo.getUserId()
            ORDER BY LoginTime DESC LIMIT 1];

        if (listHistory.isEmpty()) return '';
        return listHistory[0].SourceIp;
    }
    
    /**
        Insert a SUCCESS in ISSP_Web_Service_Log__c using the AccountInputData object information
    **/
    private static void createSuccessLog(AccountInputData inputData) {
        createErrorLog(inputData,null);
    }

    /**
        Insert a ISSP_Web_Service_Log__c record using the AccountInputData object information
    **/
    private static void createErrorLog(AccountInputData inputData, WSException wsException) {
        ISSP_Web_Service_Log__c log = new ISSP_Web_Service_Log__c();
        log.Web_Service__c = 'ISSP_WS_SISAccount';
        log.Method__c = 'updateAccount';
        //log.System__c = app;
        log.Login_Ip__c = getLoginIP();
        log.Input_Description__c = 'User Id: ' + UserInfo.getUsername() + '\n';
        log.Input_Description__c += 'sisAccountId: ' + inputData.sisAccountId + '\n';
        log.Input_Description__c += 'sis3DigitCode: ' + inputData.sis3DigitCode + '\n';
        log.Input_Description__c += 'sis2LetterCode: ' + inputData.sis2LetterCode + '\n';
        log.Input_Description__c += 'sisVerified: ' + inputData.sisVerified + '\n';
        log.Input_Description__c += 'sisStatus: ' + inputData.sisStatus + '\n';
        log.Input_Description__c += 'sisSubStatus: ' + inputData.sisSubStatus + '\n';
        log.Finished__c = system.now();
        if (wsException==null) {
            log.Success__c = true;
        } else {
            log.Success__c = false;
            log.Error_Code__c = wsException.errorCode;
            log.Error_Message__c = wsException.description;
        }
        insert log;
    }

}