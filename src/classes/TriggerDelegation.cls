public class TriggerDelegation implements Queueable{

	public class TriggerDelegationException extends Exception{}

	private static TriggerDelegation instance;
	private String originalCaller;
	private Integer executeCheck;
	private List<TriggerAction> actions;
	private Id jobId;

	public static TriggerDelegation register(String handlerName){
		if(instance == null){
			instance = new TriggerDelegation();
			instance.actions = new List<TriggerAction>();
			instance.originalCaller = handlerName;
			instance.executeCheck = 0;
		}

		if(handlerName == instance.originalCaller) instance.executeCheck++;
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

	public void enqueue(String handlerName){
		if(originalCaller != handlerName) executeCheck--;

		if(executeCheck > 0 || actions.isEmpty()) return;

		if(jobId != null) System.abortJob(jobId);
		jobId = System.enqueueJob(this);
	}

	public void execute(QueueableContext qc){
		TriggerHandler handler = (TriggerHandler)Type.forName(originalCaller).newInstance();
		UnitOfWork uw = handler.getUnitOfWork();
		for(TriggerAction a : actions) a.executeFuture(uw);
		uw.commitWork();
	}

}