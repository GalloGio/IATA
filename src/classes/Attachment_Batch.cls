/*
	Batch to clean up the SAP Invoices as an attachment
*/
global class Attachment_Batch implements Database.Batchable<sObject> {
	
	String action;
	
	global Attachment_Batch(String action) {
		this.action = action;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, ParentId FROM Attachment WHere Name LIKE \'801%\'' + (!Test.isRunningTest() ? ' and CreatedDate < TODAY' : '');
        return Database.getQueryLocator(query);
    }

   	global void execute(Database.BatchableContext BC, List<Attachment> scope) {
		if(action == 'sapinvtodelete'){
			Attachment_Svc.deleteAttachments(scope);
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}