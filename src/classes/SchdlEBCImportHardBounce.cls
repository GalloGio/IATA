global class SchdlEBCImportHardBounce implements Database.AllowsCallouts, Schedulable {
    // Schedulable
    global void execute(SchedulableContext SC)  {
        EBC_Setup__c s = [Select ET_Last_EventDate__c From EBC_Setup__c];
        IECEBC_ETSubscriberBouncedRetrieve.RetrieveBouncedSubscriber('HardBounce', s.ET_Last_EventDate__c);
    }
    global static void cancel() {
        cancel('SchdlEBCImportHardBounce');
    }
    global static void cancel(String name) {
        CronTrigger ct = [SELECT Id, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType FROM CronTrigger Where CronJobDetail.Name = :name LIMIT 1];
        System.abortJob(ct.Id);
    }
    
    global static void Schedule() {
        SchdlEBCImportHardBounce a = new SchdlEBCImportHardBounce();
        System.schedule('SchdlEBCImportHardBounce', '0 0 * * * ?', a);
    }
}