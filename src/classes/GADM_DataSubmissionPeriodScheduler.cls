global without sharing class GADM_DataSubmissionPeriodScheduler implements Schedulable {

    global void execute(SchedulableContext context) {
        checkDataSubmissions(Date.today());
    }

    private void checkDataSubmissions(Date dateToCompare) {
        GADM_DataSubmissionPeriodHelper.notifyContacts(dateToCompare);
    }



}