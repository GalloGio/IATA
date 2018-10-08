public class AsyncDML_Util implements Queueable {

	public static final String DML_INSERT = 'insert';
	public static final String DML_UPDATE = 'update';
	public static final String DML_DELETE = 'delete';
	public static final String DML_UPSERT = 'upsert';
	public static final String DML_UNDELETE = 'undelete';

	private List<SObject> records {get;set;}
	private Boolean allOrNone {get;set;}
	private String typeOfOperation {get;set;}

	public AsyncDML_Util(List<SObject> records, String typeOfOperation, Boolean allOrNone) {
		this.records = records;
		this.typeOfOperation = typeOfOperation;
		this.allOrNone = allOrNone;
	}

	public void execute(QueueableContext context) {
		if(typeOfOperation == DML_INSERT) {
			Database.insert(records, allOrNone);
		} else if(typeOfOperation == DML_UPDATE) {
			Database.update(records, allOrNone);
		} else if(typeOfOperation == DML_UPSERT) {
			Database.upsert(records, allOrNone);
		} else if(typeOfOperation == DML_DELETE) {
			Database.delete(records, allOrNone);
		} else if(typeOfOperation == DML_UNDELETE) {
			Database.undelete(records, allOrNone);
		}
	}

}