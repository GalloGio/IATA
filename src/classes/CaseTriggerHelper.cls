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
    public static final String CASE_STATUS_ESCALATED_EXTERNALLY = 'Escalated Externally';
    public static final String CASE_STATUS_REOPEN = 'Reopen';
    
    public static final String CASE_ACTION_CASE_CLOSURE = 'Case Closure';
    public static final String CASE_ACTION_CASE_ESCALATION = 'Case Escalation';
    public static final String CASE_ACTION_CASE_REOPENING = 'Case Reopening';
    public static final String CASE_ACTION_SEND_NOI = 'Send NOI';
    
    public static List<String> actionTypes = new List<String>{CASE_ACTION_CASE_CLOSURE, CASE_ACTION_CASE_ESCALATION, CASE_ACTION_CASE_REOPENING, CASE_ACTION_SEND_NOI};
    public static List<String> caseStatuses = new List<String>{CASE_STATUS_CLOSED, CASE_STATUS_ESCALATED_INTERNALLY, CASE_STATUS_REOPEN};
            
            
            
            

    
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
            
            // escalation
            if((newMap.get(c.Id).Status == CASE_STATUS_ESCALATED_EXTERNALLY || newMap.get(c.Id).Status == CASE_STATUS_ESCALATED_INTERNALLY) && 
               configsMap.get(CASE_ACTION_CASE_ESCALATION).keySet().contains(cRTDevName)) {
                   
                   List<String> oldStatuses = configsMap.get(CASE_ACTION_CASE_ESCALATION).get(cRTDevName).Status_From__c.split(',');
                   if(oldStatuses.contains(oldMap.get(c.Id).Status)){
                       consideredForEscInt.add(c.Id);
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

        if(allConsidered.size() == 0) {
            System.debug('+++CaseTriggerHelper: no cases to consider');
            return;
        }
        
        // find registered case closures from past
        List<KPI_Value__c> claimingClosures = [SELECT Id, Responsible__c, CaseNumber__c FROM KPI_Value__c 
                                               WHERE CaseNumber__c IN :consideredForClosure
                                               AND FDS_KPI_Reporting__r.Type_Of_Action__c=:CASE_ACTION_CASE_CLOSURE];
        Map<Id, KPI_Value__c> typeOfActionClosureMap = new Map<Id, KPI_Value__c>();
        for(KPI_Value__c cc: claimingClosures)
        {
            typeOfActionClosureMap.put(cc.CaseNumber__c, cc);
        }
        
        // closure
        for(Id cId: consideredForClosure) {
            String cRTDevName = RecordTypeSingleton.getInstance().getRecordTypeById('Case', oldMap.get(cId).RecordTypeId).DeveloperName;
            
            // sprint6 if a case is close as part of same query
            // substract from original user while awarding the new one
            
            KPI_Value__c valueToInsert = createKPIReportingValue(newMap.get(cId), 
                                                                 configsMap.get(CASE_ACTION_CASE_CLOSURE).get(cRTDevName).Points__c.intValue(), 
                                                                 kpiReportingClosureId);
            kpiValuesToInsert.add(valueToInsert);
            // if points were awarded to someone else substract them from original
            if(newMap.get(cId).Reopening_reason__c == 'same query' && typeOfActionClosureMap.get(cId) != null
               && newMap.get(cId).Status=='Closed' && oldMap.get(cId).Status=='Reopen') {
                   KPI_Value__c valueToAdd = new KPI_Value__c();
                   
                   
                   valueToAdd.Responsible__c = typeOfActionClosureMap.get(cId).Responsible__c;
                   valueToAdd.Name = 'Value_' + cId + '_' + System.now().format('hh_mm_ss');
                   valueToAdd.FDS_KPI_Reporting__c = kpiReportingReopeningId;
                   valueToAdd.CaseNumber__c = cId;
                   valueToAdd.Month__c = System.now().format('MMMM');
                   valueToAdd.Year__c = String.valueOf(Date.today().year());
                   valueToAdd.KPI_Value__c = configsMap.get(CASE_ACTION_CASE_REOPENING).get(cRTDevName).Points__c.intValue();
                   kpiValuesToInsert.add(valueToAdd);
                   
               } 
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
    
  
    public static List<ISSP_KPI_Reporting__mdt> getKPIConfig(List<String> actionTypes) {
        return [SELECT Id, Action__c, Case_Record_Type__c, Field_API_Name__c, Value_To__c,
                Points__c, Reopening_Reason__c, Status_From__c, Status_To__c, Type_of_Task__c, Value_From__c
         FROM ISSP_KPI_Reporting__mdt
         WHERE Action__c IN :actionTypes
                ];
    }
    
 
    
    public static KPI_Value__c createKPIReportingValue(Case caseToProcess, Integer points, String kpiReportingId){
        KPI_Value__c valueToAdd = new KPI_Value__c();
        
        valueToAdd.Name = 'Value_' + caseToProcess.Id + '_' + System.now().format('hh_mm_ss');
        valueToAdd.FDS_KPI_Reporting__c = kpiReportingId;
        valueToAdd.CaseNumber__c = caseToProcess.Id;
        valueToAdd.Month__c = System.now().format('MMMM');
        valueToAdd.Year__c = String.valueOf(Date.today().year());
        valueToAdd.KPI_Value__c = points;
        valueToAdd.Responsible__c = UserInfo.getUserId();
        
        return valueToAdd;
    }
}