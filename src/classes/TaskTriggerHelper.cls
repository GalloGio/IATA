/**
 * Class created to keep logic separated from the TaskTrigger.
 *
 * unit test class: FDSKPIReportingTest
 */
public with sharing class TaskTriggerHelper {

    public static final String CASE_ACTION_CREATING_A_TASK = 'Creating a Task';    
    public static List<ISSP_KPI_Reporting__mdt> config = new List<ISSP_KPI_Reporting__mdt>();
    
    public static void createKPIValues(Map<Id, Task> newMap, List<Task> newList, List<Task> oldList) {
        List<KPI_Value__c> kpiValuesToInsert = new List<KPI_Value__c>();
        Map<String, ISSP_KPI_Reporting__mdt> configToPointsMap = new Map<String, ISSP_KPI_Reporting__mdt>();
        Map<String, ISSP_KPI_Reporting__mdt> configMap = new Map<String, ISSP_KPI_Reporting__mdt>();
        config = getKPIConfig(CASE_ACTION_CREATING_A_TASK);
        List<Id> confRTs = new List<Id>();
     
        if(config.size() > 0) {
            for(ISSP_KPI_Reporting__mdt setting : config){
                confRTs.add(RecordTypeSingleton.getInstance().getRecordType('Case', setting.Case_Record_Type__c).Id);
                configMap.put(setting.Case_Record_Type__c, setting);
                configToPointsMap.put(setting.Action__c, setting);
            }
        } else {
            System.debug('KPI Reporting config not present, but it should be! Exiting...');
            return;
        }
        
        List<Task> tasks = [SELECT ID, WhatId, What.RecordType.DeveloperName, TaskSubType, What.RecordTypeId 
                            FROM Task WHERE What.RecordTypeId IN :confRTs AND ID IN :newList];

        
        List<FDS_KPI_Reporting__c> kpiReporting = [SELECT Id, Type_Of_Action__c FROM FDS_KPI_Reporting__c WHERE Name =: CASE_ACTION_CREATING_A_TASK AND Type_Of_Action__c =: CASE_ACTION_CREATING_A_TASK];
        
        if(kpiReporting.size() == 0) {
             System.debug('KPI Reporting  not present, but it should be! Exiting...');
            return;
        }
        String kpiReportingId = kpiReporting.get(0).Id;
        for(Task t : tasks) {

            if(t.TaskSubType == configToPointsMap.get(CASE_ACTION_CREATING_A_TASK).Type_of_Task__c) {
                System.debug('LW criteria are met - if 1');
                String rtDevName = RecordTypeSingleton.getInstance().getRecordTypeById('Case', t.What.RecordTypeId).developerName;
                KPI_Value__c valueToInsert = createKPIReportingValue(t.WhatId, Integer.valueOf(configMap.get(rtDevName).Points__c), kpiReportingId);
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