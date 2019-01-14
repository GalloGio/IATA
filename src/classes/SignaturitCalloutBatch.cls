global class SignaturitCalloutBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{

    global List<Tracked_Email__c> trackedEmails;
    
    public SignaturitCalloutBatch(List<Tracked_Email__c> trackedEmails){
        this.trackedEmails = trackedEmails;
    }

    global List<Tracked_Email__c> start(Database.BatchableContext BC){
        return trackedEmails;
    }
    
    global void execute(Database.BatchableContext BC, List<Tracked_Email__c> scope){
        System.debug('SignaturitCalloutBatch.execute()');
        try{
            SignaturitUtils.sendTrackedEmails(scope);
        }
        catch (Exception ex) {
            System.debug('SignaturitCalloutBatch.execute() ERROR : '+ ex.getMessage());
        }
    }

    global void finish(Database.BatchableContext BC){}
}