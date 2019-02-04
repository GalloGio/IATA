public with sharing class CaseCommentHandler {
    public static final String CASE_COMMENT_ACTION = 'Public Case Comment';
    
    List<FDS_KPI_Reporting__c> kpiReportingsToInsert = new List<FDS_KPI_Reporting__c>();
    List<KPI_Value__c> kpiValuesToInsert = new List<KPI_Value__c>();
    
    
    public static void doBeforeInsert(list<CaseComment> listComments) {
        
        // chck if the incoming casecomment comes from E2CP process
        if (getE2cpRunUsers().contains(UserInfo.getUSerId())) {
            preventInsertionInClosedCases(listComments);
        }
    }
    
    public void doAfterInsert(List<CaseComment> listOfComments) {
        List<ISSP_KPI_Reporting__mdt> config = new List<ISSP_KPI_Reporting__mdt>();
        Map<String, ISSP_KPI_Reporting__mdt> rtToConfigMap = new Map<String, ISSP_KPI_Reporting__mdt>();
        Set<Id> recordTypesToProcess = new Set<Id>();
        
        config = getKPIConfig(CASE_COMMENT_ACTION);

        if(config.size() == 0) {
            System.debug('CaseCommentHandler: no KPI config, exiting');
            return;
        }


        for(ISSP_KPI_Reporting__mdt cfg : config){
            recordTypesToProcess.add(RecordTypeSingleton.getInstance().getRecordType('Case', cfg.Case_Record_Type__c).Id);
            rtToConfigMap.put(cfg.Case_Record_Type__c, cfg);
        }
        
        List<CaseComment> fullCaseComments = [SELECT id, isPublished, ParentId, Parent.RecordType.DeveloperName
                                              FROM CaseComment WHERE ID IN: listOfComments AND isPublished=True
                                              AND Parent.RecordTypeId IN :recordTypesToProcess];
        
        if(fullCaseComments.isEmpty()) return;
        
        List<FDS_KPI_Reporting__c> kpiReporting = [SELECT Id, Type_Of_Action__c 
                                                   FROM FDS_KPI_Reporting__c 
                                                   WHERE Name =: CASE_COMMENT_ACTION 
                                                   AND Type_Of_Action__c =: CASE_COMMENT_ACTION];
        if(kpiReporting.size() == 0) {
            System.debug('CaseCommentHandler: missing KPI reporting, exiting');
            return;
        }
        
        Id kpiReportingId = kpiReporting.get(0).Id;
        
        for (CaseComment cc : fullCaseComments) {
            if (rtToConfigMap.containsKey(cc.Parent.RecordType.DeveloperName)) {
                createKPIReportingValue(cc, Integer.valueOf(rtToConfigMap.get(cc.Parent.RecordType.DeveloperName).Points__c), kpiReportingId);
            }
        }
        
        
        try{
            if(kpiValuesToInsert.size() > 0 ) {
                insert kpiValuesToInsert;
            }
            
        } catch (DmlException e){
            System.debug('DML Exception: ' + e.getMessage());
        }
        
    }
    
    /**
* @description used to retreive KPI Configuration from custom metadata: ISSP_KPI_Reporting__mdt
*
* @param null
* @return List<ISSP_KPI_Reporting__mdt> - list of configs
*/
    private List<ISSP_KPI_Reporting__mdt> getKPIConfig(String actionType) {
        String queryString = '';
        queryString = 'SELECT ' +
            'Action__c, ' +
            'Case_Record_Type__c, ' +
            'DeveloperName, ' +
            'Id, ' +
            'Points__c ' +
            'FROM ' +
            'ISSP_KPI_Reporting__mdt ' +
            'WHERE ' +
            'Action__c =: actionType ';
        
        return Database.query(queryString);
    }
    
    /**
* @description method used to return ID of existing FDS_KPI_Reporting record or to create new record.
*
* @return String - FDS_KPI_Reporting__c Id for KPI_Value__c
*/
    private String kpiReportingExistsOrCreate() {
        List<FDS_KPI_Reporting__c> listOfKPIReportings = [SELECT Id, Type_Of_Action__c FROM FDS_KPI_Reporting__c WHERE Name =: CASE_COMMENT_ACTION AND Type_Of_Action__c =: CASE_COMMENT_ACTION];
        String returnMe = '';
        if(listOfKPIReportings.size() > 0 ) {
            returnMe = listOfKPIReportings.get(0).Id;
        } else {
            FDS_KPI_Reporting__c newKPIReporting = new FDS_KPI_Reporting__c();
            
            newKPIReporting.Type_Of_Action__c = CASE_COMMENT_ACTION;
            newKPIReporting.Name = CASE_COMMENT_ACTION;
            newKPIReporting.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'FDS_KPI_Reporting__c' and DeveloperName = 'CSC' LIMIT 1].Id;
            
            kpiReportingsToInsert.add(newKPIReporting);
        }
        
        try{
            if(kpiReportingsToInsert.size() > 0 ){
                insert kpiReportingsToInsert;
            }
            
            returnMe = [SELECT Id, Type_Of_Action__c FROM FDS_KPI_Reporting__c WHERE Name =: CASE_COMMENT_ACTION AND Type_Of_Action__c =: CASE_COMMENT_ACTION LIMIT 1].Id;
        } catch (DmlException e) {
            System.debug('DML Exception: ' + e.getMessage());
        }
        
        return returnMe;
    }
    
    /**
* @description method will create KPI_Value__c record in database for existing FDS_KPI_Reporting__c
*              with Type_Of_Action == 'Case Comment'. If not exists, then FDS_KPI_Reporting
*              will be created with Type_Of_Action == 'Case Comment'
*
* @param comment - CaseComment record
*
* @return void
*/
    private void createKPIReportingValue(CaseComment comment, Integer points, String kpiReportingId){
        
        KPI_Value__c valueToAdd = new KPI_Value__c();
        
        valueToAdd.Name = 'Value_' + comment.ParentId + '_' + DateTime.now().hour()+'_'+DateTime.now().minute()+'_'+DateTime.now().second();
        valueToAdd.FDS_KPI_Reporting__c = kpiReportingId;
        valueToAdd.CaseNumber__c = comment.ParentId;
        valueToAdd.Month__c = convertMonthNumberToText(Integer.valueOf(Date.today().month()));
        valueToAdd.Year__c = String.valueOf(Date.today().year());
        valueToAdd.KPI_Value__c = points;
        valueToAdd.Responsible__c = UserInfo.getUserId();
        
        kpiValuesToInsert.add(valueToAdd);
    }
    
    /**
* @description method used to coverts month number to Text
*
* @param month
*
* @return month name
*/
    public static String convertMonthNumberToText (Integer month) {
        String monthName = '';
        
        if(month == 1)
            monthName = 'January';
        else if (month == 2)
            monthName = 'February';
        else if (month == 3)
            monthName = 'March';
        else if (month == 4)
            monthName = 'April';
        else if (month == 5)
            monthName = 'May';
        else if (month == 6)
            monthName = 'June';
        else if (month == 7)
            monthName = 'July';
        else if (month == 8)
            monthName = 'August';
        else if (month == 9)
            monthName = 'September';
        else if (month == 10)
            monthName = 'October';
        else if (month == 11)
            monthName = 'November';
        else if (month == 12)
            monthName = 'December';
        else
            monthName = 'incorrect month';
        
        return monthName;
    }
    
    /**
If an input case comment tries to insert then it is blocked, but only if:
- case belongs to a list of RTs
- Case is closed for more than 2 weeks
- Incoming case comment is public
**/
    private static void preventInsertionInClosedCases(list<CaseComment> listComments) {
        Set<Id> caseIds = new Set<Id>();
        for (CaseComment caseComment : listComments) {
            caseIds.add(caseComment.parentId);
        }
        
        Map<Id, Case> casesMap = new Map<Id, Case>([
            SELECT Id, ClosedDate
            FROM Case
            WHERE Id IN :caseIds
            AND RecordType.DeveloperName IN :EmailMessageHandler.LIST_VALID_RT]);
        
        List<CaseComment> caseComments = new List<CaseComment>();
        for (CaseComment caseComment : listComments) {
            Case parentCase = casesMap.get(caseComment.ParentId);
            if (caseComment.IsPublished && parentCase!=null && parentCase.ClosedDate < Date.today().addDays(-14)) {
                caseComment.addError('Case Comment ignored because the parent case is closed for more than 2 weeks'); // prevent insertion
            }
        }
    }
    
    /**
Get an id list of all users runing the E2CP email service
To check this manually go to:
Setup->EmailService->select 'ProcessMessage' service->Check run users
**/
    public static set<Id> TEST_E2CPRUNUSERS = new set<id>();
    private static set<Id> getE2cpRunUsers() {
        set<Id> listRunUsers = new set<Id>();
        // Apex class in Email to Case Premium used to process incoming emails
        list<ApexClass> listClasses = [Select Id  from ApexClass where Name = 'ProcessMessage'];
        //Find run as users related to the E2CP service
        for (EmailServicesAddress serviceAddress: [
            SELECT Id, RunAsUserId
            FROM EmailServicesAddress
            WHERE Function.ApexClassId IN :listClasses])
        {
            listRunUsers.add(serviceAddress.RunAsUserId);
        }
        return Test.isRunningTest()? TEST_E2CPRUNUSERS: listRunUsers;
    }
}