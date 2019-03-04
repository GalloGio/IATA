/**
 * Created by Samuel Anjos on 2019-03-01.
 */

global class ISSP_AMC_CaseCleanUpBatch implements Database.Batchable<sObject> {

    private Date dateToDeleteTo;

    global ISSP_AMC_CaseCleanUpBatch(){

        AMC_Configuration__c amcConfiguration = AMC_Configuration__c.getInstance();
        Integer numberOfDays = Integer.valueOf(amcConfiguration.Case_Number_Of_Days_To_Delete_To__c);

        dateToDeleteTo = Date.today() - numberOfDays;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        // get the RecordType Id
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Airline Coding Application').getRecordTypeId();

        // Query Case Object
        return Database.getQueryLocator([
                SELECT id
                FROM Case
                WHERE Id IN (
                        SELECT Case__c
                        FROM Participation_Online_Application__c
                        WHERE LastModifiedDate < :dateToDeleteTo
                )
                AND Status = 'Open'
                AND RecordTypeId = :recordTypeId
        ]);

    }

    global void execute(Database.BatchableContext BC, List<Case> scope) {

        List <Participation_Online_Application__c> participationList = [SELECT Id FROM Participation_Online_Application__c WHERE Case__c IN :scope];
        if ( scope.size() > 0){
            delete scope;
        }

        if ( participationList.size() > 0 ){
            delete participationList;
        }

    }

    global void finish(Database.BatchableContext BC) {
    }

}