global class Attachment_Sch implements Schedulable {

	//schedule the batch to delete SAP Invoices 
	//runs every day at 1 AM. '0 0 1 * * ?'
	global static String scheduleDeleteSAPInvoices(String CRON_EXP) {
        Attachment_Sch attachmentSch = new Attachment_Sch();
        return System.schedule('SAP Invoices to delete', CRON_EXP, attachmentSch);
    }
    
	global void execute(SchedulableContext sc) {
	  	Attachment_Batch batch = new Attachment_Batch('sapinvtodelete');
	    Database.executebatch(batch); 	    
	}
	
}