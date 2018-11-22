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

		/*as the register - method that increments the executeCheck variable - is executed in every trigger type of operation 
		and this method is only executed for After Triggers, the executeCheck variable needs to be decremented twice
		Example: first Before Trigger register - executeCheck = 1
				 second Before Trigger register - executeCheck = 2
				 second After Trigger register - executeCheck = 3
				 second After Trigger enqueue - executeCheck = 1
				 first After Trigger register - executeCheck = 2
				 first After Trigger enqueue - executeCheck = 0 */
		if(originalCaller == handlerName) executeCheck-=2;

		if(executeCheck > 0 || actions.isEmpty()) return;

		/* !Test.isRunningTest() is needed because in test context, the method enqueueJob returns an empty value
		   as the value returned is not exactly null, the test classe fails in the abortJob even with the validation
		   This is a salesforce known issue:
		   https://success.salesforce.com/issues_view?id=a1p300000008XJvAAM&title=system-enqueuejob-returns-null-in-apex-tests */
		if(jobId != null && !Test.isRunningTest()) System.abortJob(jobId);

		jobId = System.enqueueJob(this);

		//since the actions were already enqueued, this instance is no longer needed
		instance = null;
	}

	public void execute(QueueableContext qc){
		TriggerHandler handler = (TriggerHandler)Type.forName(originalCaller).newInstance();
		UnitOfWork uw = handler.getUnitOfWork();
		for(TriggerAction a : actions) a.executeFuture(uw);
		uw.commitWork();
	}

}