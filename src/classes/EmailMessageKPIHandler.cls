public class EmailMessageKPIHandler {
    public static final String CASE_EMAIL_SEND_ACTION = 'Send Email';
    
    public static void createKPIValues(List<EmailMessage> newEmails) {
        List<ISSP_KPI_Reporting__mdt> config = new List<ISSP_KPI_Reporting__mdt>();
        Map<String, ISSP_KPI_Reporting__mdt> rtToConfigMap = new Map<String, ISSP_KPI_Reporting__mdt>();
        Set<Id> recordTypesToProcess = new Set<Id>();
        List<EmailMessage> emailsToProcess = new List<EmailMessage>();
        for(EmailMessage e: newEmails) {
            if(e.ParentId.getSObjectType() == Case.SObjectType && e.Incoming==false) {
                emailsToProcess.add(e);
            }
        }
        
        if (emailsToProcess.size() == 0) {
            System.debug('+++emailMessageKPIHandler: no emails to process.');
            return;
        }
        
        config = getKPIConfig(CASE_EMAIL_SEND_ACTION);
        
        if(config.size() == 0) {
            System.debug('+++emailMessageKPIHandler: no KPI config, exiting');
            return;
        }
        
        for(ISSP_KPI_Reporting__mdt cfg : config){
            recordTypesToProcess.add(RecordTypeSingleton.getInstance().getRecordType('Case', cfg.Case_Record_Type__c).Id);
            rtToConfigMap.put(cfg.Case_Record_Type__c, cfg);
        }
        
        List<EmailMessage> emailMessages = [SELECT id, ParentId, Parent.RecordType.DeveloperName
                                            FROM EmailMessage WHERE ID IN: newEmails AND Incoming=False
                                            AND Parent.RecordTypeId IN :recordTypesToProcess];
        
        if(emailMessages.isEmpty()) {
            System.debug('+++emailMessageKPIHandler: no emails returned');
            return;
        }
        
        List<FDS_KPI_Reporting__c> kpiReporting = [SELECT Id, Type_Of_Action__c 
                                                   FROM FDS_KPI_Reporting__c 
                                                   WHERE Name =: CASE_EMAIL_SEND_ACTION 
                                                   AND Type_Of_Action__c =: CASE_EMAIL_SEND_ACTION];
        if(kpiReporting.size() == 0) {
            System.debug('+++emailMessageKPIHandler: missing KPI reporting, exiting');
            return;
        }
        
        Id kpiReportingId = kpiReporting.get(0).Id;
        List<KPI_Value__c> kpiValuesToInsert = new List<KPI_Value__c>();
        
        for (EmailMessage em : emailMessages) {
            if (rtToConfigMap.containsKey(em.Parent.RecordType.DeveloperName)) {
                kpiValuesToInsert.add(createKPIReportingValue(em, Integer.valueOf(rtToConfigMap.get(em.Parent.RecordType.DeveloperName).Points__c), kpiReportingId));
            }
        }
        
        
        
        if(kpiValuesToInsert.size() > 0 ) {
            insert kpiValuesToInsert;
        }
        
        
        
    }
    
    private static List<ISSP_KPI_Reporting__mdt> getKPIConfig(String actionType) {
        
        return [SELECT Action__c, Case_Record_Type__c, DeveloperName, Id, Points__c 
                FROM ISSP_KPI_Reporting__mdt WHERE Action__c =: actionType];
    }
    
    private static KPI_Value__c createKPIReportingValue(EmailMessage email, Integer points, String kpiReportingId){
        
        KPI_Value__c valueToAdd = new KPI_Value__c();
        
        valueToAdd.Name = 'Value_' + email.ParentId + '_' + System.now().format('hh_mm_ss');
        valueToAdd.FDS_KPI_Reporting__c = kpiReportingId;
        valueToAdd.CaseNumber__c = email.ParentId;
        valueToAdd.Month__c = System.now().format('MMMM');
        valueToAdd.Year__c = String.valueOf(Date.today().year());
        valueToAdd.KPI_Value__c = points;
        valueToAdd.Responsible__c = UserInfo.getUserId();
        
        return valueToAdd;
    }
    
}