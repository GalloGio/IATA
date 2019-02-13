public class EmailMessageKPIHandler {
    public static final String CASE_EMAIL_SEND_ACTION = 'Send Email';
    
    
    private static List<KPI_Value__c> kpiValuesToInsert = new List<KPI_Value__c>();
    
    public static void createKPIValues(List<EmailMessage> newEmails) {
        List<ISSP_KPI_Reporting__mdt> config = new List<ISSP_KPI_Reporting__mdt>();
        Map<String, ISSP_KPI_Reporting__mdt> rtToConfigMap = new Map<String, ISSP_KPI_Reporting__mdt>();
        Set<Id> recordTypesToProcess = new Set<Id>();
        
        config = getKPIConfig(CASE_EMAIL_SEND_ACTION);
        
        if(config.size() == 0) {
            System.debug('+++emailMessageKPIHandler: no KPI config, exiting');
            return;
        }
        
        for(ISSP_KPI_Reporting__mdt cfg : config){
            recordTypesToProcess.add(RecordTypeSingleton.getInstance().getRecordType('Case', cfg.Case_Record_Type__c).Id);
            rtToConfigMap.put(cfg.Case_Record_Type__c, cfg);
        }
        		System.debug('+++email considered initially: '+newEmails);
                System.debug('+++email looking for rts: '+recordTypesToProcess);

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
        
        for (EmailMessage em : emailMessages) {
            if (rtToConfigMap.containsKey(em.Parent.RecordType.DeveloperName)) {
                createKPIReportingValue(em, Integer.valueOf(rtToConfigMap.get(em.Parent.RecordType.DeveloperName).Points__c), kpiReportingId);
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
    
    private static List<ISSP_KPI_Reporting__mdt> getKPIConfig(String actionType) {
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
    
    private static void createKPIReportingValue(EmailMessage email, Integer points, String kpiReportingId){
        
        KPI_Value__c valueToAdd = new KPI_Value__c();
        
        valueToAdd.Name = 'Value_' + email.ParentId + '_' + DateTime.now().hour()+'_'+DateTime.now().minute()+'_'+DateTime.now().second();
        valueToAdd.FDS_KPI_Reporting__c = kpiReportingId;
        valueToAdd.CaseNumber__c = email.ParentId;
        valueToAdd.Month__c = convertMonthNumberToText(Integer.valueOf(Date.today().month()));
        valueToAdd.Year__c = String.valueOf(Date.today().year());
        valueToAdd.KPI_Value__c = points;
        valueToAdd.Responsible__c = UserInfo.getUserId();
        
        kpiValuesToInsert.add(valueToAdd);
    }
    
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
}