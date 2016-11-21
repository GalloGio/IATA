/**  
  * Description: This class contains batchable class for processing SAP Invoices and sending them to SAP
  * Note: Using batch to avoid two issues:
  *		1- Supporting Callout on Schedulable Jobs
  * Author: Alexandre McGraw
  * Version: 1.0
  * History: 
  */
global class BtchIECSendInvoicesToSAP implements Database.Batchable<sObject>, Database.AllowsCallouts {

	public String query;

    global Database.querylocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
    	
    	List<IEC_SAP_Invoice__c> lstSAPInvoicesToSend = new List<IEC_SAP_Invoice__c>();
    	for (sObject sObj : scope) 
    		lstSAPInvoicesToSend.add((IEC_SAP_Invoice__c)sObj);
    	
		IECSAPManager.sendInvoicesToSAP(lstSAPInvoicesToSend);
    }

    global void finish(Database.BatchableContext BC) {
	}
}