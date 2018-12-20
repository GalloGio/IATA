/**
 * Class created to keep logic separated from the TaskTrigger.
 *
 * unit test class: FDSKPIReportingTest
 */
public with sharing class TaskTriggerHelper {

    public static final String CASE_ACTION_CREATING_A_TASK = 'Creating a Task';

    public static String cscRTId = [SELECT Id FROM RecordType WHERE sObjectType = 'FDS_KPI_Reporting__c' and DeveloperName = 'CSC' LIMIT 1].Id;
    public static List<ISSP_KPI_Reporting__mdt> config = new List<ISSP_KPI_Reporting__mdt>();
    public static Map<String, ISSP_KPI_Reporting__mdt> configToPointsMap = new Map<String, ISSP_KPI_Reporting__mdt>();
    public static Map<String, ISSP_KPI_Reporting__mdt> configMap = new Map<String, ISSP_KPI_Reporting__mdt>();
    public static List<FDS_KPI_Reporting__c> kpiReporting = [SELECT Id, Type_Of_Action__c FROM FDS_KPI_Reporting__c WHERE Name =: CASE_ACTION_CREATING_A_TASK AND Type_Of_Action__c =: CASE_ACTION_CREATING_A_TASK];
    public static List<KPI_Value__c> kpiValuesToInsert = new List<KPI_Value__c>();

    public static void createKPIValues(Map<Id, Task> newMap, List<Task> newList, List<Task> oldList) {

        List<String> caseCreateTaskRecordTypes = new List<String>();
        Map<String, String> rtIdToDeveloperName = new Map<String, String>();
        List<RecordType> recordTypes = [SELECT ID, DeveloperName FROM RecordType WHERE sObjectType = 'Case'];
        KPI_Value__c valueToInsert = new KPI_Value__c();
        Set<String> caseIds = new Set<String>();

        for(Task t : newList){
            caseIds.add(t.WhatId);
        }

        Map<Id, Case> idToCaseMap = new Map<Id, Case>([SELECT ID, RecordTypeId FROM Case WHERE Id IN: caseIds]);

        List<Case> cases = [SELECT ID, RecordTypeId, RecordType.DeveloperName FROM Case WHERE Id IN: caseIds];
        Set<Id> taskIds = new Set<Id>();

        for(Task t : newList) {
            taskIds.add(t.Id);
        }

        List<Task> tasks = [SELECT ID, WhatId, What.RecordType.DeveloperName, TaskSubType, What.RecordTypeId FROM Task WHERE ID IN: taskIds];

        for(Case c : cases){
            for(RecordType rt : recordTypes){
                if(c.RecordTypeId == rt.Id){
                    rtIdToDeveloperName.put(rt.Id, rt.DeveloperName);
                }
            }
        }

        config = getKPIConfig(CASE_ACTION_CREATING_A_TASK);

        if(config.size() > 0) {
            for(ISSP_KPI_Reporting__mdt setting : config){
                configToPointsMap.put(setting.Action__c, setting);
            }
        }

        if(config.size() > 0) {
            for(ISSP_KPI_Reporting__mdt setting : config){
                caseCreateTaskRecordTypes.add(setting.Case_Record_Type__c);
                configMap.put(setting.Case_Record_Type__c, setting);
            }
        }

        String kpiReportingId = kpiReporting.size() > 0 ? kpiReporting.get(0).Id : createKPIReporting();

        for(Task t : tasks) {

            if(caseCreateTaskRecordTypes.contains(rtIdToDeveloperName.get(idToCaseMap.get(newMap.get(t.Id).WhatId).RecordTypeId)) &&
            t.TaskSubType == configToPointsMap.get(CASE_ACTION_CREATING_A_TASK).Type_of_Task__c) {
                System.debug('LW criteria are met - if 1');

                valueToInsert = createKPIReportingValue(t.WhatId, Integer.valueOf(configMap.get(t.What.RecordType.DeveloperName).Points__c), kpiReportingId);
                kpiValuesToInsert.add(valueToInsert);
            }
        }

        try{
            if(kpiValuesToInsert.size() > 0 ){
                insert kpiValuesToInsert;
            }
        } catch(DmlException e) {
            System.debug('Insert exception: ' + e.getMessage());
        }
    }

    /**
     * Retrieve ISSP_KPI_Reporting__mdt configration for specific type of action
     *
     * @param String - actionType
     *
     * @return List<ISSP_KPI_Reporting__mdt> - list of configs
     */
    public static List<ISSP_KPI_Reporting__mdt> getKPIConfig(String actionType) {
        String queryString = '';
        queryString = 'SELECT ' +
                'Action__c, ' +
                'Case_Record_Type__c, ' +
                'DeveloperName, ' +
                'Id, ' +
                'Points__c, ' +
                'Type_of_Task__c ' +
                'FROM ' +
                'ISSP_KPI_Reporting__mdt ' +
                'WHERE ' +
                'Action__c =: actionType ';

        return Database.query(queryString);
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
     * @description method used to return ID of existing FDS_KPI_Reporting record or to create new record.
     *
     * @return String - FDS_KPI_Reporting__c Id for KPI_Value__c
     */
    private static String createKPIReporting() {
        List<FDS_KPI_Reporting__c> kpiReportingsToInsert = new List<FDS_KPI_Reporting__c>();
        String returnMe = '';

            FDS_KPI_Reporting__c newKPIReporting = new FDS_KPI_Reporting__c();
            newKPIReporting.Type_Of_Action__c = CASE_ACTION_CREATING_A_TASK;
            newKPIReporting.Name = CASE_ACTION_CREATING_A_TASK;
            newKPIReporting.RecordTypeId = cscRTId;

            kpiReportingsToInsert.add(newKPIReporting);

        try{
            if(kpiReportingsToInsert.size() > 0 ){
                insert kpiReportingsToInsert;
            }

            returnMe = [SELECT Id FROM FDS_KPI_Reporting__c WHERE Name =: CASE_ACTION_CREATING_A_TASK AND Type_Of_Action__c =: CASE_ACTION_CREATING_A_TASK LIMIT 1].Id;
        } catch (DmlException e) {
            System.debug('DML Exception: ' + e.getMessage());
        }

        return returnMe;
    }

    public static KPI_Value__c createKPIReportingValue(String caseId, Integer points, String kpiReportingId){
        KPI_Value__c valueToAdd = new KPI_Value__c();

        valueToAdd.Name = 'Value_' + caseId + '_' + DateTime.now().hour()+'_'+DateTime.now().minute()+'_'+DateTime.now().second();
        valueToAdd.FDS_KPI_Reporting__c = kpiReportingId;
        valueToAdd.CaseNumber__c = caseId;
        valueToAdd.Month__c = convertMonthNumberToText(Integer.valueOf(Date.today().month()));
        valueToAdd.Year__c = String.valueOf(Date.today().year());
        valueToAdd.KPI_Value__c = points;
        valueToAdd.Responsible__c = UserInfo.getUserId();

        return valueToAdd;
    }
}