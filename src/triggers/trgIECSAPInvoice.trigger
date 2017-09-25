/**  
  * Description: Trigger for the SAP Invoice object for the IEC project
  * Author: Samy Saied
  * Version: 1.0
  * History: 
  */

trigger trgIECSAPInvoice on IEC_SAP_Invoice__c (before insert, before update, after insert, after update, after delete) {
	if(Trigger.isUpdate && Trigger.isAfter) {
		trgHndlrIECSAPInvoice.OnAfterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
	}

	if (Trigger.isBefore) { //INC295559
		if(Trigger.isInsert || Trigger.isUpdate){
			trgHndlrIECSAPInvoice.OnBeforeInsert(Trigger.new);			
		}
	}
}