public with sharing class Product_Term_Condition_Dom
{
	/****************************************************************************************************
			Data variables
	****************************************************************************************************/
	private List<Product_Term_Condition__c> newList = new List<Product_Term_Condition__c>();
	private List<Product_Term_Condition__c> oldList = new List<Product_Term_Condition__c>();
	private Map<Id, Product_Term_Condition__c> newMap = new Map<Id, Product_Term_Condition__c>();
	private Map<Id, Product_Term_Condition__c> oldMap = new Map<Id, Product_Term_Condition__c>();


	/****************************************************************************************************
			Call trigger method corresponding to trigger event
	****************************************************************************************************/
	public static void triggerHandler() {
		//*** instantiate the domain class to prevent too many static methods
		Product_Term_Condition_Dom exe = new Product_Term_Condition_Dom();

		//*** call handler method corresponding to trigger event
		if (trigger.isBefore) {
		 	if (trigger.isInsert) exe.onBeforeInsert();
			else if (trigger.isUpdate) exe.onBeforeUpdate();
			/*else if (trigger.isDelete) exe.onBeforeDelete();*/
		} else if (trigger.isAfter) {
			if (trigger.isInsert) exe.onAfterInsert();
			//else if (trigger.isUpdate) exe.onAfterUpdate();
			//else if (trigger.isDelete) exe.onAfterDelete();
		}
	} //*** end of "triggerHandler"


	/****************************************************************************************************
			Set trigger data to data variables
	****************************************************************************************************/
	private void getData(Boolean newDataAvailable, Boolean oldDataAvailable) {
		if (newDataAvailable) {
			newList = (List<Product_Term_Condition__c>) trigger.new;
			newMap = (Map<Id, Product_Term_Condition__c>) trigger.newMap;
		}
		if (oldDataAvailable) {
			oldList = (List<Product_Term_Condition__c>) trigger.old;
			oldMap = (Map<Id, Product_Term_Condition__c>) trigger.oldMap;
		}
	} //*** end of "getData"

	/****************************************************************************************************
			Method for event
	****************************************************************************************************/
	private void onBeforeInsert() {
		getData(true, false);

		Product_Term_Condition_Svc.validateProductTnC(newList);
	}

	private void onAfterInsert()
	{
		getData(true, true);
	}

	private void onBeforeUpdate() {
		getData(true, true);

		Product_Term_Condition_Svc.validateProductTnC(newList);
	}

	/*private void onAfterUpdate() {
		getData(true, true);
	}*/

	/*private void onBeforeDelete() {
		getData(false, true);
	}*/

	/*private void onAfterDelete() {
		getData(true, true);
	}*/
}
