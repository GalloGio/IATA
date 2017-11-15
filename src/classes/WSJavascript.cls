global with sharing class WSJavascript {

    webservice static void refreshSignaturitEvents (String signaturitid) {
        Tracked_Email__c te = [
            Select Id, Signaturit_Id__c, Signaturit_Certificate_Ids__c, FromName__c, Email__c, Status__c
            From Tracked_Email__c
            where id = :signaturitid
        ];
        
        
        List<Tracked_Email_Event__c> events = SignaturitRest.updateEventList(te);
        
        Database.insert(events, false);
        
		SignaturitRest.updateEmailStatus(new List<Tracked_Email__c>{te});
    }

}