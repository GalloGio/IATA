public with sharing class Term_And_Condition_Dom
{
	/****************************************************************************************************
			Data variables
	****************************************************************************************************/
	private List<Term_And_Condition__c> newList = new List<Term_And_Condition__c>();
	private List<Term_And_Condition__c> oldList = new List<Term_And_Condition__c>();
	private Map<Id, Term_And_Condition__c> newMap = new Map<Id, Term_And_Condition__c>();
	private Map<Id, Term_And_Condition__c> oldMap = new Map<Id, Term_And_Condition__c>();


	/****************************************************************************************************
			Call trigger method corresponding to trigger event
	****************************************************************************************************/
	public static void triggerHandler() {
		//*** instantiate the domain class to prevent too many static methods
		Term_And_Condition_Dom exe = new Term_And_Condition_Dom();

		//*** call handler method corresponding to trigger event
		if (trigger.isBefore) {
		 	if (trigger.isInsert) exe.onBeforeInsert();
			else if (trigger.isUpdate) exe.onBeforeUpdate();
			/*else if (trigger.isDelete) exe.onBeforeDelete();*/
		} else if (trigger.isAfter) {
			/*if (trigger.isInsert) exe.onAfterInsert();
			else*/ if (trigger.isUpdate) exe.onAfterUpdate();
			//else if (trigger.isDelete) exe.onAfterDelete();
		}
	} //*** end of "triggerHandler"


	/****************************************************************************************************
			Set trigger data to data variables
	****************************************************************************************************/
	private void getData(Boolean newDataAvailable, Boolean oldDataAvailable) {
		if (newDataAvailable) {
			newList = (List<Term_And_Condition__c>) trigger.new;
			newMap = (Map<Id, Term_And_Condition__c>) trigger.newMap;
		}
		if (oldDataAvailable) {
			oldList = (List<Term_And_Condition__c>) trigger.old;
			oldMap = (Map<Id, Term_And_Condition__c>) trigger.oldMap;
		}
	} //*** end of "getData"

	/****************************************************************************************************
			Method for event
	****************************************************************************************************/
	private void onBeforeInsert()
	{
		getData(true, false);
		Term_And_Condition_Svc.validateTnC(null, newList);
	}

	private void onBeforeUpdate()
	{
		getData(true, true);
		Term_And_Condition_Svc.validateTnC(oldMap, newList);
	}

	private void onAfterUpdate() {
		getData(true, true);

		//-- If Status become Final and attachment changed then send notification
		List<Term_And_Condition__c> lst = Term_And_Condition_Svc.getFinalTerms(oldMap, newList);
		if(lst.size() > 0)
			Term_And_Condition_Svc.notifyAutoRenewCustomers(lst);
	}

	/*private void onAfterInsert()
	{
		getData(true, true);
	}*/

	/*private void onBeforeDelete() {
		getData(false, true);
	}*/

	/*private void onAfterDelete() {
		getData(true, true);
	}*/
}
