public with sharing class Contact_Dom {
	/****************************************************************************************************
			Call trigger method corresponding to trigger event
	****************************************************************************************************/
	public static void triggerHandler() {
		//*** instantiate the domain class to prevent too many static methods
		Contact_Dom exe = new Contact_Dom();

		//*** call handler method corresponding to trigger event
		if (trigger.isAfter)
		{
			if (trigger.isUpdate) exe.onAfterUpdate();
		}
	} //*** end of "triggerHandler"

	/****************************************************************************************************
			Data variables
	****************************************************************************************************/
	private List<Contact> newList = new List<Contact>();
	private List<Contact> oldList = new List<Contact>();
	private Map<Id, Contact> newMap = new Map<Id, Contact>();
	private Map<Id, Contact> oldMap = new Map<Id, Contact>();

	/****************************************************************************************************
			Set trigger data to data variables
	****************************************************************************************************/
	private void getData(Boolean newDataAvailable, Boolean oldDataAvailable) {
		if (newDataAvailable) {
			newList = (List<Contact>) trigger.new;
			newMap = (Map<Id, Contact>) trigger.newMap;
		}
		if (oldDataAvailable) {
			oldList = (List<Contact>) trigger.old;
			oldMap = (Map<Id, Contact>) trigger.oldMap;
		}
	} //*** end of "getData"

	private void onAfterUpdate() {
		getData(true, true);

		//On demand test run
		if (Test.isRunningTest() && Utility.getNumericSetting('Execute Trigger Contact') != 1) return;

		//Contact to Sync with SAP
		contact_svc.contactLocationToSynWithSap(newMap,oldMap);


	}

}
