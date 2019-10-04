public without sharing class portalIftpHistoryManagement {

    static final Integer numberOfEventTypes = 8;
    public static final Integer Employee_Start_Working_for_ITP = 1;
    public static final Integer Employee_Stop_Working_for_ITP = 2;
    public static final Integer Employee_Start_Working_at_Station = 3;
    public static final Integer Employee_Stop_Working_at_Station = 4;
    public static final Integer Employee_Receives_Proficiency = 5;
    public static final Integer Employee_Loose_Proficiency = 6;
    public static final Integer Start_Suppression = 7;
    public static final Integer Stop_Suppression = 8;

    @AuraEnabled (cacheable=false)    
    public static void insertIntoIftpHistory(List<IFTP_History__c> iftpHistoryRecordList){
        insert iftpHistoryRecordList;
    }

    @AuraEnabled (cacheable=false)    
    public static void insertIntoIftpHistory(IFTP_History__c iftpHistoryRecord){
        List<IFTP_History__c> iftpHistoryRecordList = new List<IFTP_History__c>();
        iftpHistoryRecordList.add(iftpHistoryRecord);
        insertIntoIftpHistory(iftpHistoryRecordList);
    }

    @AuraEnabled (cacheable=false)    
    public static IFTP_History__c createIftpHistoryRecord(Integer eventType, 
                                                            String employeeCode, 
                                                            String employeeFirstName, 
                                                            String employeeLastName){

        LoggedUserInfoWrapper loggedUserInfo = getLoggedUserNameStr();
        IFTP_History__c ih;
        if(eventType  == Employee_Start_Working_for_ITP || eventType == Employee_Stop_Working_for_ITP) {
            ih = new IFTP_History__c( Event_Type__c = String.valueOf(eventType),
                                            ITP_Name__c = loggedUserInfo.ITP_name,
                                            Employee_Code__c = employeeCode,
                                            Employee_First_Name__c = employeeFirstName,
                                            Employee_Last_Name__c = employeeLastName,
                                            Logged_User__c = loggedUserInfo.logged_user_name_Str);
        }
        return ih;
    }

    @AuraEnabled (cacheable=false)    
    public static IFTP_History__c createIftpHistoryRecord(Integer eventType,
                                                            String employeeCode, 
                                                            String employeeFirstName, 
                                                            String employeeLastName,
                                                            String addressCode,
                                                            String addressCity){
        LoggedUserInfoWrapper loggedUserInfo = getLoggedUserNameStr();
        IFTP_History__c ih;
        if(eventType  == Employee_Start_Working_at_Station || eventType == Employee_Stop_Working_at_Station) {
            ih = new IFTP_History__c( Event_Type__c = String.valueOf(eventType),
                                            ITP_Name__c = loggedUserInfo.ITP_name,
                                            Employee_Code__c = employeeCode,
                                            Employee_First_Name__c = employeeFirstName,
                                            Employee_Last_Name__c = employeeLastName,
                                            Address_Code__c = addressCode,
                                            Address_City__c = addressCity,
                                            Logged_User__c = loggedUserInfo.logged_user_name_Str);
        }
        return ih;
    }

    @AuraEnabled (cacheable=false)    
    public static IFTP_History__c createIftpHistoryRecord(Integer eventType, 
                                                            String employeeCode, 
                                                            String employeeFirstName, 
                                                            String employeeLastName,
                                                            String addressCode,
                                                            String addressCity,
                                                            String certificationName,
                                                            String proficiencyLevel,
                                                            String proficiencyGrantedBy){
        LoggedUserInfoWrapper loggedUserInfo = getLoggedUserNameStr();
        IFTP_History__c ih;
        if(eventType  == Employee_Receives_Proficiency || eventType == Employee_Loose_Proficiency || eventType == Start_Suppression || eventType == Stop_Suppression) {
            ih = new IFTP_History__c( Event_Type__c = String.valueOf(eventType),
                                            ITP_Name__c = loggedUserInfo.ITP_name,
                                            Employee_Code__c = employeeCode,
                                            Employee_First_Name__c = employeeFirstName,
                                            Employee_Last_Name__c = employeeLastName,
                                            Address_Code__c = addressCode,
                                            Address_City__c = addressCity,
                                            Certification_Name__c = certificationName,
                                            Proficiency_Level__c = proficiencyLevel,
                                            Proficiency_Granted_By__c = proficiencyGrantedBy,
                                            Logged_User__c = loggedUserInfo.logged_user_name_Str);
        }
        return ih;
    }

    @AuraEnabled (cacheable=false) 
    public static LoggedUserInfoWrapper getLoggedUserNameStr(){
        Id userId = System.UserInfo.getUserId();
        Contact loggedUserInfo = [SELECT FirstName, LastName, Account.Name FROM Contact WHERE id IN (SELECT ContactId FROM user WHERE Id = :userId) LIMIT 1];

        LoggedUserInfoWrapper userWrap = new LoggedUserInfoWrapper(loggedUserInfo.Account.Name ,loggedUserInfo.FirstName, loggedUserInfo.LastName);

        return userWrap;
    }

    public class LoggedUserInfoWrapper {
        @AuraEnabled
        public String ITP_name {get;set;}
        @AuraEnabled
        public String logged_user_first_name {get;set;}
        @AuraEnabled
        public String logged_user_last_name {get;set;}
        @AuraEnabled
        public String logged_user_name_Str {get;set;}
  
        public LoggedUserInfoWrapper(String ITP_name, String logged_user_first_name, String logged_user_last_name){                                           
            this.ITP_name = ITP_name;
            this.logged_user_first_name = logged_user_first_name;
            this.logged_user_last_name = logged_user_last_name;
            this.logged_user_name_Str = logged_user_last_name.toUpperCase() + ', ' + logged_user_first_name;
        }
    }
}