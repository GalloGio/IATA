public abstract class TriggerAction {

	private List<SObject> records = new List<SObject>();

	public void filter(SObject s){
		if(isRelevant(s)) records.add(s);
	}

	public void executeAction(UnitOfWork uw){

		if(records.isEmpty()) return;
		else{
			execute(records, uw);
		}
	}

	protected void registerFuture(){
		TriggerDelegation.addAction(this);
	}

	//future action receives a clean unit of work from the delegation
	public void executeFuture(UnitOfWork uw){
		futureAction(uw);
	}

	protected abstract Boolean isRelevant(SObject s);
	protected abstract void execute(List<SObject> records, UnitOfWork uw);
	protected virtual void futureAction(UnitOfWork uw) {}

}