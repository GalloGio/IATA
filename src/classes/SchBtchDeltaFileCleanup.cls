/**  
  * Description: Scheduler class to run daily for Delta entries cleanup older than 2 months 
  * Author: Abdellah Bellahssan
  * Version: 1.0
  * History: 
  */
global class SchBtchDeltaFileCleanup implements Schedulable {
   global void execute(SchedulableContext sc) {
        BtchDeltaFileCleanup BDel = new BtchDeltaFileCleanup();
        Datetime d = Datetime.now();
        d = d.addDays(-62);
        // Query for selecting the documents to delete
        BDel.query = 'SELECT Id FROM GDP_Delta__c WHERE DeltaLastModifiedDate__c < '+d.format('yyyy-MM-dd') ; // +'T'+d.format('HH:mm')+':00.000Z';
        // Invoke the batch job.
        ID batchprocessid = Database.executeBatch(BDel);
        System.debug('Returned batch process ID: ' + batchProcessId);
   }
}