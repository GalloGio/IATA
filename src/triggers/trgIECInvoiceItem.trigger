/**  
  * Description: Trigger for the Invoice Item object
  * Author: Samy Saied
  * Version: 1.0
  * History: 
  */
trigger trgIECInvoiceItem on Invoice_Item__c (after insert) {
    if(Trigger.isInsert && Trigger.isAfter) {
		trgHndlrIECInvoiceItem.OnAfterInsert(Trigger.new, Trigger.newMap);
	}
}