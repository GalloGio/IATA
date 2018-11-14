public abstract class TriggerHandler {

	private TriggerDelegation delegator;
	private UnitOfWork uw;
	private String handlerName;

	private static void runHandler(String handlerName){

		TriggerHandler handler = (TriggerHandler)Type.forName(handlerName).newInstance();
		handler.handlerName = handlerName;
		handler.run();
	}

	public void run() {

		//check for trigger bypass
		uw = getUnitOfWork();
		delegator = TriggerDelegation.register(handlerName);

		runTrigger(Trigger.operationType);
		
		uw.commitWork();
		if(Trigger.isAfter) delegator.enqueue(handlerName);
	}

	private void runTrigger(System.TriggerOperation op) {
		List<TriggerAction> actions = getActions(op);

		for(SObject s : Trigger.isDelete ? Trigger.old : Trigger.new){
			for(TriggerAction a : actions) a.filter(s);
		}

		for(TriggerAction a : actions) a.executeAction(uw);
	}

	private List<TriggerAction> getActions(System.TriggerOperation op){
		List<Type> actions;
		switch on op {
		    when BEFORE_INSERT{ actions = getBeforeInsertActions(); }
		    when BEFORE_UPDATE{ actions = getBeforeUpdateActions(); }
		    when BEFORE_DELETE{ actions = getBeforeDeleteActions(); }
		    when AFTER_INSERT{ actions = getAfterInsertActions(); }
		    when AFTER_UPDATE{ actions = getAfterUpdateActions(); }
		    when AFTER_DELETE{ actions = getAfterDeleteActions(); }
		    when AFTER_UNDELETE{ actions = getAfterUndeleteActions(); }
		}
		return convertToActions(actions);
	}

	private List<TriggerAction> convertToActions(List<Type> actionClasses){
		List<TriggerAction> actions = new List<TriggerAction>();

		for(Type a : actionClasses){
			String actionName = a.getName();
			//check for actionbypass

			actions.add((TriggerAction)a.newInstance());
		}
		return actions;
	}

	public virtual UnitOfWork getUnitOfWork(){
		return new UnitOfWork(getSObjectTypes());
	}

	protected abstract List<Schema.SObjectType> getSObjectTypes();

	protected virtual List<Type> getBeforeInsertActions(){
		return new List<Type>();
	}
	protected virtual List<Type> getBeforeUpdateActions(){
		return new List<Type>();
	}
	protected virtual List<Type> getBeforeDeleteActions(){
		return new List<Type>();
	}
	protected virtual List<Type> getAfterInsertActions(){
		return new List<Type>();
	}
	protected virtual List<Type> getAfterUpdateActions(){
		return new List<Type>();
	}
	protected virtual List<Type> getAfterDeleteActions(){
		return new List<Type>();
	}
	protected virtual List<Type> getAfterUndeleteActions(){
		return new List<Type>();
	}
}