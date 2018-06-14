/**
    This batch is for Generic purpose
    You can use it to update a large list of any kind of Object in async.
    Use:
        call run static method passing your list and the batch size, 200 suggested
    Example:
        BatchUpdate.run(myList, 200);
**/
global  class BatchUpdate implements Database.Batchable<sObject> {
    private list<sObject> listObject;

    global BatchUpdate (list<sObject> listObject) {
        this.listObject = listObject;
    }

    global Iterable<sObject> start(Database.BatchableContext info){
        return this.listObject;
    }
    global void execute(Database.BatchableContext info, List<sObject> scope){
        Database.update(scope,false);
    }
    global void finish(Database.BatchableContext info){
    }

    public static void run(list<sObject> listObject, Integer batchSize) {
        Database.executeBatch(new BatchUpdate(listObject), batchSize);
    }
}
