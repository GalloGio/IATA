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
    
    public void onAfterUpdate(){ 
        ANG_TrackingHistory.trackHistory(Trigger.newMap, Trigger.oldMap, 'User', 'User_History__c');
    }

    public void onAfterInsert(){
    	assignUserFederationId();
    }

    // ************************************************************
    // ********************* action methods ***********************
    // ************************************************************
	
	private void assignContactFederationId(){
         for(User u : triggerNew){
            if(u.contactId != null) {
            String fedID = String.valueOf(u.contactId).left(15);
            u.FederationIdentifier = fedID;
                system.debug('contact ID' + u.contactId);
                system.debug('fedID' + fedID);
            }
         }
     }


	private void assignUserFederationId() {

		List<Id> users = new List<Id>();
		for(User u : triggerNew){
			if(u.FederationIdentifier == null) users.add(u.Id);
		}

        if(!users.isEmpty()) setFederationId(users);
	}

    @Future
    private static void setFederationId(List<Id> userIds) {
        List<User> users = new List<User>();
        for(Id u : userIds) users.add(new User(Id = u, FederationIdentifier = u));

        doNotRun = true; //prevent recursion of triggers
        update users;
        doNotRun = false;
    }		
}