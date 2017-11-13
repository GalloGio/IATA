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
}