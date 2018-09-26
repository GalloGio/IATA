global class SchdlIECEBCEmailExclusionRelation implements Database.Batchable<sObject>, Schedulable {
    public static final Integer BATCH_SIZE = 40;
    public Boolean EXISTING_RELATION = true;

    // Batchable
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
                                            SELECT Id, Email__c, Unsubscribe_From__c FROM EBC_Email_Exclusion__c Where Is_Relation_Created__c  = :EXISTING_RELATION
                                        ]);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<EBC_Email_Exclusion__c> ees = (List<EBC_Email_Exclusion__c>)scope;
        Map<String, EBC_Email_Exclusion_Relation__c> eers = new Map<String, EBC_Email_Exclusion_Relation__c>();
        for (EBC_Email_Exclusion__c ee : ees) {
            ee.Is_Relation_Created__c = true;

            EBC_Email_Exclusion_Relation__c eer = new EBC_Email_Exclusion_Relation__c();
            eer.Billing_Account__c = ee.Unsubscribe_From__c;
            eer.EBC_Email_Exclusion__c = ee.Id;
//            eer.External_Id__c = '';
//            eer.GDP_Products_Account_View__c = '';
//            eer.ID_Card__c = '';
            eer.Is_Global__c = String.isBlank(ee.Unsubscribe_From__c);

            String externalId = '';

            List<GDP_Products_Account_View__c> gpavs = [Select Id From GDP_Products_Account_View__c Where Email_Address__c = :ee.Email__c];
            for (GDP_Products_Account_View__c gpav : gpavs) {
                EBC_Email_Exclusion_Relation__c eerNew = eer.clone(false, true, false, false);
                eerNew.GDP_Products_Account_View__c = gpav.Id;

                externalId = eerNew.External_Id__c = ee.Email__c.toLowerCase() + '_' + gpav.Id + '_' + ee.Unsubscribe_From__c;

                eers.put(externalId, eerNew);
            }
            List<Id_Card__c> ics = [Select Id From Id_Card__c Where Email__c = :ee.Email__c];
            for (Id_Card__c ic : ics) {
                EBC_Email_Exclusion_Relation__c eerNew = eer.clone(false, true, false, false);
                eerNew.ID_Card__c = ic.Id;

                externalId = eerNew.External_Id__c = ee.Email__c.toLowerCase() + '_' + ic.Id + '_' + ee.Unsubscribe_From__c;

                eers.put(externalId, eerNew);
            }

        }

        System.debug(eers);

        Schema.SObjectField f = EBC_Email_Exclusion_Relation__c.Fields.External_Id__c;
        if (eers.size() > 0) Database.UpsertResult [] cr = Database.upsert(eers.values(), f, false);

        update ees;
    }

    global void finish(Database.BatchableContext BC) {
    }

    // Schedulable
    global void execute(SchedulableContext SC)  {
        CronTrigger ct = [Select c.Id, c.CronJobDetail.Name, c.CronJobDetailId, c.CronExpression From CronTrigger c Where Id = :SC.getTriggerId()];

        SchdlIECEBCEmailExclusionRelation n = new SchdlIECEBCEmailExclusionRelation();
        n.EXISTING_RELATION = ct.CronJobDetail.Name == 'SchdlIECEBCEmailExclusionRelationDaily' + (Test.isRunningTest() ? 'Test' : '');
        Database.executeBatch(n, SchdlIECEBCEmailExclusionRelation.BATCH_SIZE);
    }
    global static void cancel() {
        cancel('SchdlIECEBCEmailExclusionRelationDaily' + (Test.isRunningTest() ? 'Test' : ''));
        cancel('SchdlIECEBCEmailExclusionRelationHourly' + (Test.isRunningTest() ? 'Test' : ''));
    }
    global static void cancel(String name) {
        CronTrigger ct = [SELECT Id, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType FROM CronTrigger Where CronJobDetail.Name = :name LIMIT 1];
        System.abortJob(ct.Id);
    }

    global static void Schedule() {
        System.schedule('SchdlIECEBCEmailExclusionRelationDaily' + (Test.isRunningTest() ? 'Test' : ''), '0 0 4 * * ?', new SchdlIECEBCEmailExclusionRelation());
        System.schedule('SchdlIECEBCEmailExclusionRelationHourly' + (Test.isRunningTest() ? 'Test' : ''), '0 35 * * * ?', new SchdlIECEBCEmailExclusionRelation());
    }
}