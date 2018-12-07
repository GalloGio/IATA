public without sharing class Account_Dom { 
	/****************************************************************************************************
	        Call trigger method corresponding to trigger event
	****************************************************************************************************/
	public static void triggerHandler() {
	    //*** instantiate the domain class to prevent too many static methods
	    Account_Dom exe = new Account_Dom();
	    
	    //*** call handler method corresponding to trigger event
	    if (trigger.isAfter)
	    {
	        if (trigger.isUpdate) exe.onAfterUpdate();
	    }
	} //*** end of "triggerHandler"

	/****************************************************************************************************
	        Data variables
	****************************************************************************************************/
	private List<Account> newList = new List<Account>();
	private List<Account> oldList = new List<Account>();
	private Map<Id, Account> newMap = new Map<Id, Account>();
	private Map<Id, Account> oldMap = new Map<Id, Account>();
	
	/****************************************************************************************************
	        Set trigger data to data variables
	****************************************************************************************************/
	private void getData(Boolean newDataAvailable, Boolean oldDataAvailable) {
		if (newDataAvailable) {
	        newList = (List<Account>) trigger.new;
	        newMap = (Map<Id, Account>) trigger.newMap;
		}
	    if (oldDataAvailable) {
	        oldList = (List<Account>) trigger.old;
	        oldMap = (Map<Id, Account>) trigger.oldMap;
	    }
	} //*** end of "getData"

	/****************************************************************************************************
	        Method for event
	****************************************************************************************************/
	private void onAfterUpdate() {

		//This is a special custom setting to be added for each test class, and it is used to force skipping the trigger to avoid running unit test
		if (Test.isRunningTest() && Utility.getNumericSetting('Execute Trigger Account') != 1) return;

	    getData(true, true);
	    
	    // Sync account updates with SAP
	    Account_Svc.syncAccountUpdateWithExternalSystems(newList, oldMap);
	}
}