/*
    Class Name: ISSP_AMC_CaseCleanUpBatch
    Related Classes:

    Copyright @PwC

    Purpose: Batch Class to clean

    VERSION     AUTHOR              DATE        DETAIL/CHANGE REFERENCE
    1.0         Samuel Anjos       03-2019      INITIAL DEVELOPMENT
    2.0         Manuel Conde       03-2019      Code Reviewed
*/
global class ISSP_AMC_CaseCleanUpBatch implements Database.Batchable<sObject> {

    private Date dateToDeleteTo;

    global ISSP_AMC_CaseCleanUpBatch(){

        AMC_Configuration__c amcConfiguration = AMC_Configuration__c.getInstance();
        Integer numberOfDays = Integer.valueOf(amcConfiguration.Case_Number_Of_Days_To_Delete_To__c);

        dateToDeleteTo = Date.today() - numberOfDays;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {

        // get the RecordType Id by Developer name
        Schema.DescribeSObjectResult R = Case.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> RT = R.getRecordTypeInfos();
        Id recordTypeId;
                for(Schema.RecordTypeInfo aRT : RT){
            if(aRT.getDeveloperName().equals('Airline_Coding_Application')){
                recordTypeId = aRT.getRecordTypeId();
            }
        }

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

        if(!scope.isEmpty()) delete scope;

        if(!participationList.isEmpty()) delete participationList;


    }

    global void finish(Database.BatchableContext BC) {
    }

}