
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


    public static Boolean isDone = false;

    public static List<KPI_Value__c> kpiValuesToInsert = new List<KPI_Value__c>();

    public static void createKPIValues(Map<Id, Case> oldMap, Map<Id, Case> newMap, List<Case> newList) {

        KPI_Value__c valueToInsert = new KPI_Value__c();
        Map<String, ISSP_KPI_Reporting__mdt> configToPointsMap = new Map<String, ISSP_KPI_Reporting__mdt>();
        Map<String, String> rtIdToDeveloperName = new Map<String, String>();
        List<RecordType> recordTypes = [SELECT ID, DeveloperName FROM RecordType WHERE sObjectType = 'Case'];

        List<FDS_KPI_Reporting__c> listOfKPIReportings = [SELECT Id, Type_Of_Action__c FROM FDS_KPI_Reporting__c WHERE RecordTypeId =: cscRTId];
        Map<String, String> actionToKPIReportingIdMap = new Map<String,String>();

        Boolean containsClosedStatus = false;
        Boolean containsExcalatedInternallyStatus = false;
        Boolean containsReopeningReason = false;

        List<ISSP_KPI_Reporting__mdt> config = new List<ISSP_KPI_Reporting__mdt>();
        config = CaseTriggerHelper.getKPIConfig();

        //technical lists
        List<String> caseClosureStatusesFrom = new List<String>();
        List<String> caseEscalationStatusesFrom = new List<String>();
        List<String> caseReopeningStatusesFrom = new List<String>();
        List<String> caseClosureRecordTypes = new List<String>();
        List<String> caseEscalationRecordTypes = new List<String>();
        List<String> caseReopeningRecordTypes = new List<String>();
        List<String> caseNOIRecordTypes = new List<String>();

        System.debug('LW config size: ' + config.size());

        if(config.size() > 0) {
            for(ISSP_KPI_Reporting__mdt setting : config){
                configToPointsMap.put(setting.Action__c, setting);
            }
        }

        for(Case c : newList){
            for(RecordType rt : recordTypes){
                if(c.RecordTypeId == rt.Id){
                    rtIdToDeveloperName.put(rt.Id, rt.DeveloperName);
                }
            }
        }

        for(FDS_KPI_Reporting__c kpi : listOfKPIReportings) {
            actionToKPIReportingIdMap.put(kpi.Type_Of_Action__c, kpi.Id);
        }

        caseClosureStatusesFrom = configToPointsMap.get(CASE_ACTION_CASE_CLOSURE).Status_From__c.split(',');
        caseEscalationStatusesFrom = configToPointsMap.get(CASE_ACTION_CASE_ESCALATION).Status_From__c.split(',');
        caseReopeningStatusesFrom = configToPointsMap.get(CASE_ACTION_CASE_REOPENING).Status_From__c.split(',');
        caseClosureRecordTypes = configToPointsMap.get(CASE_ACTION_CASE_CLOSURE).Case_Record_Type__c.split(',');
        caseEscalationRecordTypes = configToPointsMap.get(CASE_ACTION_CASE_ESCALATION).Case_Record_Type__c.split(',');
        caseReopeningRecordTypes = configToPointsMap.get(CASE_ACTION_CASE_REOPENING).Case_Record_Type__c.split(',');
        caseNOIRecordTypes = configToPointsMap.get(CASE_ACTION_SEND_NOI).Case_Record_Type__c.split(',');

        System.debug('LW contains Closed Status: ' + containsClosedStatus);
        System.debug('LW contains Escalated Internally Status: ' + containsExcalatedInternallyStatus);



        for(Case c : newList){
            //System.debug('LW Case Status values: Status from: ' + oldMap.get(c.Id).Status + ' Status To: ' + newMap.get(c.Id).Status);
            System.debug('LW Case Status values: Status from: ' + oldMap.get(c.Id).Status + ' Status To: ' + c.Status);
            System.debug('LW oldMap: ' + oldMap.get(c.Id).Status);
            System.debug('LW newMap: ' + newMap.get(c.Id).Status);

            System.debug('LW LW LW : '+  rtIdToDeveloperName.get(newMap.get(c.Id).RecordTypeId));

            if(caseClosureStatusesFrom.contains(oldMap.get(c.Id).Status) &&
            configToPointsMap.containsKey(CASE_ACTION_CASE_CLOSURE) &&
            //configToPointsMap.get(CASE_ACTION_CASE_CLOSURE).Status_To__c == newMap.get(c.Id).Status &&
                    configToPointsMap.get(CASE_ACTION_CASE_CLOSURE).Status_To__c == c.Status &&
            //caseClosureRecordTypes.contains(rtIdToDeveloperName.get(newMap.get(c.Id).RecordTypeId))
                caseClosureRecordTypes.contains(rtIdToDeveloperName.get(c.RecordTypeId))
            ) {

                System.debug('LW if criteria are met - if 1');

                String kpiReportingId = CaseTriggerHelper.kpiReportingExistsOrCreate(CASE_ACTION_CASE_CLOSURE, actionToKPIReportingIdMap);
                System.debug('LW kpi Reporting ID: ' + kpiReportingId);


                valueToInsert = CaseTriggerHelper.createKPIReportingValue(c, Integer.valueOf(configToPointsMap.get(CASE_ACTION_CASE_CLOSURE).Points__c), kpiReportingId);
                kpiValuesToInsert.add(valueToInsert);


            } else

            if(caseEscalationStatusesFrom.contains(oldMap.get(c.Id).Status) &&
            configToPointsMap.containsKey(CASE_ACTION_CASE_ESCALATION) &&
            configToPointsMap.get(CASE_ACTION_CASE_ESCALATION).Status_To__c == newMap.get(c.Id).Status &&
            caseEscalationRecordTypes.contains(rtIdToDeveloperName.get(newMap.get(c.Id).RecordTypeId))
            ){

                System.debug('LW if criteria are met - if 2');

                String kpiReportingId = CaseTriggerHelper.kpiReportingExistsOrCreate(CASE_ACTION_CASE_ESCALATION, actionToKPIReportingIdMap);
                System.debug('LW kpi Reporting ID: ' + kpiReportingId);

                valueToInsert = CaseTriggerHelper.createKPIReportingValue(c, Integer.valueOf(configToPointsMap.get(CASE_ACTION_CASE_ESCALATION).Points__c), kpiReportingId);
                kpiValuesToInsert.add(valueToInsert);

            } else

            if(caseReopeningStatusesFrom.contains(oldMap.get(c.Id).Status) &&
            configToPointsMap.containsKey(CASE_ACTION_CASE_REOPENING) &&
            configToPointsMap.get(CASE_ACTION_CASE_REOPENING).Status_To__c == newMap.get(c.Id).Status &&
            configToPointsMap.get(CASE_ACTION_CASE_REOPENING).Reopening_reason__c == newMap.get(c.Id).Reopening_reason__c &&
            caseReopeningRecordTypes.contains(rtIdToDeveloperName.get(newMap.get(c.Id).RecordTypeId))
            ){

                System.debug('LW if criteria are met - if 3');

                String kpiReportingId = CaseTriggerHelper.kpiReportingExistsOrCreate(CASE_ACTION_CASE_REOPENING, actionToKPIReportingIdMap);
                System.debug('LW kpi Reporting ID: ' + kpiReportingId);

                valueToInsert = CaseTriggerHelper.createKPIReportingValue(c, Integer.valueOf(configToPointsMap.get(CASE_ACTION_CASE_REOPENING).Points__c), kpiReportingId);
                kpiValuesToInsert.add(valueToInsert);
            } else

            if(configToPointsMap.containsKey(CASE_ACTION_SEND_NOI) && configToPointsMap.get(CASE_ACTION_SEND_NOI) != null &&
            oldMap.get(c.Id).NOI_sent__c == null && newMap.get(c.Id).NOI_sent__c != null &&
            caseNOIRecordTypes.contains(rtIdToDeveloperName.get(newMap.get(c.Id).RecordTypeId))) {

                System.debug('LW if criteria are met - if 4');

                String kpiReportingId = CaseTriggerHelper.kpiReportingExistsOrCreate(CASE_ACTION_SEND_NOI, actionToKPIReportingIdMap);
                System.debug('LW kpi Reporting ID: ' + kpiReportingId);

                valueToInsert = CaseTriggerHelper.createKPIReportingValue(c, Integer.valueOf(configToPointsMap.get(CASE_ACTION_SEND_NOI).Points__c), kpiReportingId);
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
    public static List<ISSP_KPI_Reporting__mdt> getKPIConfig() {
        String queryString = '';

        queryString = 'SELECT ' +
                'Id, Action__c, Case_Record_Type__c, Field_API_Name__c, Points__c, Reopening_Reason__c, Status_From__c, Status_To__c, Type_of_Task__c, Value_From__c, Value_To__c ' +
                'FROM ' +
                'ISSP_KPI_Reporting__mdt';

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
    public static String kpiReportingExistsOrCreate(String actionType, Map<String, String> actionToKPIReportingIdMap) {
        List<FDS_KPI_Reporting__c> kpiReportingsToInsert = new List<FDS_KPI_Reporting__c>();
        String returnMe = '';

        if(actionToKPIReportingIdMap.containsKey(actionType)){
            returnMe = actionToKPIReportingIdMap.get(actionType);
        } else {

            FDS_KPI_Reporting__c newKPIReporting = new FDS_KPI_Reporting__c();

            newKPIReporting.Type_Of_Action__c = actionType;
            newKPIReporting.Name = actionType;
            newKPIReporting.RecordTypeId = cscRTId;

            kpiReportingsToInsert.add(newKPIReporting);
        }

        try{
            if(kpiReportingsToInsert.size() > 0 ){
                insert kpiReportingsToInsert;
            }

            returnMe = [SELECT Id, Type_Of_Action__c FROM FDS_KPI_Reporting__c WHERE Name =: actionType AND Type_Of_Action__c =: actionType LIMIT 1].Id;
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