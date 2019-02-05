public class CaseDetailTriggerHandler {

    public List<Case_Detail__c> triggerNew = (List<Case_Detail__c>) Trigger.new;
    public List<Case_Detail__c> triggerOld = (List<Case_Detail__c>) Trigger.old;
    public Map<Id, Case_Detail__c> newMap = (Map<Id, Case_Detail__c>) Trigger.newMap;
    public Map<Id, Case_Detail__c> oldMap = (Map<Id, Case_Detail__c>) Trigger.oldMap; 

    public static final String CALL_MONITORING = RecordTypeSingleton.getInstance().getRecordTypeId('Case_Detail__c', 'Call_Monitoring'); 
    public static final String CASE_MONITORING = RecordTypeSingleton.getInstance().getRecordTypeId('Case_Detail__c', 'Case_Monitoring'); 


    public void onBeforeInsert() {
        calculateScore();
    }
    //public void onAfterInsert() {}

    public void onBeforeUpdate() {
        calculateScore();
    }
    //public void onAfterUpdate() {}

    //public void onBeforeDelete() {}
    //public void onAfterDelete() {}
    

    private void calculateScore() {
        String weightField;
        Integer totalScore = 0;

        for(Case_Detail__c caseDetail : triggerNew) {
            List<Case_Detail_Score_Fields_Weight__c> scoreWeights = Case_Detail_Score_Fields_Weight__c.getall().values();

            for(Case_Detail_Score_Fields_Weight__c sw : scoreWeights) {
                if(caseDetail.get(sw.Name) == true) {
                    Decimal fieldScore = (caseDetail.RecordTypeId == CALL_MONITORING) ? sw.Call_Monitoring_Weight__c : sw.Case_Monitoring_Weight__c;
                    totalScore = totalScore + Integer.valueOf(fieldScore);
                }

            }
            caseDetail.Score1__c = String.valueOf(totalScore);
        }
    }

}