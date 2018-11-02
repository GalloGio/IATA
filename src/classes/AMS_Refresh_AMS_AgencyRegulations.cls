global class AMS_Refresh_AMS_AgencyRegulations implements Database.Batchable<sObject>, Schedulable {

    private Integer batchScope {get;set;}
    String query = 'SELECT Id FROM AMS_Agency_Regulation__c WHERE Expiry_Date__c = LAST_N_DAYS:2 AND Type_Of_Certificate__c = \'DGR\'';

    public static void start(String cron, Integer scope) {
        if(!Test.isRunningTest()) {
            System.schedule('AMS Agency Regulations Refresh Batch', cron, new AMS_Refresh_AMS_AgencyRegulations (scope));
        }else{
            System.schedule('AMS Agency Regulations Refresh Batch TEST', cron, new AMS_Refresh_AMS_AgencyRegulations (scope));
        }
        
    }
    
    global static void stop(){
        String sJobName = '';
        if(!Test.isRunningTest()) {
            sJobName = 'AMS Agency Regulations Refresh Batch';
        }else{
            sJobName = 'AMS Agency Regulations Refresh Batch TEST';
        }
        
        List<CronTrigger> SCHEDULE_ID = [SELECT Id FROM CronTrigger where CronJobDetail.Name = :sJobName limit 1]; 
        
        if(SCHEDULE_ID.size() > 0){
            System.abortJob(SCHEDULE_ID[0].Id);
        }
    }

    global void execute(SchedulableContext sc) {
        Database.executeBatch(this, this.batchScope);
    }
    
    global AMS_Refresh_AMS_AgencyRegulations(Integer batchScope) {
        this.batchScope = batchScope;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        try {
            System.debug('before - ' + scope);
            update scope;
            System.debug('after- ' + scope);
        } catch(Exception e) {
            System.debug(e);
        }
    }

    global void finish(Database.BatchableContext BC) {

    }

}