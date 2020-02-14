public class ANG_CreateSObjectQueueable implements Queueable {
	private SObject objectToCreate;
	private List<SObject> objectsToCreate;

    public ANG_CreateSObjectQueueable(SObject objectToCreate) {
		this.objectToCreate = objectToCreate;
	}

    public ANG_CreateSObjectQueueable(List<SObject> objectsToCreate) {
		this.objectsToCreate = objectsToCreate;
	}
	
	public void execute(QueueableContext context) {
		if (objectToCreate != null)
			insert this.objectToCreate;
		else if (objectsToCreate != null)
			insert this.objectsToCreate;
	}
}