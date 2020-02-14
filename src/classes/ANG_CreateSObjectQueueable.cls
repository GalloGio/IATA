public class ANG_CreateSObjectQueueable implements Queueable {
	private List<SObject> objectsToCreate;
	
	public ANG_CreateSObjectQueueable(SObject objectToCreate) {
		this(new List<SObject> { objectToCreate });
	}
	
	public ANG_CreateSObjectQueueable(List<SObject> objectsToCreate) {
		this.objectsToCreate = objectsToCreate;
	}
	
	public void execute(QueueableContext context) {
		Savepoint sp = Database.setSavepoint();
		try {
			if (objectsToCreate != null && ! objectsToCreate.isEmpty())
				insert this.objectsToCreate;
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, '____ [cls ANG_CreateSObjectQueueable - execute] Exception: ' + e.getMessage());
			System.debug(LoggingLevel.ERROR, '____ [cls ANG_CreateSObjectQueueable - execute] Exception Stacktrace: ' + e.getStackTraceString());
			Database.rollback(sp);
			commitTechnicalLogs(new Technical_Logs__c(
				Operation__c = 'ANG_CreateSObjectQueueable - Creating new SObjects',
				Status__c = (e.getMessage() + '\n' + e.getStackTraceString()).left(254),
				Log__c = JSON.serialize(objectsToCreate)));
		}
	}

	public static void commitTechnicalLogs(Technical_Logs__c technicalLogs) {
		try {
			System.debug(LoggingLevel.INFO, '____ [cls ANG_CreateSObjectQueueable - commitTechnicalLogs] technicalLogs: ' + technicalLogs);
			insert technicalLogs;
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, '____ [cls ANG_CreateSObjectQueueable - commitTechnicalLogs] Exception: ' + e.getMessage());
			System.debug(LoggingLevel.ERROR, '____ [cls ANG_CreateSObjectQueueable - commitTechnicalLogs] Exception Stacktrace: ' + e.getStackTraceString());
		}
		
	}
}