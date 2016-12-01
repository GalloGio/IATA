global class SchdlEBCFixIdCardAgencyLink implements Database.Batchable<sObject>, Schedulable {
    // Batch
    public String query = 'Select Id, Agency_IATA_Code__c From ID_Card__c';
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<ID_Card__c> scope){
        for(ID_Card__c ic : scope) {
            if (String.isBlank(ic.Agency_IATA_Code__c)) continue;
            
        	ic.GDP_Products_Account_View__r = new GDP_Products_Account_View__c(IATA_Code__c = ic.Agency_IATA_Code__c);
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
        CronTrigger ct = [SELECT Id, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType FROM CronTrigger Where CronJobDetail.Name = :name LIMIT 1];
        System.abortJob(ct.Id);
    }
    
    global static void Schedule(string sch) {
        SchdlEBCFixIdCardAgencyLink a = new SchdlEBCFixIdCardAgencyLink();
        if (String.isBlank(sch)) {
            sch = '0 0 9 * * ?';
        }
        System.schedule('SchdlEBCFixIdCardAgencyLink' + (Test.isRunningTest() ? 'Test' : ''), sch, a);
    }
    }