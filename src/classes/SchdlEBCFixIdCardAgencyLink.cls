global class SchdlEBCFixIdCardAgencyLink implements Database.Batchable<sObject>, Schedulable {
    // Batch
     public String query = 'Select Id, Agency_IATA_Code__c From ID_Card__c Where GDP_Products_Account_View__c=null and Agency_IATA_Code__c!=null';
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<ID_Card__c> scope){
        for(ID_Card__c ic : scope) {
            String iata_code=ic.Agency_IATA_Code__c;
            if (String.isBlank(iata_code)) continue;
            if (iata_code.length()<8) continue;
            iata_code = iata_code.substring(0,7);
            ic.GDP_Products_Account_View__r = new GDP_Products_Account_View__c(IATA_Code__c = iata_code);
        }
        
        update scope;
    }
    
    global void finish(Database.BatchableContext BC){
    }
    // Schedule
    
    global void execute(SchedulableContext SC)  {
        SchdlEBCFixIdCardAgencyLink n = new SchdlEBCFixIdCardAgencyLink();
        Database.executeBatch(n,200);
    }
    global static void cancel() {
        cancel('SchdlEBCFixIdCardAgencyLink' + (Test.isRunningTest() ? 'Test' : ''));
    }
    global static void cancel(String name) {
        List<CronTrigger> ct = new List<CronTrigger>();
        ct = [SELECT Id, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType FROM CronTrigger Where CronJobDetail.Name = :name LIMIT 1];
        if (ct.size()>0) System.abortJob(ct[0].Id);
    }
    
    global static void Schedule(string sch) {
        SchdlEBCFixIdCardAgencyLink a = new SchdlEBCFixIdCardAgencyLink();
        if (String.isBlank(sch)) {
            sch = '0 0 9 * * ?';
        }
        System.schedule('SchdlEBCFixIdCardAgencyLink' + (Test.isRunningTest() ? 'Test' : ''), sch, a);
    }
    }