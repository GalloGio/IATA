global class SignaturitEventsBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{

    global String query;

    global SignaturitEventsBatch(){
        this.query = 'SELECT Id,BccAddress__c,Case__c,CcAddress__c,ConnectionReceivedId,EmailMessage__c,FromAddress__c,FromName__c,Name,Signaturit_Certificate_Ids__c,Signaturit_Id__c,Status__c,Subject__c,ToContact__c'
            + ' FROM Tracked_Email__c'
            + ' where Status__c in (\'sent\',\'processed\',\'bounce\') '
            + ' and Signaturit_Id__c != null';
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        for(sobject s : scope) {
            Tracked_Email__c te = (Tracked_Email__c)s;
            try {
                SignaturitRest.updateEventList(te);
            } catch (Exception e) {
                System.debug( 'ERROR SignaturitEventsBatch in ' + te.Id + '  ' + e.getMessage() );
            }
        }
    }

    global void finish(Database.BatchableContext BC){

    }

}