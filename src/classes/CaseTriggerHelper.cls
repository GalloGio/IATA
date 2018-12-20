
/**
 * Class created as helper to keep logic separated from the CaseAfterTrigger.
 *
 * unit test class: FDSKPIReportingTest
 */
public with sharing class CaseTriggerHelper {

    public static String cscRTId = [SELECT Id FROM RecordType WHERE sObjectType = 'FDS_KPI_Reporting__c' and DeveloperName = 'CSC' LIMIT 1].Id;
    public static final String CASE_STATUS_CLOSED = 'Closed';
    public static final String CASE_STATUS_ESCALATED_INTERNALLY = 'Escalated Internally';
    public static final String CASE_ACTION_PUBLIC_COMMENT = 'Public Case Comment';
    public static final String CASE_ACTION_CASE_CLOSURE = 'Case Closure';
    public static final String CASE_ACTION_CASE_ESCALATION = 'Case Escalation';
    public static final String CASE_ACTION_CASE_REOPENING = 'Case Reopening';
    public static final String CASE_ACTION_CREATING_A_TASK = 'Creating a Task';
    public static final String CASE_ACTION_SEND_NOI = 'Send NOI';

    public static List<String> actionTypes = new List<String>{CASE_ACTION_CASE_CLOSURE, CASE_ACTION_CASE_ESCALATION, CASE_ACTION_CASE_REOPENING, CASE_ACTION_SEND_NOI};


    public static Boolean isDone = false;

    public static List<KPI_Value__c> kpiValuesToInsert = new List<KPI_Value__c>();


    public static List<FDS_KPI_Reporting__c> kpiReporting = [SELECT Id, Type_Of_Action__c FROM FDS_KPI_Reporting__c WHERE Name IN: actionTypes AND Type_Of_Action__c IN: actionTypes];
    public static Map<String, FDS_KPI_Reporting__c> actionToKPIReportingMap = new Map<String, FDS_KPI_Reporting__c>();

    public static void createKPIValues(Map<Id, Case> oldMap, Map<Id, Case> newMap, List<Case> newList) {

        KPI_Value__c valueToInsert = new KPI_Value__c();
        Set<Id> caseIds = new Set<Id>();
        List<Case> cases = new List<Case>();
        List<ISSP_KPI_Reporting__mdt> configs = getKPIConfig(actionTypes);

        //key1: type of action, key2: recordtype
        Map<String, Map<String, ISSP_KPI_Reporting__mdt>> configsMap = new Map<String, Map<String, ISSP_KPI_Reporting__mdt>>();

        for(Case c : newList){
            caseIds.add(c.Id);
        }

        cases = [SELECT Id, RecordTypeId, RecordType.DeveloperName, Status, Reopening_reason__c, NOI_sent__c FROM Case WHERE Id IN: caseIds];

        for(ISSP_KPI_Reporting__mdt cfg : configs) {
            if(cfg.Action__c == CASE_ACTION_CASE_CLOSURE){
                if(configsMap.containsKey(CASE_ACTION_CASE_CLOSURE)){
                    configsMap.get(CASE_ACTION_CASE_CLOSURE).put(cfg.Case_Record_Type__c, cfg);
                } else {
                    configsMap.put(CASE_ACTION_CASE_CLOSURE, new Map<String, ISSP_KPI_Reporting__mdt>());
                    configsMap.get(CASE_ACTION_CASE_CLOSURE).put(cfg.Case_Record_Type__c, cfg);
                }
            } else if(cfg.Action__c == CASE_ACTION_CASE_ESCALATION){
                if(configsMap.containsKey(CASE_ACTION_CASE_ESCALATION)){
                    configsMap.get(CASE_ACTION_CASE_ESCALATION).put(cfg.Case_Record_Type__c, cfg);
                } else {
                    configsMap.put(CASE_ACTION_CASE_ESCALATION, new Map<String, ISSP_KPI_Reporting__mdt>());
                    configsMap.get(CASE_ACTION_CASE_ESCALATION).put(cfg.Case_Record_Type__c, cfg);
                }
            } else if(cfg.Action__c == CASE_ACTION_CASE_REOPENING){
                if(configsMap.containsKey(CASE_ACTION_CASE_REOPENING)){
                    configsMap.get(CASE_ACTION_CASE_REOPENING).put(cfg.Case_Record_Type__c, cfg);
                } else {
                    configsMap.put(CASE_ACTION_CASE_REOPENING, new Map<String, ISSP_KPI_Reporting__mdt>());
                    configsMap.get(CASE_ACTION_CASE_REOPENING).put(cfg.Case_Record_Type__c, cfg);
                }
            } else if(cfg.Action__c == CASE_ACTION_SEND_NOI){
                if(configsMap.containsKey(CASE_ACTION_SEND_NOI)){
                    configsMap.get(CASE_ACTION_SEND_NOI).put(cfg.Case_Record_Type__c, cfg);
                } else {
                    configsMap.put(CASE_ACTION_SEND_NOI, new Map<String, ISSP_KPI_Reporting__mdt>());
                    configsMap.get(CASE_ACTION_SEND_NOI).put(cfg.Case_Record_Type__c, cfg);
                }
            }
        }

        for(FDS_KPI_Reporting__c parent : kpiReporting){
            actionToKPIReportingMap.put(parent.Type_Of_Action__c, parent);
        }


        String kpiReportingClosureId = actionToKPIReportingMap.containsKey(CASE_ACTION_CASE_CLOSURE) ? actionToKPIReportingMap.get(CASE_ACTION_CASE_CLOSURE).Id : createKPIReporting(CASE_ACTION_CASE_CLOSURE);
        String kpiReportingEscalationId = actionToKPIReportingMap.containsKey(CASE_ACTION_CASE_ESCALATION) ? actionToKPIReportingMap.get(CASE_ACTION_CASE_ESCALATION).Id : createKPIReporting(CASE_ACTION_CASE_ESCALATION);
        String kpiReportingReopeningId = actionToKPIReportingMap.containsKey(CASE_ACTION_CASE_REOPENING) ? actionToKPIReportingMap.get(CASE_ACTION_CASE_REOPENING).Id : createKPIReporting(CASE_ACTION_CASE_REOPENING);
        String kpiReportingNOIId = actionToKPIReportingMap.containsKey(CASE_ACTION_SEND_NOI) ? actionToKPIReportingMap.get(CASE_ACTION_SEND_NOI).Id : createKPIReporting(CASE_ACTION_SEND_NOI);

        List<String> oldStatuses = new List<String>();
        for(Case c : cases){

            //case closure
            if(newMap.get(c.Id).Status == 'Closed' && configsMap.get(CASE_ACTION_CASE_CLOSURE).keySet().contains(c.RecordType.DeveloperName)){
                oldStatuses = configsMap.get(CASE_ACTION_CASE_CLOSURE).get(c.RecordType.DeveloperName).Status_From__c.split(',');
                system.debug('LWLWLW: ' + oldStatuses);

                if(oldStatuses.contains(oldMap.get(c.Id).Status)){
                    valueToInsert = createKPIReportingValue(c, Integer.valueOf(configsMap.get(CASE_ACTION_CASE_CLOSURE).get(c.RecordType.DeveloperName).Points__c), kpiReportingClosureId);
                    kpiValuesToInsert.add(valueToInsert);
                }
            } else
             //case escalation
             if(newMap.get(c.Id).Status == 'Escalated Internally' && configsMap.get(CASE_ACTION_CASE_ESCALATION).keySet().contains(c.RecordType.DeveloperName)){
                 oldStatuses = configsMap.get(CASE_ACTION_CASE_ESCALATION).get(c.RecordType.DeveloperName).Status_From__c.split(',');

                 if(oldStatuses.contains(oldMap.get(c.Id).Status)){
                     valueToInsert = createKPIReportingValue(c, Integer.valueOf(configsMap.get(CASE_ACTION_CASE_ESCALATION).get(c.RecordType.DeveloperName).Points__c), kpiReportingEscalationId);
                     kpiValuesToInsert.add(valueToInsert);
                 }
             } else
             //case reopening
             if(newMap.get(c.Id).Status == 'Reopen' && oldMap.get(c.Id).Status == 'Closed' && configsMap.get(CASE_ACTION_CASE_REOPENING).keySet().contains(c.RecordType.DeveloperName)){
                 List<String> reopenReason = configsMap.get(CASE_ACTION_CASE_REOPENING).get(c.RecordType.DeveloperName).Reopening_Reason__c.split(',');

                 if(reopenReason.contains(c.Reopening_reason__c)){
                     valueToInsert = createKPIReportingValue(c, Integer.valueOf(configsMap.get(CASE_ACTION_CASE_REOPENING).get(c.RecordType.DeveloperName).Points__c), kpiReportingReopeningId);
                     kpiValuesToInsert.add(valueToInsert);
                 }
             }
            //NOI sent
            if(newMap.get(c.Id).NOI_sent__c != null && oldMap.get(c.Id).NOI_sent__c == null && configsMap.get(CASE_ACTION_SEND_NOI).keySet().contains(c.RecordType.DeveloperName)){
                valueToInsert = createKPIReportingValue(c, Integer.valueOf(configsMap.get(CASE_ACTION_SEND_NOI).get(c.RecordType.DeveloperName).Points__c), kpiReportingNOIId);
                kpiValuesToInsert.add(valueToInsert);
            }
        }

        try{
            if(kpiValuesToInsert.size() > 0 ){
                insert kpiValuesToInsert;
            }
        } catch(DmlException e) {
            system.debug('LW insert error: ' + e.getMessage());
        }

        if(!Test.isRunningTest()){
            CaseTriggerHelper.isDone = true;
        }
    }




    /**
     * Retrieve ISSP_KPI_Reporting__mdt configration for specific type of action
     *
     * @param String - actionType
     *
     * @return List<ISSP_KPI_Reporting__mdt> - list of configs
     */
    public static List<ISSP_KPI_Reporting__mdt> getKPIConfig(List<String> actionTypes) {
        String queryString = '';

        queryString = 'SELECT ' +
                'Id, Action__c, Case_Record_Type__c, Field_API_Name__c, Points__c, Reopening_Reason__c, Status_From__c, Status_To__c, Type_of_Task__c, Value_From__c, Value_To__c ' +
                'FROM ' +
                'ISSP_KPI_Reporting__mdt WHERE Action__c IN: actionTypes';

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
     * @param String - actionType
     *
     * @return String - FDS_KPI_Reporting__c Id for KPI_Value__c
     */
    public static String createKPIReporting(String actionType) {
        List<FDS_KPI_Reporting__c> kpiReportingsToInsert = new List<FDS_KPI_Reporting__c>();
        String returnMe = '';

        FDS_KPI_Reporting__c newKPIReporting = new FDS_KPI_Reporting__c();
        newKPIReporting.Type_Of_Action__c = actionType;
        newKPIReporting.Name = actionType;
        newKPIReporting.RecordTypeId = cscRTId;

        kpiReportingsToInsert.add(newKPIReporting);

        try{
            if(kpiReportingsToInsert.size() > 0 ){
                insert kpiReportingsToInsert;
            }

            returnMe = [SELECT Id FROM FDS_KPI_Reporting__c WHERE Name =: actionType AND Type_Of_Action__c =: actionType LIMIT 1].Id;
        } catch (DmlException e) {
            System.debug('DML Exception: ' + e.getMessage());
        }

        return returnMe;
    }

    public static KPI_Value__c createKPIReportingValue(Case caseToProcess, Integer points, String kpiReportingId){
        KPI_Value__c valueToAdd = new KPI_Value__c();

        valueToAdd.Name = 'Value_' + caseToProcess.Id + '_' + DateTime.now().hour()+'_'+DateTime.now().minute()+'_'+DateTime.now().second();
        valueToAdd.FDS_KPI_Reporting__c = kpiReportingId;
        valueToAdd.CaseNumber__c = caseToProcess.Id;
        valueToAdd.Month__c = convertMonthNumberToText(Integer.valueOf(Date.today().month()));
        valueToAdd.Year__c = String.valueOf(Date.today().year());
        valueToAdd.KPI_Value__c = points;
        valueToAdd.Responsible__c = UserInfo.getUserId();

        return valueToAdd;
    }

}