/**  
  * Description: Trigger for the SAP Invoice object for the IEC project
  * Author: Samy Saied
  * Version: 1.0
  * History: 
  */

trigger trgIECSAPInvoice on IEC_SAP_Invoice__c (after update) {
	if(Trigger.isUpdate && Trigger.isAfter) {
		trgHndlrIECSAPInvoice.OnAfterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
	}
}