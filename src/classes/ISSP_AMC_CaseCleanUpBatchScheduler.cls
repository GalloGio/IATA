/**
 * Created by Samuel Anjos on 2019-03-04.
 */

global class ISSP_AMC_CaseCleanUpBatchScheduler implements Schedulable{


    global void execute(SchedulableContext SC) {

        ISSP_AMC_CaseCleanUpBatch cleanUpBatch = new ISSP_AMC_CaseCleanUpBatch();
        Database.executeBatch(cleanUpBatch);

    }
}