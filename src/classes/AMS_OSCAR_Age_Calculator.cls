global class AMS_OSCAR_Age_Calculator implements Database.Batchable<sObject>, Database.Stateful, Schedulable {

    private Integer batchSize {get;set;}

    public AMS_OSCAR_Age_Calculator(Integer batchSize) {
        this.batchSize = batchSize;
    }

    public static void start(String cron, Integer batchSize) {
        String jobName = 'AMS OSCAR Process Eff. Age Calculator';
        if(Test.isRunningTest()) {
            jobName += ' Test';
        }
        System.schedule(jobName, cron, new AMS_OSCAR_Age_Calculator(batchSize));
    }

    public static void stop() {
        String jobName = 'AMS OSCAR Process Eff. Age Calculator';
        if(Test.isRunningTest()) {
            jobName += ' Test';
        }

        List<CronTrigger> sJobs = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :jobName limit 1]; 
        
        if(sJobs.size() > 0) {
            System.abortJob(sJobs[0].Id);
        }
    }

    global void execute(SchedulableContext sc) {
        Database.executeBatch(this, this.batchSize);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        Set<String> reasons = AMS_Utils.REASONS_FOR_KPI_CALCULATION;
        Date x1stDay = Date.newInstance(2019, 1, 1);

        String queryStr = 'SELECT Id, ClosedDate, OSCAR__c, OSCAR__r.Dossier_Reception_Date__c, OSCAR__r.Payment_requested__c, ';
        queryStr += 'OSCAR__r.Proof_of_payment_received__c, OSCAR__r.Bank_Guarantee_requested__c, OSCAR__r.Bank_Guarantee_received__c, ';
        queryStr += 'OSCAR__r.Agreement_requested__c, OSCAR__r.PSAA_EACP_Agreement_received__c, OSCAR__r.Disapproval_date__c, ';
        queryStr += 'OSCAR__r.Reconsideration_date__c, OSCAR__r.Process_Eff_Age__c, OSCAR__r.Change_effective_as_of__c ';
        queryStr += 'FROM Case ';
        queryStr += 'WHERE Reason1__c IN :reasons AND IsClosed = false AND OSCAR__c <> null AND CreatedDate >= :x1stDay ';
        queryStr += 'AND OSCAR__r.Dossier_Reception_Date__c <> null AND (NOT Owner.Name LIKE \'%Recycle%\') ';

        return Database.getQueryLocator(queryStr);
    }

    global void execute(Database.BatchableContext BC, List<Case> scope) {
        List<AMS_OSCAR__c> oscars = new List<AMS_OSCAR__c>();
        for(Case cse : scope) {
            AMS_OSCAR__c oscar = new AMS_OSCAR__c(
                Id= cse.OSCAR__c,
                Dossier_Reception_Date__c= cse.OSCAR__r.Dossier_Reception_Date__c,
                Payment_requested__c= cse.OSCAR__r.Payment_requested__c,
                Proof_of_payment_received__c= cse.OSCAR__r.Proof_of_payment_received__c,
                Bank_Guarantee_requested__c= cse.OSCAR__r.Bank_Guarantee_requested__c,
                Bank_Guarantee_received__c= cse.OSCAR__r.Bank_Guarantee_received__c,
                Agreement_requested__c= cse.OSCAR__r.Agreement_requested__c,
                PSAA_EACP_Agreement_received__c= cse.OSCAR__r.PSAA_EACP_Agreement_received__c,
                Disapproval_date__c= cse.OSCAR__r.Disapproval_date__c,
                Reconsideration_date__c= cse.OSCAR__r.Reconsideration_date__c,
                Process_Eff_Age__c= cse.OSCAR__r.Process_Eff_Age__c,
                Change_effective_as_of__c= cse.OSCAR__r.Change_effective_as_of__c
            );
            
            calculate(new Case(Id= cse.Id, ClosedDate= cse.ClosedDate), oscar);
            oscars.add(oscar);
        }

        update oscars;
    }

    global void finish(Database.BatchableContext BC) {
        
    }

    public static void calculate(Case cse, AMS_OSCAR__c oscar) {
        Map<String,Object> params = new Map<String,Object> {'case_record' => cse, 'oscar' => oscar};
        Flow.Interview.AMS_OSCAR_Effective_Age_Calculator flow = new Flow.Interview.AMS_OSCAR_Effective_Age_Calculator(params);
        flow.start();
        Decimal val = (Decimal) flow.getVariableValue('EffectiveAge');
        oscar.Process_Eff_Age__c = val;
    }

}