global class AMS_OSCAR_Age_Calculator implements Database.Batchable<sObject>, Database.Stateful, Schedulable {

    private Integer batchSize {get;set;}
    private String region {get;set;}
    private List<UpdateResult> executionResult {get;set;}

    public AMS_OSCAR_Age_Calculator(String region, Integer batchSize) {
        this.batchSize = batchSize;
        this.region = region;
        this.executionResult = new List<UpdateResult>();
    }

    public static void start(String cron, String region, Integer batchSize) {
        String jobName = 'AMS OSCAR Eff. Age Calculator ' + region;
        if(Test.isRunningTest()) {
            jobName += ' Test';
        }
        System.schedule(jobName, cron, new AMS_OSCAR_Age_Calculator(region, batchSize));
    }

    public static void stop(String region) {
        String jobName = 'AMS OSCAR Eff. Age Calculator ' + region;
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
        Date x1stDay = Date.newInstance(2019, 1, 1);
        List<String> reasons = new List<String>();
        for(Case_Process_Type__mdt mt : [SELECT Reason__c FROM Case_Process_Type__mdt WHERE Record_Type__c = 'OSCAR_Communication']) {
            reasons.add(mt.Reason__c);
        }
        List<String> oscarFields = new List<String>();
        List<Schema.FieldSetMember> kpiFields = SObjectType.AMS_OSCAR__c.FieldSets.KPI_Fields.getFields();
        for(Schema.FieldSetMember field : kpiFields) {
            oscarFields.add('OSCAR__r.' + field.getFieldPath());
        }

        String queryStr = 'SELECT Id, ClosedDate, OSCAR__c, ' + String.join(oscarFields, ', ') + ' FROM Case ';
        queryStr += 'WHERE Reason1__c IN :reasons AND IsClosed = false AND OSCAR__c <> null AND CreatedDate >= :x1stDay ';
        queryStr += 'AND OSCAR__r.Dossier_Reception_Date__c <> null AND (NOT Owner.Name LIKE \'%Recycle%\') ';
        queryStr += 'AND Account.IATA_ISO_Country__r.Region__c = \'' + this.region + '\'';

        return Database.getQueryLocator(queryStr);
    }

    global void execute(Database.BatchableContext BC, List<Case> scope) {
        List<Schema.FieldSetMember> kpiFields = SObjectType.AMS_OSCAR__c.FieldSets.KPI_Fields.getFields();
        List<AMS_OSCAR__c> oscars = new List<AMS_OSCAR__c>();
        for(Case cse : scope) {
            AMS_OSCAR__c oscar = (AMS_OSCAR__c) cse.getSobject('OSCAR__r');
            /* We need to preform this assignment to make sure that null fields are set before flow execution */
            for(Schema.FieldSetMember field : kpiFields) {
                if(field.getSObjectField().getDescribe().isUpdateable()) {
                    oscar.put(field.getFieldPath(), oscar.get(field.getFieldPath()));
                }
            }           
            calculate(new Case(Id= cse.Id, ClosedDate= cse.ClosedDate), oscar);
            oscars.add(oscar);
        }

        AMS_OSCARTriggerHandler.isRunningAgeCalculator = true;
        List<Database.SaveResult> results = Database.update(oscars, false);
        AMS_OSCARTriggerHandler.isRunningAgeCalculator = false;
        Integer i= 0;
        for(Database.SaveResult r : results) {
            if(r.isSuccess()) {
                this.executionResult.add(new UpdateResult(r.getId(), true));
            } else {
                UpdateResult ur = new UpdateResult((Id) scope[i].get('OSCAR__c'), false);
                for(Database.Error err : r.getErrors()) {
                    ur.errors.add(err.getMessage().escapeCsv());
                }
                this.executionResult.add(ur);
            }
            i++;
        }
    }

    global void finish(Database.BatchableContext BC) {
        String report = 'Id,Success,Errors\n';
        for(UpdateResult ur : this.executionResult) {
            report += ur.recordId + ',' + ur.success + ',' + String.join(ur.errors, ' - ') + '\n';
        }

        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        Blob csvReport = Blob.valueOf(report);
        csvAttc.setFileName('AMS OSCAR Effective Age Batch.csv');
        csvAttc.setBody(csvReport);

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.subject = 'AMS OSCAR Effective Age Calculation ' + this.region;
        message.setPlainTextBody('AMS OSCAR Effective Age Calculation - Check attachment with execution results');
        message.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        Messaging.SingleEmailMessage[] messages =  new List<Messaging.SingleEmailMessage> {message};    

        if(!Test.isRunningTest()) {
            message.setTargetObjectId(UserInfo.getUserId());
            message.setSaveAsActivity(false);
            Messaging.sendEmail(messages);
        }   
    }

    public static void calculate(Case cse, AMS_OSCAR__c oscar) {
        Map<String,Object> params = new Map<String,Object> {'case_record' => cse, 'oscar' => oscar};
        Flow.Interview.AMS_OSCAR_Effective_Age_Calculator flow = new Flow.Interview.AMS_OSCAR_Effective_Age_Calculator(params);
        flow.start();
        Decimal val = (Decimal) flow.getVariableValue('EffectiveAge');
        oscar.Process_Eff_Age__c = val;
    }

    public class UpdateResult {
        public Id recordId {get;set;}
        public Boolean success {get;set;}
        public List<String> errors {get;set;}

        public UpdateResult(Id recordId, Boolean success) {
            this.recordId = recordId;
            this.success = success;
            this.errors = new List<String>();
        }
    }

}