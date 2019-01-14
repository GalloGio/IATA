global with sharing class ISSP_WS_SIS_UpdateAccount {

    public static final set<String> VALID_REQUEST_TYPES = ISSP_WS_SIS_Common.VALID_REQUEST_TYPES;
    public static final map<String,Boolean> MAP_MEMBER_CONVERSION = new map<String,Boolean>{
        'LIVE' => true,
        'SUSPENDED' => true,
        'TERMINATED' => false,
        'NOT A MEMBER' => false
    };

    global class InputData {
        WebService String SISMemberID;
        WebService String MemberAccountingCode;
        WebService String MemberDesignator;
        WebService String ISMembershipStatus;
        WebService String IsMembershipSubStatus;
        WebService String ISEntryDate;
        WebService String ICHMembershipStatus;
        WebService String ACHMembershipStatus;
        WebService String TypeOfService;
        WebService String RequestType;
    }

    global class ResponseData {
        WebService Boolean IsSuccess;
        WebService String SISMemberID;
        WebService String ErrorCode;
        WebService String ErrorDescription;
    }

    /**
        Webservice call to update SIS values in an Account
    **/
    WebService static ResponseData UpdateAccount(InputData inputData) {
        Savepoint sPointContact = Database.setSavepoint();
        Account account = null;
        try {
            validateInputData(inputData);
            account = updateSISAccount(inputData);
            // Return a Success response
            return createResponseSuccess(inputData,account);

        } catch(ISSP_WS_SIS_Common.WSException e) {
            // rollback all database changes
            Database.rollback(sPointContact);
            //Return an Error Response
            return createResponseError(inputData,e,account);
        } catch(Exception e) {
            // rollback all database changes
            Database.rollback(sPointContact);
            //Return an Error Response
            System.debug(e.getStackTraceString());
            ISSP_WS_SIS_Common.WSException wsException = new ISSP_WS_SIS_Common.WSException('001','Exception not handled');
            return createResponseError(inputData, wsException, account);
        }
    }
    
    /**
        check all fields in the incoming data, returns an exception if error found
    **/
    private static void validateInputData(InputData inputData) {
        if (String.isBlank(inputData.SISMemberID) || inputData.SISMemberID.length()>9) {
            throw new ISSP_WS_SIS_Common.WSException('018','');
        }
        if (String.isBlank(inputData.MemberAccountingCode)) {
            throw new ISSP_WS_SIS_Common.WSException('023','MemberAccountingCode');
        }
        if (String.isBlank(inputData.MemberDesignator)) {
            throw new ISSP_WS_SIS_Common.WSException('023','MemberDesignator');
        }
        if (String.isBlank(inputData.ISMembershipStatus)) {
            throw new ISSP_WS_SIS_Common.WSException('023','ISMembershipStatus');
        }
        if (String.isBlank(inputData.IsMembershipSubStatus)) {
            throw new ISSP_WS_SIS_Common.WSException('023','IsMembershipSubStatus');
        }
        if (inputData.ISMembershipStatus=='Active' ) {
            if (String.isBlank(inputData.ISEntrydate)) {
                throw new ISSP_WS_SIS_Common.WSException('023','ISEntrydate');
            }
            if (strToDate(inputData.ISEntrydate) == null ) {
                throw new ISSP_WS_SIS_Common.WSException('025','');
            }
        }
        if (inputData.ICHMembershipStatus==null || !MAP_MEMBER_CONVERSION.containsKey(inputData.ICHMembershipStatus.toUpperCase())) {
            throw new ISSP_WS_SIS_Common.WSException('023','ICHMembershipStatus');
        }
        if (inputData.ACHMembershipStatus==null || !MAP_MEMBER_CONVERSION.containsKey(inputData.ACHMembershipStatus.toUpperCase())) {
            throw new ISSP_WS_SIS_Common.WSException('023','ACHMembershipStatus');
        }
        if (inputData.TypeOfService != 'SIS') {
            throw new ISSP_WS_SIS_Common.WSException('010','');
        }
        if (!VALID_REQUEST_TYPES.contains(inputData.RequestType)) {
            throw new ISSP_WS_SIS_Common.WSException('022','');
        }
    }
    
    /**
        Main method to udpate an account
        1. First search for a Account with the incoming SIS member Id code
        2. if found update all SIS values in that account using the incoming data
        3. Return a success response
    **/
    private static Account updateSISAccount(InputData inputData) {
        list<Account> listAccount = [
            SELECT Id, SIS_ID__c, EF_SIS_Code__c, EF_SIS_Designator__c, SIS_Status__c,
            SIS_Sub_Status__c, ICH_Member__c, ACH_Member__c
            FROM Account
            WHERE SIS_ID__c = :inputData.SISMemberID
            LIMIT 1];
        if (listAccount.isEmpty()) {
            throw new ISSP_WS_SIS_Common.WSException('005',''); // Account not found
        }
        Account account = listAccount[0];
        try {
            //prevent the callout execution for update account
            ISSP_SIS_AccountHandler.BLOCK_EXECUTION = true;
            
            account.EF_SIS_Code__c = inputData.MemberAccountingCode;
            account.EF_SIS_Designator__c = inputData.MemberDesignator;
            account.SIS_Status__c = inputData.ISMembershipStatus;
            account.SIS_Sub_Status__c = inputData.IsMembershipSubStatus;
            if (inputData.ISEntryDate!=null) account.SIS_Entry_Date__c = strToDate(inputData.ISEntryDate);
            account.ICH_Member__c = convertMember(inputData.ICHMembershipStatus);
            account.ACH_Member__c = convertMember(inputData.ACHMembershipStatus);
            update account;
            
        } catch (Exception e) {
            throw new ISSP_WS_SIS_Common.WSException('001',e.getMessage());
        }
        return account;
    }
    
    private static Boolean convertMember(String member) {
        Boolean result = MAP_MEMBER_CONVERSION.get(member.toUpperCase());
        return result==null? false: result;
    }
    
    /**
        Creates the response object for updateAccount WS when it is success
    **/
    private static ResponseData createResponseSuccess(InputData inputData, Account account) {
        insertSuccessLog(inputData, account);
        ResponseData response = new ResponseData();
        response.IsSuccess = true;
        response.SISMemberID = account.SIS_ID__c;
        response.ErrorCode = '';
        response.ErrorDescription = '';
        return response;
    }
    
    /**
        Creates the response object for updateAccount WS when it has an error
    **/
    private static ResponseData createResponseError(InputData inputData, ISSP_WS_SIS_Common.WSException wsException, Account account) {
        insertErrorLog(inputData, wsException, account);
        ResponseData response = new ResponseData();
        response.IsSuccess = false;
        response.SISMemberID = inputData.SISMemberID;
        response.ErrorCode = wsException.errorCode;
        response.ErrorDescription = wsException.description;
        return response;
    }
    
    /**
        Creates and inserts a new log with a Success
    **/
    private static void insertSuccessLog(InputData inputData, Account account) {
        ISSP_Web_Service_Log__c log = createLog(inputData, account);
        log.Success__c = true;
        log.Error_Code__c = '';
        log.Error_Message__c = '';
        log.User__c = null;
        log.Contact__c = null;
        insert log;
    }
    
    /**
        Creates and inserts a new log with an Error
    **/
    private static void insertErrorLog(InputData inputData, ISSP_WS_SIS_Common.WSException wsException, Account account) {
        ISSP_Web_Service_Log__c log = createLog(inputData, account);
        log.Success__c = false;
        log.Error_Code__c = wsException.errorCode;
        log.Error_Message__c = wsException.description;
        insert log;
    }
    
    /**
        Convert string from SIS to a valid Date
    **/
    private static final map<String,Integer> MONTHS  = new map<String,Integer>{
        'JAN' => 1,'FEB' => 2,'MAR' => 3,'APR' => 4,'MAY' => 5,'JUN' => 6,
        'JUL' => 7,'AUG' => 8,'SEP' => 9,'OCT' => 10,'NOV' => 11,'DEC' => 12
    };
    private static Date strToDate(String str) {
        try {
            String[] part = str.split('-');
            Integer day = Integer.valueOf(part[0]);
            Integer month = MONTHS.get(part[1]);
            Integer year = Integer.valueOf(part[2]);
            return Date.newInstance(year, month, day);
        } catch (Exception e) {
            return null;
        }
    }
    
    /**
        create a basic log object
    **/
    private static ISSP_Web_Service_Log__c createLog(InputData inputData, Account account) {
        ISSP_Web_Service_Log__c log = new ISSP_Web_Service_Log__c();
        log.Web_Service__c = 'ISSP_WS_SIS_UpdateAccount';
        log.Method__c = 'updateSISAccount';
        log.System__c = inputData.TypeOfService;
        log.Login_Ip__c = ISSP_WS_SIS_Common.getLoginIP();
        log.Input_Description__c = 'User Id: ' + UserInfo.getUsername() + '\n';
        log.Input_Description__c +='SISMemberID' + inputData.SISMemberID + '\n';
        log.Input_Description__c +='MemberAccountingCode' + inputData.MemberAccountingCode + '\n';
        log.Input_Description__c +='MemberDesignator' + inputData.MemberDesignator + '\n';
        log.Input_Description__c +='ISMembershipStatus' + inputData.ISMembershipStatus + '\n';
        log.Input_Description__c +='IsMembershipSubStatus' + inputData.IsMembershipSubStatus + '\n';
        log.Input_Description__c +='ISEntryDate' + inputData.ISEntryDate + '\n';
        log.Input_Description__c +='ICHMembershipStatus' + inputData.ICHMembershipStatus + '\n';
        log.Input_Description__c +='ACHMembershipStatus' + inputData.ACHMembershipStatus + '\n';
        log.Input_Description__c +='TypeOfService' + inputData.TypeOfService + '\n';
        log.Input_Description__c +='RequestType' + inputData.RequestType + '\n';
        log.Finished__c = system.now();
        log.Account__c = account==null? null: account.Id;
        return log;
    }

}