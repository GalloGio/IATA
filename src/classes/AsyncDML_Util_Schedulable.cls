public class AsyncDML_Util_Schedulable implements Schedulable {

    private List<SObject> records {get;set;}
    private Boolean allOrNone {get;set;}
    private String typeOfOperation {get;set;}
    
    public AsyncDML_Util_Schedulable(List<SObject> records, String typeOfOperation, Boolean allOrNone) {
        this.records = records;
        this.typeOfOperation = typeOfOperation;
        this.allOrNone = allOrNone;
    }
    
    public void execute(SchedulableContext sc) {
        System.enqueueJob(new AsyncDML_Util(records, typeOfOperation, allOrNone));
        // Abort the job once the job is queued
        System.abortJob(sc.getTriggerId());
    }
}