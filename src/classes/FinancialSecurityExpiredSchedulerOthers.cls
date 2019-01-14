global class FinancialSecurityExpiredSchedulerOthers implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        
        FinancialSecurityExpiredBatchOthers b = new FinancialSecurityExpiredBatchOthers();
        database.executebatch(b,1);
    }
}