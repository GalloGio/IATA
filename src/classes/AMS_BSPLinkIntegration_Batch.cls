global class AMS_BSPLinkIntegration_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts{
	private list<Agency_Authorization__c> lsToRemove;
	private string sEmailUser;
	private string sProcess;
	private list<AMS_BSPLinkIntegration.Response> lsResponse;
	private id CaseId;
	
	global AMS_BSPLinkIntegration_Batch(string sEmail, list<Agency_Authorization__c> ls, string sPr, id CaseId){
		this.sEmailUser = sEmail;
		this.lsToRemove = ls;
		this.sProcess = sPr;
		this.lsResponse = new list<AMS_BSPLinkIntegration.Response>();
		this.CaseId = CaseId;
	}
	
	global List<Agency_Authorization__c> start(Database.BatchableContext BC){
		return (this.lsToRemove);
	}

	global void execute(Database.BatchableContext BC, list<Agency_Authorization__c> scope){
		list<id> AccountIds = new list<id>();
		for(Agency_Authorization__c aa:scope)
			AccountIds.add(aa.Account__c);
		
		lsResponse.addAll(AMS_BSPLinkIntegration.ProcessBSPLinkFromCase(this.sProcess, AccountIds, 'List', CaseId));
	}

	global void finish(Database.BatchableContext BC){
		string sMailBody = this.sProcess + ' completed';
		
		for(AMS_BSPLinkIntegration.Response rsp:this.lsResponse){
			sMailBody = sMailBody + rsp.result + ': ';
			sMailBody = sMailBody + rsp.description + '\n';
		}
		
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
        email.setSubject(this.sProcess + ' completed');
        email.setPlainTextBody( 'Results: \n\n' +  sMailBody );
        email.setToAddresses( new list<string>{sEmailUser} );

        // Sends the email
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
	}	
}