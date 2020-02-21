public with sharing class ProductEmailNotification_Dom {

	public static void triggerHandler() {
		//*** instantiate the domain class to prevent too many static methods
		ProductEmailNotification_Dom exe = new ProductEmailNotification_Dom();

		//*** call handler method corresponding to trigger event
		if (trigger.isBefore) {
				 /*if (trigger.isInsert) exe.onBeforeInsert();
			*/
			if(trigger.isInsert) exe.onBeforeInsert();
			else if (trigger.isUpdate) exe.onBeforeUpdate();
			//else if (trigger.isDelete) exe.onBeforeDelete();
		} else if (trigger.isAfter) {
			/*if (trigger.isInsert) exe.onAfterInsert();
			else if (trigger.isUpdate) exe.onAfterUpdate();
			else if (trigger.isDelete) exe.onAfterDelete();*/
		}
	}

	/****************************************************************************************************
			Data variables
	****************************************************************************************************/
	private List<Product_Email_Notification__c> newList = new List<Product_Email_Notification__c>();
	private List<Product_Email_Notification__c> oldList = new List<Product_Email_Notification__c>();
	private Map<Id, Product_Email_Notification__c> newMap = new Map<Id, Product_Email_Notification__c>();
	private Map<Id, Product_Email_Notification__c> oldMap = new Map<Id, Product_Email_Notification__c>();

	/****************************************************************************************************
			Set trigger data to data variables
	****************************************************************************************************/
	private void getData(Boolean newDataAvailable, Boolean oldDataAvailable) {
		if (newDataAvailable) {
			newList = (List<Product_Email_Notification__c>) trigger.new;
			newMap = (Map<Id, Product_Email_Notification__c>) trigger.newMap;
		}
		/*if (oldDataAvailable) {
			oldList = (List<Product_Email_Notification__c>) trigger.old;
			oldMap = (Map<Id, Product_Email_Notification__c>) trigger.oldMap;
		}*/
	}

	/****************************************************************************************************
			Method for event
	****************************************************************************************************/
	private void onBeforeInsert() {
		getData(true, false);
		//Prevent Internal and External emails entry at the same time
		ProductEmailNotification_Svc.preventInternalAndExternalEntry(newList);
	}

	private void onBeforeUpdate(){
		getData(true, false);
		//Prevent Internal and External emails entry at the same time
		ProductEmailNotification_Svc.preventInternalAndExternalEntry(newList);
	}

}
