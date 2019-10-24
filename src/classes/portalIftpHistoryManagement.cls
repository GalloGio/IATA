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
                                                            String itpName, 
                                                            String employeeFirstName, 
                                                            String employeeLastName){

        IFTP_History__c ih;
        if(eventType  == Employee_Start_Working_for_ITP || eventType == Employee_Stop_Working_for_ITP) {
            ih = new IFTP_History__c( Event_Type__c = String.valueOf(eventType),
                                            ITP_Name__c = itpName,
                                            Employee_Code__c = employeeCode,
                                            Employee_First_Name__c = employeeFirstName,
                                            Employee_Last_Name__c = employeeLastName,
                                            Logged_User__c = employeeLastName.toUpperCase() + ', ' + employeeFirstName);
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

    @AuraEnabled (cacheable=false) 
    public static List<ITPReportWrapper> getProficiencyReport(String itpName, String monthValue, String yearValue){

        System.debug('[portalIftpHistoryManagement - getProficiencyReport]: INTI');

        Map<String,String> results = new Map<String,String>();

        
        Integer nextMonth = Integer.valueOf(monthValue) + 1;
        Integer previousMonth = Integer.valueOf(monthValue) - 1;

        Integer numberOfDaysPreviousMonth = Date.daysInMonth(Integer.valueOf(yearValue), previousMonth);
        
        Datetime checkDate = DateTime.newInstance(Integer.valueOf(yearValue), nextMonth, 1, 0, 0, 0);
        Datetime checkDateNextMonth = Datetime.newinstance(Integer.valueOf(yearValue), nextMonth, 1, 0, 0, 0);
        Date checkDatePreviousMonth = Date.newInstance(Integer.valueOf(yearValue), previousMonth, numberOfDaysPreviousMonth);

        //Get Account Id
        Account accId = [SELECT Id
                            FROM Account
                            WHERE Name = :itpName 
                            AND Sector__c = 'Airline Supplier' AND Category__c = 'Fuel Supplier' 
                            LIMIT 1];

        // Get Woring Employees List
        List<IFTP_History__c> workingEmployeesList = [SELECT ITP_Name__c, 
                                                                    Event_Type__c,
                                                                    Employee_Code__c,
                                                                    CreatedDate
                                                                FROM IFTP_History__c
                                                                WHERE ITP_Name__c = :itpName
                                                                AND CreatedDate < :checkDate
                                                                AND Event_Type__c in ('1','2')
                                                                ORDER BY Employee_Code__c, Address_Code__c, CreatedDate];

        System.debug('[portalIftpHistoryManagement - getProficiencyReport]: itpName:' + itpName);
        System.debug('[portalIftpHistoryManagement - getProficiencyReport]: checkDate:' + checkDate);
        System.debug('[portalIftpHistoryManagement - getProficiencyReport]: workingEmployeesList:' + workingEmployeesList);
        System.debug('[portalIftpHistoryManagement - getProficiencyReport]: workingEmployeesList.Size():' + workingEmployeesList.Size());

        String currentEmp = '';
        Set<String> workingEmp = new Set<String>();
        Boolean isWorking = false;

        for(IFTP_History__c rec : workingEmployeesList){
    
            if(currentEmp != rec.Employee_Code__c){
                //Check 1st employee
                if(currentEmp == ''){
                    currentEmp = rec.Employee_Code__c;
                }else{
                    //reset for new employee
                    isWorking = false;
                    currentEmp = rec.Employee_Code__c;
                }
            }

            String createdMonth = String.valueOf(rec.CreatedDate.month());
            String createdYear = String.valueOf(rec.CreatedDate.year());

            if(Integer.valueOf(createdMonth) <= Integer.valueOf(monthValue) && Integer.valueOf(createdYear) <= Integer.valueOf(yearValue)){

                //Check ITP
                // 1 - Employee Start Working for ITP 
                if(rec.Event_Type__c == '1'){
                    isWorking = true;
                    if(!workingEmp.contains(currentEmp)){
                        workingEmp.add(currentEmp);
                    }
                }
                // 2 - Employee Stop Working for ITP 
                if(rec.Event_Type__c == '2'){
                    isWorking = false;
                    //Only remove from list if the month NOT equal the current Month
                    if(Integer.valueOf(createdMonth) < Integer.valueOf(monthValue) ){
                        if(workingEmp.contains(currentEmp)){
                            workingEmp.remove(currentEmp);
                        }
                    }
                }
               
            }
        }

        //Check Last User from previous cycle
        if(isWorking){
            workingEmp.add(currentEmp);
        }
        System.debug('[portalIftpHistoryManagement - getProficiencyReport]: workingEmp:' + workingEmp);

        // Get Proficiency Employees List
        List<IFTP_History__c> proficiencyEmployeesList = [SELECT ITP_Name__c, 
                                                                    Event_Type__c,
                                                                    Employee_Code__c,
                                                                    CreatedDate,
                                                                    Certification_Name__c,
                                                                    Proficiency_Level__c
                                                                FROM IFTP_History__c
                                                                WHERE ITP_Name__c = :itpName
                                                                AND CreatedDate < :checkDate
                                                                AND Event_Type__c in ('5','6')
                                                                AND Employee_Code__c IN :workingEmp
                                                                ORDER BY Employee_Code__c, Address_Code__c, CreatedDate];
        
        System.debug('[portalIftpHistoryManagement - getProficiencyReport]: proficiencyEmployeesList:' + proficiencyEmployeesList);
        System.debug('[portalIftpHistoryManagement - getProficiencyReport]: proficiencyEmployeesList.Size():' + proficiencyEmployeesList.Size());

        currentEmp = '';
        Map<String,Set<String>> mapProfEmp = new Map<String,Set<String>>();
        
        for(IFTP_History__c rec : proficiencyEmployeesList){
            
            if(currentEmp != rec.Employee_Code__c){
                //Check 1st employee
                if(currentEmp == ''){
                    currentEmp = rec.Employee_Code__c;
                }else{
                    //reset for new employee
                    // isWorking = false;
                    currentEmp = rec.Employee_Code__c;
                }
            }

            String createdMonth = String.valueOf(rec.CreatedDate.month());
            String createdYear = String.valueOf(rec.CreatedDate.year());

            if(Integer.valueOf(createdMonth) <= Integer.valueOf(monthValue) && Integer.valueOf(createdYear) <= Integer.valueOf(yearValue)){

                //Check ITP
                // 5 - Employee Receives Proficiency 
                if(rec.Event_Type__c == '5'){
                    Set<String> auxSet = new Set<String>();

                    //Checks for proficiency
                    if(rec.Proficiency_Level__c == 'Yes'){
                        if(mapProfEmp.containsKey(rec.Employee_Code__c)){
                            auxSet = mapProfEmp.get(rec.Employee_Code__c);
                        }
                        auxSet.add(rec.Certification_Name__c);
                        mapProfEmp.put(rec.Employee_Code__c, auxSet);
                    }
                }
                // 6 - Employee Loose Proficiency 
                if(rec.Event_Type__c == '6'){

                    //Only remove from list if the month NOT equal the current Month
                    if(Integer.valueOf(createdMonth) < Integer.valueOf(monthValue) ){
                        Set<String> auxSet = new Set<String>();

                        if(mapProfEmp.containsKey(rec.Employee_Code__c)){
                            auxSet = mapProfEmp.get(rec.Employee_Code__c);
                            if(auxSet.contains(rec.Certification_Name__c)){
                                auxSet.remove(rec.Certification_Name__c);
                            }
                            mapProfEmp.put(rec.Employee_Code__c, auxSet);
                        }
                    }                                          
                }
               
            }
        }

        System.debug('[portalIftpHistoryManagement - getProficiencyReport]: mapProfEmp:' + mapProfEmp);
        

        //Get All certifications
        List<IFTP_Certification_Detail__c> preReqCerts = [SELECT Certification__c, General_Training__c, Prerequisite_Level__c, Name 
            FROM IFTP_Certification_Detail__c];

        System.debug('[portalIftpHistoryManagement - getProficiencyReport]: preReqCerts:' + preReqCerts);
        System.debug('[portalIftpHistoryManagement - getProficiencyReport]: preReqCerts.size():' + preReqCerts.size());

        Set<Id> listCert = new Set<Id>();
        Set<Id> listCertL2 = new Set<Id>();
        Set<Id> listCertL3 = new Set<Id>();
        Set<Id> listPreReqCert = new Set<Id>();
        Set<Id> listPreReqCertL2 = new Set<Id>();
        Set<Id> listPreReqCertL3 = new Set<Id>();
        for(IFTP_Certification_Detail__c rec : preReqCerts){

            if(rec.General_Training__c == 'Yes'){
                listPreReqCert.add(rec.Certification__c);
                if(rec.Prerequisite_Level__c == 'Level 2'){
                    listPreReqCertL2.add(rec.Certification__c);
                }
                if(rec.Prerequisite_Level__c == 'Level 3'){
                    listPreReqCertL3.add(rec.Certification__c);
                }
            }else{
                // listCert.add(rec.Certification__c); //IFTP-318 - fast correction only L2 certifications be counted
                if(rec.Prerequisite_Level__c == 'Level 2'){
                    listCert.add(rec.Certification__c); //IFTP-318 - fast correction only L2 certifications be counted
                    listCertL2.add(rec.Certification__c);
                }
                if(rec.Prerequisite_Level__c == 'Level 3'){
                    listCertL3.add(rec.Certification__c);
                }
            }
        }

        List<Account_Contact_Role__c> lContRoleEmpType = [SELECT Company_Code__c, Contact_Role__c, Service_Rendered__c, Status__c, 
                                Contact__r.AccountId, Contact__r.Account.name
                            FROM Account_Contact_Role__c  
                            WHERE Company_Code__c IN :workingEmp
                            AND Contact__r.AccountId = :accId.Id
                            AND Service_Rendered__c = 'IFTP'];

        Map<String,String> empType = new Map<String,String>();  
        Map<String,String> accInfo = new Map<String,String>();

        for(Account_Contact_Role__c rec : lContRoleEmpType){
            empType.put(rec.Company_Code__c, rec.Contact_Role__c);
            accInfo.put(rec.Contact__r.Account.name, rec.Contact__r.AccountId);
        }

        //IFTP-313 - remove the expiry date filter
        // List<AggregateResult> lContRoleCerts = [SELECT Account_Contact_Role__r.Company_Code__c,
        //                         Certification__c, Certification__r.Code__c, Certification__r.Name
        //                     FROM Contact_Role_Certification__c  
        //                     WHERE Account_Contact_Role__r.Company_Code__c IN :workingEmp
        //                     AND Account_Contact_Role__r.Contact__r.AccountId = :accId.Id
        //                     AND Certification__c IN :listCert
        //                     AND createddate < :checkDateNextMonth
        //                     AND Expiration_Date__c > :checkDatePreviousMonth 
        //                     GROUP BY Account_Contact_Role__r.Company_Code__c,
        //                         Certification__c, Certification__r.Code__c, Certification__r.Name ];
       List<AggregateResult> lContRoleCerts = [SELECT Account_Contact_Role__r.Company_Code__c,
                                Certification__c, Certification__r.Code__c, Certification__r.Name
                            FROM Contact_Role_Certification__c  
                            WHERE Account_Contact_Role__r.Company_Code__c IN :workingEmp
                            AND Account_Contact_Role__r.Contact__r.AccountId = :accId.Id
                            AND Certification__c IN :listCert
                            AND createddate < :checkDateNextMonth
                            GROUP BY Account_Contact_Role__r.Company_Code__c,
                                Certification__c, Certification__r.Code__c, Certification__r.Name ];
  
        System.debug('[portalIftpHistoryManagement - getProficiencyReport]: lContRoleCerts:' + lContRoleCerts);
        System.debug('[portalIftpHistoryManagement - getProficiencyReport]: lContRoleCerts:' + lContRoleCerts.size());

        currentEmp = '';
        Integer numberModules = 0;
        Map<String,Integer> empModules = new Map<String,Integer>();
        
        for(AggregateResult rec : lContRoleCerts){

            if(currentEmp != (String)rec.get('Company_Code__c')){
                 //Check 1st employee
                if(currentEmp == ''){
                    currentEmp =  (String)rec.get('Company_Code__c');
                }else{
                    //reset for new employee
                    numberModules = 0;
                    currentEmp = (String)rec.get('Company_Code__c');
                }
            }

            if(mapProfEmp.containsKey(currentEmp)){
                Set<String> auxSet2 = mapProfEmp.get(currentEmp);
                if(auxSet2.contains((String)rec.get('Name'))){
                    numberModules++;
                }
            }

            empModules.put(currentEmp, numberModules);
            
        }

        System.debug('[portalIftpHistoryManagement - getProficiencyReport]: empModules:' + empModules);


        //add remaining working employees with 0 certifications to the list of empModules
        for(String rec : workingEmp){
            if(!empModules.containsKey(rec)){
                empModules.put(rec, 0);
            }
        }
        System.debug('[portalIftpHistoryManagement - getProficiencyReport]: empModules:' + empModules);

        //Check Last User from previous cycle
        //empModules.put(currentEmp, numberModules);

        Map<String,Integer> mapResults = new Map<String,Integer>();

        for(String rec : empModules.keySet() ){
            String ikey = String.valueOf(empModules.get(rec));
            System.debug('[portalIftpHistoryManagement - getProficiencyReport]: ikey:' + ikey);

            if(empType != null){
                String sEmpType = empType.containsKey(rec) ? empType.get(rec) : '' ;
                System.debug('[portalIftpHistoryManagement - getProficiencyReport]: sEmpType:' + sEmpType);
                if(sEmpType.contains('ITP Training Coordinator') && !sEmpType.contains('ITP Trainee')  && ikey == '0'){
                    continue;
                }
            }

            if(mapResults.containsKey(ikey)){
                Integer aux = ((Integer)mapResults.get(ikey));
                System.debug('[portalIftpHistoryManagement - getProficiencyReport]: aux:' + aux);
                aux = aux+1;
                System.debug('[portalIftpHistoryManagement - getProficiencyReport]: aux:' + aux);
                mapResults.put(ikey,aux);
            }else{
                mapResults.put(ikey,1);
            }
        }

        System.debug('[portalIftpHistoryManagement - getProficiencyReport]: mapResults:' + mapResults);

        List<ITPReportWrapper> resultList = new List<ITPReportWrapper>();

        for(Integer i = 0; i < 10 ; i++ ){
            String sI = String.valueOf(i);
            if(mapResults.containsKey(sI)){
                resultList.add(new ITPReportWrapper(itpName, accId.Id, sI, String.valueOf(mapResults.get(sI)), monthValue, yearValue));
            }else{
                 resultList.add(new ITPReportWrapper(itpName, accId.Id, sI, '0', monthValue, yearValue));
            }
        }

        

        // for(String rec : mapResults.keySet() ){
        //     resultList.add(new ITPReportWrapper(itpName, rec, String.valueOf(mapResults.get(rec))));
        // }
        
        // resultList.add(new ITPReportWrapper('Menzies', '1', '5'));
        // resultList.add(new ITPReportWrapper('Menzies', '2', '4'));
        // resultList.add(new ITPReportWrapper('Menzies', '3', '7'));
        // resultList.add(new ITPReportWrapper('Menzies', '4', '2'));
        // resultList.add(new ITPReportWrapper('Menzies', '5', '1'));
        // resultList.add(new ITPReportWrapper('Menzies', '6', '1'));
        // resultList.add(new ITPReportWrapper('Menzies', '7', '2'));
        // resultList.add(new ITPReportWrapper('Menzies', '8', '2'));
        // resultList.add(new ITPReportWrapper('Menzies', '9', '1'));
        
        return resultList;

    }

    // private boolean certExists(List<certWrapper> listRec, certWrapper rec){
    //     Boolean result = false;
    //     for(certWrapper aux: listRec){
    //         if(aux.station == rec.station && aux.certification == rec.certification && aux.proficiency == rec.proficiency){
    //             result = true;
    //             break;
    //         }
    //     }
    //     return result;
    // }

    // private List<certWrapper> addCertificate(List<certWrapper> listRec, certWrapper rec){
    //     if(!certExists(listRec,rec)){
    //         listRec.add(rec);
    //     }
    //     return listRec;
    // }

    // private List<certWrapper> removeCertificate(List<certWrapper> listRec, certWrapper rec){
    //     // for(certWrapper aux: listRec){
    //     for(Integer i = 0; i < listRec.size(); i++){
    //         if(listRec.get(i).station == rec.station && listRec.get(i).certification == rec.certification && listRec.get(i).proficiency == rec.proficiency){
    //             listRec.remove(i);
    //             break;
    //         }
    //     }
    //     return listRec;
    // }

    // private List<certWrapper> removeAllStationCertificate(List<certWrapper> listRec, String station){
    //     // for(certWrapper aux: listRec){
    //     for(Integer i = 0; i < listRec.size(); i++){
    //         if(listRec.get(i).station == station){
    //             listRec.remove(i);
    //         }
    //     }
    //     return listRec;
    // }


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

    // public class certWrapper {
    //     @AuraEnabled
    //     public String station {get;set;}
    //     @AuraEnabled
    //     public String certification {get;set;}
    //     @AuraEnabled
    //     public String proficiency {get;set;}
        
    //     public certWrapper(String station, String certification, String proficiency){                                           
    //         this.station = station;
    //         this.certification = certification;
    //         this.proficiency = proficiency;
    //     }
    // }

    public class ITPReportWrapper {
        @AuraEnabled
        public String ITP_name {get;set;}
        @AuraEnabled
        public String accountId {get;set;}
        @AuraEnabled
        public String numberModules {get;set;}
        @AuraEnabled
        public String numberEmployees {get;set;}
        @AuraEnabled
        public String reqMonth {get;set;}
        @AuraEnabled
        public String reqYear {get;set;}
        
        public ITPReportWrapper(String ITP_name, String accountId, String numberModules, String numberEmployees, String reqMonth, String reqYear){                                           
            this.ITP_name = ITP_name;
            this.accountId = accountId;
            this.numberModules = numberModules;
            this.numberEmployees = numberEmployees;
            this.reqMonth = reqMonth;
            this.reqYear = reqYear;
        }
    }
}