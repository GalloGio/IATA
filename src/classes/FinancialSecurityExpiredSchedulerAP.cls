global class FinancialSecurityExpiredSchedulerAP implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        
        FinancialSecurityExpiredBatchAP b = new FinancialSecurityExpiredBatchAP();
        database.executebatch(b,1);
    }
}