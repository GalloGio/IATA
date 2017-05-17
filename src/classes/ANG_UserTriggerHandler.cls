public class ANG_UserTriggerHandler {

	private List<User> triggerNew = (List<User>) Trigger.new;
    private List<User> triggerOld = (List<User>) Trigger.old;

    private Map<Id, User> newMap = (Map<Id,User>) Trigger.newMap;
    private Map<Id, User> oldMap = (Map<Id,User>) Trigger.oldMap;

    public static Boolean doNotRun{
    	get{
    		if(doNotRun == null) doNotRun = false;
    		return doNotRun;
    	}
    	private set;
    }

    // ************************************************************
    // ****************** distribution methods ********************
    // ************************************************************

    public void onBeforeInsert(){
    	assignContactFederationId();
    }

    public void onBeforeUpdate(){ }

    public void onAfterInsert(){
    	assignUserFederationId();
    }

    // ************************************************************
    // ********************* action methods ***********************
    // ************************************************************
	
	private void assignContactFederationId(){
		for(User u : triggerNew){
			u.FederationIdentifier = u.contactId;
		}
	}

	private void assignUserFederationId() {

		List<User> users = new List<User>();
		for(User u : triggerNew){
			if(u.FederationIdentifier == null) users.add(new User(Id = u.Id, FederationIdentifier = u.Id));
		}

		doNotRun = true; //prevent recursion of triggers
		update users;
		doNotRun = false;
	}
	
}
