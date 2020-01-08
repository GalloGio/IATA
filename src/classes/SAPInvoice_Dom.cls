/**
 *
 * @author: Kevin Ky <kevin.ky@cgi.com>
 * @date: 2015-12-03
 *
 *
 **/
public without sharing class SAPInvoice_Dom {

	/****************************************************************************************************

		Call trigger method corresponding to trigger event
	****************************************************************************************************/
	public static void triggerHandler() {
		//*** instantiate the domain class to prevent too many static methods
		SAPInvoice_Dom exe = new SAPInvoice_Dom();

		//*** call handler method corresponding to trigger event
		if (trigger.isBefore) {
				 /*if (trigger.isInsert) exe.onBeforeInsert();
			else if (trigger.isUpdate) exe.onBeforeUpdate();
			else if (trigger.isDelete) exe.onBeforeDelete();*/
		} else if (trigger.isAfter) {
				 if (trigger.isInsert) exe.onAfterInsert();
			/*else if (trigger.isUpdate) exe.onAfterUpdate();
			else if (trigger.isDelete) exe.onAfterDelete();*/
		}
	} //*** end of "triggerHandler"

	/****************************************************************************************************
			Data variables
	****************************************************************************************************/
	private List<SAP_Invoice__c> newList = new List<SAP_Invoice__c>();
	//private List<SAP_Invoice__c> oldList = new List<SAP_Invoice__c>();
	private Map<Id, SAP_Invoice__c> newMap = new Map<Id, SAP_Invoice__c>();
	//private Map<Id, SAP_Invoice__c> oldMap = new Map<Id, SAP_Invoice__c>();

	/****************************************************************************************************
			Set trigger data to data variables
	****************************************************************************************************/
	private void getData(Boolean newDataAvailable, Boolean oldDataAvailable) {
		if (newDataAvailable) {
			newList = (List<SAP_Invoice__c>) trigger.new;
			newMap = (Map<Id, SAP_Invoice__c>) trigger.newMap;
		}
		/*if (oldDataAvailable) {
			oldList = (List<SAP_Invoice__c>) trigger.old;
			oldMap = (Map<Id, SAP_Invoice__c>) trigger.oldMap;
		}*/
	} //*** end of "getData"


	/****************************************************************************************************
			Method for event
	****************************************************************************************************/
	/*private void onBeforeInsert() {
		//getData(true, false);
	}
	private void onBeforeUpdate() {
		//getData(true, true);
	}
	private void onBeforeDelete() {
		//getData(false, true);
	}*/
	private void onAfterInsert() {
		getData(true, false);
		//Link the zProduct to Product
		SAPInvoice_Svc.updateOrderStatus(newList);
	}
	/*private void onAfterUpdate() {
		//getData(true, true);

	}
	private void onAfterDelete() {
		//getData(false, true);
	}*/

}
