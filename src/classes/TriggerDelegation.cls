public class TriggerDelegation implements Queueable{

	public class TriggerDelegationException extends Exception{}

	private static TriggerDelegation instance;
	private TriggerHandler originalCaller;
	private List<TriggerAction> actions;
	private Id jobId;
	
	public static TriggerDelegation register(TriggerHandler handler){
		if(instance == null){
			instance = new TriggerDelegation();
			instance.actions = new List<TriggerAction>();
			instance.originalCaller = handler;
		}

		return getInstance();
	}

	public static TriggerDelegation getInstance(){
		if(instance == null){
			throw new TriggerDelegationException('TriggerDelegation must be registered by the TriggerHandler before being called');
		}

		return instance;
	}

	public static void addAction(TriggerAction a){
		instance.actions.add(a);
	}

	public void enqueue(TriggerHandler handler){

		if(originalCaller != handler || actions.isEmpty()) return;

		if(jobId != null) System.abortJob(jobId);
		jobId = System.enqueueJob(this);
	}

	public void execute(QueueableContext qc){
		UnitOfWork uw = originalCaller.getUnitOfWork();
		for(TriggerAction a : actions) a.executeFuture(uw);
		uw.commitWork();
	}

}