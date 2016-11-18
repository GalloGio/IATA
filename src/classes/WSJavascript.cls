global with sharing class WSJavascript {

    webservice static void refreshSignaturitEvents (String signaturitid) {
        Tracked_Email__c te = [
            Select Id, Signaturit_Id__c, Signaturit_Certificate_Ids__c, FromName__c
            From Tracked_Email__c
            where id = :signaturitid
        ];
        SignaturitRest.updateEventList(te);
    }

}