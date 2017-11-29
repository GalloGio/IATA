/**
    Class to store shared methods and variables used in SIS Web services.
    See classes starting with ISSP_WS_SIS_...
**/
global class ISSP_WS_SIS_Common {

    public static final Id SIS_ID_PORTAL_APP = ISSP_Portal_Service_Ids__c.getInstance().SIS__c;
    public static final map<String,String> MAP_USER_TYPES = new map<String,String>{
        'S' => 'Super User',
        'R' => 'User'
    };
    public static final set<String> VALID_REQUEST_TYPES = new set<String>{'O','R'};

    /**
        Exception used to capture all errors in SIS Web services
    **/
    global class WSException extends Exception{
        public String errorCode;
        public String description;

        public WSException(String errorCode, String description) {
            this.errorCode = errorCode;
            this.description = ISSP_Int_Error__c.getValues(errorCode).Error_Message__c + ' ' + description;
        }
    }
    
    /**
        Get last IP acces for current User
        used to store the incoming user ip for the logs
    **/
    public static String getLoginIP() {
        list<LoginHistory> listHistory = [
            SELECT Id, SourceIp
            FROM LoginHistory
            WHERE UserId = :UserInfo.getUserId()
            ORDER BY LoginTime DESC LIMIT 1];

        if (listHistory.isEmpty()) return '';
        return listHistory[0].SourceIp;
    }
    
    /**
        Check if input text is a valid email
    **/
    public static final Pattern EMAIL_PATTERN = Pattern.compile('^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,13}$');
    public static Boolean isValidEmail(String checkEmail) {
        Matcher matcher = EMAIL_PATTERN.matcher(checkEmail);
        return matcher.matches();
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
            
        // prevent triggers that make callouts to SIS
        ISSP_UserTriggerHandler.preventSISIntegration = true;
        ISSP_UserTriggerHandler.preventTrigger = true;

        if (appRightList.isEmpty()){
            //create new app right
            try {
                Portal_Application_Right__c appRight = ISSP_WS_Utilities.createApp(SIS_ID_PORTAL_APP, contact.Id);

                insert appRight;
            } catch (Exception e) {
                throw new WSException('001', 'Application right creation failed ' + e.getMessage());
            }
        } else {
            //grant access to already existing app right
            Portal_Application_Right__c appRight = appRightList[0];
            if (appRight.Right__c != 'Access Granted'){
                try{
                    appRight.Right__c = 'Access Granted';
                    update appRight;
                } catch (Exception e){
                    throw new WSException('001', 'Application right update failed ' + e.getMessage());
                }
            }
        }
    }
}