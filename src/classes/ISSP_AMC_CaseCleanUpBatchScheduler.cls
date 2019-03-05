/*
    Class Name: ISSP_AMC_CaseCleanUpBatchScheduler
    Related Classes:

    Copyright @PwC

    Purpose: Scheduler class of the ISSP_AMC_CaseCleanUpBatchScheduler Batch Class

    VERSION     AUTHOR              DATE        DETAIL/CHANGE REFERENCE
    1.0         Samuel Anjos       03-2019      INITIAL DEVELOPMENT
*/

global class ISSP_AMC_CaseCleanUpBatchScheduler implements Schedulable{


    global void execute(SchedulableContext SC) {

        ISSP_AMC_CaseCleanUpBatch cleanUpBatch = new ISSP_AMC_CaseCleanUpBatch();

        Database.executeBatch(cleanUpBatch);

    }
}