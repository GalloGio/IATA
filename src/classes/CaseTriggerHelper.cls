/** 
* IATA CS Portal extension | Vanja Djurdjevic 
* Class created as helper to keep logic separated from the CaseAfterTrigger.
*
* unit test class: FDSKPIReportingTest
*/
public with sharing class CaseTriggerHelper {
    public static Boolean isDone = false;
    
    public static final String CASE_STATUS_CLOSED = 'Closed';
    public static final String CASE_STATUS_ESCALATED_INTERNALLY = 'Escalated Internally';
    public static final String CASE_STATUS_REOPEN = 'Reopen';
    
    //public static final String CASE_ACTION_PUBLIC_COMMENT = 'Public Case Comment';
    public static final String CASE_ACTION_CASE_CLOSURE = 'Case Closure';
    public static final String CASE_ACTION_CASE_ESCALATION = 'Case Escalation';
    public static final String CASE_ACTION_CASE_REOPENING = 'Case Reopening';
    //public static final String CASE_ACTION_CREATING_A_TASK = 'Creating a Task';
    public static final String CASE_ACTION_SEND_NOI = 'Send NOI';
    
    public static List<String> actionTypes = new List<String>{CASE_ACTION_CASE_CLOSURE, 
        CASE_ACTION_CASE_ESCALATION, CASE_ACTION_CASE_REOPENING, CASE_ACTION_SEND_NOI};
            
            public static List<String> caseStatuses = new List<String>{CASE_STATUS_CLOSED,
                CASE_STATUS_ESCALATED_INTERNALLY, CASE_STATUS_REOPEN};
                    
                    
                    
                    
                    public static Map<Id, KPI_Value__c> typeOfActionClosureMap = new Map<Id, KPI_Value__c>();
    
    public static void createKPIValues(Map<Id, Case> oldMap, Map<Id, Case> newMap, List<Case> newList) {
        if(isDone) return;
        Map<String, Map<String, ISSP_KPI_Reporting__mdt>> configsMap = new Map<String, Map<String, ISSP_KPI_Reporting__mdt>>();
        // initialize configs map
        for(String at: actionTypes)
            configsMap.put(at, new Map<String, ISSP_KPI_Reporting__mdt>());
        
        // get all configs since they are needed for filtering
        List<ISSP_KPI_Reporting__mdt> configs = getKPIConfig(actionTypes);
        if(configs.size() == 0) {
            System.debug('CaseTriggerHelper: missing mdt config, exiting');
            return;
        }
        
        List<KPI_Value__c> kpiValuesToInsert = new List<KPI_Value__c>();
        Map<String, FDS_KPI_Reporting__c> actionToKPIReportingMap = new Map<String, FDS_KPI_Reporting__c>();
        
        List<FDS_KPI_Reporting__c> curKPIReportings = [SELECT Id, Type_Of_Action__c 
                                                       FROM FDS_KPI_Reporting__c 
                                                       WHERE Name IN: actionTypes AND Type_Of_Action__c IN: actionTypes];
        
        System.debug('+++ got shit 2: 123456789');

        System.debug('+++ got shit: '+curKPIReportings);
        for(FDS_KPI_Reporting__c rep : curKPIReportings)
            actionToKPIReportingMap.put(rep.Type_Of_Action__c, rep);
        if(actionTypes.size() != actionToKPIReportingMap.size()) {
            // a KPI reporting for an action type is missing, abort, they all should be present
            System.debug('CaseTriggerHelper: KPI report for one of action types not present, aborting.');
            return;
        }
        
        String kpiReportingClosureId = actionToKPIReportingMap.get(CASE_ACTION_CASE_CLOSURE).Id;
        String kpiReportingEscalationId = actionToKPIReportingMap.get(CASE_ACTION_CASE_ESCALATION).Id;
        String kpiReportingReopeningId = actionToKPIReportingMap.get(CASE_ACTION_CASE_REOPENING).Id;
        String kpiReportingNOIId = actionToKPIReportingMap.get(CASE_ACTION_SEND_NOI).Id;        
        
        
        
        Set<Id> allConsidered = new Set<Id>();
        Set<Id> consideredForClosure = new Set<Id>();
        Set<Id> consideredForEscInt = new Set<Id>();
        Set<Id> consideredForReopen = new Set<Id>();
        Set<Id> consideredForNOI = new Set<Id>();
        
        
        
        
        for(ISSP_KPI_Reporting__mdt cfg : configs) {
            if(cfg.Action__c == CASE_ACTION_CASE_CLOSURE) {
                configsMap.get(CASE_ACTION_CASE_CLOSURE).put(cfg.Case_Record_Type__c, cfg);
            } else if(cfg.Action__c == CASE_ACTION_CASE_ESCALATION) {
                configsMap.get(CASE_ACTION_CASE_ESCALATION).put(cfg.Case_Record_Type__c, cfg);
            } else if(cfg.Action__c == CASE_ACTION_CASE_REOPENING) {
                configsMap.get(CASE_ACTION_CASE_REOPENING).put(cfg.Case_Record_Type__c, cfg);
            } else if(cfg.Action__c == CASE_ACTION_SEND_NOI) {
                configsMap.get(CASE_ACTION_SEND_NOI).put(cfg.Case_Record_Type__c, cfg);
            }
        }
        
        
        // filter out the cases that need to be treated
        for(Case c: newList) {
            // todo: RecordTypeSingleton has a bug in getRecordTypeById- ret type should be string, its RecordType
            String cRTDevName = RecordTypeSingleton.getInstance().getRecordTypeById('Case', c.RecordTypeId).DeveloperName;
            // case closure
            if(newMap.get(c.Id).Status == CASE_STATUS_CLOSED && 
               configsMap.get(CASE_ACTION_CASE_CLOSURE).keySet().contains(cRTDevName)) {
                   List<String> oldStatuses = configsMap.get(CASE_ACTION_CASE_CLOSURE).get(cRTDevName).Status_From__c.split(',');
                   if(oldStatuses.contains(oldMap.get(c.Id).Status)){
                       
                       consideredForClosure.add(c.Id);
                       allConsidered.add(c.Id);
                   }         
               }
            
            
            if(newMap.get(c.Id).Status == CASE_STATUS_ESCALATED_INTERNALLY && 
               configsMap.get(CASE_ACTION_CASE_ESCALATION).keySet().contains(cRTDevName)) {
                   
                   List<String> oldStatuses = configsMap.get(CASE_ACTION_CASE_ESCALATION).get(cRTDevName).Status_From__c.split(',');
                   if(oldStatuses.contains(oldMap.get(c.Id).Status)){
                       consideredForEscInt.add(c.Id);
                       allConsidered.add(c.Id);
                   }
               }


            System.debug('@@@ config: '+configsMap.get(CASE_ACTION_CASE_REOPENING));
            System.debug('@@@ config rt: '+configsMap.get(CASE_ACTION_CASE_REOPENING).get('Cases_Global'));
            System.debug('@@@ old status: '+oldMap.get(c.Id).Status);
            System.debug('@@@ new status: '+newMap.get(c.Id).Status);
            // case reopen
            if(newMap.get(c.Id).Status == CASE_STATUS_REOPEN && oldMap.get(c.Id).Status == CASE_STATUS_CLOSED
               && configsMap.get(CASE_ACTION_CASE_REOPENING).keySet().contains(cRTDevName)) {
                   List<String> reopenReasons = configsMap.get(CASE_ACTION_CASE_REOPENING).get(cRTDevName).Reopening_Reason__c.split(',');
                   if(reopenReasons.contains(c.Reopening_reason__c)) {
                       consideredForReopen.add(c.Id);
                       allConsidered.add(c.Id);
                   }
               }
           


            // NOI sent
            if(newMap.get(c.Id).NOI_sent__c != null && oldMap.get(c.Id).NOI_sent__c == null 
               && configsMap.get(CASE_ACTION_SEND_NOI).keySet().contains(cRTDevName)) {
                   consideredForNOI.add(c.Id);
                   allConsidered.add(c.Id);
               }
        }
        // create new KPI values
        if(allConsidered.size() == 0) {
            System.debug('+++CaseTriggerHelper: no cases to consider');
            return;
        }
        // find registered case closures from past
        List<KPI_Value__c> claimingClosures = [SELECT Id, Responsible__c, CaseNumber__c FROM KPI_Value__c 
                                               WHERE CaseNumber__c IN :allConsidered
                                               AND FDS_KPI_Reporting__r.Type_Of_Action__c=:CASE_ACTION_CASE_CLOSURE];
        Map<Id, KPI_Value__c> typeOfActionClosureMap = new Map<Id, KPI_Value__c>();
        for(KPI_Value__c cc: claimingClosures)
        {   // todo: assuming there are no dupes this should be fine, otherwise it's quite undeterministic
            typeOfActionClosureMap.put(cc.CaseNumber__c, cc);
        }
        
        
        System.debug('+++ consideredForClosure:'+consideredForClosure);
                System.debug('+++ consideredForEscInt:'+consideredForEscInt);

                System.debug('+++ consideredForReopen:'+consideredForReopen);

                System.debug('+++ consideredForNOI:'+consideredForNOI);

        // closure
        for(Id cId: consideredForClosure) {
            String cRTDevName = RecordTypeSingleton.getInstance().getRecordTypeById('Case', oldMap.get(cId).RecordTypeId).DeveloperName;
            
            KPI_Value__c valueToInsert = createKPIReportingValue(oldMap.get(cId), 
                                                                 Integer.valueOf(configsMap.get(CASE_ACTION_CASE_CLOSURE).get(cRTDevName).Points__c.intValue()), 
                                                                 kpiReportingClosureId);
            kpiValuesToInsert.add(valueToInsert);
        }
        
        // case internal escalation
        for(Id cId: consideredForEscInt) {
            String cRTDevName = RecordTypeSingleton.getInstance().getRecordTypeById('Case', oldMap.get(cId).RecordTypeId).DeveloperName;
            KPI_Value__c valueToInsert = createKPIReportingValue(oldMap.get(cId), Integer.valueOf(configsMap.get(CASE_ACTION_CASE_ESCALATION).get(cRTDevName).Points__c.intValue()), 
                                                                 kpiReportingEscalationId);
            kpiValuesToInsert.add(valueToInsert);
        }
        // case reopen
        for(Id cId: consideredForReopen) {
            String cRTDevName = RecordTypeSingleton.getInstance().getRecordTypeById('Case', oldMap.get(cId).RecordTypeId).DeveloperName;
            KPI_Value__c valueToInsert = createKPIReportingValue(oldMap.get(cId), Integer.valueOf(configsMap.get(CASE_ACTION_CASE_REOPENING).get(cRTDevName).Points__c.intValue()),
                                                                 kpiReportingReopeningId);
            kpiValuesToInsert.add(valueToInsert);
        }
        
        // NOI sent
        for(Id cId: consideredForNOI) {
            String cRTDevName = RecordTypeSingleton.getInstance().getRecordTypeById('Case', oldMap.get(cId).RecordTypeId).DeveloperName;
            KPI_Value__c valueToInsert = createKPIReportingValue(oldMap.get(cId), Integer.valueOf(configsMap.get(CASE_ACTION_SEND_NOI).get(cRTDevName).Points__c.intValue()), 
                                                                 kpiReportingNOIId);
            kpiValuesToInsert.add(valueToInsert);
            
        }
        
        try{
            if(kpiValuesToInsert.size() > 0 )
                insert kpiValuesToInsert;
        } catch(DmlException e) {
            system.debug('LW insert error: ' + e.getMessage());
        }
        


            CaseTriggerHelper.isDone = true;

    }
    
    /**
* Retrieve ISSP_KPI_Reporting__mdt configration for specific type of action
*
* @param String - actionType
*
* @return List<ISSP_KPI_Reporting__mdt> - list of configs
*/
    public static List<ISSP_KPI_Reporting__mdt> getKPIConfig(List<String> actionTypes) {
        String queryString = 'SELECT ' +
            'Id, Action__c, Case_Record_Type__c, Field_API_Name__c, Points__c, Reopening_Reason__c, Status_From__c, Status_To__c, Type_of_Task__c, Value_From__c, Value_To__c ' +
            'FROM ' +
            'ISSP_KPI_Reporting__mdt WHERE Action__c IN :actionTypes';
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
    
    
    public static KPI_Value__c createKPIReportingValue(Case caseToProcess, Integer points, String kpiReportingId){
        KPI_Value__c valueToAdd = new KPI_Value__c();
        
        valueToAdd.Name = 'Value_' + caseToProcess.Id + '_' + DateTime.now().hour()+'_'+DateTime.now().minute()+'_'+DateTime.now().second();
        valueToAdd.FDS_KPI_Reporting__c = kpiReportingId;
        valueToAdd.CaseNumber__c = caseToProcess.Id;
        valueToAdd.Month__c = convertMonthNumberToText(Integer.valueOf(Date.today().month()));
        valueToAdd.Year__c = String.valueOf(Date.today().year());
        valueToAdd.KPI_Value__c = points;
        
        if(caseToProcess.Reopening_reason__c == 'same query' && typeOfActionClosureMap.get(caseToProcess.Id) != null) {
            valueToAdd.Responsible__c = typeOfActionClosureMap.get(caseToProcess.Id).Responsible__c;
            System.debug('+++modding responsible');
        } else {
            System.debug('+++first responsible by my user');
            valueToAdd.Responsible__c = UserInfo.getUserId();
        }
        return valueToAdd;
    }
}